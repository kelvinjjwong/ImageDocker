//
//  DeviceTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class DeviceTreeDataSource : TreeDataSource {
    
    let logger = ConsoleLogger(category: "TREE", subCategory: "DEVICE")
    
    private var deviceIdToDevice : [String : PhoneDevice] = [String : PhoneDevice] ()
    
    func loadChildren(_ collection: TreeCollection?, condition:SearchCondition?) -> ([TreeCollection], String?) {
        
        if let condition = condition, !condition.isEmpty() {
            // TODO: search ImageDeviceFile first ??
        }
        
        if collection == nil {
            let android = TreeCollection("Android")
            let iphone = TreeCollection("iPhone")
            return ([android, iphone], nil)
        }else{
            if let col = collection {
                if col.name == "Android" {
                    return self.loadAndroidDevices()
                }else if col.name == "iPhone" {
                    return self.loadIPhoneDevices()
                }
            }
        }
        return ([], nil)
    }
    
    func findNode(path: String) -> TreeCollection? {
        return nil
    }
    
    func filter(keyword: String) {
        
    }
    
    func findNode(keyword: String) -> TreeCollection? {
        return nil
    }
    
    private func convertToTreeNode(device: PhoneDevice, connected: Bool) -> TreeCollection {
        return TreeCollection(device.represent(), id: device.deviceId, object: device, state: connected ? 1 : 0)
    }
    
    private func loadDevicesFromDatabase(type: String) -> ([ImageDevice], [String]) {
        var deviceIds:[String] = []
        let devs = DeviceDao.default.getDevices(type: type)
        for device in devs {
            if let id = device.deviceId {
                deviceIds.append(id)
            }
        }
        return (devs, deviceIds)
    }
    
    private func loadAndroidDevices() -> ([TreeCollection], String?) {
        var nodes:[TreeCollection] = []
        
        var (devs, deviceIds) = self.loadDevicesFromDatabase(type: "Android")
        
        // devices those connected
        let devices:[String] = Android.bridge.devices()
//        self.logger.log("android device count: \(devices.count)")
        self.cleanCachedDeviceIds(type: .Android)
        if devices.count > 0 {
            for deviceId in devices {
                if let device:PhoneDevice = Android.bridge.device(id: deviceId) {
                    let imageDevice = DeviceDao.default.getOrCreateDevice(device: device)
                    var dev:PhoneDevice = Android.bridge.memory(device: device)
                    if imageDevice.name != "" {
                        dev.name = imageDevice.name ?? ""
                    }
                    self.deviceIdToDevice[deviceId] = dev
                    let node = self.convertToTreeNode(device: dev, connected: true)
                    nodes.append(node)
                    
                    if let id = imageDevice.deviceId, let i = deviceIds.firstIndex(of: id) {
                        deviceIds.remove(at: i)
                    }
                }
            }
        }
        // devices those not connected
        if deviceIds.count > 0 {
            for device in devs {
                if let id = device.deviceId, let _ = deviceIds.firstIndex(of: id) {
                    var dev:PhoneDevice = PhoneDevice(type: .Android, deviceId: id, manufacture: device.manufacture ?? "", model: device.model ?? "")
                    dev.name = device.name ?? ""
                    
                    self.deviceIdToDevice[id] = dev
                    let node = self.convertToTreeNode(device: dev, connected: false)
                    nodes.append(node)
                }
            }
        }
        var message:String? = nil
        if devices.count == 0 {
//                self.showTreeNodeButton(collection: collection, image: NSImage(named: .caution))
            message = Words.device_tree_need_debug_mode.word()
            
        }
        logger.log("loader loaded count \(nodes.count)")
        return (nodes, message)
    }
    
    private func loadIPhoneDevices() -> ([TreeCollection], String?) {
        if PreferencesController.iosDeviceMountPoint() == "" {
            return ([], Words.device_tree_setup_mountpoint_for_ios.word())
        }
        
        if !IPHONE.bridge.validCommands() {
//                self.showTreeNodeButton(collection: collection, image: NSImage(named: .caution))
            
            return ([], Words.device_tree_ifuse_not_installed.word())
        }
        
        var nodes:[TreeCollection] = []
        
        var (devs, deviceIds) = self.loadDevicesFromDatabase(type: "iPhone")
        
        // devices those connected
        let devices:[String] = IPHONE.bridge.devices()
        logger.log("iphone device count: \(devices.count)")
        self.cleanCachedDeviceIds(type: .iPhone)
        if devices.count > 0 {
            if let device:PhoneDevice = IPHONE.bridge.device() {
                let imageDevice = DeviceDao.default.getOrCreateDevice(device: device)
                logger.log("connected ios device: \(imageDevice.deviceId ?? "")")
                var dev = device
                if imageDevice.name != "" {
                    dev.name = imageDevice.name ?? ""
                }
                self.deviceIdToDevice[device.deviceId] = dev

                let node = self.convertToTreeNode(device: dev, connected: true)
                nodes.append(node)
                
                if let id = imageDevice.deviceId, let i = deviceIds.firstIndex(of: id) {
                    deviceIds.remove(at: i)
                }
            }else{
                logger.log("Unable to connect to ios device: \(devices[0])")
                return ([], Words.device_tree_unable_to_connect_ios.word())
            }
        }
        // devices those not connected
        if deviceIds.count > 0 {
            for device in devs {
                if let id = device.deviceId, let _ = deviceIds.firstIndex(of: id), let t = device.type, t == "iPhone" {
                    var dev:PhoneDevice = PhoneDevice(type: .iPhone, deviceId: id, manufacture: device.manufacture ?? "", model: device.model ?? "")
                    dev.name = device.name ?? ""
                    
                    self.deviceIdToDevice[id] = dev

                    let node = self.convertToTreeNode(device: dev, connected: false)
                    nodes.append(node)
                }
            }
        }
        var message:String? = nil
        if devices.count == 0 {
//                self.showTreeNodeButton(collection: collection, image: NSImage(named: .caution))
            
            message = Words.device_tree_no_ios_connected.word()
        }
        logger.log("loader loaded count \(nodes.count)")
        return (nodes, message)
    }
    
    private func cleanCachedDeviceIds(type:MobileType){
        for deviceId in deviceIdToDevice.keys {
            if let device = deviceIdToDevice[deviceId], device.type == type {
                self.deviceIdToDevice.removeValue(forKey: deviceId)
            }
        }
    }
    
    func getDeviceById(_ deviceId:String) -> PhoneDevice? {
        return self.deviceIdToDevice[deviceId]
    }

}
