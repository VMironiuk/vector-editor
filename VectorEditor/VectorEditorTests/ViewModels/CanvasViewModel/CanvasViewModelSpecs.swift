//
//  CanvasViewModelSpecs.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 09.03.2024.
//

import Foundation

protocol CanvasViewModelSpecs {
    func test_init_doesNotAskStoreCoordinatorToSaveDocument()
    func test_init_doesNotAskStoreCoordinatorToLoadDocument()
    func test_init_desNotInitializeDocument()
    
    func test_saveDocument_succeedsOnSuccessfulStoreCoordinatorDocumentSave()
    func test_saveDocument_failsOnFailedStoreCoordinatorDocumentSave()
}
