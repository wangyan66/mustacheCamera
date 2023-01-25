//
//  ViewController.swift
//  moodMeTest
//
//  Created by 王焱 on 2023/1/24.
//

import UIKit
import ARKit
class ViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var StartBtn: UIButton!
    @IBOutlet weak var StopBtn: UIButton!
    private var capture: ARCapture?
    
    let noseOptions = ["nose01", "nose02", "nose03", "nose04", "nose05", "nose06", "nose07", "nose08", "nose09"]
    let beardOptions = ["beard01", "beard03"]
    let features = ["beard"]
    var featureIndices = [[0]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StartBtn.isHidden = false
        StopBtn.isHidden = true
        sceneView.delegate = self
        capture = ARCapture(view: sceneView)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuratio = ARFaceTrackingConfiguration()
        
        sceneView.session.run(configuratio)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    @IBAction func  handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        let results = sceneView.hitTest(location, options: nil)
        if let result = results.first,
            let node = result.node as? FaceNode {
            node.next()
        }
    }
    
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
//        print(featureIndices)
        node.geometry?.firstMaterial?.transparency = 0.0
        for (feature, indices) in zip(features, featureIndices) {
            let child = node.childNode(withName: feature, recursively: false) as? FaceNode
            let vertices = indices.map { anchor.geometry.vertices[$0] }
            child?.updatePosition(for: vertices)
        }
    }
    /// "Record" button action handler
    @IBAction func recordAction(_ sender: UIButton) {
        StartBtn.isHidden = true
        StopBtn.isHidden = false
        capture?.start()
    }

    /// "Stop" button action handler
    @IBAction func stopAction(_ sender: UIButton) {
        StartBtn.isHidden = false
        StopBtn.isHidden = true
        capture?.stop({ (status) in
            print("Video exported: \(status)")
        })
    }

}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        

        let device: MTLDevice!
        device = MTLCreateSystemDefaultDevice()
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return nil
        }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
                node.geometry?.firstMaterial?.fillMode = .lines
        
        let noseNode = FaceNode(with: beardOptions)
        noseNode.name = "beard"
        node.addChildNode(noseNode)
        
        updateFeatures(for: node, using: faceAnchor)
        
        return node
    }
    
    func renderer(
        _ renderer: SCNSceneRenderer,
        didUpdate node: SCNNode,
        for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
                return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
    }
    
    
}

