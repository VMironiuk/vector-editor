//
//  ToolbarViewController.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

class ToolbarViewController: UIViewController {
    weak var eventHandler: ToolbarViewEventHandler?
    
    @IBAction private func rectButtonTapped(_ sender: UIButton) {
        eventHandler?.onRectButtonTapped()
    }
    
    @IBAction private func circleButtonTapped(_ sender: UIButton) {
        eventHandler?.onCircleButtonTapped()
    }
}
