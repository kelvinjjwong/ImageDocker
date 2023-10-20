//
//  SQLHelper.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/10/20.
//  Copyright © 2023 nonamecat. All rights reserved.
//


import Foundation
import LoggerFactory

enum ExecuteState : Int {
    case OK
    case DATABASE_LOCKED
    case NON_SQL_ERROR
    case ERROR
    case NO_RECORD
}

struct SQLHelper {
    
    static let logger = LoggerFactory.get(category: "SQLHelper")
    
    /// - caller: NONE
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
        SQLHelper.logger.log(error)
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
    
}
