//
//  CanvasViewModelTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 07.03.2024.
//

import XCTest

final class DocumentStoreCoordinatorSpy {
    private(set) var saveDocumentCallCount = 0
}

final class CanvasViewModel {
    private let storeCoordinator: DocumentStoreCoordinatorSpy
    
    init(storeCoordinator: DocumentStoreCoordinatorSpy) {
        self.storeCoordinator = storeCoordinator
    }
}

final class CanvasViewModelTests: XCTestCase {
    func test_init_doesNotAskStoreCoordinatorToSaveDocument() {
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        
        XCTAssertEqual(storeCoordinator.saveDocumentCallCount, 0)
    }
}
