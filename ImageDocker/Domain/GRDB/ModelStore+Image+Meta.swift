//
//  ModelStore+Image+Meta.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStore {
    
    // MARK: - Options
    
    func getImageSources() -> [String:Bool]{
        var results:[String:Bool] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT DISTINCT imageSource FROM Image")
                for row in rows {
                    let src = row["imageSource"] as String?
                    if let src = src, src != "" {
                        results[src] = false
                    }
                }
            }
        }catch{
            print(error)
        }
        
        return results
    }
    
    func getCameraModel() -> [String:Bool] {
        var results:[String:Bool] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT DISTINCT cameraMaker,cameraModel FROM Image")
                for row in rows {
                    let name1:String = row["cameraMaker"] ?? ""
                    let name2:String = row["cameraModel"] ?? ""
                    if name1 != "" && name2 != "" {
                        results["\(name1),\(name2)"] = false
                    }
                }
            }
        }catch{
            print(error)
        }
        
        return results
    }
    
    // MARK: - DATE
    
    func getAllDates(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Row] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = """
        SELECT photoTakenYear, photoTakenMonth, photoTakenDay, count(path) as photoCount FROM
        (SELECT IFNULL(photoTakenYear,0) AS photoTakenYear, IFNULL(photoTakenMonth,0) AS photoTakenMonth, IFNULL(photoTakenDay,0) AS photoTakenDay, path, imageSource, cameraModel from Image)
        WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY photoTakenYear,photoTakenMonth,photoTakenDay ORDER BY photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC
        """
        print(sql)
        var result:[Row] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql, arguments:StatementArguments(sqlArgs))
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getAllPlacesAndDates(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Row] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
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
        var result:[Row] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql, arguments:StatementArguments(sqlArgs))
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getYears(event:String? = nil) -> [Int] {
        var condition = ""
        var args:[String] = []
        if let ev = event {
            condition = " where event=? "
            args.append(ev)
        }
        let sql = "select distinct photoTakenYear from image \(condition) order by photoTakenYear desc"
        
        var result:[Int] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql, arguments:StatementArguments(args))
                for row in rows {
                    let year = row["photoTakenYear"] as Int? ?? 0
                    result.append(year)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getDatesByYear(year:Int, event:String? = nil) -> [String:[String]] {
        var sql = "select distinct photoTakenMonth,photoTakenDay from image where photoTakenYear=? order by photoTakenMonth,photoTakenDay"
        var args:[Any] = [year]
        
        if let ev = event, ev != "" {
            sql = "select distinct photoTakenMonth,photoTakenDay from image where photoTakenYear=? and event=? order by photoTakenMonth,photoTakenDay"
            args.append(ev)
        }
        
        //print(sql)
        var result:[String:[String]] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql, arguments:StatementArguments(args))
                for row in rows {
                    let month = row["photoTakenMonth"] as Int? ?? 0
                    let day = row["photoTakenDay"] as Int? ?? 0
                    if result["\(month)"] == nil {
                        result["\(month)"] = []
                    }
                    result["\(month)"]?.append("\(day)")
                }
            }
        }catch{
            print(error)
        }
        return result
    }

}
