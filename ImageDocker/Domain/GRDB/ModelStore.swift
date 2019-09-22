//
//  ModelStore.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/7/14.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB



enum ExecuteState : Int {
    case OK
    case DATABASE_LOCKED
    case NON_SQL_ERROR
    case ERROR
    case NO_RECORD
}

class ModelStore {
    
    internal let dbfile = PreferencesController.databasePath(filename: "ImageDocker.sqlite")
    
    static let `default` = ModelStore()
    
    var _duplicates:Duplicates? = nil
    
    init(){
        self.checkDatabase()
        self.versionCheck()
    }
    
    // MARK: - SHARED DATABASE INSTANCE
    
    private static var _sharedDBPool:DatabaseWriter?
    
    static func sharedDBPool() -> DatabaseWriter{
        if _sharedDBPool == nil {
            do {
                //var config = Configuration()
                //config.trace = { print($0) }     // Prints all SQL statements
                
                _sharedDBPool = try DatabasePool(path: ModelStore.default.dbfile
                                                //, configuration: config
                                                )
            }catch{
                print(error) //SQLite error 5: database is locked
            }
            
        }
        return _sharedDBPool!
    }
    
    // MARK: - HEALTH CHECK
    
    func testDatabase() -> (Bool, Error?) {
        if ModelStore._sharedDBPool == nil {
//            if debug_attempt == debug_pass_at {
                do {
                    //var config = Configuration()
                    //config.trace = { print($0) }     // Prints all SQL statements
                    
                        ModelStore._sharedDBPool = try DatabasePool(path: ModelStore.default.dbfile
                        //, configuration: config
                        )
                }catch{
                    print(error) //SQLite error 5: database is locked
                    return (false, error)
                }
//            }else{
//                debug_attempt += 1
//            }
            if ModelStore._sharedDBPool == nil {
                return (false, nil)
            }else{
                return (true, nil)
            }
        }else{
            return (true, nil)
        }
    }
    
    func checkDatabase() {
        let dbpath = URL(fileURLWithPath: dbfile).deletingLastPathComponent().path
        if !FileManager.default.fileExists(atPath: dbpath) {
            do {
                try FileManager.default.createDirectory(atPath: dbpath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Unable to create directory for database file")
                print(error)
            }
        }
    }
    
    // MARK: - HELPER
    
    internal func errorState(_ error:Error) -> ExecuteState {
        print(error)
        if error.localizedDescription.starts(with: "SQLite error") {
            if error.localizedDescription.hasSuffix("database is locked") {
                return .DATABASE_LOCKED
            }
            return .ERROR
        }
        return .NON_SQL_ERROR
    }
    
    internal func inArray(field:String, array:[Any]?, where whereStmt:inout String, args sqlArgs:inout [Any]){
        if let array = array {
            if array.count > 0 {
                let marks = repeatElement("?", count: array.count).joined(separator: ",")
                whereStmt = "AND \(field) in (\(marks))"
                sqlArgs.append(contentsOf: array)
            }
        }
    }
    
    internal func likeArray(field:String, array:[Any]?, wildcardPrefix:Bool = true, wildcardSuffix:Bool = true) -> String{
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
    
    internal func joinArrayToStatementCondition(values:[String], field:String, like:Bool = false) -> String {
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
    
    internal func joinArrayToStatementCondition(values:[Int], field:String) -> String {
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
    
    internal func joinStatementConditions(conditions:[String], or:Bool = false) -> String {
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
