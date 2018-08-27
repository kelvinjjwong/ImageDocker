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
    
    var gov:String = ""
    var place:String
    var year:Int
    var month:Int
    var day:Int
    var event:String?
    var photoCount:Int = 0
    var children:[Moment] = [Moment]()
    var groupByPlace:Bool = false
    
    var hasDuplicates:Bool = false
    
    var countryData:String = ""
    var provinceData:String = ""
    var cityData:String = ""
    var placeData:String = ""
    
    init(gov:String) {
        self.gov = gov
        self.place = ""
        self.year = 0
        self.month = 0
        self.day = 0
    }
    
    init(place:String, gov:String = "") {
        self.gov = gov
        self.place = place
        self.year = 0
        self.month = 0
        self.day = 0
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
    
    init(day:Int, ofMonth month:Int, ofYear year:Int, event:String? = nil, place:String = "", gov:String = ""){
        self.year = year
        self.month = month
        self.day = day
        self.event = event
        self.place = place
        self.gov = gov
    }
    
    // MARK: DISPLAY
    
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
    
    // MARK: IDENTITY
    
    var id:String {
        let tag = groupByPlace ? "place" : "moment"
        if month == 0 && day == 0 {
            return "\(tag)\(gov)\(place)\(year)0000"
        }
        if month != 0 && day == 0 {
            let monthString:String = month < 10 ? "0\(month)" : "\(month)"
            return "\(tag)\(gov)\(place)\(year)\(monthString)00"
        }
        let monthString:String = month < 10 ? "0\(month)" : "\(month)"
        let dayString:String = day < 10 ? "0\(day)" : "\(day)"
        return "\(tag)\(gov)\(place)\(year)\(monthString)\(dayString)"
    }
}

class Moments {
    
    // MARK: MOMENTS
    
    var years:[Moment] = [Moment] ()
    
    func readMoments(_ datas:[Row]) -> [Moment]{
        for data in datas {
            
            let place = data["place"] as? String ?? ""
            let year = data["photoTakenYear"] as Int? ?? 0
            let month = data["photoTakenMonth"] as Int? ?? 0
            let day = data["photoTakenDay"] as Int? ?? 0
            let photoCount = data["photoCount"] as Int? ?? 0
            
            //print("Got \(place)-\(year)-\(month)-\(day)")
            var yearEntry:Moment
            var monthEntry:Moment
            
            if year == 0 && month == 0 && day == 0 {
                // TODO: change to SET<String> for performance
                if years.index(where: {$0.place == "未能识别日期"}) == nil {
                    yearEntry = Moment(place: "未能识别日期")
                    years.append(yearEntry)
                }else{
                    yearEntry = years.first(where: {$0.place == "未能识别日期"})!
                }
                yearEntry.photoCount += photoCount
                
                let dayEntry:Moment = Moment(day: day, ofMonth: month, ofYear: year, place: place == "" ? "未能识别地址" : place)
                dayEntry.photoCount = photoCount
                
                yearEntry.children.append(dayEntry)
            }else {
            
                // TODO: change to SET<String> for performance
                if years.index(where: {$0.year == year}) == nil {
                    yearEntry = Moment(year: year)
                    years.append(yearEntry)
                }else{
                    yearEntry = years.first(where: {$0.year == year})!
                }
                yearEntry.photoCount += photoCount
                
                // TODO: change to SET<String> for performance
                if yearEntry.children.index(where: {$0.month == month}) == nil {
                    monthEntry = Moment(month: month, ofYear: year, place: place)
                    yearEntry.children.append(monthEntry)
                }else {
                    monthEntry = yearEntry.children.first(where: {$0.month == month})!
                }
                monthEntry.photoCount += photoCount
                
                let dayEntry:Moment = Moment(day: day, ofMonth: month, ofYear: year, place: place)
                dayEntry.photoCount = photoCount
                
                monthEntry.children.append(dayEntry)
            }
            
            
        }
        return years
    }
    
    // MARK: PLACES
    
    var places:[Moment] = [Moment] ()
    
    func readPlaces(_ datas:[Row]) -> [Moment]{
        for data in datas {
            var gov = ""
            let country = data["country"] as? String ?? ""
            let province = data["province"] as? String ?? ""
            let city = data["city"] as? String ?? ""
            
            var place = data["place"] as? String ?? ""
            let year = data["photoTakenYear"] as Int? ?? 0
            let month = data["photoTakenMonth"] as Int? ?? 0
            let day = data["photoTakenDay"] as Int? ?? 0
            let photoCount = data["photoCount"] as Int? ?? 0
            
            if place == "" && (country == "" && province == "" && city == "") {
                continue
            }
            
            if year == 0 && month == 0 && day == 0 && place != "" {
                gov = "未知日期"
            }else if year == 0 && month == 0 && day == 0 && place == "" {
                gov = "未知日期"
                place = "未知地址"
            }else if country == "" && province == "" && city == "" && place != "" {
                gov = place
            }else {
                if country == "中国" {
                    if province == city {
                        gov = city
                    }else{
                        gov = "\(province)\(city)"
                    }
                }else{
                    gov = "\(country), \(city)"
                }
            }
            
            if place == "" && (country != "" || province != "" || city != "") {
                if city != "" {
                    place = city
                }
                if place == "" && province != "" {
                    place = province
                }
                if place == "" && country != "" {
                    place = country
                }
            }
            gov = gov.replacingOccurrences(of: "特别行政区", with: "")
            place = place.replacingOccurrences(of: "特别行政区", with: "")
            
            //print("Got \(place)-\(year)-\(month)-\(day)")
            var govEntry:Moment
            var placeEntry:Moment
            var yearEntry:Moment
            var monthEntry:Moment
            
            // TODO: change to SET<String> for performance
            if places.index(where: {$0.gov == gov}) == nil {
                govEntry = Moment(gov: gov)
                govEntry.groupByPlace = true
                places.append(govEntry)
            }else{
                govEntry = places.first(where: {$0.gov == gov})!
            }
            govEntry.photoCount += photoCount
            
            // TODO: change to SET<String> for performance
            if govEntry.children.index(where: {$0.place == place}) == nil {
                placeEntry = Moment(place: place, gov: gov)
                placeEntry.groupByPlace = true
                govEntry.children.append(placeEntry)
            }else{
                placeEntry = govEntry.children.first(where: {$0.place == place})!
            }
            placeEntry.photoCount += photoCount
            placeEntry.countryData = data["country"] as? String ?? ""
            placeEntry.provinceData = data["province"] as? String ?? ""
            placeEntry.cityData = data["city"] as? String ?? ""
            placeEntry.placeData = data["place"] as? String ?? ""
            
            // TODO: change to SET<String> for performance
            if placeEntry.children.index(where: {$0.year == year}) == nil {
                yearEntry = Moment(year: year, place: place, gov: gov)
                yearEntry.groupByPlace = true
                placeEntry.children.append(yearEntry)
            }else{
                yearEntry = placeEntry.children.first(where: {$0.year == year})!
            }
            yearEntry.photoCount += photoCount
            yearEntry.countryData = data["country"] as? String ?? ""
            yearEntry.provinceData = data["province"] as? String ?? ""
            yearEntry.cityData = data["city"] as? String ?? ""
            yearEntry.placeData = data["place"] as? String ?? ""
            
            // TODO: change to SET<String> for performance
            if yearEntry.children.index(where: {$0.month == month}) == nil {
                monthEntry = Moment(month: month, ofYear: year, place: place, gov: gov)
                monthEntry.groupByPlace = true
                yearEntry.children.append(monthEntry)
            }else {
                monthEntry = yearEntry.children.first(where: {$0.month == month})!
            }
            monthEntry.photoCount += photoCount
            monthEntry.countryData = data["country"] as? String ?? ""
            monthEntry.provinceData = data["province"] as? String ?? ""
            monthEntry.cityData = data["city"] as? String ?? ""
            monthEntry.placeData = data["place"] as? String ?? ""
            
            let dayEntry:Moment = Moment(day: day, ofMonth: month, ofYear: year, place: place, gov: gov)
            dayEntry.groupByPlace = true
            
            monthEntry.children.append(dayEntry)
            
            dayEntry.photoCount = photoCount
            dayEntry.countryData = data["country"] as? String ?? ""
            dayEntry.provinceData = data["province"] as? String ?? ""
            dayEntry.cityData = data["city"] as? String ?? ""
            dayEntry.placeData = data["place"] as? String ?? ""
            
        }
        return places
    }
    
    
}
