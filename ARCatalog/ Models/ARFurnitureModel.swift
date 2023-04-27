//
//  ARFurnitureModel.swift
//  ARCatalog
//
//  Created by User on 20.02.2023.
//

import Foundation

enum FurnitureItem: String, CaseIterable {
    case cabinet, coffee, note, candle, Doguinho, shark, BigBenTower
}

struct FurnitureObject {
    let name: String
    var isSelected: Bool = false
    var isPlaced: Bool = false
}

class ARFurnitureModel {
    var itemsArray = FurnitureItem.allCases.map {
        FurnitureObject(name: $0.rawValue)
    }
    var selectedIndex: IndexPath?
    var selectedItem: FurnitureObject? {
        guard let selectedIndex = selectedIndex,
              itemsArray.count > selectedIndex.item else {
            return nil
        }
        return itemsArray[selectedIndex.item]
    }
}
