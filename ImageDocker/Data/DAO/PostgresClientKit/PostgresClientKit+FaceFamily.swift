//
//  PostgresClientKit+FaceFamily.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory

class ImageFaceDaoPostgresCK : ImageFaceDaoInterface {
    
    let logger = LoggerFactory.get(category: "ImageFaceDaoPostgresCK")
    
    func updateImageScannedFace(imageId: String, facesCount: Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "scanedFace"=true, "facesCount"=$1 where id=$2
            """, parameterValues: [facesCount, imageId])
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func updateImageRecognizedFace(imageId: String, recognizedPeopleIds: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "recognizedFace"=true,"recognizedPeopleIds"=$1 where id=$2
            """, parameterValues: [recognizedPeopleIds,imageId])
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    

}

class FaceDaoPostgresCK : FaceDaoInterface {
    
    let logger = LoggerFactory.get(category: "FaceDaoPostgresCK")
    
    func getFamily(id:String) -> Family? {
        let db = PostgresConnection.database()
        do {
            return try Family.fetchOne(db, parameters: ["id" : id])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getFamilies() -> [Family] {
        let db = PostgresConnection.database()
        do {
            return try Family.fetchAll(db, orderBy: "name")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getFamilies(peopleId: String) -> [String] {
        var result:[String] = []
        let db = PostgresConnection.database()
        final class TempRecord : DatabaseRecord {
            var familyId:String = ""
            public init() {}
        }
        do {
            let records = try TempRecord.fetchAll(db, sql: """
            SELECT "familyId" FROM "FamilyMember" WHERE "peopleId"='\(peopleId)'
            """)
            for row in records {
                result.append(row.familyId)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
    }
    
    func saveFamilyMember(peopleId: String, familyId: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        final class TempRecord : DatabaseRecord {
            var familyId:String = ""
            var peopleId:String = ""
            public init() {}
        }
        do {
            let records = try TempRecord.fetchAll(db, sql: """
            SELECT "familyId","peopleId" FROM "FamilyMember" WHERE "familyId"='\(familyId)' AND "peopleId"='\(peopleId)'
            """)
            if records.count == 0 {
                let record = FamilyMember()
                record.familyId = familyId
                record.peopleId = peopleId
                try record.save(db)
            }
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func deleteFamilyMember(peopleId: String, familyId: String) -> ExecuteState {
        let db = PostgresConnection.database()
        let record = FamilyMember()
        record.familyId = familyId
        record.peopleId = peopleId
        do {
            try record.delete(db)
        return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func saveFamily(familyId: String?, name: String, type: String, owner:String) -> String? {
        let db = PostgresConnection.database()
        var recordId:String? = ""
        
        do {
            var needInsert = false
            if let id = familyId {
                final class TempRecord : DatabaseRecord {
                    var id:String = ""
                    public init() {}
                }
                let rows = try TempRecord.fetchAll(db, sql: "SELECT \"id\" FROM \"Family\" WHERE \"id\"='\(id)'")
                if rows.count > 0 {
                    recordId = id
                    try db.execute(sql: """
        UPDATE "Family" SET name='\(name)',category='\(type)',owner='\(owner)' WHERE "id"='\(id)'
        """)
                    try db.execute(sql: """
        UPDATE "ImageFamily" set "familyName"='\(name)' WHERE "familyId"='\(id)'
        """)
                }else{
                    needInsert = true
                }
            }else{
                needInsert = true
            }
            if needInsert {
                recordId = UUID().uuidString
                try db.execute(sql: "INSERT INTO \"Family\" (id, name, category, owner) VALUES ('\(recordId!)','\(name)','\(type)','\(owner)')")
            }
        }catch{
            self.logger.log(.error, error)
            recordId = nil
        }
        return recordId
    }
    
    func deleteFamily(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: "DELETE FROM \"FamilyMember\" WHERE \"familyId\"='\(id)'")
            try db.execute(sql: "DELETE FROM \"FamilyJoint\" WHERE \"smallFamilyId\"='\(id)'")
            try db.execute(sql: "DELETE FROM \"FamilyJoint\" WHERE \"bigFamilyId\"='\(id)'")
            try db.execute(sql: "DELETE FROM \"Family\" WHERE id='\(id)'")
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func getFamilyMembers() -> [FamilyMember] {
        let db = PostgresConnection.database()
        do {
            return try FamilyMember.fetchAll(db)
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getRelationship(primary: String, secondary: String) -> (String, String) {
        var value1 = ""
        var value2 = ""
        let db = PostgresConnection.database()
        do {
            if let rows1 = try PeopleRelationship.fetchOne(db, where: "subject='\(primary)' AND object='\(secondary)'") {
                value1 = rows1.callName
            }
            if let rows2 = try PeopleRelationship.fetchOne(db, where: "subject='\(secondary)' AND object='\(primary)'") {
                value2 = rows2.callName
            }
        }catch{
            self.logger.log(.error, error)
        }
        return (value1, value2)
    }
    
    func getRelationships(peopleId: String) -> [[String : String]] {
        var result:[[String:String]] = []
        let db = PostgresConnection.database()
        do {
            let rows = try PeopleRelationship.fetchAll(db, where: "subject='\(peopleId)' OR object='\(peopleId)'")
            for row in rows {
                let primary = row.subject
                let secondary = row.object
                let callName = row.callName
                var dict:[String:String] = [:]
                dict["primary"] = primary
                dict["secondary"] = secondary
                dict["callName"] = callName
                result.append(dict)
            }
        }catch{
            self.logger.log(.error, error)
        }
        return result
    }
    
    func saveRelationship(primary: String, secondary: String, callName: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            let rows = try PeopleRelationship.fetchAll(db, sql: "SELECT subject,object,\"callName\" FROM \"PeopleRelationship\" WHERE subject='\(primary)' AND object='\(secondary)'")
            if rows.count > 0 {
                try db.execute(sql: "UPDATE \"PeopleRelationship\" SET \"callName\"='\(callName)' WHERE subject='\(primary)' AND object='\(secondary)'")
            }else{
                try db.execute(sql: "INSERT INTO \"PeopleRelationship\" (subject, object, \"callName\") VALUES ('\(primary)','\(secondary)','\(callName)')")
            }
            return .OK
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func getRelationships() -> [PeopleRelationship] {
        let db = PostgresConnection.database()
        do {
            return try PeopleRelationship.fetchAll(db)
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getPeople() -> [People] {
        let db = PostgresConnection.database()
        do {
            return try People.fetchAll(db, orderBy: "\"coreMember\" desc, \"name\"")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getCoreMembers() -> [People] {
        let db = PostgresConnection.database()
        do {
            return try People.fetchAll(db, parameters: ["coreMember": true], orderBy: "name")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getPeopleIds(inFamilyQuotedSeparated:String, db: PostgresDB) -> [String] {
        var peopleIds:[String] = []
        
        final class TempRecord : DatabaseRecord {
            var peopleId:String = ""
            public init() {}
        }
        do {
            let records = try TempRecord.fetchAll(db, sql: """
            SELECT "peopleId" FROM "FamilyMember" WHERE "familyId" in (\(inFamilyQuotedSeparated))
            """)
            if records.count > 0 {
                for record in records {
                    peopleIds.append(record.peopleId.quotedDatabaseValueIdentifier)
                }
            }
        }catch{
            self.logger.log(.error, error)
        }
        return peopleIds
    }
    
    func getPeople(inFamilyQuotedSeparated:String, exclude:Bool) -> [People] {
        let db = PostgresConnection.database()
        var stmt = ""
        if inFamilyQuotedSeparated != "" {
            
            let peopleIds:[String] = self.getPeopleIds(inFamilyQuotedSeparated: inFamilyQuotedSeparated, db: db)
            if peopleIds.count > 0 {
                
                let peopleIdsSeparated = peopleIds.joined(separator: ",")
                
                stmt = """
            "id" \(exclude ? "NOT" : "") in (\(peopleIdsSeparated))
            """
            }
        }
        do {
            return try People.fetchAll(db, where: stmt, orderBy: "name")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getPeople(except: String) -> [People] {
        let db = PostgresConnection.database()
        do {
            return try People.fetchAll(db, where: "id <> '\(except)'", orderBy: "name")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getPerson(id: String) -> People? {
        let db = PostgresConnection.database()
        do {
            return try People.fetchOne(db, parameters: ["id" : id])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getPerson(name: String) -> People? {
        let db = PostgresConnection.database()
        do {
            return try People.fetchOne(db, parameters: ["name" : name])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getPerson(nickname: String) -> People? {
        let db = PostgresConnection.database()
        do {
            return try People.fetchOne(db, parameters: ["shortName" : nickname])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func savePersonName(id: String, name: String, shortName: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            let person = People()
            person.id = id
            person.name = name
            person.shortName = shortName
            try person.save(db)
            try db.execute(sql: """
            UPDATE "ImageFamily" set "owner"='\(shortName)' WHERE "ownerId"='\(id)'
            """)
        }catch{
            self.logger.log(.error, "Unable to update people name in ImageFamily table: \(error)")
        }
        return .OK
    }
    
    func updatePersonIconImage(id: String, repositoryPath: String, cropPath: String, subPath: String, filename: String) -> Bool {
        let db = PostgresConnection.database()
        if let person = getPerson(id: id) {
            let ps = person
            ps.iconRepositoryPath = repositoryPath
            ps.iconCropPath = cropPath
            ps.iconSubPath = subPath
            ps.iconFilename = filename
            do {
                try ps.save(db)
                return true
            }catch{
                self.logger.log(.error, error)
                return false
            }
        }
        return false
    }
    
    func deletePerson(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: "delete from \"People\" where id = $1", parameterValues: [id])
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func updatePersonIsCoreMember(id:String, isCoreMember:Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: "update \"People\" set \"coreMember\"='\(isCoreMember ? "t" : "f")' where id = $1", parameterValues: [id])
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func updatePersonCoreMemberColor(id:String, hexColor:String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: "update \"People\" set \"coreMemberColor\"= $1 where id = $2", parameterValues: [hexColor, id])
        }catch{
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func getRepositoryOwnerColors() -> [Int:String] {
        var list:[Int:String] = [:]
        
        final class TempRecord : DatabaseRecord {
            var repositoryId:Int = 0
            var ownerId:String = ""
            var ownerColor:String = ""
            public init() {}
        }
        let db = PostgresConnection.database()
        do {
            let records = try TempRecord.fetchAll(db, sql: """
            select r."id" as "repositoryId",COALESCE(p."id", 'shared') as "ownerId", COALESCE(p."coreMemberColor", '2E2E2E') as "ownerColor" from "ImageRepository" as r LEFT JOIN "People" as p on r.owner = p.id ORDER BY "repositoryId"
            """)
            if records.count > 0 {
                for record in records {
                    list[record.repositoryId] = record.ownerColor
                }
            }
        }catch{
            self.logger.log(.error, error)
        }
        return list
    }
    

}
