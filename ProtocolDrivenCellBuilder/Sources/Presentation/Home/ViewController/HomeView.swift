//
//  HomeView.swift
//  ProtocolDrivenCellBuilder
//
//  Created by 이숭인 on 6/4/24.
//

import UIKit
import SnapKit

class HomeView: BaseView {
    let collectionView: UICollectionView = UICollectionView(scrollDirection: .vertical)
    
    override func setupSubviews() {
        addSubview(collectionView)
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension UICollectionView {
    public convenience init(scrollDirection: UICollectionView.ScrollDirection,
                            flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()) {
        flowLayout.scrollDirection = scrollDirection
        self.init(frame: .zero, collectionViewLayout: flowLayout)
        self.delaysContentTouches = false
        self.canCancelContentTouches = true
        self.backgroundColor = .clear
    }
}
