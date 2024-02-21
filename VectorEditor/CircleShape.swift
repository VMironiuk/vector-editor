//
//  CircleShape.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 21.02.2024.
//

import Foundation
import CoreGraphics

struct CircleShape: ShapeProtocol {
    private let point: CGPoint
    let id: UUID
    let createdAt: Date

    var type: ShapeType { .circle }
    
    init(point: CGPoint) {
        self.point = point
        id = UUID()
        createdAt = .now
    }
    
    func draw(in context: CGContext) {
        context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        let rect = CGRect(x: point.x, y: point.y, width: 50, height: 50)
        context.fillEllipse(in: rect)
    }
}
