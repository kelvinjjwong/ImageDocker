//
//  Family.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/29.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct Family : Codable {
    //var id: Int64?      // <- the row id
    var id: String
    var name: String
    var category: String?
}

extension Family: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}

struct FamilyMember : Codable {
    //var id: Int64?      // <- the row id
    var familyId: String
    var peopleId: String
}

extension FamilyMember: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}

struct FamilyJoint : Codable {
    //var id: Int64?      // <- the row id
    var bigFamilyId: String
    var smallFamilyId: String
}

extension FamilyJoint: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
