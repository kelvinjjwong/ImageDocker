//
//  PostgresClientKit+ExportProfile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

class ImageExportDaoPostgresCK : ImageExportDaoInterface {
    
    func cleanImageExportTime(path: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            UPDATE "Image" set "exportTime" = null WHERE path='\(path)'
            """)
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    func storeImageOriginalMD5(path: String, md5: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "originalMD5" = $1 WHERE path=$2
            """, parameterValues: [md5, path])
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    func storeImageExportedMD5(path: String, md5: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "exportedMD5" = $1 WHERE path=$2
            """, parameterValues: [md5, path])
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    func storeImageExportSuccess(path: String, date: Date, exportToPath: String, exportedFilename: String, exportedMD5: String, exportedLongDescription: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "exportTime" = $1, "exportToPath" = $2, "exportAsFilename" = $3, "exportedMD5" = $4, "exportedLongDescription" = $5, "exportState" = 'OK', "exportFailMessage" = '' WHERE path=$6
            """, parameterValues: [date, exportToPath, exportedFilename, exportedMD5, exportedLongDescription, path])
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    func storeImageExportedTime(path: String, date: Date) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "exportTime" = $1 WHERE path=$2
            """, parameterValues: [date, path])
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    func storeImageExportFail(path: String, date: Date, message: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "exportTime" = $1, "exportState" = 'FAIL', "exportFailMessage" = $2 WHERE path=$3
            """, parameterValues: [date, message, path])
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    func cleanImageExportPath(path: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "exportToPath" = null, "exportAsFilename" = null, "exportTime" = null, "exportState" = null, "exportFailMessage" = '', "exportedMD5" = null, WHERE path=$1
            """, parameterValues: [path])
        }catch{
            return .ERROR
        }
        return .OK
    }
    

}

class ExportDaoPostgresCK : ExportDaoInterface {
    
    func getOrCreateExportProfile(id: String, name: String, directory: String, repositoryPath: String, specifyPeople: Bool, specifyEvent: Bool, specifyRepository: Bool, people: String, events: String, duplicateStrategy: String, fileNaming: String, subFolder: String, patchImageDescription: Bool, patchDateTime: Bool, patchGeolocation: Bool) -> ExportProfile {
        let db = PostgresConnection.database()
        if let profile = ExportProfile.fetchOne(db, parameters: ["id" : id]) {
            return profile
        }else{
            let profile = ExportProfile(
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
                lastExportTime: nil
            )
            profile.save(db)
            return profile
        }
    }
    
    func updateExportProfile(id: String, name: String, directory: String, duplicateStrategy: String, specifyPeople: Bool, specifyEvent: Bool, specifyRepository: Bool, people: String, events: String, repositoryPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        if var profile = ExportProfile.fetchOne(db, parameters: ["id" : id]) {
            profile.name = name
            profile.directory = directory
            profile.duplicateStrategy = duplicateStrategy
            profile.specifyRepository = specifyRepository
            profile.specifyEvent = specifyEvent
            profile.specifyPeople = specifyPeople
            profile.people = people
            profile.events = events
            profile.repositoryPath = repositoryPath
            profile.save(db)
            return .OK
        }else{
            return .NO_RECORD
        }
        
    }
    
    func enableExportProfile(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        if var profile = ExportProfile.fetchOne(db, parameters: ["id" : id]) {
            profile.enabled = true
            profile.save(db)
            return .OK
        }else{
            return .NO_RECORD
        }
    }
    
    func disableExportProfile(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        if var profile = ExportProfile.fetchOne(db, parameters: ["id" : id]) {
            profile.enabled = false
            profile.save(db)
            return .OK
        }else{
            return .NO_RECORD
        }
    }
    
    func updateExportProfileLastExportTime(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        if var profile = ExportProfile.fetchOne(db, parameters: ["id" : id]) {
            profile.lastExportTime = Date()
            profile.save(db)
            return .OK
        }else{
            return .NO_RECORD
        }
    }
    
    func getExportProfile(id: String) -> ExportProfile? {
        let db = PostgresConnection.database()
        return ExportProfile.fetchOne(db, parameters: ["id" : id])
    }
    
    func getAllExportProfiles() -> [ExportProfile] {
        let db = PostgresConnection.database()
        return ExportProfile.fetchAll(db)
    }
    
    func deleteExportProfile(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        let profile = ExportProfile()
        profile.id = id
        profile.delete(db)
        return .OK
    }
    

}
