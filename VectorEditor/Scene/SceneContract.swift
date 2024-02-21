//
//  SceneContract.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import Foundation

// MARK: - Entity

struct ScenePresenterState {
    let shapeType: ShapeType
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
    func removeShape(with id: UUID)
}

// MARK: - Presenter

protocol SceneViewEventHandler: AnyObject {
    func onShapeAdded(_ shape: ShapeProtocol)
}

// MARK: - Interactor
