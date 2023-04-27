//
//  ARFurnitureViewController+UICollectionView.swift
//  ARCatalog
//
//  Created by User on 11.04.2023.
//

import UIKit

extension ARFurnitureViewController: UICollectionViewDataSource , UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.itemsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.update(object: model.itemsArray[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if model.selectedIndex == indexPath {
            model.selectedIndex = nil
            addObjectButton.isEnabled = false
            collectionView.deselectItem(at: indexPath, animated: false)
            navigationItem.title = "Please select item to display"
        } else {
            model.selectedIndex = indexPath
            addObjectButton.isEnabled = true
            navigationItem.title = "Tap add butoon to display selected item"
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        model.selectedIndex = nil
        addObjectButton.isEnabled = false
    }
}
