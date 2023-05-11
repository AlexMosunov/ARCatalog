//
//  ARObjectRecognitionVC.swift
//  ARCatalog
//
//  Created by User on 03.05.2023.
//

import ARKit
import SceneKit
import UIKit

class ARObjectRecognitionVC: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    
    var session: ARSession {
        return sceneView.session
    }
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueueForObject")
    
    var objectNode: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        // Start the AR experience
        resetTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }

    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "ARObjects", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        configuration.detectionObjects = referenceObjects
        sceneView.session.run(configuration)
    }

    @IBAction func swimActionTapped(_ sender: UIButton) {
        runSwimAction(for: objectNode)
    }
    
    @IBAction func jumpActionTapped(_ sender: UIButton) {
        rot(for: objectNode)
    }
    
}

// MARK: - ARSCNViewDelegate
extension ARObjectRecognitionVC: ARSCNViewDelegate, ARSessionDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let objectAnchor = anchor as? ARObjectAnchor else { return }
        updateQueue.async {
            let plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x),
                                 height: CGFloat(objectAnchor.referenceObject.extent.y))
            plane.firstMaterial?.diffuse.contents = UIColor.brown.withAlphaComponent(0.3)
            plane.firstMaterial?.isDoubleSided = true
            let planeNode = SCNNode(geometry: plane)
            //            planeNode.eulerAngles.x = -.pi / 2
            planeNode.position = SCNVector3(
                objectAnchor.referenceObject.center.x,
                objectAnchor.referenceObject.center.y,
                objectAnchor.referenceObject.center.z
            )
            node.addChildNode(planeNode)
            guard let name = objectAnchor.referenceObject.name else {
                return
            }
            if let node = SCNNode.getNode(named: name){
                node.position = SCNVector3(
                    x: 0,
                    y: 0.05,
                    z: 0.05)
                self.objectNode = node
                let initialScale = node.scale
                node.scale = SCNVector3(0, 0, 0)
                planeNode.addChildNode(node)
                node.runAction(
                    SCNAction.sequence([.wait(duration: 0.5),
                                        .scale(to: CGFloat(initialScale.x * 0.1), duration: 1.0),
                                        .wait(duration: 1.0)])
                ) {
                    self.runSwimAction(for: node)
                }
            }
        }
    }
    
    func runSwimAction(for node: SCNNode?) {
        guard let node = node else {
            return
        }
        node.runAction(
            SCNAction.sequence([
                SCNAction.group([.moveBy(x: 0.1, y: 0, z: 0.1, duration: 1.0),
                                 SCNAction.rotate(by: CGFloat(GLKMathDegreesToRadians(90)), around: SCNVector3(x: 0, y: 1, z: 0), duration: 1.0)]),
                SCNAction.group([.moveBy(x: 0.1, y: 0, z: -0.1, duration: 1.0),
                                 SCNAction.rotate(by: CGFloat(GLKMathDegreesToRadians(90)), around: SCNVector3(x: 0, y: 1, z: 0), duration: 1.0)]),
                SCNAction.group([.moveBy(x: -0.1, y: 0, z: -0.1, duration: 1.0),
                                 SCNAction.rotate(by: CGFloat(GLKMathDegreesToRadians(90)), around: SCNVector3(x: 0, y: 1, z: 0), duration: 1.0)]),
                SCNAction.group([.moveBy(x: -0.1, y: 0, z: 0.1, duration: 1.0),
                                 SCNAction.rotate(by: CGFloat(GLKMathDegreesToRadians(90)), around: SCNVector3(x: 0, y: 1, z: 0), duration: 1.0)])
            ])
        )
    }

    func runJumpAction(for node: SCNNode?) {
        guard let node = node else {
            return
        }
        node.runAction(
            SCNAction.sequence([
                SCNAction.group([.moveBy(x: 0, y: 0.05, z: 0, duration: 0.5),
                                 .rotateBy(x: 3.0, y: 0, z: 0, duration: 0.5)]),
                SCNAction.group([.moveBy(x: 0, y: -0.05, z: 0, duration: 0.5),
                                 .rotateBy(x: 3.0, y: 0, z: 0, duration: 0.5)])
            ])
        )
    }
    
    func rot(for node: SCNNode?) {
        guard let node = node else {
            return
        }
        node.runAction(
            SCNAction.sequence([
                SCNAction.group([.moveBy(x: 0, y: 0.05, z: 0, duration: 0.5),
                                 SCNAction.rotate(by: -CGFloat(GLKMathDegreesToRadians(180)), around: SCNVector3(x: 1, y: 0, z: 0), duration: 0.5)]),
                SCNAction.group([.moveBy(x: 0, y: -0.05, z: 0, duration: 0.5),
                                 SCNAction.rotate(by: -CGFloat(GLKMathDegreesToRadians(180)), around: SCNVector3(x: 1, y: 0, z: 0), duration: 0.5)])
            ])
        )
        
    }
}
