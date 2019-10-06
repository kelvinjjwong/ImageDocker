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
    
    func addDeviceTreeEntry(device:PhoneDevice, connected:Bool = false){
        let collection:PhotoCollection = PhotoCollection(title: device.represent() ,
                                                         identifier: device.deviceId,
                                                         type: .library,
                                                         source: .device )
        collection.photoCount = 0
        collection.deviceConnected = connected
        
        if let exist = self.treeIdItems[device.deviceId] {
            if device.type == .Android {
                self.treeIdItems["device_type_Android"]?.removeChildItem(exist)
            }else if device.type == .iPhone {
                self.treeIdItems["device_type_iPhone"]?.removeChildItem(exist)
            }
        }
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: connected ? phoneConnectedIcon : phoneIcon)
        
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
                let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "DeviceCopyView"), bundle: nil)
                let viewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "DeviceCopyViewController")) as! DeviceCopyViewController
                let window = NSWindow(contentViewController: viewController)
                
                let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
                let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
                let windowWidth = 850
                let windowHeight = 620
                let originX = (screenWidth - windowWidth) / 2
                let originY = (screenHeight - windowHeight) / 2
                
                let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
                window.title = "Export Manager"
                window.setFrame(frame, display: false)
                window.makeKeyAndOrderFront(self)
                viewController.viewInit(device: device, connected: collection.deviceConnected)
                
//                if let window = self.deviceCopyWindowController.window {
//                    if self.deviceCopyWindowController.isWindowLoaded {
//                        window.makeKeyAndOrderFront(self)
//                        print("order to front")
//                    }else{
//                        self.deviceCopyWindowController.showWindow(self)
//                    }
//                    let vc = window.contentViewController as! DeviceCopyViewController
//                    vc.viewInit(device: device, connected: collection.deviceConnected)
//                }
            }
        }
    }
    
    func selectDeviceType(_ collection:PhotoCollection) {
        self.hideTreeNodeButton(collection: collection)
        var deviceIds:[String] = []
        let devs = ModelStore.default.getDevices()
        for device in devs {
            if let id = device.deviceId {
                deviceIds.append(id)
            }
        }
        if collection.identifier == "device_type_Android" {
            // list all devices, tag the connected ones
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
                        self.addDeviceTreeEntry(device: dev, connected: true)
                        
                        if let id = imageDevice.deviceId, let i = deviceIds.index(of: id) {
                            deviceIds.remove(at: i)
                        }
                    }
                }
            }
            // devices those not connected
            if deviceIds.count > 0 {
                for device in devs {
                    if let id = device.deviceId, let _ = deviceIds.index(of: id), let t = device.type, t == "Android" {
                        var dev:PhoneDevice = PhoneDevice(type: .Android, deviceId: id, manufacture: device.manufacture ?? "", model: device.model ?? "")
                        dev.name = device.name ?? ""
                        
                        self.deviceIdToDevice[id] = dev
                        self.addDeviceTreeEntry(device: dev, connected: false)
                    }
                }
            }
            self.sourceList.reloadData()
            if devices.count > 0 {
                let item = self.treeIdItems["device_type_Android"]
                self.sourceList.expandItem(item)
            }else{
                self.showTreeNodeButton(collection: collection, image: NSImage(named: .caution))
                
                self.popNotification(message: "Enable [DEBUG MODE] in [Settings >> System >> Developer Options] if you've properly connected your phone via USB.")
                
            }
            
        }else if collection.identifier == "device_type_iPhone" {
            
            if PreferencesController.iosDeviceMountPoint() == "" {
                Alert.invalidIOSMountPoint()
                return
            }
            
            if !IPHONE.bridge.validCommands() {
                self.showTreeNodeButton(collection: collection, image: NSImage(named: .caution))
                
                self.popNotification(message: "iFuse/iDevice is not installed. Please install it by command [brew cask install osxfuse] and then [brew install ifuse] in console. To install Homebrew as a prior condition, please access [https://brew.sh] for detail.")
            }
            
            // devices those connected
            let devices:[String] = IPHONE.bridge.devices()
            print("iphone device count: \(devices.count)")
            self.cleanCachedDeviceIds(type: .iPhone)
            if devices.count > 0 {
                if let device:PhoneDevice = IPHONE.bridge.device() {
                    let imageDevice = ModelStore.default.getOrCreateDevice(device: device)
                    print("connected ios device: \(imageDevice.deviceId ?? "")")
                    var dev = device
                    if imageDevice.name != "" {
                        dev.name = imageDevice.name ?? ""
                    }
                    self.deviceIdToDevice[device.deviceId] = dev
                    self.addDeviceTreeEntry(device: dev, connected: true)
                    
                    if let id = imageDevice.deviceId, let i = deviceIds.index(of: id) {
                        deviceIds.remove(at: i)
                    }
                }else{
                    print("Unable to connect to ios device: \(devices[0])")
                    self.popNotification(message: "Unable to connect to iOS device. Please unlock the screen and then retry.")
                }
            }
            // devices those not connected
            if deviceIds.count > 0 {
                for device in devs {
                    if let id = device.deviceId, let _ = deviceIds.index(of: id), let t = device.type, t == "iPhone" {
                        var dev:PhoneDevice = PhoneDevice(type: .iPhone, deviceId: id, manufacture: device.manufacture ?? "", model: device.model ?? "")
                        dev.name = device.name ?? ""
                        
                        self.deviceIdToDevice[id] = dev
                        self.addDeviceTreeEntry(device: dev, connected: false)
                    }
                }
            }
            self.sourceList.reloadData()
            if devices.count > 0 {
                let item = self.treeIdItems["device_type_iPhone"]
                self.sourceList.expandItem(item)
            }else{
                self.showTreeNodeButton(collection: collection, image: NSImage(named: .caution))
                
                self.popNotification(message: "No iOS devices found. Please connect your iPhone/iPad via USB.")
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
