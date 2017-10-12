//
//  ARSCNView+Extension.swift
//  AR_Day3_ARuler
//
//  Created by 王永顺 on 2017/9/19.
//  Copyright © 2017年 EasonWang. All rights reserved.
//

import ARKit

extension ARSCNView {

//    拿到三维坐标
    func worldVector(for position: CGPoint) -> SCNVector3? {
        
        let results = self.hitTest(position, types: [.featurePoint])
        
        guard let result = results.first else {
            return nil
        }
        
//        等一下我们返回相机的位置
        return SCNVector3.positionTransform(result.worldTransform)
    }
}
