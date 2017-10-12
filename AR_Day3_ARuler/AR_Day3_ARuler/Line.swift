//
//  Line.swift
//  AR_Day3_ARuler
//
//  Created by 王永顺 on 2017/9/19.
//  Copyright © 2017年 EasonWang. All rights reserved.
//

import ARKit

enum LengthUnit {
    case meter, cenitMeter, inch
    
    var factor: Float {
        switch self {
        case .meter:
            return 1.0
        case .cenitMeter:
            return 100.0
        case .inch:
            return 39.3700787
        }
    }
    
    var name: String {
        switch self {
        case .meter:
            return "m"
        case .cenitMeter:
            return "cm"
        case .inch:
            return "inch"
        }
    }
    
}

class Line {
    
    var color = UIColor.red
    var startNode: SCNNode
    var endNode: SCNNode
    var textNode: SCNNode
    var text: SCNText
    var lineNode: SCNNode?
    
    let sceneView: ARSCNView
    let startVector: SCNVector3
    let unit: LengthUnit
    
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: LengthUnit) {
//        我们将要在这里创建节点。（开始，结束，线，数字，单位）
        
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        let dot = SCNSphere(radius: 0.5)
        dot.firstMaterial?.diffuse.contents = color
        dot.firstMaterial?.lightingModel = .constant//不会产生阴影
        dot.firstMaterial?.isDoubleSided = true //两面都一样光亮
//        创建一个圆的两面光亮，正反两面都抛光的球
        startNode = SCNNode(geometry: dot)
        startNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)//注意这里有巨坑 除数要float
        startNode.position = startVector
        
        sceneView.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: dot)
        endNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = .systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = color
        text.firstMaterial?.lightingModel = .constant//不会产生阴影
        text.firstMaterial?.isDoubleSided = true//两面都一样光亮
        text.alignmentMode = kCAAlignmentCenter
        text.truncationMode = kCATruncationMiddle//...
//        包装文字的节点
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)//让字体对着我
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        
//        我们无法预期说文字会出现在哪？所以我们要给它来个约束，这个约束把文字和节点绑在我们的线中间位置
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
//        SCNLookAtConstraint 是一个约束，让他跟随我们设定的目标
//        永远面向使用者
        
        constraint.isGimbalLockEnabled = true//默认是false
        
        textNode.constraints = [constraint]//添加约束
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
        //01:2105
    }
    
    func update(to vector: SCNVector3) {
        
        lineNode?.removeFromParentNode()//把所有的线移除
        
        lineNode = startVector.line(to: vector, color: color)
        sceneView.scene.rootNode.addChildNode(lineNode!)
//        更新文字
        text.string = distance(to: vector)
//        设置文字的位置（放在线的中间）
        textNode.position = SCNVector3((startVector.x + vector.x) / 2.0, (startVector.y + vector.y) / 2.0, (startVector.z + vector.z) / 2.0)
        
//        结束节点的位置 在手机移动了多少 他就在那里
        endNode.position = vector
        
        if endNode.parent == nil {
            
            sceneView.scene.rootNode.addChildNode(endNode)
        }
    }
    
    func distance(to vector: SCNVector3) -> String {
        
        return String(format: "%0.2f %@", startVector.distance(form: vector) * unit.factor, unit.name)
    }
    
    func remove() {
        startNode.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
    }
}
