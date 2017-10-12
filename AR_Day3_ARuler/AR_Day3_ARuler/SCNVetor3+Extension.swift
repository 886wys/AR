//
//  SCNVetor3+Extension.swift
//  AR_Day3_ARuler
//
//  Created by 王永顺 on 2017/9/19.
//  Copyright © 2017年 EasonWang. All rights reserved.
//

import ARKit

extension SCNVector3 {
//    拿到镜头的坐标
    static func positionTransform(_ transfom: matrix_float4x4) -> SCNVector3 {
        
        return SCNVector3Make(transfom.columns.3.x, transfom.columns.3.y, transfom.columns.3.z)
    }
    
//    求距离
    func distance(form vector: SCNVector3) -> Float {
        
        let distanceX = self.x - vector.x
        let distanceY = self.y - vector.y
        let distanceZ = self.z - vector.z
        
        return sqrt((distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
        //        A(x1,y1,z1),B(x2,y2,z2),则A,B之间的距离为
        //        d=√[(x1-x2)^2+(y1-y2)^2+(z1-z2)^2]
    }
    
//    划线的方法
    func line(to vector: SCNVector3, color: UIColor) -> SCNNode {
    
        let indices: [UInt32] = [0,1] // 指数 (这个 0,1 到底是啥？ homework!) 材料
//        0 一维 .
//        1 二维 -
        let source = SCNGeometrySource(vertices: [self,vector]) //创建一个几何的容器
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)//创建一个几何元素（一条线）
        
        let geometry = SCNGeometry(sources :[source], elements: [element])
        
        geometry.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: geometry)
        return node
    }
}

extension SCNVector3: Equatable {
    
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}
