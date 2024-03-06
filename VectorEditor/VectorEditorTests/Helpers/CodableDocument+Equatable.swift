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
            
        case let (.triangle(lhsPt1, lhsPt2, lhsPt3), .triangle(rhsPt1, rhsPt2, rhsPt3)):
            return lhsPt1 == rhsPt1 && lhsPt2 == rhsPt2 && lhsPt3 == rhsPt3
            
        default:
            return false
        }
    }
}
