//
//  ModelStore+Image+Search.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class ImageSearchDaoGRDB : ImageSearchDaoInterface {
    
    
    
    // MARK: - COLLECTION
    
    // get by date & place
    func getPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        
        print("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden, sqlArgs) = SQLHelper.generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        print(stmt)
        print(stmtHidden)
        
        var result:[Image] = []
        var hiddenCount:Int = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                hiddenCount = try Image.filter(sql: stmtHidden, arguments:StatementArguments(sqlArgs) ?? []).fetchCount(db)
                if pageNumber > 0 && pageSize > 0 {
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs) ?? [])
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .limit(pageSize, offset: pageSize * (pageNumber - 1))
                        .fetchAll(db)
                }else{
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs) ?? [])
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
        print("loaded \(result.count) records")
        return result
    }
    
    // get by date & event & place
    func getPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        
        print("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden, sqlArgs) = SQLHelper.generateSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result:[Image] = []
        var hiddenCount:Int = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                hiddenCount = try Image.filter(sql: stmtHidden, arguments:StatementArguments(sqlArgs) ?? []).fetchCount(db)
                if pageNumber > 0 && pageSize > 0 {
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs) ?? [])
                        .order([Column("photoTakenDate").asc, Column("filename").asc])
                        .limit(pageSize, offset: pageSize * (pageNumber - 1))
                        .fetchAll(db)
                }else{
                    result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs) ?? [])
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
        let (stmt, stmtHidden) = SQLHelper.generateSQLStatementForSearchingPhotoFiles(years: years, months: months, days: days, peopleIds: peopleIds, keywords: keywords, includeHidden:includeHidden)
        
        var result:[Image] = []
        var hiddenCount:Int = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: "hidden=0 and photoTakenYear=\(year) and photoTakenMonth=\(month) and photoTakenDay=\(day) and photoTakenHour=\(hour)").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getMaxPhotoTakenYear() -> Int {
        let sql = "select distinct max(photoTakenYear) photoTakenYear from image where hidden=0"
        
        var result:Int = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    result = rows[0]["photoTakenYear"] as Int? ?? 0
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getMinPhotoTakenYear() -> Int {
        let sql = "select distinct min(photoTakenYear) photoTakenYear from image where hidden=0"
        
        var result:Int = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    result = rows[0]["photoTakenYear"] as Int? ?? 0
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getSqlByTodayInPrevious() -> String {
        let max = self.getMaxPhotoTakenYear()
        let min = self.getMinPhotoTakenYear()
        var sql = ""
        var k = 0
        for i in min..<max {
            k += 1
            sql += "DATE('now', 'localtime', '-\(k) year'), DATE('now', 'localtime', '-\(k) year', '-1 day'), DATE('now', 'localtime', '-\(k) year', '-2 day'), DATE('now', 'localtime', '-\(k) year', '+1 day'), DATE('now', 'localtime', '-\(k) year', '+2 day')"
            if i+1 != max {
                sql += ","
            }
        }
        return sql
    }
    
    func getYearsByTodayInPrevious() -> [Int]{
        var sql = "select distinct photoTakenYear from image where hidden=0 and DATE(phototakendate) IN ("
        sql += self.getSqlByTodayInPrevious()
        sql += ") order by photoTakenYear desc"
        
        var result:[Int] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        result.append(row["photoTakenYear"] as Int? ?? 0)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getDatesAroundToday() -> [String] {
        let sql = """
select DATE('now', 'localtime', '-1 day') date union
select DATE('now', 'localtime', '-2 day') date union
select DATE('now', 'localtime', '+1 day') date union
select DATE('now', 'localtime', '+2 day') date union
select DATE('now', 'localtime')  date
"""
        var result:[String] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        if let date = row["date"] as String? {
                            result.append(date)
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getDatesByTodayInPrevious(year:Int) -> [String]{
        let now = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: now)
        let k = currentYear - year
        
        var sql = "select distinct DATE(photoTakenDate) as photoTakenDate from image where hidden=0 and DATE(phototakendate) IN ("
        sql += "DATE('now', 'localtime', '-\(k) year'), DATE('now', 'localtime', '-\(k) year', '-1 day'), DATE('now', 'localtime', '-\(k) year', '-2 day'), DATE('now', 'localtime', '-\(k) year', '+1 day'), DATE('now', 'localtime', '-\(k) year', '+2 day')"
        sql += ") order by DATE(photoTakenDate) desc"
        print(sql)
        
        var result:[String] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        if let date = row["photoTakenDate"] as String? {
                            result.append(date)
                        }
                    }
                }
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "hidden != 1 AND cameraMaker is null and (lastTimeExtractExif = 0 or updateExifDate is null OR photoTakenYear is null OR photoTakenYear = 0 OR (latitude <> '0.0' AND latitudeBD = '0.0') OR (latitudeBD <> '0.0' AND COUNTRY = ''))").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath=? and hidden=0 \(scannedCondition) and id not in (select distinct imageid from imageface)", arguments:[root]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - PATH
    
    func getAllPhotoPaths(includeHidden:Bool = true) -> Set<String> {
        var result:Set<String> = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(Column("path").like("\(rootPath.withStash())%")).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - EXPORT
    
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
}
