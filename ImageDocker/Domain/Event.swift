//
//  Event.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/17.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

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
    var events:[Event] = [Event] ()
    
    func read(_ datas:[[String : AnyObject]]) -> [Event]{
        for data in datas {
            let event = data["event"] as? String ?? ""
            let year = data["photoTakenYear"] as! Int
            let month = data["photoTakenMonth"] as! Int
            let day = data["photoTakenDay"] as! Int
            let photoCount = data["photoCount"] as! Int
            let place = data["place"] as? String ?? ""
            
            //print("Got \(event)-\(year)-\(month)-\(day)-\(place)")
            var eventEntry:Event
            var monthEntry:Event
            
            if events.index(where: {$0.event == event}) == nil {
                eventEntry = Event(event: event)
                events.append(eventEntry)
            }else{
                eventEntry = events.first(where: {$0.event == event})!
            }
            eventEntry.photoCount += photoCount
            
            if eventEntry.children.index(where: {$0.year == year && $0.month == month}) == nil {
                monthEntry = Event(month: month, ofYear: year, event:event, place: place)
                
                eventEntry.children.append(monthEntry)
            }else {
                monthEntry = eventEntry.children.first(where: {$0.year == year && $0.month == month})!
            }
            monthEntry.photoCount += photoCount
            
            let dayEntry:Event = Event(day: day, ofMonth: month, ofYear: year, event:event, place: place)
            dayEntry.photoCount = photoCount
            
            monthEntry.children.append(dayEntry)
            
            
        }
        return events
    }
}
