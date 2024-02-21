//
//  SceneView.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

protocol SceneViewDelegate: AnyObject {
    func sceneView(_ view: SceneView, touchBeganWithPoint point: CGPoint)
    func sceneView(_ view: SceneView, touchMovedWithPoint point: CGPoint)
    func sceneView(_ view: SceneView, touchEndedWithPoint point: CGPoint)
}

final class SceneView: UIView {
    private var drawingHandler: DrawingHandler?
   
    weak var delegate: SceneViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1, let point = touches.first?.location(in: self) else { return }
        delegate?.sceneView(self, touchBeganWithPoint: point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1, let point = touches.first?.location(in: self) else { return }
        delegate?.sceneView(self, touchMovedWithPoint: point)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1, let point = touches.first?.location(in: self) else { return }
        delegate?.sceneView(self, touchEndedWithPoint: point)
    }
        
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawingHandler?(context)
        drawingHandler = nil
    }
    
    func redraw(with drawingHandler: @escaping DrawingHandler) {
        self.drawingHandler = drawingHandler
        setNeedsDisplay()
    }
}
