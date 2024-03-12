//
//  CanvasViewModelDelegateSpy.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 12.03.2024.
//

import Foundation
import VectorEditor

final class CanvasViewModelDelegateSpy: CanvasViewModelDelegate {
    private(set) var document: Document?
    private(set) var savingErrors = [Error]()
    
    var viewModelToCheckMemoryLeak: CanvasViewModel?
    
    func didUpdateDocument(_ document: Document) {
        self.document = document
    }
    
    func didFailToSaveDocument(with error: any Error) {
        savingErrors.append(error)
    }
}
