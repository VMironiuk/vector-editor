//
//  ToolbarComposer.swift
//  VectorEditoriOS
//
//  Created by Volodymyr Myroniuk on 07.03.2024.
//

import UIKit

public final class ToolbarComposer {
    private let viewController: ToolbarViewController
    public let viewModel: ToolbarViewModel
    
    public var view: UIView { viewController.view }
    
    public init(documentName: String) {
        self.viewModel = ToolbarViewModel(documentName: documentName, supportedShapes: SupportedShape.allCases)
        self.viewController = ToolbarViewController(viewModel: viewModel)
    }
}
