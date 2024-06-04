//
//  HomeView.swift
//  ProtocolDrivenCellBuilder
//
//  Created by 이숭인 on 6/4/24.
//

import UIKit
import SnapKit

final class HomeView: BaseView {
    let collectionView: UICollectionView = UICollectionView(frame: .zero)
    
    override func setupSubviews() {
        addSubview(collectionView)
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
