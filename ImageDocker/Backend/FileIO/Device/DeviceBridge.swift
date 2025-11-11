//
//  DeviceBridge.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/8/26.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Foundation
import Synchronization
import SharedDeviceLib
import AndroidDeviceReader
import IPhoneDeviceReader

public enum DeviceType {
    case android
    case iphone
}

public class DeviceBridge {
    
    fileprivate static let _android = AndroidDeviceReader.Android(path: "/Users/kelvinwong/Develop/mac/adb") // TODO: assign to environment
    fileprivate static let _iphone = IPhoneDeviceReader.IPHONE(path: "/opt/homebrew/bin")
    
    public static let connectivity = Mutex([String:Bool]())
    
    public static func Android() -> Android {
        return _android
    }
    
    public static func IPHONE() -> IPHONE {
        return _iphone
    }
    
    public static func isConnected(deviceId:String) -> Bool {
        let state = connectivity.withLock{
            return $0[deviceId]
        }
        if let state = state {
            return state
        }else{
            return false
        }
    }
}
