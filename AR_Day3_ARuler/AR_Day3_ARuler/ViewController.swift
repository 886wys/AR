//
//  ViewController.swift
//  AR_Day3_ARuler
//
//  Created by 王永顺 on 2017/9/19.
//  Copyright © 2017年 EasonWang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var targetImageView: UIImageView!
    
    var session = ARSession()
    var configuration = ARWorldTrackingConfiguration()
    var isMeasuring = false //默认是没有在测量状态
    
    var vectorZero = SCNVector3() //0,0,0
    var vectorStart = SCNVector3()
    var vectorEnd = SCNVector3()
    var lines = [Line]()
    var currentLine: Line?
    var unit = LengthUnit.cenitMeter //单位默认cm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        全局追踪的高级用法，牛逼！
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
    }
    
    func setup() {
        sceneView.delegate = self
        sceneView.session = session
        infoLabel.text = "环境初始化中~"
    }
    
    
    @IBAction func resetButtonHandler(_ sender: UIButton) {
        
        for line in lines {
            line.remove()
        }
        
        lines.removeAll()
    }
    
    @IBAction func unitButtonHandler(_ sender: UIButton) {
    }
    
//    点击屏幕
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        如果不在测量状态的话
        if !isMeasuring {
            reset()
            isMeasuring = true
            targetImageView.image = UIImage(named: "GreenTarget")
        } else {
            isMeasuring = false
            
            if let line = currentLine {
                lines.append(line)
                currentLine = nil
                targetImageView.image = UIImage(named: "WhiteTarget")
            }
        }
    }
    
    func reset() {
//        isMeasuring = true
        vectorStart = SCNVector3()
        vectorEnd = SCNVector3()
    }
    
//    扫描这个世界（开始测量）
    func scanWorld() {
//        获取现在画面中心点的位置
        guard let worldPosition = sceneView.worldVector(for: view.center) else {
            return
        }
        
//        如果画面上一条线都没有
        if lines.isEmpty {
            infoLabel.text = "点击画面试试看"
        }
        
//        如果现在测量状态
        if isMeasuring {
//            设置开始节点
            if vectorStart == vectorZero {
                vectorStart = worldPosition//把现在的位置设为开始
                currentLine = Line(sceneView: sceneView, startVector: vectorStart, unit: unit)
            }
            
//            设置结束的节点
            vectorEnd = worldPosition
            currentLine?.update(to: vectorEnd)
            infoLabel.text = currentLine?.distance(to: vectorEnd) ?? "..."
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            self.scanWorld()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
        infoLabel.text = "错误"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
        infoLabel.text = "中断~"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
        infoLabel.text = "结束"
    }
}

