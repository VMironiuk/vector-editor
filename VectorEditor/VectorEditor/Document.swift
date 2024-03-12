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
