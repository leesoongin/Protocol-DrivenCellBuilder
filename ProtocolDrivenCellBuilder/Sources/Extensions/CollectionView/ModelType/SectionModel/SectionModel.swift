//
//  SectionModel.swift
//  ProtocolDrivenCellBuilder
//
//  Created by 이숭인 on 6/4/24.
//

import UIKit

public struct SectionModel: SectionModelType {
    public let identifier: String

    public let minimumLineSpacing: CGFloat
    public let minimumInteritemSpacing: CGFloat

    public let insets: UIEdgeInsets

    public let header: ItemModelType?
    public let footer: ItemModelType?

    public let itemModels: [ItemModelType]

    public init(identifier: String,
                minimumLineSpacing: CGFloat = 16,
                minimumInteritemSpacing: CGFloat = 0,
                insets: UIEdgeInsets = .zero,
                header: ItemModelType? = nil,
                footer: ItemModelType? = nil,
                itemModels: [ItemModelType]) {
        self.identifier = identifier
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.insets = insets
        self.header = header
        self.footer = footer
        self.itemModels = itemModels
    }

    public func hash(into hasher: inout Hasher) { }
}
