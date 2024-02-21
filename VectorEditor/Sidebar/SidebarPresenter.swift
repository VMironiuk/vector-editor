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
    
    func addShape(_ shapeType: ShapeType) {
        var shapes = presenterState.shapes
        shapes.append(shapeType)
        presenterState = SidebarPresenterState(shapes: shapes)
        
        view?.update(state: presenterState)
    }
}
