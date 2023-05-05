//
//  OptionModel.swift
//  ARCatalog
//
//  Created by User on 20.02.2023.
//

import UIKit

enum OptionType {
    case furniture, solarSystem, drawing, dice
}

struct Option {
    let image: UIImage?
    let labelName: String
}

struct ChooseVCModel {
    let options: [Option] = [
        .init(image: #imageLiteral(resourceName: "furniture-image"), labelName: "Furniture"),
        .init(image: #imageLiteral(resourceName: "dice-image"), labelName: "Play dice"),
        .init(image: UIImage(systemName: "photo.artframe"), labelName: "Image recognition"),
        .init(image: UIImage(named: "objectRec"), labelName: "Object recognition")
//        ,
//        .init(image: #imageLiteral(resourceName: "solarSystem-image"), labelName: "Solar System"),
//        .init(image: #imageLiteral(resourceName: "drawing-image"), labelName: "Drawing"),
        
    ]
    
}
