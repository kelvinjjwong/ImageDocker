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
            UPDATE "Image" SET "assignPlace"=$1 WHERE "assignPlace"=$2
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
    

}
