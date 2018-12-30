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
    var faceDisplayName: String?
    var majorFacePath: String?
    var facesPath: String?
}

extension People: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}

struct PeopleRelationship : Codable {
    //var id: Int64?      // <- the row id
    var primary: String
    var secondary: String
    var callName: String
}

extension PeopleRelationship: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
