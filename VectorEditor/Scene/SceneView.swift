//
//  SceneView.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

final class SceneView: UIView {
    private var circleCenterPoints: [CGPoint] = []
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1, let point = touches.first?.location(in: self) else { return }
        circleCenterPoints.append(CGPoint(x: point.x - 25, y: point.y - 25))
        
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        circleCenterPoints.forEach { point in
            let context = UIGraphicsGetCurrentContext()
            context?.setLineWidth(2.0)
            context?.setFillColor(UIColor.red.cgColor)
            let rect = CGRect(x: point.x, y: point.y, width: 50, height: 50)
            context?.fillEllipse(in: rect)
        }
    }
}
