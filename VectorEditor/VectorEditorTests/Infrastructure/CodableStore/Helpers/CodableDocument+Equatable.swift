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
        case let (.circle(lhsMetadata, lhsFrame), .circle(rhsMetadata, rhsFrame)):
            return lhsMetadata == rhsMetadata && lhsFrame == rhsFrame
            
        case let (.rectangle(lhsMetadata, lhsFrame), .rectangle(rhsMetadata, rhsFrame)):
            return lhsMetadata == rhsMetadata && lhsFrame == rhsFrame

        default:
            return false
        }
    }
}

extension CodableDocument.Shape.Metadata: Equatable {
    public static func == (lhs: CodableDocument.Shape.Metadata, rhs: CodableDocument.Shape.Metadata) -> Bool {
        lhs.id == rhs.id && lhs.createdAt == rhs.createdAt
    }
}
