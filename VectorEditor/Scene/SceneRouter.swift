//
//  SceneRouter.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import Foundation

final class SceneRouter {
    let viewController = SceneViewController()
}

extension SceneRouter: ToolbarRouterDelegate {
    func didChangeShapeType(to shapeType: ShapeType) {
        print("shape type changed to \(shapeType)")
    }
}
