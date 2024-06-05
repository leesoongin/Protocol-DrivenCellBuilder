//
//  CollectionViewAdapter.swift
//  ProtocolDrivenCellBuilder
//
//  Created by 이숭인 on 6/4/24.
//

import UIKit
import Combine

public final class CollectionViewAdapter: NSObject {
    weak var collectionView: UICollectionView?
    var cancellables = Set<AnyCancellable>()
    // 여기의 identifiers는 collectionView register의 reuseIdentifier이다. ModelType의 identifier가 아님.
    var registeredCellIdentifiers: Set<String> = []
    // height strategy의 adaptive를 계산하기 위한 더미
    let dummyViewController = UIViewController()
    
    var sectionModels: [SectionModelType] = []
    
    func sectionModel(at indexPath: IndexPath) -> SectionModelType? {
        sectionModels[indexPath.section]
    }
    
    func itemModel(at indexPath: IndexPath) -> ItemModelType? {
        sectionModels[indexPath.section].itemModels[indexPath.row]
    }
    
    
    let inputSectionsRelay = PassthroughSubject<[SectionModelType], Never>()
    let didUpdateRelay = PassthroughSubject<[SectionModelType], Never>()
    
    public init(with collectionView: UICollectionView) {
        super.init()

        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        bindInputSections()
    }
    
    deinit {
        dummyViewController.view.subviews
            .compactMap { $0 as? ItemModelBindable }
            .forEach { view in
                view.prepareForReuse()
            }
    }
    
    private func bindInputSections() {
        inputSectionsRelay
            .throttle(for: 1, scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] sections in
                self?.updateSections(with: sections)
            })
            .store(in: &cancellables)
    }
    
    private func updateSections(with inputSection: [SectionModelType]) {
        guard let collectionView = collectionView else { return }
        
        
        DispatchQueue.main.async { [weak self] in
            self?.sectionModels = inputSection
            guard let sectionModels = self?.sectionModels else { return }
            
            collectionView.reloadData()
            self?.didUpdateRelay.send(inputSection)
        }
    }
}

extension CollectionViewAdapter: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !sectionModels.isEmpty else {
            return .zero
        }
        return sectionModels[section].itemModels.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellProvider(with: collectionView, indexPath: indexPath)
    }
}

extension CollectionViewAdapter {
    private func cellProvider(with collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let itemModel = itemModel(at: indexPath) else { fatalError() }
        
        let reuseIdentifier = itemModel.viewType.getIdentifier()
        registerCellInNeeded(about: reuseIdentifier, with: itemModel)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        bindItemModelIfNeeded(to: cell, with: itemModel)
        
        return cell
    }
    
    private func registerCellInNeeded(about identifier: String, with itemModel: ItemModelType) {
        guard registeredCellIdentifiers.contains(identifier) == false else { return }
        collectionView?.register(itemModel.viewType.getClass(), forCellWithReuseIdentifier: identifier)
    }
    
    private func bindItemModelIfNeeded(to cell: UICollectionViewCell, with itemModel: ItemModelType) {
        guard let cell = cell as? ItemModelBindableProtocol else { return }
        UIView.performWithoutAnimation {
            cell.bind(with: itemModel)
        }
    }
}


//MARK: - Calculate Size
extension CollectionViewAdapter: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionModel = sectionModels[safe: indexPath.section],
              let itemModel = itemModel(at: indexPath) else {
            return .zero
        }
        let width = getWidthStrategyValue(sectionModel: sectionModel, itemModel: itemModel)
        let height = getHeightStrategyValue(itemModel: itemModel, width: width)
        
        return CGSize(width: width, height: height)
    }
    
    private func getWidthStrategyValue(sectionModel: SectionModelType, itemModel: ItemModelType) -> CGFloat {
        guard let collectionView = collectionView else { return .leastNonzeroMagnitude }
        
        let baseSize = collectionView.bounds.width
        let insets = sectionModel.insets + collectionView.contentInset
        
        let minimumInteritemSpacing = sectionModel.minimumInteritemSpacing
        let withoutInsetSize = max(baseSize - insets.horizontal, 0)
        
        switch itemModel.viewWidthStrategy {
        case .static(let value):
            return value
        case .ration(let value):
            return floor(baseSize * value)
        case .fill:
            return withoutInsetSize
        case .column(let count):
            return floor((withoutInsetSize - (CGFloat(count - 1) * minimumInteritemSpacing)) / CGFloat(count))
        case .adaptive:
            return calculateAdaptiveWidth(at: itemModel)
        }
    }
    
    private func getHeightStrategyValue(itemModel: ItemModelType, width: CGFloat) -> CGFloat {
        guard let collectionView = collectionView else { return .leastNonzeroMagnitude }
        
        let baseSize = collectionView.bounds.height
        
        switch itemModel.viewHeightStartegy {
        case .static(let value):
            return value
        case .ratio(let value):
            return floor(width * value)
        case .ratioWithCollectionView(let value):
            return floor(baseSize * value)
        case .adaptive:
            return calculateAdaptiveHeight(at: itemModel, with: width)
        }
    }
}

extension CollectionViewAdapter {
    private func calculateAdaptiveWidth(at itemModel: ItemModelType) -> CGFloat {
        // 셀 초기화. 기존에 붙어있는 셀을 재활용. 없으면 생성
        let dummyView = createDummyViewIfNeeded(at: itemModel)

        // model을 바인딩하여 크기를 제대로 잡아준다
        dummyView.bind(with: itemModel)

        dummyView.setNeedsLayout()
        dummyView.layoutIfNeeded()
        // prepareForReuse 등에서 disposeBag 등 초기화 할 여지가 있어 호출해준다
        dummyView.prepareForReuse()

        return dummyView.contentView.bounds.width
    }

    private func calculateAdaptiveHeight(at itemModel: ItemModelType, with width: CGFloat) -> CGFloat {
        // 셀 초기화. 기존에 붙어있는 셀을 재활용. 없으면 생성
        let dummyView = createDummyViewIfNeeded(at: itemModel, with: width)

        // model을 바인딩하여 크기를 제대로 잡아준다
        dummyView.bind(with: itemModel)

        dummyView.setNeedsLayout()
        dummyView.layoutIfNeeded()
        // prepareForReuse 등에서 disposeBag 등 초기화 할 여지가 있어 호출해준다
        dummyView.prepareForReuse()

        let height = max(dummyView.contentView.bounds.height,
                         dummyView.sizeThatFits(CGSize(width: width, height: .leastNonzeroMagnitude)).height)

        return height
    }
    
    private func createDummyViewIfNeeded(at itemModel: ItemModelType, with width: CGFloat? = nil) -> ItemModelBindable {
        guard case let .type(viewType) = itemModel.viewType else { fatalError() }

        // 더미 뷰 로드
        dummyViewController.loadViewIfNeeded()

        let existView = dummyViewController.view.subviews.first { type(of: $0) == viewType }
        if let existView = existView as? ItemModelBindable {
            if let anchor = existView.constraints.first(where: { $0.identifier == "dummy_view_width_anchor" }), let width {
                anchor.constant = width
                dummyViewController.view.updateConstraintsIfNeeded()
            }
            return existView
        }

        let dummyView = viewType.init(frame: .zero)
        dummyViewController.view.addSubview(dummyView)

        dummyView.translatesAutoresizingMaskIntoConstraints = false
        dummyView.topAnchor.constraint(equalTo: dummyViewController.view.topAnchor).isActive = true
        dummyView.leadingAnchor.constraint(equalTo: dummyViewController.view.leadingAnchor).isActive = true

        if let width {
            let widthAnchor = dummyView.widthAnchor.constraint(equalToConstant: width)
            widthAnchor.identifier = "dummy_view_width_anchor"
            widthAnchor.isActive = true
        }

        dummyView.contentView.translatesAutoresizingMaskIntoConstraints = false
        dummyView.contentView.topAnchor.constraint(equalTo: dummyView.topAnchor).isActive = true
        dummyView.contentView.leadingAnchor.constraint(equalTo: dummyView.leadingAnchor).isActive = true
        dummyView.contentView.trailingAnchor.constraint(equalTo: dummyView.trailingAnchor).isActive = true
        dummyView.contentView.bottomAnchor.constraint(equalTo: dummyView.bottomAnchor).isActive = true

        return dummyView
    }
}

//MARK: - LineSpacing
extension CollectionViewAdapter {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let sectionModel = sectionModels[safe: section] else { return .zero }

        return sectionModel.insets
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard let sectionModel = sectionModels[safe: section] else { return .zero }

        return sectionModel.minimumLineSpacing
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard let sectionModel = sectionModels[safe: section] else { return .zero }

        return sectionModel.minimumInteritemSpacing
    }
}

public extension UIEdgeInsets {
    static func += (lhs: inout UIEdgeInsets, rhs: UIEdgeInsets) {
        // swiftlint:disable:next shorthand_operator
        lhs = lhs + rhs
    }
    
    static func -= (lhs: inout UIEdgeInsets, rhs: UIEdgeInsets) {
        // swiftlint:disable:next shorthand_operator
        lhs = lhs - rhs
    }
    
    static func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        UIEdgeInsets(top: lhs.top + rhs.top,
                     left: lhs.left + rhs.left,
                     bottom: lhs.bottom + rhs.bottom,
                     right: lhs.right + rhs.right)
    }
    
    static func - (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        UIEdgeInsets(top: lhs.top - rhs.top,
                     left: lhs.left - rhs.left,
                     bottom: lhs.bottom - rhs.bottom,
                     right: lhs.right - rhs.right)
    }
}

public extension UIEdgeInsets {
    var horizontal: CGFloat { self.left + self.right }
    var vertical: CGFloat { self.top + self.bottom }
}

extension Array {
    public subscript(safe index: Index) -> Element? { indices ~= index ? self[index] : nil }
}
