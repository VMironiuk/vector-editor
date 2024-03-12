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
    
    func test_loadDocument_succeedsOnSuccessfulStoreCoordinatorDocumentLoad()
    func test_loadDocument_failsOnFailedStoreCoordinatorDocumentLoad()
    
    func test_addShape_addsShapeToDocument()
    func test_addShape_doesNotAddSameShapeToDocument()
    func test_addShape_addsDiferentShapeToDocument()
    func test_addShape_informsDelegateAboutUpdatedDocument()
    func test_addShape_doesNotInformDelegateAboutUpdatedDocumentWhenAddedSameShape()
    func test_addShape_asksStoreCoordinatorToSaveDocument()
    func test_addShape_asksStoreCoordinatorToSaveDocumentTwiceWhenAddingTwoDifferentShapes()
    func test_addShape_doesNotAskStoreCoordinatorToSaveDocumentWhenAddedSameShape()
    func test_addShape_informsItsDelegateAboutFailedDocumentSaving()
}
