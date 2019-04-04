//
//  ImageDevicePath.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/2/13.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct ImageDevicePath : Codable {
    //var id: Int64?      // <- the row id
    var id: String
    var deviceId: String
    var path: String
    var toSubFolder: String
    var exclude: Bool
    var manyChildren: Bool
    
    
    
    static func include(deviceId: String, path:String, toSubFolder:String, manyChildren:Bool = false) -> ImageDevicePath {
        let key = "\(deviceId):\(path)"
        return ImageDevicePath(
            id: key,
            deviceId: deviceId,
            path: path,
            toSubFolder: toSubFolder,
            exclude: false,
            manyChildren: manyChildren
        )
    }
    
    static func exclude(deviceId: String, path:String) -> ImageDevicePath {
        let key = "\(deviceId):\(path)"
        return ImageDevicePath(
            id: key,
            deviceId: deviceId,
            path: path,
            toSubFolder: "",
            exclude: true,
            manyChildren: false
        )
    }
}

extension ImageDevicePath: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
