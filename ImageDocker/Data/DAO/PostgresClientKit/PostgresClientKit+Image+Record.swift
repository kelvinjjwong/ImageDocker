//
//  PostgresClientKit+Image+Record.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit

class ImageRecordDaoPostgresCK : ImageRecordDaoInterface {
    
    
    let logger = ConsoleLogger(category: "ImageRecordDaoPostgresCK")
    
    // MARK: QUERY
    
    func getImage(path: String) -> Image? {
        let db = PostgresConnection.database()
        return Image.fetchOne(db, parameters: ["path": path]) // FIXME: it's PK now, deprecate in future version
    }
    
    func getImage(id: String) -> Image? {
        let db = PostgresConnection.database()
        return Image.fetchOne(db, parameters: ["id" : id]) 
    }
    
    func findImage(repositoryVolume:String, repositoryPath:String, subPath:String) -> Image? {
        let path = Naming.Image.generatePath(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
        let db = PostgresConnection.database()
        return Image.fetchOne(db, parameters: ["path": path])
    }
    
    func findImage(repositoryId:Int, subPath:String) -> Image? {
        let db = PostgresConnection.database()
        return Image.fetchOne(db, parameters: ["repositoryId": repositoryId, "subPath": subPath.removeFirstStash()])
    }
    
    // MARK: CRUD
    
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
        image.save(db)
        
        if let createdImage = self.findImage(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath) {
            return createdImage
        }else{
            return nil
        }
    }
    
    func getOrCreatePhoto(filename: String, path: String, parentPath: String, repositoryPath: String?) -> Image {
        let db = PostgresConnection.database()
        self.logger.log(.debug, "trying to get image with path: \(path)")
        if let image = Image.fetchOne(db, parameters: ["path" : path]) {
            return image
        }else{
            let image = Image.new(filename: filename, path: path, parentFolder: parentPath, repositoryPath: repositoryPath ?? "")
            image.save(db)
            return image
        }
    }
    
    func saveImage(image: Image) -> ExecuteState {
        let db = PostgresConnection.database()
        image.save(db)
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
                return .ERROR
            }
            return .OK
        }else{
            let image = Image()
            image.id = id
            image.delete(db)
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
                return .ERROR
            }
            return .OK
        }else{
            let image = Image()
            image.path = path
            image.delete(db)
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return (.ERROR, "")
        }
        return (.OK, id)
    }
    
    func updateImageWithContainerId(id:String, repositoryId:Int, containerId:Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "repositoryId" = $1, "containerId" = $2 where id = $3
            """, parameterValues: [repositoryId, containerId, id])
        }catch{
            self.logger.log(.error, "[updateImageWithContainerId]", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    // MARK: UPDATE PATH
    
    func updateImagePaths(oldPath: String, newPath: String, repositoryPath: String, subPath: String, containerPath: String, id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set path = $1, "repositoryPath" = $2, "subPath" = $3, "containerPath" = $4, id = $5 where path = $6
            """, parameterValues: [newPath, repositoryPath, subPath, containerPath, id, oldPath])
        }catch{
            self.logger.log(.error, "[updateImagePaths]", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRawBase(oldRawPath: String, newRawPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            update "Image" set "originPath" = $1 where "originPath" = $2
            """, parameterValues: [newRawPath, oldRawPath])
        }catch{
            self.logger.log(.error, "[updateImageRawBase]", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRawBase(repositoryPath: String, rawPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            update "Image" set "originPath" = $1 where "repositoryPath" = $2
            """, parameterValues: [rawPath, repositoryPath])
        }catch{
            self.logger.log(.error, "[updateImageRawBase]", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRawBase(pathStartsWith path: String, rawPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            update "Image" set "originPath" = $1 where path like $2
            """, parameterValues: [rawPath, "\(path.withLastStash())%"])
        }catch{
            self.logger.log(.error, "[updateImageRawBase]", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRepositoryBase(pathStartsWith path: String, repositoryPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            update "Image" set "repositoryPath" = $1 where path like $2
            """, parameterValues: [repositoryPath, "\(path.withLastStash())%"])
        }catch{
            self.logger.log(.error, "[updateImageRepositoryBase]", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRepositoryBase(oldRepositoryPath: String, newRepository: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            update "Image" set "repositoryPath" = $1 where "repositoryPath" = $2
            """, parameterValues: [newRepository, oldRepositoryPath])
        }catch{
            self.logger.log(.error, "[updateImageRepositoryBase]", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImagePath(repositoryPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            update "Image" set path = "repositoryPath" || "subPath" where "repositoryPath" = $1 and "subPath" <> ''
            """, parameterValues: [repositoryPath])
        }catch{
            self.logger.log(.error, "[updateImagePath]", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    // MARK: UPDATE DATE
    
    func updateImageDateTimeFromFilename(path:String, dateTimeFromFilename:String) -> ExecuteState{
        self.logger.log("[updateImageDateTimeFromFilename] update image to \(dateTimeFromFilename) - path:\(path)")
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "dateTimeFromFilename" = '\(dateTimeFromFilename)' WHERE path=$1
            """, parameterValues: [path])
        }catch{
            self.logger.log(.error, "[updateImageDateTimeFromFilename] Error to update image to \(dateTimeFromFilename) - path:\(path)", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageDateTimeFromFilename(id:String, dateTimeFromFilename:String) -> ExecuteState{
        self.logger.log("[updateImageDateTimeFromFilename] update image to \(dateTimeFromFilename) - id:\(id)")
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "dateTimeFromFilename" = '\(dateTimeFromFilename)' WHERE id=$1
            """, parameterValues: [id])
        }catch{
            self.logger.log(.error, "[updateImageDateTimeFromFilename] Error to update image to \(dateTimeFromFilename) - id:\(id)", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageDates(path: String, date: Date, fields: Set<String>) -> ExecuteState {
        let db = PostgresConnection.database()
        var arguments:[PostgresValueConvertible] = []
        var values:[String] = []
        
        var placeholders = 0
        for field in fields {
            if field == "PhotoTakenDate" {
                
                values.append("""
                    "photoTakenDate" = \(add(&placeholders)), "photoTakenYear" = \(add(&placeholders)), "photoTakenMonth" = \(add(&placeholders)), "photoTakenDay" = \(add(&placeholders))
                    """)
                arguments.append(date)
                let year = Calendar.current.component(.year, from: date)
                let month = Calendar.current.component(.month, from: date)
                let day = Calendar.current.component(.day, from: date)
                arguments.append(year)
                arguments.append(month)
                arguments.append(day)
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
        print("[UPDATE-DATE-SQL] UPDATE \"Image\" set \(valueSets) WHERE \"path\"=\"\(path)\"")
        print("[UPDATE-DATE-SQL] ARGS: \(arguments)")
        do {
            try db.execute(sql: """
            UPDATE "Image" set \(valueSets) WHERE "path"='\(path)'
            """, parameterValues: arguments)
        }catch{
            self.logger.log(.error, "[updateImageDates]", error)
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }
    
    // MARK: UPDATE ROTATION
    
    func updateImageRotation(path:String, rotation:Int) -> ExecuteState{
        self.logger.log("update image rotation to \(rotation) - \(path)")
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            UPDATE "Image" set "rotation" = \(rotation) WHERE path=$1
            """, parameterValues: [path])
        }catch{
            self.logger.log(.error, "Error to update image rotation to \(rotation) - \(path)", error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
            return .ERROR
        }
        return .OK
    }

}
