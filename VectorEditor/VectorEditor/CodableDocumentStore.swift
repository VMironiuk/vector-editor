//
//  CodableDocumentStore.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 06.03.2024.
//

import Foundation

public final class CodableDocumentStore {
    public init() {}
    
    public func save(document: CodableDocument, to storeURL: URL, completion: @escaping (Error?) -> Void) {
        do {
            let encoder = JSONEncoder()
            let encodedDocument = try encoder.encode(document)
            try encodedDocument.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func load(from storeURL: URL, completion: @escaping (Result<CodableDocument, Error>) -> Void) {
        do {
            let data = try Data(contentsOf: storeURL)
            let decoder = JSONDecoder()
            let document = try decoder.decode(CodableDocument.self, from: data)
            completion(.success(document))
        } catch {
            completion(.failure(error))
        }
    }
}
