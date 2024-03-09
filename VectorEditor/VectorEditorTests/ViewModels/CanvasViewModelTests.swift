//
//  CanvasViewModelTests.swift
//  VectorEditorTests
//
//  Created by Volodymyr Myroniuk on 07.03.2024.
//

import XCTest

public struct Document {
    public enum Shape {
        public struct Metadata {
            public let id: UUID
            public let createdAt: Date
            public init(id: UUID, createdAt: Date) {
                self.id = id
                self.createdAt = createdAt
            }
        }
        case circle(Metadata, NSRect)
        case rectangle(Metadata, NSRect)
    }

    public let name: String
    public let shapes: [Shape]
    
    public init(name: String, shapes: [Shape]) {
        self.name = name
        self.shapes = shapes
    }
}

final class DocumentStoreCoordinatorSpy {
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

final class CanvasViewModelDelegateSpy: CanvasViewModelDelegate {
    private(set) var document: Document?
    private(set) var savingErrors = [Error]()
    
    func didUpdateDocument(_ document: Document) {
        self.document = document
    }
    
    func didFailToSaveDocument(with error: any Error) {
        savingErrors.append(error)
    }
}

protocol CanvasViewModelDelegate: AnyObject {
    func didUpdateDocument(_ document: Document)
    func didFailToSaveDocument(with error: Error)
}

final class CanvasViewModel {
    private let storeCoordinator: DocumentStoreCoordinatorSpy
    private(set) var document: Document?
    
    var onDocumentDidUpdate: ((Document) -> Void)?
    var onDocumentSaveDidFail: ((Error) -> Void)?
    
    weak var delegate: CanvasViewModelDelegate?
    
    init(storeCoordinator: DocumentStoreCoordinatorSpy) {
        self.storeCoordinator = storeCoordinator
    }
    
    func saveDocument(_ document: Document, completion: @escaping (Error?) -> Void) {
        storeCoordinator.saveDocument(document, completion: completion)
    }
    
    func loadDocument(from storeURL: URL, completion: @escaping (Result<Document, Error>) -> Void) {
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
    
    func addShape(_ shape: Document.Shape) {
        guard let document = document, !document.shapes.contains(shape) else { return }
        var shapes = document.shapes
        shapes.append(shape)
        self.document = .init(name: document.name, shapes: shapes)
        notifyDocumentDidUpdate()
    }
    
    private func notifyDocumentDidUpdate() {
        guard let document = document else { return }
        onDocumentDidUpdate?(document)
        delegate?.didUpdateDocument(document)
        storeCoordinator.saveDocument(document) { [weak self] error in
            guard let error = error else { return }
            self?.delegate?.didFailToSaveDocument(with: error)
            self?.onDocumentSaveDidFail?(error)
        }
    }
}

final class CanvasViewModelTests: XCTestCase {
    func test_init_doesNotAskStoreCoordinatorToSaveDocument() {
        let (_, storeCoordinator) = makeSUT()
        
        XCTAssertEqual(storeCoordinator.saveDocumentCallCount, 0)
    }
    
    func test_init_doesNotAskStoreCoordinatorToLoadDocument() {
        let (_, storeCoordinator) = makeSUT()

        XCTAssertEqual(storeCoordinator.loadDocumentCallCount, 0)
    }
    
    func test_init_desNotInitializeDocument() {
        let (sut, _) = makeSUT()

        XCTAssertNil(sut.document)
    }
    
    func test_saveDocument_succeedsOnSuccessfulStoreCoordinatorDocumentSave() {
        expectSaveDocument(toCompleteWith: nil)
    }
    
    func test_saveDocument_failsOnFailedStoreCoordinatorDocumentSave() {
        expectSaveDocument(toCompleteWith: anyNSError())
    }
    
    func test_loadDocument_succeedsOnSuccessfulStoreCoordinatorDocumentLoad() {
        expectLoadDocument(toCompleteWith: .success(anyDocument()))
    }
    
    func test_loadDocument_failsOnFailedStoreCoordinatorDocumentLoad() {
        expectLoadDocument(toCompleteWith: .failure(anyNSError()))
    }
    
    func test_addShape_addsShapeToDocument() {
        let shapeToAdd = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        assertAddingShapes([shapeToAdd], didAddShapes: [shapeToAdd])
    }
    
    func test_addShape_doesNotAddSameShapeToDocument() {
        let shapeToAdd = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        assertAddingShapes([shapeToAdd, shapeToAdd], didAddShapes: [shapeToAdd])
    }
    
    func test_addShape_addsDiferentShapeToDocument() {
        let shapeToAdd = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let anotherShapeToAdd = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        assertAddingShapes([shapeToAdd, anotherShapeToAdd], didAddShapes: [shapeToAdd, anotherShapeToAdd])
    }
    
    func test_addShape_informsObserverAboutUpdatedDocument() {
        let shapeToAdd = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        assertAddingShapes([shapeToAdd], informsObserverAboutAddedShapes: [shapeToAdd])
    }
    
    func test_addShape_doesNotInformObserverAboutUpdatedDocumentWhenAddedSameShape() {
        let shapeToAdd = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        assertAddingShapes([shapeToAdd, shapeToAdd], informsObserverAboutAddedShapes: [shapeToAdd])
    }
    
    func test_addShape_informsDelegateAboutUpdatedDocument() {
        let shapeToAdd = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        assertAddingShapes([shapeToAdd], informsDelegateAboutAddedShapes: [shapeToAdd])
    }
    
    func test_addShape_doesNotInformDelegateAboutUpdatedDocumentWhenAddedSameShape() {
        let shapeToAdd = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        assertAddingShapes([shapeToAdd, shapeToAdd], informsDelegateAboutAddedShapes: [shapeToAdd])
    }
    
    func test_addShape_asksStoreCoordinatorToSaveDocument() {
        let shapeToAdd = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        assertAddingShapesAsksStoreCoordinatorToSaveDocument([shapeToAdd])
    }
    
    func test_addShape_asksStoreCoordinatorToSaveDocumentTwiceWhenAddingTwoDifferentShapes() {
        assertAddingShapesAsksStoreCoordinatorToSaveDocument([
            .circle(.init(id: UUID(), createdAt: .now), .zero),
            .rectangle(.init(id: UUID(), createdAt: .now), .zero)
        ])
    }
    
    func test_addShape_doesNotAskStoreCoordinatorToSaveDocumentWhenAddedSameShape() {
        let shapeToAdd = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        assertAddingShapesAsksStoreCoordinatorToSaveDocument([shapeToAdd, shapeToAdd])
    }
    
    func test_addShape_informsItsDelegateAboutFailedDocumentSaving() {
        let savingError = anyNSError()
        let delegate = CanvasViewModelDelegateSpy()
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        sut.delegate = delegate
        
        sut.loadDocument(from: anyURL()) { _ in }
        storeCoordinator.completeDocumentLoading(with: .success(anyDocument()))
        sut.addShape(anyShape())
        storeCoordinator.completeDocumentSaving(with: savingError)
        
        XCTAssertEqual(delegate.savingErrors.map { $0 as NSError }, [savingError])
    }
    
    func test_addShape_informsItsObserverAboutFailedDocumentSaving() {
        let savingError = anyNSError()
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        
        sut.onDocumentSaveDidFail = {
            XCTAssertEqual($0 as NSError, savingError)
        }
        
        sut.loadDocument(from: anyURL()) { _ in }
        storeCoordinator.completeDocumentLoading(with: .success(anyDocument()))
        sut.addShape(anyShape())
        storeCoordinator.completeDocumentSaving(with: savingError)
    }

    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (CanvasViewModel, DocumentStoreCoordinatorSpy) {
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)

        trackForMemoryLeaks(storeCoordinator, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, storeCoordinator)
    }
    
    private func expectSaveDocument(
        toCompleteWith expectedError: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        let exp = expectation(description: "Wait for save completion")
        
        sut.saveDocument(anyDocument()) { receivedError in
            XCTAssertEqual(expectedError as? NSError, receivedError as? NSError, file: file, line: line)
            exp.fulfill()
        }
        storeCoordinator.completeDocumentSaving(with: expectedError)
        wait(for: [exp], timeout: 1)
    }
    
    private func expectLoadDocument(
        toCompleteWith expectedResult: Result<Document, Error>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        let exp = expectation(description: "Wait for load completion")
                
        sut.loadDocument(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedDocument), .success(expectedDocument)):
                XCTAssertEqual(receivedDocument, expectedDocument, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        storeCoordinator.completeDocumentLoading(with: expectedResult)
        wait(for: [exp], timeout: 1)
    }
    
    private func assertAddingShapes(
        _ shapesToAdd: [Document.Shape],
        didAddShapes addedShapes: [Document.Shape],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // given
        
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        
        XCTAssertNil(sut.document, "Expected the document to be nil initially",  file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        sut.loadDocument(from: anyURL()) { _ in exp.fulfill() }
        
        let anyDocument = anyDocument()
        storeCoordinator.completeDocumentLoading(with: .success(anyDocument))
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(sut.document?.shapes, anyDocument.shapes, file: file, line: line)
        
        // when
        
        shapesToAdd.forEach { sut.addShape($0) }
        
        // then
        
        var expectedShapes = anyDocument.shapes
        addedShapes.forEach { expectedShapes.append($0) }
        XCTAssertEqual(sut.document?.shapes.count, expectedShapes.count, file: file, line: line)
        XCTAssertEqual(sut.document?.shapes, expectedShapes, file: file, line: line)
    }
    
    private func assertAddingShapes(
        _ shapesToAdd: [Document.Shape],
        informsObserverAboutAddedShapes addedShapes: [Document.Shape],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        var receivedDocument: Document?
        sut.onDocumentDidUpdate = { receivedDocument = $0  }
        
        XCTAssertNil(sut.document, "Expected the document to be nil initially", file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        sut.loadDocument(from: anyURL()) { _ in exp.fulfill() }
        
        let initialDocument = emptyDocument()
        storeCoordinator.completeDocumentLoading(with: .success(initialDocument))
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(sut.document?.shapes, initialDocument.shapes, file: file, line: line)
        
        // when
        
        shapesToAdd.forEach { sut.addShape($0) }
        
        // then
        
        var expectedShapes = initialDocument.shapes
        addedShapes.forEach { expectedShapes.append($0) }
        let expectedDocument = Document(name: initialDocument.name, shapes: expectedShapes)
        XCTAssertEqual(expectedDocument.shapes.count, receivedDocument?.shapes.count, file: file, line: line)
        XCTAssertEqual(expectedDocument, receivedDocument, file: file, line: line)
    }
    
    private func assertAddingShapes(
        _ shapesToAdd: [Document.Shape],
        informsDelegateAboutAddedShapes addedShapes: [Document.Shape],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let delegate = CanvasViewModelDelegateSpy()
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        sut.delegate = delegate
        
        XCTAssertNil(sut.document, "Expected the document to be nil initially", file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        sut.loadDocument(from: anyURL()) { _ in exp.fulfill() }
        
        let initialDocument = anyDocument()
        storeCoordinator.completeDocumentLoading(with: .success(initialDocument))
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(sut.document?.shapes, initialDocument.shapes, file: file, line: line)
        
        // when
        
        shapesToAdd.forEach { sut.addShape($0) }
        
        // then
        
        var expectedShapes = initialDocument.shapes
        addedShapes.forEach { expectedShapes.append($0) }
        let expectedDocument = Document(name: initialDocument.name, shapes: expectedShapes)
        XCTAssertEqual(expectedDocument.shapes.count, delegate.document?.shapes.count, file: file, line: line)
        XCTAssertEqual(expectedDocument, delegate.document, file: file, line: line)
    }
    
    private func assertAddingShapesAsksStoreCoordinatorToSaveDocument(
        _ shapesToAdd: [Document.Shape],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let delegate = CanvasViewModelDelegateSpy()
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)
        sut.delegate = delegate
        
        XCTAssertNil(sut.document, "Expected the document to be nil initially", file: file, line: line)
        XCTAssertEqual(storeCoordinator.saveDocumentCallCount, 0, "Expected no save requests", file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        sut.loadDocument(from: anyURL()) { _ in exp.fulfill() }
        
        let initialDocument = anyDocument()
        storeCoordinator.completeDocumentLoading(with: .success(initialDocument))
        
        wait(for: [exp], timeout: 1)
        
        // when
        
        let uniqueShapesToAdd = Array(Set(shapesToAdd))
        uniqueShapesToAdd.forEach { sut.addShape($0) }
        
        // then
        
        XCTAssertEqual(
            storeCoordinator.saveDocumentCallCount, uniqueShapesToAdd.count,
            "Expected to ask for save \(uniqueShapesToAdd.count) time(s), but called \(storeCoordinator.saveDocumentCallCount) time(s)",
            file: file,
            line: line)
    }
    
    private func anyDocument() -> Document {
        Document(name: "a document", shapes: [
            .circle(.init(id: UUID(), createdAt: .now), .init(x: 3, y: 3, width: 14, height: 14)),
            .rectangle(.init(id: UUID(), createdAt: .now), .init(x: 14, y: 14, width: 42, height: 42))
        ])
    }
    
    private func emptyDocument() -> Document {
        Document(name: "initially empty document", shapes: [])
    }
    
    private func anyShape() -> Document.Shape {
        .circle(.init(id: UUID(), createdAt: .now), .zero)
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any domain", code: 1)
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
}

extension Document: Equatable, Hashable {
    public static func == (lhs: Document, rhs: Document) -> Bool {
        lhs.name == rhs.name && lhs.shapes == rhs.shapes
    }
}

extension Document.Shape: Equatable, Hashable {
    public static func == (lhs: Document.Shape, rhs: Document.Shape) -> Bool {
        switch (lhs, rhs) {
        case let (.circle(lhsMetadata, lhsFrame), .circle(rhsMetadata, rhsFrame)):
            return lhsMetadata == rhsMetadata && lhsFrame == rhsFrame
            
        case let (.rectangle(lhsMetadata, lhsFrame), .rectangle(rhsMetadata, rhsFrame)):
            return lhsMetadata == rhsMetadata && lhsFrame == rhsFrame

        default:
            return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .circle(metadata, frame):
            hasher.combine(metadata)
            hasher.combine(frame)
        case let .rectangle(metadata, frame):
            hasher.combine(metadata)
            hasher.combine(frame)
        }
    }
}

extension Document.Shape.Metadata: Equatable, Hashable {
    public static func == (lhs: Document.Shape.Metadata, rhs: Document.Shape.Metadata) -> Bool {
        lhs.id == rhs.id && lhs.createdAt == rhs.createdAt
    }
}

extension NSRect: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(origin.x)
        hasher.combine(origin.y)
        hasher.combine(width)
        hasher.combine(height)
    }
}
