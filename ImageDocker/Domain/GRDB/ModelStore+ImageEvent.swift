//
//  ModelStore+ImageEvent.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStore {
    
    // MARK: - CREATE
    
    func getOrCreateEvent(name:String) -> ImageEvent{
        var event:ImageEvent?
        do {
            let db = ModelStore.sharedDBPool()
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
    
    // MARK: - SEARCH
    
    func getAllEvents() -> [ImageEvent] {
        var events:[ImageEvent] = []
        
        do {
            let dbPool = ModelStore.sharedDBPool()
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
            stmt = self.likeArray(field: "name", array: keys)
        }
        do {
            let db = ModelStore.sharedDBPool()
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
    
    func getAllEvents(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Row] {
        var sqlArgs:[Any] = []
        var imageSourceWhere = ""
        var cameraModelWhere = ""
        inArray(field: "imageSource", array: imageSource, where: &imageSourceWhere, args: &sqlArgs)
        inArray(field: "cameraModel", array: cameraModel, where: &cameraModelWhere, args: &sqlArgs)
        
        let sql = "SELECT event, photoTakenYear, photoTakenMonth, photoTakenDay, place, count(path) as photoCount FROM Image WHERE 1=1 \(imageSourceWhere) \(cameraModelWhere) GROUP BY event, photoTakenYear,photoTakenMonth,photoTakenDay,place ORDER BY event DESC,photoTakenYear DESC,photoTakenMonth DESC,photoTakenDay DESC,place"
        print(sql)
        var result:[Row] = []
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                result = try Row.fetchAll(db, sql, arguments:StatementArguments(sqlArgs))
            }
        }catch{
            print(error)
        }
        return result
        
    }
    
    // MARK: - UPDATE
    
    func renameEvent(oldName:String, newName:String) -> ExecuteState{
        print("RENAME EVENT \(oldName) to \(newName)")
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                if let _ = try ImageEvent.fetchOne(db, key: newName){
                    try ImageEvent.deleteOne(db, key: oldName)
                }else {
                    if var event = try ImageEvent.fetchOne(db, key: oldName) {
                        event.name = newName
                        try event.save(db)
                    }
                }
                try db.execute("UPDATE Image SET AssignPlace=? WHERE AssignPlace=?", arguments: StatementArguments([oldName, newName]))
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
    
    // MARK: - DELETE
    
    func deleteEvent(name:String) -> ExecuteState{
        do {
            let db = ModelStore.sharedDBPool()
            try db.write { db in
                try ImageEvent.deleteOne(db, key: name)
                try db.execute("UPDATE Image SET event='' WHERE event=?", arguments: StatementArguments([name]))
            }
        }catch{
            return self.errorState(error)
        }
        return .OK
    }
}
