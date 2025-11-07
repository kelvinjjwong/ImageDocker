//
//  CachePrefetch.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2025/3/20.
//  Copyright © 2025 nonamecat. All rights reserved.
//
import Foundation
import Synchronization
import LoggerFactory

public final class CachePrefetch {
    let logger = LoggerFactory.get(category: "ImageRecordDao")
    
    static var `default`:CachePrefetch {
        return CachePrefetch()
    }
    
    public func refresh() {
        let _ = self.getMetaInfoOfDevices(reload: true)
    }
    
    fileprivate let _devicesMetaInfo = Mutex([JSON]())
    
    public func getMetaInfoOfDevices(reload:Bool = false) -> [JSON] {
        let array = self._devicesMetaInfo.withLock{
            return $0
        }
        if reload || array == [] {
            var devicesMetaInfo:[JSON] = []
            let devices = DeviceDao.default.getDevices()
            for device in devices {
                if let metaInfo = device.metaInfo {
                    self.logger.log("[screen meta] \(metaInfo)")
                    let json = metaInfo.toJSON()
                    devicesMetaInfo.append(json)
                }
            }
            self._devicesMetaInfo.withLock{
                $0 = devicesMetaInfo
            }
        }
        return self._devicesMetaInfo.withLock{
            return $0
        }
    }
    
}
