//
//  ImagePeople.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/29.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct ImagePeople : Codable {
    //var id: Int64?      // <- the row id
    var imageId: String
    var peopleId: String
    var position: String?
}

extension ImagePeople: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
