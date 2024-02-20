//
//  SidebarContract.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import Foundation

// MARK: - Entity

struct SidebarPresenterState {
    let shapes: [String]
}

// MARK: - Router

// MARK: - View

protocol SidebarViewProtocol: AnyObject {
    func update(state: SidebarPresenterState)
}

// MARK: - Presenter

// MARK: - Interactor
