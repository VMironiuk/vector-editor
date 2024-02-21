//
//  CircleShape.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 21.02.2024.
//

import Foundation

struct CircleShape: ShapeProtocol {
    let point: CGPoint
    let id: UUID
    let createdAt: Date

    var type: ShapeType { .circle }
    
    init(point: CGPoint) {
        self.point = point
        id = UUID()
        createdAt = .now
    }
}
