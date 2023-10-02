//
//  ImageEvent.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import PostgresModelFactory

public final class ImageEvent : Codable {
    //var id: Int64?      // <- the row id
    var name: String = ""
    var startDate: Date?
    var startYear: Int?
    var startMonth: Int?
    var startDay: Int?
    var endDate: Date?
    var endYear: Int?
    var endMonth: Int?
    var endDay: Int?
    var category: String = ""
    var owner: String = ""
    var ownerAge: String = ""
    var attenders: String = ""
    var family: String = ""
    var activity1: String = ""
    var activity2: String = ""
    var imageCount: Int = 0
    var note: String = ""
    var lastUpdateTime: Date?
    var ownerNickname: String = ""
    var ownerId: String = ""
    var owner2: String = ""
    var owner2Nickname: String = ""
    var owner2Id: String = ""
    var owner3: String = ""
    var owner3Nickname: String = ""
    var owner3Id: String = ""
    
    public init() {
        
    }
    
    public init(name:String) {
        self.name = name
    }
}

//extension ImageEvent: FetchableRecord, MutablePersistableRecord, TableRecord {
//
//}


extension ImageEvent : PostgresRecord {
    public func postgresTable() -> String {
        return "ImageEvent"
    }
    
    public func primaryKeys() -> [String] {
        return ["name"]
    }
    
    public func autofillColumns() -> [String] {
        return []
    }
    
    
}
