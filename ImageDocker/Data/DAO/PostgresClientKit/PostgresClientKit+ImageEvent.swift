//
//  PostgresClientKit+ImageEvent.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory

class EventDaoPostgresCK : EventDaoInterface {
    
    let logger = LoggerFactory.get(category: "EventDaoPostgresCK")
    
    func getOrCreateEvent(name: String) -> ImageEvent {
        let db = PostgresConnection.database()
        let dummy = ImageEvent(name: name)
        do {
            if let event = try ImageEvent.fetchOne(db, parameters: ["name": name]) {
                return event
            }else{
                try dummy.save(db)
                return dummy
            }
        }catch{
            self.logger.log(.error, error)
            return dummy
        }
        
    }
    
    func createEvent(event:ImageEvent) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try event.save(db)
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func updateEventDetail(event:ImageEvent) -> ExecuteState{
        let db = PostgresConnection.database()
        do {
            if let rec = try ImageEvent.fetchOne(db, parameters: ["name": event.name]) {
                rec.category = event.category
                rec.activity1 = event.activity1
                rec.activity2 = event.activity2
                rec.attenders = event.attenders
                rec.family = event.family
                rec.note = event.note
                rec.imageCount = event.imageCount
                rec.lastUpdateTime = Date()
                rec.owner = event.owner
                rec.ownerNickname = event.ownerNickname
                rec.ownerId = event.ownerId
                rec.owner2 = event.owner2
                rec.owner2Nickname = event.owner2Nickname
                rec.owner2Id = event.owner2Id
                rec.owner3 = event.owner3
                rec.owner3Nickname = event.owner3Nickname
                rec.owner3Id = event.owner3Id
                try rec.save(db)
                return .OK
            }
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .ERROR
    }
    
    func getAllEvents() -> [ImageEvent] {
        let db = PostgresConnection.database()
        do {
            return try ImageEvent.fetchAll(db)
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getEvents(byName names: String?) -> [ImageEvent] {
        let db = PostgresConnection.database()
        var stmtName = ""
        if let names = names, names != "" {
            let keys:[String] = names.components(separatedBy: " ")
            stmtName = SQLHelper.likeArray(field: "name", array: keys)
        }
        do {
            return try ImageEvent.fetchAll(db, where: stmtName, orderBy: "category,name")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getEvents(categoriesQuotedSeparated:String?, exclude:Bool = false) -> [ImageEvent] {
        let db = PostgresConnection.database()
        var stmtCategory = ""
        if let categoriesQuotedSeparated = categoriesQuotedSeparated, categoriesQuotedSeparated != "" {
            stmtCategory = """
        "category" \(exclude ? "NOT" : "") in (\(categoriesQuotedSeparated))
        """
        }
        do {
            return try ImageEvent.fetchAll(db, where: stmtCategory, orderBy: "category,name")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getEventCategories() -> [String] {
        var result:[String] = []
        
        let sql = """
        select distinct "category" from "ImageEvent" order by "category"
        """
//        self.logger.log(sql)
        
        final class TempRecord : DatabaseRecord {
            var category:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: sql)
            for row in records {
                result.append(row.category)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
        
    }
    
    func getEventActivities() -> [String] {
        var result:[String] = []
        
        let sql = """
        select "act" from (
        select distinct "activity1" as "act" from "ImageEvent" where "activity1" <> ''
        union
        select distinct "activity2" as "act" from "ImageEvent" where "activity2" <> ''
        ) t order by "act"
        """
//        self.logger.log(sql)
        
        final class TempRecord : DatabaseRecord {
            var acc:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: sql)
            for row in records {
                result.append(row.acc)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
        
    }
    
    func getEventActivities(category: String) -> [String] {
        var result:[String] = []
        
        let sql = """
        select "act" from (
        select distinct "activity1" as "act" from "ImageEvent" where "category" = '\(category)' and "activity1" <> ''
        union
        select distinct "activity2" as "act" from "ImageEvent" where "category" = '\(category)' and "activity2" <> ''
        ) t order by "act"
        """
//        self.logger.log(sql)
        
        final class TempRecord : DatabaseRecord {
            var acc:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: sql)
            for row in records {
                result.append(row.acc)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
        
    }
    
    func getAllEvents(imageSource: [String]?, cameraModel: [String]?) -> [Event] {
        let db = PostgresConnection.database()
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        SQLHelper.inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs, numericPlaceholders: true)
        SQLHelper.inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs, numericPlaceholders: true)
        
        let sql = """
        SELECT event, "photoTakenYear", "photoTakenMonth", "photoTakenDay", place, count(path) as "photoCount" FROM "Image" WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY event, "photoTakenYear","photoTakenMonth","photoTakenDay",place ORDER BY event DESC,"p"hotoTakenYear" DESC,"photoTakenMonth" DESC,"photoTakenDay" DESC,place
        """
        
        final class TempRecord : DatabaseRecord {
            
            
            var event:String = ""
            var photoTakenYear:Int = 0
            var photoTakenMonth:Int = 0
            var photoTakenDay:Int = 0
            var place:String = ""
            var photoCount:Int = 0
            
            public init() {}
        }
        
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
        }
        
        var events:[Event] = [Event] ()
        for data in records {
            let event = data.event
            //self.logger.log(event)
            let year = data.photoTakenYear
            //self.logger.log(.trace, "year")
            let month = data.photoTakenMonth
            //self.logger.log(.trace, "month")
            let day = data.photoTakenDay
            //self.logger.log(.trace, "day")
            let photoCount = data.photoCount
            //self.logger.log(.trace, "count")
            let place = data.place
            
            //self.logger.log(.trace, "Got \(event)-\(year)-\(month)-\(day)-\(place)")
            var eventEntry:Event
            var monthEntry:Event
            
            if events.firstIndex(where: {$0.event == event}) == nil {
                eventEntry = Event(event: event)
                events.append(eventEntry)
            }else{
                eventEntry = events.first(where: {$0.event == event})!
            }
            eventEntry.photoCount += photoCount
            
            if eventEntry.children.firstIndex(where: {$0.year == year && $0.month == month}) == nil {
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
    
    func renameEvent(oldName: String, newName: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            if try !ImageEvent.exists(db, parameters: ["name" : newName]) {
                if let event = try ImageEvent.fetchOne(db, parameters: ["name": oldName]) {
                    event.name = newName
                    try event.save(db)
                }
            }
            try db.execute(sql: """
            UPDATE "Image" SET "event"=$1, "lastUpdateTime"=now() WHERE "event"=$2
            """, parameterValues: [newName, oldName])
            let event = ImageEvent()
            event.name = oldName
            try event.delete(db)
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func deleteEvent(name: String) -> ExecuteState {
        let db = PostgresConnection.database()
        let event = ImageEvent()
        event.name = name
        do {
            try event.delete(db)
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    
    func countImagesOfEvent(event:String) -> Int {
        let db = PostgresConnection.database()
        var result = 0
        do {
            result = try Image.count(db, where: """
        "event"=$1
        """, parameters:[event])
        }catch{
            self.logger.log(.error, error)
        }
        
        do {
            try db.execute(sql: """
            UPDATE "ImageEvent" SET "imageCount"=$1,"lastUpdateTime"=now() WHERE "name"=$2
            """, parameterValues: [result, event])
        }catch {
            self.logger.log(.error, error)
        }
        
        final class TempRecord : DatabaseRecord {
            var dt:Date? = nil
            public init() {}
        }
        
        do {
            let maxSql = """
            select max("photoTakenDate") from "Image" where "event"='\(event)'
            """
            self.logger.log(maxSql)
            var maxDate:Date? = nil
            let max = try TempRecord.fetchAll(db, sql: maxSql)
            if max.count > 0 {
                maxDate = max[0].dt
            }
            
            let minSql = """
            select min("photoTakenDate") from "Image" where "event"='\(event)'
            """
            self.logger.log(minSql)
            var minDate:Date? = nil
            let min = try TempRecord.fetchAll(db, sql: minSql)
            if min.count > 0 {
                minDate = min[0].dt
            }
        
            try db.execute(sql: """
            UPDATE "ImageEvent" SET "startDate"=$1,"endDate"=$2, "lastUpdateTime"=now() WHERE "name"=$3
            """, parameterValues: [minDate, maxDate, event])
        }catch{
            self.logger.log(.error, error)
        }
        
        return result
    }
    
    func importEventsFromImages() {
        let db = PostgresConnection.database()
        final class TempRecord : DatabaseRecord {
            var event:String? = nil
            public init() {}
        }
        
        let sql = """
        select DISTINCT "event" from "Image" where "event" not in (
        select DISTINCT "name" from "ImageEvent")
        """
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
        }
        var events:[String] = []
        if records.count > 0 {
            for record in records {
                if let ev = record.event {
                    events.append(ev)
                }
            }
            
            for ev in events {
                let _ = self.getOrCreateEvent(name: ev)
            }
        }
    }
    
    func getEventsByCategories(categories:[String]) -> [String] {
        var result:[String] = []
        let sql = """
select "name" from "ImageEvent" where "category" in (\(categories.joinedSingleQuoted(separator: ","))) order by "name"
"""
        final class TempRecord : DatabaseRecord {
            var name:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: sql)
            for row in records {
                result.append(row.name)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
    }
    
    func getEventsByOwner(ownerId:String) -> [(String, String, String, String, String)] {
        var result:[(String, String, String, String, String)] = []
        final class TempRecord : DatabaseRecord {
            var category:String = ""
            var name:String = ""
            var ownerNickname:String = ""
            var owner2Nickname:String = ""
            var owner3Nickname:String = ""
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: """
select DISTINCT "category", "name", "ownerNickname", "owner2Nickname", "owner3Nickname" from "ImageEvent" where "ownerId" = '\(ownerId)' or "owner2Id" = '\(ownerId)' or "owner3Id" = '\(ownerId)' order by "name"
""")
            for row in records {
                result.append((row.category, row.name, row.ownerNickname, row.owner2Nickname, row.owner3Nickname))
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
    }
    
    func getEvents(imageIds:[String]) -> [String]  {
        if imageIds.isEmpty {
            return []
        }
        var result:[String] = []
        final class TempRecord : DatabaseRecord {
            var event:String? = nil
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: """
select DISTINCT "event" from "Image" where "id" in (\(imageIds.joinedSingleQuoted(separator: ","))) order by "event"
""")
            for row in records {
                if let ev = row.event {
                    result.append(ev)
                }
            }
        }catch{
            self.logger.log(.error, error)
        }
        self.logger.log(.trace, "getEvents(imageIds: \(imageIds)")
        self.logger.log(.trace, result)
        return result
    }
    
    func getEvent(name:String) -> ImageEvent? {
        let db = PostgresConnection.database()
        
        do {
            return try ImageEvent.fetchOne(db, parameters: ["name": name])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }

}
