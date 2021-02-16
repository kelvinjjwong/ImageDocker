//
//  ModelStore+ImageEvent.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class EventDaoGRDB : EventDaoInterface {
    
    
    // MARK: - CREATE
    
    func getOrCreateEvent(name:String) -> ImageEvent{
        var event:ImageEvent?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                event = try ImageEvent.fetchOne(db, key: name)
            }
            if event == nil {
                try db.write { db in
                    event = ImageEvent(name: name)
                    try event?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return event!
    }
    
    func updateEventDetail(event:ImageEvent){
        var record:ImageEvent?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                record = try ImageEvent.fetchOne(db, key: event.name)
            }
            if var rec = record {
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
                try db.write { db in
                    try rec.save(db)
                }
            }
        }catch{
            print(error)
        }
    }
    
    // MARK: - SEARCH
    
    func getAllEvents() -> [ImageEvent] {
        var events:[ImageEvent] = []
        
        do {
            let dbPool = try SQLiteConnectionGRDB.default.sharedDBPool()
            try dbPool.read { db in
                events = try ImageEvent.order([Column("country").asc, Column("province").asc, Column("city").asc, Column("name").asc]).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return events
    }
    
    func getEvents(byName names:String? = nil) -> [ImageEvent] {
        var result:[ImageEvent] = []
        var stmt = ""
        if let names = names {
            let keys:[String] = names.components(separatedBy: " ")
            stmt = SQLHelper.likeArray(field: "name", array: keys)
        }
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                if stmt != "" {
                    result = try ImageEvent.filter(stmt).order(Column("name").asc).fetchAll(db)
                }else{
                    result = try ImageEvent.order(Column("name").asc).fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getEventCategories() -> [String] {
        let sql = """
select distinct category from ImageEvent order by category
"""
        var result:[String] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        if let date = row["category"] as String? {
                            result.append(date)
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getEventActivities() -> [String] {
        let sql = """
select act from (
select distinct activity1 as act from ImageEvent where activity1 <> ''
union
select distinct activity2 as act from ImageEvent where activity2 <> ''
) t order by act
"""
        var result:[String] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        if let date = row["act"] as String? {
                            result.append(date)
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getEventActivities(category: String) -> [String] {
        let sql = """
select act from (
select distinct activity1 as act from ImageEvent where category='\(category)' and activity1 <> ''
union
select distinct activity2 as act from ImageEvent where category='\(category)' activity2 <> ''
) t order by act
"""
        var result:[String] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: sql)
                if rows.count > 0 {
                    for row in rows {
                        if let date = row["act"] as String? {
                            result.append(date)
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    func getAllEvents(imageSource:[String]?, cameraModel:[String]?) -> [Event] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        SQLHelper.inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        SQLHelper.inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = "SELECT event, photoTakenYear, photoTakenMonth, photoTakenDay, place, count(path) as photoCount FROM Image WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY event, photoTakenYear,photoTakenMonth,photoTakenDay,place ORDER BY event DESC,photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC,place"
//        print(sql)
        var result:[Row] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql: sql, arguments:StatementArguments(sqlArgs) ?? [])
            }
        }catch{
            print(error)
        }
        
        return Events().read(result)
        
    }
    
    // MARK: - UPDATE
    
    func renameEvent(oldName:String, newName:String) -> ExecuteState{
        print("RENAME EVENT \(oldName) to \(newName)")
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                if let _ = try ImageEvent.fetchOne(db, key: newName){
                    try ImageEvent.deleteOne(db, key: oldName)
                }else {
                    if var event = try ImageEvent.fetchOne(db, key: oldName) {
                        event.name = newName
                        try event.save(db)
                    }
                }
                try db.execute(sql: "UPDATE Image SET event=? WHERE event=?", arguments: StatementArguments([oldName, newName]))
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    // MARK: - DELETE
    
    func deleteEvent(name:String) -> ExecuteState{
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try ImageEvent.deleteOne(db, key: name)
                try db.execute(sql: "UPDATE Image SET event='' WHERE event=?", arguments: StatementArguments([name]))
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func countImagesOfEvent(event:String) -> Int {
        var result = 0
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                result = try Image.filter(sql: "event=?", arguments:[event]).fetchCount(db)
                
                try db.execute(sql: "UPDATE ImageEvent SET imageCount=? WHERE name=?", arguments: [result, event])
            }
        }catch{
            print(error)
        }
        
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                var maxDate: Date?
                let max:[Row] = try Row.fetchAll(db, sql: """
                select max(photoTakenDate) as dt from Image where event=?
                """, arguments:[event])
                
                if max.count > 0 {
                    maxDate = max[0]["dt"] as? Date
                }
                
                
                var minDate: Date?
                let min:[Row] = try Row.fetchAll(db, sql: """
                select min(photoTakenDate) as dt from Image where event=?
                """, arguments:[event])
                
                if min.count > 0 {
                    minDate = min[0]["dt"] as? Date
                }
                
                try db.execute(sql: "UPDATE ImageEvent SET startDate=?,endDate=? WHERE name=?", arguments: [minDate, maxDate, event])
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func importEventsFromImages() {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                var events:[String] = []
                let records:[Row] = try Row.fetchAll(db, sql: """
                select DISTINCT event from Image where event not in (
                select DISTINCT name from ImageEvent)
                """)
                
                if records.count > 0 {
                    for record in records {
                        if let ev = record["event"] as? String {
                            events.append(ev)
                        }
                    }
                }
                for ev in events {
                    let _ = self.getOrCreateEvent(name: ev)
                }
            }
        }catch{
            print(error)
        }
    }
}
