//
//  ToolbarPresenter.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import Foundation

final class ToolbarPresenter {
    weak var delegate: ToolbarPresenterDelegate?
}

extension ToolbarPresenter: ToolbarViewEventHandler {
    func onRectButtonTapped() {
        delegate?.didTapRectButton()
    }
    
    func onCircleButtonTapped() {
        delegate?.didTapCircleButton()
    }
}
