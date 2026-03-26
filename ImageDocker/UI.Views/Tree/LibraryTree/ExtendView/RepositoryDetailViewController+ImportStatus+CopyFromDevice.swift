//
//  RepositoryDetailViewController+ImportStatus+CopyFromDevice.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/26.
//  Copyright © 2026 nonamecat. All rights reserved.
//

import Cocoa
import SharedDeviceLib

extension RepositoryDetailViewController {
    
    public func copyFromDevice() {
        if let repository = RepositoryDao.default.getRepository(id: self._repositoryId),
            let device = DeviceDao.default.getDevice(deviceId: repository.deviceId),
            let deviceType = device.type {
            
            let phoneDevice = self.phoneDevice
                            ?? PhoneDevice(type: .Unknown, deviceId: "", manufacture: "", model: "") // not bind phone yet or local disk folder
            
            self.onShowDeviceDialog(phoneDevice)
            
        }
    }
}
