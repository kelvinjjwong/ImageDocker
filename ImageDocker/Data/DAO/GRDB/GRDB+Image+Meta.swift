//
//  ModelStore+Image+Meta.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStoreGRDB {
    
    // MARK: - Options
    
    func getImageSources() -> [String:Bool]{
        var results:[String:Bool] = [:]
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT DISTINCT imageSource FROM Image")
                for row in rows {
                    let src = row["imageSource"] as String?
                    if let src = src, src != "" {
                        results[src] = false
                    }
                }
            }
        }catch{
            print(error)
        }
        
        return results
    }
    
    func getCameraModel() -> [String:Bool] {
        var results:[String:Bool] = [:]
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT DISTINCT cameraMaker,cameraModel FROM Image")
                for row in rows {
                    let name1:String = row["cameraMaker"] ?? ""
                    let name2:String = row["cameraModel"] ?? ""
                    if name1 != "" && name2 != "" {
                        results["\(name1),\(name2)"] = false
                    }
                }
            }
        }catch{
            print(error)
        }
        
        return results
    }
    
    // MARK: - DATE
    
    
    
    func getMoments(_ condition:MomentCondition, year:Int = 0, month:Int = 0) -> [Moment] {
        var fields = ""
        var arguments = ""
        
        if condition == .YEAR {
            fields = "photoTakenYear"
        }else if condition == .MONTH {
            fields = "photoTakenYear, photoTakenMonth"
            arguments = "AND photoTakenYear=\(year)"
        }else if condition == .DAY {
            fields = "photoTakenYear, photoTakenMonth, photoTakenDay"
            arguments = "AND photoTakenYear=\(year) AND photoTakenMonth=\(month)"
        }
        
        let sql = """
        SELECT count(path) as photoCount, \(fields)  FROM
        (SELECT IFNULL(photoTakenYear,0) AS photoTakenYear, IFNULL(photoTakenMonth,0) AS photoTakenMonth, IFNULL(photoTakenDay,0) AS photoTakenDay, path, imageSource, cameraModel from Image)
        WHERE 1=1 \(arguments) GROUP BY \(fields) ORDER BY \(fields) DESC
        """
        print(sql)
        var result:[Moment] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql)
                for row in rows {
                    
                    var yy = 0
                    var mm = 0
                    var dd = 0
                    var cc = 0
                    if let c = Int("\(row[0] ?? 0)") {
                        cc = c
                    }
                    if row.count >= 2, let y = Int("\(row[1] ?? 0)") {
                        yy = y
                    }
                    if row.count >= 3, let m = Int("\(row[2] ?? 0)") {
                        mm = m
                    }
                    if row.count >= 4, let d = Int("\(row[3] ?? 0)") {
                        dd = d
                    }
                    let collection = Moment(.MOMENTS, imageCount: cc, year: yy, month: mm, day: dd)
                    result.append(collection)
                }
                
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getAllDates(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Row] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        ModelStore.inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        ModelStore.inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = """
        SELECT photoTakenYear, photoTakenMonth, photoTakenDay, count(path) as photoCount FROM
        (SELECT IFNULL(photoTakenYear,0) AS photoTakenYear, IFNULL(photoTakenMonth,0) AS photoTakenMonth, IFNULL(photoTakenDay,0) AS photoTakenDay, path, imageSource, cameraModel from Image)
        WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY photoTakenYear,photoTakenMonth,photoTakenDay ORDER BY photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC
        """
        print(sql)
        var result:[Row] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql, arguments:StatementArguments(sqlArgs))
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func appendSqlTextCondition(_ column:String, value:String?, where statement:inout String, args arguments:inout [String]) {
        if value == nil || value == "" {
            statement = "\(statement) AND (\(column)='' OR \(column) IS NULL)"
        }else{
            statement = "\(statement) AND \(column)=?"
            arguments.append(value!)
        }
    }
    
    func appendSqlIntegerCondition(_ column:String, value:Int?, where statement:inout String) {
        if value == nil || value == 0 {
            statement = "\(statement) AND (\(column)=0 OR \(column) IS NULL)"
        }else{
            statement = "\(statement) AND \(column)=\(value ?? 0)"
        }
    }
    
    func getMomentsByPlace(_ condition:MomentCondition, parent:Moment? = nil) -> [Moment] {
        var fields = ""
        var whereStmt = ""
        var order = ""
        var argumentValues:[String] = []
        
        if condition == .PLACE {
            fields = "country, province, city, place"
        }else if condition == .YEAR {
            fields = "country, province, city, place, photoTakenYear"
            if let p = parent {
                self.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues)
            }
            order = "DESC"
        }else if condition == .MONTH {
            fields = "country, province, city, place, photoTakenYear, photoTakenMonth"
            if let p = parent {
                self.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues)
                self.appendSqlIntegerCondition("photoTakenYear", value: p.year, where: &whereStmt)
            }
            order = "DESC"
        }else if condition == .DAY {
            fields = "country, province, city, place, photoTakenYear, photoTakenMonth, photoTakenDay"
            if let p = parent {
                self.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues)
                self.appendSqlIntegerCondition("photoTakenYear", value: p.year, where: &whereStmt)
                self.appendSqlIntegerCondition("photoTakenMonth", value: p.month, where: &whereStmt)
            }
            order = "DESC"
        }
        
        let sql = """
        SELECT count(path), \(fields) FROM
        (
        SELECT ifnull(country, '') as country, ifnull(province, '') as province, ifnull(city, '') as city, place, photoTakenYear, photoTakenMonth, photoTakenDay, path, imageSource,cameraModel from Image WHERE assignCountry is null and assignProvince is null and assignCity is null
        UNION
        SELECT assignCountry as country, assignProvince as province, assignCity as city, assignPlace as place, photoTakenYear, photoTakenMonth, photoTakenDay, path, imageSource,cameraModel from Image WHERE assignCountry is not null and assignProvince is not null and assignCity is not null
        )
        WHERE 1=1 \(whereStmt)
        GROUP BY \(fields) ORDER BY \(fields) \(order)
        """
        print(sql)
        print("SQL values: \(argumentValues)")
        var result:[Moment] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql, arguments:StatementArguments(argumentValues))
                for row in rows {
                    var country = ""
                    var province = ""
                    var city = ""
                    var place = ""
                    var year = 0
                    var month = 0
                    var day = 0
                    var count = 0
                    if let c = Int("\(row[0] ?? 0)") {
                        count = c
                    }
                    if let c = row[1] {
                        country = "\(c)"
                    }
                    if let c = row[2] {
                        province = "\(c)"
                    }
                    if let c = row[3] {
                        city = "\(c)"
                    }
                    if let c = row[4] {
                        place = "\(c)"
                    }
                    if row.count >= 6, let y = Int("\(row[5] ?? 0)") {
                        year = y
                    }
                    if row.count >= 7, let m = Int("\(row[6] ?? 0)") {
                        month = m
                    }
                    if row.count >= 8, let d = Int("\(row[7] ?? 0)") {
                        day = d
                    }
                    let collection = Moment(.MOMENTS, imageCount: count, year: year, month: month, day: day, country: country, province: province, city: city, place: place)
                    collection.groupByPlace = true
                    if let p = parent {
                        collection.gov = p.gov
                        collection.place = p.place
                    }
                    result.append(collection)
                }
                
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
        ModelStore.inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        ModelStore.inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
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
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql, arguments:StatementArguments(sqlArgs))
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
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
            let db = ModelStoreGRDB.sharedDBPool()
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
            let db = ModelStoreGRDB.sharedDBPool()
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

}
