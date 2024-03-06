//
//  CodableDocument+Equatable.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 06.03.2024.
//

import VectorEditor

extension CodableDocument: Equatable {
    public static func == (lhs: CodableDocument, rhs: CodableDocument) -> Bool {
        lhs.name == rhs.name && lhs.shapes == rhs.shapes
    }
}

extension CodableDocument.Shape: Equatable {
    public static func == (lhs: CodableDocument.Shape, rhs: CodableDocument.Shape) -> Bool {
        switch (lhs, rhs) {
        case let (.circle(lhsRect), .circle(rhsRect)):
            return lhsRect == rhsRect
            
        case let (.rectangle(lhsRect), .rectangle(rhsRect)):
            return lhsRect == rhsRect
            
        default:
            return false
        }
    }
}

extension CodableDocument.Circle: Equatable {
    public static func == (lhs: CodableDocument.Circle, rhs: CodableDocument.Circle) -> Bool {
        lhs.id == rhs.id && lhs.createdAt == rhs.createdAt && lhs.frame == rhs.frame
    }
}

extension CodableDocument.Rectangle: Equatable {
    public static func == (lhs: CodableDocument.Rectangle, rhs: CodableDocument.Rectangle) -> Bool {
        lhs.id == rhs.id && lhs.createdAt == rhs.createdAt && lhs.frame == rhs.frame
    }
}
