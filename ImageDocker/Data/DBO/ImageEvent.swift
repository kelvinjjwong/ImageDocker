//
//  ImageEvent.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

public final class ImageEvent : Codable {
    //var id: Int64?      // <- the row id
    var name: String = ""
    var category: String = ""
    var startDate: Date?
    var startYear: Int?
    var startMonth: Int?
    var startDay: Int?
    var endDate: Date?
    var endYear: Int?
    var endMonth: Int?
    var endDay: Int?
    
    public init() {
        
    }
    
    public init(name:String) {
        self.name = name
    }
}

extension ImageEvent: FetchableRecord, MutablePersistableRecord, TableRecord {

}


extension ImageEvent : PostgresRecord {
    public func postgresTable() -> String {
        return "ImageEvent"
    }
    
    public func primaryKeys() -> [String] {
        return ["category", "name"]
    }
    
    
}
