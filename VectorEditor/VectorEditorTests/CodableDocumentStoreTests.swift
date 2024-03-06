//
//  CodableDocumentStoreTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import XCTest
import VectorEditor

final class CodableDocumentStore {
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func save(document: CodableDocument, completion: @escaping (Error?) -> Void) {
        do {
            let encoder = JSONEncoder()
            let encodedDocument = try encoder.encode(document)
            try encodedDocument.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func load(completion: @escaping (Result<CodableDocument, Error>) -> Void) {
        do {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.success(CodableDocument(name: "", shapes: [])))
            }
            
            let decoder = JSONDecoder()
            let document = try decoder.decode(CodableDocument.self, from: data)
            completion(.success(document))
        } catch {
            completion(.failure(error))
        }
    }
}

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
        
        sut.save(document: anyCodableDocument()) { error in
            XCTAssertNil(error, "Expected a document saving to complete successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        
        XCTAssertNotNil(try? Data(contentsOf: testSpecificStoreURL()))
    }
    
    func test_load_LoadsDocument() {
        let sut = makeSUT()
        let document = anyCodableDocument()
        sut.save(document: document) { _ in }
        
        let exp = expectation(description: "Wait for a document loading completion")
        
        sut.load { result in
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
    
    // MARK: - Helpers
    
    private func makeSUT() -> CodableDocumentStore {
        CodableDocumentStore(storeURL: testSpecificStoreURL())
    }
    
    private func anyCodableDocument() -> CodableDocument {
        CodableDocument(name: "a document", shapes: [
            .circle(NSRect(x: 3, y: 3, width: 21, height: 21)),
            .rectangle(NSRect(x: 14, y: 21, width: 42, height: 42))
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
