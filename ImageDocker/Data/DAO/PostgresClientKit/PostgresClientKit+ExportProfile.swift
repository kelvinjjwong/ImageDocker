//
//  PostgresClientKit+ExportProfile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

class ExportDaoPostgresCK : ExportDaoInterface {
    
    // MARK: - PROFILE CRUD
    
    func getOrCreateExportProfile(id: String, name: String, directory: String, repositoryPath: String, specifyPeople: Bool, specifyEvent: Bool, specifyRepository: Bool, people: String, events: String, duplicateStrategy: String, fileNaming: String, subFolder: String, patchImageDescription: Bool, patchDateTime: Bool, patchGeolocation: Bool, specifyFamily:Bool, family:String) -> ExportProfile {
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
                lastExportTime: nil,
                specifyFamily: specifyFamily,
                family: family
            )
            profile.save(db)
            return profile
        }
    }
    
    func updateExportProfile(id: String,
                             name: String,
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
                             subFolder: String) -> ExecuteState {
        let db = PostgresConnection.database()
        if let profile = ExportProfile.fetchOne(db, parameters: ["id" : id]) {
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
            profile.save(db)
            return .OK
        }else{
            return .NO_RECORD
        }
        
    }
    
    func enableExportProfile(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        if let profile = ExportProfile.fetchOne(db, parameters: ["id" : id]) {
            profile.enabled = true
            profile.save(db)
            return .OK
        }else{
            return .NO_RECORD
        }
    }
    
    func disableExportProfile(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        if let profile = ExportProfile.fetchOne(db, parameters: ["id" : id]) {
            profile.enabled = false
            profile.save(db)
            return .OK
        }else{
            return .NO_RECORD
        }
    }
    
    func updateExportProfileLastExportTime(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        if let profile = ExportProfile.fetchOne(db, parameters: ["id" : id]) {
            profile.lastExportTime = Date()
            profile.save(db)
            return .OK
        }else{
            return .NO_RECORD
        }
    }
    
    func getLastExportTime(profile:ExportProfile) -> Date? {
        // query ExportLog to get max export time
        let sql = """
        select max("lastExportTime") as "lastExportTime" from "ExportLog" where "profileId" = '\(profile.id)'
"""
        final class TempRecord : PostgresCustomRecord {
            var lastExportTime:Date?
            public init() {}
        }
        
        let db = PostgresConnection.database()
        if let record = TempRecord.fetchOne(db, sql: sql) {
            return record.lastExportTime
        }
        
        return nil
    }
    
    func getExportedFilename(imageId:String, profileId:String) -> (String?, String?) {
        final class TempRecord : PostgresCustomRecord {
            var subfolder:String? = nil
            var filename:String? = nil
            public init() {}
        }
        
        let sql = """
select "subfolder", "filename" from "ExportLog" where "imageId" = '\(imageId)' and "profileId" = '\(profileId)'
"""
        let db = PostgresConnection.database()
        if let record = TempRecord.fetchOne(db, sql: sql) {
            return (record.subfolder, record.filename)
        }
        return (nil, nil)
    }
    
    func getExportProfile(id: String) -> ExportProfile? {
        let db = PostgresConnection.database()
        return ExportProfile.fetchOne(db, parameters: ["id" : id])
    }
    
    func getExportProfile(name:String) -> ExportProfile? {
        let db = PostgresConnection.database()
        return ExportProfile.fetchOne(db, parameters: ["name" : name])
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
    
    // MARK: - SEARCH FOR IMAGES
    
    func generateImageQuerySQLPart(tableAlias:String, tableColumn:String, profileSetting:String) -> String {
        var SQL = ""
        if profileSetting.starts(with: "include:") {
            SQL = """
            and \(tableAlias)."\(tableColumn)" in (\(profileSetting.replacingFirstOccurrence(of: "include:", with: "").replacingOccurrences(of: "'", with: "''").replacingOccurrences(of: "\"", with: "'")))
            """
        }else if profileSetting.starts(with: "exclude:"){
            SQL = """
            and \(tableAlias)."\(tableColumn)" not in (\(profileSetting.replacingFirstOccurrence(of: "exclude:", with: "").replacingOccurrences(of: "'", with: "''").replacingOccurrences(of: "\"", with: "'")))
            """
        }
        return SQL
    }
    
    func generateImageQuerySQL(isCount:Bool, profile:ExportProfile, limit:Int?) -> String {
        let repoSQL = self.generateImageQuerySQLPart(tableAlias: "c", tableColumn: "name", profileSetting: profile.repositoryPath)
        let eventSQL = self.generateImageQuerySQLPart(tableAlias: "i", tableColumn: "event", profileSetting: profile.events)
        
        let columns = isCount ? "count(1)" : "i.*"
        
        let _ = """
        select i.*
        from "Image" i
        left join "ImageContainer" c on i."repositoryPath" = c."repositoryPath"
        where i.hidden = 'f' and i."hiddenByContainer" = 'f' and i."hiddenByRepository" = 'f'
        and i."photoTakenYear" > 0
        and c."name" in ('Who''s iphone6', 'Who''s iPhone8')
        and i.event in ('boating','swimming')
        and "recognizedPeopleIds" similar to '%(,someone,|,anotherone,)%'
        """
        let sql = """
        select \(columns)
        from "Image" i
        left join "ImageContainer" c on i."repositoryPath" = c."repositoryPath"
        where i.hidden = 'f' and i."hiddenByContainer" = 'f' and i."hiddenByRepository" = 'f'
        and i."photoTakenYear" > 0
        \(repoSQL)
        \(eventSQL)
        order by i."photoTakenYear" desc, i."photoTakenMonth" desc, i."photoTakenDay" desc
        """
        
        // TODO: after profile.lastExportEndTime
        
        print("sql for export images:")
        print(sql)
        
        return sql
    }
    
    func getImagesForExport(profile:ExportProfile, limit:Int?) -> [Image] {
        let db = PostgresConnection.database()
        
        let sql = self.generateImageQuerySQL(isCount: false, profile: profile, limit: limit)
        let images = Image.fetchAll(db, sql: sql)
        
        return images
    }
    
    func countImagesForExport(profile:ExportProfile) -> Int {
        let db = PostgresConnection.database()
        
        let sql = self.generateImageQuerySQL(isCount: true, profile: profile, limit: nil)
        return db.count(sql: sql)
    }
    
    func getExportedImages(profileId:String) -> [(String, String, String)] {
        
        let sql = """
select "imageId", "subfolder", "filename" from "ExportLog" where "profileId" = '\(profileId)' and "shouldDelete" = 'f' order by "lastExportTime"
"""
        final class TempRecord : PostgresCustomRecord {
            var imageId:String = ""
            var subfolder:String? = nil
            var filename:String? = nil
            public init() {}
        }
        
        var array:[(String, String, String)] = []
        
        let db = PostgresConnection.database()
        let records = TempRecord.fetchAll(db, sql: sql)
        for record in records {
            let imageId = record.imageId
            let subfolder = record.subfolder ?? ""
            let filename = record.filename ?? ""
            array.append((imageId, subfolder, filename))
        }
        return array
        
    }
    
    // MARK: - EXPORT RECORD LOG
    
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
    
    func storeImageExportSuccess(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, exportedMD5: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        let count = db.count(sql: """
        SELECT "ExportLog" where "imageId" = '\(imageId)' and "profileId" = '\(profileId)'
        """)
        if count < 1 {
            do {
                try db.execute(sql: """
                INSERT "ExportLog" ("imageId", "profileId", "lastExportTime", "repositoryPath", "subfolder", "filename", "exportedMD5", "state", "failMessage") VALUES ($1, $2, now(), $3, $4, $5, $6, 'OK', '')
                """, parameterValues: [imageId, profileId, repositoryPath, subfolder, filename, exportedMD5])
            }catch{
                return .ERROR
            }
        }else{
            do {
                try db.execute(sql: """
                UPDATE "ExportLog" set "lastExportTime" = now(), "repositoryPath" = $1, "subfolder" = $2, "filename" = $3, "exportedMD5" = $4, "state" = 'OK', "failMessage" = '' WHERE "imageId"=$5 and "profileId"=$6
                """, parameterValues: [repositoryPath, subfolder, filename, exportedMD5, imageId, profileId])
            }catch{
                return .ERROR
            }
        }
        return .OK
    }
    
    func storeImageExportFail(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, failMessage:String) -> ExecuteState {
        let db = PostgresConnection.database()
        let count = db.count(sql: """
        SELECT "ExportLog" where "imageId" = '\(imageId)' and "profileId" = '\(profileId)'
        """)
        if count < 1 {
            do {
                try db.execute(sql: """
                INSERT "ExportLog" ("imageId", "profileId", "repositoryPath", "subfolder", "filename", "state", "failMessage") VALUES ($1, $2, $3, $4, $5, 'ERROR', $6)
                """, parameterValues: [imageId, profileId, repositoryPath, subfolder, filename, failMessage])
            }catch{
                return .ERROR
            }
        }else{
            do {
                try db.execute(sql: """
                UPDATE "ExportLog" set "repositoryPath" = $1, "subfolder" = $2, "filename" = $3, "state" = 'ERROR', "failMessage" = $4 WHERE "imageId"=$5 and "profileId"=$6
                """, parameterValues: [repositoryPath, subfolder, filename, failMessage, imageId, profileId])
            }catch{
                return .ERROR
            }
        }
        return .OK
    }
    
    func deleteExportLog(imageId:String, profileId:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do{
            try db.execute(sql: """
delete from "ExportLog" where "imageId" = '\(imageId)' and "profileId" = '\(profileId)'
""")
        }catch{
            return .ERROR
        }
        return .OK
    }
}
