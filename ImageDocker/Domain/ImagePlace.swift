//
//  ImagePlace.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct ImagePlace : Codable {
    //var id: Int64?      // <- the row id
    var name: String
    var country: String?
    var province: String?
    var city: String?
    var district: String?
    var businessCircle: String?
    var street: String?
    var address: String?
    var addressDescription: String?
    var latitude:String?
    var latitudeBD:String?
    var longitude:String?
    var longitudeBD:String?
}

extension ImagePlace: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
