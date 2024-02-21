//
//  RectShape.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 21.02.2024.
//

import Foundation

struct RectShape: ShapeProtocol {
    let rect: CGRect
    let id: UUID
    let createdAt: Date

    var type: ShapeType { .rect }
    
    init(rect: CGRect) {
        self.rect = rect
        id = UUID()
        createdAt = .now
    }
}
