//
//  ItemCell.swift
//  ARCatalog
//
//  Created by User on 20.02.2023.
//

import UIKit

class ItemCell: UICollectionViewCell {
    @IBOutlet weak var itemLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let redView = UIView(frame: bounds)
        redView.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        self.backgroundView = redView

        let blueView = UIView(frame: bounds)
        blueView.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        self.selectedBackgroundView = blueView
    }

    override func prepareForReuse() {
        self.itemLabel.text = nil
        super.prepareForReuse()
    }

    func update(object: FurnitureObject) {
        self.itemLabel.text = object.name
    }
}
