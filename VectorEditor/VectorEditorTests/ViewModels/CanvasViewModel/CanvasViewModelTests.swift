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

final class MulticastDelegate<T> {
    private var storedDelegates = NSHashTable<AnyObject>(options: .weakMemory)
    
    var delegates: [T] {
        storedDelegates.allObjects as? [T] ?? []
    }
    
    func add(_ delegate: T) {
        storedDelegates.add(delegate as AnyObject)
    }
    
    func remove(_ delegate: T) {
        storedDelegates.remove(delegate as AnyObject)
    }
}

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

protocol DocumentStoreCoordinatorProtocol {
    func saveDocument(_ document: Document, completion: @escaping (Error?) -> Void)
    func loadDocument(from storeURL: URL, completion: @escaping (Result<Document, Error>) -> Void)
}

protocol CanvasViewModelDelegate: AnyObject {
    func didUpdateDocument(_ document: Document)
    func didFailToSaveDocument(with error: Error)
}

final class CanvasViewModel {
    private let storeCoordinator: DocumentStoreCoordinatorProtocol
    private var multicastDelegate = MulticastDelegate<CanvasViewModelDelegate>()
    
    private(set) var document: Document?
    
    init(storeCoordinator: DocumentStoreCoordinatorProtocol) {
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
    
    func removeShape(_ shape: Document.Shape) {
        guard var shapes = document?.shapes,
              let document = document,
              let shapeIndex = shapes.firstIndex(of: shape) else { return }
        shapes.remove(at: shapeIndex)
        self.document = .init(name: document.name, shapes: shapes)
        notifyDocumentDidUpdate()
    }
    
    func registerObserver(_ observer: CanvasViewModelDelegate) {
        multicastDelegate.add(observer)
    }
    
    func removeObserver(_ observer: CanvasViewModelDelegate) {
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

final class CanvasViewModelTests: XCTestCase, CanvasViewModelSpecs {
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
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, toSaveDocument: anyDocument(), withError: nil, when: {
            storeCoordinator.completeDocumentSaving(with: nil)
        })
    }
    
    func test_saveDocument_failsOnFailedStoreCoordinatorDocumentSave() {
        let (sut, storeCoordinator) = makeSUT()
        let anyNSError = anyNSError()
        expect(sut, toSaveDocument: anyDocument(), withError: anyNSError, when: {
            storeCoordinator.completeDocumentSaving(with: anyNSError)
        })
    }
    
    func test_loadDocument_succeedsOnSuccessfulStoreCoordinatorDocumentLoad() {
        let (sut, storeCoordinator) = makeSUT()
        let successfulResult: Result<Document, Error> = .success(anyDocument())
        expect(sut, toLoadDocumentFromURL: anyURL(), withResult: successfulResult, when: {
            storeCoordinator.completeDocumentLoading(with: successfulResult)
        })
    }
    
    func test_loadDocument_failsOnFailedStoreCoordinatorDocumentLoad() {
        let (sut, storeCoordinator) = makeSUT()
        let failedResult: Result<Document, Error> = .failure(anyNSError())
        expect(sut, toLoadDocumentFromURL: anyURL(), withResult: failedResult, when: {
            storeCoordinator.completeDocumentLoading(with: failedResult)
        })
    }
    
    func test_addShape_addsShapeToDocument() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, updatesDocumentWithShapes: [shape], whenAddsShapes: [shape])
    }
    
    func test_addShape_doesNotAddSameShapeToDocument() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, updatesDocumentWithShapes: [shape], whenAddsShapes: [shape, shape])
    }
    
    func test_addShape_addsDiferentShapeToDocument() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let anotherShape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, updatesDocumentWithShapes: [shape, anotherShape], whenAddsShapes: [shape, anotherShape])
    }
    
    func test_addShape_informsDelegateAboutUpdatedDocument() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, informsDelegateAboutAddedShapes: [shape], whenAddsShapes: [shape])
    }
    
    func test_addShape_doesNotInformDelegateAboutUpdatedDocumentWhenAddedSameShape() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, informsDelegateAboutAddedShapes: [shape], whenAddsShapes: [shape])
    }
    
    func test_addShape_asksStoreCoordinatorToSaveDocument() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, asksStoreCoordinatorToSaveDocumentWhenAddsShapes: [shape])
    }
    
    func test_addShape_asksStoreCoordinatorToSaveDocumentTwiceWhenAddingTwoDifferentShapes() {
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, asksStoreCoordinatorToSaveDocumentWhenAddsShapes: [
            .circle(.init(id: UUID(), createdAt: .now), .zero),
            .rectangle(.init(id: UUID(), createdAt: .now), .zero)
        ])
    }
    
    func test_addShape_doesNotAskStoreCoordinatorToSaveDocumentWhenAddedSameShape() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, asksStoreCoordinatorToSaveDocumentWhenAddsShapes: [shape, shape])
    }
    
    func test_addShape_informsItsDelegateAboutFailedDocumentSaving() {
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, informsDelegateAboutFailedDocumentSavingWithError: anyNSError())
    }
    
    func test_removeShape_doesNotAskStoreCoordinatorToRemoveShapeFromEmptyDocument() {
        let (sut, storeCoordinator) = makeSUT()
        
        sut.removeShape(.circle(.init(id: UUID(), createdAt: .now), .zero))
        
        XCTAssertEqual(storeCoordinator.saveDocumentCallCount, 0)
    }
    
    func test_removeShape_doesNotAskStoreCoordinatorToRemoveNonExistingShapeFromDocument() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withDocumentShapes: [shape], toCallStoreCoordinator: storeCoordinator, times: 1, when: {
            sut.removeShape(.rectangle(.init(id: UUID(), createdAt: .now), .zero))
        })
    }
    
    func test_removeShape_asksStoreCoordinatorToRemoveExistingShapeFromDocument() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withDocumentShapes: [shape], toCallStoreCoordinator: storeCoordinator, times: 2, when: {
            sut.removeShape(shape)
        })
    }
    
    func test_removeShape_removesShapeFromDocument() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, andAddedShapes: [shape], toHasShapesInDocument: [], when: {
            sut.removeShape(shape)
        })
    }
    
    func test_removeShape_doesNotRemoveNonExistingShapeFromDocument() {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, andAddedShapes: [shape], toHasShapesInDocument: [shape], when: {
            sut.removeShape(.rectangle(.init(id: UUID(), createdAt: .now), .zero))
        })
    }
    
    func test_removeShape_removesSecondShapeFromDocumentWhenCalledTwice() {
        let shape1 = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let shape2 = Document.Shape.rectangle(.init(id: UUID(), createdAt: .now), .zero)
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, withStoreCoordinator: storeCoordinator, andAddedShapes: [shape1, shape2], toHasShapesInDocument: [], when: {
            sut.removeShape(shape1)
            sut.removeShape(shape2)
        })
    }
    
    func test_removeShape_informsDelegateAboutUpdatedDocument() {
        let (sut, storeCoordinator) = makeSUT()
        expect(sut, informsDelegateAboutShapeRemovingWithStoreCoordinator: storeCoordinator)
    }
    
    func test_registerObserver_doesNotHaveMemoryLeak() {
        let (sut, storeCoordinator) = makeSUT()
        expectSUTDoesNotHaveMemoryLeakWithItsDelegate(sut, storeCoordinator: storeCoordinator)
    }

    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (CanvasViewModel, DocumentStoreCoordinatorSpy) {
        let storeCoordinator = DocumentStoreCoordinatorSpy()
        let sut = CanvasViewModel(storeCoordinator: storeCoordinator)

        trackForMemoryLeaks(storeCoordinator, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, storeCoordinator)
    }
    
    private func expect(
        _ sut: CanvasViewModel,
        toSaveDocument document: Document,
        withError expectedError: Error?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for save completion")
        sut.saveDocument(document) { receivedError in
            XCTAssertEqual(expectedError as? NSError, receivedError as? NSError, file: file, line: line)
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(
        _ sut: CanvasViewModel,
        toLoadDocumentFromURL storeURL: URL,
        withResult expectedResult: Result<Document, Error>,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
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
        
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(
        _ sut: CanvasViewModel,
        withStoreCoordinator storeCoordinator: DocumentStoreCoordinatorSpy,
        updatesDocumentWithShapes addedShapes: [Document.Shape],
        whenAddsShapes shapesToAdd: [Document.Shape],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // given
        
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
    
    private func expect(
        _ sut: CanvasViewModel,
        withStoreCoordinator storeCoordinator: DocumentStoreCoordinatorSpy,
        informsDelegateAboutAddedShapes addedShapes: [Document.Shape],
        whenAddsShapes shapesToAdd: [Document.Shape],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let delegate = CanvasViewModelDelegateSpy()
        sut.registerObserver(delegate)
        
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
    
    private func expect(
        _ sut: CanvasViewModel,
        withStoreCoordinator storeCoordinator: DocumentStoreCoordinatorSpy,
        asksStoreCoordinatorToSaveDocumentWhenAddsShapes  shapesToAdd: [Document.Shape],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // given
        
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
    
    func expect(
        _ sut: CanvasViewModel,
        withStoreCoordinator storeCoordinator: DocumentStoreCoordinatorSpy,
        informsDelegateAboutFailedDocumentSavingWithError savingError: NSError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // given
        
        let delegate = CanvasViewModelDelegateSpy()
        sut.registerObserver(delegate)
        
        // when
        
        sut.loadDocument(from: anyURL()) { _ in }
        storeCoordinator.completeDocumentLoading(with: .success(anyDocument()))
        sut.addShape(anyShape())
        storeCoordinator.completeDocumentSaving(with: savingError)
        
        // then
        
        XCTAssertEqual(delegate.savingErrors.map { $0 as NSError }, [savingError])
    }
    
    private func expect(
        _ sut: CanvasViewModel,
        withStoreCoordinator storeCoordinator: DocumentStoreCoordinatorSpy,
        andAddedShapes addedShapes: [Document.Shape],
        toHasShapesInDocument expectedShapes: [Document.Shape],
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // given
        
        sut.loadDocument(from: anyURL()) { _ in }
        storeCoordinator.completeDocumentLoading(with: .success(emptyDocument()))
        XCTAssertEqual(sut.document?.shapes, [], "Expected no shapes in document initially", file: file, line: line)
        addedShapes.forEach { sut.addShape($0) }
        XCTAssertEqual(sut.document?.shapes, addedShapes, "Expected added shapes to be in document", file: file, line: line)
        
        // when
        
        action()
        
        // then
        
        XCTAssertEqual(sut.document?.shapes, expectedShapes, file: file, line: line)
    }
    
    private func expect(
        _ sut: CanvasViewModel,
        withDocumentShapes shapes: [Document.Shape],
        toCallStoreCoordinator storeCoordinator: DocumentStoreCoordinatorSpy,
        times saveCallCount: Int,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // given
        
        sut.loadDocument(from: anyURL()) { _ in }
        storeCoordinator.completeDocumentLoading(with: .success(emptyDocument()))
        XCTAssertEqual(storeCoordinator.saveDocumentCallCount, 0, "Expected no save document requests")
        shapes.forEach { sut.addShape($0) }
        XCTAssertEqual(storeCoordinator.saveDocumentCallCount, 1, "Expected 1 save document request")
        
        // when
        
        action()
        
        // then
        
        XCTAssertEqual(
            storeCoordinator.saveDocumentCallCount,
            saveCallCount,
            "Expected \(saveCallCount) save document requests, got \(storeCoordinator.saveDocumentCallCount) instead",
            file: file,
            line: line)
    }
    
    private func expect(
        _ sut: CanvasViewModel,
        informsDelegateAboutShapeRemovingWithStoreCoordinator storeCoordinator: DocumentStoreCoordinatorSpy,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let shape = Document.Shape.circle(.init(id: UUID(), createdAt: .now), .zero)
        let delegate = CanvasViewModelDelegateSpy()
        sut.registerObserver(delegate)
        sut.loadDocument(from: anyURL()) { _ in }
        storeCoordinator.completeDocumentLoading(with: .success(emptyDocument()))
        XCTAssertTrue(sut.document?.shapes.isEmpty ?? true, "Expected view model's document to be empty or nil", file: file, line: line)
        XCTAssertTrue(delegate.document?.shapes.isEmpty ?? true, "Expected view models delegate's document to be empty or nil", file: file, line: line)
        sut.addShape(shape)
        XCTAssertEqual(sut.document?.shapes.count, 1, "Expected 1 shape added to view model's document", file: file, line: line)
        XCTAssertEqual(delegate.document?.shapes.count, 1, "Expected 1 shape added to view model delegate's document", file: file, line: line)
        
        sut.removeShape(shape)
        
        XCTAssertEqual(sut.document?.shapes.count, 0, file: file, line: line)
        XCTAssertEqual(delegate.document?.shapes.count, 0, file: file, line: line)
        XCTAssertEqual(sut.document, delegate.document, file: file, line: line)
    }
    
    private func expectSUTDoesNotHaveMemoryLeakWithItsDelegate(
        _ sut: CanvasViewModel,
        storeCoordinator: DocumentStoreCoordinatorSpy,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // given
        
        let delegate = CanvasViewModelDelegateSpy()
        
        // when
        
        sut.registerObserver(delegate)
        delegate.viewModelToCheckMemoryLeak = sut
        
        // then
        
        trackForMemoryLeaks(delegate, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(storeCoordinator, file: file, line: line)
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
