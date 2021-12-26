//
//  ModelStore+Image+Duplicate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class ImageDuplicateDaoGRDB : ImageDuplicationDaoInterface {
    
    let logger = ConsoleLogger(category: "ImageDuplicateDaoGRDB")
    
    static var _duplicates:Duplicates? = nil
    
    func reloadDuplicatePhotos() {
        self.logger.log("Loading duplicate photos from db")
        
        let duplicates:Duplicates = Duplicates()
        var dupDates:Set<Date> = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            // try DatabaseQueue(path: dbfile)
            try db.read { db in
                let cursor = try Row.fetchCursor(db,
                                                 sql: """
SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate,place,photoCount FROM
(
    SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate,place,count(path) as photoCount FROM
    (
        SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate,place,path FROM IMAGE
        WHERE photoTakenDate LIKE '%.000'
        UNION
        SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate || '.000' ,place,path FROM IMAGE
        WHERE photoTakenDate IS NOT NULL AND photoTakenDate NOT LIKE '%.000'
    )
    GROUP BY photoTakenDate, place, photoTakenDay, photoTakenMonth, photoTakenYear
) WHERE photoCount > 1 ORDER BY photoTakenDate
"""
                )
                
                while let row = try cursor.next() {
                    
                    //let dup:Duplicate = Duplicate()
                    let year = row["photoTakenYear"] as Int
                    let month = row["photoTakenMonth"]  as Int
                    let day = row["photoTakenDay"]  as Int
                    let date = row["photoTakenDate"] as Date
                    //let place = row["place"] as! String? ?? ""
                    //dup.event = row["event"] as! String? ?? ""
                    //duplicates.duplicates.append(dup)
                    
                    let monthString = month < 10 ? "0\(month)" : "\(month)"
                    let dayString = day < 10 ? "0\(day)" : "\(day)"
                    let category:String = "\(year)年\(monthString)月\(dayString)日"
                    
                    duplicates.categories.insert(category)
                    
                    duplicates.years.insert(year)
                    duplicates.yearMonths.insert(year * 1000 + month)
                    duplicates.yearMonthDays.insert(year * 100000 + month * 100 + day)
                    
                    //self.logger.log("duplicated date: \(date)")
                    dupDates.insert(date)
                }
            }
        }catch{
            self.logger.log(error)
        }
        
        var firstPhotoInPlaceAndDate:[String:String] = [:]
        self.logger.log("Marking duplicate tag to photo files")
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                self.logger.log("duplicated date count: \(dupDates.count)")
                let marks = repeatElement("?", count: dupDates.count).joined(separator: ",")
                let sql = "SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate,place,path FROM Image WHERE photoTakenYear <> 0 AND photoTakenYear IS NOT NULL AND photoTakenDate in (\(marks))"
                //self.logger.log(sql)
                let photosInSameDate = try Row.fetchCursor(db, sql: sql, arguments:StatementArguments(dupDates))
                
                while let photo = try photosInSameDate.next() {
                    if let date = photo["photoTakenDate"] as Date? {
                        let year = Calendar.current.component(.year, from: date)
                        let month = Calendar.current.component(.month, from: date)
                        let day = Calendar.current.component(.day, from: date)
                        let hour = Calendar.current.component(.hour, from: date)
                        let minute = Calendar.current.component(.minute, from: date)
                        let second = Calendar.current.component(.second, from: date)
                        let key = "\(photo["place"] ?? "")_\(year)_\(month)_\(day)_\(hour)_\(minute)_\(second)"
                        //self.logger.log("duplicated record: \(key)")
                        let path = photo["path"] as String? ?? ""
                        if let first = firstPhotoInPlaceAndDate[key] {
                            // duplicates
                            duplicates.paths.insert(first)
                            duplicates.paths.insert(path)
                        }else{
                            firstPhotoInPlaceAndDate[key] = path
                        }
                        
                        // bi-direction mapping
                        duplicates.pathToKey[path] = key
                        if let _ = duplicates.keyToPath[key] {
                            duplicates.keyToPath[key]?.append(path)
                        }else{
                            duplicates.keyToPath[key] = [path]
                        }
                    }
                }
            }
            //            for key in duplicates.keyToPath.keys {
            //                self.logger.log("-------")
            //                self.logger.log("duplicated key: \(key)")
            //                for p in duplicates.keyToPath[key]! {
            //                    self.logger.log("duplicated path: \(p)")
            //                }
            //            }
        }catch{
            self.logger.log(error)
        }
        self.logger.log("Marking duplicate tag to photo files: DONE")
        
        ImageDuplicateDaoGRDB._duplicates = duplicates
        self.logger.log("Loading duplicate photos from db: DONE")
    }
    
    func getDuplicatePhotos(forceReload: Bool) -> Duplicates {
        if forceReload || ImageDuplicateDaoGRDB._duplicates == nil {
            reloadDuplicatePhotos()
        }
        return ImageDuplicateDaoGRDB._duplicates!
    }
    
    func getDuplicatePhotos() -> Duplicates {
        return self.getDuplicatePhotos(forceReload: false)
    }
    
    func getDuplicatedImages(repositoryRoot:String, theOtherRepositoryRoot:String) -> [String:[Image]] {
        var result:[String:[Image]] = [:]
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.read { db in
                let keyword = "\(repositoryRoot.withStash())%"
                let otherKeyword = "\(theOtherRepositoryRoot.withStash())%"
                let cursor = try Image.filter(sql: "(path like ? or path like ?) and duplicatesKey is not null and duplicatesKey != '' ", arguments:[keyword, otherKeyword]).order(sql: "duplicatesKey asc, path asc").fetchCursor(db)
                
                while let image = try cursor.next() {
                    if let key = image.duplicatesKey, key != "" {
                        //self.logger.log("found \(key) - \(image.path)")
                        if let _ = result[key] {
                            result[key]?.append(image)
                        }else{
                            result[key] = [image]
                        }
                    }
                }
            }
            
            
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func getChiefImageOfDuplicatedSet(duplicatesKey:String) -> Image?{
        var result:Image? = nil
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: "hidden=0 and duplicatesKey='\(duplicatesKey)'").fetchOne(db)
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func getFirstImageOfDuplicatedSet(duplicatesKey:String) -> Image?{
        var result:Image? = nil
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: "duplicatesKey='\(duplicatesKey)'").order(Column("path").asc).fetchOne(db)
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func markImageDuplicated(path:String, duplicatesKey:String?, hide:Bool){
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let _ = try db.write { db in
                try db.execute(sql: "update Image set duplicatesKey = ?, hidden = ? where path = ?", arguments: [duplicatesKey, hide, path])
            }
        }catch{
            self.logger.log(error)
        }
    }
}
