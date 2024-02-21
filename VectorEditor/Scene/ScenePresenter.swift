//
//  ScenePresenter.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import Foundation

final class ScenePresenter {
    weak var view: SceneViewProtocol?
    weak var delegate: ScenePresenterDelegate?
    
    func changeShapeType(to shapeType: ShapeType) {
        view?.update(state: ScenePresenterState(shapeType: shapeType))
    }
}

extension ScenePresenter: SceneViewEventHandler {
    func onShapeAdded(_ shapeType: ShapeType) {
        delegate?.didAddShape(shapeType)
    }
}
