//
//  HomeViewController.swift
//  ProtocolDrivenCellBuilder
//
//  Created by 이숭인 on 6/4/24.
//

import Foundation
import UIKit
import Then
import Combine

final class HomeViewController: ViewController<HomeView> {
    lazy var adapter: CollectionViewAdapter = CollectionViewAdapter(with: contentView.collectionView)
    var cancellables = Set<AnyCancellable>()
    
    var mockComponents: [AssistantCommonErrorComponent] = [
        AssistantCommonErrorComponent(identifier: "1", message: "일일"),
        AssistantCommonErrorComponent(identifier: "2", message: "투"),
        AssistantCommonErrorComponent(identifier: "3", message: "삼"),
        AssistantCommonErrorComponent(identifier: "4", message: "사"),
        AssistantCommonErrorComponent(identifier: "5", message: "오"),
    ]
    
    lazy var sectionModel: [SectionModelType] = [
        SectionModel(identifier: "mock_section", itemModels: mockComponents)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.backgroundColor = .white
        
        bindViewModel()
        bindAdapterUpdate()
    }
    
    private func bindViewModel() {
        _ = adapter.receive(sectionModel)
    }
    
    private func bindAdapterUpdate() {
        adapter.didUpdateRelay
            .sink { [weak self] sections in
                print("didUpdateRelay 호출됨")
            }
            .store(in: &cancellables)
    }
}
