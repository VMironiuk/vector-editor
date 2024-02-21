//
//  ScenePresenter.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import Foundation

final class ScenePresenter {
    weak var view: SceneViewProtocol?
    weak var interactor: SceneInteractorProtocol?
    weak var delegate: ScenePresenterDelegate?
}

extension ScenePresenter: SceneViewEventHandler {
    func onTouchBegan(with point: CGPoint) {
        interactor?.handleTouchBegan(with: point)
    }
    
    func onTouchMoved(with point: CGPoint) {
        interactor?.handleTouchMoved(with: point)
    }
    
    func onTouchEnded(with point: CGPoint) {
        interactor?.handleTouchEnded(with: point)
    }
}

extension ScenePresenter: SceneInteractorDelegate {
    func didUpdateDrawingHandler(_ drawingHandler: @escaping DrawingHandler) {
        view?.update(state: ScenePresenterState(drawingHandler: drawingHandler))
    }
    
    func didAddShape(_ shape: ShapeProtocol) {
        delegate?.didAddShape(shape)
    }
}
