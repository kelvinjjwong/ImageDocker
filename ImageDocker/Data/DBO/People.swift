//
//  People.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/29.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import PostgresModelFactory

public final class People : Codable {
    //var id: Int64?      // <- the row id
    var id: String = ""
    var name: String = ""
    var shortName: String? = nil
    var iconRepositoryPath:String = ""
    var iconCropPath:String = ""
    var iconSubPath:String = ""
    var iconFilename:String = ""
    var coreMember:Bool = false
    var coreMemberColor:String = ""
    
    public init() {
        
    }
    
    static func new(id:String, name:String, shortName:String) -> People{
        let people = People()
        people.id = id
        people.name = name
        people.shortName = shortName
        return people
    }
    
    static func unknown() -> People {
        let people = People()
        people.name = "Unknown"
        people.shortName = "Unknown"
        return people
    }
}

//extension People: FetchableRecord, MutablePersistableRecord, TableRecord {
//
//}

extension People : PostgresRecord {
    
    public func postgresTable() -> String {
        return "People"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}

public final class PeopleRelationship : Codable {
    //var id: Int64?      // <- the row id
    var subject: String = ""
    var object: String = ""
    var callName: String = ""
    
    public init() {
        
    }
}

//extension PeopleRelationship: FetchableRecord, MutablePersistableRecord, TableRecord {
//
//}


extension PeopleRelationship : PostgresRecord {
    public func postgresTable() -> String {
        return "PeopleRelationship"
    }
    
    public func primaryKeys() -> [String] {
        return ["subject", "object"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
