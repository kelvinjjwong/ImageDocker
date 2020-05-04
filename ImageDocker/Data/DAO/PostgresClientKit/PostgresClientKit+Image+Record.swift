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
    
    func getOrCreatePhoto(filename: String, path: String, parentPath: String, repositoryPath: String?) -> Image {
        let db = PostgresConnection.database()
        if let image = Image.fetchOne(db, parameters: ["path" : path]) {
            return image
        }else{
            let image = Image.new(filename: filename, path: path, parentFolder: parentPath, repositoryPath: repositoryPath ?? "")
            image.save(db)
            return image
        }
    }
    
    func getImage(path: String) -> Image? {
        let db = PostgresConnection.database()
        return Image.fetchOne(db, parameters: ["path": path])
    }
    
    func getImage(id: String) -> Image? {
        let db = PostgresConnection.database()
        return Image.fetchOne(db, parameters: ["id" : id])
    }
    
    func saveImage(image: Image) -> ExecuteState {
        let db = PostgresConnection.database()
        image.save(db)
        return .OK
    }
    
    func deletePhoto(atPath path: String, updateFlag: Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        if updateFlag {
            do {
                try db.execute(sql: "update Image set delFlag = $1", parameterValues: [true])
            }catch{
                print(error)
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
    
    func updateImagePaths(oldPath: String, newPath: String, repositoryPath: String, subPath: String, containerPath: String, id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: "update Image set path = $1, repositoryPath = $2, subPath = $3, containerPath = $4, id = $5 where path = $6", parameterValues: [newPath, repositoryPath, subPath, containerPath, id, oldPath])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRawBase(oldRawPath: String, newRawPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: "update Image set originPath = $1 where originPath = $2", parameterValues: [newRawPath, oldRawPath])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRawBase(repositoryPath: String, rawPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: "update Image set originPath = $1 where repositoryPath = $2", parameterValues: [rawPath, repositoryPath])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRawBase(pathStartsWith path: String, rawPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: "update Image set originPath = $1 where path like $2", parameterValues: [rawPath, "\(path.withStash())%"])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRepositoryBase(pathStartsWith path: String, repositoryPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: "update Image set repositoryPath = $1 where path like $2", parameterValues: [repositoryPath, "\(path.withStash())%"])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRepositoryBase(oldRepositoryPath: String, newRepository: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: "update Image set repositoryPath = $1 where repositoryPath = $2", parameterValues: [newRepository, oldRepositoryPath])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImagePath(repositoryPath: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: "update Image set path = repositoryPath || subPath where repositoryPath = $1 and subPath <> ''", parameterValues: [repositoryPath])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageDates(path: String, date: Date, fields: Set<String>) -> ExecuteState {
        let db = PostgresConnection.database()
        var arguments:[PostgresValueConvertible?] = []
        var values:[String] = []
        
        var placeholders = 0
        for field in fields {
            if field == "PhotoTakenDate" {
                
                values.append("photoTakenDate = $\(placeholders+=1), photoTakenYear = \(add(&placeholders)), photoTakenMonth = \(add(&placeholders)), photoTakenDay = \(add(&placeholders))")
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
                values.append("exifDateTimeOriginal = \(add(&placeholders))")
                arguments.append(date)
                continue
            }
            if field == "CreateDate" {
                values.append("exifCreateDate = \(add(&placeholders))")
                arguments.append(date)
                continue
            }
            if field == "ModifyDate" {
                values.append("exifModifyDate = \(add(&placeholders))")
                arguments.append(date)
                continue
            }
            if field == "FileCreateDate" {
                values.append("filesysCreateDate = \(add(&placeholders))")
                arguments.append(date)
                continue
            }
        }
        arguments.append(path)
        let valueSets = values.joined(separator: ",")
        do {
            try db.execute(sql: "UPDATE Image set \(valueSets) WHERE path=\(add(&placeholders))", parameterValues: arguments)
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func storeImageDescription(path: String, shortDescription: String?, longDescription: String?) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            if let brief = shortDescription, let detailed = longDescription {
                try db.execute(sql: "UPDATE Image set shortDescription = $1, longDescription = $2 WHERE path=$3", parameterValues: [brief, detailed, path])
            }else if let brief = shortDescription {
                try db.execute(sql: "UPDATE Image set shortDescription = $1 WHERE path=$2", parameterValues: [brief, path])
            }else if let detailed = longDescription {
                try db.execute(sql: "UPDATE Image set longDescription = $1 WHERE path=$2", parameterValues: [detailed, path])
            }
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    

}
