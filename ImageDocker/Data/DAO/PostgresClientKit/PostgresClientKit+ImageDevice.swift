//
//  PostgresClientKit+ImageDevice.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory
import SharedDeviceLib

class DeviceDaoPostgresCK : DeviceDaoInterface {
    
    let logger = LoggerFactory.get(category: "DeviceDao", subCategory: "Postgres", includeTypes: [])
    
    func getDevices() -> [ImageDevice] {
        let db = PostgresConnection.database()
        do {
            return try ImageDevice.fetchAll(db, orderBy: "name")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getDevices(type: String) -> [ImageDevice] {
        let db = PostgresConnection.database()
        do {
            return try ImageDevice.fetchAll(db, where: "type = '\(type)'", orderBy: "name")
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getOrCreateDevice(device: PhoneDevice) -> ImageDevice {
        let db = PostgresConnection.database()
        
        let dummy = ImageDevice.new(
            deviceId: device.deviceId,
            type: device.type == .Android ? "Android" : "iPhone",
            manufacture: device.manufacture,
            model: device.model
        )
        
        do {
            if let device = try ImageDevice.fetchOne(db, parameters: ["deviceId": device.deviceId]) {
                return device
            }else{
                
                try dummy.save(db)
                return dummy
            }
        }catch{
            self.logger.log(.error, error)
            return dummy
        }
    }
    
    func getDevice(deviceId: String) -> ImageDevice? {
        let db = PostgresConnection.database()
        do {
            return try ImageDevice.fetchOne(db, parameters: ["deviceId" : deviceId])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func saveDevice(device: ImageDevice) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try device.save(db)
        }catch{
            self.logger.log(.error, error)
        }
        return .OK
    }
    
    func getImportedFile(deviceId: String, file: PhoneFile) -> ImageDeviceFile? {
        let db = PostgresConnection.database()
        let key = "\(deviceId):\(file.path)"
        do {
            return try ImageDeviceFile.fetchOne(db, parameters: ["fileId" : key])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func getOrCreateDeviceFile(deviceId: String, file: PhoneFile) -> ImageDeviceFile {
        let db = PostgresConnection.database()
        let key = "\(deviceId):\(file.path)"
        
        let dummy = ImageDeviceFile.new(
            fileId: key,
            deviceId: deviceId,
            path: file.path,
            filename: file.filename,
            fileDateTime: file.fileDateTime,
            fileSize: file.fileSize
        )
        
        do {
            if let deviceFile = try ImageDeviceFile.fetchOne(db, parameters: ["fileId": key]) {
                return deviceFile
            }else{
                try dummy.save(db)
                return dummy
            }
        }catch{
            self.logger.log(.error, error)
            return dummy
        }
    }
    
    func saveDeviceFile(file: ImageDeviceFile) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try file.save(db)
        }catch{
            self.logger.log(.error, error)
        }
        return .OK
    }
    
    func deleteDeviceFiles(deviceId: String) -> ExecuteState {
        let db = PostgresConnection.database()
        var sample = ImageDeviceFile()
        sample.deviceId = deviceId
        do {
            try sample.delete(db, keyColumns: ["deviceId"])
        }catch{
            self.logger.log(.error, error)
        }
        return .OK
    }
    
    func getDeviceFiles(deviceId: String) -> [ImageDeviceFile] {
        let db = PostgresConnection.database()
        do {
            return try ImageDeviceFile.fetchAll(db, parameters: ["deviceId" : deviceId], orderBy: "importToPath".quotedDatabaseIdentifier)
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getDeviceFiles(deviceId: String, importToPath: String) -> [ImageDeviceFile] {
        let db = PostgresConnection.database()
        do {
            return try ImageDeviceFile.fetchAll(db, parameters: ["deviceId" : deviceId, "importToPath": importToPath], orderBy: "fileId".quotedDatabaseIdentifier)
        }catch{
            self.logger.log(.error, error)
            return []
        }
    }
    
    func getDevicePath(deviceId: String, path: String) -> ImageDevicePath? {
        let db = PostgresConnection.database()
        do {
            return try ImageDevicePath.fetchOne(db, parameters: ["deviceId": deviceId, "path" : path])
        }catch{
            self.logger.log(.error, error)
            return nil
        }
    }
    
    func saveDevicePath(file: ImageDevicePath) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            try file.save(db)
        }catch{
            self.logger.log(.error, error)
        }
        return .OK
    }
    
    func deleteDevicePath(deviceId: String, path: String) -> ExecuteState {
        let db = PostgresConnection.database()
        let sample = ImageDevicePath()
        sample.deviceId = deviceId
        sample.path = path
        do {
            try sample.delete(db, keyColumns: ["deviceId", "path"])
        }catch{
            self.logger.log(.error, error)
        }
        return .OK
    }
    
    func getDevicePaths(deviceId: String, deviceType: MobileType) -> [ImageDevicePath] {
        let db = PostgresConnection.database()
        var result:[ImageDevicePath] = []
        do {
            result = try ImageDevicePath.fetchAll(db, parameters: ["deviceId" : deviceId])
        }catch{
            self.logger.log(.error, error)
        }
        if result.count == 0 {
            if deviceType == .Android {
                result = [
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/DCIM/Camera/", toSubFolder: "Camera"),
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/tencent/MicroMsg/Weixin/", toSubFolder: "WeChat"),
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/tencent/QQ_Images/", toSubFolder: "QQ"),
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/tencent/QQ_Video/", toSubFolder: "QQ"),
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/Snapseed/", toSubFolder: "Snapseed"),
                    ImageDevicePath.include(deviceId: deviceId, path: "/sdcard/Pictures/Instagram/", toSubFolder: "Instagram")
                ]
            }else {
                result = [
                    ImageDevicePath.include(deviceId: deviceId, path: "/DCIM/", toSubFolder: "Camera")
                ]
            }
            for devicePath in result {
                let _ = self.saveDevicePath(file: devicePath)
            }
        }
        return result
    }
    
    func getExcludedImportedContainerPaths(withStash: Bool) -> Set<String> {
        let db = PostgresConnection.database()
        let sql = """
        select distinct (d."repositoryPath" || '/' || p."toSubFolder") path from "ImageDevicePath" p
        left join (select "deviceId","repositoryPath" from "ImageDevice" where "repositoryPath" is not null) d
        on p."deviceId"=d."deviceId"
        where p."excludeImported"=true
        """
        
        final class TempRecord : DatabaseRecord{
            
            var path:String = ""
            
            public init() {}
            
        }
        var records:[TempRecord] = []
        do {
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
        }
        var results:Set<String> = []
        for row in records {
            if withStash {
                results.insert(row.path.withLastStash())
            }else{
                results.insert(row.path)
            }
        }
        return results
    }
    
    func getLastImportDateOfDevices() -> ([String : String], [(String, String, String?, String?)]) {
        let db = PostgresConnection.database()
        let sql = """
        select (CASE WHEN c."name" IS NULL THEN 'NOT_SCAN' ELSE c."name" END) as name,d."deviceId", d."name" as "deviceName", f."lastImportDate",d."repositoryPath",d."storagePath" from "ImageDevice" d left join (
        select max("importDate") as "lastImportDate","deviceId" from "ImageDeviceFile" group by "deviceId" ) f on d."deviceId"=f."deviceId"
        left join
        (select "name","deviceId" from "ImageContainer" where "parentFolder"='') c on d."deviceId"=c."deviceId"
        order by c."name"
        """
        
        final class TempRecord : DatabaseRecord {
            
            var name: String = ""
            var deviceId: String = ""
            var deviceName: String = ""
            var lastImportDate: String = ""
            var repositoryPath:String?
            var storagePath: String?
            
            public init() {}
        }
        var records:[TempRecord] = []
        do { 
            records = try TempRecord.fetchAll(db, sql: sql)
        }catch{
            self.logger.log(.error, error)
        }
        
        var notScans:[(String,String,String?,String?)] = []
        var results:[String:String] = [:]
        for row in records {
            if row.name == "NOT_SCAN" {
                notScans.append((row.deviceName, row.lastImportDate, row.repositoryPath, row.storagePath))
            }else{
                results[row.name] = row.lastImportDate
            }
        }
        return (results, notScans)
    }
    

}
