//
//  DocumentStoreCoordinatorSpy.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 12.03.2024.
//

import Foundation
import VectorEditor

final class DocumentStoreCoordinatorSpy: DocumentStoreCoordinatorProtocol {
    var saveDocumentCallCount: Int { saveCompletions.count }
    var loadDocumentCallCount: Int { loadCompletions.count }
    
    private var saveCompletions = [(Error?) -> Void]()
    private var loadCompletions = [(Result<Document, Error>) -> Void]()
    
    func saveDocument(_ document: Document, completion: @escaping (Error?) -> Void) {
        saveCompletions.append(completion)
    }
    
    func loadDocument(from storeURL: URL, completion: @escaping (Result<Document, Error>) -> Void) {
        loadCompletions.append(completion)
    }
    
    func completeDocumentSaving(with error: Error?, at index: Int = 0) {
        saveCompletions[index](error)
    }
    
    func completeDocumentLoading(with result: Result<Document, Error>, at index: Int  = 0) {
        loadCompletions[index](result)
    }
}
