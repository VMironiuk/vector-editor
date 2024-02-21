//
//  SidebarViewController.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 20.02.2024.
//

import UIKit

class SidebarViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    private var shapes: [ShapeItem] = []
    
    weak var eventHandler: SidebarViewEventHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shapeCellNib = UINib(nibName: "ShapeCell", bundle: .main)
        tableView.register(shapeCellNib, forCellReuseIdentifier: "ShapeCell")
    }
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
        let shape = shapes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShapeCell", for: indexPath) as! ShapeCell
        cell.shapeImage.image = shape.image
        cell.shapeName.text = shape.name
        cell.shapeCreatedAt.text = shape.createdAt
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let shapeId = shapes[indexPath.row].id
        shapes.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        eventHandler?.onShapeRemoved(id: shapeId)
    }
}
