//
//  ImageDevice.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/10.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct ImageDevice : Codable {
    
    var deviceId:String?
    var type:String?
    var manufacture:String?
    var model:String?
    var name:String?
    var storagePath:String?
    var marketName:String?
    
    static func databaseTableName() -> String
    {
        return "ImageDevice"
    }
    
    static func new(deviceId: String, type: String, manufacture: String, model:String) -> ImageDevice {
        return ImageDevice(
            deviceId: deviceId,
            type: type,
            manufacture: manufacture,
            model: model,
            name: nil,
            storagePath: nil,
            marketName: nil
        )
    }
}

extension ImageDevice: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
