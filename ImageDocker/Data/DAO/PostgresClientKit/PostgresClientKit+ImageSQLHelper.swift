//
//  ImageSQLHelper+PostgresClientKit.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/5/4.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresModelFactory

extension SQLHelper {
    
    static func inPostgresArray(field:String, array:[DatabaseValueConvertible]?, where whereStmt:inout String, args sqlArgs:inout [DatabaseValueConvertible], numericPlaceholders:Bool = false){
        if let array = array {
            if array.count > 0 {
                if numericPlaceholders {
                    var placeholders:[String] = []
                    for i in 1...array.count {
                        placeholders.append("$\(i)")
                    }
                    let marks = placeholders.joined(separator: ",")
                    whereStmt = "AND \(field.quotedDatabaseIdentifier) in (\(marks))"
                    sqlArgs.append(contentsOf: array)
                }else{
                    let marks = repeatElement("?", count: array.count).joined(separator: ",")
                    whereStmt = "AND \(field.quotedDatabaseIdentifier) in (\(marks))"
                    sqlArgs.append(contentsOf: array)
                }
            }
        }
    }
}

extension ImageSQLHelper {
    
    // sql by container
    static func generatePostgresSQLStatement(filter:CollectionFilter) -> (String, String) {
        self.logger.log("[generatePostgresSQLStatement] filter: \(filter.represent())")
        
        var hiddenWhere = ""
        if filter.includeHidden == .ShowOnly {
            hiddenWhere = "AND hidden=false"
        }else if filter.includeHidden == .HiddenOnly {
            hiddenWhere = "AND hidden=true"
        }
        
        var stmt = ""
        
        if !filter.repositoryOwners.isEmpty {
            stmt += " and (\(SQLHelper.joinArrayToStatementCondition(field: "repositoryId", values: filter.getRepositoryIds(), quoteColumn: true)))"
        }
        if !filter.eventCategories.isEmpty {
            stmt += " and (\(SQLHelper.joinArrayToStatementCondition(field: "event", values: filter.getEvents(), quoteColumn: true)))"
        }
        if !filter.imageSources.isEmpty {
            stmt += " and (\(SQLHelper.joinArrayToStatementCondition(field: "imageSource", values: filter.getImageSources(), quoteColumn: true)))"
        }
        
        if !filter.includePhoto {
            stmt += " and lower((regexp_split_to_array(filename, '\\.'))[array_upper(regexp_split_to_array(filename, '\\.'), 1)]) not in (\(FileTypeRecognizer.photoExts.joinedSingleQuoted(separator: ",")))"
        }
        
        if !filter.includeVideo {
            stmt += " and lower((regexp_split_to_array(filename, '\\.'))[array_upper(regexp_split_to_array(filename, '\\.'), 1)]) not in (\(FileTypeRecognizer.videoExts.joinedSingleQuoted(separator: ",")))"
        }
        
        if filter.limitWidth && filter.width > 0 {
            var op = filter.opWidth
            if filter.opWidth == "≤" {
                op = "<="
            }else if filter.opWidth == "≥" {
                op = ">="
            }
            stmt += " and \"imageWidth\"\(op)\(filter.width)"
        }
        
        if filter.limitHeight && filter.height > 0 {
            var op = filter.opHeight
            if filter.opHeight == "≤" {
                op = "<="
            }else if filter.opHeight == "≥" {
                op = ">="
            }
            stmt += " and \"imageHeight\"\(op)\(filter.height)"
        }
        
        return (stmt, hiddenWhere)
    }
    
    // sql by date & place
    static func generatePostgresSQLStatementForPhotoFiles(filter:CollectionFilter, year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?) -> (String, String, [DatabaseValueConvertible]) {
        
        var stmtWithoutHiddenWhere = _generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place)
        
        var sqlArgs:[DatabaseValueConvertible] = []
        
        let (stmtBase, hiddenWhere) = self.generatePostgresSQLStatement(filter: filter)
        
        stmtWithoutHiddenWhere += stmtBase
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=true"
        
        self.logger.log("[Postgres Image] Generated SQL statement for all: \(stmt)")
        self.logger.log("[Postgres Image] Generated SQL statement for hidden: \(stmtHidden)")
        self.logger.log("[Postgres Image] SQL args: \(sqlArgs)")
        
        return (stmt, stmtHidden, sqlArgs)
    }
    
    // sql by date & event & place
    static func generatePostgresSQLStatementForPhotoFiles(filter:CollectionFilter, year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "") -> (String, String, [DatabaseValueConvertible]) {
        
        var (stmtWithoutHiddenWhere, hasEvent) = _generateSQLStatementForPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place)
        
        var sqlArgs:[DatabaseValueConvertible] = []
        if hasEvent {
            sqlArgs.append(event)
        }
        
        let (stmtBase, hiddenWhere) = self.generatePostgresSQLStatement(filter: filter)
        
        stmtWithoutHiddenWhere += stmtBase
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=true"
        
        self.logger.log("[Postgres Image -> Searching] Generated SQL statement for all: \(stmt)")
        self.logger.log("[Postgres Image -> Searching] Generated SQL statement for hidden: \(stmtHidden)")
        self.logger.log("[Postgres Image -> Searching] SQL args: \(sqlArgs)")
        
        return (stmt, stmtHidden, sqlArgs)
    }
}
