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

protocol ToolbarViewModelDelegate: AnyObject {
    func didSelectShape(_ shape: SupportedShape)
}

final class ToolbarViewModel {
    let documentName: String
    let supportedShapes: [SupportedShape]
    
    weak var delegate: ToolbarViewModelDelegate?
    
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
    
    func test_init_doesNotInformDelegateAboutSelectedShape() {
        let delegate = ToolbarViewModelDelegateSpy()
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.delegate = delegate
        
        XCTAssertEqual(delegate.didSelectShapeCallCount, 0)
    }
    
    // MARK: - Helpers
    
    private class ToolbarViewModelDelegateSpy: ToolbarViewModelDelegate {
        private(set) var didSelectShapeCallCount = 0
        
        func didSelectShape(_ shape: SupportedShape) {
            didSelectShapeCallCount += 1
        }
    }
}

extension SupportedShape: Equatable {}
