//
//  ImageEvent.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

struct ImageEvent : Codable {
    //var id: Int64?      // <- the row id
    var name: String
    var category: String
    var startDate: Date?
    var startYear: Int?
    var startMonth: Int?
    var startDay: Int?
    var endDate: Date?
    var endYear: Int?
    var endMonth: Int?
    var endDay: Int?
    
    init(name:String, category:String = "", startDate:Date? = nil, startYear:Int? = nil, startMonth:Int? = nil, startDay:Int? = nil,
         endDate:Date? = nil, endYear:Int? = nil, endMonth:Int? = nil, endDay:Int? = nil){
        //self.id = id
        self.name = name
        self.category = category
        self.startDate = startDate
        self.startYear = startYear
        self.startMonth = startMonth
        self.startDay = startDay
        self.endDate = endDate
        self.endYear = endYear
        self.endMonth = endMonth
        self.endDay = endDay
        
    }
}

extension ImageEvent: FetchableRecord, MutablePersistableRecord, TableRecord {
    mutating func didInsert(with rowID: Int64, for column: String?) {
        // Update id after insertion
        //id = rowID
    }
}
