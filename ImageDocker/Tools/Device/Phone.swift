//
//  PhoneFile.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/20.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

struct PhoneFile {
    
    var filename:String = ""
    var md5:String = ""
    var path:String = ""
    
    init(filename:String, path:String){
        self.filename = filename
        self.path = path
    }
    
    init(filename:String, path:String, md5:String){
        self.filename = filename
        self.path = path
        self.md5 = md5
    }
}

enum MobileType:Int {
    case Android
    case iPhone
}

struct PhoneDevice {
    var type:MobileType
    var deviceId:String = ""
    var manufacture:String = ""
    var model:String = ""
    var name:String = ""
    var iccid:String = ""
    var meid:String = ""
    var totalSize:String = ""
    var availSize:String = ""
    var usedPercent:String = ""
    
    init(type:MobileType, deviceId:String, manufacture:String, model:String) {
        self.type = type
        self.deviceId = deviceId
        self.manufacture = manufacture
        self.model = model
    }
    
    func represent() -> String {
        var summary = ""
        if totalSize != "" {
            summary = "\(availSize) / \(totalSize), used \(usedPercent)"
        }else {
            summary = deviceId
        }
        if name != "" {
            return "\(manufacture) \(name) [\(summary)]"
            
        }
        if model != "" && manufacture != "" {
            return "\(manufacture) \(model) [\(summary)]"
        }
        if deviceId != "" {
            if type == .Android {
                return "Android \(deviceId)"
            }
            if type == .iPhone {
                return "iPhone \(deviceId)"
            }
        }
        return "Unknown \(deviceId)"
    }
    
}
