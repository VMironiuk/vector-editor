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
    
    func addShape(_ shape: ShapeProtocol) {
        var shapes = presenterState.shapes
        shapes.append(shapeItem(from: shape))
        presenterState = SidebarPresenterState(shapes: shapes)
        
        view?.update(state: presenterState)
    }
    
    private func shapeItem(from shape: ShapeProtocol) -> ShapeItem {
        let name = shapeName(from: shape.type)
        return ShapeItem(id: shape.id, name: name, createdAt: shape.createdAt.description)
    }
    
    private func shapeName(from shapeType: ShapeType) -> String {
        switch shapeType {
        case .rect:
            return "Rectangle"
        case .circle:
            return "Circle"
        }
    }
}
