//
//  RepositoryDetailViewController+Device.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/26.
//  Copyright © 2026 nonamecat. All rights reserved.
//

import Cocoa
import SharedDeviceLib

extension RepositoryDetailViewController {
    
    public func loadDeviceInfo(repository: ImageRepository) -> ImageDevice? {
        var isAndroid = false
        
        if repository.deviceId != "" {
            if let device = DeviceDao.default.getDevice(deviceId: repository.deviceId) {
                
                var deviceInfo:[[String:String]] = []
                
                isAndroid = ( (device.type ?? "") == Naming.Device.Android)
                
                deviceInfo.append(["id":"fixed_type", "datatype":"text", "name":"类型", "value" : device.type ?? ""])
                deviceInfo.append(["id":"fixed_manufacture", "datatype":"text", "name":"厂家", "value" : device.manufacture ?? ""])
                deviceInfo.append(["id":"fixed_marketName", "datatype":"text", "name":"名称", "value" : device.marketName ?? ""])
                deviceInfo.append(["id":"fixed_model", "datatype":"text", "name":"型号", "value" : device.model ?? ""])
                let deviceInfoMeta = (device.metaInfo ?? "{}").toJSON()
                deviceInfo.append(["id":"ImageWidth", "datatype":"int", "name":"照片宽度", "value" : "\(deviceInfoMeta["ImageWidth"].stringValue)"])
                deviceInfo.append(["id":"ImageHeight", "datatype":"int", "name":"照片高度", "value" : "\(deviceInfoMeta["ImageHeight"].stringValue)"])
                deviceInfo.append(["id":"ScreenWidth", "datatype":"int", "name":"画面宽度", "value" : "\(deviceInfoMeta["ScreenWidth"].stringValue)"])
                deviceInfo.append(["id":"ScreenHeight", "datatype":"int", "name":"画面宽度", "value" : "\(deviceInfoMeta["ScreenHeight"].stringValue)"])
                
                let connectedDevices = DeviceBridge.connectivity.withLock{ dictionary in
                    return dictionary
                }
                self.logger.log(.info, "Connected devices: \(connectedDevices)")
                
                self.phoneDevice = PhoneDevice(type: isAndroid ? .Android : .iPhone,
                                              deviceId: repository.deviceId,
                                              manufacture: device.manufacture ?? "",
                                              model: device.model ?? "")
                self.phoneDevice?.name = device.name ?? ""
                
                var connectedDeviceIds:[String] = []
                if isAndroid {
                    connectedDeviceIds = DeviceBridge.Android().devices()
                    self.logger.log(.debug, "Connected Android devices: \(connectedDeviceIds)")
                }else{
                    var connectIOS = true
                    if Setting.localEnvironment.iosDeviceMountPoint() == "" {
                        connectIOS = false
                        MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: Words.device_tree_setup_mountpoint_for_ios.word())
                    }
                    if !DeviceBridge.IPHONE().validCommands() {
                        connectIOS = false
                        MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: Words.device_tree_ifuse_not_installed.word())
                    }
                    self.logger.log(.debug, "Connected IOS devices: \(connectIOS)")
                    if connectIOS {
                        connectedDeviceIds = DeviceBridge.IPHONE().devices()
                        self.logger.log(.debug, "Connected IOS devices: \(connectedDeviceIds)")
                    }
                }
                if !connectedDeviceIds.contains(repository.deviceId) {
                    
                    DispatchQueue.main.async {
//                                MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: "Device is not connected")
                        if isAndroid {
                            MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: Words.device_tree_need_debug_mode.word())
                        }else{
                            MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: Words.device_tree_no_ios_connected.word())
                        }
                    }
                }

                let device_status = DeviceBridge.connectivity.withLock{
                    return $0[device.deviceId ?? ""]
                }
                if let device_status = device_status {
                    deviceInfo.append(["id":"Connected", "datatype":"text", "value": (device_status == true ? "已连接" : "未连接")])
                }else{
                    deviceInfo.append(["id":"Connected", "datatype":"text", "value": ("未连接")])
                }
                
                DispatchQueue.main.async {
                    self.deviceInfoTableController.load(deviceInfo)
                }
                
                return device
            }else{
                DispatchQueue.main.async {
                    MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: "Cannot find device id for this repository")
                }
            }
        }else{
            // no device was connected to repository
            self.logger.log(.info, "Found no device was connected to repository id:\(repository.id)")
            let connectedDevices = DeviceBridge.connectivity.withLock{ dictionary in
                return dictionary
            }
            self.logger.log(.info, "Connected devices: \(connectedDevices)")
            
            var connectedDeviceIds:[String] = []
            if isAndroid {
                connectedDeviceIds = DeviceBridge.Android().devices()
                self.logger.log(.debug, "Connected Android devices: \(connectedDeviceIds)")
            }else{
                var connectIOS = true
                if Setting.localEnvironment.iosDeviceMountPoint() == "" {
                    connectIOS = false
                    MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: Words.device_tree_setup_mountpoint_for_ios.word())
                }
                if !DeviceBridge.IPHONE().validCommands() {
                    connectIOS = false
                    MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: Words.device_tree_ifuse_not_installed.word())
                }
                self.logger.log(.debug, "Connected IOS devices: \(connectIOS)")
                if connectIOS {
                    connectedDeviceIds = DeviceBridge.IPHONE().devices()
                    self.logger.log(.debug, "Connected IOS devices: \(connectedDeviceIds)")
                    
                    if connectedDeviceIds.count > 0 {
                        for connectedDeviceid in connectedDeviceIds {
                            if let connectedIphoneDevice = DeviceBridge.IPHONE().device() {
                                self.logger.log(.debug, "Connected IOS device: \(connectedIphoneDevice)")
                                
                                if let iphoneDevice = DeviceDao.default.getDevice(deviceId: connectedIphoneDevice.deviceId) {
                                    iphoneDevice.type = "iPhone"
                                    iphoneDevice.manufacture = connectedIphoneDevice.manufacture
                                    iphoneDevice.model = connectedIphoneDevice.model
                                    iphoneDevice.name = connectedIphoneDevice.name
                                    let _state = DeviceDao.default.saveDevice(device: iphoneDevice)
                                    if _state == .ERROR {
                                        let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageDeviceDaoPostgresCK", name: "updateImageDevice", message: "ERROR")
                                    }
                                    
                                }else{
                                    let iPhoneDevice = ImageDevice.new(deviceId: connectedIphoneDevice.deviceId,
                                                                       type: "iPhone",
                                                                       manufacture: connectedIphoneDevice.manufacture,
                                                                       model: connectedIphoneDevice.model)
                                    iPhoneDevice.name = connectedIphoneDevice.name
                                    let _state = DeviceDao.default.saveDevice(device: iPhoneDevice)
                                    if _state == .ERROR {
                                        let _ = NotificationMessageManager.default.createNotificationMessage(type: "ImageDeviceDaoPostgresCK", name: "createImageDevice", message: "ERROR")
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        return nil
    }
    
}
