//
//  DocumentManagerTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import XCTest
import VectorEditor

final class DocumentManager {
    private let store: DocumentStoreProtocol
    
    init(store: DocumentStoreProtocol) {
        self.store = store
    }
    
    func load() {
        store.load()
    }
    
    func save() {
        store.save()
    }
}

final class DocumentManagerTests: XCTestCase {
    func test_init_doesNotLoadOrSave() {
        let store = DocumentStoreSpy()
        _ = DocumentManager(store: store)
        
        XCTAssertEqual(store.loadCallCount, 0)
        XCTAssertEqual(store.saveCallCount, 0)
    }
    
    func test_load_loadsDocumentOnLoad() {
        let store = DocumentStoreSpy()
        let sut = DocumentManager(store: store)
        
        sut.load()
        
        XCTAssertEqual(store.loadCallCount, 1)
        XCTAssertEqual(store.saveCallCount, 0)
    }
    
    func test_load_loadsDocumentTwiceOnCallingLoadTwice() {
        let store = DocumentStoreSpy()
        let sut = DocumentManager(store: store)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(store.loadCallCount, 2)
        XCTAssertEqual(store.saveCallCount, 0)
    }
    
    func test_load_savesDocumentOnSave() {
        let store = DocumentStoreSpy()
        let sut = DocumentManager(store: store)
        
        sut.save()
        
        XCTAssertEqual(store.loadCallCount, 0)
        XCTAssertEqual(store.saveCallCount, 1)
    }
    
    func test_load_savesDocumentTwiceOnCallingSaveTwice() {
        let store = DocumentStoreSpy()
        let sut = DocumentManager(store: store)
        
        sut.save()
        sut.save()
        
        XCTAssertEqual(store.loadCallCount, 0)
        XCTAssertEqual(store.saveCallCount, 2)
    }
    
    // MARK: - Helpers
    
    private final class DocumentStoreSpy: DocumentStoreProtocol {
        private(set) var loadCallCount = 0
        private(set) var saveCallCount = 0
        
        func load() {
            loadCallCount += 1
        }
        
        func save() {
            saveCallCount += 1
        }
    }
}
