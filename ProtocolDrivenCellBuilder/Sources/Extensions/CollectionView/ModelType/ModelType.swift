//
//  ModelType.swift
//  ProtocolDrivenCellBuilder
//
//  Created by 이숭인 on 6/4/24.
//

import Foundation

public protocol ModelType {
    var identifier: String { get }
//    func hash(into hasher: inout Hasher)
//    func sizeHash(into hasher: inout Hasher)
}

extension ModelType {
    public func sizeHash(into hasher: inout Hasher) {
//        hash(into: &hasher)
    }
}
