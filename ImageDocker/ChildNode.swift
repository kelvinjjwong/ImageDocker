//
//  ChildNode.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

class ChildNode : BaseNode {
    
    
    override init() {
        super.init()
        self.nodeTitle = ""
    }
    
    override func description() -> String {
        return "ChildNode"
    }
    
    override func mutableKeys() -> [String] {
        var keys:[String] = super.mutableKeys()
        keys.append("description")
        return keys
    }
}
