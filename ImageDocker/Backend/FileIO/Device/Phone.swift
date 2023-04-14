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
    var path:String = ""
    var onDevicePath:String = ""
    var fileMD5:String = "" {
        didSet {
            matched = ( fileMD5 == storedMD5 && fileDateTime == storedDateTime && fileSize == storedSize )
            matchedWithoutMD5 = ( fileDateTime == storedDateTime && fileSize == storedSize )
        }
    }
    var fileDateTime:String = ""
    var fileSize:String = ""
    var storedMD5:String = ""
    var storedDateTime:String = ""
    var storedSize:String = ""
    var importDate:String = ""
    var importToPath:String = ""
    var importAsFilename:String = "" {
        didSet {
            stored = (importAsFilename != "")
            
            if fileDateTime == "" { // from mac os
                matched = ( fileSize == storedSize )
                matchedWithoutMD5 = matched
                //stored = matched
            } else { // from android device
                matched = ( fileMD5 == storedMD5 && fileDateTime == storedDateTime && fileSize == storedSize )
                matchedWithoutMD5 = ( fileDateTime == storedDateTime && fileSize == storedSize )
            }
        }
    }
    
    var matched:Bool = false
    var matchedWithoutMD5:Bool = false
    var checksumMode:ChecksumMode = .Rough
    var stored:Bool = false
    var deviceFile:ImageDeviceFile?
    var folder:String = ""
    
    init(filename:String, path:String){
        self.filename = filename
        self.path = path
    }
    
    init(filename:String, path:String, md5:String){
        self.filename = filename
        self.path = path
        self.fileMD5 = md5
    }
}

enum MobileType:Int {
    case Android
    case iPhone
    case Unknown
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
    
    // present as title in tree node
    func represent() -> String {
        var summary = ""
//        if totalSize != "" {
//            summary = "\(availSize) / \(totalSize), used \(usedPercent)"
//        }else {
            summary = deviceId
//        }
        if name != "" {
            let recognizedModel = Naming.Camera.recognize(maker: manufacture, model: model)
            return "\(name) (\(manufacture) \(recognizedModel)) [\(summary)]"
            
        }
        if model != "" && manufacture != "" {
            let recognizedModel = Naming.Camera.recognize(maker: manufacture, model: model)
            return "\(manufacture) \(recognizedModel) [\(summary)]"
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
