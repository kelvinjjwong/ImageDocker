//
//  DeviceDaoInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/18.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import SharedDeviceLib

protocol DeviceDaoInterface {
    
    func getDevices() -> [ImageDevice]
    
    func getDevices(type:String) -> [ImageDevice]
    
    func getOrCreateDevice(device:PhoneDevice) -> ImageDevice
    
    func getDevice(deviceId:String) -> ImageDevice?
    
    func saveDevice(device:ImageDevice) -> ExecuteState
    
    func updateMetaInfo(deviceId:String, metaId:String, value:String) -> ExecuteState
    
    // MARK: - FILES ON DEVICE
    
    func getImportedFile(deviceId:String, file:PhoneFile) -> ImageDeviceFile?
    
    func getOrCreateDeviceFile(deviceId:String, file:PhoneFile) -> ImageDeviceFile
    
    func saveDeviceFile(file:ImageDeviceFile) -> ExecuteState
    
    func updateDeviceFileWithImageId(importedImageId: String, repositoryId:Int, subPath:String) -> ExecuteState
    
    func deleteDeviceFiles(deviceId:String) -> ExecuteState
    
    func getDeviceFiles(deviceId:String) -> [ImageDeviceFile]
    
    func getDeviceFile(repositoryId:Int, localFilePath:String) -> ImageDeviceFile?
    
//    func getDeviceFiles(deviceId:String, importToPath:String) -> [ImageDeviceFile]
    
    // MARK: - PATHS ON DEVICE
    
    func getDevicePath(deviceId:String, path:String) -> ImageDevicePath?
    
    func saveDevicePath(file:ImageDevicePath) -> ExecuteState
    
    func deleteDevicePath(deviceId:String, path:String) -> ExecuteState
    
    func getDevicePaths(deviceId:String, deviceType:MobileType) -> [ImageDevicePath]
    
    func getExcludedImportedContainerPaths(withStash:Bool) -> Set<String>
    
    func getLastImportDateOfDevices() -> ([String:String], [(String,String,String?,String?)])
}
