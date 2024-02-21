//
//  SceneInteractor.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 21.02.2024.
//

import Foundation
import CoreGraphics

final class SceneInteractor {
    private var shapeType: ShapeType?
    private var startPoint: CGPoint?
    private var isMoving = false
    private var shapes: [ShapeProtocol] = []
    
    weak var delegate: SceneInteractorDelegate?
    
    private var drawingHandler: (CGContext) -> Void {
        { [weak self] context in
            self?.shapes.forEach { $0.draw(in: context) }
        }
    }
}

extension SceneInteractor: SceneInteractorProtocol {
    func changeShapeType(to shapeType: ShapeType) {
        self.shapeType = shapeType
    }
    
    func handleTouchBegan(with point: CGPoint) {
        guard shapeType != nil else { return }
        startPoint = point
    }
    
    func handleTouchMoved(with point: CGPoint) {
        guard shapeType == .rect, let startPoint = startPoint else { return }
        
        let rect = CGRect.make(p1: startPoint, p2: point)
        let shape = RectShape(rect: rect)
        
        if isMoving, !shapes.isEmpty, shapes.last?.type == .rect {
            shapes[shapes.count - 1] = shape
        } else {
            isMoving = true
            shapes.append(shape)
        }
        
        delegate?.didUpdateDrawingHandler(drawingHandler)
    }
    
    func handleTouchEnded(with point: CGPoint) {
        guard let shapeType = shapeType else { return }
        
        switch shapeType {
        case .rect:
            guard let shape = shapes.last, shape.type == .rect, isMoving else { return }
            delegate?.didAddShape(shape)
            isMoving = false
            
        case .circle:
            let shape = CircleShape(point: CGPoint(x: point.x - 25, y: point.y - 25))
            shapes.append(shape)
            delegate?.didAddShape(shape)
        }
        
        delegate?.didUpdateDrawingHandler(drawingHandler)
    }
    
    func removeShape(with id: UUID) {
        guard let index = (shapes.firstIndex { $0.id == id }) else { return }
        shapes.remove(at: index)
        delegate?.didUpdateDrawingHandler(drawingHandler)
    }
}

extension CGRect {
    static func make(p1: CGPoint, p2: CGPoint) -> CGRect {
        make(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y)
    }
    
    static func make(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat) -> CGRect {
        CGRect(x: min(x1, x2), y: min(y1, y2), width: abs(x1 - x2), height: abs(y1 - y2))
    }
}
