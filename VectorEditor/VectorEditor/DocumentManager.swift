//
//  DocumentManager.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import Foundation

public final class DocumentManager {
    private let store: DocumentStoreProtocol
    
    public init(store: DocumentStoreProtocol) {
        self.store = store
    }
    
    public func load() {
        store.load()
    }
    
    public func save() {
        store.save()
    }
}
