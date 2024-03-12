//
//  Document.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 12.03.2024.
//

import Foundation

public struct Document {
    public enum Shape {
        public struct Metadata {
            public let id: UUID
            public let createdAt: Date
            public init(id: UUID, createdAt: Date) {
                self.id = id
                self.createdAt = createdAt
            }
        }
        case circle(Metadata, NSRect)
        case rectangle(Metadata, NSRect)
    }

    public let name: String
    public let shapes: [Shape]
    
    public init(name: String, shapes: [Shape]) {
        self.name = name
        self.shapes = shapes
    }
}

extension Document: Equatable {
    public static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.name == rhs.name && lhs.shapes == rhs.shapes
    }
}

extension Document.Shape: Equatable {
    public static func == (lhs: Document.Shape, rhs: Document.Shape) -> Bool {
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

extension Document.Shape.Metadata: Equatable {
    public static func == (lhs: Document.Shape.Metadata, rhs: Document.Shape.Metadata) -> Bool {
        lhs.id == rhs.id && lhs.createdAt == rhs.createdAt
    }
}
