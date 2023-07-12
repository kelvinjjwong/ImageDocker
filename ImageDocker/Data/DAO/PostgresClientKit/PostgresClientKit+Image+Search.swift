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
    
    let logger = ConsoleLogger(category: "ImageSearchDao", subCategory: "Postgres")
    
    func getAllPlacesAndDates(imageSource: [String]?, cameraModel: [String]?) -> [Moment] {
        let db = PostgresConnection.database()
        var sqlArgs:[PostgresValueConvertible] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        SQLHelper.inPostgresArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        SQLHelper.inPostgresArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = """
        SELECT "country", "province", "city", "place", "photoTakenYear", "photoTakenMonth", "photoTakenDay", count(path) as "photoCount" FROM
        (
        SELECT "country", province, city, place, "photoTakenYear", "photoTakenMonth", "photoTakenDay", path, "imageSource","cameraModel" from "Image" WHERE "assignCountry" is null and "assignProvince" is null and "assignCity" is null
        UNION
        SELECT "assignCountry" as country, "assignProvince" as province, "assignCity" as city, "assignPlace" as place, "photoTakenYear", "photoTakenMonth", "photoTakenDay", path, "imageSource","cameraModel" from "Image" WHERE "assignCountry" is not null and "assignProvince" is not null and "assignCity" is not null
        ) t
        WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere)
        GROUP BY country,province,city,place,"photoTakenYear","photoTakenMonth","photoTakenDay" ORDER BY country,province,city,place,"photoTakenYear" DESC,"photoTakenMonth" DESC,"photoTakenDay" DESC
        """
        
//        self.logger.log(sql)
        
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
            
            //self.logger.log("Got \(place)-\(year)-\(month)-\(day)")
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
        let records = TempRecord.fetchAll(db, sql: """
            SELECT DISTINCT imageSource FROM Image
            """)
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
        let records = TempRecord.fetchAll(db, sql: """
            SELECT DISTINCT cameraMaker,cameraModel FROM Image
            """)
        for row in records {
            let name1 = row.cameraMaker
            let name2 = row.cameraModel
            if name1 != "" && name2 != "" {
                results["\(name1),\(name2)"] = false
            }
        }
        return results
    }
    
    func getMoments(_ momentCondition: MomentCondition, year: Int, month: Int, condition:SearchCondition?) -> [Moment] {
        let db = PostgresConnection.database()
        var fields = ""
        var arguments = ""
        
        if momentCondition == .YEAR {
            fields = "\"photoTakenYear\""
        }else if momentCondition == .MONTH {
            fields = "\"photoTakenYear\", \"photoTakenMonth\""
            arguments = "AND \"photoTakenYear\"=\(year)"
        }else if momentCondition == .DAY {
            fields = "\"photoTakenYear\", \"photoTakenMonth\", \"photoTakenDay\""
            arguments = "AND \"photoTakenYear\"=\(year) AND \"photoTakenMonth\"=\(month)"
        }
        
        var additionalConditions = ""
        if let cd = condition {
            if !cd.isEmpty() {
                (additionalConditions, _) = SQLHelper.generateSQLStatementForSearchingPhotoFiles(condition: cd, includeHidden: true, quoteColumn: true)
            }
        }
        if additionalConditions.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            additionalConditions = "AND \(additionalConditions)"
        }
        
        let sql = """
        SELECT count(path) as "photoCount", \(fields)  FROM
        (SELECT COALESCE("photoTakenYear",0) AS "photoTakenYear", COALESCE("photoTakenMonth",0) AS "photoTakenMonth", COALESCE("photoTakenDay",0) AS "photoTakenDay", path, "imageSource",
        "event",
        "longDescription",
        "shortDescription",
        "place",
        "country",
        "province",
        "city",
        "district",
        "businessCircle",
        "street",
        "address",
        "addressDescription",
        "assignPlace",
        "assignCountry",
        "assignProvince",
        "assignCity",
        "assignDistrict",
        "assignBusinessCircle",
        "assignStreet",
        "assignAddress",
        "assignAddressDescription",
        "cameraMaker",
        "cameraModel",
        "softwareName",
        "repositoryPath",
        "filename"
        from "Image") t
        WHERE 1=1 \(arguments) \(additionalConditions) GROUP BY \(fields) ORDER BY \(fields) DESC
        """
//        self.logger.log(">> Postgres SQL of loading moments treeview")
//        self.logger.log(sql)
//        self.logger.log("\n")
        var result:[Moment] = []
        final class TempRecord : PostgresCustomRecord {
            var photoCount: Int = 0
            var photoTakenYear: Int? = 0
            var photoTakenMonth: Int? = 0
            var photoTakenDay: Int? = 0
            public init() {}
        }
        let records = TempRecord.fetchAll(db, sql: sql)
//        self.logger.log(">> got \(records.count) from SQL")
        for row in records {
//            self.logger.log("moment node: y:\(row.photoTakenYear ?? 0) m:\(row.photoTakenMonth ?? 0) d:\(row.photoTakenDay ?? 0)")
            let collection = Moment(.MOMENTS, imageCount: row.photoCount, year: row.photoTakenYear ?? 0, month: row.photoTakenMonth ?? 0, day: row.photoTakenDay ?? 0)
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
        SELECT "photoTakenYear", "photoTakenMonth", "photoTakenDay", count(path) as "photoCount" FROM
        (SELECT COALESCE("photoTakenYear",0) AS "photoTakenYear", COALESCE("photoTakenMonth",0) AS "photoTakenMonth", COALESCE("photoTakenDay",0) AS "photoTakenDay", path, "imageSource", "cameraModel" from "Image") t
        WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY "photoTakenYear","photoTakenMonth","photoTakenDay" ORDER BY "photoTakenYear" DESC,"photoTakenMonth" DESC,"photoTakenDay" DESC
        """
//        self.logger.log(sql)
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
            
            //self.logger.log("Got \(place)-\(year)-\(month)-\(day)")
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
    
    func getMomentsByPlace(_ momentCondition: MomentCondition, parent: Moment?, condition:SearchCondition?) -> [Moment] {
        let db = PostgresConnection.database()
        var fields = ""
        var selectFields = ""
        var orderFields = ""
        var whereStmt = ""
        var argumentValues:[String] = []
        
        var additionalConditions = ""
        if let cd = condition {
            if !cd.isEmpty() {
                (additionalConditions, _) = SQLHelper.generateSQLStatementForSearchingPhotoFiles(condition: cd, includeHidden: true, quoteColumn: true)
            }
        }
        if additionalConditions.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            additionalConditions = "AND \(additionalConditions)"
        }
        
        if momentCondition == .PLACE {
            selectFields = """
            country, province, city, place, 0 as "photoTakenYear", 0 as "photoTakenMonth", 0 as "photoTakenDay"
            """
            fields = """
            country, province, city, place, "photoTakenYear", "photoTakenMonth", "photoTakenDay"
            """
            orderFields = """
            country, province, city, place, "photoTakenYear" DESC, "photoTakenMonth" DESC, "photoTakenDay" DESC
            """
        }else if momentCondition == .YEAR {
            selectFields = """
            country, province, city, place, "photoTakenYear", 0 as "photoTakenMonth", 0 as "photoTakenDay"
            """
            fields = """
            country, province, city, place, "photoTakenYear", "photoTakenMonth", "photoTakenDay"
            """
            orderFields = """
            country, province, city, place, "photoTakenYear" DESC, "photoTakenMonth" DESC, "photoTakenDay" DESC
            """
            if let p = parent {
                var numericPlaceholder = 0
                SQLHelper.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
            }
        }else if momentCondition == .MONTH {
            selectFields = """
            country, province, city, place, "photoTakenYear", "photoTakenMonth", 0 as "photoTakenDay"
            """
            fields = """
            country, province, city, place, "photoTakenYear", "photoTakenMonth", "photoTakenDay"
            """
            orderFields = """
            country, province, city, place, "photoTakenYear" DESC, "photoTakenMonth" DESC, "photoTakenDay" DESC
            """
            if let p = parent {
                var numericPlaceholder = 0
                SQLHelper.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlIntegerCondition("\"photoTakenYear\"", value: p.year, where: &whereStmt)
            }
        }else if momentCondition == .DAY {
            selectFields = """
            country, province, city, place, "photoTakenYear", "photoTakenMonth", "photoTakenDay"
            """
            fields = """
            country, province, city, place, "photoTakenYear", "photoTakenMonth", "photoTakenDay"
            """
            orderFields = """
            country, province, city, place, "photoTakenYear" DESC, "photoTakenMonth" DESC, "photoTakenDay" DESC
            """
            if let p = parent {
                var numericPlaceholder = 0
                SQLHelper.appendSqlTextCondition("country", value: p.countryData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlTextCondition("province", value: p.provinceData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlTextCondition("city", value: p.cityData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlTextCondition("place", value: p.placeData, where: &whereStmt, args: &argumentValues, numericPlaceholder: &numericPlaceholder)
                SQLHelper.appendSqlIntegerCondition("\"photoTakenYear\"", value: p.year, where: &whereStmt)
                SQLHelper.appendSqlIntegerCondition("\"photoTakenMonth\"", value: p.month, where: &whereStmt)
            }
        }
        
        let sql = """
        SELECT count(path) as "photoCount", \(selectFields) FROM
        (
        SELECT COALESCE(country, '') as country, COALESCE(province, '') as province, COALESCE(city, '') as city, place, "photoTakenYear", "photoTakenMonth", "photoTakenDay", path, "imageSource",
        "event",
        "longDescription",
        "shortDescription",
        "district",
        "businessCircle",
        "street",
        "address",
        "addressDescription",
        "assignPlace",
        "assignCountry",
        "assignProvince",
        "assignCity",
        "assignDistrict",
        "assignBusinessCircle",
        "assignStreet",
        "assignAddress",
        "assignAddressDescription",
        "cameraMaker",
        "cameraModel",
        "softwareName",
        "repositoryPath",
        "filename"
        from "Image"
        WHERE "assignCountry" is null and "assignProvince" is null and "assignCity" is null
        UNION
        SELECT "assignCountry" as country, "assignProvince" as province, "assignCity" as city, "assignPlace" as place, "photoTakenYear", "photoTakenMonth", "photoTakenDay", path, "imageSource",
        "event",
        "longDescription",
        "shortDescription",
        "district",
        "businessCircle",
        "street",
        "address",
        "addressDescription",
        "assignPlace",
        "assignCountry",
        "assignProvince",
        "assignCity",
        "assignDistrict",
        "assignBusinessCircle",
        "assignStreet",
        "assignAddress",
        "assignAddressDescription",
        "cameraMaker",
        "cameraModel",
        "softwareName",
        "repositoryPath",
        "filename"
        from "Image"
        WHERE "assignCountry" is not null and "assignProvince" is not null and "assignCity" is not null
        ) t
        WHERE 1=1 \(whereStmt) \(additionalConditions)
        GROUP BY \(fields) ORDER BY \(orderFields)
        """
//        self.logger.log(sql)
//        self.logger.log("SQL values: \(argumentValues)")
        var result:[Moment] = []
        
        final class TempRecord : PostgresCustomRecord {
            var photoCount:Int = 0
            var country: String = ""
            var province: String = ""
            var city:String = ""
            var place:String? = ""
            var photoTakenYear:Int? = 0
            var photoTakenMonth:Int? = 0
            var photoTakenDay:Int? = 0
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
            
            let collection = Moment(.MOMENTS, imageCount: count, year: year ?? 0, month: month ?? 0, day: day ?? 0, country: country, province: province, city: city, place: place ?? "")
            collection.groupByPlace = true
            if let p = parent {
                collection.gov = p.gov
                collection.place = p.place
            }
            result.append(collection)
        }
        return result
    }
    
    func getImageEvents(condition:SearchCondition?) -> [Moment] {
        let db = PostgresConnection.database()
        
        final class TempRecord : PostgresCustomRecord {
            var cnt:Int = 0
            var category: String = ""
            var name: String = ""
            public init() {}
        }
        
        var result:[Moment] = []
        var sql = """
        select t.cnt, COALESCE(e.category,'') as category, t.name from (
        select name, sum(cnt) as cnt from (
        select name, 0 as cnt from "ImageEvent"
        union
        select COALESCE(event,'') as name, count(path) as cnt from "Image" group by event
        ) t1 group by name) as t
        left join "ImageEvent" e on e.name = t.name order by category, t.name
        """
        
        var additionalConditions = ""
        if let cd = condition {
            if !cd.isEmpty() {
                (additionalConditions, _) = SQLHelper.generateSQLStatementForSearchingPhotoFiles(condition: cd, includeHidden: true, quoteColumn: true)
            }
        }
        if additionalConditions.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            additionalConditions = "AND \(additionalConditions)"
            
            sql = """
            select count(path) as cnt, category, name from
            (
            select "Image".path as path, COALESCE("ImageEvent".category,'') as category, COALESCE("Image".event,'') as name,
            "photoTakenYear",
            "photoTakenMonth",
            "photoTakenDay",
            "imageSource",
            "event",
            "longDescription",
            "shortDescription",
            "place",
            "country",
            "province",
            "city",
            "district",
            "businessCircle",
            "street",
            "address",
            "addressDescription",
            "assignPlace",
            "assignCountry",
            "assignProvince",
            "assignCity",
            "assignDistrict",
            "assignBusinessCircle",
            "assignStreet",
            "assignAddress",
            "assignAddressDescription",
            "cameraMaker",
            "cameraModel",
            "softwareName",
            "repositoryPath",
            "filename"
            from "Image"
            left join "ImageEvent" on "ImageEvent".name = "Image".event
            ) t
            WHERE 1=1 \(additionalConditions)
            group by category, name
            order by category, name
            """
        }
        
//        self.logger.log(sql)
        
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
    
    func getMomentsByEvent(event: String, category: String, year: Int, month: Int, condition:SearchCondition?) -> [Moment] {
        let db = PostgresConnection.database()
//        var sqlParams:[PostgresValueConvertible?] = []
        var whereStmt = "event=$1"
        var ev = event
        if event == "未分配事件" {
            ev = ""
            whereStmt = "(event=$1 or event is null)"
        }
        var fields = ""
        if year == 0 {
            fields = "\"photoTakenYear\""
        }else if month == 0 {
            fields = "\"photoTakenYear\", \"photoTakenMonth\""
            whereStmt = "\(whereStmt) AND \"photoTakenYear\"=\(year)"
        }else {
            fields = "\"photoTakenYear\", \"photoTakenMonth\", \"photoTakenDay\""
            whereStmt = "\(whereStmt) AND \"photoTakenYear\"=\(year) AND \"photoTakenMonth\"=\(month)"
        }
        
        var additionalConditions = ""
        if let cd = condition {
            if !cd.isEmpty() {
                (additionalConditions, _) = SQLHelper.generateSQLStatementForSearchingPhotoFiles(condition: cd, includeHidden: true, quoteColumn: true)
            }
        }
        if additionalConditions.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            additionalConditions = "AND \(additionalConditions)"
        }
        
        var result:[Moment] = []
        let sql = """
        select count(path) as cnt, COALESCE(event, '') as event, \(fields)
        from (
        select path, event,
        "photoTakenYear",
        "photoTakenMonth",
        "photoTakenDay",
        "imageSource",
        "longDescription",
        "shortDescription",
        "place",
        "country",
        "province",
        "city",
        "district",
        "businessCircle",
        "street",
        "address",
        "addressDescription",
        "assignPlace",
        "assignCountry",
        "assignProvince",
        "assignCity",
        "assignDistrict",
        "assignBusinessCircle",
        "assignStreet",
        "assignAddress",
        "assignAddressDescription",
        "cameraMaker",
        "cameraModel",
        "softwareName",
        "repositoryPath",
        "filename"
        from "Image"
        ) t
        where \(whereStmt) \(additionalConditions)
        group by event, \(fields) order by event, \(fields) DESC
        """
//        self.logger.log(sql)
//        self.logger.log("SQL argument: \(ev)")
        
        final class TempRecord : PostgresCustomRecord {
            var cnt:Int = 0
            var event: String = ""
            var photoTakenYear: Int? = 0
            var photoTakenMonth:Int? = 0
            var photoTakenDay:Int? = 0
            public init() {}
        }
        
        let records = TempRecord.fetchAll(db, sql: sql, values: [ev])
        for row in records {
            let moment = Moment(event: event, category: category, imageCount: row.cnt)
            moment.year = row.photoTakenYear ?? 0
            moment.month = row.photoTakenMonth ?? 0
            moment.day = row.photoTakenDay ?? 0
            result.append(moment)
        }
        return result
    }
    
    func getYears(event: String?) -> [Int] {
        let db = PostgresConnection.database()
        
        final class TempRecord : PostgresCustomRecord {
            var photoTakenYear: Int? = 0
            public init() {}
        }
        var condition = ""
        var args:[String] = []
        if let ev = event {
            condition = " where \"event\"=? "
            args.append(ev)
        }
        //self.logger.log("debug 1")
        let records = TempRecord.fetchAll(db, sql: """
            select distinct "photoTakenYear" from "Image" \(condition) order by "photoTakenYear" desc
            """, values: args)
        var result:[Int] = []
        for row in records {
            let year = row.photoTakenYear
            result.append(year ?? 0)
        }
        return result
    }
    
    func getDatesByYear(year: Int, event: String?) -> [String : [String]] {
        let db = PostgresConnection.database()
        var sql = """
        select distinct "photoTakenMonth","photoTakenDay" from "Image" where "photoTakenYear"=$1 order by "photoTakenMonth","photoTakenDay"
        """
        var args:[PostgresValueConvertible] = [year]
        
        if let ev = event, ev != "" {
            sql = """
            select distinct "photoTakenMonth","photoTakenDay" from "Image" where "photoTakenYear"=$1 and event=$2 order by "photoTakenMonth","photoTakenDay"
            """
            args.append(ev)
        }
        
        final class TempRecord : PostgresCustomRecord {
            var photoTakenMonth: Int? = 0
            var photoTakenYear: Int? = 0
            public init() {}
        }
        
        //self.logger.log(sql)
        var result:[String:[String]] = [:]
        var sqlParams:[PostgresValueConvertible?] = [year]
        if let ev = event {
            sqlParams.append(ev)
        }
        let records = TempRecord.fetchAll(db, sql: sql, values: sqlParams)
        for row in records {
            let month = row.photoTakenMonth ?? 0
            let day = row.photoTakenYear ?? 0
            if result["\(month)"] == nil {
                result["\(month)"] = []
            }
            result["\(month)"]?.append("\(day)")
        }
        return result
    }
    
    func getPhotoFiles(year: Int, month: Int, day: Int, ignoreDate: Bool, country: String, province: String, city: String, place: String?, includeHidden: Bool, imageSource: [String]?, cameraModel: [String]?, hiddenCountHandler: ((Int) -> Void)?, pageSize: Int, pageNumber: Int) -> [Image] {
        let db = PostgresConnection.database()
        self.logger.log("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden, sqlArgs) = SQLHelper.generatePostgresSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
//        self.logger.log(stmt)
//        self.logger.log(stmtHidden)
        
        var result:[Image] = []
        let hiddenCount = db.count(sql: "select count(1) from \"Image\" where \(stmtHidden)", parameterValues: sqlArgs)
        if pageNumber > 0 && pageSize > 0 {
            result = Image.fetchAll(db, sql: """
                select * from "Image" where \(stmt) order by "photoTakenDate", filename
                """, values: sqlArgs, offset: pageSize * (pageNumber - 1), limit: pageSize)
        }else{
            result = Image.fetchAll(db, sql: """
                select * from "Image" where \(stmt) order by "photoTakenDate", filename
                """, values: sqlArgs)
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
//        self.logger.log("loaded \(result.count) records")
        return result
        
    }
    
    func getPhotoFiles(year: Int, month: Int, day: Int, event: String, country: String, province: String, city: String, place: String, includeHidden: Bool, imageSource: [String]?, cameraModel: [String]?, hiddenCountHandler: ((Int) -> Void)?, pageSize: Int, pageNumber: Int) -> [Image] {
        let db = PostgresConnection.database()
//        self.logger.log("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden, sqlArgs) = SQLHelper.generatePostgresSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result:[Image] = []
        let hiddenCount = db.count(sql: "select count(1) from \"Image\" where \(stmtHidden)", parameterValues: sqlArgs)
        if pageNumber > 0 && pageSize > 0 {
            result = Image.fetchAll(db, sql: """
                select * from "Image" where \(stmt) order by "photoTakenDate", filename
                """, values: sqlArgs, offset: pageSize * (pageNumber - 1), limit: pageSize)
        }else{
            result = Image.fetchAll(db, sql: """
                select * from "Image" where \(stmt) order by "photoTakenDate", filename
                """, values: sqlArgs)
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
//        self.logger.log("loaded \(result.count) records")
        return result
    }
    
    func searchImages(condition:SearchCondition, includeHidden:Bool, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)?, pageSize:Int, pageNumber:Int) -> [Image] {
        let db = PostgresConnection.database()
//        self.logger.log("pageSize:\(pageSize) | pageNumber:\(pageNumber)")
        let (stmt, stmtHidden) = SQLHelper.generateSQLStatementForSearchingPhotoFiles(condition: condition, includeHidden: includeHidden, quoteColumn: true)
        
        var result:[Image] = []
        let hiddenCount = db.count(sql: "select count(1) from \"Image\" where \(stmtHidden)")
        if pageNumber > 0 && pageSize > 0 {
            result = Image.fetchAll(db, sql: """
                select * from "Image" where \(stmt) order by "photoTakenDate", filename
                """, offset: pageSize * (pageNumber - 1), limit: pageSize)
        }else{
            result = Image.fetchAll(db, sql: """
                select * from "Image" where \(stmt) order by "photoTakenDate", filename
                """)
        }
        if hiddenCountHandler != nil {
            hiddenCountHandler!(hiddenCount)
        }
//        self.logger.log("loaded \(result.count) records")
        return result
    }
    
    func getImagesByDate(year: Int, month: Int, day: Int, event: String?) -> [Image] {
        let db = PostgresConnection.database()
        var sql = """
        hidden=false and "photoTakenYear"=\(year) and "photoTakenMonth"=\(month) and "photoTakenDay"=\(day)
        """
        if let ev = event, ev != "" {
            sql = """
            hidden=false and "photoTakenYear"=\(year) and "photoTakenMonth"=\(month) and "photoTakenDay"=\(day) and event='\(ev)'
            """
        }
        return Image.fetchAll(db, where: sql)
    }
    
    func getImagesByYear(year: String?, scannedFace: Bool?, recognizedFace: Bool?) -> [Image] {
        let db = PostgresConnection.database()
        var sql = "hidden=false"
        if let y = year, y != "" {
            sql += " and \"photoTakenYear\"=\(y)"
        }else{
            sql += " and \"photoTakenYear\" > 1920"
        }
        if let flag = scannedFace {
            if flag {
                sql += " and \"scanedFace\"=true"
            }else{
                sql += " and \"scanedFace\"=false"
            }
        }
        if let flag = recognizedFace {
            if flag {
                sql += " and \"recognizedFace\"=true"
            }else{
                sql += " and \"recognizedFace\"=false"
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
        return Image.fetchAll(db, where: "hidden=false and \"photoTakenYear\"=\(year) and \"photoTakenMonth\"=\(month) and \"photoTakenDay\"=\(day) and \"photoTakenHour\"=\(hour)")
    }
    
    func getMaxPhotoTakenYear() -> Int {
        let db = PostgresConnection.database()
        let sql = "select distinct max(\"photoTakenYear\") \"photoTakenYear\" from \"Image\" where hidden=false"
        final class TempRecord : PostgresCustomRecord {
            var photoTakenYear: Int? = 0
            public init() {}
        }
        if let record = TempRecord.fetchOne(db, sql: sql) {
            return record.photoTakenYear ?? 0
        }else{
            return 0
        }
    }
    
    func getMinPhotoTakenYear() -> Int {
        let db = PostgresConnection.database()
        let sql = "select distinct min(\"photoTakenYear\") \"photoTakenYear\" from \"Image\" where hidden=false"
        final class TempRecord : PostgresCustomRecord {
            var photoTakenYear: Int? = 0
            public init() {}
        }
        if let record = TempRecord.fetchOne(db, sql: sql) {
            return record.photoTakenYear ?? 0
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
            sql += """
            DATE 'today' - INTERVAL '\(k) year',
            DATE 'today' - INTERVAL '\(k) year' - INTERVAL '1 day',
            DATE 'today' - INTERVAL '\(k) year' - INTERVAL '2 day',
            DATE 'today' - INTERVAL '\(k) year' + INTERVAL '1 day',
            DATE 'today' - INTERVAL '\(k) year' + INTERVAL '2 day'
            """
            if i+1 != max {
                sql += ","
            }
        }
        return sql
    }
    
    func getYearsByTodayInPrevious() -> [Int] {
        let db = PostgresConnection.database()
        let sql = """
        select distinct "photoTakenYear" from "Image" where hidden=false and DATE("photoTakenDate" + INTERVAL '\(PreferencesController.postgresTimestampTimezoneOffset)h') IN (
        \(self.getSqlByTodayInPrevious())
        ) order by "photoTakenYear" desc
        """
        
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
select DATE("date") as date FROM (
select DATE 'today' + INTERVAL '-1 day' as "date"
union
select DATE 'today' + INTERVAL '-2 day' as "date"
union
select DATE 'today' + INTERVAL '+1 day' as "date"
union
select DATE 'today' + INTERVAL '+2 day' as "date"
union
select DATE 'today' as  "date" ) t
order by "date"
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
        
        let sql = """
        select distinct DATE("photoTakenDate" + INTERVAL '\(PreferencesController.postgresTimestampTimezoneOffset)h') as "photoTakenDate" from "Image" where hidden=false and
        DATE("photoTakenDate" + INTERVAL '\(PreferencesController.postgresTimestampTimezoneOffset)h') IN (
        DATE 'today' - INTERVAL '\(k) year',
        DATE 'today' - INTERVAL '\(k) year' - INTERVAL '1 day',
        DATE 'today' - INTERVAL '\(k) year' - INTERVAL '2 day',
        DATE 'today' - INTERVAL '\(k) year' + INTERVAL '1 day',
        DATE 'today' - INTERVAL '\(k) year' + INTERVAL '2 day'
        ) order by DATE("photoTakenDate" + INTERVAL '\(PreferencesController.postgresTimestampTimezoneOffset)h') desc
        """
//        self.logger.log(sql)
        
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
        return Image.fetchAll(db, where: """
        hidden != true AND ("updateExifDate" is null OR "photoTakenYear" is null OR "photoTakenYear" = 0 OR latitude is null or (latitude <> '0.0' AND "latitudeBD" = '0.0') OR ("latitudeBD" <> '0.0' AND country = ''))
        """, orderBy: """
        "photoTakenDate", filename
        """)
    }
    
    func getPhotoFilesWithoutExif(repositoryPath:String, limit: Int?) -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: """
        "repositoryPath"='\(repositoryPath)' and hidden != true AND ("updateExifDate" is null OR "photoTakenYear" is null OR "photoTakenYear" = 0 OR latitude is null or (latitude <> '0.0' AND "latitudeBD" = '0.0') OR ("latitudeBD" <> '0.0' AND country = ''))
        """, orderBy: """
        "photoTakenDate", filename
        """)
    }
    
    /// "repositoryPath"='\(repositoryPath)' and hidden != true AND "cameraMaker" is null and ("lastTimeExtractExif" = 0 or "updateExifDate" is null OR "photoTakenYear" is null OR "photoTakenYear" = 0 OR (latitude <> '0.0' AND "latitudeBD" = '0.0') OR ("latitudeBD" <> '0.0' AND country = ''))
    ///
    ///
    ///
    
    func getPhotoFilesWithoutLocation(repositoryPath:String) -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: """
        "repositoryPath"='\(repositoryPath)' and hidden != true AND ("updateLocationDate" is null or latitude is null or (latitude <> '0.0' AND "latitudeBD" = '0.0') OR ("latitudeBD" <> '0.0' AND country = ''))
        """, orderBy: """
        "photoTakenDate", filename
        """)
    }
    
    func getPhotoFilesWithoutLocation() -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: """
        hidden != true AND ("updateLocationDate" is null or latitude is null or (latitude <> '0.0' AND "latitudeBD" = '0.0') OR ("latitudeBD" <> '0.0' AND country = ''))
        """, orderBy: """
        "photoTakenDate", filename
        """)
    }
    
    func getPhotoFiles(after date: Date) -> [Image] {
        let db = PostgresConnection.database()
        
        return Image.fetchAll(db, where: "\"updateLocationDate\" >= $1", values: [date])
    }
    
    func getImagesWithoutFace(repositoryRoot: String, includeScanned: Bool) -> [Image] {
        let db = PostgresConnection.database()
        
        let root = repositoryRoot.withLastStash()
        let scannedCondition = includeScanned ? "" : " and \"scanedFace\"=false"
        
        return Image.fetchAll(db, where: """
            "repositoryPath"=$1 and hidden=false \(scannedCondition) and id not in (select distinct "imageId" from "ImageFace")
            """, values: [root])
    }
    
    func getAllPhotoPaths(includeHidden: Bool) -> Set<String> {
        var result:Set<String> = []
        let db = PostgresConnection.database()
        if includeHidden {
            let records = Image.fetchAll(db, orderBy: "\"photoTakenDate\", filename")
            for record in records {
                result.insert(record.path)
            }
        }else{
            let records = Image.fetchAll(db, where: "hidden = false", orderBy: "\"photoTakenDate\", filename")
            for record in records {
                result.insert(record.path)
            }
        }
        return result
    }
    
    func getAllPhotoPaths(repositoryPath:String, includeHidden: Bool) -> Set<String> {
        var result:Set<String> = []
        let db = PostgresConnection.database()
        if includeHidden {
            let records = Image.fetchAll(db, where: "\"repositoryPath\" = '\(repositoryPath)'",  orderBy: "\"photoTakenDate\", filename")
            for record in records {
                result.insert(record.path)
            }
        }else{
            let records = Image.fetchAll(db, where: "\"repositoryPath\" = '\(repositoryPath)' and hidden = false", orderBy: "\"photoTakenDate\", filename")
            for record in records {
                result.insert(record.path)
            }
        }
        return result
    }
    
    func getPhotoFilesWithoutSubPath(rootPath: String) -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: "path like $1 and \"subPath\" = ''", values: ["\(rootPath.withLastStash())%"] )
    }
    
    // FIXME: separate volume and path, get by id rather than path
    func getPhotoFiles(parentPath: String, repositoryId:Int?, repositoryVolume:String?, rawVolume:String?, includeHidden: Bool, pageSize: Int, pageNumber: Int, subdirectories: Bool) -> [Image] {
        let db = PostgresConnection.database()
        var otherPredicate:String = ""
        if !includeHidden {
            otherPredicate = " AND (\"hidden\" is null or \"hidden\" = false)"
        }
        
        var condition = "\"containerPath\" = $1"
        var key:[String] = [parentPath]
        if subdirectories {
            condition = "(\"containerPath\" = $1 or \"containerPath\" like $2)"
            key.append("\(parentPath.withLastStash())%")
        }
        
//        self.logger.log("\(condition) \(otherPredicate)")
        
        if pageSize > 0 && pageNumber > 0 {
            return Image.fetchAll(db, where: "\(condition) \(otherPredicate)", orderBy: "\"photoTakenDate\", filename", values: key, offset: pageSize * (pageNumber - 1), limit: pageSize)
        }else{
            return Image.fetchAll(db, where: "\(condition) \(otherPredicate)", orderBy: "\"photoTakenDate\", filename", values: key)
        }
    }
    
    func getImages(repositoryPath: String) -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: "\"repositoryPath\" = $1", orderBy: "path", values: [repositoryPath])
    }
    
    func getPhotoFiles(rootPath: String) -> [Image] {
        let db = PostgresConnection.database()
        return Image.fetchAll(db, where: "path like $1", values: ["\(rootPath.withLastStash())%"])
    }
    

}
