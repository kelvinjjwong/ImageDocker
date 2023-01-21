//
//  ImageDevicePath.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/13.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

public final class ImageDevicePath : Codable {
    //var id: Int64?      // <- the row id
    var id: String = ""
    var deviceId: String = ""
    var path: String = ""
    var toSubFolder: String = ""
    var exclude: Bool = false
    var manyChildren: Bool = false
    var excludeImported: Bool = false
    
    public init(){
        
    }
    
    static func include(deviceId: String, path:String, toSubFolder:String, manyChildren:Bool = false) -> ImageDevicePath {
        let key = "\(deviceId):\(path)"
        let obj = ImageDevicePath()
        obj.id = key
        obj.deviceId = deviceId
        obj.path = path
        obj.toSubFolder = toSubFolder
        obj.exclude = false
        obj.manyChildren = manyChildren
        obj.excludeImported = false
        return obj
    }
    
    static func exclude(deviceId: String, path:String) -> ImageDevicePath {
        let key = "\(deviceId):\(path)"
        let obj = ImageDevicePath()
        obj.id = key
        obj.deviceId = deviceId
        obj.path = path
        obj.toSubFolder = ""
        obj.exclude = true
        obj.manyChildren = false
        obj.excludeImported = false
        return obj
    }
}

extension ImageDevicePath: FetchableRecord, MutablePersistableRecord, TableRecord {

}


extension ImageDevicePath : PostgresRecord {
    public func postgresTable() -> String {
        return "ImageDevicePath"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
