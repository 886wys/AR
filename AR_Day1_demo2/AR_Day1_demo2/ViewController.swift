//
//  ViewController.swift
//  AR_Day1_demo2
//
//  Created by 王永顺 on 2017/9/11.
//  Copyright © 2017年 EasonWang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let textures = ["earth.jpg","jupiter.jpg","mars.jpg","venus.jpg"]
    private var index = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
        
//        let scene = SCNScene()
//        //创建几何
//        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//        //创建节点
//        let boxNode = SCNNode(geometry: box)
//
//        //xuanr
//        let material = SCNMaterial()// material 渲染器
////        material.diffuse.contents = UIColor.red
//        material.diffuse.contents = UIImage(named: "brick.png")
//
//        box.materials = [material]
//
//        //设置节点位置
//        boxNode.position = SCNVector3(0,0,-0.2)
//        //把节点添加到根节点上
//        scene.rootNode.addChildNode(boxNode)
//
//        sceneView.scene = scene
//        ++++++++++++++++++++++++++++++++++++++++++++++++++
        
        let scene = SCNScene()
        
        let sphere = SCNSphere(radius: 0.1)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "earth.jpg")
        sphere.materials = [material]
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0,0,-0.5)
        scene.rootNode.addChildNode(sphereNode)
        
        sceneView.scene = scene
        
        registerGestureRecognizers()
    }
    
    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func tapAction(reconizer: UIGestureRecognizer) {
        
        let sceneView = reconizer.view as! ARSCNView
        let touchLocation = reconizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        //一开始的时候 index = 0
        if !hitResults.isEmpty {
            if index == self.textures.count {
                index = 0
            }
            
            guard let hitResult = hitResults.first else {
                return
            }
            
            let node = hitResult.node
            node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: textures[index])
            
            index += 1
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
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
