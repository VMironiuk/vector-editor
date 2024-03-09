//
//  XCTestCase+MemoryLeaksTracking.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 09.03.2024.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Expected object to be nil, potential memory leak", file: file, line: line)
        }
    }
}
