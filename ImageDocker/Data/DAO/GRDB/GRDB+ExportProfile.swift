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
    
    // MARK: - PROFILE CRUD
    
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
    
    // MARK: - SEARCH FOR IMAGES
    
    func getAllExportedImages(includeHidden:Bool = true) -> [Image] {
        var result:[Image] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                if includeHidden {
                    result = try Image.filter(sql: "exportToPath is not null and exportAsFilename is not null and exportToPath <> '' and exportAsFilename <> ''").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
                }else{
                    result = try Image.filter(sql: "hidden = 0 and exportToPath is not null and exportAsFilename is not null and exportToPath <> '' and exportAsFilename <> ''").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllExportedPhotoFilenames(includeHidden:Bool = true) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                if includeHidden {
                    let cursor = try Image.filter(sql: "exportToPath is not null and exportAsFilename is not null and exportToPath <> '' and exportAsFilename <> ''").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchCursor(db)
                    while let photo = try cursor.next() {
                        let path = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
                        result.insert(path)
                    }
                }else{
                    let cursor = try Image.filter(sql: "hidden = 0 and exportToPath is not null and exportAsFilename is not null and exportToPath <> '' and exportAsFilename <> ''").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchCursor(db)
                    while let photo = try cursor.next() {
                        let path = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
                        result.insert(path)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllPhotoFilesForExporting(after date:Date, limit:Int? = nil) -> [Image] {
        var result:[Image] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                var query = Image.filter(sql: "hidden != 1 AND photoTakenYear <> 0 AND photoTakenYear IS NOT NULL AND (updateDateTimeDate > ? OR updateExifDate > ? OR updateLocationDate > ? OR updateEventDate > ? OR exportTime is null)", arguments:StatementArguments([date, date, date, date]))
                    .order([Column("photoTakenDate").asc, Column("filename").asc])
                if let lim = limit {
                    query = query.limit(lim)
                }
                result = try query.fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getAllPhotoFilesMarkedExported() -> [Image] {
        var result:[Image] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter("hidden != 1 AND exportTime is not null)").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func countAllPhotoFilesForExporting(after date:Date) -> Int {
        var result = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "hidden != 1 AND photoTakenYear <> 0 AND photoTakenYear IS NOT NULL AND (updateDateTimeDate > ? OR updateExifDate > ? OR updateLocationDate > ? OR updateEventDate > ? OR exportTime is null)", arguments:StatementArguments([date, date, date, date])).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    
    // MARK: - EXPORT RECORD LOG
    
    func cleanImageExportTime(path:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "UPDATE Image set exportTime = null WHERE path='\(path)'")
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func storeImageOriginalMD5(path:String, md5:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "UPDATE Image set originalMD5 = ? WHERE path=?", arguments: StatementArguments([md5, path]))
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func storeImageExportedMD5(path:String, md5:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "UPDATE Image set exportedMD5 = ? WHERE path=?", arguments: StatementArguments([md5, path]))
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func storeImageExportSuccess(path:String, date:Date, exportToPath:String, exportedFilename:String, exportedMD5:String, exportedLongDescription:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "UPDATE Image set exportTime = ?, exportToPath = ?, exportAsFilename = ?, exportedMD5 = ?, exportedLongDescription = ?, exportState = 'OK', exportFailMessage = '' WHERE path=?", arguments: StatementArguments([date, exportToPath, exportedFilename, exportedMD5, exportedLongDescription, path]) ?? [])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func storeImageExportedTime(path:String, date:Date) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "UPDATE Image set exportTime = ? WHERE path=?", arguments: StatementArguments([date, path]) ?? [])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func storeImageExportFail(path:String, date:Date, message:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "UPDATE Image set exportTime = ?, exportState = 'FAIL', exportFailMessage = ? WHERE path=?", arguments: StatementArguments([date, message, path]) ?? [])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func cleanImageExportPath(path:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "UPDATE Image set exportToPath = null, exportAsFilename = null, exportTime = null, exportState = null, exportFailMessage = '', exportedMD5 = null, WHERE path=?", arguments: StatementArguments([path]))
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
        
    }
}
