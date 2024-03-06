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
    
    func save(completion: @escaping (Error?) -> Void) {
        let document = CodableDocument(name: "a document", shapes: [
            .circle(NSRect(x: 3, y: 3, width: 21, height: 21)),
            .rectangle(NSRect(x: 14, y: 21, width: 42, height: 42))
        ])
        
        do {
            let encoder = JSONEncoder()
            let encodedDocument = try encoder.encode(document)
            try encodedDocument.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
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
        _ = CodableDocumentStore(storeURL: testSpecificStoreURL())
        
        XCTAssertNil(try? Data(contentsOf: testSpecificStoreURL()))
    }
    
    func test_save_savesDocument() {
        let sut = CodableDocumentStore(storeURL: testSpecificStoreURL())
        
        sut.save { _ in }
        
        XCTAssertNotNil(try? Data(contentsOf: testSpecificStoreURL()))
    }
    
    // MARK: - Helpers
    
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
