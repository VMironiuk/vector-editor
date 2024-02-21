//
//  SceneView.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

protocol SceneViewDelegate: AnyObject {
    func sceneView(_ view: SceneView, didAddShape shape: ShapeProtocol)
}

final class SceneView: UIView {
    private var shapes: [ShapeProtocol] = []
    
    private var startPoint: CGPoint?
    private var isMoving = false
       
    var shapeType: ShapeType?
    
    weak var delegate: SceneViewDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1 else { return }
        startPoint = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard shapeType == .rect,
              touches.count == 1,
              let startPoint = startPoint,
              let endPoint = touches.first?.location(in: self) else { return }
        
        let rect = CGRect.make(p1: startPoint, p2: endPoint)
        let shape = RectShape(rect: rect)
        
        if isMoving, !shapes.isEmpty, shapes.last?.type == .rect {
            shapes[shapes.count - 1] = shape
        } else {
            isMoving = true
            shapes.append(shape)
        }

        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let shapeType = shapeType else { return }
        
        switch shapeType {
        case .rect:
            guard isMoving, let shape = shapes.last, shape.type == .rect else { return }
            isMoving = false
            delegate?.sceneView(self, didAddShape: shape)
            
        case .circle:
            guard touches.count == 1, let point = touches.first?.location(in: self) else { return }
            let shape = CircleShape(point: CGPoint(x: point.x - 25, y: point.y - 25))
            shapes.append(shape)
            delegate?.sceneView(self, didAddShape: shape)
        }
                
        setNeedsDisplay()

    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawRects(in: context)
        drawCircles(in: context)
    }
    
    private func drawRects(in context: CGContext) {
        let rects = shapes.filter { $0.type == .rect }.map { ($0 as! RectShape).rect }
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rects)
    }
    
    private func drawCircles(in context: CGContext) {
        let points = shapes.filter { $0.type == .circle }.map { ($0 as! CircleShape).point }
        points.forEach { point in
            context.setFillColor(UIColor.red.cgColor)
            let rect = CGRect(x: point.x, y: point.y, width: 50, height: 50)
            context.fillEllipse(in: rect)
        }
    }
}

extension CGRect {
    static func make(p1: CGPoint, p2: CGPoint) -> CGRect {
        make(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y)
    }
    
    static func make(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGRect {
        CGRect(x: min(x1, x2), y: min(y1, y2), width: abs(x1 - x2), height: abs(y1 - y2))
    }
}
