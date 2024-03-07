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
    private var selectedShape: SupportedShape?
    
    let documentName: String
    let supportedShapes: [SupportedShape]
    
    weak var delegate: ToolbarViewModelDelegate?
    
    var onShapeSelected: ((SupportedShape) -> Void)?
    
    init(documentName: String, supportedShapes: [SupportedShape]) {
        self.documentName = documentName
        self.supportedShapes = supportedShapes
    }
    
    func selectShape(_ shape: SupportedShape) {
        guard selectedShape != shape else { return }
        delegate?.didSelectShape(shape)
        selectedShape = shape
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
        
        XCTAssertEqual(delegate.selectedShapes, [])
    }
    
    func test_init_doesNotInformObserverAboutSelectedShape() {
        var onShapeSelectedCallCount = 0
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.onShapeSelected = { _ in onShapeSelectedCallCount += 1 }
        
        XCTAssertEqual(onShapeSelectedCallCount, 0)
    }
    
    func test_selectShape_informsDelegateAboutSelectedShape() {
        let delegate = ToolbarViewModelDelegateSpy()
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.delegate = delegate
        
        sut.selectShape(.circle)
        
        XCTAssertEqual(delegate.selectedShapes, [.circle])
    }
    
    func test_selectShape_informsDelegateAboutSelectedShapeTwice() {
        let delegate = ToolbarViewModelDelegateSpy()
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.delegate = delegate
        
        sut.selectShape(.circle)
        sut.selectShape(.rectangle)
        
        XCTAssertEqual(delegate.selectedShapes, [.circle, .rectangle])
    }
    
    func test_selectShape_doesNotInformDelegateIfSelectedSameShape() {
        let delegate = ToolbarViewModelDelegateSpy()
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.delegate = delegate
        
        sut.selectShape(.circle)
        sut.selectShape(.circle)
        
        XCTAssertEqual(delegate.selectedShapes, [.circle])
    }
    
    // MARK: - Helpers
    
    private class ToolbarViewModelDelegateSpy: ToolbarViewModelDelegate {
        private(set) var selectedShapes = [SupportedShape]()
        
        func didSelectShape(_ shape: SupportedShape) {
            selectedShapes.append(shape)
        }
    }
}

extension SupportedShape: Equatable {}
