//
//  HomeViewController.swift
//  ProtocolDrivenCellBuilder
//
//  Created by 이숭인 on 6/4/24.
//

import Foundation
import UIKit
import Then

final class HomeViewController: ViewController<HomeView> {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.backgroundColor = .brown
        contentView.do {
            $0.backgroundColor = .brown
            $0.collectionView.dataSource = self
            $0.collectionView.delegate = self
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
