//
//  Family.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/29.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB
import PostgresModelFactory

public final class Family : Codable {
    //var id: Int64?      // <- the row id
    var id: String = ""
    var name: String = ""
    var category: String?
    
    public init() {
        
    }
}

extension Family: FetchableRecord, MutablePersistableRecord, TableRecord {
    
}

extension Family : PostgresRecord {
    public func postgresTable() -> String {
        return "Family"
    }
    
    public func primaryKeys() -> [String] {
        return ["id"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}

public final class FamilyMember : Codable {
    //var id: Int64?      // <- the row id
    var familyId: String = ""
    var peopleId: String = ""
    
    public init() {
        
    }
}

extension FamilyMember: FetchableRecord, MutablePersistableRecord, TableRecord {

}

extension FamilyMember : PostgresRecord {
    public func postgresTable() -> String {
        return "FamilyMember"
    }
    
    public func primaryKeys() -> [String] {
        return ["familyId", "peopleId"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}

public final class FamilyJoint : Codable {
    //var id: Int64?      // <- the row id
    var bigFamilyId: String = ""
    var smallFamilyId: String = ""
    
    public init() {
        
    }
}

extension FamilyJoint: FetchableRecord, MutablePersistableRecord, TableRecord {

}


extension FamilyJoint : PostgresRecord {
    public func postgresTable() -> String {
        return "FamilyJoint"
    }
    
    public func primaryKeys() -> [String] {
        return ["bigFamilyId", "smallFamilyid"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
