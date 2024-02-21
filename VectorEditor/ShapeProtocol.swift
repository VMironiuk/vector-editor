//
//  ShapeProtocol.swift
//  VectorEditor
//
//  Created by Volodymyr Myroniuk on 21.02.2024.
//

import Foundation

protocol ShapeProtocol {
    var id: UUID { get }
    var type: ShapeType { get }
    var createdAt: Date { get }
}
