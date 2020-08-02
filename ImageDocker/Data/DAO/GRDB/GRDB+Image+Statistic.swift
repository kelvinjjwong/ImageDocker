//
//  ModelStore+Image+Statistic.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class ImageCountDaoGRDB : ImageCountDaoInterface {
    
    // MARK: - COLLECTION

    // count by date & place
    func countPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (stmt, _, sqlArgs) = SQLHelper.generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs) ?? []).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // count by date & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (_, stmtHidden, sqlArgs) = SQLHelper.generateSQLStatementForPhotoFiles(year: year, month: month, day: day, ignoreDate:ignoreDate, country: country, province: province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmtHidden, arguments:StatementArguments(sqlArgs) ?? []).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // count by date & event & place
    func countPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (stmt, _, sqlArgs) = SQLHelper.generateSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmt, arguments:StatementArguments(sqlArgs) ?? []).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // count by date & event & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        let (_, stmtHidden, sqlArgs) = SQLHelper.generateSQLStatementForPhotoFiles(year: year, month:month, day:day, event:event, country:country, province:province, city:city, place:place, includeHidden:includeHidden, imageSource:imageSource, cameraModel:cameraModel)
        
        var result = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql:stmtHidden, arguments:StatementArguments(sqlArgs) ?? []).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - FACE
    
    func countImageWithoutFace(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath=? and hidden=0 and id not in (select distinct imageid from imageface)", arguments:[root]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func countImageNotYetFacialDetection(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(sql: "repositoryPath=? and hidden=0 and scanedFace<>1 and id not in (select distinct imageid from imageface)", arguments:[root]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - ID
    
    func countImageWithoutId(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "id is null and path like ?", arguments:[keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    // MARK: - PATH
    
    // count by path~
    func countPhotoFiles(rootPath:String) -> Int {
        var result:Int = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Image.filter(Column("path").like("\(rootPath)%")).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    
    func countImageWithoutRepositoryPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "repositoryPath='' and path like ?", arguments:[keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImageWithoutSubPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "subPath='' and path like ?", arguments:[keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImageUnmatchedRepositoryRoot(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "repositoryPath = ? and path not like ?", arguments: [root, keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countImages(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "path like ?", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countHiddenImages(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try Image.filter(sql: "path like ? and hidden = 1", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countContainersWithoutRepositoryPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try ImageContainer.filter(sql: "repositoryPath = '' and path like ?", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func countContainersWithoutSubPath(repositoryRoot:String) -> Int {
        var result = 0
        let root = repositoryRoot.withStash()
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let keyword = "\(root)%"
                result = try ImageContainer.filter(sql: "subPath = '' and path like ?", arguments: [keyword]).fetchCount(db)
            }
        }catch{
            print(error)
        }
        return result
        
    }
}
