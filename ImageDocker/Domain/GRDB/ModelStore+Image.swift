//
//  ModelStore+Image.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStore {
    
    
    // MARK: - CREATE
    
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String? = nil, sharedDB:DatabaseWriter? = nil) -> Image{
        var image:Image?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                image = try Image.fetchOne(db, key: path)
            }
            if image == nil {
                let queue = try sharedDB ?? DatabaseQueue(path: dbfile)
                try queue.write { db in
                    image = Image.new(filename: filename, path: path, parentFolder: parentPath, repositoryPath: repositoryPath ?? "")
                    try image?.save(db)
                }
                
            }
        }catch{
            print(error)
        }
        return image!
    }
    
    // MARK: - GETTER
    
    func getImage(path:String) -> Image?{
        var image:Image?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                image = try Image.fetchOne(db, key: path)
            }
        }catch{
            print(error)
        }
        return image
    }
    
    func getImage(id:String) -> Image? {
        var image:Image?
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                image = try Image.filter(sql: "id='\(id)'").fetchOne(db)
            }
        }catch{
            print(error)
        }
        return image
    }
    
    // MARK: - HELPER
    
    // sql by date & place
    internal func generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> (String, String, [Any]) {
        
        print("\(year) | \(month) | \(day) | ignoreDate:\(ignoreDate) | \(country) | \(province) | \(city)")
        
        var hiddenWhere = ""
        if !includeHidden {
            hiddenWhere = "AND hidden=0"
        }
        var placeWhere = ""
        if (place == nil || place == ""){
            if country != "" {
                placeWhere += " AND (country = '\(country)' OR assignCountry = '\(country)')"
            }
            if province != "" {
                placeWhere += " AND (province = '\(province)' OR assignProvince = '\(province)')"
            }
            if city != "" {
                placeWhere += " AND (city = '\(city)' OR assignCity = '\(city)')"
            }
        }else {
            placeWhere = "AND (place = '\(place ?? "")' OR assignPlace = '\(place ?? "")') "
        }
        
        
        var stmtWithoutHiddenWhere = ""
        
        if year == 0 && month == 0 && day == 0 {
            if ignoreDate {
                stmtWithoutHiddenWhere = "1=1 \(placeWhere)"
            }else{
                stmtWithoutHiddenWhere = "( (photoTakenYear = 0 and photoTakenMonth = 0 and photoTakenDay = 0) OR (photoTakenYear is null and photoTakenMonth is null and photoTakenDay is null) ) \(placeWhere)"
            }
        }else{
            if year == 0 {
                // no condition
            } else if month == 0 {
                stmtWithoutHiddenWhere = "photoTakenYear = \(year) \(placeWhere) \(hiddenWhere)"
            } else if day == 0 {
                stmtWithoutHiddenWhere = "photoTakenYear = \(year) and photoTakenMonth = \(month) \(placeWhere)"
            } else {
                stmtWithoutHiddenWhere = "photoTakenYear = \(year) and photoTakenMonth = \(month) and photoTakenDay = \(day) \(placeWhere)"
            }
        }
        
        var sqlArgs:[Any] = []
        
        self.inArray(field: "imageSource", array: imageSource, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        self.inArray(field: "cameraModel", array: cameraModel, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=1"
        
        print(stmt)
        
        return (stmt, stmtHidden, sqlArgs)
    }
    
    // sql by date & event & place
    internal func generateSQLStatementForPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> (String, String, [Any]) {
        
        print("\(year) | \(month) | \(day) | event:\(event) | \(country) | \(province) | \(city)")
        
        var hiddenWhere = ""
        if !includeHidden {
            hiddenWhere = "AND hidden=0"
        }
        var stmtWithoutHiddenWhere = ""
        
        if year == 0 {
            stmtWithoutHiddenWhere = "event = '\(event)' \(hiddenWhere)"
        } else if day == 0 {
            stmtWithoutHiddenWhere = "event = '\(event)' and photoTakenYear = \(year) and photoTakenMonth = \(month) \(hiddenWhere)"
        } else {
            stmtWithoutHiddenWhere = "event = '\(event)' and photoTakenYear = \(year) and photoTakenMonth = \(month) and photoTakenDay = \(day) \(hiddenWhere)"
        }
        
        var sqlArgs:[Any] = []
        
        self.inArray(field: "imageSource", array: imageSource, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        self.inArray(field: "cameraModel", array: cameraModel, where: &stmtWithoutHiddenWhere, args: &sqlArgs)
        
        let stmt = "\(stmtWithoutHiddenWhere) \(hiddenWhere)"
        let stmtHidden = "\(stmtWithoutHiddenWhere) AND hidden=1"
        
        print(stmt)
        
        return (stmt, stmtHidden, sqlArgs)
    }
    
    // search sql by date & event & place
    internal func generateSQLStatementForSearchingPhotoFiles(years:[Int], months:[Int], days:[Int], peopleIds:[String], keywords:[String], includeHidden:Bool = true) -> (String, String) {
        
        var hiddenFlagStatement = ""
        if !includeHidden {
            hiddenFlagStatement = "AND hidden=0 AND hiddenByRepository=0 AND hiddenByContainer=0"
        }
        let hiddenStatement = "AND (hidden=1 OR hiddenByRepository=1 OR hiddenByContainer=1)"
        
        let yearStatement = self.joinArrayToStatementCondition(values: years, field: "photoTakenYear")
        let monthStatement = self.joinArrayToStatementCondition(values: months, field: "photoTakenMonth")
        let dayStatement = self.joinArrayToStatementCondition(values: days, field: "photoTakenDay")
        
        let dateStatement = self.joinStatementConditions(conditions: [yearStatement, monthStatement, dayStatement])
        
        let peopleIdStatement = self.joinArrayToStatementCondition(values: peopleIds, field: "recognizedPeopleIds", like: true)
        
        let eventStatement = self.joinArrayToStatementCondition(values: keywords, field: "event", like: true)
        let longDescStatement = self.joinArrayToStatementCondition(values: keywords, field: "longDescription", like: true)
        let shortDescStatement = self.joinArrayToStatementCondition(values: keywords, field: "shortDescription", like: true)
        
        let placeStatement = self.joinArrayToStatementCondition(values: keywords, field: "place", like: true)
        let countryStatement = self.joinArrayToStatementCondition(values: keywords, field: "country", like: true)
        let provinceStatement = self.joinArrayToStatementCondition(values: keywords, field: "province", like: true)
        let cityStatement = self.joinArrayToStatementCondition(values: keywords, field: "city", like: true)
        let districtStatement = self.joinArrayToStatementCondition(values: keywords, field: "district", like: true)
        let businessCircleStatement = self.joinArrayToStatementCondition(values: keywords, field: "businessCircle", like: true)
        let streetStatement = self.joinArrayToStatementCondition(values: keywords, field: "street", like: true)
        let addressStatement = self.joinArrayToStatementCondition(values: keywords, field: "address", like: true)
        let addressDescStatement = self.joinArrayToStatementCondition(values: keywords, field: "addressDescription", like: true)
        
        let assignPlaceStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignPlace", like: true)
        let assignCountryStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignCountry", like: true)
        let assignProvinceStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignProvince", like: true)
        let assignCityStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignCity", like: true)
        let assignDistrictStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignDistrict", like: true)
        let assignBusinessCircleStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignBusinessCircle", like: true)
        let assignStreetStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignStreet", like: true)
        let assignAddressStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignAddress", like: true)
        let assignAddressDescStatement = self.joinArrayToStatementCondition(values: keywords, field: "assignAddressDescription", like: true)
        
        let keywordStatement = self.joinStatementConditions(conditions: [
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
        
        let stmtWithoutHiddenFlag = self.joinStatementConditions(conditions: [dateStatement, peopleIdStatement, keywordStatement])
        
        let stmt = "\(stmtWithoutHiddenFlag) \(hiddenFlagStatement)"
        let stmtHidden = "\(stmtWithoutHiddenFlag) \(hiddenStatement)"
        
        print("------")
        print(stmt)
        print("------")
        
        return (stmt, stmtHidden)
    }
    
}
