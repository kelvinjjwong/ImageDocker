//
//  DeviceDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import SharedDeviceLib

class DeviceDao {
    
    private let impl:DeviceDaoInterface
    
    init(_ impl:DeviceDaoInterface){
        self.impl = impl
    }
    
    static var `default`:DeviceDao {
        let location = Setting.database.databaseLocation()
        if location == "local" {
            return DeviceDao(DeviceDaoPostgresCK())
        }else{
            return DeviceDao(DeviceDaoPostgresCK())
        }
    }
    
    func getDevices() -> [ImageDevice] {
        return self.impl.getDevices()
    }
    
    func getDevices(type:String) -> [ImageDevice] {
        return self.impl.getDevices(type: type)
    }
    
    func getOrCreateDevice(device:PhoneDevice) -> ImageDevice{
        return self.impl.getOrCreateDevice(device: device)
    }
    
    func getDevice(deviceId:String) -> ImageDevice? {
        return self.impl.getDevice(deviceId: deviceId)
    }
    
    func saveDevice(device:ImageDevice) -> ExecuteState{
        return self.impl.saveDevice(device: device)
    }
    
    // MARK: - FILES ON DEVICE
    
    func getImportedFile(deviceId:String, file:PhoneFile) -> ImageDeviceFile? {
        return self.impl.getImportedFile(deviceId: deviceId, file: file)
    }
    
    func getOrCreateDeviceFile(deviceId:String, file:PhoneFile) -> ImageDeviceFile{
        return self.impl.getOrCreateDeviceFile(deviceId: deviceId, file: file)
    }
    
    func saveDeviceFile(file:ImageDeviceFile) -> ExecuteState{
        return self.impl.saveDeviceFile(file: file)
    }
    
    func deleteDeviceFiles(deviceId:String) -> ExecuteState{
        return self.impl.deleteDeviceFiles(deviceId: deviceId)
    }
    
    func getDeviceFiles(deviceId:String) -> [ImageDeviceFile] {
        return self.impl.getDeviceFiles(deviceId: deviceId)
    }
    
    func getDeviceFiles(deviceId:String, importToPath:String) -> [ImageDeviceFile] {
        return self.impl.getDeviceFiles(deviceId: deviceId, importToPath: importToPath)
    }
    
    // MARK: - PATHS ON DEVICE
    
    func getDevicePath(deviceId:String, path:String) -> ImageDevicePath? {
        return self.impl.getDevicePath(deviceId: deviceId, path: path)
    }
    
    func saveDevicePath(file:ImageDevicePath) -> ExecuteState {
        return self.impl.saveDevicePath(file: file)
    }
    
    func deleteDevicePath(deviceId:String, path:String) -> ExecuteState{
        return self.impl.deleteDevicePath(deviceId: deviceId, path: path)
    }
    
    func getDevicePaths(deviceId:String, deviceType:MobileType = .Android) -> [ImageDevicePath] {
        return self.impl.getDevicePaths(deviceId: deviceId, deviceType: deviceType)
    }
    
    func getExcludedImportedContainerPaths(withStash:Bool = false) -> Set<String>{
        return self.impl.getExcludedImportedContainerPaths(withStash: withStash)
    }
    
    func getLastImportDateOfDevices() -> ([String:String], [(String,String,String?,String?)]) {
        return self.impl.getLastImportDateOfDevices()
    }
    
    
}
