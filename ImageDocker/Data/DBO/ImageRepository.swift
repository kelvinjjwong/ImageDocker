//
//  ImageRepository.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/7.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import PostgresModelFactory

public final class ImageRepository: Codable {
    var id: Int = 0      // <- the row id
    var name: String = ""
    var homeVolume:String = ""
    var homePath: String = ""
    var repositoryVolume: String = ""
    var repositoryPath: String = ""
    var storageVolume:String = ""
    var storagePath: String = ""
    var faceVolume:String = ""
    var facePath: String = ""
    var cropVolume:String = ""
    var cropPath: String = ""
    var deviceId: String = ""
    var useFirstFolderAsEvent: Bool = false
    var folderAsEvent: Bool = false
    var eventFolderLevel: Int = 0
    var folderAsBrief: Bool = false
    var briefFolderLevel: Int = 0
    var owner: String = ""
    
    public init() {
        
    }
}

//extension ImageRepository: FetchableRecord, MutablePersistableRecord, TableRecord {
//
//}


extension ImageRepository : DatabaseRecord {
    public func postgresTable() -> String {
        "ImageRepository"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    public func autofillColumns() -> [String] {
        return ["id"]
    }
    
    
}
