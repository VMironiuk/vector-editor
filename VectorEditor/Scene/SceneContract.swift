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
    func didAddShape()
}

protocol ScenePresenterDelegate: AnyObject {
    func didAddShape()
}

// MARK: - View

protocol SceneViewProtocol: AnyObject {
    func update(state: ScenePresenterState)
}

// MARK: - Presenter

protocol SceneViewEventHandler: AnyObject {
    func onShapeAdded()
}

// MARK: - Interactor
