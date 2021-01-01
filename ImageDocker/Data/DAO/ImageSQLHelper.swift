//
//  ImageSQLHelper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

enum ExecuteState : Int {
    case OK
    case DATABASE_LOCKED
    case NON_SQL_ERROR
    case ERROR
    case NO_RECORD
}

struct SQLHelper {
    
    static func appendSqlTextCondition(_ column:String, value:String?, where statement:inout String, args arguments:inout [String]) {
        if value == nil || value == "" {
            statement = "\(statement) AND (\(column)='' OR \(column) IS NULL)"
        }else{
            statement = "\(statement) AND \(column)=?"
            arguments.append(value!)
        }
    }
    
    static func appendSqlTextCondition(_ column:String, value:String?, where statement:inout String, args arguments:inout [String], numericPlaceholder:inout Int) {
        if value == nil || value == "" {
            statement = "\(statement) AND (\(column)='' OR \(column) IS NULL)"
        }else{
            numericPlaceholder += 1
            statement = "\(statement) AND \(column)=$\(numericPlaceholder)"
            arguments.append(value!)
        }
    }
    
    static func appendSqlIntegerCondition(_ column:String, value:Int?, where statement:inout String) {
        if value == nil || value == 0 {
            statement = "\(statement) AND (\(column)=0 OR \(column) IS NULL)"
        }else{
            statement = "\(statement) AND \(column)=\(value ?? 0)"
        }
    }
    
    static func errorState(_ error:Error) -> ExecuteState {
        print(error)
        if error.localizedDescription.starts(with: "SQLite error") {
            if error.localizedDescription.hasSuffix("database is locked") {
                return .DATABASE_LOCKED
            }
            return .ERROR
        }
        return .NON_SQL_ERROR
    }
    
    static func inArray(field:String, array:[Any]?, where whereStmt:inout String, args sqlArgs:inout [Any], numericPlaceholders:Bool = false){
        if let array = array {
            if array.count > 0 {
                if numericPlaceholders {
                    var placeholders:[String] = []
                    for i in 1...array.count {
                        placeholders.append("$\(i)")
                    }
                    let marks = placeholders.joined(separator: ",")
                    whereStmt = "AND \(field) in (\(marks))"
                    sqlArgs.append(contentsOf: array)
                }else{
                    let marks = repeatElement("?", count: array.count).joined(separator: ",")
                    whereStmt = "AND \(field) in (\(marks))"
                    sqlArgs.append(contentsOf: array)
                }
            }
        }
    }
    
    static func likeArray(field:String, array:[Any]?, wildcardPrefix:Bool = true, wildcardSuffix:Bool = true) -> String{
        if let array = array {
            if array.count > 0 {
                var stmts:[String] = []
                let p = wildcardPrefix ? "'%" : "'"
                let s = wildcardSuffix ? "%'" : "'"
                for value in array {
                    if "\(value)" == "" {
                        stmts.append("\(field) is null")
                        stmts.append("\(field) = ''")
                    }
                    stmts.append("\(field) LIKE \(p)\(value)\(s)")
                }
                return stmts.joined(separator: " OR ")
            }
        }
        return ""
    }
    
    static func joinArrayToStatementCondition(values:[String], field:String, like:Bool = false) -> String {
        var statement = ""
        if values.count > 0 {
            for i in 0..<values.count {
                let value = values[i]
                if like {
                    statement += " \(field) like '%\(value)%' "
                }else{
                    statement += " \(field) = '\(value)' "
                }
                if i != (values.count - 1) {
                    statement += "OR"
                }
            }
        }
        return statement
    }
    
    static func joinArrayToStatementCondition(values:[Int], field:String) -> String {
        var statement = ""
        if values.count > 0 {
            for i in 0..<values.count {
                let value = values[i]
                statement += " \(field) = \(value) "
                if i != (values.count - 1) {
                    statement += "OR"
                }
            }
        }
        return statement
    }
    
    static func joinStatementConditions(conditions:[String], or:Bool = false) -> String {
        var statement = ""
        for i in 0..<conditions.count {
            let subStatement = conditions[i]
            if subStatement != "" {
                if statement != "" {
                    if or {
                        statement += " OR "
                    }else{
                        statement += " AND "
                    }
                }
                statement += "(\(subStatement))"
            }
        }
        return statement
    }
    
    internal static func _generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> (String,String) {
        
        print("SQL conditions: year=\(year) | month=\(month) | day=\(day) | ignoreDate:\(ignoreDate) | country=\(country) | province=\(province) | city=\(city) | place=\(place) | includeHidden=\(includeHidden)")
        
        var hiddenWhere = ""
        if !includeHidden {
            hiddenWhere = "AND hidden=false"
        }
        var placeWhere = ""
        if country != "" {
            placeWhere += " AND (country = '\(country)' OR \"assignCountry\" = '\(country)')"
        }
        if province != "" {
            placeWhere += " AND (province = '\(province)' OR \"assignProvince\" = '\(province)')"
        }
        if city != "" {
            placeWhere += " AND (city = '\(city)' OR \"assignCity\" = '\(city)')"
        }
        // FIXME
        if (place == nil || place == ""){
            
//            if country == "" && province == "" && city == "" {
//                placeWhere += " AND (place = '' OR place is null OR \"assignPlace\" = '' OR \"assignPlace\" is null)"
//            }else{
//                //
//                // ignore place
//            }
        }else {
            if country == "" && province == "" && city == "" {
                placeWhere = "AND (place = '\(place ?? "")' OR \"assignPlace\" = '\(place ?? "")' OR province = '\(place ?? "")' OR \"assignProvince\" = '\(place ?? "")' OR city = '\(place ?? "")' OR \"assignCity\" = '\(place ?? "")') "
            }else{
                if country == "中国" {
                    placeWhere += " AND (place = '\(place ?? "")' OR \"assignPlace\" = '\(place ?? "")') "
                }else{
                    placeWhere += " OR (place = '\(place ?? "")' OR \"assignPlace\" = '\(place ?? "")') "
                }
            }
        }
        
        
        var stmtWithoutHiddenWhere = ""
        
        if year == 0 && month == 0 && day == 0 {
            if ignoreDate {
                stmtWithoutHiddenWhere = "1=1 \(placeWhere)"
            }else{
                stmtWithoutHiddenWhere = "( (\"photoTakenYear\" = 0 and \"photoTakenMonth\" = 0 and \"photoTakenDay\" = 0) OR (\"photoTakenYear\" is null and \"photoTakenMonth\" is null and \"photoTakenDay\" is null) ) \(placeWhere)"
            }
        }else{
            if year == 0 {
                // no condition
            } else if month == 0 {
                stmtWithoutHiddenWhere = "\"photoTakenYear\" = \(year) \(placeWhere) \(hiddenWhere)"
            } else if day == 0 {
                stmtWithoutHiddenWhere = "\"photoTakenYear\" = \(year) and \"photoTakenMonth\" = \(month) \(placeWhere)"
            } else {
                stmtWithoutHiddenWhere = "\"photoTakenYear\" = \(year) and \"photoTakenMonth\" = \(month) and \"photoTakenDay\" = \(day) \(placeWhere)"
            }
        }
        
        return (stmtWithoutHiddenWhere, hiddenWhere)
    }
    
    // sql by date & place
    static func generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> (String, String, [Any]) {
        
        var (stmtWithoutHiddenWhere, hiddenWhere) = _generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
        
        var sqlArgs:[Any] = []
        
        SQLHelper.inArray(field: "imageSource", array: imageSource, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        SQLHelper.inArray(field: "cameraModel", array: cameraModel, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=true"
        
        print("SQL args: \(sqlArgs)")
        
        print("[GRDB Image] Generated SQL statement for all:")
        print(stmt)
        print("[GRDB Image] Generated SQL statement for hidden:")
        print(stmtHidden)
        
        return (stmt, stmtHidden, sqlArgs)
    }
    
    internal static func _generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> (String, String, Bool) {
        
        print("SQL conditions: year=\(year) | month=\(month) | day=\(day) | event=\(event) | country=\(country) | province=\(province) | city=\(city) | place=\(place) | includeHidden=\(includeHidden)")
        
        var hasEvent = false
        
        var eventWhere = ""
        if event == "" || event == "未分配事件" {
            eventWhere = "(event='' OR event is null)"
        }else{
            eventWhere = "event = $1"
            hasEvent = true
        }
        
        var hiddenWhere = ""
        if !includeHidden {
            hiddenWhere = "AND hidden=false"
        }
        var stmtWithoutHiddenWhere = ""
        
        if year == 0 {
            stmtWithoutHiddenWhere = "\(eventWhere) \(hiddenWhere)"
        } else if day == 0 {
            if month == 0 {
                stmtWithoutHiddenWhere = "\(eventWhere) and \"photoTakenYear\" = \(year) \(hiddenWhere)"
            }else{
                stmtWithoutHiddenWhere = "\(eventWhere) and \"photoTakenYear\" = \(year) and \"photoTakenMonth\" = \(month) \(hiddenWhere)"
            }
        } else {
            stmtWithoutHiddenWhere = "\(eventWhere) and \"photoTakenYear\" = \(year) and \"photoTakenMonth\" = \(month) and \"photoTakenDay\" = \(day) \(hiddenWhere)"
        }
        return (stmtWithoutHiddenWhere, hiddenWhere, hasEvent)
    }
    
    // sql by date & event & place
    static func generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> (String, String, [Any]) {
        
        var (stmtWithoutHiddenWhere, hiddenWhere, hasEvent) = _generateSQLStatementForPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
        
        var sqlArgs:[Any] = []
        if hasEvent {
            sqlArgs.append(event)
        }
        
        SQLHelper.inArray(field: "imageSource", array: imageSource, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        SQLHelper.inArray(field: "cameraModel", array: cameraModel, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=true"
        
        print("[GRDB Image -> Searching] Generated SQL statement for all:")
        print(stmt)
        print("[GRDB Image -> Searching] Generated SQL statement for hidden:")
        print(stmtHidden)
        print("SQL args: \(sqlArgs)")
        
        return (stmt, stmtHidden, sqlArgs)
    }
    
    // search sql by date & event & place
    static func generateSQLStatementForSearchingPhotoFiles(years:[Int], months:[Int], days:[Int], peopleIds:[String], keywords:[String], includeHidden:Bool = true) -> (String, String) {
        
        var hiddenFlagStatement = ""
        if !includeHidden {
            hiddenFlagStatement = "AND hidden=false AND \"hiddenByRepository\"=false AND \"hiddenByContainer\"=false"
        }
        let hiddenStatement = "AND (hidden=true OR \"hiddenByRepository\"=true OR \"hiddenByContainer\"=true)"
        
        let yearStatement = SQLHelper.joinArrayToStatementCondition(values: years, field: "photoTakenYear".quotedDatabaseIdentifier)
        let monthStatement = SQLHelper.joinArrayToStatementCondition(values: months, field: "photoTakenMonth".quotedDatabaseIdentifier)
        let dayStatement = SQLHelper.joinArrayToStatementCondition(values: days, field: "photoTakenDay".quotedDatabaseIdentifier)
        
        let dateStatement = SQLHelper.joinStatementConditions(conditions: [yearStatement, monthStatement, dayStatement])
        
        let peopleIdStatement = SQLHelper.joinArrayToStatementCondition(values: peopleIds, field: "recognizedPeopleIds".quotedDatabaseIdentifier, like: true)
        
        let eventStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "event".quotedDatabaseIdentifier, like: true)
        let longDescStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "longDescription".quotedDatabaseIdentifier, like: true)
        let shortDescStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "shortDescription".quotedDatabaseIdentifier, like: true)
        
        let placeStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "place".quotedDatabaseIdentifier, like: true)
        let countryStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "country".quotedDatabaseIdentifier, like: true)
        let provinceStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "province".quotedDatabaseIdentifier, like: true)
        let cityStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "city".quotedDatabaseIdentifier, like: true)
        let districtStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "district".quotedDatabaseIdentifier, like: true)
        let businessCircleStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "businessCircle".quotedDatabaseIdentifier, like: true)
        let streetStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "street".quotedDatabaseIdentifier, like: true)
        let addressStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "address".quotedDatabaseIdentifier, like: true)
        let addressDescStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "addressDescription".quotedDatabaseIdentifier, like: true)
        
        let assignPlaceStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "assignPlace".quotedDatabaseIdentifier, like: true)
        let assignCountryStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "assignCountry".quotedDatabaseIdentifier, like: true)
        let assignProvinceStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "assignProvince".quotedDatabaseIdentifier, like: true)
        let assignCityStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "assignCity".quotedDatabaseIdentifier, like: true)
        let assignDistrictStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "assignDistrict".quotedDatabaseIdentifier, like: true)
        let assignBusinessCircleStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "assignBusinessCircle".quotedDatabaseIdentifier, like: true)
        let assignStreetStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "assignStreet".quotedDatabaseIdentifier, like: true)
        let assignAddressStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "assignAddress".quotedDatabaseIdentifier, like: true)
        let assignAddressDescStatement = SQLHelper.joinArrayToStatementCondition(values: keywords, field: "assignAddressDescription".quotedDatabaseIdentifier, like: true)
        
        let keywordStatement = SQLHelper.joinStatementConditions(conditions: [
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
        
        let stmtWithoutHiddenFlag = SQLHelper.joinStatementConditions(conditions: [dateStatement, peopleIdStatement, keywordStatement])
        
        let stmt = "\(stmtWithoutHiddenFlag) \(hiddenFlagStatement)"
        let stmtHidden = "\(stmtWithoutHiddenFlag) \(hiddenStatement)"
        
        print("------")
        print(stmt)
        print("------")
        
        return (stmt, stmtHidden)
    }
    
}

