//
//  ExportProfile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/5.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

public final class ExportProfile : Codable {
    var id: String = ""
    var name: String = ""
    var directory: String = ""
    var repositoryPath: String = ""
    var specifyPeople: Bool = false
    var specifyEvent: Bool = false
    var specifyRepository: Bool = false
    var people: String = ""
    var events: String = ""
    var duplicateStrategy: String = ""
    var fileNaming:String = ""
    var subFolder:String = ""
    var patchImageDescription:Bool = false
    var patchDateTime:Bool = false
    var patchGeolocation:Bool = false
    var enabled: Bool = false
    var lastExportTime: Date?
    
    public init() {
        
    }
    
    public init(id:String,
                name:String,
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
                lastExportTime:Date?) {
        self.id = id
        self.name = name
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
    }
}

extension ExportProfile: FetchableRecord, MutablePersistableRecord, TableRecord {
    
}



extension ExportProfile : PostgresRecord {
    public func postgresTable() -> String {
        return "ExportProfile"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    
}
