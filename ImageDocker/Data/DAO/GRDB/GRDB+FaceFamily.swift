//
//  ModelStore+Family.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB
import LoggerFactory

class FaceDaoGRDB : FaceDaoInterface {
    
    let logger = LoggerFactory.get(category: "FaceDaoGRDB")

    // MARK: - FAMILY
    
    func getFamilies() -> [Family] {
        var result:[Family] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                result = try Family.order(sql: "name asc").fetchAll(db)
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func getFamilies(peopleId:String) -> [String] {
        var result:[String] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT familyId FROM FamilyMember WHERE peopleId='\(peopleId)'")
                for row in rows {
                    if let id = row["familyId"] as String? {
                        result.append(id)
                    }
                }
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func saveFamilyMember(peopleId:String, familyId:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                let rows = try Row.fetchAll(db, sql: "SELECT familyId,peopleId FROM FamilyMember WHERE familyId='\(familyId)' AND peopleId='\(peopleId)'")
                if rows.count == 0 {
                    try db.execute(sql: "INSERT INTO FamilyMember (familyId, peopleId) VALUES ('\(familyId)','\(peopleId)')")
                }
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func deleteFamilyMember(peopleId:String, familyId:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "DELETE FROM FamilyMember WHERE familyId='\(familyId)' AND peopleId='\(peopleId)'")
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func saveFamily(familyId:String?=nil, name:String, type:String) -> String? {
        var recordId:String? = ""
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                var needInsert = false
                if let id = familyId {
                    let rows = try Row.fetchAll(db, sql: "SELECT id FROM Family WHERE id='\(id)'")
                    if rows.count > 0 {
                        recordId = id
                        try db.execute(sql: "UPDATE Family SET name='\(name)',category='\(type)' WHERE id='\(id)'")
                    }else{
                        needInsert = true
                    }
                }else{
                    needInsert = true
                }
                if needInsert {
                    recordId = UUID().uuidString
                    try db.execute(sql: "INSERT INTO Family (id, name, category) VALUES ('\(recordId!)','\(name)','\(type)')")
                }
            }
        }catch{
            self.logger.log(error)
            recordId = nil
        }
        return recordId
    }
    
    func deleteFamily(id:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "DELETE FROM FamilyMember WHERE familyId='\(id)'")
                try db.execute(sql: "DELETE FROM FamilyJoint WHERE smallFamilyId='\(id)'")
                try db.execute(sql: "DELETE FROM FamilyJoint WHERE bigFamilyId='\(id)'")
                try db.execute(sql: "DELETE FROM Family WHERE id='\(id)'")
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func getFamilyMembers() -> [FamilyMember] {
        return []
    }
    
    // MARK: - RELATIONSHIP
    
    func getRelationship(primary:String, secondary:String) -> (String, String) {
        var value1 = ""
        var value2 = ""
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows1 = try Row.fetchAll(db, sql: "SELECT subject,object,callName FROM PeopleRelationship WHERE subject='\(primary)' AND object='\(secondary)'")
                if rows1.count > 0, let callName = rows1[0]["callName"] {
                    value1 = "\(callName)"
                }
                
                let rows2 = try Row.fetchAll(db, sql: "SELECT subject,object,callName FROM PeopleRelationship WHERE subject='\(secondary)' AND object='\(primary)'")
                if rows2.count > 0, let callName = rows2[0]["callName"] {
                    value2 = "\(callName)"
                }
            }
        }catch{
            self.logger.log(error)
        }
        return (value1, value2)
    }
    
    func getRelationships(peopleId:String) -> [[String:String]] {
        var result:[[String:String]] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT subject,object,callName FROM PeopleRelationship WHERE subject='\(peopleId)' OR object='\(peopleId)'")
                for row in rows {
                    if let primary = row["subject"] as String?,
                        let secondary = row["object"] as String?,
                        let callName = row["callName"] as String? {
                        var dict:[String:String] = [:]
                        dict["primary"] = primary
                        dict["secondary"] = secondary
                        dict["callName"] = callName
                        result.append(dict)
                    }
                }
            }
        }catch{
            self.logger.log(error)
        }
        return result
    }
    
    func saveRelationship(primary:String, secondary:String, callName:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                let rows = try Row.fetchAll(db, sql: "SELECT subject,object,callName FROM PeopleRelationship WHERE subject='\(primary)' AND object='\(secondary)'")
                if rows.count > 0 {
                    try db.execute(sql: "UPDATE PeopleRelationship SET callName='\(callName)' WHERE subject='\(primary)' AND object='\(secondary)'")
                }else{
                    try db.execute(sql: "INSERT INTO PeopleRelationship (subject, object, callName) VALUES ('\(primary)','\(secondary)','\(callName)')")
                }
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func getRelationships() -> [PeopleRelationship] {
        var obj:[PeopleRelationship] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                obj = try PeopleRelationship.fetchAll(db)
            }
        }catch{
            self.logger.log(error)
        }
        return obj
    }
    
    // MARK: - PEOPLE
    
    func getPeople() -> [People] {
        var obj:[People] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                obj = try People.order(sql: "name asc").fetchAll(db)
            }
        }catch{
            self.logger.log(error)
        }
        return obj
    }
    
    func getCoreMembers() -> [People] {
        return []
    }
    
    func getPeopleIds(inFamilyQuotedSeparated:String, db: DatabaseWriter) -> [String] {
        var peopleIds:[String] = []
        do{
            try db.read { db in
                let members = try FamilyMember.filter(sql: "familyId in (\(inFamilyQuotedSeparated))").fetchAll(db)
                for member in members {
                    peopleIds.append(member.peopleId.quotedDatabaseValueIdentifier)
                }
            }
        }catch{
            self.logger.log(error)
        }
        return peopleIds
    }
    
    func getPeople(inFamilyQuotedSeparated:String, exclude:Bool) -> [People] {
        var obj:[People] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            let peopleIds:[String] = self.getPeopleIds(inFamilyQuotedSeparated: inFamilyQuotedSeparated, db: db)
            if peopleIds.count == 0 {
                try db.read { db in
                    obj = try People.order(sql: "name asc").fetchAll(db)
                }
            }else{
                let peopleIdsSeparated = peopleIds.joined(separator: ",")
                try db.read { db in
                    obj = try People.filter(sql: "id \(exclude ? "NOT" : "") in (\(peopleIdsSeparated))").order(sql: "name asc").fetchAll(db)
                }
            }
        }catch{
            self.logger.log(error)
        }
        return obj
    }
    
    func getPeople(except:String) -> [People] {
        var obj:[People] = []
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                obj = try People.filter(sql: "id <> '\(except)'").order(sql: "name asc").fetchAll(db)
            }
        }catch{
            self.logger.log(error)
        }
        return obj
    }
    
    func getPerson(id: String) -> People? {
        var obj:People?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                obj = try People.fetchOne(db, key: id)
            }
            return obj
        }catch{
            self.logger.log(error)
        }
        return nil
    }
    
    func getPerson(name: String) -> People? {
        var obj:People?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                obj = try People.fetchOne(db, sql: "name = '\(name)'")
            }
            return obj
        }catch{
            self.logger.log(error)
        }
        return nil
    }
    
    func savePersonName(id:String, name:String, shortName:String) -> ExecuteState {
        var person = People.new(id: id, name: name, shortName: shortName)
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try person.save(db)
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updatePersonIconImage(id:String, repositoryPath:String, cropPath:String, subPath:String, filename:String) -> Bool{
        if let person = getPerson(id: id) {
            var ps = person
            ps.iconRepositoryPath = repositoryPath
            ps.iconCropPath = cropPath
            ps.iconSubPath = subPath
            ps.iconFilename = filename
            do {
                let db = try SQLiteConnectionGRDB.default.sharedDBPool()
                try db.write { db in
                    try ps.save(db)
                }
                return true
            }catch{
                self.logger.log(error)
                return false
            }
        }else{
            return false
        }
    }
    
    func deletePerson(id:String) -> ExecuteState {
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "delete from People where id = ?", arguments: [id])
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updatePersonIsCoreMember(id:String, isCoreMember:Bool) -> ExecuteState {
        return .ERROR
    }
    
}
