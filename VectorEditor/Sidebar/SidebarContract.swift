//
//  SidebarContract.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import Foundation

// MARK: - Entity

struct SidebarPresenterState {
    let shapes: [ShapeItem]
}

// MARK: - Router

protocol SidebarRouterDelegate: AnyObject {
    func didRemoveShape(id: UUID)
}

protocol SidebarPresenterDelegate: AnyObject {
    func didRemoveShape(id: UUID)
}

// MARK: - View

protocol SidebarViewProtocol: AnyObject {
    func update(state: SidebarPresenterState)
}

// MARK: - Presenter

protocol SidebarViewEventHandler: AnyObject {
    func onShapeRemoved(id: UUID)
}

// MARK: - Interactor
