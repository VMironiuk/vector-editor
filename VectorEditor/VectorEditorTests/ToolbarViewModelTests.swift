//
//  ToolbarViewModelTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 07.03.2024.
//

import XCTest
import VectorEditor

final class ToolbarViewModelTests: XCTestCase {
    func test_selectShape_informsDelegateAboutSelectingShape() {
        let delegate = ToolbarViewModelDelegateSpy()
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.delegate = delegate
        
        sut.selectShape(.circle)
        
        XCTAssertEqual(delegate.selectedShapes, [.circle])
    }
    
    func test_selectShape_informsDelegateAboutSelectingTwoDifferentShapes() {
        let delegate = ToolbarViewModelDelegateSpy()
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.delegate = delegate
        
        sut.selectShape(.circle)
        sut.selectShape(.rectangle)
        
        XCTAssertEqual(delegate.selectedShapes, [.circle, .rectangle])
    }
    
    func test_selectShape_doesNotInformDelegateOnSelectingSameShape() {
        let delegate = ToolbarViewModelDelegateSpy()
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.delegate = delegate
        
        sut.selectShape(.circle)
        sut.selectShape(.circle)
        
        XCTAssertEqual(delegate.selectedShapes, [.circle])
    }
    
    func test_selectShape_informsObserverAboutSelectingShape() {
        var selectedShapes = [SupportedShape]()
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.onShapeSelected = { selectedShapes.append($0) }
        
        sut.selectShape(.circle)
        
        XCTAssertEqual(selectedShapes, [.circle])
    }
    
    func test_selectShape_informsObserverAboutSelectingTwoDifferentShapes() {
        var selectedShapes = [SupportedShape]()
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.onShapeSelected = { selectedShapes.append($0) }
        
        sut.selectShape(.circle)
        sut.selectShape(.rectangle)
        
        XCTAssertEqual(selectedShapes, [.circle, .rectangle])
    }
    
    func test_selectShape_doesNotInformObserverOnSelectingSameShape() {
        var selectedShapes = [SupportedShape]()
        let sut = ToolbarViewModel(documentName: "", supportedShapes: SupportedShape.allCases)
        sut.onShapeSelected = { selectedShapes.append($0) }
        
        sut.selectShape(.circle)
        sut.selectShape(.circle)
        
        XCTAssertEqual(selectedShapes, [.circle])
    }
    
    // MARK: - Helpers
    
    private class ToolbarViewModelDelegateSpy: ToolbarViewModelDelegate {
        private(set) var selectedShapes = [SupportedShape]()
        
        func didSelectShape(_ shape: SupportedShape) {
            selectedShapes.append(shape)
        }
    }
}
