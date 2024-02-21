//
//  RectShape.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 21.02.2024.
//

import Foundation
import CoreGraphics

struct RectShape: ShapeProtocol {
    private let rect: CGRect
    let id: UUID
    let createdAt: Date

    var type: ShapeType { .rect }
    
    init(rect: CGRect) {
        self.rect = rect
        id = UUID()
        createdAt = .now
    }
    
    func draw(in context: CGContext) {
        context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        context.fill([rect])
    }
}
