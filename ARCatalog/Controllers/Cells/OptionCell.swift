//
//  OptionCell.swift
//  ARCatalog
//
//  Created by User on 20.02.2023.
//

import UIKit

class OptionCell: UICollectionViewCell {
    static var indentifier: String { "OptionCell" }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 10
    }
    func update(model: Option) {
        imageView.image = model.image
        label.text = model.labelName
    }
}


