//
//  CodableDocument.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import CoreGraphics

public struct CodableDocument: Codable {
    public enum Shape: Codable {
        case circle(NSRect)
        case rectangle(NSRect)
        case triangle(NSPoint, NSPoint, NSPoint)
    }

    public let name: String
    public let shapes: [Shape]
    
    public init(name: String, shapes: [Shape]) {
        self.name = name
        self.shapes = shapes
    }
}
