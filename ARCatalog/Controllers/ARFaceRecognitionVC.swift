//
//  ARFaceRecognitionVC.swift
//  ARCatalog
//
//  Created by User on 09.05.2023.
//

import UIKit
import ARKit
import SceneKit

class ARFaceRecognitionVC: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    var contentNode: SCNNode?
    var occlusionNode: SCNNode?
    var faceOverlayContent: SCNReferenceNode?
    var updatedGlasses = false
    
    let glasses = ["fbxGlasses", "glassesSun", "Glasses", "sunglasses"]
    var selectedGlasses: String?
    var randomGlasses: String {
        selectedGlasses = glasses.randomElement()!
        return selectedGlasses!
    }
    
    var session: ARSession {
        return sceneView.session
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.orange]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
    
    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        configuration.isLightEstimationEnabled = true
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }


}

extension ARFaceRecognitionVC: ARSCNViewDelegate, ARSessionDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView,
              anchor is ARFaceAnchor else { return nil }
        
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        faceGeometry.firstMaterial!.colorBufferWriteMask = []
        occlusionNode = SCNNode(geometry: faceGeometry)
        occlusionNode!.renderingOrder = -1
        // Add 3D asset positioned to appear as "glasses".
        generateRandomGlasses()
        
        contentNode = SCNNode()
        if let occlusionNode = occlusionNode,
           let faceOverlayContent = faceOverlayContent {
            contentNode!.addChildNode(occlusionNode)
            contentNode!.addChildNode(faceOverlayContent)
        }
        updateMessage(message: "Blink to get next glasses")
        return contentNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = occlusionNode?.geometry as? ARSCNFaceGeometry,
              let faceAnchor = anchor as? ARFaceAnchor
        else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
        
        let blendShapes = faceAnchor.blendShapes
        guard let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
              let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,
              let jawOpen = blendShapes[.jawOpen] as? Float
        else { return }
        updateGlasses(with: eyeBlinkRight, and: eyeBlinkLeft)
        if jawOpen > 0.5 {
            generateRandomGlasses()
        }
    }
    
    private func generateRandomGlasses() {
        faceOverlayContent?.removeFromParentNode()
        let randomGl = randomGlasses
        faceOverlayContent = SCNReferenceNode(named: randomGl)
        if randomGl == "glassesSun" {
            faceOverlayContent?.scale = SCNVector3(x: 1.4, y: 1.4, z: 1.4)
        }
        contentNode?.addChildNode(faceOverlayContent!)
    }
    
    private func getNextGlasses() {
        guard let selectedGlasses = selectedGlasses else {
            generateRandomGlasses()
            return
        }
        if let nextGl = glasses.nextElement(after: selectedGlasses) {
            self.selectedGlasses = nextGl
            faceOverlayContent?.removeFromParentNode()
            faceOverlayContent = SCNReferenceNode(named: nextGl)
            if nextGl == "glassesSun" {
                faceOverlayContent?.scale = SCNVector3(x: 1.4, y: 1.4, z: 1.4)
            }
            contentNode?.addChildNode(faceOverlayContent!)
        }
    }
    
    private func updateGlasses(with eyeBlinkRight: Float, and eyeBlinkLeft: Float) {
        if eyeBlinkRight < 0.5 && eyeBlinkLeft > 0.5 ||
           eyeBlinkRight > 0.5 && eyeBlinkLeft < 0.5 {
            if !updatedGlasses {
                updatedGlasses = true
                getNextGlasses()
                self.updateMessage(message: "Open your mouth to generate random glasses")
            }
        } else  if eyeBlinkRight < 0.25 && eyeBlinkLeft < 0.25 {
            updatedGlasses = false
        }
    }
    
    private func updateMessage(message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.navigationItem.title = message
        }
    }
}
