//
//  ToolbarRouter.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

final class ToolbarRouter {
    private let view: ToolbarViewController
    private let presenter: ToolbarPresenter
    
    var viewController: UIViewController { view }
    
    weak var delegate: ToolbarRouterDelegate?
    
    init() {
        view = ToolbarViewController()
        presenter = ToolbarPresenter()
        
        presenter.delegate = self
        view.eventHandler = presenter
    }
}

extension ToolbarRouter: ToolbarPresenterDelegate {
    func didTapRectButton() {
        delegate?.didChangeShapeType(to: .rect)
    }
    
    func didTapCircleButton() {
        delegate?.didChangeShapeType(to: .circle)
    }
}
