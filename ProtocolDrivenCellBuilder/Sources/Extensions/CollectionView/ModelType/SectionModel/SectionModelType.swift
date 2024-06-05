//
//  SectionModelType.swift
//  ProtocolDrivenCellBuilder
//
//  Created by 이숭인 on 6/4/24.
//

import UIKit

public protocol SectionModelType: ModelType {
    var minimumLineSpacing: CGFloat { get }
    var minimumInteritemSpacing: CGFloat { get }

    var insets: UIEdgeInsets { get }

    var header: ItemModelType? { get }
    var footer: ItemModelType? { get }

    var itemModels: [ItemModelType] { get }
}

extension SectionModelType {
    // swiftlint:disable:next legacy_hashing
    public var hashValue: Int {
        var hasher = Hasher()
//        innerHash(into: &hasher)
        return hasher.finalize()
    }

//    public func innerHash(into hasher: inout Hasher) {
//        hasher.combine(identifier)
//        hasher.combine(minimumLineSpacing)
//        hasher.combine(minimumInteritemSpacing)
//        insets.hash(into: &hasher)
//        header?.innerHash(into: &hasher)
//        footer?.innerHash(into: &hasher)
//
//        hash(into: &hasher)
//    }

//    public var sizeHashValue: Int {
//        var hasher = Hasher()
//        sizeInnerHash(into: &hasher)
//        return hasher.finalize()
//    }

//    public func sizeInnerHash(into hasher: inout Hasher) {
//        hasher.combine(minimumLineSpacing)
//        hasher.combine(minimumInteritemSpacing)
//        insets.hash(into: &hasher)
//
//        sizeHash(into: &hasher)
//    }
}
