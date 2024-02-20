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

// MARK: - View

protocol SceneViewProtocol: AnyObject {
    func update(state: ScenePresenterState)
}

// MARK: - Presenter

// MARK: - Interactor
