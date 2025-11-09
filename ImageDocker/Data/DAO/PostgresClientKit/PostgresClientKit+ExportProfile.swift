//
//  PostgresClientKit+ExportProfile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory

class ExportDaoPostgresCK : ExportDaoInterface {
    
    let logger = LoggerFactory.get(category: "ExportDaoPostgresCK")
    
    // MARK: - PROFILE CRUD
    
    func getOrCreateExportProfile(id: String,
                                  name: String,
                                  targetVolume: String,
                                  directory: String,
                                  repositoryPath: String,
                                  specifyRepository: Bool,
                                  duplicateStrategy: String,
                                  fileNaming: String,
                                  subFolder: String,
                                  patchImageDescription: Bool,
                                  patchDateTime: Bool,
                                  patchGeolocation: Bool,
                                  specifyFamily:Bool,
                                  family:String,
                                  eventCategories:String,
                                  specifyEventCategory:Bool
    ) -> ExportProfile {
        let db = PostgresConnection.database()
        
        let dummy = ExportProfile(
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
            specifyEventCategory: specifyEventCategory,
            repositoryId: 0
        )
        do {
            if let profile = try ExportProfile.fetchOne(db, parameters: ["id" : id]) {
                return profile
            }else{
                try dummy.save(db)
                return dummy
            }
        }catch{
            self.logger.log(.error, error)
            return dummy
        }
    }
    
    func updateExportProfile(id: String,
                             name: String,
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
                             specifyEventCategory:Bool, style:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            if let profile = try ExportProfile.fetchOne(db, parameters: ["id" : id]) {
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
                profile.style = style
                try profile.save(db)
                return .OK
            }else{
                return .NO_RECORD
            }
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        
    }
    
    func enableExportProfile(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            if let profile = try ExportProfile.fetchOne(db, parameters: ["id" : id]) {
                profile.enabled = true
                try profile.save(db)
                return .OK
            }else{
                return .NO_RECORD
            }
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func disableExportProfile(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            if let profile = try ExportProfile.fetchOne(db, parameters: ["id" : id]) {
                profile.enabled = false
                try profile.save(db)
                return .OK
            }else{
                return .NO_RECORD
            }
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func updateExportProfileLastExportTime(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            if let profile = try ExportProfile.fetchOne(db, parameters: ["id" : id]) {
                profile.lastExportTime = Date()
                try profile.save(db)
                return .OK
            }else{
                return .NO_RECORD
            }
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func getLastExportTime(profile:ExportProfile) -> Date? {
        // query ExportLog to get max export time
        let sql = """
        select max("lastExportTime") as "lastExportTime" from "ExportLog" where "profileId" = '\(profile.id)'
"""
        final class TempRecord : DatabaseRecord {
            var lastExportTime:Date?
            public init() {}
        }
        
        let db = PostgresConnection.database()
        do {
            if let record = try TempRecord.fetchOne(db, sql: sql) {
                return record.lastExportTime
            }
        }catch{
            self.logger.log(.error, error)
            return nil
        }
        
        return nil
    }
    
    func getExportedFilename(imageId:String, profileId:String) -> (String?, String?) {
        final class TempRecord : DatabaseRecord {
            var subfolder:String? = nil
            var filename:String? = nil
            public init() {}
        }
        
        let sql = """
select "subfolder", "filename" from "ExportLog" where "imageId" = '\(imageId)' and "profileId" = '\(profileId)'
"""
        let db = PostgresConnection.database()
        do {
            if let record = try TempRecord.fetchOne(db, sql: sql) {
                return (record.subfolder, record.filename)
            }
        }catch{
            self.logger.log(.error, error)
            return (nil, nil)
        }
        return (nil, nil)
    }
    
    func getExportProfile(id: String) -> ExportProfile? {
        let db = PostgresConnection.database()
        do {
            return try ExportProfile.fetchOne(db, parameters: ["id" : id])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getExportProfile(name:String) -> ExportProfile? {
        let db = PostgresConnection.database()
        do {
            return try ExportProfile.fetchOne(db, parameters: ["name" : name])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getAllExportProfiles() -> [ExportProfile] {
        let db = PostgresConnection.database()
        do {
            return try ExportProfile.fetchAll(db)
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func deleteExportProfile(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        let profile = ExportProfile()
        profile.id = id
        do {
            try profile.delete(db)
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    // MARK: - SEARCH FOR IMAGES
    
    func generateImageQuerySQLPart(tableAlias:String, tableColumn:String, profileSetting:String) -> String {
        var SQL = ""
        if profileSetting.starts(with: "include:") {
            
            var nullSQL = ""
            let options = profileSetting.replacingFirstOccurrence(of: "include:", with: "").split(separator: ",")
            if options.contains("\"\"") {
                nullSQL = """
            \(tableAlias)."\(tableColumn)" is null or
            """
            }
            
            SQL = """
            and (\(nullSQL) \(tableAlias)."\(tableColumn)" in (\(profileSetting.replacingFirstOccurrence(of: "include:", with: "").replacingOccurrences(of: "'", with: "''").replacingOccurrences(of: "\"", with: "'"))) )
            """
        }else if profileSetting.starts(with: "exclude:"){
            
            var nullSQL = ""
            let options = profileSetting.replacingFirstOccurrence(of: "exclude:", with: "").split(separator: ",")
            if options.contains("\"\"") {
                nullSQL = """
            \(tableAlias)."\(tableColumn)" is not null and
            """
            }
            
            SQL = """
            and ( \(nullSQL) \(tableAlias)."\(tableColumn)" not in (\(profileSetting.replacingFirstOccurrence(of: "exclude:", with: "").replacingOccurrences(of: "'", with: "''").replacingOccurrences(of: "\"", with: "'"))) )
            """
        }
        return SQL
    }
    
    func generateImageQuerySQL(isCount:Bool, profile:ExportProfile, pageSize:Int?, pageNumber:Int?, years:[String] = []) -> String {
        
        let repoFilterSQL = self.generateImageQuerySQLPart(tableAlias: "r", tableColumn: "owner", profileSetting: profile.repositoryPath)
        let eventFilterSQL = self.generateImageQuerySQLPart(tableAlias: "i", tableColumn: "event", profileSetting: profile.events)
        
        var yearCondition = """
                    i."photoTakenYear" > 0
            """
        if years.count > 0 {
            yearCondition = """
            i."photoTakenYear" in (\(years.joined(separator: ",")))
            """
        }
        
        let eventCategories = profile.eventCategories ?? ""
        var eventCategoryFilterSQL = ""
        var eventCategoryJoinSQL = ""
        if eventCategories != "" {
            eventCategoryJoinSQL = """
            left join "ImageEvent" e on i."event" = e."name"
            """
            eventCategoryFilterSQL = self.generateImageQuerySQLPart(tableAlias: "e", tableColumn: "category", profileSetting: eventCategories)
        }
        
        var pagination = ""
        if !isCount {
            if let limit = pageSize, let pageNumber = pageNumber {
                let offset = (pageNumber - 1) * limit
                pagination = "LIMIT \(limit) OFFSET \(offset)"
            }
        }
        
        let columns = isCount ? "count(1)" : "i.*"
        var orderSQL = ""
        if !isCount {
            orderSQL = """
            order by i."photoTakenYear" desc, i."photoTakenMonth" desc, i."photoTakenDay" desc
            """
        }
        
        let _ = """
        select i.*
        from "Image" i
        left join "ImageRepository" r on i."repositoryId" = r."id"
        left join "ImageEvent" e on i."event" = e."name"
        where i.hidden = 'f' and i."hiddenByContainer" = 'f' and i."hiddenByRepository" = 'f'
        and i."photoTakenYear" > 0
        and r."owner" in ('kelvin_wong')
        and e.category in ('trip','party')
        """
        
        // TODO: add family filter to export SQL
        let sql = """
        select \(columns)
        from "Image" i
        left join "ImageRepository" r on i."repositoryId" = r."id"
        \(eventCategoryJoinSQL)
        where i.hidden = 'f' and i."hiddenByContainer" = 'f' and i."hiddenByRepository" = 'f'
        and \(yearCondition)
        \(repoFilterSQL)
        \(eventCategoryFilterSQL)
        \(orderSQL)
        \(pagination)
        """
        
        self.logger.log(.trace, "sql for export images:")
        self.logger.log(sql)
        
        return sql
    }
    
    func getExportedImagesButNowHidden(profileId:String) -> [(String, String, String)]  {
        final class TempRecord : DatabaseRecord {
            var imageId:String? = nil
            var subfolder:String? = nil
            var filename:String? = nil
            public init() {}
        }
        
        let sql = """
        select e."imageId", e."subfolder", e."filename" from "ExportLog" e
        LEFT JOIN "Image" i on e."imageId" = i."id"
         where e."profileId"='\(profileId)'
        and i.hidden='t' and i."hiddenByContainer"='t' and i."hiddenByRepository"='t'
        order by "subfolder","imageId"
        """
        
        let db = PostgresConnection.database()
        do {
            var rtn:[(String, String, String)] = []
            let records = try TempRecord.fetchAll(db, sql: sql)
            for record in records {
                rtn.append((record.imageId ?? "", record.subfolder ?? "", record.filename ?? ""))
            }
            return rtn
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getSQLForImageExport(profile:ExportProfile, years:[String]) -> String {
        return self.generateImageQuerySQL(isCount: false, profile: profile, pageSize: nil, pageNumber: nil, years: years)
    }
    
    func getImagesForExport(profile:ExportProfile, pageSize:Int?, pageNumber:Int?, years:[String]) -> [Image] {
        let db = PostgresConnection.database()
        
        let sql = self.generateImageQuerySQL(isCount: false, profile: profile, pageSize: pageSize, pageNumber: pageNumber, years: years)
        do {
            return try Image.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func countImagesForExport(profile:ExportProfile, years:[String]) -> Int {
        let db = PostgresConnection.database()
        
        let sql = self.generateImageQuerySQL(isCount: true, profile: profile, pageSize: nil, pageNumber: nil, years: years)
        do {
            return try db.count(sql: sql)
        }catch{
            self.logger.log(.error, error)
            return 0
        }
    }
    
    func getExportedImages(profileId:String) -> [(String, String, String)] {
        
        let sql = """
select "imageId", "subfolder", "filename" from "ExportLog" where "profileId" = '\(profileId)' and "shouldDelete" = 'f' order by "lastExportTime"
"""
        final class TempRecord : DatabaseRecord {
            var imageId:String = ""
            var subfolder:String? = nil
            var filename:String? = nil
            public init() {}
        }
        
        var array:[(String, String, String)] = []
        
        let db = PostgresConnection.database()
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
        }
        for record in records {
            let imageId = record.imageId
            let subfolder = record.subfolder ?? ""
            let filename = record.filename ?? ""
            array.append((imageId, subfolder, filename))
        }
        return array
        
    }
    
    // MARK: - EXPORT RECORD LOG
    
    func deleteExportLogNotRelateToImageId(profileId:String) -> ExecuteState  {
        let db = PostgresConnection.database()
        
        let sql = """
        delete from "ExportLog" where "imageId" in
        (
        select e."imageId" from "ExportLog" e
        LEFT JOIN "Image" i on e."imageId" = i."id"
         where e."profileId"='\(profileId)'
         and i."id" is NULL
        )
        """
        do {
            try db.execute(sql: sql)
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func countExportedImages(profile:ExportProfile, years:[String]) -> Int {
        let db = PostgresConnection.database()
        
        var yearCondition = """
                    i."photoTakenYear" > 0
            """
        if years.count > 0 {
            yearCondition = """
            i."photoTakenYear" in (\(years.joined(separator: ",")))
            """
        }
        
        let sql = """
select count(1) from "ExportLog" e
left join "Image" i on e."imageId" = i."id"
where e."profileId"='\(profile.id)'
and i."hidden" = 'f'
and i."hiddenByRepository" = 'f'
and i."hiddenByContainer" = 'f'
and \(yearCondition)
"""
        do {
            return try db.count(sql: sql)
        }catch{
            self.logger.log(.error, error)
            return 0
        }
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
    
    func storeImageOriginalMD5(id: String, md5: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "originalMD5" = $1 WHERE "id"=$2
            """, parameterValues: [md5, id])
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    // MARK: Logging
    
    func storeImageExportSuccess(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, exportedMD5: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            let count = try db.count(sql: """
            SELECT count(1) from "ExportLog" where "imageId" = '\(imageId)' and "profileId" = '\(profileId)'
            """)
            if count < 1 {
                self.logger.log(.trace, "insert log \(imageId) \(profileId)")
                try db.execute(sql: """
                INSERT INTO "ExportLog" ("imageId", "profileId", "lastExportTime", "repositoryPath", "subfolder", "filename", "exportedMd5", "state", "failMessage") VALUES ($1, $2, now(), $3, $4, $5, $6, 't', '')
                """, parameterValues: [imageId, profileId, repositoryPath, subfolder, filename, exportedMD5])
            }else{
                self.logger.log(.trace, "update log \(imageId) \(profileId)")
                try db.execute(sql: """
                UPDATE "ExportLog" set "lastExportTime" = now(), "repositoryPath" = $1, "subfolder" = $2, "filename" = $3, "exportedMd5" = $4, "state" = 't', "failMessage" = '' WHERE "imageId"=$5 and "profileId"=$6
                """, parameterValues: [repositoryPath, subfolder, filename, exportedMD5, imageId, profileId])
            }
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func storeImageExportFail(imageId:String, profileId:String, repositoryPath:String, subfolder:String, filename: String, failMessage:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            let count = try db.count(sql: """
            SELECT count(1) from "ExportLog" where "imageId" = '\(imageId)' and "profileId" = '\(profileId)'
            """)
            if count < 1 {
                try db.execute(sql: """
                INSERT INTO "ExportLog" ("imageId", "profileId", "repositoryPath", "subfolder", "filename", "state", "failMessage") VALUES ($1, $2, $3, $4, $5, 'f', $6)
                """, parameterValues: [imageId, profileId, repositoryPath, subfolder, filename, failMessage])
            }else{
                try db.execute(sql: """
                UPDATE "ExportLog" set "repositoryPath" = $1, "subfolder" = $2, "filename" = $3, "state" = 'f', "failMessage" = $4 WHERE "imageId"=$5 and "profileId"=$6
                """, parameterValues: [repositoryPath, subfolder, filename, failMessage, imageId, profileId])
            }
            return .OK
        }catch{
            return .ERROR
        }
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
    
    // MARK: target volumes
    
    func getTargetVolumes() -> [String] {
        var result:[String] = []
        
        let sql = """
        select distinct "targetVolume" from "ExportProfile"
        """
//        self.logger.log(sql)
        
        final class TempRecord : DatabaseRecord {
            var targetVolume:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: sql)
            for row in records {
                result.append(row.targetVolume)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
    }
    
    // MARK: - Profile Events
    
    func deleteProfileEvents(profileId:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
delete from "ExportProfileEvent" where "profileId"='\(profileId)'
""")
            
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func saveProfileEvent(profileId:String, eventOwner:String, eventNodeType:String, eventId:String, eventName:String, exclude:Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
delete from "ExportProfileEvent" where "profileId"='\(profileId)' and "eventId"='\(eventId)'
""")
            let pe = ExportProfileEvent()
            pe.profileId = profileId
            pe.exclude = exclude
            pe.eventId = eventId
            pe.eventName = eventName
            pe.eventNodeType = eventNodeType
            pe.eventOwner = eventOwner
            
            try pe.save(db)
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func saveProfileEvents(profileId:String, selectedEventNodes:[TreeNodeData], exclude:Bool, owner:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
delete from "ExportProfileEvent" where "profileId"='\(profileId)'
""")
            for node in selectedEventNodes {
                let pe = ExportProfileEvent()
                pe.profileId = profileId
                pe.exclude = exclude
                pe.eventId = node.getId()
                pe.eventName = node.getText()
                pe.eventNodeType = node.expandable() ? "group" : "event"
                pe.eventOwner = owner
                
                try pe.save(db)
            }
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func loadProfileEvents(profileId:String) -> [ExportProfileEvent] {
        let db = PostgresConnection.database()
        do {
            return try ExportProfileEvent.fetchAll(db, parameters: ["profileId":profileId])
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
}
