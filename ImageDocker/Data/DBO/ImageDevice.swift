//
//  ImageDevice.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/10.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import PostgresModelFactory

public final class ImageDevice : Codable {
    
    var deviceId:String?
    var type:String?
    var manufacture:String?
    var model:String?
    var name:String?
    var storagePath:String? // FIXME: demise
    var marketName:String?
    var repositoryPath:String? // FIXME: demise
    var homePath:String? // FIXME: demise
    var metaInfo:String?
    // FIXME: add field - repositoryId
    
    public init() {
        
    }
    
    static func databaseTableName() -> String
    {
        return "ImageDevice"
    }
    
    static func new(deviceId: String, type: String, manufacture: String, model:String) -> ImageDevice {
        let obj = ImageDevice()
        obj.deviceId = deviceId
        obj.type = type
        obj.manufacture = manufacture
        obj.model = model
        return obj
    }
}

//extension ImageDevice: FetchableRecord, MutablePersistableRecord, TableRecord {
//    mutating func didInsert(with rowID: Int64, for column: String?) {
//        // Update id after insertion
//        //id = rowID
//    }
//}



extension ImageDevice : DatabaseRecord {
    public func postgresTable() -> String {
        return "ImageDevice"
    }
    
    public func primaryKeys() -> [String] {
        return ["deviceId"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
