//
//  SidebarViewController.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

class SidebarViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var shapes: [ShapeType] = []
}

extension SidebarViewController: SidebarViewProtocol {
    func update(state: SidebarPresenterState) {
        shapes = state.shapes
        tableView.reloadData()
    }
}

extension SidebarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shapes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(shapes[indexPath.row])"
        return cell
    }
}
