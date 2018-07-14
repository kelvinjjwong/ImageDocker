//
//  Moment.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/9.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class Moment {
    
    var place:String
    var year:Int
    var month:Int
    var day:Int
    var event:String?
    var photoCount:Int = 0
    var children:[Moment] = [Moment]()
    var groupByPlace:Bool = false
    
    var hasDuplicates:Bool = false
    
    init(place:String) {
        self.place = place
        self.year = 0
        self.month = 0
        self.day = 0
    }
    
    init(year:Int, place:String = "") {
        self.year = year
        self.month = 0
        self.day = 0
        self.place = place
    }
    
    init(month:Int, ofYear year:Int, place:String = ""){
        self.year = year
        self.month = month
        self.day = 0
        self.place = place
    }
    
    init(day:Int, ofMonth month:Int, ofYear year:Int, event:String? = nil, place:String = ""){
        self.year = year
        self.month = month
        self.day = day
        self.event = event
        self.place = place
    }
    
    var represent:String {
        if year == 0 {
            if place == "" {
                return "未识别"
            }else{
                return "\(place)"
            }
        }
        if month == 0 && day == 0 {
            if year == 0 {
                return "未识别"
            }else{
                return "\(year) 年"
            }
        }
        if month != 0 && day == 0 {
            if year == 0 {
                return "未识别"
            }else{
                return "\(month) 月"
            }
        }
        if event != nil {
            return event!
        }
        let monthString:String = month < 10 ? "0\(month)" : "\(month)"
        let dayString:String = day < 10 ? "0\(day)" : "\(day)"
        let alertString:String = (hasDuplicates && !groupByPlace) ? " !!" : ""
        return "\(year)年\(monthString)月\(dayString)日\(alertString)"
    }
    
    var id:String {
        if month == 0 && day == 0 {
            return "\(place)\(year)0000"
        }
        if month != 0 && day == 0 {
            let monthString:String = month < 10 ? "0\(month)" : "\(month)"
            return "\(place)\(year)\(monthString)00"
        }
        let monthString:String = month < 10 ? "0\(month)" : "\(month)"
        let dayString:String = day < 10 ? "0\(day)" : "\(day)"
        return "\(place)\(year)\(monthString)\(dayString)"
    }
}

class Moments {
    
    var years:[Moment] = [Moment] ()
    var places:[Moment] = [Moment] ()
    
    func read(_ datas:[Row], groupByPlace:Bool = false) -> [Moment]{
        for data in datas {
            let place = data["place"] as? String ?? ""
            let year = data["photoTakenYear"] as Int
            let month = data["photoTakenMonth"] as Int
            let day = data["photoTakenDay"] as Int
            let photoCount = data["photoCount"] as Int
            
            //print("Got \(place)-\(year)-\(month)-\(day)")
            var placeEntry:Moment?
            var yearEntry:Moment
            var monthEntry:Moment
            
            if year == 0 && month == 0 && day == 0 {
                if groupByPlace && place != "" {
                    if places.index(where: {$0.place == "未知地址"}) == nil {
                        placeEntry = Moment(place: "未知地址")
                        placeEntry?.groupByPlace = groupByPlace
                        places.append(placeEntry!)
                    }else{
                        placeEntry = places.first(where: {$0.place == "未知地址"})!
                    }
                    placeEntry?.photoCount += photoCount
                    
                    let dayEntry:Moment = Moment(day: day, ofMonth: month, ofYear: year, place: "未知地址")
                    dayEntry.photoCount = photoCount
                    dayEntry.groupByPlace = groupByPlace
                    
                    placeEntry?.children.append(dayEntry)
                }else {
                    if years.index(where: {$0.place == "未知日期"}) == nil {
                        yearEntry = Moment(place: "未知日期")
                        yearEntry.groupByPlace = groupByPlace
                        years.append(yearEntry)
                    }else{
                        yearEntry = years.first(where: {$0.place == "未知日期"})!
                    }
                    yearEntry.photoCount += photoCount
                    
                    let dayEntry:Moment = Moment(day: day, ofMonth: month, ofYear: year, place: place)
                    dayEntry.photoCount = photoCount
                    dayEntry.groupByPlace = groupByPlace
                    
                    yearEntry.children.append(dayEntry)
                }
                continue
            }
            
            if groupByPlace {
                if places.index(where: {$0.place == place}) == nil {
                    placeEntry = Moment(place: place)
                    placeEntry?.groupByPlace = groupByPlace
                    places.append(placeEntry!)
                }else{
                    placeEntry = places.first(where: {$0.place == place})!
                }
                placeEntry?.photoCount += photoCount
            }
            
            if groupByPlace && placeEntry != nil {
                if placeEntry!.children.index(where: {$0.year == year}) == nil {
                    yearEntry = Moment(year: year, place: place)
                    yearEntry.groupByPlace = groupByPlace
                    placeEntry!.children.append(yearEntry)
                }else{
                    yearEntry = placeEntry!.children.first(where: {$0.year == year})!
                }
            }else{
                if years.index(where: {$0.year == year}) == nil {
                    yearEntry = Moment(year: year)
                    yearEntry.groupByPlace = groupByPlace
                    years.append(yearEntry)
                }else{
                    yearEntry = years.first(where: {$0.year == year})!
                }
            }
            yearEntry.photoCount += photoCount
            
            if yearEntry.children.index(where: {$0.month == month}) == nil {
                monthEntry = Moment(month: month, ofYear: year, place: place)
                monthEntry.groupByPlace = groupByPlace
                yearEntry.children.append(monthEntry)
            }else {
                monthEntry = yearEntry.children.first(where: {$0.month == month})!
            }
            monthEntry.photoCount += photoCount
            
            let dayEntry:Moment = Moment(day: day, ofMonth: month, ofYear: year, place: place)
            dayEntry.photoCount = photoCount
            dayEntry.groupByPlace = groupByPlace
            
            monthEntry.children.append(dayEntry)
            
            
        }
        return groupByPlace ? places : years
    }
}
