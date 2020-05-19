//
//  ImageContainer.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

public final class ImageContainer: Codable {
    //var id: Int64?      // <- the row id
    var path: String = ""
    var name: String = ""
    var parentFolder: String = ""
    var imageCount: Int = 0
    var repositoryPath: String = ""
    var homePath: String = ""
    var storagePath: String = ""
    var facePath: String = ""
    var cropPath: String = ""
    var subPath: String = ""
    var parentPath: String = ""
    var hiddenByRepository: Bool = false
    var hiddenByContainer: Bool = false
    var deviceId: String = ""
    var manyChildren: Bool = false
    var hideByParent: Bool = false
    var useFirstFolderAsEvent: Bool = false
    var folderAsEvent: Bool = false
    var eventFolderLevel: Int = 0
    var folderAsBrief: Bool = false
    var briefFolderLevel: Int = 0
    
    public init() {
        
    }
    
    public init(name:String,
                parentFolder:String,
                path:String,
                imageCount:Int,
                repositoryPath:String,
                homePath:String,
                storagePath:String,
                facePath:String,
                cropPath:String,
                subPath:String,
                parentPath:String,
                hiddenByRepository:Bool,
                hiddenByContainer:Bool,
                deviceId:String,
                manyChildren:Bool,
                hideByParent:Bool,
                folderAsEvent:Bool,
                eventFolderLevel:Int,
                folderAsBrief:Bool,
                briefFolderLevel:Int) {
        self.name = name
        self.parentFolder = parentFolder
        self.path = path
        self.imageCount = imageCount
        self.repositoryPath = repositoryPath
        self.homePath = homePath
        self.storagePath = storagePath
        self.facePath = facePath
        self.cropPath = cropPath
        self.subPath = subPath
        self.parentPath = parentPath
        self.hiddenByRepository = hiddenByRepository
        self.hiddenByContainer = hiddenByContainer
        self.deviceId = deviceId
        self.manyChildren = manyChildren
        self.hideByParent = hideByParent
        self.folderAsEvent = folderAsEvent
        self.eventFolderLevel = eventFolderLevel
        self.folderAsBrief = folderAsBrief
        self.briefFolderLevel = briefFolderLevel
        
    }
}

extension ImageContainer: FetchableRecord, MutablePersistableRecord, TableRecord {

}


extension ImageContainer : PostgresRecord {
    public func postgresTable() -> String {
        "ImageContainer"
    }
    
    public func primaryKeys() -> [String] {
        return ["path"]
    }
    
    
}
