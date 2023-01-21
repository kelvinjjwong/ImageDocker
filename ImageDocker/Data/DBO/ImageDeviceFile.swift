//
//  ImageDeviceFile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/10.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct ImageDeviceFile : Codable {
    
    var fileId:String?
    var deviceId:String?
    var filename:String?
    var path:String?
    var fileDateTime:String?
    var fileSize:String?
    var fileMD5:String?
    var importDate:String?
    var importToPath:String?
    var importAsFilename:String?
    var localFilePath:String?
    
    static func new(fileId:String, deviceId:String, path:String, filename:String, fileDateTime:String, fileSize:String) -> ImageDeviceFile {
        return ImageDeviceFile(
            fileId: fileId,
            deviceId: deviceId,
            filename: filename,
            path: path,
            fileDateTime: fileDateTime,
            fileSize: fileSize,
            fileMD5: nil,
            importDate: nil,
            importToPath: nil,
            importAsFilename: nil,
            localFilePath: nil
        )
    }
}

extension ImageDeviceFile: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}


extension ImageDeviceFile : PostgresRecord {
    func postgresTable() -> String {
        return "ImageDeviceFile"
    }
    
    func primaryKeys() -> [String] {
        return ["fileId"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
