//
//  ViewController.swift
//  AR_Day4_任意门
//
//  Created by 王永顺 on 2017/9/23.
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
//    检测平面
//    当我侦测到锚 的时候调用这个方法
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        锚点 VS 节点
        if anchor is ARPlaneAnchor {
//            锚 可以是任何形态，因为我们现在要检测水平面，所以我们会把锚 放在我们侦测到的水平面上
            let planeAnchor = anchor as! ARPlaneAnchor
            
            // 水平面 用 x，z 垂直面 用x，y
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//            extent  检测平面的宽跟高
//            锚 的大小 = 我所侦测到的水平面的大小
            let planeNode = SCNNode()//先不要急着把几何放进去
//            节点到底在哪里？节点就在锚 的中心位置（平面的中心位置）
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            //逆时针旋转90度
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane //??
            node.addChildNode(planeNode)
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //是否第一次点击
        if let touch = touches.first {
//            在2d 的屏幕上 点击的位置
            let touchLocation = touch.location(in: sceneView)
//            在2d 屏幕上所点击的位置，转换成手机里面的 3d坐标
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            //existingPlaneUsingExtent 我只在侦测到的平面的图上点击 才有作用
            
//            点击结果是否是 它的第一次
            if let hitResult = results.first {
                
                let boxScene = SCNScene(named: "art.scnassets/ship.scn")
                
                if let boxNode = boxScene?.rootNode.childNode(withName: "box", recursively: true) {
                    
                    boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
                    
                    sceneView.scene.rootNode.addChildNode(boxNode)
                }
            }
            
        }
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
