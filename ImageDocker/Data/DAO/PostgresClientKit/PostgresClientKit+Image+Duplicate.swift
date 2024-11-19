//
//  PostgresClientKit+Image+Duplicate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory

class ImageDuplicateDaoPostgresCK : ImageDuplicationDaoInterface {
    
    static var _duplicates:Duplicates? = nil
    
    let logger = LoggerFactory.get(category: "DB", subCategory: "PostgresClientKit+Image+Duplicate")
    
    func reloadDuplicatePhotos() {
        let db = PostgresConnection.database()
        
        self.logger.log(.trace, "Loading duplicate photos from db")
        let startTime_loadDup = Date()
        
        let duplicates:Duplicates = Duplicates()
        var dupDates:Set<Date> = []
        
        let sql = """
        SELECT "photoTakenYear","photoTakenMonth","photoTakenDay","photoTakenDate",place,"photoCount" FROM
        (
            SELECT "photoTakenYear","photoTakenMonth","photoTakenDay","photoTakenDate",place,count(path) as "photoCount" FROM
            (
                SELECT "photoTakenYear","photoTakenMonth","photoTakenDay","photoTakenDate",place,path FROM "Image"
                WHERE "photoTakenDate" IS NOT NULL
            ) t1
            GROUP BY "photoTakenDate", place, "photoTakenDay", "photoTakenMonth", "photoTakenYear"
        ) t2 WHERE "photoCount" > 1 ORDER BY "photoTakenDate"
        """
        final class TempRecord : DatabaseRecord {
            var photoTakenYear: Int? = 0
            var photoTakenMonth: Int? = 0
            var photoTakenDay: Int? = 0
            var photoTakenDate: Date? = Date()
            var place:String? = ""
            var photoCount:Int = 0
            public init() {}
        }
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch {
            self.logger.log(.error, "Unable to query custom SQL: \(sql)", error)
        }
        
        for row in records {
            let year = row.photoTakenYear ?? 0
            let month = row.photoTakenMonth ?? 0
            let day = row.photoTakenDay ?? 0
            let date = row.photoTakenDate ?? Date()
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
            
            //self.logger.log(.trace, "duplicated date: \(date)")
            dupDates.insert(date)
        }
        
        var firstPhotoInPlaceAndDate:[String:String] = [:]
        let startTime_TagDup = Date()
        logger.log("Marking duplicate tag to photo files - START")
        logger.log("duplicated date count: \(dupDates.count)")
        var marks:[String] = []
//        var placeholders = 0
        for i in 1...dupDates.count {
            marks.append("$\(i)")
        }
        let sql2 = """
        SELECT "photoTakenYear","photoTakenMonth","photoTakenDay","photoTakenDate",place,path FROM "Image" WHERE "photoTakenYear" <> 0 AND "photoTakenYear" IS NOT NULL AND "photoTakenDate" in (\(marks.joined(separator: ",")))
        """
        
        final class TempRecord2 : DatabaseRecord {
            var photoTakenYear: Int? = 0
            var photoTakenMonth: Int? = 0
            var photoTakenDay: Int? = 0
            var photoTakenDate: Date? = nil
            var place:String? = ""
            var path:String = ""
            public init() {}
        }
        var dates:[Date] = []
        for dt in dupDates {
            dates.append(dt)
        }
        var photosInSameDate:[TempRecord2] = []
        do {
            photosInSameDate = try TempRecord2.fetchAll(db, sql: sql2, values: dates)
        }catch {
            self.logger.log(.error, "Unable to query custom SQL: \(sql2)", error)
        }
        for photo in photosInSameDate {
            if let date = photo.photoTakenDate {
                let year = Calendar.current.component(.year, from: date)
                let month = Calendar.current.component(.month, from: date)
                let day = Calendar.current.component(.day, from: date)
                let hour = Calendar.current.component(.hour, from: date)
                let minute = Calendar.current.component(.minute, from: date)
                let second = Calendar.current.component(.second, from: date)
                let key = "\(photo.place ?? "")_\(year)_\(month)_\(day)_\(hour)_\(minute)_\(second)"
                //self.logger.log(.trace, "duplicated record: \(key)")
                let path = photo.path
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
        logger.timecost("Marking duplicate tag to photo files: DONE", fromDate: startTime_TagDup)
        
        ImageDuplicateDaoPostgresCK._duplicates = duplicates
        logger.timecost("Loading duplicate photos from db: DONE", fromDate: startTime_loadDup)
    }
    
    func getDuplicatePhotos() -> Duplicates {
        return self.getDuplicatePhotos(forceReload: false)
    }
    
    func getDuplicatePhotos(forceReload:Bool) -> Duplicates {
        if forceReload || ImageDuplicateDaoPostgresCK._duplicates == nil {
            DispatchQueue.global().async {
                self.reloadDuplicatePhotos()
            }
        }
        if ImageDuplicateDaoPostgresCK._duplicates == nil {
            return Duplicates()
        }else{
            return ImageDuplicateDaoPostgresCK._duplicates!
        }
    }
    
    func getDuplicatedImages(repositoryRoot: String, theOtherRepositoryRoot: String) -> [String : [Image]] {
        let db = PostgresConnection.database()
        var result:[String:[Image]] = [:]
        let keyword = "\(repositoryRoot.withLastStash())%"
        let otherKeyword = "\(theOtherRepositoryRoot.withLastStash())%"
        do {
            let records = try Image.fetchAll(db, where: """
            (path like $1 or path like $2) and "duplicatesKey" is not null and "duplicatesKey" != ''
            """, orderBy: "\"duplicatesKey\" asc, path asc", values: [keyword, otherKeyword])
            for image in records {
                if let key = image.duplicatesKey, key != "" {
                    //self.logger.log(.trace, "found \(key) - \(image.path)")
                    if let _ = result[key] {
                        result[key]?.append(image)
                    }else{
                        result[key] = [image]
                    }
                }
            }
        }catch{
            self.logger.log(.error, "Unable to query images", error)
        }
        return result
    }
    
    func getDuplicatedImages(repositoryId:Int) -> [String : [Image]] {
        let db = PostgresConnection.database()
        var result:[String:[Image]] = [:]
        do {
            let records = try Image.fetchAll(db, where: """
                "repositoryId"=$1 and "duplicatesKey" is not null and "duplicatesKey" != ''
                """, orderBy: "\"duplicatesKey\" asc, path asc", values: [repositoryId])
            for image in records {
                if let key = image.duplicatesKey, key != "" {
                    //self.logger.log(.trace, "found \(key) - \(image.path)")
                    if let _ = result[key] {
                        result[key]?.append(image)
                    }else{
                        result[key] = [image]
                    }
                }
            }
        }catch{
            self.logger.log(.error, "Unable to query images", error)
        }
        return result
    }
    
    func getChiefImageOfDuplicatedSet(duplicatesKey: String) -> Image? {
        let db = PostgresConnection.database()
        do {
            return try Image.fetchOne(db, where: "hidden=false and \"duplicatesKey\"='\(duplicatesKey)'")
        }catch{
            self.logger.log(.error, "Unable to query images", error)
            return nil
        }
    }
    
    func getFirstImageOfDuplicatedSet(duplicatesKey: String) -> Image? {
        let db = PostgresConnection.database()
        do {
            return try Image.fetchOne(db, where: "\"duplicatesKey\"='\(duplicatesKey)'", orderBy: "path")
        }catch{
            self.logger.log(.error, "Unable to query images", error)
            return nil
        }
    }
    
    func markImageDuplicated(path: String, duplicatesKey: String?, hide: Bool) {
        let db = PostgresConnection.database()
        do{
            try db.execute(sql: "update \"Image\" set \"duplicatesKey\" = $1, hidden = $2 where path = $3", parameterValues: [duplicatesKey, hide, path])
        }catch{
            logger.log("Error at markImageDuplicated")
            logger.log(error)
            let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageDuplicateDaoPostgresCK", name: "markImageDuplicated", message: "\(error)")
        }
    }
    

}
