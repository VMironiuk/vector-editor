//
//  CanvasViewModelTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 07.03.2024.
//

import XCTest

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

final class DocumentStoreCoordinatorSpy {
    var saveDocumentCallCount: Int { completions.count }
    private(set) var loadDocumentCallCount = 0
    
    private var completions = [((Error?) -> Void)]()
    
    func saveDocument(_ document: Document, completion: @escaping (Error?) -> Void) {
        completions.append(completion)
    }
    
    func complete(with error: Error?, at index: Int = 0) {
        completions[index](error)
    }
}

final class CanvasViewModel {
    private let storeCoordinator: DocumentStoreCoordinatorSpy
    
    init(storeCoordinator: DocumentStoreCoordinatorSpy) {
        self.storeCoordinator = storeCoordinator
    }
    
    func saveDocument(_ document: Document, completion: @escaping (Error?) -> Void) {
        storeCoordinator.saveDocument(document, completion: completion)
    }
}

final class CanvasViewModelTests: XCTestCase {
    func test_init_doesNotAskStoreCoordinatorToSaveDocument() {
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        _ = CanvasViewModel(storeCoordinator: storeCoordinator)
        
        XCTAssertEqual(storeCoordinator.saveDocumentCallCount, 0)
    }
    
    func test_init_doesNotAskStoreCoordinatorToLoadDocument() {
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        _ = CanvasViewModel(storeCoordinator: storeCoordinator)
        
        XCTAssertEqual(storeCoordinator.loadDocumentCallCount, 0)
    }
    
    func test_saveDocument_succeedsOnSuccessfulStoreCoordinatorDocumentSave() {
        expectSaveDocument(toCompleteWith: nil)
    }
    
    func test_saveDocument_failsOnFailedStoreCoordinatorDocumentSave() {
        expectSaveDocument(toCompleteWith: anyNSError())
    }
    
    // MARK: - Helper
    
    private func expectSaveDocument(
        toCompleteWith expectedError: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        let exp = expectation(description: "Wait for save completion")
        
        sut.saveDocument(anyDocument()) { receivedError in
            XCTAssertEqual(expectedError as? NSError, receivedError as? NSError, file: file, line: line)
            exp.fulfill()
        }
        storeCoordinator.complete(with: expectedError)
        wait(for: [exp], timeout: 1)
    }
    
    private func anyDocument() -> Document {
        Document(name: "a document", shapes: [
            .circle(.init(id: UUID(), createdAt: .now), .init(x: 3, y: 3, width: 14, height: 14)),
            .rectangle(.init(id: UUID(), createdAt: .now), .init(x: 14, y: 14, width: 42, height: 42))
        ])
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any domain", code: 1)
    }
}
