//
//  ImageContainer.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct ImageContainer: Codable {
    //var id: Int64?      // <- the row id
    var name: String
    var parentFolder: String
    var path: String
    var imageCount: Int
}

extension ImageContainer: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
