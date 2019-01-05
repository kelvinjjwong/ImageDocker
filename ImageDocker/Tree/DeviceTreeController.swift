//
//  DeviceTreeController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/6.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList
import GRDB


extension ViewController {
    
    // MARK: DATA SOURCE
    
    // MARK: REFRESH
    
    // MARK: ADD NODES
    
    func addDeviceTypeTreeEntry(type:String){
        let collection:PhotoCollection = PhotoCollection(title: type ,
                                                         identifier: "device_type_\(type)",
            type: .library,
            source: .device )
        collection.photoCount = 0
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: phoneIcon)
        
        self.deviceItem().addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.deviceToCollection["device_type_\(type)"] = collection
        
        self.treeIdItems["device_type_\(type)"] = item
        
    }
    
    func addDeviceTreeEntry(device:PhoneDevice){
        let collection:PhotoCollection = PhotoCollection(title: device.represent() ,
                                                         identifier: device.deviceId,
                                                         type: .library,
                                                         source: .device )
        collection.photoCount = 0
        
        if let exist = self.treeIdItems[device.deviceId] {
            if device.type == .Android {
                self.treeIdItems["device_type_Android"]?.removeChildItem(exist)
            }else if device.type == .iPhone {
                self.treeIdItems["device_type_iPhone"]?.removeChildItem(exist)
            }
        }
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: phoneIcon)
        
        if device.type == .Android {
            self.treeIdItems["device_type_Android"]?.addChildItem(item)
        }else if device.type == .iPhone {
            self.treeIdItems["device_type_iPhone"]?.addChildItem(item)
        }
        
        // avoid collection object to be purged from memory
        self.deviceToCollection["\(device.deviceId)"] = collection
        
        self.treeIdItems[device.deviceId] = item
        
    }
    
    // MARK: CLICK ACTION
    
    func selectDeviceNode(_ collection:PhotoCollection) {
        print("selected device: \(collection.identifier)")
        if collection.identifier.starts(with: "device_type_") {
            self.selectDeviceType(collection)
        }else {
            if let device = self.deviceIdToDevice[collection.identifier] {
                if let window = self.deviceCopyWindowController.window {
                    if self.deviceCopyWindowController.isWindowLoaded {
                        window.makeKeyAndOrderFront(self)
                        print("order to front")
                    }else{
                        self.deviceCopyWindowController.showWindow(self)
                        print("show window")
                    }
                    let vc = window.contentViewController as! DeviceCopyViewController
                    vc.viewInit(device: device)
                }
            }
        }
    }
    
    func selectDeviceType(_ collection:PhotoCollection) {
        if collection.identifier == "device_type_Android" {
            let devices:[String] = Android.bridge.devices()
            print("android device count: \(devices.count)")
            self.cleanCachedDeviceIds(type: .Android)
            if devices.count > 0 {
                for deviceId in devices {
                    if let device:PhoneDevice = Android.bridge.device(id: deviceId) {
                        let imageDevice = ModelStore.default.getOrCreateDevice(device: device)
                        
                        var dev:PhoneDevice = Android.bridge.memory(device: device)
                        if imageDevice.name != "" {
                            dev.name = imageDevice.name ?? ""
                        }
                        self.deviceIdToDevice[deviceId] = dev
                        self.addDeviceTreeEntry(device: dev)
                    }
                }
            }
            self.sourceList.reloadData()
            if devices.count > 0 {
                let item = self.treeIdItems["device_type_Android"]
                self.sourceList.expandItem(item)
            }else{
                PopNotification.enableDebugMode()
            }
            
        }else if collection.identifier == "device_type_iPhone" {
            
            if PreferencesController.iosDeviceMountPoint() == "" {
                Alert.invalidIOSMountPoint()
                return
            }
            
            let devices:[String] = IPHONE.bridge.devices()
            print("iphone device count: \(devices.count)")
            self.cleanCachedDeviceIds(type: .iPhone)
            if devices.count > 0 {
                if let device:PhoneDevice = IPHONE.bridge.device() {
                    let imageDevice = ModelStore.default.getOrCreateDevice(device: device)
                    
                    var dev = device
                    if imageDevice.name != "" {
                        dev.name = imageDevice.name ?? ""
                    }
                    self.deviceIdToDevice[device.deviceId] = dev
                    self.addDeviceTreeEntry(device: dev)
                }
            }
            self.sourceList.reloadData()
            if devices.count > 0 {
                let item = self.treeIdItems["device_type_iPhone"]
                self.sourceList.expandItem(item)
            }
        }
    }
    
    fileprivate func cleanCachedDeviceIds(type:MobileType){
        for deviceId in deviceIdToDevice.keys {
            if let device = deviceIdToDevice[deviceId], device.type == type {
                
                if let exist = self.treeIdItems[deviceId] {
                    if type == .Android {
                        self.treeIdItems["device_type_Android"]?.removeChildItem(exist)
                    }else if type == .iPhone {
                        self.treeIdItems["device_type_iPhone"]?.removeChildItem(exist)
                    }
                }
                
                self.treeIdItems.removeValue(forKey: deviceId)
                self.deviceToCollection.removeValue(forKey: deviceId)
                self.deviceIdToDevice.removeValue(forKey: deviceId)
            }
        }
    }
    
}
