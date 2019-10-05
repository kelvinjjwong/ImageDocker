//
//  ModelStore+ExportProfile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/5.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStore {
    
    // MARK: - CREATE
    
    func getOrCreateExportProfile(id:String,
                                  name:String,
                                  directory: String,
                                  duplicateStrategy: String,
                                  specifyPeople: Bool,
                                  specifyEvent: Bool,
                                  specifyRepository: Bool,
                                  people: String,
                                  events: String,
                                  repositoryPath: String) -> ExportProfile{
        var profile:ExportProfile?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                profile = try ExportProfile.fetchOne(db, key: name)
            }
            if profile == nil {
                try db.write { db in
                    profile = ExportProfile(
                        id: id,
                        name: name,
                        directory: directory,
                        duplicateStrategy: duplicateStrategy,
                        specifyPeople: specifyPeople,
                        specifyEvent: specifyEvent,
                        specifyRepository: specifyRepository,
                        people: people,
                        events: events,
                        repositoryPath: repositoryPath,
                        enabled: true,
                        lastExportTime: nil
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
                             people: String,
                             events: String,
                             repositoryPath: String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                if var profile = try ExportProfile.fetchOne(db, key: id) {
                    profile.name = name
                    profile.directory = directory
                    profile.duplicateStrategy = duplicateStrategy
                    profile.specifyRepository = specifyRepository
                    profile.specifyEvent = specifyEvent
                    profile.specifyPeople = specifyPeople
                    profile.people = people
                    profile.events = events
                    profile.repositoryPath = repositoryPath
                    
                    try profile.save(db)
                }
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func enableExportProfile(id:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                if var profile = try ExportProfile.fetchOne(db, key: id) {
                    profile.enabled = true
                    
                    try profile.save(db)
                }
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func disableExportProfile(id:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                if var profile = try ExportProfile.fetchOne(db, key: id) {
                    profile.enabled = false
                    
                    try profile.save(db)
                }
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func updateExportProfileLastExportTime(id:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                if var profile = try ExportProfile.fetchOne(db, key: id) {
                    profile.lastExportTime = Date()
                    
                    try profile.save(db)
                }
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    // MARK: - GETTER
    
    func getExportProfile(id:String) -> ExportProfile? {
        var profile:ExportProfile?
        do {
            let db = ModelStore.sharedDBPool()
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
            let dbPool = ModelStore.sharedDBPool()
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
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                let _ = try ExportProfile.deleteOne(db, key: id)
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
}
