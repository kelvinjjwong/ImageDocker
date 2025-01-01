//
//  ExportProfile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/5.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import PostgresModelFactory

public final class ExportProfile : Codable {
    var id: String = ""
    var name: String = ""
    var targetVolume: String = ""
    var directory: String = ""
    var duplicateStrategy: String = ""
    var specifyPeople: Bool = false
    var specifyEvent: Bool = false
    var specifyRepository: Bool = false
    var people: String = ""
    var events: String = ""
    var repositoryPath: String = ""
    var enabled: Bool = false
    var lastExportTime: Date?
    var patchImageDescription:Bool = false
    var patchDateTime:Bool = false
    var patchGeolocation:Bool = false
    var fileNaming:String = ""
    var subFolder:String = ""
    var specifyFamily: Bool = false
    var family: String = ""
    var eventCategories: String? = ""
    var specifyEventCategory: Bool? = false
    var style:String = ""
    
    public init() {
        
    }
    
    public init(id:String,
                name:String,
                targetVolume:String,
                directory:String,
                repositoryPath:String,
                specifyPeople:Bool,
                specifyEvent:Bool,
                specifyRepository:Bool,
                people:String,
                events:String,
                duplicateStrategy:String,
                fileNaming:String,
                subFolder:String,
                patchImageDescription:Bool,
                patchDateTime:Bool,
                patchGeolocation:Bool,
                enabled:Bool,
                lastExportTime:Date?,
                specifyFamily:Bool,
                family:String,
                eventCategories:String,
                specifyEventCategory:Bool) {
        self.id = id
        self.name = name
        self.targetVolume = targetVolume
        self.directory = directory
        self.repositoryPath = repositoryPath
        self.specifyPeople = specifyPeople
        self.specifyEvent = specifyEvent
        self.specifyRepository = specifyRepository
        self.people = people
        self.events = events
        self.duplicateStrategy = duplicateStrategy
        self.fileNaming = fileNaming
        self.subFolder = subFolder
        self.patchImageDescription = patchImageDescription
        self.patchDateTime = patchDateTime
        self.patchGeolocation = patchGeolocation
        self.enabled = enabled
        self.lastExportTime = lastExportTime
        self.specifyFamily = specifyFamily
        self.family = family
        self.eventCategories = eventCategories
        self.specifyEventCategory = specifyEventCategory
    }
}

//extension ExportProfile: FetchableRecord, MutablePersistableRecord, TableRecord {
//    
//}



extension ExportProfile : DatabaseRecord {
    public func postgresTable() -> String {
        return "ExportProfile"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
