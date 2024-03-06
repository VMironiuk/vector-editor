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
                .circle(.init(id: UUID(), createdAt: .now), .init(x: 0, y: 0, width: 100, height: 100)),
                .circle(.init(id: UUID(), createdAt: .now), .init(x: 3, y: 3, width: 42, height: 42)),
                .rectangle(.init(id: UUID(), createdAt: .now), .init(x: 42, y: 42, width: 21, height: 21))
            ])
        
        let data = try JSONEncoder().encode(document)
        
        let decodedDocument = try JSONDecoder().decode(CodableDocument.self, from: data)
        
        XCTAssertEqual(document, decodedDocument)
    }
}
