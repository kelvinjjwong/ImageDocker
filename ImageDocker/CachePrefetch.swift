//
//  CachePrefetch.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2025/3/20.
//  Copyright © 2025 nonamecat. All rights reserved.
//
import Foundation
import LoggerFactory

public final class CachePrefetch {
    let logger = LoggerFactory.get(category: "ImageRecordDao")
    
    static var `default`:CachePrefetch {
        return CachePrefetch()
    }
    
    public func refresh() {
        let _ = self.getMetaInfoOfDevices(reload: true)
    }
    
    fileprivate var _devicesMetaInfo:[JSON] = []
    
    public func getMetaInfoOfDevices(reload:Bool = false) -> [JSON] {
        if reload || self._devicesMetaInfo == [] {
            var devicesMetaInfo:[JSON] = []
            let devices = DeviceDao.default.getDevices()
            for device in devices {
                if let metaInfo = device.metaInfo {
                    self.logger.log("[screen meta] \(metaInfo)")
                    let json = metaInfo.toJSON()
                    devicesMetaInfo.append(json)
                }
            }
            self._devicesMetaInfo = devicesMetaInfo
        }
        return self._devicesMetaInfo
    }
    
}
