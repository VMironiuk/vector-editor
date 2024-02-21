//
//  SidebarPresenter.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

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
        let image = shapeImage(from: shape.type)
        let createdAt = shapeCreatedAt(from: shape.createdAt)
        return ShapeItem(id: shape.id, name: name, createdAt: createdAt, image: image)
    }
    
    private func shapeName(from shapeType: ShapeType) -> String {
        switch shapeType {
        case .rect:
            return "Rectangle"
        case .circle:
            return "Circle"
        }
    }
    
    private func shapeImage(from shapeType: ShapeType) -> UIImage? {
        switch shapeType {
        case .rect:
            return UIImage(named: "Rectangle")
        case .circle:
            return UIImage(named: "Ellipse")
        }
    }
    
    private func shapeCreatedAt(from date: Date) -> String {
        date.formatted(date: .numeric, time: .standard)
    }
}
