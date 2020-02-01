//
//  ModelStore+ImageDevice.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStoreGRDB {
    // MARK: - DEVICES
    
    func getDevices() -> [ImageDevice] {
        var result:[ImageDevice] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageDevice.order(Column("name").asc).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getDevices(type:String) -> [ImageDevice] {
        var result:[ImageDevice] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageDevice.filter(sql: "type='\(type)'").order(Column("name").asc).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getOrCreateDevice(device:PhoneDevice) -> ImageDevice{
        var dev:ImageDevice?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                dev = try ImageDevice.fetchOne(db, key: device.deviceId)
            }
            if dev == nil {
                try db.write { db in
                    dev = ImageDevice.new(
                        deviceId: device.deviceId,
                        type: device.type == .Android ? "Android" : "iPhone",
                        manufacture: device.manufacture,
                        model: device.model
                    )
                    try dev?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return dev!
    }
    
    func getDevice(deviceId:String) -> ImageDevice? {
        var dev:ImageDevice?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                dev = try ImageDevice.fetchOne(db, key: deviceId)
            }
        }catch{
            print(error)
        }
        return dev
    }
    
    func saveDevice(device:ImageDevice) -> ExecuteState{
        var dev = device
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try dev.save(db)
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    // MARK: - FILES ON DEVICE
    
    func getImportedFile(deviceId:String, file:PhoneFile) -> ImageDeviceFile? {
        var deviceFile:ImageDeviceFile?
        do {
            let key = "\(deviceId):\(file.path)"
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                deviceFile = try ImageDeviceFile.fetchOne(db, key: key)
            }
        }catch{
            print(error)
        }
        return deviceFile
    }
    
    func getOrCreateDeviceFile(deviceId:String, file:PhoneFile) -> ImageDeviceFile{
        var deviceFile:ImageDeviceFile?
        do {
            let key = "\(deviceId):\(file.path)"
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                deviceFile = try ImageDeviceFile.fetchOne(db, key: key)
            }
            if deviceFile == nil {
                try db.write { db in
                    deviceFile = ImageDeviceFile.new(
                        fileId: key,
                        deviceId: deviceId,
                        path: file.path,
                        filename: file.filename,
                        fileDateTime: file.fileDateTime,
                        fileSize: file.fileSize
                    )
                    try deviceFile?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return deviceFile!
    }
    
    func saveDeviceFile(file:ImageDeviceFile) -> ExecuteState{
        var f = file
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
    
    func deleteDeviceFiles(deviceId:String) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try db.execute("delete from ImageDeviceFile where deviceId = ?", arguments: [deviceId])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func getDeviceFiles(deviceId:String) -> [ImageDeviceFile] {
        var result:[ImageDeviceFile] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageDeviceFile.filter(sql: "deviceId='\(deviceId)'").order(Column("importToPath").asc).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    func getDeviceFiles(deviceId:String, importToPath:String) -> [ImageDeviceFile] {
        var result:[ImageDeviceFile] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageDeviceFile.filter(sql: "deviceId='\(deviceId)' and importToPath='\(importToPath)'").order(Column("fileId").asc).fetchAll(db)
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - PATHS ON DEVICE
    
    func getDevicePath(deviceId:String, path:String) -> ImageDevicePath? {
        var devicePath:ImageDevicePath?
        do {
            let key = "\(deviceId):\(path)"
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                devicePath = try ImageDevicePath.fetchOne(db, key: key)
            }
            return devicePath
        }catch{
            print(error)
        }
        return nil
    }
    
    func saveDevicePath(file:ImageDevicePath) -> ExecuteState {
        var f = file
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
    
    func deleteDevicePath(deviceId:String, path:String) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                try db.execute("delete from ImageDevicePath where deviceId = ? and path = ?", arguments: [deviceId, path])
            }
        }catch{
            return ModelStore.errorState(error)
        }
        return .OK
    }
    
    func getDevicePaths(deviceId:String, deviceType:MobileType = .Android) -> [ImageDevicePath] {
        var result:[ImageDevicePath] = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                result = try ImageDevicePath.filter(sql: "deviceId='\(deviceId)'").order(Column("path").asc).fetchAll(db)
            }
        }catch{
            print(error)
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
    
    func getExcludedImportedContainerPaths(withStash:Bool = false) -> Set<String>{
        let sql = """
select distinct (d.repositoryPath || '/' || p.tosubfolder) path from imagedevicepath p
left join (select deviceid,repositorypath from imagedevice where repositorypath is not null) d
on p.deviceId=d.deviceId
where p.excludeimported=1
"""
        var results:Set<String> = []
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql)
                for row in rows {
                    if let path = row["path"] as String? {
                        if withStash {
                            results.insert(path.withStash())
                        }else{
                            results.insert(path)
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
        
        return results
    }
    
    func getLastImportDateOfDevices() -> ([String:String], [(String,String,String?,String?)]) {
        let sql = """
select (CASE WHEN c.name IS NULL THEN 'NOT_SCAN' ELSE c.name END) name,d.deviceid, d.name deviceName, f.lastImportDate,d.repositoryPath,d.storagePath from imageDevice d left join (
select max(importDate) lastImportDate,deviceId from imagedevicefile group by deviceId ) f on d.deviceId=f.deviceId
left join
(select name,deviceid from imageContainer where parentFolder='') c on d.deviceId=c.deviceId
order by c.name
"""
        var notScans:[(String,String,String?,String?)] = []
        var results:[String:String] = [:]
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, sql)
                for row in rows {
                    if let name = row["name"] as String?, let date = row["lastImportDate"] as String?, let deviceName = row["deviceName"] as String? {
                        if name == "NOT_SCAN" {
                            let repoPath = row["repositoryPath"] as String?
                            let backupPath = row["storagePath"] as String?
                            notScans.append((deviceName, date, repoPath, backupPath))
                        }else{
                            results[name] = date
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
        
        return (results, notScans)
    }
}
