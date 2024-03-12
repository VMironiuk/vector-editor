//
//  CanvasViewModel.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 12.03.2024.
//

import Foundation

public protocol DocumentStoreCoordinatorProtocol {
    func saveDocument(_ document: Document, completion: @escaping (Error?) -> Void)
    func loadDocument(from storeURL: URL, completion: @escaping (Result<Document, Error>) -> Void)
}

public protocol CanvasViewModelDelegate: AnyObject {
    func didUpdateDocument(_ document: Document)
    func didFailToSaveDocument(with error: Error)
}

public final class CanvasViewModel {
    private let storeCoordinator: DocumentStoreCoordinatorProtocol
    private var multicastDelegate = MulticastDelegate<CanvasViewModelDelegate>()
    
    public private(set) var document: Document?
    
    public init(storeCoordinator: DocumentStoreCoordinatorProtocol) {
        self.storeCoordinator = storeCoordinator
    }
    
    public func saveDocument(_ document: Document, completion: @escaping (Error?) -> Void) {
        storeCoordinator.saveDocument(document, completion: completion)
    }
    
    public func loadDocument(from storeURL: URL, completion: @escaping (Result<Document, Error>) -> Void) {
        storeCoordinator.loadDocument(from: storeURL) { [weak self] result in
            switch result {
            case let .success(document):
                self?.document = document
                completion(.success(document))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public func addShape(_ shape: Document.Shape) {
        guard let document = document, !document.shapes.contains(shape) else { return }
        var shapes = document.shapes
        shapes.append(shape)
        self.document = .init(name: document.name, shapes: shapes)
        notifyDocumentDidUpdate()
    }
    
    public func removeShape(_ shape: Document.Shape) {
        guard var shapes = document?.shapes,
              let document = document,
              let shapeIndex = shapes.firstIndex(of: shape) else { return }
        shapes.remove(at: shapeIndex)
        self.document = .init(name: document.name, shapes: shapes)
        notifyDocumentDidUpdate()
    }
    
    public func registerObserver(_ observer: CanvasViewModelDelegate) {
        multicastDelegate.add(observer)
    }
    
    public func removeObserver(_ observer: CanvasViewModelDelegate) {
        multicastDelegate.remove(observer)
    }
    
    private func notifyDocumentDidUpdate() {
        guard let document = document else { return }
        multicastDelegate.delegates.forEach { $0.didUpdateDocument(document) }
        storeCoordinator.saveDocument(document) { [weak self] error in
            guard let error = error else { return }
            self?.multicastDelegate.delegates.forEach { $0.didFailToSaveDocument(with: error) }
        }
    }
}
