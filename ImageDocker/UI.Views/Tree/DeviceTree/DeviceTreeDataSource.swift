//
//  DeviceTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

class DeviceTreeDataSource : TreeDataSource {
    
    let logger = LoggerFactory.get(category: "TREE", subCategory: "DEVICE")
    
    private var deviceIdToDevice : [String : PhoneDevice] = [String : PhoneDevice] ()
    
    var isLoading = false
    
    var registered_android_id_names:[String:String] = [:]
    var registered_iphone_id_names:[String:String] = [:]
    
    var deviceConnectivityStatus:[String:Bool] = [:]
    
    var volumesConnectivityTimer:Timer?
    var androidConnectivityTimer:Timer?
    var iphoneConnectivityTimer:Timer?
    
    func loadRegisteredDevices() {
        guard !self.isLoading else {return}
        
        self.isLoading = true
        
        if self.registered_android_id_names.isEmpty {
            
            let registeredDevices = DeviceDao.default.getDevices(type: "Android")
            for registeredDevice in registeredDevices {
                if let id = registeredDevice.deviceId {
                    
                    do {
                        self.logger.log("[DEVICE][Android] assigning id:\(id) to registered device: \(registeredDevice.name ?? "")")
                        self.registered_android_id_names[id] = ""
                        self.registered_android_id_names[id] = PhoneDevice.represent(
                            deviceId: id,
                            name: registeredDevice.name ?? "",
                            manufacture: registeredDevice.manufacture ?? "",
                            model: registeredDevice.marketName ?? registeredDevice.model ?? "",
                            type: .Android
                        )
                    }catch{
                        self.logger.log(.error, error)
                    }
                }
            }
        }
        if self.registered_iphone_id_names.isEmpty {
            
            let registeredDevices = DeviceDao.default.getDevices(type: "iPhone")
            for registeredDevice in registeredDevices {
                if let id = registeredDevice.deviceId {
                    
                    do {
                        self.logger.log("[DEVICE][iPhone] assigning id:\(id) to registered device: \(registeredDevice.name ?? "")")
                        self.registered_iphone_id_names[id] = ""
                        self.registered_iphone_id_names[id] = PhoneDevice.represent(
                            deviceId: id,
                            name: registeredDevice.name ?? "",
                            manufacture: registeredDevice.manufacture ?? "",
                            model: registeredDevice.marketName ?? registeredDevice.model ?? "",
                            type: .iPhone
                        )
                    }catch{
                        self.logger.log(.error, error)
                    }
                }
            }
        }
        self.isLoading = false
    }
    
    func startConnectivityTest() {
//        self.logger.log("start connectivity test timer")
        
        self.volumesConnectivityTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block:{_ in
            DispatchQueue.global().async {
                let registeredVolumes = PreferencesController.getSavedRepositoryVolumes()
                let mountedVolumes = LocalDirectory.bridge.mountpoints()
                
                var volumes_change_to_be_connected:[String] = []
                var volumes_change_to_be_disconnected:[String] = []
                
                for registeredVolume in registeredVolumes {
                    let connectivityStatus = mountedVolumes.contains(registeredVolume)
                    
                    // initial
                    if self.deviceConnectivityStatus[registeredVolume] == nil {

                        self.deviceConnectivityStatus[registeredVolume] = connectivityStatus

                    }else{
                        // status change listener
                        
                        if let oldStatus = self.deviceConnectivityStatus[registeredVolume], oldStatus != connectivityStatus {
                            
                            self.deviceConnectivityStatus[registeredVolume] = connectivityStatus
                            
                            if connectivityStatus {
                                volumes_change_to_be_connected.append(registeredVolume)
                                
                            }else{
                                volumes_change_to_be_disconnected.append(registeredVolume)
                            }
                        }
                    }
                }
                if !volumes_change_to_be_connected.isEmpty {
                    MessageEventCenter.default.showMessage(
                        type: Words.notification_volume_connected.word(),
                        name: "Disk",
                        message: Words.notification_which_volume_connected.fill(arguments: "\(volumes_change_to_be_connected)")
                    )
                }
                if !volumes_change_to_be_disconnected.isEmpty {
                    MessageEventCenter.default.showMessage(
                        type: Words.notification_volume_missing.word(),
                        name: "Disk",
                        message: Words.notification_which_volume_missing.fill(arguments: "\(volumes_change_to_be_disconnected)")
                    )
                }
            }
        })
        
        self.androidConnectivityTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block:{_ in
                DispatchQueue.global().async {
                    self.loadRegisteredDevices()

                    let connectedDeviceIds:[String] = Android.bridge.devices()
//                    self.logger.log("connected android phones: \(connectedDeviceIds)")
                    for deviceId in self.registered_android_id_names.keys {

                        let connectivityStatus = connectedDeviceIds.contains(deviceId)

                        // initial
                        if self.deviceConnectivityStatus[deviceId] == nil {

                            self.deviceConnectivityStatus[deviceId] = connectivityStatus
                            
                            if connectivityStatus {
                                if let represent = self.registered_android_id_names[deviceId] {
                                    MessageEventCenter.default.showMessage(
                                        type: Words.notification_volume_connected.word(),
                                        name: "Android",
                                        message: Words.notification_which_volume_connected.fill(arguments: represent)
                                    )
                                }
                            }

                        }else{
                            // status change listener

                            if let oldStatus = self.deviceConnectivityStatus[deviceId], oldStatus != connectivityStatus {
                                
                                self.deviceConnectivityStatus[deviceId] = connectivityStatus

                                if let represent = self.registered_android_id_names[deviceId] {
                                    if connectivityStatus {
                                        MessageEventCenter.default.showMessage(
                                            type: Words.notification_volume_connected.word(),
                                            name: "Android",
                                            message: Words.notification_which_volume_connected.fill(arguments: represent)
                                        )
                                    }else{
                                        MessageEventCenter.default.showMessage(
                                            type: Words.notification_volume_missing.word(),
                                            name: "Android",
                                            message: Words.notification_which_volume_missing.fill(arguments: represent)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                
            })
        
        self.iphoneConnectivityTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block:{_ in
                DispatchQueue.global().async {
                    self.loadRegisteredDevices()
                    
                    let connectedDeviceIds:[String] = IPHONE.bridge.devices()
//                    self.logger.log("connected android phones: \(connectedDeviceIds)")
                    for deviceId in self.registered_iphone_id_names.keys {

                        let connectivityStatus = connectedDeviceIds.contains(deviceId)
//                        print(connectivityStatus)

                        // initial
                        if self.deviceConnectivityStatus[deviceId] == nil {

                            self.deviceConnectivityStatus[deviceId] = connectivityStatus
                            
                            if connectivityStatus {
                                if let represent = self.registered_iphone_id_names[deviceId] {
                                    MessageEventCenter.default.showMessage(
                                        type: Words.notification_volume_connected.word(),
                                        name: "iPhone",
                                        message: Words.notification_which_volume_connected.fill(arguments: represent)
                                    )
                                }
                            }

                        }else{
                            // status change listener

                            if let oldStatus = self.deviceConnectivityStatus[deviceId], oldStatus != connectivityStatus {
                                
                                self.deviceConnectivityStatus[deviceId] = connectivityStatus

                                if let represent = self.registered_iphone_id_names[deviceId] {
                                    if connectivityStatus {
                                        MessageEventCenter.default.showMessage(
                                            type: Words.notification_volume_connected.word(),
                                            name: "iPhone",
                                            message: Words.notification_which_volume_connected.fill(arguments: represent)
                                        )
                                    }else{
                                        MessageEventCenter.default.showMessage(
                                            type: Words.notification_volume_missing.word(),
                                            name: "iPhone",
                                            message: Words.notification_which_volume_missing.fill(arguments: represent)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                
            })
    }
    
    func loadChildren(_ collection: TreeCollection?, condition:SearchCondition?) -> ([TreeCollection], String?, String?) {
        
        if let condition = condition, !condition.isEmpty() {
            // FIXME: search ImageDeviceFile first ??
        }
        
        if collection == nil {
            let android = TreeCollection("Android", id: "DEV_ANDROID", object: PhoneDevice(type: .Android, deviceId: "", manufacture: "", model: ""))
            android.expandable = true
            let registeredAndroidCount = self.countDevicesFromDatabase(type: "Android")
            android.subImagesCount = registeredAndroidCount
            android.childrenCount = registeredAndroidCount
            let iphone = TreeCollection("iPhone", id: "DEV_IPHONE", object: PhoneDevice(type: .iPhone, deviceId: "", manufacture: "", model: ""))
            iphone.expandable = true
            let registeredIphoneCount = self.countDevicesFromDatabase(type: "iPhone")
            iphone.subImagesCount = registeredIphoneCount
            iphone.childrenCount = registeredIphoneCount
            
            return ([android, iphone], nil, nil)
        }else{
            if let col = collection {
                if col.name == "Android" {
                    let androids = self.loadAndroidDevices()
                    var connectedAndroid = 0
                    for devi in androids.0 {
                        if let state = devi.relatedObjectState {
                            if state == 1 {
                                connectedAndroid += 1
                            }
                        }
                    }
                    col.connectedCount = connectedAndroid
                    return androids
                }else if col.name == "iPhone" {
                    let iphones = self.loadIPhoneDevices()
                    var connectedIphones = 0
                    for devi in iphones.0 {
                        if let state = devi.relatedObjectState {
                            if state == 1 {
                                connectedIphones += 1
                            }
                        }
                    }
                    col.connectedCount = connectedIphones
                    return iphones
                }
            }
        }
        return ([], nil, nil)
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
        self.logger.log("convert to tree node: \(device) , connected=\(connected)")
        return TreeCollection(device.represent(), id: device.deviceId, object: device, state: connected ? 1 : 0)
    }
    
    private func countDevicesFromDatabase(type: String) -> Int {
        let devs = DeviceDao.default.getDevices(type: type)
        return devs.count
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
    
    private func loadAndroidDevices() -> ([TreeCollection], String?, String?) {
        var nodes:[TreeCollection] = []
        
        var (devs, deviceIds) = self.loadDevicesFromDatabase(type: "Android")
        
        // devices those connected
        let devices:[String] = Android.bridge.devices()
        self.logger.log("connected android device count: \(devices.count)")
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
        return (nodes, message, "Android")
    }
    
    private func loadIPhoneDevices() -> ([TreeCollection], String?, String?) {
        if Setting.localEnvironment.iosDeviceMountPoint() == "" {
            return ([], Words.device_tree_setup_mountpoint_for_ios.word(), "iPhone")
        }
        
        if !IPHONE.bridge.validCommands() {
//                self.showTreeNodeButton(collection: collection, image: NSImage(named: .caution))
            
            return ([], Words.device_tree_ifuse_not_installed.word(), "iPhone")
        }
        
        var nodes:[TreeCollection] = []
        
        var (devs, deviceIds) = self.loadDevicesFromDatabase(type: "iPhone")
        
        // devices those connected
        let devices:[String] = IPHONE.bridge.devices()
        logger.log("connected iphone device count: \(devices.count)")
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
                return ([], Words.device_tree_unable_to_connect_ios.word(), "iPhone")
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
        return (nodes, message, "iPhone")
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
