//
//  ARImageRecognitionVC.swift
//  ARCatalog
//
//  Created by User on 27.04.2023.
//

import ARKit
import SceneKit
import UIKit

class ARImageRecognitionVC: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet var answerButtons: [UIButton]!
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    var refferenceImageName: String?
    
    let model = QuizModel()
    var planeNode: SCNNode?
    
    // MARK: - View Controller Life Cycle
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
    
    @IBAction func quizAnswerButtonTapped(_ sender: UIButton) {
        guard let name = refferenceImageName,
              let question = self.model.questions[name] else { return }
        if sender.titleLabel?.text == question.correctAnswer {
            UIView.animate(withDuration: 2) {
                sender.tintColor = .green
            } completion: { completed in
                if completed {
                    self.model.questions[name]?.answeredCorrectly = true
                    self.updateARData(question: self.model.questions[name]!)
                }
            }
        } else {
            sender.tintColor = .red
        }
    }
    
    func resetUI() {
        DispatchQueue.main.async {
            for btn in self.answerButtons {
                btn.tintColor = UIColor.link
            }
        }
    }
    
    
    // MARK: - Session management (Image detection setup)
    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
    func resetTracking() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "ARpics", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        session.run(configuration)
    }
}

// MARK: - ARSCNViewDelegate

extension ARImageRecognitionVC: ARSCNViewDelegate, ARSessionDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        refferenceImageName = referenceImage.name
        guard let name = refferenceImageName,
              let question = self.model.questions[name] else { return }
        self.resetUI()
        updateQueue.async {
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor.clear
            self.planeNode = SCNNode(geometry: plane)
            self.planeNode?.eulerAngles.x = -.pi / 2
            node.addChildNode(self.planeNode!)

            self.updateARData(question: question)
        }
    }
    
    func updateARData(question: QuizQuestionObject) {
        guard let planeNode = planeNode else { return }
        planeNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        let spacingX: Float = 0.005
        var spacingY: Float = 0

        if question.answeredCorrectly {
            let descriptionNode = textNode(question.description, font: UIFont.systemFont(ofSize: 5), maxWidth: 100)
            descriptionNode.pivotOnTopLeft()
            descriptionNode.position.x += 0.07 + spacingX
            descriptionNode.position.y += 0.12
            planeNode.addChildNode(descriptionNode)
            
            let pln = SCNPlane(width: descriptionNode.width, height: CGFloat(descriptionNode.height))
            pln.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.5)
            pln.firstMaterial?.isDoubleSided = true
//            pln.cornerRadius = pln.width / 10
            let plnNode = SCNNode(geometry: pln)
//            plnNode.eulerAngles.x = -.pi / 2
            plnNode.pivotOnTopLeft()
            plnNode.position = SCNVector3(descriptionNode.position.x, descriptionNode.position.y, descriptionNode.position.z - 0.01)
            planeNode.addChildNode(plnNode)
            
        } else {
            for itemText in question.answers {
                let answersTitle = self.textNode(itemText, font: UIFont.boldSystemFont(ofSize: 10))
                answersTitle.pivotOnTopLeft()
                answersTitle.position.x += 0.07 + spacingX
                answersTitle.position.y += answersTitle.position.y - spacingY
                planeNode.addChildNode(answersTitle)
                spacingY += answersTitle.height + 0.01
            }
        }
        
        let questionTitle = model.getQuestiontitle(question)
        planeNode.addChildNode(questionTitle)
        
        if let objectNode = model.get3DModel(question) {
            let initialScale = objectNode.scale
            objectNode.scale = SCNVector3(0, 0, 0)
            planeNode.addChildNode(objectNode)
            objectNode.runAction(
                SCNAction.sequence([.wait(duration: 0.2),
                                    .scale(to: CGFloat(initialScale.x), duration: 1.0)])
            )
        }
    }
    
    func createBGNode(for node: SCNNode) -> SCNNode {
        let plane = SCNPlane(width: 200, height: 100)
        plane.firstMaterial?.diffuse.contents = UIColor.black
        let BGnode = SCNNode(geometry: plane)
        BGnode.position = SCNVector3(0, 0, 0)
        BGnode.eulerAngles.x = -.pi / 2
        return BGnode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("didRemove")
    }
}


extension ARImageRecognitionVC {
    func textNode(_ str: String, font: UIFont, maxWidth: Int? = nil) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0)

        text.flatness = 0.1
        text.font = font


        if let maxWidth = maxWidth {
            text.containerFrame = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: 500))
            text.isWrapped = true
        }

        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)

        return textNode
    }
}
