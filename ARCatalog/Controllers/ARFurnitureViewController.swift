//
//  ARFurnitureViewController.swift
//  ARCatalog
//
//  Created by User on 20.02.2023.
//

import Foundation

import UIKit
import ARKit
class ARFurnitureViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var sceneView: VirtualObjectARView!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    @IBOutlet weak var addObjectButton: UIButton!
    
    // MARK: - Properties
    let model = ARFurnitureModel()
    
    let coachingOverlay = ARCoachingOverlayView()
    
    var focusSquare = FocusSquare()
    
    let configuration = ARWorldTrackingConfiguration()
    
    /// A type which manages gesture manipulation of virtual content in the scene.
    lazy var virtualObjectInteraction = VirtualObjectInteraction(sceneView: sceneView, viewController: self)
    /// Coordinates the loading and unloading of reference nodes for virtual objects.
    let virtualObjectLoader = VirtualObjectLoader()

    var session: ARSession {
        return sceneView.session
    }
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "updateQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        
        // Set up coaching overlay.
        setupCoachingOverlay()
        
        self.itemCollectionView.dataSource = self
        self.itemCollectionView.delegate = self
        self.registerGestureRecognizers()
        setupButton()
        setupTitile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        // Run the view's session
        session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func registerGestureRecognizers() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
    }

    private func setupButton() {
        addObjectButton.layer.cornerRadius = addObjectButton.layer.frame.width / 2
        addObjectButton.clipsToBounds = true
        addObjectButton.isEnabled = false
    }
    
    private func setupTitile() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.green]
        navigationItem.standardAppearance = appearance
    }
    

    @IBAction func addObjectTapped(_ sender: UIButton) {
        var object: VirtualObject?
        if let selectedItem = model.selectedItem {
            let modelsURL = Bundle.main.url(forResource: "art.scnassets", withExtension: nil)!
            let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
            
            _ = fileEnumerator.map { element in
                let url = element as! URL
                
                guard url.pathExtension == "scn" && url.path.contains(selectedItem.name) else { return }
                object = VirtualObject(url: url)
            }
        }
        guard let object = object else { return }
        if let query = sceneView.getRaycastQuery(for: object.allowedAlignment),
           let result = sceneView.castRay(for: query).first {
            object.mostRecentInitialPlacementResult = result
            object.raycastQuery = query
        } else {
            object.mostRecentInitialPlacementResult = nil
            object.raycastQuery = nil
        }
        virtualObjectLoader.loadVirtualObject(object, loadedHandler: { [unowned self] loadedObject in
            
            do {
                let scene = try SCNScene(url: object.referenceURL, options: nil)
                self.sceneView.prepare([scene], completionHandler: { _ in
                    DispatchQueue.main.async {
                        self.placeVirtualObject(loadedObject)
                    }
                })
            } catch {
                fatalError("Failed to load SCNScene from object.referenceURL")
            }
            
        })
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

    // MARK: - Focus Square

    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible || coachingOverlay.isActive {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
        }
        
        // Perform ray casting only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let query = sceneView.getRaycastQuery(),
            let result = sceneView.castRay(for: query).first {
            
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(raycastResult: result, camera: camera)
            }
            if !coachingOverlay.isActive {
                changeUI(hide: false)
            }
        } else {
            updateQueue.async {
                self.focusSquare.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
            changeUI(hide: true)
            navigationItem.title = "Find a surface to place objects"
        }
    }
    
    func changeUI(hide: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.addObjectButton.alpha = hide ? 0 : 1
            self.itemCollectionView.alpha = hide ? 0 : 1
        }) { _ in
            self.addObjectButton.isHidden = hide
            self.itemCollectionView.isHidden = hide
        }
    }
    
}

extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}



