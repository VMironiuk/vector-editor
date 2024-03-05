//
//  CodableDocumentTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import XCTest
import VectorEditor

final class CodableDocumentTests: XCTestCase {
    func test_coding_codableDocument() throws {
        let document = CodableDocument(
            name: "A document",
            shapes: [
                .circle(NSRect(x: 0, y: 0, width: 100, height: 100)),
                .circle(NSRect(x: 3, y: 3, width: 42, height: 42)),
                .rectangle(NSRect(x: 42, y: 42, width: 21, height: 21)),
                .triangle(NSPoint(x: 0, y: 0), NSPoint(x: 3, y: 3), NSPoint(x: 14, y: 14))
            ])
        
        let data = try JSONEncoder().encode(document)
        
        let decodedDocument = try JSONDecoder().decode(CodableDocument.self, from: data)
        
        XCTAssertEqual(document, decodedDocument)
    }
}

extension CodableShape: Equatable {
    public static func == (lhs: CodableShape, rhs: CodableShape) -> Bool {
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

extension CodableDocument: Equatable {
    public static func == (lhs: CodableDocument, rhs: CodableDocument) -> Bool {
        lhs.name == rhs.name && lhs.shapes == rhs.shapes
    }
}
