//
//  PostgresClientKit+Image+Duplicate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

class ImageDuplicateDaoPostgresCK : ImageDuplicationDaoInterface {
    
    static var _duplicates:Duplicates? = nil
    
    func reloadDuplicatePhotos() {
        let db = PostgresConnection.database()
        
        print("\(Date()) Loading duplicate photos from db")
        
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
        final class TempRecord : PostgresCustomRecord {
            var photoTakenYear: Int? = 0
            var photoTakenMonth: Int? = 0
            var photoTakenDay: Int? = 0
            var photoTakenDate: Date? = Date()
            var place:String? = ""
            var photoCount:Int = 0
            public init() {}
        }
        let records = TempRecord.fetchAll(db, sql: sql)
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
            
            //print("duplicated date: \(date)")
            dupDates.insert(date)
        }
        
        var firstPhotoInPlaceAndDate:[String:String] = [:]
        print("\(Date()) Marking duplicate tag to photo files")
        print("duplicated date count: \(dupDates.count)")
        var marks:[String] = []
//        var placeholders = 0
        for i in 1...dupDates.count {
            marks.append("$\(i)")
        }
        let sql2 = """
        SELECT "photoTakenYear","photoTakenMonth","photoTakenDay","photoTakenDate",place,path FROM "Image" WHERE "photoTakenYear" <> 0 AND "photoTakenYear" IS NOT NULL AND "photoTakenDate" in (\(marks.joined(separator: ",")))
        """
        
        final class TempRecord2 : PostgresCustomRecord {
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
        let photosInSameDate = TempRecord2.fetchAll(db, sql: sql2, values: dates)
        for photo in photosInSameDate {
            if let date = photo.photoTakenDate {
                let year = Calendar.current.component(.year, from: date)
                let month = Calendar.current.component(.month, from: date)
                let day = Calendar.current.component(.day, from: date)
                let hour = Calendar.current.component(.hour, from: date)
                let minute = Calendar.current.component(.minute, from: date)
                let second = Calendar.current.component(.second, from: date)
                let key = "\(photo.place ?? "")_\(year)_\(month)_\(day)_\(hour)_\(minute)_\(second)"
                //print("duplicated record: \(key)")
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
        print("\(Date()) Marking duplicate tag to photo files: DONE")
        
        ImageDuplicateDaoPostgresCK._duplicates = duplicates
        print("\(Date()) Loading duplicate photos from db: DONE")
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
        let keyword = "\(repositoryRoot.withStash())%"
        let otherKeyword = "\(theOtherRepositoryRoot.withStash())%"
        let records = Image.fetchAll(db, where: """
            (path like $1 or path like $2) and "duplicatesKey" is not null and "duplicatesKey" != ''
            """, orderBy: "\"duplicatesKey\" asc, path asc", values: [keyword, otherKeyword])
        for image in records {
            if let key = image.duplicatesKey, key != "" {
                //print("found \(key) - \(image.path)")
                if let _ = result[key] {
                    result[key]?.append(image)
                }else{
                    result[key] = [image]
                }
            }
        }
        return result
    }
    
    func getChiefImageOfDuplicatedSet(duplicatesKey: String) -> Image? {
        let db = PostgresConnection.database()
        return Image.fetchOne(db, where: "hidden=false and \"duplicatesKey\"='\(duplicatesKey)'")
    }
    
    func getFirstImageOfDuplicatedSet(duplicatesKey: String) -> Image? {
        let db = PostgresConnection.database()
        return Image.fetchOne(db, where: "\"duplicatesKey\"='\(duplicatesKey)'", orderBy: "path")
    }
    
    func markImageDuplicated(path: String, duplicatesKey: String?, hide: Bool) {
        let db = PostgresConnection.database()
        do{
            try db.execute(sql: "update \"Image\" set \"duplicatesKey\" = $1, hidden = $2 where path = $3", parameterValues: [duplicatesKey, hide, path])
        }catch{
            print("Error at markImageDuplicated")
            print(error)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ImageDB.NOTIFICATION_ERROR), object: error)
        }
    }
    

}
