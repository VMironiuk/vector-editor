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
    private let interactor: SceneInteractor
    
    var viewController: UIViewController { view }
    
    weak var delegate: SceneRouterDelegate?
    
    init() {
        view = SceneViewController()
        presenter = ScenePresenter()
        interactor = SceneInteractor()
        
        presenter.view = view
        presenter.delegate = self
        presenter.interactor = interactor
        view.eventHandler = presenter
        interactor.delegate = presenter
    }
}

extension SceneRouter: ToolbarRouterDelegate {
    func didChangeShapeType(to shapeType: ShapeType) {
        interactor.changeShapeType(to: shapeType)
    }
}

extension SceneRouter: SidebarRouterDelegate {
    func didRemoveShape(id: UUID) {
        interactor.removeShape(with: id)
    }
}

extension SceneRouter: ScenePresenterDelegate {
    func didAddShape(_ shape: ShapeProtocol) {
        delegate?.didAddShape(shape)
    }
}
