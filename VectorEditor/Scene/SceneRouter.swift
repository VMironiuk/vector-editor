//
//  SceneRouter.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

final class SceneRouter {
    private let view: SceneViewController
    private let presenter: ScenePresenter
    
    var viewController: UIViewController { view }
    
    weak var delegate: SceneRouterDelegate?
    
    init() {
        view = SceneViewController()
        presenter = ScenePresenter()
        
        presenter.view = view
        presenter.delegate = self
        view.eventHandler = presenter
    }
}

extension SceneRouter: ToolbarRouterDelegate {
    func didChangeShapeType(to shapeType: ShapeType) {
        presenter.changeShapeType(to: shapeType)
    }
}

extension SceneRouter: SidebarRouterDelegate {
    func didRemoveShape(id: UUID) {
        presenter.removeShape(with: id)
    }
}

extension SceneRouter: ScenePresenterDelegate {
    func didAddShape(_ shape: ShapeProtocol) {
        delegate?.didAddShape(shape)
    }
}
