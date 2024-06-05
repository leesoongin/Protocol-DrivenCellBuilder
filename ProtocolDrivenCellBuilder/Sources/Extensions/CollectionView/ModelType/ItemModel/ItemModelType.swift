//
//  ItemModelType.swift
//  ProtocolDrivenCellBuilder
//
//  Created by 이숭인 on 6/4/24.
//

import UIKit

public typealias ItemModelBindable = UICollectionViewCell & ItemModelBindableProtocol
public protocol ItemModelBindableProtocol {
    func bind(with itemModel: ItemModelType)
}

public protocol ItemModelType: ModelType {
    var viewType: ViewType { get }
    var viewWidthStrategy: ViewWidthStrategy { get }
    var viewHeightStartegy: ViewHeightStrategy { get }
}

public enum ViewType {
    case type(ItemModelBindable.Type)
    
    func getClass() -> AnyClass {
        guard case let .type(type) = self else { fatalError() }
        return type
    }
    
    func getIdentifier() -> String {
        guard case let .type(type) = self else { fatalError() }
        return String(describing: type)
    }
}

public enum ViewWidthStrategy: Hashable {
    /// 단순값
    case `static`(CGFloat)
    /// collectionView width size *  비율
    case ration(CGFloat)
    /// collectionView width size 만큼
    case fill
    /// collectionView column 개수
    case column(Int)
    /// Cell의 크기에 맞게
    case adaptive
}

/// CollectionViewCell의 세로 크기 정책
public enum ViewHeightStrategy: Hashable {
    /// 단순값
    case `static`(CGFloat)
    /// alignment 크기 * 비율만큼
    case ratio(CGFloat)
    /// collectionView 세로 크기 * 비율만큼
    case ratioWithCollectionView(CGFloat)
    /// Cell의 크기에 따라
    case adaptive
}
