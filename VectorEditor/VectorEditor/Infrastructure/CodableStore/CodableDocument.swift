//
//  CodableDocument.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import CoreGraphics

public struct CodableDocument: Codable {
    public enum Shape: Codable {
        public struct Metadata: Codable {
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
