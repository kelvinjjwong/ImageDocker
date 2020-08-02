//
//  ModelStore+Image+Update.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ImageRecordDaoGRDB {
    
    // MARK: - BASIC
    
    func saveImage(image: Image) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                var image = image
                try image.save(db)
                //print("saved image")
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func deletePhoto(atPath path:String, updateFlag:Bool = true) -> ExecuteState{
        if updateFlag {
            do {
                let db = try SQLiteConnectionGRDB.default.sharedDBPool()
                let _ = try db.write { db in
                    try db.execute(sql: "update Image set delFlag = ?", arguments: [true])
                }
            }catch{
                return SQLHelper.errorState(error)
            }
            return .OK
        }else{
            do {
                let db = try SQLiteConnectionGRDB.default.sharedDBPool()
                let _ = try db.write { db in
                    try Image.deleteOne(db, key: path)
                }
            }catch{
                return SQLHelper.errorState(error)
            }
            return .OK
        }
    }
    
    // MARK: - PATH
    
    func updateImagePaths(oldPath:String, newPath:String, repositoryPath:String, subPath:String, containerPath:String, id:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update Image set path = ?, repositoryPath = ?, subPath = ?, containerPath = ?, id = ? where path = ?", arguments: [newPath, repositoryPath, subPath, containerPath, id, oldPath])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageRawBase(oldRawPath:String, newRawPath:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update Image set originPath = ? where originPath = ?", arguments: [newRawPath, oldRawPath])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageRawBase(repositoryPath:String, rawPath:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update Image set originPath = ? where repositoryPath = ?", arguments: [rawPath, repositoryPath])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageRawBase(pathStartsWith path:String, rawPath:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update Image set originPath = ? where path like ?", arguments: [rawPath, "\(path.withStash())%"])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageRepositoryBase(pathStartsWith path:String, repositoryPath:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update Image set repositoryPath = ? where path like ?", arguments: [repositoryPath, "\(path.withStash())%"])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageRepositoryBase(oldRepositoryPath:String, newRepository:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update Image set repositoryPath = ? where repositoryPath = ?", arguments: [newRepository, oldRepositoryPath])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImagePath(repositoryPath:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update Image set path = repositoryPath || subPath where repositoryPath = ? and subPath <> ''", arguments: [repositoryPath])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    
    
    // MARK: - DATE
    
    func updateImageDates(path:String, date:Date, fields:Set<String>) -> ExecuteState{
        var arguments:[Any] = []
        var values:[String] = []
        
        for field in fields {
            if field == "PhotoTakenDate" {
                
                values.append("photoTakenDate = ?, photoTakenYear = ?, photoTakenMonth = ?, photoTakenDay = ?")
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
                values.append("exifDateTimeOriginal = ?")
                arguments.append(date)
                continue
            }
            if field == "CreateDate" {
                values.append("exifCreateDate = ?")
                arguments.append(date)
                continue
            }
            if field == "ModifyDate" {
                values.append("exifModifyDate = ?")
                arguments.append(date)
                continue
            }
            if field == "FileCreateDate" {
                values.append("filesysCreateDate = ?")
                arguments.append(date)
                continue
            }
        }
        arguments.append(path)
        let valueSets = values.joined(separator: ",")
        
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "UPDATE Image set \(valueSets) WHERE path=?", arguments: StatementArguments(arguments) ?? [])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    // MARK: - DESCRIPTION
    
    func storeImageDescription(path:String, shortDescription:String?, longDescription:String?) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                if let brief = shortDescription, let detailed = longDescription {
                    try db.execute(sql: "UPDATE Image set shortDescription = ?, longDescription = ? WHERE path=?", arguments: StatementArguments([brief, detailed, path]))
                }else if let brief = shortDescription {
                    try db.execute(sql: "UPDATE Image set shortDescription = ? WHERE path=?", arguments: StatementArguments([brief, path]))
                }else if let detailed = longDescription {
                    try db.execute(sql: "UPDATE Image set longDescription = ? WHERE path=?", arguments: StatementArguments([detailed, path]))
                }
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    
}

class ImageFaceDaoGRDB : ImageFaceDaoInterface {
    
    // MARK: - FACE
    
    func updateImageScannedFace(imageId:String, facesCount:Int) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update Image set scanedFace=1, facesCount=? where id=?", arguments: [facesCount, imageId])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updateImageRecognizedFace(imageId:String, recognizedPeopleIds:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update Image set recognizedFace=1,recognizedPeopleIds=? where id=?", arguments: [recognizedPeopleIds,imageId])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
}

class ImageExportDaoGRDB : ImageExportDaoInterface {
}
