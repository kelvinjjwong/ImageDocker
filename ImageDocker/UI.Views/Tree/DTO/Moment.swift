//
//  Moment.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/9.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
//import GRDB

enum MomentTree:Int {
    case MOMENTS
    case PLACES
    case EVENTS
}

enum MomentCondition:Int {
    case YEAR
    case MONTH
    case DAY
    case PLACE
    case EVENT
}

class Moment {
    
    var tree:MomentTree = .MOMENTS
    
    var gov:String = ""
    var place:String = ""
    var year:Int = 0
    var month:Int = 0
    var day:Int = 0
    var event:String = ""
    var eventCategory:String = ""
    var eventOwner:String = ""
    var photoCount:Int = 0
    var children:[Moment] = [Moment]()
    
    var groupByPlace:Bool = false
    var groupByEvent:Bool = false
    
    var hasDuplicates:Bool = false
    
    var countryData:String = ""
    var provinceData:String = ""
    var cityData:String = ""
    var placeData:String = ""
    
    var eventData:String = ""
    var eventCategoryData:String = ""
    var eventOwnerData:String = ""
    
    init(gov:String) {
        self.gov = gov
        self.place = ""
        self.year = 0
        self.month = 0
        self.day = 0
        self.groupByPlace = true
    }
    
    init(place:String, gov:String = "") {
        self.gov = gov
        self.place = place
        self.year = 0
        self.month = 0
        self.day = 0
        self.groupByPlace = true
    }
    
    init(eventCategory:String){
        self.eventCategory = eventCategory
        self.eventCategoryData = eventCategory
    }
    
    init(eventCategory:String, owner:String){
        self.eventCategory = eventCategory
        self.eventCategoryData = eventCategory
        self.eventOwner = owner
        self.eventOwnerData = owner
    }
    
    init(event:String, category:String, imageCount:Int = 0) {
        self.eventData = event
        self.event = event
        self.eventCategoryData = category
        self.eventCategory = category
        self.photoCount = imageCount
    }
    
    init(event:String, category:String, owner:String, imageCount:Int = 0) {
        self.eventData = event
        self.event = event
        self.eventCategoryData = category
        self.eventCategory = category
        self.eventOwner = owner
        self.eventOwnerData = owner
        self.photoCount = imageCount
    }
    
    init(year:Int, place:String = "", gov:String = "") {
        self.year = year
        self.month = 0
        self.day = 0
        self.place = place
        self.gov = gov
    }
    
    init(month:Int, ofYear year:Int, place:String = "", gov:String = ""){
        self.year = year
        self.month = month
        self.day = 0
        self.place = place
        self.gov = gov
    }
    
    init(day:Int, ofMonth month:Int, ofYear year:Int, event:String = "", place:String = "", gov:String = ""){
        self.year = year
        self.month = month
        self.day = day
        self.event = event
        self.place = place
        self.gov = gov
    }
    
    init(_ tree:MomentTree, imageCount:Int, year:Int, month:Int = 0, day:Int = 0, event:String = "", country:String = "", province:String = "", city:String = "", place:String = "") {
        self.photoCount = imageCount
        self.year = year
        self.month = month
        self.day = day
        self.event = event
        self.countryData = country
        self.provinceData = province
        self.cityData = city
        self.placeData = place
        self.place = place
        self.tree = tree
    }
    
    // MARK: DISPLAY
    
    var represent:String {
        if year == 0 {
            return "未识别日期"
        }
        if month == 0 && day == 0 {
            if year == 0 {
                return "未识别日期"
            }else{
                return "\(year) 年"
            }
        }
        if month != 0 && day == 0 {
            if year == 0 {
                return "未识别日期"
            }else{
                return "\(month) 月"
            }
        }
        let alertString:String = (hasDuplicates && !groupByPlace && !groupByEvent) ? " !!" : ""
        return "\(year.paddingZero(4))年\(month.paddingZero(2))月\(day.paddingZero(2))日\(alertString)"
    }
    
    // MARK: IDENTITY
    
    var id:String {
        var prefix = "moment"
        if self.groupByPlace {
            prefix = "place_\(gov)\(place)"
        }else if self.groupByEvent {
            prefix = "event_\(eventCategory)\(event)"
        }
        return "\(prefix)_\(year.paddingZero(4))\(month.paddingZero(2))\(day.paddingZero(2))"
    }
}

class Moments {
    
    // MARK: MOMENTS
    
    var years:[Moment] = [Moment] ()
    
    // MARK: PLACES
    
    var places:[Moment] = [Moment] ()
    
}
