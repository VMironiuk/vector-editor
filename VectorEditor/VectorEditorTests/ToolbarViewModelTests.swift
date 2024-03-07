//
//  ToolbarViewModelTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 07.03.2024.
//

import XCTest

final class ToolbarViewModel {
    let documentName: String
    
    init(documentName: String) {
        self.documentName = documentName
    }
}

final class ToolbarViewModelTests: XCTestCase {
    func test_init_setsDocumentName() {
        let documentName = "document name"
        let sut = ToolbarViewModel(documentName: documentName)
        
        XCTAssertEqual(documentName, sut.documentName)
    }
}
