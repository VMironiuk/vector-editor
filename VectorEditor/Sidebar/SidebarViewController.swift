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
        cell.shapeImage.image = nil
        cell.shapeName.text = shape.name
        cell.shapeCreatedAt.text = shape.createdAt
        return cell
    }
}
