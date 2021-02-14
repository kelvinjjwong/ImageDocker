//
//  PostgresClientKit+ImageEvent.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

class EventDaoPostgresCK : EventDaoInterface {
    
    func getOrCreateEvent(name: String) -> ImageEvent {
        let db = PostgresConnection.database()
        if let event = ImageEvent.fetchOne(db, parameters: ["name": name]) {
            return event
        }else{
            let event = ImageEvent(name: name)
            event.save(db)
            return event
        }
        
    }
    
    func updateEventDetail(event:ImageEvent){
        let db = PostgresConnection.database()
        if var rec = ImageEvent.fetchOne(db, parameters: ["name": event.name]) {
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
            rec.save(db)
        }
    }
    
    func getAllEvents() -> [ImageEvent] {
        let db = PostgresConnection.database()
        return ImageEvent.fetchAll(db)
    }
    
    func getEvents(byName names: String?) -> [ImageEvent] {
        let db = PostgresConnection.database()
        var whereStmt = ""
        if let names = names {
            let keys:[String] = names.components(separatedBy: " ")
            whereStmt = SQLHelper.likeArray(field: "name", array: keys)
        }
        return ImageEvent.fetchAll(db, where: whereStmt, orderBy: "name")
    }
    
    func getEventCategories() -> [String] {
        var result:[String] = []
        
        let sql = """
        select distinct "category" from "ImageEvent" order by "category"
        """
//        print(sql)
        
        final class TempRecord : PostgresCustomRecord {
            var category:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            result.append(row.category)
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
//        print(sql)
        
        final class TempRecord : PostgresCustomRecord {
            var acc:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            result.append(row.acc)
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
        print(sql)
        
        final class TempRecord : PostgresCustomRecord {
            var acc:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        let records = TempRecord.fetchAll(db, sql: sql)
        for row in records {
            result.append(row.acc)
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
        
        final class TempRecord : PostgresCustomRecord {
            
            
            var event:String = ""
            var photoTakenYear:Int = 0
            var photoTakenMonth:Int = 0
            var photoTakenDay:Int = 0
            var place:String = ""
            var photoCount:Int = 0
            
            public init() {}
        }
        
        let records = TempRecord.fetchAll(db, sql: sql)
        
        var events:[Event] = [Event] ()
        for data in records {
            let event = data.event
            //print(event)
            let year = data.photoTakenYear
            //print("year")
            let month = data.photoTakenMonth
            //print("month")
            let day = data.photoTakenDay
            //print("day")
            let photoCount = data.photoCount
            //print("count")
            let place = data.place
            
            //print("Got \(event)-\(year)-\(month)-\(day)-\(place)")
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
        if !ImageEvent.exists(db, parameters: ["name" : newName]) {
            if let event = ImageEvent.fetchOne(db, parameters: ["name": oldName]) {
                event.name = newName
                event.save(db)
            }
        }
        do {
            try db.execute(sql: """
            UPDATE "Image" SET "event"=$1, "lastUpdateTime"=now() WHERE "event"=$2
            """, parameterValues: [newName, oldName])
            let event = ImageEvent()
            event.name = oldName
            event.delete(db)
        }catch {
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func deleteEvent(name: String) -> ExecuteState {
        let db = PostgresConnection.database()
        let event = ImageEvent()
        event.name = name
        event.delete(db)
        return .OK
    }
    
    
    func countImagesOfEvent(event:String) -> Int {
        let db = PostgresConnection.database()
        let result = Image.count(db, where: """
        "event"=$1
        """, parameters:[event])
        
        do {
            try db.execute(sql: """
            UPDATE "ImageEvent" SET "imageCount"=$1,"lastUpdateTime"=now() WHERE "name"=$2
            """, parameterValues: [result, event])
        }catch {
            print(error)
        }
        
        final class TempRecord : PostgresCustomRecord {
            var dt:Date? = nil
            public init() {}
        }
        
        let maxSql = """
        select max("photoTakenDate") from "Image" where "event"='\(event)'
        """
        print(maxSql)
        var maxDate:Date? = nil
        let max = TempRecord.fetchAll(db, sql: maxSql)
        if max.count > 0 {
            maxDate = max[0].dt
        }
        
        let minSql = """
        select min("photoTakenDate") from "Image" where "event"='\(event)'
        """
        print(minSql)
        var minDate:Date? = nil
        let min = TempRecord.fetchAll(db, sql: minSql)
        if min.count > 0 {
            minDate = min[0].dt
        }
        
        do {
            try db.execute(sql: """
            UPDATE "ImageEvent" SET "startDate"=$1,"endDate"=$2, "lastUpdateTime"=now() WHERE "name"=$3
            """, parameterValues: [minDate, maxDate, event])
        }catch {
            print(error)
        }
        
        return result
    }
    
    func importEventsFromImages() {
        let db = PostgresConnection.database()
        final class TempRecord : PostgresCustomRecord {
            var event:String? = nil
            public init() {}
        }
        
        let sql = """
        select DISTINCT "event" from "Image" where "event" not in (
        select DISTINCT "name" from "ImageEvent")
        """
        let records = TempRecord.fetchAll(db, sql: sql)
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

}
