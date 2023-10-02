//
//  Event.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/17.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import LoggerFactory

class Event {
    
    var place:String
    var year:Int
    var month:Int
    var day:Int
    var event:String
    var photoCount:Int = 0
    var children:[Event] = [Event]()
    
    init(event:String) {
        self.event = event
        self.year = 0
        self.month = 0
        self.day = 0
        self.place = ""
    }
    
    init(year:Int, event:String, place:String = "") {
        self.year = year
        self.month = 0
        self.day = 0
        self.place = place
        self.event = event
    }
    
    init(month:Int, ofYear year:Int, event:String, place:String = ""){
        self.year = year
        self.month = month
        self.day = 0
        self.place = place
        self.event = event
    }
    
    init(day:Int, ofMonth month:Int, ofYear year:Int, event:String, place:String = ""){
        self.year = year
        self.month = month
        self.day = day
        self.event = event
        self.place = place
    }
    
    var represent:String {
        if year == 0 {
            return "\(event)"
        }
        if month == 0 && day == 0 {
            return "\(year) 年"
        }
        let monthString:String = month < 10 ? "0\(month)" : "\(month)"
        
        if month != 0 && day == 0 {
            return "\(year) 年 \(month) 月"
        }
        
        let dayString:String = day < 10 ? "0\(day)" : "\(day)"
        let placeString:String = place == "" ? "" : " \(place)"
        return "\(year)年\(monthString)月\(dayString)日\(placeString)"
    }
    
    var id:String {
        if month == 0 && day == 0 {
            return "\(event)\(year)0000"
        }
        if month != 0 && day == 0 {
            let monthString:String = month < 10 ? "0\(month)" : "\(month)"
            return "\(event)\(year)\(monthString)00"
        }
        let monthString:String = month < 10 ? "0\(month)" : "\(month)"
        let dayString:String = day < 10 ? "0\(day)" : "\(day)"
        return "\(event)\(year)\(monthString)\(dayString)\(place)"
    }
}

class Events {
    let logger = LoggerFactory.get(category: "Events")
    var events:[Event] = [Event] ()
    
}
