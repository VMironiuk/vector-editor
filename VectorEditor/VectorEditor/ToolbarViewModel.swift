//
//  ToolbarViewModel.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 07.03.2024.
//

import Foundation

public enum SupportedShape: CaseIterable {
    case circle
    case rectangle
}

public protocol ToolbarViewModelDelegate: AnyObject {
    func didSelectShape(_ shape: SupportedShape)
}

public final class ToolbarViewModel {
    private var selectedShape: SupportedShape?
    
    public let documentName: String
    public let supportedShapes: [SupportedShape]
    
    public weak var delegate: ToolbarViewModelDelegate?
    
    public var onShapeSelected: ((SupportedShape) -> Void)?
    
    public init(documentName: String, supportedShapes: [SupportedShape]) {
        self.documentName = documentName
        self.supportedShapes = supportedShapes
    }
    
    public func selectShape(_ shape: SupportedShape) {
        guard selectedShape != shape else { return }
        delegate?.didSelectShape(shape)
        onShapeSelected?(shape)
        selectedShape = shape
        
        print(shape)
    }
}
