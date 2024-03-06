//
//  CodableDocument.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import CoreGraphics

public struct CodableDocument: Codable {
    public struct Circle: Codable {
        public let id: UUID
        public let createdAt: Date
        public let frame: NSRect
        public init(id: UUID, createdAt: Date, frame: NSRect) {
            self.id = id
            self.createdAt = createdAt
            self.frame = frame
        }
    }
    public struct Rectangle: Codable {
        public let id: UUID
        public let createdAt: Date
        public let frame: NSRect
        public init(id: UUID, createdAt: Date, frame: NSRect) {
            self.id = id
            self.createdAt = createdAt
            self.frame = frame
        }
    }
    public enum Shape: Codable {
        case circle(Circle)
        case rectangle(Rectangle)
    }

    public let name: String
    public let shapes: [Shape]
    
    public init(name: String, shapes: [Shape]) {
        self.name = name
        self.shapes = shapes
    }
}
