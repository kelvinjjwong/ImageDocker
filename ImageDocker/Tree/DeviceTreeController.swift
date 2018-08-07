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
        }
    }
    
    func selectDeviceType(_ collection:PhotoCollection) {
        if collection.identifier == "device_type_Android" {
            let devices:[String] = Android.bridge.devices()
            print("android device count: \(devices.count)")
            if devices.count > 0 {
                for deviceId in devices {
                    if let device:PhoneDevice = Android.bridge.device(id: deviceId) {
                        let dev:PhoneDevice = Android.bridge.memory(device: device)
                        self.addDeviceTreeEntry(device: dev)
                    }
                }
                self.sourceList.reloadData()
                let item = self.treeIdItems["device_type_Android"]
                self.sourceList.expandItem(item)
            }
            
        }
    }
    
}
