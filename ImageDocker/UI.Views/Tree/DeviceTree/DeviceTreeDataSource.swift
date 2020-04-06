//
//  DeviceTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class DeviceTreeDataSource : TreeDataSource {
    
    private var deviceDao = DeviceDao.default
    
    private var deviceIdToDevice : [String : PhoneDevice] = [String : PhoneDevice] ()
    
    func loadChildren(_ collection: TreeCollection?) -> ([TreeCollection], String?) {
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
        let devs = self.deviceDao.getDevices(type: type)
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
        print("android device count: \(devices.count)")
        self.cleanCachedDeviceIds(type: .Android)
        if devices.count > 0 {
            for deviceId in devices {
                if let device:PhoneDevice = Android.bridge.device(id: deviceId) {
                    let imageDevice = self.deviceDao.getOrCreateDevice(device: device)
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
            message = "Enable [DEBUG MODE] in [Settings >> System >> Developer Options] if you've connected your phone via USB."
            
        }
        print("loader loaded count \(nodes.count)")
        return (nodes, message)
    }
    
    private func loadIPhoneDevices() -> ([TreeCollection], String?) {
        if PreferencesController.iosDeviceMountPoint() == "" {
            return ([], "Please setup mount point for iOS devices")
        }
        
        if !IPHONE.bridge.validCommands() {
//                self.showTreeNodeButton(collection: collection, image: NSImage(named: .caution))
            
            return ([], "iFuse/iDevice is not installed. Please install it by command [brew cask install osxfuse] and then [brew install ifuse] in console. To install Homebrew as a prior condition, please access [https://brew.sh] for detail.")
        }
        
        var nodes:[TreeCollection] = []
        
        var (devs, deviceIds) = self.loadDevicesFromDatabase(type: "iPhone")
        
        // devices those connected
        let devices:[String] = IPHONE.bridge.devices()
        print("iphone device count: \(devices.count)")
        self.cleanCachedDeviceIds(type: .iPhone)
        if devices.count > 0 {
            if let device:PhoneDevice = IPHONE.bridge.device() {
                let imageDevice = self.deviceDao.getOrCreateDevice(device: device)
                print("connected ios device: \(imageDevice.deviceId ?? "")")
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
                print("Unable to connect to ios device: \(devices[0])")
                return ([], "Unable to connect to iOS device. Please unlock the screen and then retry.")
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
            
            message = "No iOS devices found connected. Please connect your iPhone/iPad via USB."
        }
        print("loader loaded count \(nodes.count)")
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
