//
//  SidebarRouter.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

final class SidebarRouter {
    private let view: SidebarViewController
    private let presenter: SidebarPresenter
    
    var viewController: UIViewController { view }
    
    weak var delegate: SidebarRouterDelegate?
    
    init() {
        view = SidebarViewController()
        presenter = SidebarPresenter()
        
        presenter.view = view
        presenter.delegate = self
        view.eventHandler = presenter
    }
}

extension SidebarRouter: SidebarPresenterDelegate {
    func didRemoveShape(id: UUID) {
        delegate?.didRemoveShape(id: id)
    }
}

extension SidebarRouter: SceneRouterDelegate {
    func didAddShape(_ shape: ShapeProtocol) {
        presenter.addShape(shape)
    }
}
