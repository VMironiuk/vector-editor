//
//  SceneView.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

final class SceneView: UIView {
    private var shapeType: ShapeType = .rect
    private var startPoint: CGPoint?
    
    private var rects: [CGRect] = []
    private var circleCenterPoints: [CGPoint] = []

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1 else { return }
        startPoint = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1, let startPoint = startPoint, let endPoint = touches.first?.location(in: self) else { return }
        let rect = CGRect.make(p1: startPoint, p2: endPoint)
        if rects.isEmpty {
            rects.append(rect)
        } else {
            rects.removeLast()
            rects.append(rect)
        }

        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch shapeType {
        case .rect:
            guard touches.count == 1, let startPoint = startPoint, let endPoint = touches.first?.location(in: self) else { return }
            rects.append(CGRect.make(p1: startPoint, p2: endPoint))
            
        case .circle:
            guard touches.count == 1, let point = touches.first?.location(in: self) else { return }
            circleCenterPoints.append(CGPoint(x: point.x - 25, y: point.y - 25))
        }
                
        setNeedsDisplay()

    }
    
    override func draw(_ rect: CGRect) {
        switch shapeType {
        case .rect:
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor.red.cgColor)
            context?.fill(rects)
        case .circle:
            let context = UIGraphicsGetCurrentContext()
            circleCenterPoints.forEach { point in
                context?.setFillColor(UIColor.red.cgColor)
                let rect = CGRect(x: point.x, y: point.y, width: 50, height: 50)
                context?.fillEllipse(in: rect)
            }
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
