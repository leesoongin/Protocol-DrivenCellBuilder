//
//  AssistantCommonErrorComponent.swift
//  ProtocolDrivenCellBuilder
//
//  Created by 이숭인 on 6/4/24.
//

import Foundation

import UIKit
import Combine
import CombineExt
import SnapKit

struct AssistantCommonErrorComponent: Component {
    var viewWidthStrategy: ViewWidthStrategy = .column(2)
    var viewHeightStartegy: ViewHeightStrategy = .adaptive

    let identifier: String
    let message: String

    init(identifier: String, message: String) {
        self.identifier = identifier
        self.message = message
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(message)
    }
}

extension AssistantCommonErrorComponent {
    typealias ContentType = ErrorView

    func render(content: ContentType, context: Self, cancellable: inout Set<AnyCancellable>) {
       
    }
}

final class ErrorView: BaseView {
    let label = UILabel()
    override func setup() {
        super.setup()
    }
    
    override func setupSubviews() {
        addSubview(label)
        backgroundColor = .cyan
        
        label.text = "하하하하하"
    }
    
    override func setupConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(label.intrinsicContentSize)
            make.verticalEdges.equalToSuperview().inset(32)
        }
    }
}
