//
//  IPHONE.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/21.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

struct IPHONE {
    
    /// singleton instance of this class
    static let bridge = IPHONE()
    
    // URL of the embedded version of ExifTool
    fileprivate var ideviceid: URL
    fileprivate var ideviceinfo: URL
    fileprivate var ifuse: URL
    fileprivate var df: URL
    
    // Verify access to the embedded version of ExifTool
    init() {
        if let mobileUrl = Bundle.main.url(forResource: "Mobile", withExtension: nil) {
            ideviceid = mobileUrl.appendingPathComponent("ideviceid")
            ideviceinfo = mobileUrl.appendingPathComponent("ideviceinfo")
            ifuse = mobileUrl.appendingPathComponent("ifuse")
            df = mobileUrl.appendingPathComponent("df")
        } else {
            fatalError("The Application Bundle is corrupt.")
        }
    }
    
    func devices() -> [String]{
        var result:[String] = []
        let pipe = Pipe()
        
        let command = Process()
        command.standardOutput = pipe
        command.standardError = FileHandle.nullDevice
        command.launchPath = ideviceid.path
        command.arguments = ["-l"]
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line != "" {
                result.append(line)
            }
        }
        return result
    }
    
    func mount(path:String) -> Bool{
        let pipe = Pipe()
        
        let command = Process()
        command.standardOutput = pipe
        command.standardError = FileHandle.nullDevice
        command.launchPath = ifuse.path
        command.arguments = [path]
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        if string.range(of: "No device found") != nil || string.range(of: "Input/output error") != nil {
            return false
        }else{
            return true
        }
    }
    
    func mounted(path:String) -> Bool {
        guard devices().count > 0 else {return false}
        let pipe = Pipe()
        
        let command = Process()
        command.standardOutput = pipe
        command.standardError = FileHandle.nullDevice
        command.launchPath = df.path
        command.arguments = ["-H", path]
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line.range(of: path) != nil && line.starts(with: "ifuse@osxfuse") {
                return true
            }
        }
        return false
    }
    
    func device() -> PhoneDevice? {
        let pipe = Pipe()
        
        let command = Process()
        command.standardOutput = pipe
        command.standardError = FileHandle.nullDevice
        command.launchPath = ideviceinfo.path
        command.arguments = []
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        if string.starts(with: "No device found") || string.range(of: "Input/output error") != nil {
            return nil
        }
        var device:PhoneDevice
        var name:String = ""
        var deviceId:String = ""
        var model:String = ""
        var iccid:String = ""
        var meid:String = ""
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line.starts(with: "DeviceName:") {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    name = parts[1]
                }
            }else if line.starts(with: "ProductType:") {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    model = parts[1]
                }
            }else if line.starts(with: "IntegratedCircuitCardIdentity:") {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    iccid = parts[1]
                }
            }else if line.starts(with: "InternationalMobileEquipmentIdentity:") {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    meid = parts[1]
                }
            }else if line.starts(with: "UniqueDeviceID:") {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    deviceId = parts[1]
                }
            }
        }
        if model != "" && deviceId != "" {
            device = PhoneDevice(type: .iPhone, deviceId: deviceId, manufacture: "Apple", model: model)
            device.iccid = iccid
            device.meid = meid
            device.name = name
            return device
        }else{
            return nil
        }
    }
    
    func pull(mountPoint:String, in remoteFolder:String, to targetPath:String) -> Bool{
        guard mounted(path: mountPoint) else {return false}
        let remoteUrl:URL = URL(fileURLWithPath: mountPoint).appendingPathComponent(remoteFolder)
        let localUrl:URL = URL(fileURLWithPath: targetPath)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: remoteUrl.path) && fileManager.fileExists(atPath: localUrl.path) {
            do{
                print("\(Date()) Pulling from \(remoteUrl.path) to \(localUrl.path)")
                let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants ]
                let resourceKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.typeIdentifierKey, URLResourceKey.isDirectoryKey]
                let enumerator = fileManager.enumerator(at: remoteUrl,
                                                        includingPropertiesForKeys: resourceKeys,
                                                        options: options, errorHandler: { (url, error) -> Bool in
                                                            print("\(Date()) Remote directory enumerator error at \(url): ", error)
                                                            return false
                })!
                
                for case let remoteFileUrl as URL in enumerator {
                    print("\(Date()) Pulling from \(remoteFileUrl.path) to \(localUrl.path)")
                    try fileManager.copyItem(at: remoteFileUrl, to: localUrl)
                }
                return true
            }catch{
                print(error)
                return false
            }
        }else{
            print("\(Date()) URL not exists: \(remoteUrl.path) OR \(localUrl.path)")
            return false
        }
    }
    
    
    
    func md5(mountPoint:String, at remoteFile:String) -> String {
        guard mounted(path: mountPoint) else {return ""}
        let remoteUrl:URL = URL(fileURLWithPath: mountPoint).appendingPathComponent(remoteFile)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: remoteUrl.path) {
            let pipe = Pipe()
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = "/sbin/md5"
            cmd.arguments = []
            cmd.arguments?.append(remoteUrl.path)
            cmd.launch()
            cmd.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string:String = String(data: data, encoding: String.Encoding.utf8)!
            if string != "" && string.starts(with: "MD5 (") {
                let comp:[String] = string.components(separatedBy: " = ")
                if comp.count == 2 {
                    return comp[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                }
            }
            return ""
        }else {
            return ""
        }
    }
    
    func pull(mountPoint:String, from remoteFile:String, to targetPath:String) -> Bool{
        guard mounted(path: mountPoint) else {return false}
        let remoteUrl:URL = URL(fileURLWithPath: mountPoint).appendingPathComponent(remoteFile)
        let localUrl:URL = URL(fileURLWithPath: targetPath)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: remoteUrl.path) && fileManager.fileExists(atPath: localUrl.path) {
            do{
                print("\(Date()) Pulling from \(remoteUrl.path) to \(localUrl.path)")
                try fileManager.copyItem(at: remoteUrl, to: localUrl)
                return true
            }catch{
                print(error)
                return false
            }
        }else{
            print("\(Date()) URL not exists: \(remoteUrl.path) OR \(localUrl.path)")
            return false
        }
    }
    
    func push(mountPoint:String, from filePath:String, to remoteFolder:String) -> Bool{
        guard mounted(path: mountPoint) else {return false}
        let remoteUrl:URL = URL(fileURLWithPath: mountPoint).appendingPathComponent(remoteFolder)
        let localUrl:URL = URL(fileURLWithPath: filePath)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: remoteUrl.path) && fileManager.fileExists(atPath: localUrl.path) {
            do{
                print("\(Date()) Pushing from \(localUrl.path) to \(remoteUrl.path)")
                try fileManager.copyItem(at: localUrl, to: remoteUrl)
                return true
            }catch{
                print(error)
                return false
            }
        }else{
            print("\(Date()) URL not exists: \(remoteUrl.path) OR \(localUrl.path)")
            return false
        }
    }
}
