//
//  ImageSQLHelper+PostgresClientKit.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/5/4.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit

extension SQLHelper {
    
    
    static func inPostgresArray(field:String, array:[PostgresValueConvertible]?, where whereStmt:inout String, args sqlArgs:inout [PostgresValueConvertible], numericPlaceholders:Bool = false){
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
    
    // sql by date & place
    static func generatePostgresSQLStatementForPhotoFiles(filter:CollectionFilter, year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?) -> (String, String, [PostgresValueConvertible]) {
        
        var (stmtWithoutHiddenWhere, hiddenWhere) = _generateSQLStatementForPhotoFiles(filter: filter, year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place)
        
        var sqlArgs:[PostgresValueConvertible] = []
        
//        SQLHelper.inPostgresArray(field: "imageSource", array: imageSource, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
//        SQLHelper.inPostgresArray(field: "cameraModel", array: cameraModel, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        
        if !filter.includePhoto {
            stmtWithoutHiddenWhere += " and lower((regexp_split_to_array(filename, '\\.'))[array_upper(regexp_split_to_array(filename, '\\.'), 1)]) not in (\(FileTypeRecognizer.photoExts.joinedSingleQuoted(separator: ",")))"
        }
        
        if !filter.includeVideo {
            stmtWithoutHiddenWhere += " and lower((regexp_split_to_array(filename, '\\.'))[array_upper(regexp_split_to_array(filename, '\\.'), 1)]) not in (\(FileTypeRecognizer.videoExts.joinedSingleQuoted(separator: ",")))"
        }
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=true"
        
        self.logger.log("[Postgres Image] Generated SQL statement for all: \(stmt)")
        self.logger.log("[Postgres Image] Generated SQL statement for hidden: \(stmtHidden)")
        self.logger.log("[Postgres Image] SQL args: \(sqlArgs)")
        
        return (stmt, stmtHidden, sqlArgs)
    }
    
    // sql by date & event & place
    static func generatePostgresSQLStatementForPhotoFiles(filter:CollectionFilter, year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "") -> (String, String, [PostgresValueConvertible]) {
        
        var (stmtWithoutHiddenWhere, hiddenWhere, hasEvent) = _generateSQLStatementForPhotoFiles(filter: filter, year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place)
        
        var sqlArgs:[PostgresValueConvertible] = []
        if hasEvent {
            sqlArgs.append(event)
        }
        
//        SQLHelper.inPostgresArray(field: "imageSource", array: imageSource, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
//        SQLHelper.inPostgresArray(field: "cameraModel", array: cameraModel, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        
        if !filter.includePhoto {
            stmtWithoutHiddenWhere += " and lower((regexp_split_to_array(filename, '\\.'))[array_upper(regexp_split_to_array(filename, '\\.'), 1)]) not in (\(FileTypeRecognizer.photoExts.joinedSingleQuoted(separator: ","))"
        }
        
        if !filter.includeVideo {
            stmtWithoutHiddenWhere += " and lower((regexp_split_to_array(filename, '\\.'))[array_upper(regexp_split_to_array(filename, '\\.'), 1)]) not in (\(FileTypeRecognizer.videoExts.joinedSingleQuoted(separator: ","))"
        }
        
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=true"
        
        self.logger.log("[Postgres Image -> Searching] Generated SQL statement for all: \(stmt)")
        self.logger.log("[Postgres Image -> Searching] Generated SQL statement for hidden: \(stmtHidden)")
        self.logger.log("[Postgres Image -> Searching] SQL args: \(sqlArgs)")
        
        return (stmt, stmtHidden, sqlArgs)
    }
}
