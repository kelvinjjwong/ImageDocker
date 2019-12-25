//
//  People.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/29.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct People : Codable {
    //var id: Int64?      // <- the row id
    var id: String
    var name: String
    var shortName: String?
    var iconRepositoryPath:String
    var iconCropPath:String
    var iconSubPath:String
    var iconFilename:String
    
    static func new(id:String, name:String, shortName:String) -> People{
        return People(id: id, name: name, shortName: shortName,
                      iconRepositoryPath: "", iconCropPath: "", iconSubPath: "", iconFilename: "")
    }
    
    static func unknown() -> People {
        return People(id: "", name: "Unknown", shortName: "Unknown",
                      iconRepositoryPath: "", iconCropPath: "", iconSubPath: "", iconFilename: "")
    }
}

extension People: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}

struct PeopleRelationship : Codable {
    //var id: Int64?      // <- the row id
    var subject: String
    var object: String
    var callName: String
}

extension PeopleRelationship: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
