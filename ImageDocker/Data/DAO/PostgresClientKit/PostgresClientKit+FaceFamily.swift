//
//  PostgresClientKit+FaceFamily.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

class ImageFaceDaoPostgresCK : ImageFaceDaoInterface {
    func updateImageScannedFace(imageId: String, facesCount: Int) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "Image" set "scanedFace"=true, "facesCount"=$1 where id=$2
            """, parameterValues: [facesCount, imageId])
        }catch{
            print(error)
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
            print(error)
            return .ERROR
        }
        return .OK
    }
    

}

class FaceDaoPostgresCK : FaceDaoInterface {
    
    func getFamilies() -> [Family] {
        let db = PostgresConnection.database()
        return Family.fetchAll(db, orderBy: "name")
    }
    
    func getFamilies(peopleId: String) -> [String] {
        let db = PostgresConnection.database()
        final class TempRecord : PostgresCustomRecord {
            var familyId:String = ""
            public init() {}
        }
        let records = TempRecord.fetchAll(db, sql: """
        SELECT "familyId" FROM "FamilyMember" WHERE "peopleId"='\(peopleId)'
        """)
        var result:[String] = []
        for row in records {
            result.append(row.familyId)
        }
        return result
    }
    
    func saveFamilyMember(peopleId: String, familyId: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        final class TempRecord : PostgresCustomRecord {
            var familyId:String = ""
            var peopleId:String = ""
            public init() {}
        }
        let records = TempRecord.fetchAll(db, sql: """
        SELECT "familyId","peopleId" FROM "FamilyMember" WHERE "familyId"='\(familyId)' AND "peopleId"='\(peopleId)'
        """)
        if records.count == 0 {
            let record = FamilyMember()
            record.familyId = familyId
            record.peopleId = peopleId
            record.save(db)
        }
        return .OK
    }
    
    func deleteFamilyMember(peopleId: String, familyId: String) -> ExecuteState {
        let db = PostgresConnection.database()
        let record = FamilyMember()
        record.familyId = familyId
        record.peopleId = peopleId
        record.delete(db)
        return .OK
    }
    
    func saveFamily(familyId: String?, name: String, type: String) -> String? {
        let db = PostgresConnection.database()
        var recordId:String? = ""
        
        do {
            var needInsert = false
            if let id = familyId {
                final class TempRecord : PostgresCustomRecord {
                    var id:String = ""
                    public init() {}
                }
                let rows = TempRecord.fetchAll(db, sql: "SELECT id FROM \"Family\" WHERE id='\(id)'")
                if rows.count > 0 {
                    recordId = id
                    try db.execute(sql: "UPDATE \"Family\" SET name='\(name)',category='\(type)' WHERE id='\(id)'")
                }else{
                    needInsert = true
                }
            }else{
                needInsert = true
            }
            if needInsert {
                recordId = UUID().uuidString
                try db.execute(sql: "INSERT INTO \"Family\" (id, name, category) VALUES ('\(recordId!)','\(name)','\(type)')")
            }
        }catch{
            print(error)
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
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func getRelationship(primary: String, secondary: String) -> (String, String) {
        var value1 = ""
        var value2 = ""
        let db = PostgresConnection.database()
        if let rows1 = PeopleRelationship.fetchOne(db, where: "subject='\(primary)' AND object='\(secondary)'") {
            value1 = rows1.callName
        }
        if let rows2 = PeopleRelationship.fetchOne(db, where: "subject='\(secondary)' AND object='\(primary)'") {
            value2 = rows2.callName
        }
        return (value1, value2)
    }
    
    func getRelationships(peopleId: String) -> [[String : String]] {
        var result:[[String:String]] = []
        let db = PostgresConnection.database()
        let rows = PeopleRelationship.fetchAll(db, where: "subject='\(peopleId)' OR object='\(peopleId)'")
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
        return result
    }
    
    func saveRelationship(primary: String, secondary: String, callName: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            let rows = PeopleRelationship.fetchAll(db, sql: "SELECT subject,object,\"callName\" FROM \"PeopleRelationship\" WHERE subject='\(primary)' AND object='\(secondary)'")
            if rows.count > 0 {
                try db.execute(sql: "UPDATE \"PeopleRelationship\" SET \"callName\"='\(callName)' WHERE subject='\(primary)' AND object='\(secondary)'")
            }else{
                try db.execute(sql: "INSERT INTO \"PeopleRelationship\" (subject, object, \"callName\") VALUES ('\(primary)','\(secondary)','\(callName)')")
            }
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func getRelationships() -> [PeopleRelationship] {
        let db = PostgresConnection.database()
        return PeopleRelationship.fetchAll(db)
    }
    
    func getPeople() -> [People] {
        let db = PostgresConnection.database()
        return People.fetchAll(db, orderBy: "name")
    }
    
    func getPeople(except: String) -> [People] {
        let db = PostgresConnection.database()
        return People.fetchAll(db, where: "id <> '\(except)'", orderBy: "name")
    }
    
    func getPerson(id: String) -> People? {
        let db = PostgresConnection.database()
        return People.fetchOne(db, parameters: ["id" : id])
    }
    
    func getPerson(name: String) -> People? {
        let db = PostgresConnection.database()
        return People.fetchOne(db, parameters: ["name" : name])
    }
    
    func savePersonName(id: String, name: String, shortName: String) -> ExecuteState {
        let db = PostgresConnection.database()
        let person = People()
        person.id = id
        person.name = name
        person.shortName = shortName
        person.save(db)
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
            ps.save(db)
            return true
        }
        return false
    }
    
    func deletePerson(id: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: "update \"ImageFace\" set \"peopleId\" = '', \"peopleAge\" = 0 where \"peopleId\" = $1", parameterValues: [id])
            try db.execute(sql: "delete from \"People\" where id = $1", parameterValues: [id])
        }catch{
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func getFace(id: String) -> ImageFace? {
        let db = PostgresConnection.database()
        return ImageFace.fetchOne(db, parameters: ["id" : id])
    }
    
    func getFaceCrops(imageId: String) -> [ImageFace] {
        let db = PostgresConnection.database()
        return ImageFace.fetchAll(db, where: "\"imageId\"='\(imageId)'", orderBy: "faceX".quotedDatabaseIdentifier)
    }
    
    func findFaceCrop(imageId: String, x: String, y: String, width: String, height: String) -> ImageFace? {
        let db = PostgresConnection.database()
        return ImageFace.fetchOne(db, parameters: ["imageId" : imageId, "faceX" : x, "faceY": y, "faceWidth": width, "faceHeight" : height])
    }
    
    func getYearsOfFaceCrops(peopleId: String) -> [String] {
        var results:[String] = []
        let condition = peopleId == "Unknown" || peopleId == "" ? "\"peopleId\" is null or \"peopleId\"='' or \"peopleId\"='Unknown'" : "\"peopleId\"='\(peopleId)'"
        let db = PostgresConnection.database()
        final class TempRecord : PostgresCustomRecord {
            var imageYear:Int = 0
            public init() {}
        }
        let rows = TempRecord.fetchAll(db, sql: "SELECT DISTINCT \"imageYear\" FROM \"ImageFace\" WHERE \(condition) ORDER BY \"imageYear\" DESC")
        for row in rows {
            results.append("\(row.imageYear)")
        }
        return results
    }
    
    func getMonthsOfFaceCrops(peopleId: String, imageYear: String) -> [String] {
        var results:[String] = []
        let db = PostgresConnection.database()
        let condition = peopleId == "Unknown" || peopleId == "" ? "(\"peopleId\" is null or \"peopleId\"='' or \"peopleId\"='Unknown')" : "\"peopleId\"='\(peopleId)'"
        final class TempRecord : PostgresCustomRecord {
            var imageMonth:Int = 0
            public init() {}
        }
        let rows = TempRecord.fetchAll(db, sql: "SELECT DISTINCT \"imageMonth\" FROM \"ImageFace\" WHERE \"imageYear\"=\(imageYear) and \(condition) ORDER BY \"imageMonth\" DESC")
        for row in rows {
            if row.imageMonth < 10 {
                results.append("0\(row.imageMonth)")
            }else{
                results.append("\(row.imageMonth)")
            }
        }
        return results
    }
    
    func getFaceCrops(peopleId: String, year: Int?, month: Int?, sample: Bool?, icon: Bool?, tag: Bool?, locked: Bool?) -> [ImageFace] {
        let db = PostgresConnection.database()
        var sql = ""
        if peopleId != "" && peopleId != "Unknown" {
            sql = "\"peopleId\"='\(peopleId)'"
        }else{
            sql = "(\"peopleId\" is null or \"peopleId\"='Unknown' or \"peopleId\"='')"
        }
        if let year = year {
            sql = "\(sql) and \"imageYear\"=\(year)"
        }
        if let month = month {
            sql = "\(sql) and \"imageMonth\"=\(month)"
        }
        if let sample = sample {
            sql = "\(sql) and \"sampleChoice\"=\(sample ? "true" : "false")"
        }
        if let icon = icon {
            sql = "\(sql) and \"iconChoice\"=\(icon ? "true" : "false")"
        }
        if let tag = tag {
            sql = "\(sql) and \"tagOnly\"=\(tag ? "true" : "false")"
        }
        if let locked = locked {
            sql = "\(sql) and locked=\(locked ? "true" : "false")"
        }
        return ImageFace.fetchAll(db, where: sql)
    }
    
    func saveFaceCrop(_ face: ImageFace) -> ExecuteState {
        let db = PostgresConnection.database()
        face.save(db)
        return .OK
    }
    
    func updateFaceIconFlag(id: String, peopleId: String) -> ExecuteState {
        let db = PostgresConnection.database()
        if let face = self.getFace(id: id) {
            do {
                try db.execute(sql: """
                update "ImageFace" set "iconChoice" = false where "peopleId" = $1 and "iconChoice" = true
                """, parameterValues: [peopleId])
                try db.execute(sql: """
                update "ImageFace" set "iconChoice" = true where "peopleId" = $1 and id = $2
                """, parameterValues: [peopleId, id])
                try db.execute(sql: """
                update "People" set "iconRepositoryPath" = $1, "iconCropPath" = $2, "iconSubPath" = $3, "iconFilename" = $4 WHERE id = $5
                """, parameterValues: [face.repositoryPath, face.cropPath, face.subPath, face.filename, peopleId]);
            }catch{
                return .ERROR
            }
            return .OK
        }
        return .NO_RECORD
    }
    
    func removeFaceIcon(peopleId: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            try db.execute(sql: """
            update "ImageFace" set "iconChoice" = false where "peopleId" = $1 and "iconChoice" = true
            """, parameterValues: [peopleId])
            try db.execute(sql: """
            update "People" set "iconRepositoryPath" = '', "iconCropPath" = '', "iconSubPath" = '', "iconFilename" = '' WHERE id = $1
            """, parameterValues: [peopleId]);
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    func updateFaceSampleFlag(id: String, flag: Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "ImageFace" set "sampleChoice" = \(flag ? "true" : "false"), "sampleChangeDate" = $1 where id = $1
            """, parameterValues: [Date(), id])
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    func updateFaceTagFlag(id: String, flag: Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "ImageFace" set "tagOnly" = \(flag ? "true" : "false") where id = $1
            """, parameterValues: [id])
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    func updateFaceLockFlag(id: String, flag: Bool) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "ImageFace" set locked = \(flag ? "true" : "false") where id = $1
            """, parameterValues: [id])
        }catch{
            return .ERROR
        }
        return .OK
    }
    
    func updateFaceCropPaths(old: String, new: String) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try db.execute(sql: """
            update "ImageFace" set "cropPath" = $1 where "cropPath" = $2
            """, parameterValues: [new, old])
        }catch{
            return .ERROR
        }
        return .OK
    }
    

}
