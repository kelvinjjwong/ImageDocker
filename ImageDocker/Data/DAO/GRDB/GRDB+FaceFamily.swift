//
//  ModelStore+Family.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStoreGRDB {

    // MARK: - FAMILY
    
    func getFamilies() -> [Family] {
        var result:[Family] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try Family.order(sql: "name asc").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getFamilies(peopleId:String) -> [String] {
        var result:[String] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT familyId FROM FamilyMember WHERE peopleId='\(peopleId)'")
                for row in rows {
                    if let id = row["familyId"] as String? {
                        result.append(id)
                    }
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func saveFamilyMember(peopleId:String, familyId:String) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                let rows = try Row.fetchAll(db, sql: "SELECT familyId,peopleId FROM FamilyMember WHERE familyId='\(familyId)' AND peopleId='\(peopleId)'")
                if rows.count == 0 {
                    try db.execute(sql: "INSERT INTO FamilyMember (familyId, peopleId) VALUES ('\(familyId)','\(peopleId)')")
                }
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func deleteFamilyMember(peopleId:String, familyId:String) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "DELETE FROM FamilyMember WHERE familyId='\(familyId)' AND peopleId='\(peopleId)'")
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func saveFamily(familyId:String?=nil, name:String, type:String) -> String? {
        var recordId:String? = ""
        do {
            let db = ModelStoreGRDB.sharedDBPool()
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
            print(error)
            recordId = nil
        }
        return recordId
    }
    
    func deleteFamily(id:String) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "DELETE FROM FamilyMember WHERE familyId='\(id)'")
                try db.execute(sql: "DELETE FROM FamilyJoint WHERE smallFamilyId='\(id)'")
                try db.execute(sql: "DELETE FROM FamilyJoint WHERE bigFamilyId='\(id)'")
                try db.execute(sql: "DELETE FROM Family WHERE id='\(id)'")
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    // MARK: - RELATIONSHIP
    
    func getRelationship(primary:String, secondary:String) -> (String, String) {
        var value1 = ""
        var value2 = ""
        do {
            let db = ModelStoreGRDB.sharedDBPool()
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
            print(error)
        }
        return (value1, value2)
    }
    
    func getRelationships(peopleId:String) -> [[String:String]] {
        var result:[[String:String]] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
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
            print(error)
        }
        return result
    }
    
    func saveRelationship(primary:String, secondary:String, callName:String) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                let rows = try Row.fetchAll(db, sql: "SELECT subject,object,callName FROM PeopleRelationship WHERE subject='\(primary)' AND object='\(secondary)'")
                if rows.count > 0 {
                    try db.execute(sql: "UPDATE PeopleRelationship SET callName='\(callName)' WHERE subject='\(primary)' AND object='\(secondary)'")
                }else{
                    try db.execute(sql: "INSERT INTO PeopleRelationship (subject, object, callName) VALUES ('\(primary)','\(secondary)','\(callName)')")
                }
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func getRelationships() -> [PeopleRelationship] {
        var obj:[PeopleRelationship] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                obj = try PeopleRelationship.fetchAll(db)
            }
        }catch{
            print(error)
        }
        return obj
    }
    
    // MARK: - PEOPLE
    
    func getPeople() -> [People] {
        var obj:[People] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                obj = try People.order(sql: "name asc").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return obj
    }
    
    func getPeople(except:String) -> [People] {
        var obj:[People] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                obj = try People.filter(sql: "id <> '\(except)'").order(sql: "name asc").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return obj
    }
    
    func getPerson(id: String) -> People? {
        var obj:People?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                obj = try People.fetchOne(db, key: id)
            }
            return obj
        }catch{
            print(error)
        }
        return nil
    }
    
    func savePersonName(id:String, name:String, shortName:String) -> ExecuteState {
        var person = People.new(id: id, name: name, shortName: shortName)
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try person.save(db)
            }
        }catch{
            return ModelStore.errorState(error)
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
                let db = ModelStoreGRDB.sharedDBPool()
                try db.write { db in
                    try ps.save(db)
                }
                return true
            }catch{
                print(error)
                return false
            }
        }else{
            return false
        }
    }
    
    func deletePerson(id:String) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "update ImageFace set peopleId = '', peopleAge = 0 where peopleId = ?", arguments: [id])
                try db.execute(sql: "delete from People where id = ?", arguments: [id])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    // MARK: - FACE
    
    func getFace(id: String) -> ImageFace? {
        var obj:ImageFace?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                obj = try ImageFace.fetchOne(db, key: id)
            }
            return obj
        }catch{
            print(error)
        }
        return nil
    }
    
    func getFaceCrops(imageId: String) -> [ImageFace] {
        var result:[ImageFace] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageFace.filter(sql: "imageId='\(imageId)'").order(sql: "cast(faceX as decimal)").fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func findFaceCrop(imageId: String, x:String, y:String, width:String, height:String) -> ImageFace? {
        var obj:ImageFace?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                obj = try ImageFace.filter(sql: "imageId='\(imageId)' and faceX='\(x)' and faceY='\(y)' and faceWidth='\(width)' and faceHeight='\(height)'").fetchOne(db)
            }
            return obj
        }catch{
            print(error)
        }
        return nil
    }
    
    func getYearsOfFaceCrops(peopleId:String) -> [String]{
        let condition = peopleId == "Unknown" || peopleId == "" ? "peopleId is null or peopleId='' or peopleId='Unknown'" : "peopleId='\(peopleId)'"
        var results:[String] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT DISTINCT imageYear FROM ImageFace WHERE \(condition)")
                for row in rows {
                    if let value = row["imageYear"] as Int? {
                        results.append("\(value)")
                    }
                }
            }
        }catch{
            print(error)
        }
        return results.sorted().reversed()
    }
    
    func getMonthsOfFaceCrops(peopleId:String, imageYear:String) -> [String]{
        let condition = peopleId == "Unknown" || peopleId == "" ? "(peopleId is null or peopleId='' or peopleId='Unknown')" : "peopleId='\(peopleId)'"
        var results:[String] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT DISTINCT imageMonth FROM ImageFace WHERE imageYear=\(imageYear) and \(condition)")
                for row in rows {
                    if let value = row["imageMonth"] as Int? {
                        if value < 10 {
                            results.append("0\(value)")
                        }else{
                            results.append("\(value)")
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
        return results.sorted().reversed()
    }
    
    func getFaceCrops(peopleId:String, year:Int? = nil, month:Int? = nil, sample:Bool? = nil, icon:Bool? = nil, tag:Bool? = nil, locked:Bool? = nil) -> [ImageFace]{
        var sql = ""
        if peopleId != "" && peopleId != "Unknown" {
            sql = "peopleId='\(peopleId)'"
        }else{
            sql = "(peopleId is null or peopleId='Unknown' or peopleId='')"
        }
        if let year = year {
            sql = "\(sql) and imageYear=\(year)"
        }
        if let month = month {
            sql = "\(sql) and imageMonth=\(month)"
        }
        if let sample = sample {
            sql = "\(sql) and sampleChoice=\(sample ? 1 : 0)"
        }
        if let icon = icon {
            sql = "\(sql) and iconChoice=\(icon ? 1 : 0)"
        }
        if let tag = tag {
            sql = "\(sql) and tagOnly=\(tag ? 1 : 0)"
        }
        if let locked = locked {
            sql = "\(sql) and locked=\(locked ? 1 : 0)"
        }
        var result:[ImageFace] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageFace.filter(sql: sql).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func saveFaceCrop(_ face:ImageFace) -> ExecuteState {
        var f = face
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try f.save(db)
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func updateFaceIconFlag(id:String, peopleId:String) -> ExecuteState {
        if let face = self.getFace(id: id) {
            do {
                let db = ModelStoreGRDB.sharedDBPool()
                try db.write { db in
                    try db.execute(sql: "update ImageFace set iconChoice = 0 where peopleId = ? and iconChoice = 1", arguments: [peopleId])
                    try db.execute(sql: "update ImageFace set iconChoice = 1 where peopleId = ? and id = ?", arguments: [peopleId, id])
                    try db.execute(sql: "update People set iconRepositoryPath = ?, iconCropPath = ?, iconSubPath = ?, iconFilename = ? WHERE id = ?", arguments: [face.repositoryPath, face.cropPath, face.subPath, face.filename, peopleId]);
                }
            }catch{
                return ModelStore.errorState(error)
            }
            return .OK
        }
        return .NO_RECORD
    }
    
    func removeFaceIcon(peopleId:String) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "update ImageFace set iconChoice = 0 where peopleId = ? and iconChoice = 1", arguments: [peopleId])
                try db.execute(sql: "update People set iconRepositoryPath = '', iconCropPath = '', iconSubPath = '', iconFilename = '' WHERE id = ?", arguments: [peopleId]);
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func updateFaceSampleFlag(id:String, flag:Bool) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "update ImageFace set sampleChoice = \(flag ? 1 : 0), sampleChangeDate = ? where id = ?", arguments: [Date(), id])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func updateFaceTagFlag(id:String, flag:Bool) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "update ImageFace set tagOnly = \(flag ? 1 : 0) where id = ?", arguments: [id])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func updateFaceLockFlag(id:String, flag:Bool) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "update ImageFace set locked = \(flag ? 1 : 0) where id = ?", arguments: [id])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func updateFaceCropPaths(old:String, new:String) -> ExecuteState {
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try db.execute(sql: "update ImageFace set cropPath = ? where cropPath = ?", arguments: [new, old])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
}
