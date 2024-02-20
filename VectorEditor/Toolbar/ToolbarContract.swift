//
//  ToolbarContract.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import Foundation

// MARK: - Entity

// MARK: - Router

protocol ToolbarRouterDelegate: AnyObject {
    func didChangeShapeType(to shapeType: ShapeType)
}

protocol ToolbarPresenterDelegate: AnyObject {
    func didTapRectButton()
    func didTapCircleButton()
}

// MARK: - View

// MARK: - Presenter

protocol ToolbarViewEventHandler: AnyObject {
    func onRectButtonTapped()
    func onCircleButtonTapped()
}

// MARK: - Interactor
