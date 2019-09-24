//
//  ModelStore+Image+Search.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStore {
    
    // MARK: - COLLECTION
    
    // get by date & place
    func getPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        
        print("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result:[Image] = []
        var hiddenCount:Int = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                hiddenCount = try Image.filter(sql: stmtHidden, arguments:StatementArguments(sqlArgs)).fetchCount(db)
                if pageNumber > 0 && pageSize > 0 {
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs))
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .limit(pageSize, offset: pageSize * (pageNumber - 1))
                        .fetchAll(db)
                }else{
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs))
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
        return result
    }
    
    // get by date & event & place
    func getPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        
        print("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result:[Image] = []
        var hiddenCount:Int = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                hiddenCount = try Image.filter(sql: stmtHidden, arguments:StatementArguments(sqlArgs)).fetchCount(db)
                if pageNumber > 0 && pageSize > 0 {
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs))
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .limit(pageSize, offset: pageSize * (pageNumber - 1))
                        .fetchAll(db)
                }else{
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs))
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
        return result
    }
    
    // MARK: - SEARCH
    
    // search by date & people & any keywords
    func searchPhotoFiles(years:[Int], months:[Int], days:[Int], peopleIds:[String], keywords:[String], includeHidden:Bool = true, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        
        print("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden) = self.generateSQLStatementForSearchingPhotoFiles(years: years, months: months, days: days, peopleIds: peopleIds, keywords: keywords, includeHidden:includeHidden)
        
        var result:[Image] = []
        var hiddenCount:Int = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                hiddenCount = try Image.filter(sql: stmtHidden).fetchCount(db)
                if pageNumber > 0 && pageSize > 0 {
                    result = try Image.filter(sql:stmt)
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .limit(pageSize, offset: pageSize * (pageNumber - 1))
                        .fetchAll(db)
                }else{
                    result = try Image.filter(sql:stmt)
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
        return result
    }
    
    // MARK: - DATE
    
    
    func getImagesByDate(year:Int, month:Int, day:Int, event:String? = nil) -> [Image]{
        var sql = "hidden=0 and photoTakenYear=\(year) and photoTakenMonth=\(month) and photoTakenDay=\(day)"
        if let ev = event, ev != "" {
            sql = "hidden=0 and photoTakenYear=\(year) and photoTakenMonth=\(month) and photoTakenDay=\(day) and event='\(ev)'"
        }
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: sql).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    
    func getImagesByYear(year:String? = nil, scannedFace:Bool? = nil, recognizedFace:Bool? = nil) -> [Image]{
        var sql = "hidden=0"
        if let y = year, y != "" {
            sql += " and photoTakenYear=\(y)"
        }else{
            sql += " and photoTakenYear > 1920"
        }
        if let flag = scannedFace {
            if flag {
                sql += " and scanedFace=1"
            }else{
                sql += " and scanedFace=0"
            }
        }
        if let flag = recognizedFace {
            if flag {
                sql += " and recognizedFace=1"
            }else{
                sql += " and recognizedFace=0"
            }
        }
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: sql).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    
    func getImagesByDate(photoTakenDate:Date, event:String? = nil) -> [Image]{
        let year = Calendar.current.component(.year, from: photoTakenDate)
        let month = Calendar.current.component(.month, from: photoTakenDate)
        let day = Calendar.current.component(.day, from: photoTakenDate)
        return getImagesByDate(year: year, month: month, day: day, event: event)
    }
    
    func getImagesByHour(photoTakenDate:Date) -> [Image]{
        let year = Calendar.current.component(.year, from: photoTakenDate)
        let month = Calendar.current.component(.month, from: photoTakenDate)
        let day = Calendar.current.component(.day, from: photoTakenDate)
        let hour = Calendar.current.component(.hour, from: photoTakenDate)
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: "hidden=0 and photoTakenYear=\(year) and photoTakenMonth=\(month) and photoTakenDay=\(day) and photoTakenHour=\(hour)").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - EXIF
    
    func getPhotoFilesWithoutExif(limit:Int? = nil) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "hidden != 1 AND (updateExifDate is null OR photoTakenYear is null OR photoTakenYear = 0 OR (latitude <> '0.0' AND latitudeBD = '0.0') OR (latitudeBD <> '0.0' AND COUNTRY = ''))").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - LOCATION
    
    func getPhotoFilesWithoutLocation() -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "hidden != 1 AND updateLocationDate is null").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getPhotoFiles(after date:Date) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "updateLocationDate >= ?", arguments: StatementArguments([date])).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - FACE
    
    func getImagesWithoutFace(repositoryRoot:String, includeScanned:Bool = false) -> [Image] {
        var result:[Image] = []
        let root = repositoryRoot.withStash()
        let scannedCondition = includeScanned ? "" : " and scanedFace=0"
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath=? and hidden=0 \(scannedCondition) and id not in (select distinct imageid from imageface)", arguments:[root]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - PATH
    
    func getAllPhotoPaths(includeHidden:Bool = true, sharedDB:DatabaseWriter? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                if includeHidden {
                    let cursor = try Image.order([Column("photoTakenDate").asc, Column("filename").asc]).fetchCursor(db)
                    while let photo = try cursor.next() {
                        result.insert(photo.path)
                    }
                }else{
                    let cursor = try Image.filter(sql: "hidden = 0").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchCursor(db)
                    while let photo = try cursor.next() {
                        result.insert(photo.path)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getPhotoFilesWithoutSubPath(rootPath:String) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(Column("path").like("\(rootPath.withStash())%")).filter(Column("subPath") == "").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getPhotoFiles(parentPath:String, includeHidden:Bool = true, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false) -> [Image] {
        var otherPredicate:String = ""
        if !includeHidden {
            otherPredicate = " AND (hidden is null || hidden = 0)"
        }
        
        var condition = "containerPath = ?"
        var key:[String] = [parentPath]
        if subdirectories {
            condition = "(containerPath = ? or containerPath like ?)"
            key.append("\(parentPath.withStash())%")
        }
        
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                if pageSize > 0 && pageNumber > 0 {
                    result = try Image.filter(sql: "\(condition) \(otherPredicate)", arguments: StatementArguments(key)).order([Column("photoTakenDate").asc, Column("path").asc]).limit(pageSize, offset: pageSize * (pageNumber - 1)).fetchAll(db)
                }else{
                    result = try Image.filter(sql: "\(condition) \(otherPredicate)", arguments: StatementArguments(key)).order([Column("photoTakenDate").asc, Column("path").asc]).fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getImages(repositoryPath:String) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath = ?", arguments:[repositoryPath]).order(sql: "path asc").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getPhotoFiles(rootPath:String) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(Column("path").like("\(rootPath.withStash())%")).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - EXPORT
    
    func getAllExportedImages(includeHidden:Bool = true, sharedDB:DatabaseWriter? = nil) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
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
    
    func getAllExportedPhotoFilenames(includeHidden:Bool = true, sharedDB:DatabaseWriter? = nil) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = ModelStore.sharedDBPool()
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
            let db = ModelStore.sharedDBPool()
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
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter("hidden != 1 AND exportTime is not null)").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
}
