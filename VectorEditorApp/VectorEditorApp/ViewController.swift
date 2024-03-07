//
//  ViewController.swift
//  VectorEditorApp
//
//  Created by Volodymyr Myroniuk on 07.03.2024.
//

import UIKit
import VectorEditoriOS

class ViewController: UIViewController {
    @IBOutlet private weak var toolbarContainer: UIView!
    
    private let toolbarComposer = ToolbarComposer(documentName: "", supportedShapes: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolbar = toolbarComposer.view
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbarContainer.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: toolbarContainer.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: toolbarContainer.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: toolbarContainer.topAnchor),
            toolbar.bottomAnchor.constraint(equalTo: toolbarContainer.bottomAnchor)
        ])
    }
}

