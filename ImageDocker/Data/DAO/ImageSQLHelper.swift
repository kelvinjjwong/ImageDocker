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
    
    static func joinStatementConditions(fields:[String], values:[String], like:Bool = false, or:Bool = false, quoteColumn:Bool = false) -> String {
        if fields.count == 0 || values.count == 0 {return ""}
        var conditions:[String] = []
        for field in fields {
            let conditionStatement = joinArrayToStatementCondition(field: field, values: values, like: like, quoteColumn: quoteColumn)
            conditions.append(conditionStatement)
        }
        return joinStatementConditions(conditions: conditions, or: or)
    }
    
    static func joinArrayToStatementCondition(field:String, values:[String], like:Bool = false, quoteColumn:Bool = false) -> String {
        var statement = ""
        if values.count > 0 {
            for i in 0..<values.count {
                let value = values[i]
                if value.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    if quoteColumn {

                        if like {
                            statement += " \(field.quotedDatabaseIdentifier) like '%\(value)%' "
                        }else{
                            statement += " \(field.quotedDatabaseIdentifier) = '\(value)' "
                        }
                    }else{

                        if like {
                            statement += " \(field) like '%\(value)%' "
                        }else{
                            statement += " \(field) = '\(value)' "
                        }
                    }
                    if i != (values.count - 1) {
                        statement += "OR"
                    }
                }
            }
        }
        return statement
    }
    
    static func joinArrayToStatementCondition(field:String, values:[Int], quoteColumn:Bool = false) -> String {
        var statement = ""
        if values.count > 0 {
            for i in 0..<values.count {
                let value = values[i]
                if quoteColumn {
                    statement += " \(field.quotedDatabaseIdentifier) = \(value) "
                }else{
                    statement += " \(field) = \(value) "
                }
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
            stmtWithoutHiddenWhere = "\(eventWhere) and \"photoTakenYear\" is null \(hiddenWhere)"
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
    
    static func generateSQLStatementForSearchingPhotoFiles(condition:SearchCondition, includeHidden:Bool = true, quoteColumn:Bool = false) -> (String, String) {
        
        var hiddenFlagStatement = ""
        
        // exclude any hidden=true, otherwise no limit on hidden flags
        if !includeHidden {
            hiddenFlagStatement = "AND hidden=false AND \"hiddenByRepository\"=false AND \"hiddenByContainer\"=false"
        }
        //let hiddenStatement = "AND (hidden=true OR \"hiddenByRepository\"=true OR \"hiddenByContainer\"=true)"
        
        let yearStatement = SQLHelper.joinArrayToStatementCondition(field: "photoTakenYear", values: condition.years, quoteColumn: quoteColumn)
        let monthStatement = SQLHelper.joinArrayToStatementCondition(field: "photoTakenMonth", values: condition.months, quoteColumn: quoteColumn)
        let dayStatement = SQLHelper.joinArrayToStatementCondition(field: "photoTakenDay", values: condition.days, quoteColumn: quoteColumn)
        
        // let peopleIdStatement = SQLHelper.joinArrayToStatementCondition(values: condition.peopleIds, field: "recognizedPeopleIds".quotedDatabaseIdentifier, like: true)
        
        let eventStatement = SQLHelper.joinArrayToStatementCondition(field: "event", values: condition.events, like: true, quoteColumn: quoteColumn)
        
        let notesStatement = SQLHelper.joinStatementConditions(fields: [
            "longDescription",
            "shortDescription"
        ], values: condition.notes, like: true, or: true, quoteColumn: quoteColumn)
        
        let placesStatement = SQLHelper.joinStatementConditions(fields: [
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
            "assignAddressDescription"
        ], values: condition.places, like: true, or: true, quoteColumn: quoteColumn)
        
        let camerasStatement = SQLHelper.joinStatementConditions(fields: [
            "cameraMaker",
            "cameraModel",
            "softwareName"
        ], values: condition.cameras, like: true, or: true, quoteColumn: quoteColumn)
        
        let folderStatement = SQLHelper.joinArrayToStatementCondition(field: "path", values: condition.folders, like: true, quoteColumn: quoteColumn)
        
        let filenameStatement = SQLHelper.joinArrayToStatementCondition(field: "filename", values: condition.filenames, like: true, quoteColumn: quoteColumn)
        
        let anyStatement = SQLHelper.joinStatementConditions(fields: [
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
        ], values: condition.any, like: true, or: true, quoteColumn: quoteColumn)
        
        let stmtWithoutHiddenFlag = SQLHelper.joinStatementConditions(conditions: [
            
            yearStatement,
            monthStatement,
            dayStatement,
            
            eventStatement,
            notesStatement,
            placesStatement,
            camerasStatement,
            
            folderStatement,
            filenameStatement,
            
            anyStatement
            
        ], or: false)
        
        let stmt = "\(stmtWithoutHiddenFlag) \(hiddenFlagStatement)"
        let stmtHidden = "\(stmtWithoutHiddenFlag) "
        
        print("------")
        print(stmt)
        print("------")
        
        return (stmt, stmtHidden)
    }
    
}

