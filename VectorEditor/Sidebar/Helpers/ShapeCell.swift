//
//  ShapeCell.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 21.02.2024.
//

import UIKit

class ShapeCell: UITableViewCell {
    @IBOutlet private(set) weak var shapeImage: UIImageView!
    @IBOutlet private(set) weak var shapeName: UILabel!
    @IBOutlet private(set) weak var shapeCreatedAt: UILabel!
}
