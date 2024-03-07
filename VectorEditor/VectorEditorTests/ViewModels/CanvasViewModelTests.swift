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
    var saveDocumentCallCount: Int { saveCompletions.count }
    var loadDocumentCallCount: Int { loadCompletions.count }
    
    private var saveCompletions = [(Error?) -> Void]()
    private var loadCompletions = [(Result<Document, Error>) -> Void]()
    
    func saveDocument(_ document: Document, completion: @escaping (Error?) -> Void) {
        saveCompletions.append(completion)
    }
    
    func loadDocument(from storeURL: URL, completion: @escaping (Result<Document, Error>) -> Void) {
        loadCompletions.append(completion)
    }
    
    func completeDocumentSaving(with error: Error?, at index: Int = 0) {
        saveCompletions[index](error)
    }
    
    func completeDocumentLoading(with result: Result<Document, Error>, at index: Int  = 0) {
        loadCompletions[index](result)
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
    
    func loadDocument(from storeURL: URL, completion: @escaping (Result<Document, Error>) -> Void) {
        storeCoordinator.loadDocument(from: storeURL, completion: completion)
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
    
    func test_loadDocument_succeedsOnSuccessfulStoreCoordinatorDocumentLoad() {
        expectLoadDocument(toCompleteWith: .success(anyDocument()))
    }
    
    func test_loadDocument_failsOnFailedStoreCoordinatorDocumentLoad() {
        expectLoadDocument(toCompleteWith: .failure(anyNSError()))
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
        storeCoordinator.completeDocumentSaving(with: expectedError)
        wait(for: [exp], timeout: 1)
    }
    
    private func expectLoadDocument(
        toCompleteWith expectedResult: Result<Document, Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        let exp = expectation(description: "Wait for load completion")
                
        sut.loadDocument(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedDocument), .success(expectedDocument)):
                XCTAssertEqual(receivedDocument, expectedDocument, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        storeCoordinator.completeDocumentLoading(with: expectedResult)
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
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
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
