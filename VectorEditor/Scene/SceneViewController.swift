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
        sceneView?.redraw(with: state.drawingHandler)
    }
}

extension SceneViewController: SceneViewDelegate {
    func sceneView(_ view: SceneView, touchBeganWithPoint point: CGPoint) {
        eventHandler?.onTouchBegan(with: point)
    }
    
    func sceneView(_ view: SceneView, touchMovedWithPoint point: CGPoint) {
        eventHandler?.onTouchMoved(with: point)
    }
    
    func sceneView(_ view: SceneView, touchEndedWithPoint point: CGPoint) {
        eventHandler?.onTouchEnded(with: point)
    }
}
