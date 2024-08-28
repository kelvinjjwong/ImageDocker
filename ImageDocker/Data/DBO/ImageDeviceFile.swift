//
//  ImageDeviceFile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/10.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import PostgresModelFactory

public final class ImageDeviceFile : Codable {
    
    var fileId:String?
    var deviceId:String?
    var filename:String?
    var path:String?
    var fileDateTime:String?
    var fileSize:String?
    var fileMD5:String?
    var importDate:String?
    var importToPath:String? // FIXME: demise
    var importAsFilename:String?
    var localFilePath:String?
    var devicePathId:String = ""
    var importedImageId:String = ""
    // FIXME: add field - repositoryId
    
    public init() {
        
    }
    
    static func new(fileId:String, deviceId:String, path:String, filename:String, fileDateTime:String, fileSize:String) -> ImageDeviceFile {
        let obj = ImageDeviceFile()
        obj.fileId = fileId
        obj.deviceId = deviceId
        obj.filename = filename
        obj.path = path
        obj.fileDateTime = fileDateTime
        obj.fileSize = fileSize
        return obj
    }
}

//extension ImageDeviceFile: FetchableRecord, MutablePersistableRecord, TableRecord {
//    public func didInsert(with rowID: Int64, for column: String?) {
//        // Update id after insertion
//        //id = rowID
//    }
//}


extension ImageDeviceFile : DatabaseRecord {
    public func postgresTable() -> String {
        return "ImageDeviceFile"
    }
    
    public func primaryKeys() -> [String] {
        return ["fileId"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
