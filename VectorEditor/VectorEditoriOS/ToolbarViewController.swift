//
//  ToolbarViewController.swift
//  VectorEditoriOS
//
//  Created by Volodymyr Myroniuk on 07.03.2024.
//

import UIKit

final class ToolbarViewController: UIViewController {
    private let viewModel: ToolbarViewModel
    
    init(viewModel: ToolbarViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed("ToolbarView", owner: self)
    }
}
