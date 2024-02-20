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
    
    init() {
        view = SceneViewController()
        presenter = ScenePresenter()
        
        presenter.view = view
    }
}

extension SceneRouter: ToolbarRouterDelegate {
    func didChangeShapeType(to shapeType: ShapeType) {
        presenter.changeShapeType(to: shapeType)
    }
}
