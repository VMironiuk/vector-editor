//
//  SidebarPresenter.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import Foundation

final class SidebarPresenter {
    private var presenterState = SidebarPresenterState(shapes: [])
    
    weak var view: SidebarViewProtocol?
    
    func addShape() {
        var shapes = presenterState.shapes
        shapes.append("shape")
        presenterState = SidebarPresenterState(shapes: shapes)
        
        view?.update(state: presenterState)
    }
}
