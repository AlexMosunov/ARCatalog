//
//  ARModel.swift
//  ARCatalog
//
//  Created by User on 20.02.2023.
//

import UIKit
import SceneKit

protocol ARModel {
    func secondLeftBarButtonTapped()
    func firstRightBarButtonTapped()
}

class ARDiceModel: ARModel {
    
    var diceArray = [SCNNode]()

    func rotateDice(node: SCNNode?) {
        guard let node = node else {
            return
        }
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomDuration = Double.random(in: 0.5...2)
        node.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 3),
                y: 0,
                z: CGFloat(randomZ * 3),
                duration: randomDuration)
        )
    }
    
    func addDice(x: Float, y: Float, z: Float) -> SCNNode? {
        let scene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let node = scene.rootNode.childNode(withName: "Dice", recursively: true) {
            print("Added child node")
            node.position = SCNVector3(
                x: x,
                y: y + node.boundingSphere.radius,
                z: z)
            diceArray.append(node)
            return node
        }
        return nil
    }
    
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                rotateDice(node: dice)
            }
        }
    }
    
    func removeAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    func secondLeftBarButtonTapped() {
        removeAll()
    }
    
    func firstRightBarButtonTapped() {
        rollAll()
    }
}
