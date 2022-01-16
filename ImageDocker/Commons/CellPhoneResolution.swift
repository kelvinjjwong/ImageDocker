//
//  CellPhoneResolution.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2022/1/9.
//  Copyright © 2022 nonamecat. All rights reserved.
//

import Foundation

struct CellPhoneResolution {
    
    private var store:[String:(Int, Int)] = [:]
    
    static let `default` = CellPhoneResolution()
    
    init() {
        store["Mate 10"] = (1080, 1920)
        store["iPhone 12,1"] = (1080, 2337)
        store["iPhone 7,2"] = (750, 1334)
        store["BLA-AL100"] = (1080, 2160)
    }
    
    func getSize(model:String) -> (Int, Int) {
        if let (width, height) = store[model] {
            return (width, height)
        }else{
            return (0, 0)
        }
    }
}
