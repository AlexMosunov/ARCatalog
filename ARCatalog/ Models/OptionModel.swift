//
//  OptionModel.swift
//  ARCatalog
//
//  Created by User on 20.02.2023.
//

import UIKit

enum ARSceneType: String, CaseIterable {
    case furniture = "Furniture"
    case dice = "Play dice"
    case imageRec = "Image recognition"
    case objectRec = "Object recognition"
    case faceRec = "Face Recognition"
    
    var imageName: String {
        switch self {
        case .furniture:
            return "furniture"
        case .dice:
            return "dice"
        case .imageRec:
            return "imageRecognition"
        case .objectRec:
            return "objectRecognition"
        case .faceRec:
            return "faceRecognition"
        }
    }
}

struct Option {
    let type: ARSceneType
    let image: UIImage?
    let labelName: String
}

struct ChooseVCModel {
    let options: [Option] = ARSceneType.allCases.map {
        .init(
            type: $0,
            image: UIImage(named: $0.imageName),
            labelName: $0.rawValue
        )
    }
    
}
