//
//  ARFurnitureViewController+ARSCNViewDelegate.swift
//  ARCatalog
//
//  Created by User on 30.03.2023.
//

import Foundation
import ARKit

extension ARFurnitureViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else {
            return
        }
        DispatchQueue.main.async {
            self.navigationItem.title = "Surface detected. Select item."
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare(isObjectVisible: false)
        }
    }
}
    
