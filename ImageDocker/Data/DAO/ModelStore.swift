//
//  ModelStore.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/25.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation


enum ExecuteState : Int {
    case OK
    case DATABASE_LOCKED
    case NON_SQL_ERROR
    case ERROR
    case NO_RECORD
}

class ModelStore {
    
    static let localDBFile = PreferencesController.databasePath(filename: "ImageDocker.sqlite")
    
    static let `default` = ModelStoreGRDB()
    
    // MARK: - HELPER
    
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
    
    static func inArray(field:String, array:[Any]?, where whereStmt:inout String, args sqlArgs:inout [Any]){
        if let array = array {
            if array.count > 0 {
                let marks = repeatElement("?", count: array.count).joined(separator: ",")
                whereStmt = "AND \(field) in (\(marks))"
                sqlArgs.append(contentsOf: array)
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
}
