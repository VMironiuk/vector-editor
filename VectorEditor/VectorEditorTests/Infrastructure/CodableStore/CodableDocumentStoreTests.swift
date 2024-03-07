//
//  CodableDocumentStoreTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import XCTest
import VectorEditor

final class CodableDocumentStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_init_doesNotSaveDocument() {
        _ = makeSUT()
        
        XCTAssertNil(try? Data(contentsOf: testSpecificStoreURL()))
    }
    
    func test_save_savesDocument() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for a document saving completion")
        
        sut.save(document: anyCodableDocument(), to: testSpecificStoreURL()) { error in
            XCTAssertNil(error, "Expected a document saving to complete successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        
        XCTAssertNotNil(try? Data(contentsOf: testSpecificStoreURL()))
    }
    
    func test_load_loadsDocument() {
        let sut = makeSUT()
        let document = anyCodableDocument()
        sut.save(document: document, to: testSpecificStoreURL()) { _ in }
        let exp = expectation(description: "Wait for a document loading completion")
        
        sut.load(from: testSpecificStoreURL()) { result in
            switch result {
            case let .success(receivedDocument):
                XCTAssertEqual(receivedDocument, document)
            default:
                XCTFail("Expected a document loading to complete successfully")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_failsOnLoadingNonExistingDocumentFile() {
        let sut = makeSUT()
        expect(sut, toFailOnDestructiveAction: {
            undoStoreSideEffects()
        })
    }
    
    func test_load_failsOnLoadingInvalidDocumentFile() {
        let sut = makeSUT()
        expect(sut, toFailOnDestructiveAction: {
            undoStoreSideEffects()
            let invalidDocumentData = "invalid document".data(using: .utf8)!
            try! invalidDocumentData.write(to: testSpecificStoreURL())
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> CodableDocumentStore {
        CodableDocumentStore()
    }
    
    private func expect(
        _ sut: CodableDocumentStore,
        toFailOnDestructiveAction destructiveAction: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let document = anyCodableDocument()
        sut.save(document: document, to: testSpecificStoreURL()) { _ in }
        let exp = expectation(description: "Wait for a document loading completion")
        destructiveAction()
        
        sut.load(from: testSpecificStoreURL()) { result in
            switch result {
            case let .failure(error):
                XCTAssertNotNil(error, "Expected loading error not to be nil", file: file, line: line)
            default:
                XCTFail("Expected a document loading to fail", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func anyCodableDocument() -> CodableDocument {
        CodableDocument(name: "a document", shapes: [
            .circle(.init(id: UUID(), createdAt: .now), .init(x: 3, y: 3, width: 21, height: 21)),
            .rectangle(.init(id: UUID(), createdAt: .now), .init(x: 14, y: 21, width: 42, height: 42))
        ])
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try?  FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
