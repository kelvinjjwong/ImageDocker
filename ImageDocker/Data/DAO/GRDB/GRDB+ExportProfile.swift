//
//  ModelStore+ExportProfile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/5.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class ExportDaoGRDB : ExportDaoInterface {
    
    // MARK: - CREATE
    
    func getOrCreateExportProfile(id:String,
                                  name:String,
                                  directory: String,
                                  repositoryPath: String,
                                  specifyPeople: Bool,
                                  specifyEvent: Bool,
                                  specifyRepository: Bool,
                                  people: String,
                                  events: String,
                                  duplicateStrategy: String,
                                  fileNaming: String,
                                  subFolder: String,
                                  patchImageDescription:Bool,
                                  patchDateTime:Bool,
                                  patchGeolocation:Bool,
                                  specifyFamily:Bool,
                                  family:String
                                  ) -> ExportProfile{
        var profile:ExportProfile?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                profile = try ExportProfile.fetchOne(db, key: name)
            }
            if profile == nil {
                try db.write { db in
                    profile = ExportProfile(
                        id: id,
                        name: name,
                        directory: directory,
                        repositoryPath: repositoryPath,
                        specifyPeople: specifyPeople,
                        specifyEvent: specifyEvent,
                        specifyRepository: specifyRepository,
                        people: people,
                        events: events,
                        duplicateStrategy: duplicateStrategy,
                        fileNaming: fileNaming,
                        subFolder: subFolder,
                        patchImageDescription: patchImageDescription,
                        patchDateTime: patchDateTime,
                        patchGeolocation: patchGeolocation,
                        enabled: true,
                        lastExportTime: nil,
                        specifyFamily: specifyFamily,
                        family: family
                    )
                    try profile?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return profile!
    }
    
    func updateExportProfile(id:String,
                             name:String,
                             directory: String,
                             duplicateStrategy: String,
                             specifyPeople: Bool,
                             specifyEvent: Bool,
                             specifyRepository: Bool,
                             specifyFamily: Bool,
                             people: String,
                             events: String,
                             repositoryPath: String,
                             family: String,
                             patchImageDescription:Bool,
                             patchDateTime:Bool,
                             patchGeolocation:Bool,
                             fileNaming: String,
                             subFolder: String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                if var profile = try ExportProfile.fetchOne(db, key: id) {
                    profile.name = name
                    profile.directory = directory
                    profile.duplicateStrategy = duplicateStrategy
                    profile.specifyRepository = specifyRepository
                    profile.specifyEvent = specifyEvent
                    profile.specifyPeople = specifyPeople
                    profile.specifyFamily = specifyFamily
                    profile.people = people
                    profile.events = events
                    profile.repositoryPath = repositoryPath
                    profile.family = family
                    profile.patchImageDescription = patchImageDescription
                    profile.patchDateTime = patchDateTime
                    profile.patchGeolocation = patchGeolocation
                    profile.fileNaming = fileNaming
                    profile.subFolder = subFolder
                    
                    try profile.save(db)
                }
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func enableExportProfile(id:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                if var profile = try ExportProfile.fetchOne(db, key: id) {
                    profile.enabled = true
                    
                    try profile.save(db)
                }
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func disableExportProfile(id:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                if var profile = try ExportProfile.fetchOne(db, key: id) {
                    profile.enabled = false
                    
                    try profile.save(db)
                }
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateExportProfileLastExportTime(id:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                if var profile = try ExportProfile.fetchOne(db, key: id) {
                    profile.lastExportTime = Date()
                    
                    try profile.save(db)
                }
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    // MARK: - GETTER
    
    func getExportProfile(id:String) -> ExportProfile? {
        var profile:ExportProfile?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                profile = try ExportProfile.fetchOne(db, key: id)
            }
        }catch{
            print(error)
        }
        return profile
    }
    
    // MARK: - SEARCH
    
    func getAllExportProfiles() -> [ExportProfile] {
        var profiles:[ExportProfile] = []
        
        do {
            let dbPool = try SQLiteConnectionGRDB.default.sharedDBPool()
            try dbPool.read { db in
                profiles = try ExportProfile.fetchAll(db)
            }
        }catch{
            print(error)
        }
        return profiles
    }
    
    // MARK: - DELETE
    
    func deleteExportProfile(id:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                let _ = try ExportProfile.deleteOne(db, key: id)
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
}
