//
//  DeviceDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class DeviceDao {
    
    func getDevices() -> [ImageDevice] {
        return ModelStore.default.getDevices()
    }
    
    func getOrCreateDevice(device:PhoneDevice) -> ImageDevice{
        return ModelStore.default.getOrCreateDevice(device: device)
    }
    
    func getDevice(deviceId:String) -> ImageDevice? {
        return ModelStore.default.getDevice(deviceId: deviceId)
    }
    
    func saveDevice(device:ImageDevice) -> ExecuteState{
        return ModelStore.default.saveDevice(device: device)
    }
    
    // MARK: - FILES ON DEVICE
    
    func getImportedFile(deviceId:String, file:PhoneFile) -> ImageDeviceFile? {
        return ModelStore.default.getImportedFile(deviceId: deviceId, file: file)
    }
    
    func getOrCreateDeviceFile(deviceId:String, file:PhoneFile) -> ImageDeviceFile{
        return ModelStore.default.getOrCreateDeviceFile(deviceId: deviceId, file: file)
    }
    
    func saveDeviceFile(file:ImageDeviceFile) -> ExecuteState{
        return ModelStore.default.saveDeviceFile(file: file)
    }
    
    func deleteDeviceFiles(deviceId:String) -> ExecuteState{
        return ModelStore.default.deleteDeviceFiles(deviceId: deviceId)
    }
    
    func getDeviceFiles(deviceId:String) -> [ImageDeviceFile] {
        return ModelStore.default.getDeviceFiles(deviceId: deviceId)
    }
    
    func getDeviceFiles(deviceId:String, importToPath:String) -> [ImageDeviceFile] {
        return ModelStore.default.getDeviceFiles(deviceId: deviceId, importToPath: importToPath)
    }
    
    // MARK: - PATHS ON DEVICE
    
    func getDevicePath(deviceId:String, path:String) -> ImageDevicePath? {
        return ModelStore.default.getDevicePath(deviceId: deviceId, path: path)
    }
    
    func saveDevicePath(file:ImageDevicePath) -> ExecuteState {
        return ModelStore.default.saveDevicePath(file: file)
    }
    
    func deleteDevicePath(deviceId:String, path:String) -> ExecuteState{
        return ModelStore.default.deleteDevicePath(deviceId: deviceId, path: path)
    }
    
    func getDevicePaths(deviceId:String, deviceType:MobileType = .Android) -> [ImageDevicePath] {
        return ModelStore.default.getDevicePaths(deviceId: deviceId, deviceType: deviceType)
    }
    
    func getExcludedImportedContainerPaths(withStash:Bool = false) -> Set<String>{
        return ModelStore.default.getExcludedImportedContainerPaths(withStash: withStash)
    }
    
    func getLastImportDateOfDevices() -> ([String:String], [(String,String,String?,String?)]) {
        return ModelStore.default.getLastImportDateOfDevices()
    }
    
    
}
