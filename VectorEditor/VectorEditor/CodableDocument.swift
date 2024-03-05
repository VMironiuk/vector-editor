//
//  CodableDocument.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import CoreGraphics

public enum CodableShape: Codable {
    case circle(NSRect)
    case rectangle(NSRect)
    case triangle(NSPoint, NSPoint, NSPoint)
}

public struct CodableDocument: Codable {
    public let name: String
    public let shapes: [CodableShape]
    
    public init(name: String, shapes: [CodableShape]) {
        self.name = name
        self.shapes = shapes
    }
}
