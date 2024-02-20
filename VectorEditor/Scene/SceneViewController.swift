//
//  SceneViewController.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

class SceneViewController: UIViewController {
    private var sceneView: SceneView? { view as? SceneView }
}

extension SceneViewController: SceneViewProtocol {
    func update(state: ScenePresenterState) {
        sceneView?.shapeType = state.shapeType
    }
}
