//
//  SceneViewController.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

class SceneViewController: UIViewController {
    private var sceneView: SceneView? { view as? SceneView }
    
    weak var eventHandler: SceneViewEventHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView?.delegate = self
    }
}

extension SceneViewController: SceneViewProtocol {
    func update(state: ScenePresenterState) {
        sceneView?.shapeType = state.shapeType
    }
}

extension SceneViewController: SceneViewDelegate {
    func sceneView(_ view: SceneView, didAddShape shapeType: ShapeType) {
        eventHandler?.onShapeAdded(shapeType)
    }
}
