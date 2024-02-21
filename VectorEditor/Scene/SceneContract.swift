//
//  SceneContract.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import Foundation
import CoreGraphics

// MARK: - Entity

typealias DrawingHandler = (CGContext) -> Void

struct ScenePresenterState {
    let drawingHandler: DrawingHandler
}

// MARK: - Router

protocol SceneRouterDelegate: AnyObject {
    func didAddShape(_ shape: ShapeProtocol)
}

protocol ScenePresenterDelegate: AnyObject {
    func didAddShape(_ shape: ShapeProtocol)
}

// MARK: - View

protocol SceneViewProtocol: AnyObject {
    func update(state: ScenePresenterState)
}

// MARK: - Presenter

protocol SceneViewEventHandler: AnyObject {
    func onTouchBegan(with point: CGPoint)
    func onTouchMoved(with point: CGPoint)
    func onTouchEnded(with point: CGPoint)
}

protocol SceneInteractorDelegate: AnyObject {
    func didUpdateDrawingHandler(_ drawingHandler: @escaping DrawingHandler)
    func didAddShape(_ shape: ShapeProtocol)
}

// MARK: - Interactor

protocol SceneInteractorProtocol: AnyObject {
    func changeShapeType(to shapeType: ShapeType)
    func handleTouchBegan(with point: CGPoint)
    func handleTouchMoved(with point: CGPoint)
    func handleTouchEnded(with point: CGPoint)
    func removeShape(with id: UUID)
}
