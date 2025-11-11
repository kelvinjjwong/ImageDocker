//
//  PostgresClientKit+Image+Record.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory

class ImageRecordDaoPostgresCK : ImageRecordDaoInterface {
    
    
    let logger = LoggerFactory.get(category: "ImageRecordDaoPostgresCK")
    
    // MARK: QUERY
    
    func getImage(path: String) -> Image? {
        let db = PostgresConnection.database()
        do {
            return try Image.fetchOne(db, parameters: ["path": path]) // FIXME: it's PK now, deprecate in future version
        }catch {
            self.logger.log(.error, error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "getImage", message: "\(error)")
            return nil
        }
    }
    
    func getImage(id: String) -> Image? {
        let db = PostgresConnection.database()
        do {
            return try Image.fetchOne(db, parameters: ["id" : id])
        }catch {
            self.logger.log(.error, error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "getImage", message: "\(error)")
            return nil
        }
    }
    
    func findImage(repositoryVolume:String, repositoryPath:String, subPath:String) -> Image? {
        let path = Naming.Image.generatePath(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
        let db = PostgresConnection.database()
        do {
            return try Image.fetchOne(db, parameters: ["path": path])
        }catch {
            self.logger.log(.error, error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "findImage", message: "\(error)")
            return nil
        }
    }
    
    func findImage(repositoryId:Int, subPath:String) -> Image? {
        let db = PostgresConnection.database()
        do {
            return try Image.fetchOne(db, parameters: ["repositoryId": repositoryId, "subPath": subPath.removeFirstStash()])
        }catch {
            self.logger.log(.error, error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "findImage", message: "\(error)")
            return nil
        }
    }
    
    func getImagesWithNullId(owner:String) -> [(Int, String)] { // repositoryId, subPath
        let db = PostgresConnection.database()
        let sql = """
        select i."repositoryId",i."subPath" from "Image" i
        left join "ImageRepository" r on i."repositoryId" = r."id"
        where r."owner"='\(owner)' 
        and i."id" is NULL
        order by i."repositoryId",i."subPath"
        """
        final class TempRecord : DatabaseRecord {
            var repositoryId: Int? = nil
            var subPath: String? = nil
            public init() {}
        }
        var result:[(Int, String)] = []
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
        }
        for row in records {
            result.append((row.repositoryId ?? 0, row.subPath ?? ""))
        }
        return result
    }
    
    func getImagesWithNullFileExt(owner:String) -> [(String, String)] { // imageId, subpath
        let db = PostgresConnection.database()
        let sql = """
        select i."id",i."subPath" from "Image" i
        left join "ImageRepository" r on i."repositoryId" = r."id"
        where r."owner"='\(owner)' 
        and (i."fileExt" is NULL or i."fileExt" = '')
        order by i."repositoryId",i."subPath"
        """
        final class TempRecord : DatabaseRecord {
            var id: String? = nil
            var subPath: String? = nil
            public init() {}
        }
        var result:[(String, String)] = []
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
        }
        for row in records {
            result.append((row.id ?? "", row.subPath ?? ""))
        }
        return result
        
    }
    
    func getImagesWithNullOriginalMD5(owner:String) -> [(String, Int, String, String, String, String, String)] { // imageId, repositoryId, repositoryVolume, repositoryPath, storageVolume, storagePath, subpath
        let db = PostgresConnection.database()
        let sql = """
        select i."id",i."repositoryId",r."repositoryVolume",r."repositoryPath",r."storageVolume",r."storagePath",i."subPath" from "Image" i
        left join "ImageRepository" r on i."repositoryId" = r."id"
        where r."owner"='\(owner)' 
        and (i."originalMD5" is NULL or i."originalMD5" = '')
        order by i."repositoryId",i."subPath"
        """
        final class TempRecord : DatabaseRecord {
            var id: String? = nil
            var repositoryId: Int? = nil
            var repositoryVolume: String? = nil
            var repositoryPath: String? = nil
            var storageVolume: String? = nil
            var storagePath: String? = nil
            var subPath: String? = nil
            public init() {}
        }
        var result:[(String, Int, String, String, String, String, String)] = []
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
        }
        for row in records {
            result.append((
                row.id ?? "",
                row.repositoryId ?? 0,
                row.repositoryVolume ?? "",
                row.repositoryPath ?? "",
                row.storageVolume ?? "",
                row.storagePath ?? "",
                row.subPath ?? ""
            ))
        }
        return result
    }
    
    func getImageOriginalMD5HavingDuplicated(owner:String) -> [String] {
        let db = PostgresConnection.database()
        let sql = """
        select "originalMD5" from "Image" i
        left join "ImageRepository" r on i."repositoryId" = r."id"
        where r."owner" = '\(owner)'
        group by "originalMD5"
        HAVING count("originalMD5")>1
        """
        final class TempRecord : DatabaseRecord {
            var originalMD5: String? = nil
            public init() {}
        }
        var result:[String] = []
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
        }
        for row in records {
            result.append(row.originalMD5 ?? "")
        }
        return result
    }
    
    func getImageIds(originalMD5:String, checkDuplicatesKey:Bool) -> [(String, Bool, String)] {
        let db = PostgresConnection.database()
        
        var condition = ""
        if checkDuplicatesKey {
            condition = """
                 and ("duplicatesKey" is null or "duplicatesKey" = '')
        """
        }
        let sql = """
        select "id",hidden,"duplicatesKey" from "Image"
        where "originalMD5"='\(originalMD5)' \(condition)
        order by "repositoryId", "subPath"
        """
        final class TempRecord : DatabaseRecord {
            var id: String? = nil
            var hidden: Bool? = nil
            var duplicatesKey: String? = nil
            public init() {}
        }
        var result:[(String, Bool, String)] = []
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
        }
        for row in records {
            result.append((row.id ?? "", row.hidden ?? false, row.duplicatesKey ?? ""))
        }
        return result
    }
    
    func hideImageWithDuplicateKey(imageId:String, duplicatesKey:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "duplicatesKey" = $1, hidden = 't' where "id" = $2
            """, parameterValues: [duplicatesKey, imageId])
        }catch{
            self.logger.log(.error, "[hideImageWithDuplicateKey]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "hideImageWithDuplicateKey", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func showImageWithDuplicateKey(imageId:String, duplicatesKey:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "duplicatesKey" = $1, hidden = 'f' where "id" = $2
            """, parameterValues: [duplicatesKey, imageId])
        }catch{
            self.logger.log(.error, "[hideImageWithDuplicateKey]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "hideImageWithDuplicateKey", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    // MARK: CRUD
    
    // FIXME: repositoryVolume and repositoryPath and path should be delete
    func createImage(repositoryId:Int, containerId:Int, repositoryVolume:String, repositoryPath:String, subPath:String) -> Image? {
        let db = PostgresConnection.database()
        let image = Image()
        image.id = Naming.Image.generateId()
        image.repositoryId = repositoryId
        image.containerId = containerId
        image.subPath = subPath.removeFirstStash()
        image.filename = subPath.lastPartOfUrl()
        image.path = Naming.Image.generatePath(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath) // FIXME: it's PK now, deprecate in future version
        image.repositoryPath = Naming.Image.generateFullAbsoluteRepositoryPath(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath) // FIXME: deprecate in future version
        image.containerPath = Naming.Image.generateFullAbsoluteContainerPath(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath).removeLastStash() // FIXME: deprecate in future version
        
        do {
            try image.save(db)
        }catch {
            self.logger.log(.error, error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "createImage", message: "\(error)")
        }
        
        if let createdImage = self.findImage(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath) {
            return createdImage
        }else{
            return nil
        }
    }
    
    func getOrCreatePhoto(filename: String, path: String, parentPath: String, repositoryPath: String?) -> Image {
        let db = PostgresConnection.database()
        self.logger.log(.debug, "trying to get image with path: \(path)")
        let dummy = Image.new(filename: filename, path: path, parentFolder: parentPath, repositoryPath: repositoryPath ?? "")
        do {
            if let image = try Image.fetchOne(db, parameters: ["path" : path]) {
                return image
            }else{
                try dummy.save(db)
                return dummy
            }
        }catch {
            self.logger.log(.error, error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "getOrCreatePhoto", message: "\(error)")
            return dummy
        }
    }
    
    func saveImage(image: Image) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try image.save(db)
        }catch {
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "saveImage", message: "\(error)")
            self.logger.log(.error, error)
        }
        return .OK
    }
    
    func deleteImage(id: String, updateFlag: Bool) -> ExecuteState {
        
        let db = PostgresConnection.database()
        if updateFlag {
            do {
                try db.execute(sql: """
                update "Image" set "delFlag" = $1 where id = $2
                """, parameterValues: [true, id])
            }catch{
                self.logger.log(.error, "[deletePhoto]", error)
                let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "deleteImage", message: "\(error)")
                return .ERROR
            }
            return .OK
        }else{
            let image = Image()
            image.id = id
            do {
                try image.delete(db)
            }catch {
                self.logger.log(.error, error)
                let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "deleteImage", message: "\(error)")
            }
            return .OK
        }
    }
    
    func deletePhoto(atPath path: String, updateFlag: Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        if updateFlag {
            do {
                try db.execute(sql: """
                update "Image" set "delFlag" = $1 where path = $2
                """, parameterValues: [true, path])
            }catch{
                self.logger.log(.error, "[deletePhoto]", error)
                let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "deletePhoto", message: "\(error)")
                return .ERROR
            }
            return .OK
        }else{
            let image = Image()
            image.path = path
            do {
                try image.delete(db)
            }catch {
                let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "deletePhoto", message: "\(error)")
                self.logger.log(.error, error)
            }
            return .OK
        }
    }
    
    // MARK: UPDATE ID
    
    func generateImageIdByPath(repositoryVolume:String, repositoryPath:String, subPath:String) -> (ExecuteState, String) {
        let id = Naming.Image.generateId()
        let path = Naming.Image.generatePath(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "id" = $1 where "path" = $2
            """, parameterValues: [id, path])
        }catch{
            self.logger.log(.error, "[updateImageIdByPath]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "generateImageIdByPath", message: "\(error)")
            return (.ERROR, "")
        }
        return (.OK, id)
    }
    
    func generateImageIdByContainerIdAndSubPath(containerId:Int, subPath:String) -> (ExecuteState, String) {
        let id = Naming.Image.generateId()
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "id" = $1 where "containerId" = $2 and "subPath" = $3
            """, parameterValues: [id, containerId, subPath.removeFirstStash()])
        }catch{
            self.logger.log(.error, "[generateImageIdByContainerIdAndSubPath]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "generateImageIdByContainerIdAndSubPath", message: "\(error)")
            return (.ERROR, "")
        }
        return (.OK, id)
    }
    
    func generateImageIdByRepositoryIdAndSubPath(repositoryId:Int, subPath:String) -> (ExecuteState, String) {
        let id = Naming.Image.generateId()
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "id" = $1 where "repositoryId" = $2 and "subPath" = $3
            """, parameterValues: [id, repositoryId, subPath.removeFirstStash()])
        }catch{
            self.logger.log(.error, "[generateImageIdByRepositoryIdAndSubPath]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "generateImageIdByRepositoryIdAndSubPath", message: "\(error)")
            return (.ERROR, "")
        }
        return (.OK, id)
    }
    
    func updateImageFileExt(id:String, fileExt:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "fileExt" = $1 where "id" = $2
            """, parameterValues: [fileExt, id])
        }catch{
            self.logger.log(.error, "[updateImageFileExt]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageFileExt", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func updateImageOrginalMD5(id:String, md5:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "originalMD5" = $1 where "id" = $2
            """, parameterValues: [md5, id])
        }catch{
            self.logger.log(.error, "[updateImageOrginalMD5]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageOrginalMD5", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func updateImageMd5AndDeviceFileId(id:String, md5:String, deviceId:String, deviceFileId:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "originalMD5" = $1, "deviceId" = $2, "deviceFileId" = $3 where "id" = $4
            """, parameterValues: [md5, deviceId, deviceFileId, id])
        }catch{
            self.logger.log(.error, "[updateImageMd5AndDeviceFileId]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageMd5AndDeviceFileId", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func updateImageWithContainerId(id:String, repositoryId:Int, containerId:Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "repositoryId" = $1, "containerId" = $2 where id = $3
            """, parameterValues: [repositoryId, containerId, id])
        }catch{
            self.logger.log(.error, "[updateImageWithContainerId]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageWithContainerId", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    // MARK: UPDATE PATH
    
    func updateImagePaths(oldPath: String, newPath: String, repositoryPath: String, subPath: String, containerPath: String, id: String) -> ExecuteState {
        self.logger.log(.trace, "[updateImagePaths(oldPath,newPath,repositoryPath,subPath,containerPath,id)]")
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set path = $1, "repositoryPath" = $2, "subPath" = $3, "containerPath" = $4, id = $5 where path = $6
            """, parameterValues: [newPath, repositoryPath, subPath, containerPath, id, oldPath])
        }catch{
            self.logger.log(.error, "[updateImagePaths(oldPath,newPath,repositoryPath,subPath,containerPath,id)]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImagePaths", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func updateImagePaths(id: String, newPath: String, repositoryPath: String, subPath: String, containerPath: String) -> ExecuteState {
        self.logger.log(.trace, "[updateImagePaths(id,newPath,repositoryPath,subPath,containerPath)]")
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set path = $1, "repositoryPath" = $2, "subPath" = $3, "containerPath" = $4 where id = $5
            """, parameterValues: [newPath, repositoryPath, subPath, containerPath, id])
        }catch{
            self.logger.log(.error, "[updateImagePaths(id,newPath,repositoryPath,subPath,containerPath)]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImagePaths", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    
    // MARK: UPDATE DATE
    
    func updateImageDateTimeFromFilename(path:String, dateTimeFromFilename:String) -> ExecuteState{
        self.logger.log(.trace, "[updateImageDateTimeFromFilename] update image to \(dateTimeFromFilename) - path:\(path)")
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "dateTimeFromFilename" = '\(dateTimeFromFilename)' WHERE path=$1
            """, parameterValues: [path])
        }catch{
            self.logger.log(.error, "[updateImageDateTimeFromFilename] Error to update image to \(dateTimeFromFilename) - path:\(path)", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageDateTimeFromFilename", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func updateImageDateTimeFromFilename(id:String, dateTimeFromFilename:String) -> ExecuteState{
        self.logger.log(.trace, "[updateImageDateTimeFromFilename] update image to \(dateTimeFromFilename) - id:\(id)")
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "dateTimeFromFilename" = '\(dateTimeFromFilename)' WHERE id=$1
            """, parameterValues: [id])
        }catch{
            self.logger.log(.error, "[updateImageDateTimeFromFilename] Error to update image to \(dateTimeFromFilename) - id:\(id)", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageDateTimeFromFilename", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func updateImageDates(path: String, date: Date, fields: Set<String>) -> ExecuteState {
        let db = PostgresConnection.database()
        var arguments:[DatabaseValueConvertible] = []
        var values:[String] = []
        
        var placeholders = 0
        for field in fields {
            if field == "PhotoTakenDate" {
                
                values.append("""
                    "photoTakenDate" = \(add(&placeholders)), "photoTakenYear" = \(add(&placeholders)), "photoTakenMonth" = \(add(&placeholders)), "photoTakenDay" = \(add(&placeholders)), "photoTakenHour" = \(add(&placeholders))
                    """)
                arguments.append(date)
                let year = Calendar.current.component(.year, from: date)
                let month = Calendar.current.component(.month, from: date)
                let day = Calendar.current.component(.day, from: date)
                let hour = Calendar.current.component(.hour, from: date)
                arguments.append(year)
                arguments.append(month)
                arguments.append(day)
                arguments.append(hour)
                continue
            }
            if field == "DateTimeOriginal" {
                values.append("\"exifDateTimeOriginal\" = \(add(&placeholders))")
                arguments.append(date)
                continue
            }
            if field == "CreateDate" {
                values.append("\"exifCreateDate\" = \(add(&placeholders))")
                arguments.append(date)
                continue
            }
            if field == "ModifyDate" {
                values.append("\"exifModifyDate\" = \(add(&placeholders))")
                arguments.append(date)
                continue
            }
            if field == "FileCreateDate" {
                values.append("\"filesysCreateDate\" = \(add(&placeholders))")
                arguments.append(date)
                continue
            }
        }
//        arguments.append(path)
        let valueSets = values.joined(separator: ",")
        self.logger.log(.trace, "[UPDATE-DATE-SQL] UPDATE \"Image\" set \(valueSets) WHERE \"path\"=\"\(path)\"")
        self.logger.log(.trace, "[UPDATE-DATE-SQL] ARGS: \(arguments)")
        do {
            try db.execute(sql: """
            UPDATE "Image" set \(valueSets) WHERE "path"='\(path)'
            """, parameterValues: arguments)
        }catch{
            self.logger.log(.error, "[updateImageDates]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageDates", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    // MARK: UPDATE DESCRIPTION
    
    func storeImageDescription(path: String, shortDescription: String?, longDescription: String?) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            if let brief = shortDescription, let detailed = longDescription {
                try db.execute(sql: """
                UPDATE "Image" set "shortDescription" = $1, "longDescription" = $2 WHERE path=$3
                """, parameterValues: [brief, detailed, path])
            }else if let brief = shortDescription {
                try db.execute(sql: """
                UPDATE "Image" set "shortDescription" = $1 WHERE path=$2
                """, parameterValues: [brief, path])
            }else if let detailed = longDescription {
                try db.execute(sql: """
                UPDATE "Image" set "longDescription" = $1 WHERE path=$2
                """, parameterValues: [detailed, path])
            }
        }catch{
            self.logger.log(.error, "[storeImageDescription]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "storeImageDescription", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func updateImageShortDescription(shortDescription:String, imageIds:[String]) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "shortDescription" = $1 WHERE id in (\(imageIds.joinedSingleQuoted(separator: ",")))
            """, parameterValues: [shortDescription])
        }catch{
            self.logger.log(.error, "[updateImageShortDescription]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageShortDescription", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func updateImageLongDescription(longDescription:String, imageIds:[String]) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "longDescription" = $1 WHERE id in (\(imageIds.joinedSingleQuoted(separator: ",")))
            """, parameterValues: [longDescription])
        }catch{
            self.logger.log(.error, "[updateImageLongDescription]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageLongDescription", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func updateImageShortAndLongDescription(shortDescription:String, longDescription:String, imageIds:[String]) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "shortDescription" = $1, "longDescription" = $2 WHERE id in (\(imageIds.joinedSingleQuoted(separator: ",")))
            """, parameterValues: [shortDescription, longDescription])
        }catch{
            self.logger.log(.error, "[updateImageShortDescription]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageShortDescription", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    // MARK: UPDATE EVENT
    
    func updateEvent(imageId:String, event:String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "event" = $1 WHERE id = $2
            """, parameterValues: [event, imageId])
        }catch{
            self.logger.log(.error, "[updateEvent]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateEvent", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    // MARK: UPDATE FAMILY
    
    func unlinkImageFamily(imageId:String, familyId:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            delete from "ImageFamily" where "imageId" = $1 and "familyId" = $2
            """, parameterValues: [imageId, familyId])
            return .OK
        }catch{
            self.logger.log(.error, "[unlinkImageFamily]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "unlinkImageFamily", message: "\(error)")
            return .ERROR
        }
    }
    
    func unlinkImageFamilies(imageId:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            delete from "ImageFamily" where "imageId" = $1
            """, parameterValues: [imageId])
            return .OK
        }catch{
            self.logger.log(.error, "[unlinkImageFamilies]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "unlinkImageFamilies", message: "\(error)")
            return .ERROR
        }
    }
    
    func unlinkImageFamilies(familyId:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            delete from "ImageFamily" where "familyId" = $1
            """, parameterValues: [familyId])
            return .OK
        }catch{
            self.logger.log(.error, "[unlinkImageFamilies]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "unlinkImageFamilies", message: "\(error)")
            return .ERROR
        }
    }
    
    func storeImageFamily(imageId:String, familyId:String, ownerId:String, familyName: String, owner: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            if let record = try ImageFamily.fetchOne(db, parameters: ["imageId": imageId, "familyId": familyId]) {
                
                try db.execute(sql: """
                UPDATE "ImageFamily" SET "imageId" = $1, "familyId" = $2, "ownerId" = $3, "familyName" = $4, "owner" = $5 WHERE "id" = $6
                """, parameterValues: [imageId, familyId, ownerId, familyName, owner, record.id])
                
            }else{
                
                try db.execute(sql: """
                INSERT INTO "ImageFamily" ("imageId", "familyId", "ownerId", "familyName", "owner") VALUES ($1, $2, $3, $4, $5)
                """, parameterValues: [imageId, familyId, ownerId, familyName, owner])
            }
            return .OK
        }catch{
            self.logger.log(.error, "[storeImageFamily]", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "storeImageFamily", message: "\(error)")
            return .ERROR
        }
    }
    
    // MARK: UPDATE ROTATION
    
    func updateImageRotation(path:String, rotation:Int) -> ExecuteState{
        self.logger.log(.trace, "update image rotation to \(rotation) - \(path)")
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "rotation" = \(rotation) WHERE path=$1
            """, parameterValues: [path])
        }catch{
            self.logger.log(.error, "Error to update image rotation to \(rotation) - \(path)", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "updateImageRotation", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    func hideUnsupportedRecords() -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "hidden"=true WHERE lower((regexp_split_to_array(filename, '\\.'))[array_upper(regexp_split_to_array(filename, '\\.'), 1)]) not in (\(FileTypeRecognizer.photoExts.appending(FileTypeRecognizer.videoExts).joinedSingleQuoted(separator: ",")))
            """)
        }catch{
            self.logger.log(.error, "Error to hide unsupported records", error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageRecordDaoPostgresCK", name: "hideUnsupportedRecords", message: "\(error)")
            return .ERROR
        }
        return .OK
    }
    
    // MARK: TAGGING
    
    func tagImage(imageId:String, tag:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
update "Image" set "tagx" = ARRAY(SELECT DISTINCT UNNEST("tagx" || '{\(tag)}')) where "id" = '\(imageId)'
"""
            )
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func untagImage(imageId:String, tag:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
update "Image" set "tagx" = ARRAY(SELECT DISTINCT UNNEST(array_remove("tagx",'\(tag)'))) where "id" = '\(imageId)'
"""
            )
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }

}
