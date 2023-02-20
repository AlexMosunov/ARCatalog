//
//  ARFurnitureViewController.swift
//  ARCatalog
//
//  Created by User on 20.02.2023.
//

import Foundation

import UIKit
import ARKit
class ARFurnitureViewController: UIViewController, UICollectionViewDataSource , UICollectionViewDelegate, ARSCNViewDelegate{
    
    let model = ARFurnitureModel()
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    let configuration = ARWorldTrackingConfiguration()
    var selectedItem: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        
        self.itemCollectionView.dataSource = self
        self.itemCollectionView.delegate = self
        self.registerGestureRecognizers()
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
    
    func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
        longPressGestureRecognizer.minimumPressDuration = 0.1
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        
        if !hitTest.isEmpty {
            
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            print(sender.scale)
            node.runAction(pinchAction)
            sender.scale = 1.0
        }
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        
        if let query = sceneView.raycastQuery(
            from: tapLocation,
            allowing: .existingPlaneGeometry,
            alignment: .any
        ) {
            let results = sceneView.session.raycast(query)
            if let hitResult = results.first {
                self.addItem(hitTestResult: hitResult)
            }
        }
    }
    
    func addItem(hitTestResult: ARRaycastResult) {
        if let selectedItem = self.selectedItem {
            let scene = SCNScene(named: "art.scnassets/\(selectedItem).scn")
            let node = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3
            node.position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            if selectedItem == "table" {
                self.centerPivot(for: node)
            }
            self.sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.itemsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.itemLabel.text = model.itemsArray[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedItem = model.itemsArray[indexPath.row]
        cell?.backgroundColor = UIColor.green
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }
    
    
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
    
    @objc func rotate(sender: UILongPressGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let holdLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(holdLocation)
        if !hitTest.isEmpty {
            
            let result = hitTest.first!
            if sender.state == .began {
                let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 1)
                let forever = SCNAction.repeatForever(rotation)
                result.node.runAction(forever)
            } else if sender.state == .ended {
                result.node.removeAllActions()
            }
        }
    }
    
    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }
    
    @IBAction func tapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}



