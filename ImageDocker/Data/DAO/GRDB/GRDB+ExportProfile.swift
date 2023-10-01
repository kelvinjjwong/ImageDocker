//
//  ModelStore+ExportProfile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/5.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB
import LoggerFactory

class ExportDaoGRDB : ExportDaoInterface {
    
    let logger = LoggerFactory.get(category: "ExportDaoGRDB")
    
    // MARK: - PROFILE CRUD
    
    func getOrCreateExportProfile(id:String,
                                  name:String,
                                  targetVolume: String,
                                  directory: String,
                                  repositoryPath: String,
                                  specifyRepository: Bool,
                                  duplicateStrategy: String,
                                  fileNaming: String,
                                  subFolder: String,
                                  patchImageDescription:Bool,
                                  patchDateTime:Bool,
                                  patchGeolocation:Bool,
                                  specifyFamily:Bool,
                                  family:String,
                                  eventCategories:String,
                                  specifyEventCategory:Bool
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
                        targetVolume: targetVolume,
                        directory: directory,
                        repositoryPath: repositoryPath,
                        specifyPeople: false,
                        specifyEvent: false,
                        specifyRepository: specifyRepository,
                        people: "",
                        events: "",
                        duplicateStrategy: duplicateStrategy,
                        fileNaming: fileNaming,
                        subFolder: subFolder,
                        patchImageDescription: patchImageDescription,
                        patchDateTime: patchDateTime,
                        patchGeolocation: patchGeolocation,
                        enabled: true,
                        lastExportTime: nil,
                        specifyFamily: specifyFamily,
                        family: family,
                        eventCategories: eventCategories,
                        specifyEventCategory: specifyEventCategory
                    )
                    try profile?.save(db)
                }
            }
        }catch{
            self.logger.log(error)
        }
        return profile!
    }
    
    func updateExportProfile(id:String,
                             name:String,
                             targetVolume: String,
                             directory: String,
                             duplicateStrategy: String,
                             specifyRepository: Bool,
                             specifyFamily: Bool,
                             repositoryPath: String,
                             family: String,
                             patchImageDescription:Bool,
                             patchDateTime:Bool,
                             patchGeolocation:Bool,
                             fileNaming: String,
                             subFolder: String,
                             eventCategories:String,
                             specifyEventCategory:Bool) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                if var profile = try ExportProfile.fetchOne(db, key: id) {
                    profile.name = name
                    profile.targetVolume = targetVolume
                    profile.directory = directory
                    profile.duplicateStrategy = duplicateStrategy
                    profile.specifyRepository = specifyRepository
                    profile.specifyEvent = false
                    profile.specifyPeople = false
                    profile.specifyFamily = specifyFamily
                    profile.people = ""
                    profile.events = ""
                    profile.repositoryPath = repositoryPath
                    profile.family = family
                    profile.patchImageDescription = patchImageDescription
                    profile.patchDateTime = patchDateTime
                    profile.patchGeolocation = patchGeolocation
                    profile.fileNaming = fileNaming
                    profile.subFolder = subFolder
                    profile.eventCategories = eventCategories
                    profile.specifyEventCategory = specifyEventCategory
                    
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
    
    func getLastExportTime(profile:ExportProfile) -> Date? {
        // query ExportLog to get max export time
        let sql = "select max(lastExportTime) as lastExportTime from ExportLog where profileId = '\(profile.id)'"
        var date:Date? = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        let str = "\(row[0] ?? "")"
                        date = dateFormatter.date(from: str)
                    }
                }
            }
        }catch{
            self.logger.log(error)
        }
        return date
    }
    
    func getExportedFilename(imageId:String, profileId:String) -> (String?, String?) {
        let sql = """
        select subfolder, filename from ExportLog where imageId = '\(imageId)' and profileId = '\(profileId)'
        """
        var subfolder:String? = nil
        var filename:String? = nil
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    let row = rows[0]
                    subfolder = row[0]
                    filename = row[1]
                }
            }
        }catch{
            self.logger.log(error)
        }
        return (subfolder, filename)
    }
    
    func getExportProfile(id:String) -> ExportProfile? {
        var profile:ExportProfile?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                profile = try ExportProfile.fetchOne(db, key: id)
            }
        }catch{
            self.logger.log(error)
        }
        return profile
    }
    
    func getExportProfile(name:String) -> ExportProfile? {
        var profile:ExportProfile?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                profile = try ExportProfile.fetchOne(db, key: ["name" : name])
            }
        }catch{
            self.logger.log(error)
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
            self.logger.log(error)
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
    
    func generateImageQuerySQLPart(tableAlias:String, tableColumn:String, profileSetting:String) -> String {
        var SQL = ""
        if profileSetting.starts(with: "include:") {
            SQL = """
            and \(tableAlias).\(tableColumn) in (\(profileSetting.replacingFirstOccurrence(of: "include:", with: "").replacingOccurrences(of: "'", with: "''").replacingOccurrences(of: "\"", with: "'")))
            """
        }else if profileSetting.starts(with: "exclude:"){
            SQL = """
            and \(tableAlias).\(tableColumn) not in (\(profileSetting.replacingFirstOccurrence(of: "exclude:", with: "").replacingOccurrences(of: "'", with: "''").replacingOccurrences(of: "\"", with: "'")))
            """
        }
        return SQL
    }
    
    func generateImageQuerySQL(isCount:Bool, profile:ExportProfile, pageSize:Int?, pageNumber:Int?) -> String {
        let repoSQL = self.generateImageQuerySQLPart(tableAlias: "c", tableColumn: "name", profileSetting: profile.repositoryPath)
        let eventSQL = self.generateImageQuerySQLPart(tableAlias: "i", tableColumn: "event", profileSetting: profile.events)
        
        var pagination = ""
        if !isCount {
            if let limit = pageSize, let pageNumber = pageNumber {
                let offset = (pageNumber - 1) * limit
                pagination = "LIMIT \(limit) OFFSET \(offset)"
            }
        }
        
        let columns = isCount ? "count(1) as recordCount" : "i.*"
        
        let orderSQL = isCount ? "" : "order by i.photoTakenYear desc, i.photoTakenMonth desc, i.photoTakenDay desc"
        
        let _ = """
        select i.*
        from Image i
        left join ImageContainer c on i.repositoryPath = c.repositoryPath
        where i.hidden = 0 and i.hiddenByContainer = 0 and i.hiddenByRepository = 0
        and i.photoTakenYear > 0
        and c.name in ('Who''s iphone6', 'Who''s iPhone8')
        and i.event in ('boating','swimming')
        and recognizedPeopleIds similar to '%(,someone,|,anotherone,)%'
        """
        let sql = """
        select \(columns)
        from Image i
        left join ImageContainer c on i.repositoryPath = c.repositoryPath
        where i.hidden = 0 and i.hiddenByContainer = 0 and i.hiddenByRepository = 0
        and i.photoTakenYear > 0
        \(repoSQL)
        \(eventSQL)
        \(orderSQL)
        \(pagination)
        """
        
        // TODO: after profile.lastExportEndTime
        
//        self.logger.log("sql for export images:")
//        self.logger.log(sql)
        
        return sql
    }
    
    func getImagesForExport(profile:ExportProfile, pageSize:Int?, pageNumber:Int?) -> [Image] {
        let sql = self.generateImageQuerySQL(isCount: false, profile: profile, pageSize: pageSize, pageNumber: pageNumber)
        var result:[Image] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.fetchAll(db, sql: sql)
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func countImagesForExport(profile:ExportProfile) -> Int {
        var result = 0
        let sql = self.generateImageQuerySQL(isCount: true, profile: profile, pageSize: nil, pageNumber: nil)
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    result = rows[0]["recordCount"] as Int? ?? 0
                }
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func getExportedImages(profileId:String) -> [(String, String, String)] {
        // TODO add function for GRDB
        let sql = """
        select imageId, subfolder, filename from ExportLog where profileId = '\(profileId)' order by lastExportTime
        """
        var result:[(String, String, String)] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        let imageId = "\(row[0] ?? "")"
                        let subfolder = "\(row[1] ?? "")"
                        let filename = "\(row[2] ?? "")"
                        result.append((imageId, subfolder, filename))
                    }
                }
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func getSQLForImageExport(profile:ExportProfile) -> String {
        return self.generateImageQuerySQL(isCount: false, profile: profile, pageSize: nil, pageNumber: nil)
    }
    
    
    // MARK: - EXPORT RECORD LOG
    
    func countExportedImages(profile:ExportProfile) -> Int {
        var result = 0
        let sql = """
        select count(1) as recordCount from ExportLog where profileId='\(profile.id)'
"""
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    result = rows[0]["recordCount"] as Int? ?? 0
                }
            }
        }catch{
            self.logger.log(error)
        }
        return result
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
    
    func storeImageExportSuccess(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, exportedMD5: String) -> ExecuteState{
        var recordExists = false
        let sql = """
        select count(1) from ExportLog where imageId='\(imageId)' and profileId='\(profileId)'
        """
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        let imageCount = Int("\(row[0] ?? 0)") ?? 0
                        if imageCount > 0 {
                            recordExists = true
                        }
                    }
                }
            }
        }catch{
            self.logger.log(error)
        }
        
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            
            try db.write { db in
                
                if !recordExists {
                    try db.execute(sql: "INSERT ExportLog (imageId,profileid,lastExportTime,repositoryPath,subfolder,filename,exportedMD5,state,failMessage) VALUES (?, ?, CURRENT_TIMESTAMP, ?, ? , ?, ?, 'OK', '')", arguments: StatementArguments([imageId, profileId, repositoryPath, subfolder, filename, exportedMD5]) ?? [])
                }else{

                    try db.execute(sql: "UPDATE ExportLog set lastExportTime = CURRENT_TIMESTAMP, repositoryPath = ?, subfolder = ?, filename = ?, exportedMD5 = ?, state = 'OK', failMessage = '' WHERE imageId=? and profileId=?", arguments: StatementArguments([repositoryPath, subfolder, filename, exportedMD5, imageId, profileId]) ?? [])
                }
                
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func storeImageExportFail(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, failMessage:String) -> ExecuteState{
        var recordExists = false
        let sql = """
        select count(1) from ExportLog where imageId='\(imageId)' and profileId='\(profileId)'
        """
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        let imageCount = Int("\(row[0] ?? 0)") ?? 0
                        if imageCount > 0 {
                            recordExists = true
                        }
                    }
                }
            }
        }catch{
            self.logger.log(error)
        }
        
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                if !recordExists {
                    try db.execute(sql: "INSERT ExportLog (imageId,profileid,repositoryPath,subfolder,filename,state,failMessage) VALUES (?, ?, ?, ? , ?, ?, 'ERROR', ?)", arguments: StatementArguments([imageId, profileId, repositoryPath, subfolder, filename, failMessage]) ?? [])
                }else{
                    try db.execute(sql: "UPDATE ExportLog set repositoryPath = ?, subfolder = ?, filename = ?, state = 'ERROR', failMessage = ? WHERE imageId=? and profileId=?", arguments: StatementArguments([repositoryPath, subfolder, filename, failMessage, imageId, profileId]) ?? [])
                }
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func deleteExportLog(imageId:String, profileId:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "DELETE FROM ExportLog WHERE imageId='\(imageId)' and profileId='\(profileId)'")
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
}
