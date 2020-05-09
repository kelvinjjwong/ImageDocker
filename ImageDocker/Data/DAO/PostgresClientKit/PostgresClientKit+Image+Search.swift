//
//  PostgresClientKit+Image+Search.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit

class ImageSearchDaoPostgresCK : ImageSearchDaoInterface {
    
    func getAllPlacesAndDates(imageSource: [String]?, cameraModel: [String]?) -> [Moment] {
        let db = PostgresConnection.database()
        var sqlArgs:[PostgresValueConvertible] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        SQLHelper.inPostgresArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        SQLHelper.inPostgresArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
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
        
        final class TempRecord : PostgresCustomRecord {
            var country:String? = nil
            var province:String? = nil
            var city:String? = nil
            var place:String? = nil
            var photoTakenYear:Int? = nil
            var photoTakenMonth:Int? = nil
            var photoTakenDay:Int? = nil
            var photoCount:Int? = nil
            public init() {}
        }
        
        let records = TempRecord.fetchAll(db, sql: sql)
        
        var places:[Moment] = [Moment] ()
        for data in records {
            var gov = ""
            let country = data.country ?? ""
            let province = data.province ?? ""
            let city = data.city ?? ""

            var place = data.place ?? ""
            let year = data.photoTakenYear ?? 0
            let month = data.photoTakenMonth ?? 0
            let day = data.photoTakenDay ?? 0
            let photoCount = data.photoCount ?? 0
            
            if place == "" && (country == "" && province == "" && city == "") {
                continue
            }
            
            if year == 0 && month == 0 && day == 0 && place != "" {
                gov = "未知日期"
            }else if year == 0 && month == 0 && day == 0 && place == "" {
                gov = "未知日期"
                place = "未知地址"
            }else if country == "" && province == "" && city == "" && place != "" {
                gov = place
            }else {
                if country == "中国" {
                    if province == city {
                        gov = city
                    }else{
                        gov = "\(province)\(city)"
                    }
                }else{
                    gov = "\(country)"
                }
            }
            
            if place == "" && (country != "" || province != "" || city != "") {
                if city != "" {
                    place = city
                }
                if place == "" && province != "" {
                    place = province
                }
                if place == "" && country != "" {
                    place = country
                }
            }
            gov = gov.replacingOccurrences(of: "特别行政区", with: "")
            place = place.replacingOccurrences(of: "特别行政区", with: "")
            
            //print("Got \(place)-\(year)-\(month)-\(day)")
            var govEntry:Moment
            var placeEntry:Moment
            var yearEntry:Moment
            var monthEntry:Moment
            
            if places.firstIndex(where: {$0.gov == gov}) == nil {
                govEntry = Moment(gov: gov)
                govEntry.groupByPlace = true
                places.append(govEntry)
            }else{
                govEntry = places.first(where: {$0.gov == gov})!
            }
            govEntry.photoCount += photoCount
            govEntry.countryData = data.country ?? ""
            govEntry.provinceData = data.province ?? ""
            govEntry.cityData = data.city ?? ""
            
            if govEntry.children.firstIndex(where: {$0.place == place}) == nil {
                placeEntry = Moment(place: place, gov: gov)
                placeEntry.groupByPlace = true
                govEntry.children.append(placeEntry)
            }else{
                placeEntry = govEntry.children.first(where: {$0.place == place})!
            }
            placeEntry.photoCount += photoCount
            placeEntry.countryData = data.country ?? ""
            placeEntry.provinceData = data.province ?? ""
            placeEntry.cityData = data.city ?? ""
            placeEntry.placeData = data.place ?? ""
            
            if placeEntry.children.firstIndex(where: {$0.year == year}) == nil {
                yearEntry = Moment(year: year, place: place, gov: gov)
                yearEntry.groupByPlace = true
                placeEntry.children.append(yearEntry)
            }else{
                yearEntry = placeEntry.children.first(where: {$0.year == year})!
            }
            yearEntry.photoCount += photoCount
            yearEntry.countryData = data.country ?? ""
            yearEntry.provinceData = data.province ?? ""
            yearEntry.cityData = data.city ?? ""
            yearEntry.placeData = data.place ?? ""
            
            if yearEntry.children.firstIndex(where: {$0.month == month}) == nil {
                monthEntry = Moment(month: month, ofYear: year, place: place, gov: gov)
                monthEntry.groupByPlace = true
                yearEntry.children.append(monthEntry)
            }else {
                monthEntry = yearEntry.children.first(where: {$0.month == month})!
            }
            monthEntry.photoCount += photoCount
            monthEntry.countryData = data.country ?? ""
            monthEntry.provinceData = data.province ?? ""
            monthEntry.cityData = data.city ?? ""
            monthEntry.placeData = data.place ?? ""
            
            let dayEntry:Moment = Moment(day: day, ofMonth: month, ofYear: year, place: place, gov: gov)
            dayEntry.groupByPlace = true
            
            monthEntry.children.append(dayEntry)
            
            dayEntry.photoCount = photoCount
            dayEntry.countryData = data.country ?? ""
            dayEntry.provinceData = data.province ?? ""
            dayEntry.cityData = data.city ?? ""
            dayEntry.placeData = data.place ?? ""
            
        }
        return places
    }
    
    func getImageSources() -> [String : Bool] {
        var results:[String:Bool] = [:]
        let db = PostgresConnection.database()
        final class TempRecord : PostgresCustomRecord {
            var imageSource: String = ""
            public init() {}
        }
        let records = TempRecord.fetchAll(db, sql: "SELECT DISTINCT imageSource FROM Image")
        for row in records {
            let src = row.imageSource
            if src != "" {
                results[src] = false
            }
        }
        return results
    }
    
    func getCameraModel() -> [String : Bool] {
        var results:[String:Bool] = [:]
        let db = PostgresConnection.database()
        final class TempRecord : PostgresCustomRecord {
            var cameraMaker: String = ""
            var cameraModel: String = ""
            public init() {}
        }
        let records = TempRecord.fetchAll(db, sql: "SELECT DISTINCT cameraMaker,cameraModel FROM Image")
        for row in records {
            let name1 = row.cameraMaker
            let name2 = row.cameraModel
            if name1 != "" && name2 != "" {
                results["\(name1),\(name2)"] = false
            }
        }
        return results
    }
    
    func getMoments(_ condition: MomentCondition, year: Int, month: Int) -> [Moment] {
        let db = PostgresConnection.database()
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
        final class TempRecord : PostgresCustomRecord {
            var photoCount: Int = 0
            var photoTakenYear: Int = 0
            var photoTakenMonth: Int = 0
            var photoTakenDay: Int = 0
            public init() {}
        }
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            let collection = Moment(.MOMENTS, imageCount: row.photoCount, year: row.photoTakenYear, month: row.photoTakenMonth, day: row.photoTakenDay)
            result.append(collection)
        }
        return result
    }
    
    func getAllMoments(imageSource: [String]?, cameraModel: [String]?) -> [Moment] {
        let db = PostgresConnection.database()
        var sqlArgs:[PostgresValueConvertible] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        SQLHelper.inPostgresArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        SQLHelper.inPostgresArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = """
        SELECT photoTakenYear, photoTakenMonth, photoTakenDay, count(path) as photoCount FROM
        (SELECT IFNULL(photoTakenYear,0) AS photoTakenYear, IFNULL(photoTakenMonth,0) AS photoTakenMonth, IFNULL(photoTakenDay,0) AS photoTakenDay, path, imageSource, cameraModel from Image)
        WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY photoTakenYear,photoTakenMonth,photoTakenDay ORDER BY photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC
        """
        print(sql)
        final class TempRecord : PostgresCustomRecord {
            var photoTakenYear: Int = 0
            var photoTakenMonth: Int = 0
            var photoTakenDay: Int = 0
            var photoCount: Int = 0
            var place: String = ""
            public init() {}
        }
        let records = TempRecord.fetchAll(db, sql: sql)
        
        var years:[Moment] = [Moment] ()
        
        for data in records {
            
            let place = data.place
            let year = data.photoTakenYear
            let month = data.photoTakenMonth
            let day = data.photoTakenDay
            let photoCount = data.photoCount
            
            //print("Got \(place)-\(year)-\(month)-\(day)")
            var yearEntry:Moment
            var monthEntry:Moment
            
            if year == 0 && month == 0 && day == 0 {
                if years.firstIndex(where: {$0.place == "未能识别日期"}) == nil {
                    yearEntry = Moment(place: "未能识别日期")
                    years.append(yearEntry)
                }else{
                    yearEntry = years.first(where: {$0.place == "未能识别日期"})!
                }
                yearEntry.photoCount += photoCount
                
                let dayEntry:Moment = Moment(day: day, ofMonth: month, ofYear: year, place: place == "" ? "未能识别地址" : place)
                dayEntry.photoCount = photoCount
                
                yearEntry.children.append(dayEntry)
            }else {
            
                if years.firstIndex(where: {$0.year == year}) == nil {
                    yearEntry = Moment(year: year)
                    years.append(yearEntry)
                }else{
                    yearEntry = years.first(where: {$0.year == year})!
                }
                yearEntry.photoCount += photoCount
                
                if yearEntry.children.firstIndex(where: {$0.month == month}) == nil {
                    monthEntry = Moment(month: month, ofYear: year, place: place)
                    yearEntry.children.append(monthEntry)
                }else {
                    monthEntry = yearEntry.children.first(where: {$0.month == month})!
                }
                monthEntry.photoCount += photoCount
                
                let dayEntry:Moment = Moment(day: day, ofMonth: month, ofYear: year, place: place)
                dayEntry.photoCount = photoCount
                
                monthEntry.children.append(dayEntry)
            }
            
            
        }
        return years
    }
    
    func getMomentsByPlace(_ condition: MomentCondition, parent: Moment?) -> [Moment] {
        let db = PostgresConnection.database()
        var fields = ""
        var whereStmt = ""
        var order = ""
        var argumentValues:[String] = []
        
        if condition == .PLACE {
            fields = "country, province, city, place"
        }else if condition == .YEAR {
            fields = "country, province, city, place, photoTakenYear"
            if let p = parent {
                SQLHelper.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues)
            }
            order = "DESC"
        }else if condition == .MONTH {
            fields = "country, province, city, place, photoTakenYear, photoTakenMonth"
            if let p = parent {
                SQLHelper.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlIntegerCondition("photoTakenYear", value: p.year, where: &whereStmt)
            }
            order = "DESC"
        }else if condition == .DAY {
            fields = "country, province, city, place, photoTakenYear, photoTakenMonth, photoTakenDay"
            if let p = parent {
                SQLHelper.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues)
                SQLHelper.appendSqlIntegerCondition("photoTakenYear", value: p.year, where: &whereStmt)
                SQLHelper.appendSqlIntegerCondition("photoTakenMonth", value: p.month, where: &whereStmt)
            }
            order = "DESC"
        }
        
        let sql = """
        SELECT count(path) as photoCount, \(fields) FROM
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
        
        final class TempRecord : PostgresCustomRecord {
            var photoCount:Int = 0
            var country: String = ""
            var province: String = ""
            var city:String = ""
            var place:String = ""
            var photoTakenYear:Int = 0
            var photoTakenMonth:Int = 0
            var photoTakenDay:Int = 0
            public init() {}
        }
        
        let records = TempRecord.fetchAll(db, sql: sql, values: argumentValues)
        for row in records {
            let country = row.country
            let province = row.province
            let city = row.city
            let place = row.place
            let year = row.photoTakenYear
            let month = row.photoTakenMonth
            let day = row.photoTakenDay
            let count = row.photoCount
            
            let collection = Moment(.MOMENTS, imageCount: count, year: year, month: month, day: day, country: country, province: province, city: city, place: place)
            collection.groupByPlace = true
            if let p = parent {
                collection.gov = p.gov
                collection.place = p.place
            }
            result.append(collection)
        }
        return result
    }
    
    func getImageEvents() -> [Moment] {
        let db = PostgresConnection.database()
        
        final class TempRecord : PostgresCustomRecord {
            var cnt:Int = 0
            var category: String = ""
            var name: String = ""
            public init() {}
        }
        
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
        
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            let imageCount = row.cnt
            let category = row.category
            let event = row.name
            let moment = Moment(event: event, category: category, imageCount: imageCount)
            result.append(moment)
        }
        return result
    }
    
    func getMomentsByEvent(event: String, category: String, year: Int, month: Int) -> [Moment] {
        let db = PostgresConnection.database()
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
        
        final class TempRecord : PostgresCustomRecord {
            var cnt:Int = 0
            var event: String = ""
            var photoTakenYear: Int = 0
            var photoTakenMonth:Int = 0
            var photoTakenDay:Int = 0
            public init() {}
        }
        
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            let moment = Moment(event: event, category: category, imageCount: row.cnt)
            moment.year = row.photoTakenYear
            moment.month = row.photoTakenMonth
            moment.day = row.photoTakenDay
            result.append(moment)
        }
        return result
    }
    
    func getYears(event: String?) -> [Int] {
        let db = PostgresConnection.database()
        
        final class TempRecord : PostgresCustomRecord {
            var photoTakenYear: Int = 0
            public init() {}
        }
        var condition = ""
        var args:[String] = []
        if let ev = event {
            condition = " where event=? "
            args.append(ev)
        }
        
        let records = TempRecord.fetchAll(db, sql: "select distinct photoTakenYear from image \(condition) order by photoTakenYear desc", values: args)
        var result:[Int] = []
        for row in records {
            let year = row.photoTakenYear
            result.append(year)
        }
        return result
    }
    
    func getDatesByYear(year: Int, event: String?) -> [String : [String]] {
        let db = PostgresConnection.database()
        var sql = "select distinct photoTakenMonth,photoTakenDay from image where photoTakenYear=? order by photoTakenMonth,photoTakenDay"
        var args:[PostgresValueConvertible] = [year]
        
        if let ev = event, ev != "" {
            sql = "select distinct photoTakenMonth,photoTakenDay from image where photoTakenYear=? and event=? order by photoTakenMonth,photoTakenDay"
            args.append(ev)
        }
        
        final class TempRecord : PostgresCustomRecord {
            var photoTakenMonth: Int = 0
            var photoTakenYear: Int = 0
            public init() {}
        }
        
        //print(sql)
        var result:[String:[String]] = [:]
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            let month = row.photoTakenMonth
            let day = row.photoTakenYear
            if result["\(month)"] == nil {
                result["\(month)"] = []
            }
            result["\(month)"]?.append("\(day)")
        }
        return result
    }
    
    func getPhotoFiles(year: Int, month: Int, day: Int, ignoreDate: Bool, country: String, province: String, city: String, place: String?, includeHidden: Bool, imageSource: [String]?, cameraModel: [String]?, hiddenCountHandler: ((Int) -> Void)?, pageSize: Int, pageNumber: Int) -> [Image] {
        let db = PostgresConnection.database()
        print("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden, sqlArgs) = SQLHelper.generatePostgresSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        print(stmt)
        print(stmtHidden)
        
        var result:[Image] = []
        let hiddenCount = db.count(sql: stmtHidden, parameterValues: sqlArgs)
        if pageNumber > 0 && pageSize > 0 {
            result = Image.fetchAll(db, sql: "\(stmt) order by photoTakenDate, filename", values: sqlArgs, offset: pageSize * (pageNumber - 1), limit: pageSize)
        }else{
            result = Image.fetchAll(db, sql: "\(stmt) order by photoTakenDate, filename", values: sqlArgs)
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
        print("loaded \(result.count) records")
        return result
        
    }
    
    func getPhotoFiles(year: Int, month: Int, day: Int, event: String, country: String, province: String, city: String, place: String, includeHidden: Bool, imageSource: [String]?, cameraModel: [String]?, hiddenCountHandler: ((Int) -> Void)?, pageSize: Int, pageNumber: Int) -> [Image] {
        let db = PostgresConnection.database()
        print("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden, sqlArgs) = SQLHelper.generatePostgresSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result:[Image] = []
        let hiddenCount = db.count(sql: stmtHidden, parameterValues: sqlArgs)
        if pageNumber > 0 && pageSize > 0 {
            result = Image.fetchAll(db, sql: "\(stmt) order by photoTakenDate, filename", values: sqlArgs, offset: pageSize * (pageNumber - 1), limit: pageSize)
        }else{
            result = Image.fetchAll(db, sql: "\(stmt) order by photoTakenDate, filename", values: sqlArgs)
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
        print("loaded \(result.count) records")
        return result
    }
    
    func searchPhotoFiles(years: [Int], months: [Int], days: [Int], peopleIds: [String], keywords: [String], includeHidden: Bool, hiddenCountHandler: ((Int) -> Void)?, pageSize: Int, pageNumber: Int) -> [Image] {
        let db = PostgresConnection.database()
        print("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden) = SQLHelper.generateSQLStatementForSearchingPhotoFiles(years: years, months: months, days: days, peopleIds: peopleIds, keywords: keywords, includeHidden:includeHidden)
        
        var result:[Image] = []
        let hiddenCount = db.count(sql: stmtHidden)
        if pageNumber > 0 && pageSize > 0 {
            result = Image.fetchAll(db, sql: "\(stmt) order by photoTakenDate, filename", offset: pageSize * (pageNumber - 1), limit: pageSize)
        }else{
            result = Image.fetchAll(db, sql: "\(stmt) order by photoTakenDate, filename")
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
        print("loaded \(result.count) records")
        return result
    }
    
    func getImagesByDate(year: Int, month: Int, day: Int, event: String?) -> [Image] {
        let db = PostgresConnection.database()
        var sql = "hidden=0 and photoTakenYear=\(year) and photoTakenMonth=\(month) and photoTakenDay=\(day)"
        if let ev = event, ev != "" {
            sql = "hidden=0 and photoTakenYear=\(year) and photoTakenMonth=\(month) and photoTakenDay=\(day) and event='\(ev)'"
        }
        return Image.fetchAll(db, where: sql)
    }
    
    func getImagesByYear(year: String?, scannedFace: Bool?, recognizedFace: Bool?) -> [Image] {
        let db = PostgresConnection.database()
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
        return Image.fetchAll(db, where: sql)
    }
    
    func getImagesByDate(photoTakenDate: Date, event: String?) -> [Image] {
        let year = Calendar.current.component(.year, from: photoTakenDate)
        let month = Calendar.current.component(.month, from: photoTakenDate)
        let day = Calendar.current.component(.day, from: photoTakenDate)
        return getImagesByDate(year: year, month: month, day: day, event: event)
    }
    
    func getImagesByHour(photoTakenDate: Date) -> [Image] {
        let db = PostgresConnection.database()
        let year = Calendar.current.component(.year, from: photoTakenDate)
        let month = Calendar.current.component(.month, from: photoTakenDate)
        let day = Calendar.current.component(.day, from: photoTakenDate)
        let hour = Calendar.current.component(.hour, from: photoTakenDate)
        return Image.fetchAll(db, where: "hidden=0 and photoTakenYear=\(year) and photoTakenMonth=\(month) and photoTakenDay=\(day) and photoTakenHour=\(hour)")
    }
    
    func getMaxPhotoTakenYear() -> Int {
        let db = PostgresConnection.database()
        let sql = "select distinct max(photoTakenYear) photoTakenYear from image where hidden=0"
        final class TempRecord : PostgresCustomRecord {
            var photoTakenYear: Int = 0
            public init() {}
        }
        if let record = TempRecord.fetchOne(db, sql: sql) {
            return record.photoTakenYear
        }else{
            return 0
        }
    }
    
    func getMinPhotoTakenYear() -> Int {
        let db = PostgresConnection.database()
        let sql = "select distinct min(photoTakenYear) photoTakenYear from image where hidden=0"
        final class TempRecord : PostgresCustomRecord {
            var photoTakenYear: Int = 0
            public init() {}
        }
        if let record = TempRecord.fetchOne(db, sql: sql) {
            return record.photoTakenYear
        }else{
            return 0
        }
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
    
    func getYearsByTodayInPrevious() -> [Int] {
        let db = PostgresConnection.database()
        var sql = "select distinct photoTakenYear from image where hidden=0 and DATE(phototakendate) IN ("
        sql += self.getSqlByTodayInPrevious()
        sql += ") order by photoTakenYear desc"
        
        final class TempRecord : PostgresCustomRecord {
            var photoTakenYear: Int = 0
            public init() {}
        }
        
        var result:[Int] = []
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            result.append(row.photoTakenYear)
        }
        return result
    }
    
    func getDatesAroundToday() -> [String] {
        let db = PostgresConnection.database()
        let sql = """
select DATE('now', 'localtime', '-1 day') date union
select DATE('now', 'localtime', '-2 day') date union
select DATE('now', 'localtime', '+1 day') date union
select DATE('now', 'localtime', '+2 day') date union
select DATE('now', 'localtime')  date
"""
        var result:[String] = []
        
        final class TempRecord : PostgresCustomRecord {
            var date: String = ""
            public init() {}
        }
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            result.append(row.date)
        }
        return result
        
    }
    
    func getDatesByTodayInPrevious(year: Int) -> [String] {
        let db = PostgresConnection.database()
        
        let now = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: now)
        let k = currentYear - year
        
        var sql = "select distinct DATE(photoTakenDate) as photoTakenDate from image where hidden=0 and DATE(phototakendate) IN ("
        sql += "DATE('now', 'localtime', '-\(k) year'), DATE('now', 'localtime', '-\(k) year', '-1 day'), DATE('now', 'localtime', '-\(k) year', '-2 day'), DATE('now', 'localtime', '-\(k) year', '+1 day'), DATE('now', 'localtime', '-\(k) year', '+2 day')"
        sql += ") order by DATE(photoTakenDate) desc"
        print(sql)
        
        final class TempRecord : PostgresCustomRecord {
            var photoTakenDate: String = ""
            public init() {}
        }
        
        var result:[String] = []
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            result.append(row.photoTakenDate)
        }
        return result
    }
    
    func getPhotoFilesWithoutExif(limit: Int?) -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: "hidden != 1 AND cameraMaker is null and (lastTimeExtractExif = 0 or updateExifDate is null OR photoTakenYear is null OR photoTakenYear = 0 OR (latitude <> '0.0' AND latitudeBD = '0.0') OR (latitudeBD <> '0.0' AND COUNTRY = ''))", orderBy: "photoTakenDate, filename")
    }
    
    func getPhotoFilesWithoutLocation() -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: "hidden != 1 AND updateLocationDate is null", orderBy: "photoTakenDate, filename")
    }
    
    func getPhotoFiles(after date: Date) -> [Image] {
        let db = PostgresConnection.database()
        
        return Image.fetchAll(db, where: "updateLocationDate >= $1", values: [date])
    }
    
    func getImagesWithoutFace(repositoryRoot: String, includeScanned: Bool) -> [Image] {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withStash()
        let scannedCondition = includeScanned ? "" : " and scanedFace=0"
        
        return Image.fetchAll(db, where: "repositoryPath=$1 and hidden=0 \(scannedCondition) and id not in (select distinct imageid from imageface)", values: [root])
    }
    
    func getAllPhotoPaths(includeHidden: Bool) -> Set<String> {
        var result:Set<String> = []
        let db = PostgresConnection.database()
        if includeHidden {
            let records = Image.fetchAll(db, orderBy: "photoTakenDate, filename")
            for record in records {
                result.insert(record.path)
            }
        }else{
            let records = Image.fetchAll(db, where: "hidden = 0", orderBy: "photoTakenDate, filename")
            for record in records {
                result.insert(record.path)
            }
        }
        return result
    }
    
    func getPhotoFilesWithoutSubPath(rootPath: String) -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: "path like $1 and subPath = ''", values: ["\(rootPath.withStash())%"] )
    }
    
    func getPhotoFiles(parentPath: String, includeHidden: Bool, pageSize: Int, pageNumber: Int, subdirectories: Bool) -> [Image] {
        let db = PostgresConnection.database()
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
        
        if pageSize > 0 && pageNumber > 0 {
            return Image.fetchAll(db, where: "\(condition) \(otherPredicate)", orderBy: "photoTakenDate, filename", offset: pageSize * (pageNumber - 1), limit: pageSize)
        }else{
            return Image.fetchAll(db, where: "\(condition) \(otherPredicate)", orderBy: "photoTakenDate, filename")
        }
    }
    
    func getImages(repositoryPath: String) -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: "repositoryPath = $1", orderBy: "path", values: [repositoryPath])
    }
    
    func getPhotoFiles(rootPath: String) -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: "path like $1", values: ["\(rootPath.withStash())%"])
    }
    
    func getAllExportedImages(includeHidden: Bool) -> [Image] {
        let db = PostgresConnection.database()
        if includeHidden {
            return Image.fetchAll(db, where: "exportToPath is not null and exportAsFilename is not null and exportToPath <> '' and exportAsFilename <> ''", orderBy: "photoTakenDate, filename")
        }else{
            return Image.fetchAll(db, where: "hidden = 0 and exportToPath is not null and exportAsFilename is not null and exportToPath <> '' and exportAsFilename <> ''", orderBy: "photoTakenDate, filename")
        }
    }
    
    func getAllExportedPhotoFilenames(includeHidden: Bool) -> Set<String> {
        let db = PostgresConnection.database()
        var result:Set<String> = []
        let records:[Image] = self.getAllExportedImages(includeHidden: includeHidden)
        for row in records {
            let path = "\(row.exportToPath ?? "")/\(row.exportAsFilename ?? "")"
            result.insert(path)
        }
        return result
    }
    
    func getAllPhotoFilesForExporting(after date: Date, limit: Int?) -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: "hidden != 1 AND photoTakenYear <> 0 AND photoTakenYear IS NOT NULL AND (updateDateTimeDate > ? OR updateExifDate > ? OR updateLocationDate > ? OR updateEventDate > ? OR exportTime is null)", orderBy: "photoTakenDate, filename", offset: 0, limit: limit)
    }
    
    func getAllPhotoFilesMarkedExported() -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: "hidden != 1 AND exportTime is not null)", orderBy: "photoTakenDate, filename")
    }
    

}