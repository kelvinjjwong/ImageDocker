//
//  ModelStore+Image.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStore {
    func reloadDuplicatePhotos() {
        print("\(Date()) Loading duplicate photos from db")
        
        let duplicates:Duplicates = Duplicates()
        var dupDates:Set<Date> = []
        do {
            let db = ModelStore.sharedDBPool()
            // try DatabaseQueue(path: dbfile)
            try db.read { db in
                let cursor = try Row.fetchCursor(db,
                                                 """
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
                    
                    //print("duplicated date: \(date)")
                    dupDates.insert(date)
                }
            }
        }catch{
            print(error)
        }
        
        var firstPhotoInPlaceAndDate:[String:String] = [:]
        print("\(Date()) Marking duplicate tag to photo files")
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                print("duplicated date count: \(dupDates.count)")
                let marks = repeatElement("?", count: dupDates.count).joined(separator: ",")
                let sql = "SELECT photoTakenYear,photoTakenMonth,photoTakenDay,photoTakenDate,place,path FROM Image WHERE photoTakenYear <> 0 AND photoTakenYear IS NOT NULL AND photoTakenDate in (\(marks))"
                //print(sql)
                let photosInSameDate = try Row.fetchCursor(db, sql, arguments:StatementArguments(dupDates))
                
                while let photo = try photosInSameDate.next() {
                    if let date = photo["photoTakenDate"] as Date? {
                        let year = Calendar.current.component(.year, from: date)
                        let month = Calendar.current.component(.month, from: date)
                        let day = Calendar.current.component(.day, from: date)
                        let hour = Calendar.current.component(.hour, from: date)
                        let minute = Calendar.current.component(.minute, from: date)
                        let second = Calendar.current.component(.second, from: date)
                        let key = "\(photo["place"] ?? "")_\(year)_\(month)_\(day)_\(hour)_\(minute)_\(second)"
                        //print("duplicated record: \(key)")
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
            //                print("-------")
            //                print("duplicated key: \(key)")
            //                for p in duplicates.keyToPath[key]! {
            //                    print("duplicated path: \(p)")
            //                }
            //            }
        }catch{
            print(error)
        }
        print("\(Date()) Marking duplicate tag to photo files: DONE")
        
        _duplicates = duplicates
        print("\(Date()) Loading duplicate photos from db: DONE")
    }
    
    func getDuplicatePhotos() -> Duplicates {
        if _duplicates == nil {
            reloadDuplicatePhotos()
        }
        return _duplicates!
    }
    
    // MARK: - IMAGES
    
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String? = nil, sharedDB:DatabaseWriter? = nil) -> Image{
        var image:Image?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                image = try Image.fetchOne(db, key: path)
            }
            if image == nil {
                let queue = try sharedDB ?? DatabaseQueue(path: dbfile)
                try queue.write { db in
                    image = Image.new(filename: filename, path: path, parentFolder: parentPath, repositoryPath: repositoryPath ?? "")
                    try image?.save(db)
                }
                
            }
        }catch{
            print(error)
        }
        return image!
    }
    
    func getImage(path:String) -> Image?{
        var image:Image?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                image = try Image.fetchOne(db, key: path)
            }
        }catch{
            print(error)
        }
        return image
    }
    
    func getImage(id:String) -> Image? {
        var image:Image?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                image = try Image.filter(sql: "id='\(id)'").fetchOne(db)
            }
        }catch{
            print(error)
        }
        return image
    }
    
    func saveImage(image: Image, sharedDB:DatabaseWriter? = nil) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                var image = image
                try image.save(db)
                //print("saved image")
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func updateImagePaths(oldPath:String, newPath:String, repositoryPath:String, subPath:String, containerPath:String, id:String) -> ExecuteState {
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set path = ?, repositoryPath = ?, subPath = ?, containerPath = ?, id = ? where path = ?", arguments: [newPath, repositoryPath, subPath, containerPath, id, oldPath])
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    
    
    func deletePhoto(atPath path:String, updateFlag:Bool = true) -> ExecuteState{
        if updateFlag {
            do {
                let db = ModelStore.sharedDBPool()
                let _ = try db.write { db in
                    try db.execute("update Image set delFlag = ?", arguments: [true])
                }
            }catch{
                return self.errorState(error)
            }
            return .OK
        }else{
            do {
                let db = ModelStore.sharedDBPool()
                let _ = try db.write { db in
                    try Image.deleteOne(db, key: path)
                }
            }catch{
                return self.errorState(error)
            }
            return .OK
        }
    }
    
    // MARK: IMAGES GET BY TREE
    
    func getAllDates(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Row] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = """
        SELECT photoTakenYear, photoTakenMonth, photoTakenDay, count(path) as photoCount FROM
        (SELECT IFNULL(photoTakenYear,0) AS photoTakenYear, IFNULL(photoTakenMonth,0) AS photoTakenMonth, IFNULL(photoTakenDay,0) AS photoTakenDay, path, imageSource, cameraModel from Image)
        WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY photoTakenYear,photoTakenMonth,photoTakenDay ORDER BY photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC
        """
        print(sql)
        var result:[Row] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql, arguments:StatementArguments(sqlArgs))
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getAllPlacesAndDates(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Row] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = """
        SELECT country, province, city, place, photoTakenYear, photoTakenMonth, photoTakenDay, count(path) as photoCount FROM
        (
        SELECT country, province, city, place, photoTakenYear, photoTakenMonth, photoTakenDay, path, imageSource,cameraModel from Image WHERE assignCountry is null and assignProvince is null and assignCity is null
        UNION
        SELECT assignCountry as country, assignProvince as province, assignCity as city, assignPlace as place, photoTakenYear, photoTakenMonth, photoTakenDay, path, imageSource,cameraModel from Image WHERE assignCountry is not null and assignProvince is not null and assignCity is not null
        )
        WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere)
        GROUP BY country,province,city,place,photoTakenYear,photoTakenMonth,photoTakenDay ORDER BY country,province,city,place,photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC
        """
        
        print(sql)
        var result:[Row] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql, arguments:StatementArguments(sqlArgs))
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    // MARK: IMAGES GET BY COLLECTION
    
    // sql by date & place
    private func generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> (String, String, [Any]) {
        
        print("\(year) | \(month) | \(day) | ignoreDate:\(ignoreDate) | \(country) | \(province) | \(city)")
        
        var hiddenWhere = ""
        if !includeHidden {
            hiddenWhere = "AND hidden=0"
        }
        var placeWhere = ""
        if (place == nil || place == ""){
            if country != "" {
                placeWhere += " AND (country = '\(country)' OR assignCountry = '\(country)')"
            }
            if province != "" {
                placeWhere += " AND (province = '\(province)' OR assignProvince = '\(province)')"
            }
            if city != "" {
                placeWhere += " AND (city = '\(city)' OR assignCity = '\(city)')"
            }
        }else {
            placeWhere = "AND (place = '\(place ?? "")' OR assignPlace = '\(place ?? "")') "
        }
        
        
        var stmtWithoutHiddenWhere = ""
        
        if year == 0 && month == 0 && day == 0 {
            if ignoreDate {
                stmtWithoutHiddenWhere = "1=1 \(placeWhere)"
            }else{
                stmtWithoutHiddenWhere = "( (photoTakenYear = 0 and photoTakenMonth = 0 and photoTakenDay = 0) OR (photoTakenYear is null and photoTakenMonth is null and photoTakenDay is null) ) \(placeWhere)"
            }
        }else{
            if year == 0 {
                // no condition
            } else if month == 0 {
                stmtWithoutHiddenWhere = "photoTakenYear = \(year) \(placeWhere) \(hiddenWhere)"
            } else if day == 0 {
                stmtWithoutHiddenWhere = "photoTakenYear = \(year) and photoTakenMonth = \(month) \(placeWhere)"
            } else {
                stmtWithoutHiddenWhere = "photoTakenYear = \(year) and photoTakenMonth = \(month) and photoTakenDay = \(day) \(placeWhere)"
            }
        }
        
        var sqlArgs:[Any] = []
        
        self.inArray(field: "imageSource", array: imageSource, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        self.inArray(field: "cameraModel", array: cameraModel, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=1"
        
        print(stmt)
        
        return (stmt, stmtHidden, sqlArgs)
    }
    
    // count by date & place
    func countPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (stmt, _, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs)).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // count by date & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (_, stmtHidden, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmtHidden, arguments:StatementArguments(sqlArgs)).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
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
    
    // sql by date & event & place
    private func generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> (String, String, [Any]) {
        
        print("\(year) | \(month) | \(day) | event:\(event) | \(country) | \(province) | \(city)")
        
        var hiddenWhere = ""
        if !includeHidden {
            hiddenWhere = "AND hidden=0"
        }
        var stmtWithoutHiddenWhere = ""
        
        if year == 0 {
            stmtWithoutHiddenWhere = "event = '\(event)' \(hiddenWhere)"
        } else if day == 0 {
            stmtWithoutHiddenWhere = "event = '\(event)' and photoTakenYear = \(year) and photoTakenMonth = \(month) \(hiddenWhere)"
        } else {
            stmtWithoutHiddenWhere = "event = '\(event)' and photoTakenYear = \(year) and photoTakenMonth = \(month) and photoTakenDay = \(day) \(hiddenWhere)"
        }
        
        var sqlArgs:[Any] = []
        
        self.inArray(field: "imageSource", array: imageSource, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        self.inArray(field: "cameraModel", array: cameraModel, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=1"
        
        print(stmt)
        
        return (stmt, stmtHidden, sqlArgs)
    }
    
    
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
    
    // search sql by date & event & place
    func generateSQLStatementForSearchingPhotoFiles(years:[Int], months:[Int], days:[Int], peopleIds:[String], keywords:[String], includeHidden:Bool = true) -> (String, String) {
        
        var hiddenFlagStatement = ""
        if !includeHidden {
            hiddenFlagStatement = "AND hidden=0 AND hiddenByRepository=0 AND hiddenByContainer=0"
        }
        let hiddenStatement = "AND (hidden=1 OR hiddenByRepository=1 OR hiddenByContainer=1)"
        
        let yearStatement = self.joinArrayToStatementCondition(values: years, field: "photoTakenYear")
        let monthStatement = self.joinArrayToStatementCondition(values: months, field: "photoTakenMonth")
        let dayStatement = self.joinArrayToStatementCondition(values: days, field: "photoTakenDay")
        
        let dateStatement = self.joinStatementConditions(conditions: [yearStatement, monthStatement, dayStatement])
        
        let peopleIdStatement = self.joinArrayToStatementCondition(values: peopleIds, field: "recognizedPeopleIds", like: true)
        
        let eventStatement = self.joinArrayToStatementCondition(values: keywords, field: "event", like: true)
        let longDescStatement = self.joinArrayToStatementCondition(values: keywords, field: "longDescription", like: true)
        let shortDescStatement = self.joinArrayToStatementCondition(values: keywords, field: "shortDescription", like: true)
        
        let placeStatement = self.joinArrayToStatementCondition(values: keywords, field: "place", like: true)
        let countryStatement = self.joinArrayToStatementCondition(values: keywords, field: "country", like: true)
        let provinceStatement = self.joinArrayToStatementCondition(values: keywords, field: "province", like: true)
        let cityStatement = self.joinArrayToStatementCondition(values: keywords, field: "city", like: true)
        let districtStatement = self.joinArrayToStatementCondition(values: keywords, field: "district", like: true)
        let businessCircleStatement = self.joinArrayToStatementCondition(values: keywords, field: "businessCircle", like: true)
        let streetStatement = self.joinArrayToStatementCondition(values: keywords, field: "street", like: true)
        let addressStatement = self.joinArrayToStatementCondition(values: keywords, field: "address", like: true)
        let addressDescStatement = self.joinArrayToStatementCondition(values: keywords, field: "addressDescription", like: true)
        
        let assignPlaceStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignPlace", like: true)
        let assignCountryStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignCountry", like: true)
        let assignProvinceStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignProvince", like: true)
        let assignCityStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignCity", like: true)
        let assignDistrictStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignDistrict", like: true)
        let assignBusinessCircleStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignBusinessCircle", like: true)
        let assignStreetStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignStreet", like: true)
        let assignAddressStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignAddress", like: true)
        let assignAddressDescStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignAddressDescription", like: true)
        
        let keywordStatement = self.joinStatementConditions(conditions: [
            eventStatement,
            shortDescStatement,
            longDescStatement,
            
            placeStatement,
            countryStatement,
            provinceStatement,
            cityStatement,
            districtStatement,
            businessCircleStatement,
            streetStatement,
            addressStatement,
            addressDescStatement,
            
            assignPlaceStatement,
            assignCountryStatement,
            assignProvinceStatement,
            assignCityStatement,
            assignDistrictStatement,
            assignBusinessCircleStatement,
            assignStreetStatement,
            assignAddressStatement,
            assignAddressDescStatement,
            
            ], or: true)
        
        let stmtWithoutHiddenFlag = self.joinStatementConditions(conditions: [dateStatement, peopleIdStatement, keywordStatement])
        
        let stmt = "\(stmtWithoutHiddenFlag) \(hiddenFlagStatement)"
        let stmtHidden = "\(stmtWithoutHiddenFlag) \(hiddenStatement)"
        
        print("------")
        print(stmt)
        print("------")
        
        return (stmt, stmtHidden)
    }
    
    // count by date & event & place
    func countPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (stmt, _, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs)).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // count by date & event & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (_, stmtHidden, sqlArgs) = self.generateSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmtHidden, arguments:StatementArguments(sqlArgs)).fetchCount(db)
            }
        }catch{
            print(error)
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
    
    // MARK: IMAGES GET BY CONDITIONS
    
    func getYears(event:String? = nil) -> [Int] {
        var condition = ""
        var args:[String] = []
        if let ev = event {
            condition = " where event=? "
            args.append(ev)
        }
        let sql = "select distinct photoTakenYear from image \(condition) order by photoTakenYear desc"
        
        var result:[Int] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql, arguments:StatementArguments(args))
                for row in rows {
                    let year = row["photoTakenYear"] as Int? ?? 0
                    result.append(year)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getDatesByYear(year:Int, event:String? = nil) -> [String:[String]] {
        var sql = "select distinct photoTakenMonth,photoTakenDay from image where photoTakenYear=? order by photoTakenMonth,photoTakenDay"
        var args:[Any] = [year]
        
        if let ev = event, ev != "" {
            sql = "select distinct photoTakenMonth,photoTakenDay from image where photoTakenYear=? and event=? order by photoTakenMonth,photoTakenDay"
            args.append(ev)
        }
        
        //print(sql)
        var result:[String:[String]] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql, arguments:StatementArguments(args))
                for row in rows {
                    let month = row["photoTakenMonth"] as Int? ?? 0
                    let day = row["photoTakenDay"] as Int? ?? 0
                    if result["\(month)"] == nil {
                        result["\(month)"] = []
                    }
                    result["\(month)"]?.append("\(day)")
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
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
    
    func getPhotoFilesWithoutExif(limit:Int? = nil) -> [Image] {
        var result:[Image] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "hidden != 1 AND (updateExifDate is null OR photoTakenYear is null OR photoTakenYear = 0 OR (latitude <> '0.0' AND latitudeBD = '0.0') OR (latitudeBD <> '0.0' AND COUNTRY = ''))").order([Column("photoTakenDate").asc, Column("filename").asc]).fetchAll(db)
                // TODO: OR updateLocationDate is null
            }
        }catch{
            print(error)
        }
        return result
    }
    
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
    
    // MARK: IMAGES DUPLICATES
    
    func getDuplicatedImages(repositoryRoot:String, theOtherRepositoryRoot:String) -> [String:[Image]] {
        var result:[String:[Image]] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                let keyword = "\(repositoryRoot.withStash())%"
                let otherKeyword = "\(theOtherRepositoryRoot.withStash())%"
                let cursor = try Image.filter(sql: "(path like ? or path like ?) and duplicatesKey is not null and duplicatesKey != '' ", arguments:[keyword, otherKeyword]).order(sql: "duplicatesKey asc, path asc").fetchCursor(db)
                
                while let image = try cursor.next() {
                    if let key = image.duplicatesKey, key != "" {
                        //print("found \(key) - \(image.path)")
                        if let _ = result[key] {
                            result[key]?.append(image)
                        }else{
                            result[key] = [image]
                        }
                    }
                }
            }
            
            
        }catch{
            print(error)
        }
        return result
    }
    
    func getChiefImageOfDuplicatedSet(duplicatesKey:String) -> Image?{
        var result:Image? = nil
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: "hidden=0 and duplicatesKey='\(duplicatesKey)'").fetchOne(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getFirstImageOfDuplicatedSet(duplicatesKey:String) -> Image?{
        var result:Image? = nil
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.read { db in
                result = try Image.filter(sql: "duplicatesKey='\(duplicatesKey)'").order(Column("path").asc).fetchOne(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func markImageDuplicated(path:String, duplicatesKey:String?, hide:Bool){
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set duplicatesKey = ?, hidden = ? where path = ?", arguments: [duplicatesKey, hide, path])
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: IMAGES COUNT
    
    func countImageWithoutFace(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath=? and hidden=0 and id not in (select distinct imageid from imageface)", arguments:[root]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func countImageNotYetFacialDetection(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath=? and hidden=0 and scanedFace<>1 and id not in (select distinct imageid from imageface)", arguments:[root]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
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
    
    // count by path~
    func countPhotoFiles(rootPath:String) -> Int {
        var result:Int = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(Column("path").like("\(rootPath)%")).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    
    func countImageWithoutRepositoryPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "repositoryPath='' and path like ?", arguments:[keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImageWithoutSubPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "subPath='' and path like ?", arguments:[keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImageWithoutId(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "id is null and path like ?", arguments:[keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImageUnmatchedRepositoryRoot(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "repositoryPath = ? and path not like ?", arguments: [root, keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImages(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "path like ?", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countHiddenImages(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "path like ? and hidden = 1", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countContainersWithoutRepositoryPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try ImageContainer.filter(sql: "repositoryPath = '' and path like ?", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countContainersWithoutSubPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try ImageContainer.filter(sql: "subPath = '' and path like ?", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    // MARK: IMAGES - UPDATES
    
    func updateImageRawBase(oldRawPath:String, newRawPath:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set originPath = ? where originPath = ?", arguments: [newRawPath, oldRawPath])
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func updateImageRawBase(repositoryPath:String, rawPath:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set originPath = ? where repositoryPath = ?", arguments: [rawPath, repositoryPath])
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func updateImageRawBase(pathStartsWith path:String, rawPath:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set originPath = ? where path like ?", arguments: [rawPath, "\(path.withStash())%"])
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func updateImageRepositoryBase(pathStartsWith path:String, repositoryPath:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set repositoryPath = ? where path like ?", arguments: [repositoryPath, "\(path.withStash())%"])
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func updateImageRepositoryBase(oldRepositoryPath:String, newRepository:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set repositoryPath = ? where repositoryPath = ?", arguments: [newRepository, oldRepositoryPath])
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func updateImagePath(repositoryPath:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set path = repositoryPath || subPath where repositoryPath = ? and subPath <> ''", arguments: [repositoryPath])
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func updateImageScannedFace(imageId:String, facesCount:Int = 0) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set scanedFace=1, facesCount=? where id=?", arguments: [facesCount, imageId])
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func updateImageRecognizedFace(imageId:String, recognizedPeopleIds:String = "") -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            let _ = try db.write { db in
                try db.execute("update Image set recognizedFace=1,recognizedPeopleIds=? where id=?", arguments: [recognizedPeopleIds,imageId])
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func updateImageDates(path:String, date:Date, fields:Set<String>) -> ExecuteState{
        var arguments:[Any] = []
        var values:[String] = []
        for field in fields {
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
        values.append("photoTakenDate = ?, photoTakenYear = ?, photoTakenMonth = ?, photoTakenDay = ?")
        arguments.append(date)
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        arguments.append(year)
        arguments.append(month)
        arguments.append(day)
        arguments.append(path)
        let valueSets = values.joined(separator: ",")
        
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set \(valueSets) WHERE path=?", arguments: StatementArguments(arguments))
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    // MARK: IMAGES - EXPORT
    
    func countAllPhotoFilesForExporting(after date:Date) -> Int {
        var result = 0
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "hidden != 1 AND photoTakenYear <> 0 AND photoTakenYear IS NOT NULL AND (updateDateTimeDate > ? OR updateExifDate > ? OR updateLocationDate > ? OR updateEventDate > ? OR exportTime is null)", arguments:StatementArguments([date, date, date, date])).fetchCount(db)
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
    
    func cleanImageExportTime(path:String) -> ExecuteState {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportTime = null WHERE path='\(path)'")
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func storeImageOriginalMD5(path:String, md5:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set originalMD5 = ? WHERE path=?", arguments: StatementArguments([md5, path]))
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func storeImageExportedMD5(path:String, md5:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportedMD5 = ? WHERE path=?", arguments: StatementArguments([md5, path]))
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func storeImageDescription(path:String, shortDescription:String?, longDescription:String?) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                if let brief = shortDescription, let detailed = longDescription {
                    try db.execute("UPDATE Image set shortDescription = ?, longDescription = ? WHERE path=?", arguments: StatementArguments([brief, detailed, path]))
                }else if let brief = shortDescription {
                    try db.execute("UPDATE Image set shortDescription = ? WHERE path=?", arguments: StatementArguments([brief, path]))
                }else if let detailed = longDescription {
                    try db.execute("UPDATE Image set longDescription = ? WHERE path=?", arguments: StatementArguments([detailed, path]))
                }
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func storeImageExportSuccess(path:String, date:Date, exportToPath:String, exportedFilename:String, exportedMD5:String, exportedLongDescription:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportTime = ?, exportToPath = ?, exportAsFilename = ?, exportedMD5 = ?, exportedLongDescription = ?, exportState = 'OK', exportFailMessage = '' WHERE path=?", arguments: StatementArguments([date, exportToPath, exportedFilename, exportedMD5, exportedLongDescription, path]))
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func storeImageExportedTime(path:String, date:Date) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportTime = ? WHERE path=?", arguments: StatementArguments([date, path]))
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func storeImageExportFail(path:String, date:Date, message:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportTime = ?, exportState = 'FAIL', exportFailMessage = ? WHERE path=?", arguments: StatementArguments([date, message, path]))
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    func cleanImageExportPath(path:String) -> ExecuteState {
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try db.execute("UPDATE Image set exportToPath = null, exportAsFilename = null, exportTime = null, exportState = null, exportFailMessage = '', exportedMD5 = null, WHERE path=?", arguments: StatementArguments([path]))
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
        
    }
}
