//
//  DocumentManagerTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import XCTest

final class DocumentManager {}

final class DocumentManagerTests: XCTestCase {
    func test_init_doesNotCallLoadOrSave() {
        let store = DocumentStoreSpy()
        let sut  = DocumentManager()
        
        XCTAssertEqual(store.loadCallCount, 0)
        XCTAssertEqual(store.saveCallCount, 0)
    }
    
    // MARK: - Helpers
    
    final class DocumentStoreSpy {
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
