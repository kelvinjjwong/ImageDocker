//
//  ImageSQLHelper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory


struct ImageSQLHelper {
    
    static let logger = LoggerFactory.get(category: "ImageSQLHelper")
    
    internal static func _generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?) -> String {
        
        self.logger.log("[Shared Image List] SQL conditions: year=\(year) | month=\(month) | day=\(day) | ignoreDate:\(ignoreDate) | country=\(country) | province=\(province) | city=\(city) | place=\(place ?? "")")
        
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
        if (place == nil || place == ""){
            self.logger.log(.error, "[_generateSQLStatementForPhotoFiles] place is nil or empty")
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
                stmtWithoutHiddenWhere = "\(placeWhere)"
            } else if month == 0 {
                stmtWithoutHiddenWhere = "\"photoTakenYear\" = \(year) \(placeWhere)"
            } else if day == 0 {
                stmtWithoutHiddenWhere = "\"photoTakenYear\" = \(year) and \"photoTakenMonth\" = \(month) \(placeWhere)"
            } else {
                stmtWithoutHiddenWhere = "\"photoTakenYear\" = \(year) and \"photoTakenMonth\" = \(month) and \"photoTakenDay\" = \(day) \(placeWhere)"
            }
        }
        
        return stmtWithoutHiddenWhere
    }
    
    internal static func _generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "") -> (String, Bool) {
        
        SQLHelper.logger.log("[Shared Image List] SQL conditions: year=\(year) | month=\(month) | day=\(day) | event=\(event) | country=\(country) | province=\(province) | city=\(city) | place=\(place)")
        
        var hasEvent = false
        
        var eventWhere = ""
        if event == "" || event == "未分配事件" {
            eventWhere = "(event='' OR event is null)"
        }else{
            eventWhere = "event = $1"
            hasEvent = true
        }
        
        var stmtWithoutHiddenWhere = ""
        
        if year == 0 {
            stmtWithoutHiddenWhere = "\(eventWhere) and \"photoTakenYear\" is null "
        } else if day == 0 {
            if month == 0 {
                stmtWithoutHiddenWhere = "\(eventWhere) and \"photoTakenYear\" = \(year) "
            }else{
                stmtWithoutHiddenWhere = "\(eventWhere) and \"photoTakenYear\" = \(year) and \"photoTakenMonth\" = \(month) "
            }
        } else {
            stmtWithoutHiddenWhere = "\(eventWhere) and \"photoTakenYear\" = \(year) and \"photoTakenMonth\" = \(month) and \"photoTakenDay\" = \(day) "
        }
        
        return (stmtWithoutHiddenWhere, hasEvent)
    }
    
    static func generateSQLStatementForSearchingPhotoFiles(condition:SearchCondition, includeHidden:Bool = true, quoteColumn:Bool = false) -> (String, String) {
        var hiddenFlagStatement = ""
        
        // exclude any hidden=true, otherwise no limit on hidden flags
        if !includeHidden {
            hiddenFlagStatement = "AND hidden=false AND \"hiddenByRepository\"=false AND \"hiddenByContainer\"=false"
        }
        //let hiddenStatement = "AND (hidden=true OR \"hiddenByRepository\"=true OR \"hiddenByContainer\"=true)"
        
        let filterRepositoryIdStatement = SQLHelper.joinArrayToStatementCondition(field: "repositoryId", values: condition.filter.getRepositoryIds(), quoteColumn: quoteColumn)
        let filterEventStatement = SQLHelper.joinArrayToStatementCondition(field: "event", values: condition.filter.getEvents(), quoteColumn: quoteColumn)
        let filterImageSourceStatement = SQLHelper.joinArrayToStatementCondition(field: "event", values: condition.filter.getImageSources(), quoteColumn: quoteColumn)
        
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
            
            filterRepositoryIdStatement,
            filterImageSourceStatement,
            filterEventStatement,
            
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
        
        SQLHelper.logger.log("------")
        SQLHelper.logger.log(stmt)
        SQLHelper.logger.log("------")
        
        return (stmt, stmtHidden)
    }
    
}

