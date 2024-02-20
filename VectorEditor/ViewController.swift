//
//  ViewController.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var toolbarContainer: UIView!
    @IBOutlet private weak var sidebarContainer: UIView!
    @IBOutlet private weak var sceneContainer: UIView!
    
    private let toolbarRouter = ToolbarRouter()
    private let sidebarRouter = SidebarRouter()
    private let sceneRouter = SceneRouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRouters()
    }
}

// MARK: - Setup UI

private extension ViewController {
    private func setupUI() {
        setupToolbar()
        setupSidebar()
        setupScene()
    }
    
    private func setupToolbar() {
        let toolbar = toolbarRouter.viewController.view!
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbarContainer.addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: toolbarContainer.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: toolbarContainer.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: toolbarContainer.topAnchor),
            toolbar.bottomAnchor.constraint(equalTo: toolbarContainer.bottomAnchor)])
    }
    
    private func setupSidebar() {
        let sidebar = sidebarRouter.viewController.view!
        sidebar.translatesAutoresizingMaskIntoConstraints = false
        sidebarContainer.addSubview(sidebar)
        NSLayoutConstraint.activate([
            sidebar.leadingAnchor.constraint(equalTo: sidebarContainer.leadingAnchor),
            sidebar.trailingAnchor.constraint(equalTo: sidebarContainer.trailingAnchor),
            sidebar.topAnchor.constraint(equalTo: sidebarContainer.topAnchor),
            sidebar.bottomAnchor.constraint(equalTo: sidebarContainer.bottomAnchor)])
    }
    
    private func setupScene() {
        let scene = sceneRouter.viewController.view!
        scene.translatesAutoresizingMaskIntoConstraints = false
        sceneContainer.addSubview(scene)
        NSLayoutConstraint.activate([
            scene.leadingAnchor.constraint(equalTo: sceneContainer.leadingAnchor),
            scene.trailingAnchor.constraint(equalTo: sceneContainer.trailingAnchor),
            scene.topAnchor.constraint(equalTo: sceneContainer.topAnchor),
            scene.bottomAnchor.constraint(equalTo: sceneContainer.bottomAnchor)])
    }
}

// MARK: - Setup Routers

private extension ViewController {
    private func setupRouters() {
        toolbarRouter.delegate = sceneRouter
    }
}
