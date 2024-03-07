//
//  ToolbarViewModelTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 07.03.2024.
//

import XCTest

enum SupportedShape: CaseIterable {
    case circle
    case rectangle
}

final class ToolbarViewModel {
    let documentName: String
    let supportedShapes: [SupportedShape]
    
    init(documentName: String, supportedShapes: [SupportedShape]) {
        self.documentName = documentName
        self.supportedShapes = supportedShapes
    }
}

final class ToolbarViewModelTests: XCTestCase {
    func test_init_setsDocumentName() {
        let documentName = "document name"
        let sut = ToolbarViewModel(documentName: documentName, supportedShapes: SupportedShape.allCases)
        
        XCTAssertEqual(documentName, sut.documentName)
    }
    
    func test_init_setsSupportedShapes() {
        let supportedShapes = SupportedShape.allCases
        let sut = ToolbarViewModel(documentName: "", supportedShapes: supportedShapes)
        
        XCTAssertEqual(supportedShapes, sut.supportedShapes)
    }
}

extension SupportedShape: Equatable {}
