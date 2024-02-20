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
    
    init() {
        view = SidebarViewController()
        presenter = SidebarPresenter()
        
        presenter.view = view
    }
}

extension SidebarRouter: SceneRouterDelegate {
    func didAddShape() {
        presenter.addShape()
    }
}
