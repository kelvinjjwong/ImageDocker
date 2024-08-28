//
//  ImageContainer.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import PostgresModelFactory

public final class ImageContainer: Codable {
    //var id: Int64?      // <- the row id
    var path: String = ""
    var name: String = ""
    var parentFolder: String = ""   // FIXME: will deprecate
    var imageCount: Int = 0        // COUNT
    var repositoryPath: String = "" // FIXME: will deprecate at 2nd stage
    var homePath: String = ""      // FIXME: will deprecate
    var storagePath: String = ""   // FIXME: will deprecate
    var facePath: String = ""      // FIXME: will deprecate
    var cropPath: String = ""      // FIXME: will deprecate
    var subPath: String = ""
    var parentPath: String = ""    // FIXME: will deprecate
    var hiddenByRepository: Bool = false
    var hiddenByContainer: Bool = false
    var deviceId: String = ""      // FIXME: will deprecate
    var manyChildren: Bool = false
    var hideByParent: Bool = false
    var useFirstFolderAsEvent: Bool = false // FIXME: will deprecate
    var folderAsEvent: Bool = false  // FIXME: will deprecate
    var eventFolderLevel: Int = 0    // FIXME: will deprecate
    var folderAsBrief: Bool = false  // FIXME: will deprecate
    var briefFolderLevel: Int = 0    // FIXME: will deprecate
    var subContainers: Int = 0       // COUNT
    var deviceWidth: Int = 0        // FIXME: will deprecate
    var deviceHeight: Int = 0       // FIXME: will deprecate
    var repositoryId: Int = 0
    var id: Int = 0
    var parentId: Int = 0
    
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
                briefFolderLevel:Int,
                subContainers:Int,
                repositoryId:Int) {
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
        self.subContainers = subContainers
        self.repositoryId = repositoryId
        
    }
    
    func hasParentContainer() -> Bool {
        return self.parentFolder != ""
    }
}

//extension ImageContainer: FetchableRecord, MutablePersistableRecord, TableRecord {
//
//}


extension ImageContainer : DatabaseRecord {
    public func postgresTable() -> String {
        "ImageContainer"
    }
    
    public func primaryKeys() -> [String] {
        return ["path"]
    }
    
    public func autofillColumns() -> [String] {
        return ["id"]
    }
    
    
}
