//
//  ModelStore+Image+Meta.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ImageSearchDaoGRDB {
    
    // MARK: - Options
    
    func getImageSources() -> [String:Bool]{
        var results:[String:Bool] = [:]
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT DISTINCT imageSource FROM Image")
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT DISTINCT cameraMaker,cameraModel FROM Image")
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
    
    
    
    func getMoments(_ momentCondition:MomentCondition, year:Int, month:Int, condition:SearchCondition?) -> [Moment] {
        var fields = ""
        var arguments = ""
        
        if momentCondition == .YEAR {
            fields = "photoTakenYear"
        }else if momentCondition == .MONTH {
            fields = "photoTakenYear, photoTakenMonth"
            arguments = "AND photoTakenYear=\(year)"
        }else if momentCondition == .DAY {
            fields = "photoTakenYear, photoTakenMonth, photoTakenDay"
            arguments = "AND photoTakenYear=\(year) AND photoTakenMonth=\(month)"
        }
        
        let sql = """
        SELECT count(path) as photoCount, \(fields)  FROM
        (SELECT IFNULL(photoTakenYear,0) AS photoTakenYear, IFNULL(photoTakenMonth,0) AS photoTakenMonth, IFNULL(photoTakenDay,0) AS photoTakenDay, path, imageSource, cameraModel from Image)
        WHERE 1=1 \(arguments) GROUP BY \(fields) ORDER BY \(fields) DESC
        """
        print(">> GRDB SQL of loading moments treeview")
        print(sql)
        var result:[Moment] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
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
    
    func getAllMoments(imageSource:[String]?, cameraModel:[String]?) -> [Moment] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        SQLHelper.inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        SQLHelper.inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = """
        SELECT photoTakenYear, photoTakenMonth, photoTakenDay, count(path) as photoCount FROM
        (SELECT IFNULL(photoTakenYear,0) AS photoTakenYear, IFNULL(photoTakenMonth,0) AS photoTakenMonth, IFNULL(photoTakenDay,0) AS photoTakenDay, path, imageSource, cameraModel from Image)
        WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY photoTakenYear,photoTakenMonth,photoTakenDay ORDER BY photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC
        """
        print(sql)
        var result:[Row] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql: sql, arguments:StatementArguments(sqlArgs) ?? [])
            }
        }catch{
            print(error)
        }
        return Moments().readMoments(result)
        
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
    
    func getMomentsByPlace(_ momentCondition:MomentCondition, parent:Moment?, condition:SearchCondition?) -> [Moment] {
        var fields = ""
        var whereStmt = ""
        var order = ""
        var argumentValues:[String] = []
        
        if momentCondition == .PLACE {
            fields = "country, province, city, place"
        }else if momentCondition == .YEAR {
            fields = "country, province, city, place, photoTakenYear"
            if let p = parent {
                self.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues)
            }
            order = "DESC"
        }else if momentCondition == .MONTH {
            fields = "country, province, city, place, photoTakenYear, photoTakenMonth"
            if let p = parent {
                self.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues)
                self.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues)
                self.appendSqlIntegerCondition("photoTakenYear", value: p.year, where: &whereStmt)
            }
            order = "DESC"
        }else if momentCondition == .DAY {
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql, arguments:StatementArguments(argumentValues))
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
    
    func getAllPlacesAndDates(imageSource:[String]?, cameraModel:[String]?) -> [Moment] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        SQLHelper.inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        SQLHelper.inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
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
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql: sql, arguments:StatementArguments(sqlArgs) ?? [])
            }
        }catch{
            print(error)
        }
        return Moments().readPlaces(result)
        
    }
    
    
    
    func getImageEvents(condition:SearchCondition?) -> [Moment] {
        var result:[Moment] = []
        let sql = """
        select t.cnt, ifnull(e.category,'') category, t.name from (
        select name, sum(cnt) cnt from (
        select name, 0 cnt from ImageEvent
        union
        select ifnull(event,'') as name, count(path) cnt from Image group by event
        ) group by name) as t
        left join ImageEvent e on e.name = t.name order by category, t.name
        """
        print(sql)
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        let imageCount = Int("\(row[0] ?? 0)") ?? 0
                        let category = "\(row[1] ?? "")"
                        let event = "\(row[2] ?? "")"
                        let moment = Moment(event: event, category: category, imageCount: imageCount)
                        result.append(moment)
                    }
                }
                
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getMomentsByEvent(event:String, category:String, year:Int = 0, month:Int, condition:SearchCondition?) -> [Moment] {
        var whereStmt = "event=?"
        var ev = event
        if event == "未分配事件" {
            ev = ""
            whereStmt = "(event=? or event is null)"
        }
        var fields = ""
        if year == 0 {
            fields = "photoTakenYear"
        }else if month == 0 {
            fields = "photoTakenYear, photoTakenMonth"
            whereStmt = "\(whereStmt) AND photoTakenYear=\(year)"
        }else {
            fields = "photoTakenYear, photoTakenMonth, photoTakenDay"
            whereStmt = "\(whereStmt) AND photoTakenYear=\(year) AND photoTakenMonth=\(month)"
        }
        var result:[Moment] = []
        let sql = """
        select count(path) as cnt, ifnull(event, '') event, \(fields) from Image
        where \(whereStmt)
        group by event, \(fields) order by event, \(fields) DESC
        """
        print(sql)
        print("SQL argument: \(ev)")
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql, arguments:StatementArguments([ev]))
                if rows.count > 0 {
                    for row in rows {
                        let imageCount = Int("\(row[0] ?? 0)") ?? 0
                        var y = 0
                        var m = 0
                        var d = 0
                        if row.count >= 3 {
                            y = Int("\(row[2] ?? 0)") ?? 0
                        }
                        if row.count >= 4 {
                            m = Int("\(row[3] ?? 0)") ?? 0
                        }
                        if row.count >= 5 {
                            d = Int("\(row[4] ?? 0)") ?? 0
                        }
                        let moment = Moment(event: event, category: category, imageCount: imageCount)
                        moment.year = y
                        moment.month = m
                        moment.day = d
                        result.append(moment)
                    }
                }
                
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getYears(event:String?) -> [Int] {
        var condition = ""
        var args:[String] = []
        if let ev = event {
            condition = " where event=? "
            args.append(ev)
        }
        let sql = "select distinct photoTakenYear from image \(condition) order by photoTakenYear desc"
        
        var result:[Int] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql, arguments:StatementArguments(args))
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
    
    func getDatesByYear(year:Int, event:String?) -> [String:[String]] {
        var sql = "select distinct photoTakenMonth,photoTakenDay from image where photoTakenYear=? order by photoTakenMonth,photoTakenDay"
        var args:[Any] = [year]
        
        if let ev = event, ev != "" {
            sql = "select distinct photoTakenMonth,photoTakenDay from image where photoTakenYear=? and event=? order by photoTakenMonth,photoTakenDay"
            args.append(ev)
        }
        
        //print(sql)
        var result:[String:[String]] = [:]
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql, arguments:StatementArguments(args) ?? [])
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
