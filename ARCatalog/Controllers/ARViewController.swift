//
//  ARViewController.swift
//  ARCatalog
//
//  Created by User on 14.02.2023.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    let model = ARDiceModel()
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func rollAllAgain(_ sender: UIBarButtonItem) {
        model.rollAll()
    }
    
    @IBAction func deleteAllDice(_ sender: UIBarButtonItem) {
        model.removeAll()
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - UIResponder
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            if let query = sceneView.raycastQuery(
                from: touchLocation,
                allowing: .existingPlaneGeometry,
                alignment: .any
            ) {
                let results = sceneView.session.raycast(query)
                if let hitResult = results.first {
                    if let diceNode = model.addDice(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y,
                        z: hitResult.worldTransform.columns.3.z
                    ) {
                        sceneView.scene.rootNode.addChildNode(diceNode)
                        model.rotateDice(node: diceNode)
                    }
                }
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        model.rollAll()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAchor = anchor as? ARPlaneAnchor else {
            return
        }
        // create SCNPlane
        let plane = SCNPlane(
            width: CGFloat(planeAchor.planeExtent.width),
            height: CGFloat(planeAchor.planeExtent.height)
        )
        // create SCNMaterial
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        // create SCNNode
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(x: planeAchor.center.x, y: 0, z: planeAchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        // add child node to parent node
        node.addChildNode(planeNode)
    }

}

