//
//  ViewController.swift
//  AR_Day1_demo1
//
//  Created by 王永顺 on 2017/9/11.
//  Copyright © 2017年 EasonWang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        //添加一个手势
        let topGesture = UITapGestureRecognizer(target: self, action: #selector(handTap(gestureRecognizer:)))
        
        view.addGestureRecognizer(topGesture)
    }
    
    @objc func handTap(gestureRecognizer:UITapGestureRecognizer)  {
        
        /*
         */
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
//        guard sceneView.session.currentFrame != nil else {
//            return
//        }
        
        //创建一张图片
        let imagePlane = SCNPlane(width: sceneView.bounds.width / 6000, height: sceneView.bounds.height / 6000)
        
        //渲染图片
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()//截屏
        imagePlane.firstMaterial?.lightingModel = .constant
        
        //创建一个节点
        let planNode = SCNNode(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planNode)
        
        //追踪相机的位置
        var translate = matrix_identity_float4x4
        translate.columns.3.z = -0.1
        
        planNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translate)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
