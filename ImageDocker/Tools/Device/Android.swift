//
//  Android.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/20.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

struct Android {
    
    /// singleton instance of this class
    static let bridge = Android()
    
    // URL of the embedded version of ExifTool
    fileprivate var adb: URL
    
    // Verify access to the embedded version of ExifTool
    init() {
        if let exiftoolUrl = Bundle.main.url(forResource: "Mobile", withExtension: nil) {
            adb = exiftoolUrl.appendingPathComponent("adb")
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
        command.launchPath = adb.path
        command.arguments = ["devices", "-l"]
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        if string.range(of: "* failed to start daemon") != nil || string.range(of: "error: cannot connect to daemon") != nil {
            return []
        }
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line.range(of: "device usb") != nil {
                print(line)
                let parts = line.components(separatedBy: " ")
                if parts[0] != "" {
                    result.append(parts[0])
                }
            }
        }
        return result
    }
    
    func device(id:String) -> PhoneDevice? {
        let pipe = Pipe()
        
        let command = Process()
        command.standardOutput = pipe
        command.standardError = FileHandle.nullDevice
        command.launchPath = adb.path
        command.arguments = ["-s", id, "shell", "getprop"]
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        if string.starts(with: "error: device") || string.range(of: "not found") != nil {
            return nil
        }
        var device:PhoneDevice
        var name:String = ""
        var manufacture:String = ""
        var model:String = ""
        var iccid:String = ""
        var meid:String = ""
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line.starts(with: "[ro.product.model]:") {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    model = parts[1].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                }
            }else if line.starts(with: "[ro.product.manufacturer]:") {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    manufacture = parts[1].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                }
            }else if line.starts(with: "[persist.radio.sim.iccid]:") {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    iccid = parts[1].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                }
            }else if line.starts(with: "[persist.radio.via_m]:") {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    meid = parts[1].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").uppercased()
                }
            }else if line.starts(with: "[net.hostname]:") {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    name = parts[1].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "_", with: "")
                }
            }else if line.starts(with: "[ro.product.brand]:") && name == "" {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    name = parts[1].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").uppercased()
                }
            }
        }
        if model != "" && manufacture != "" {
            device = PhoneDevice(type: .Android, deviceId: id, manufacture: manufacture, model: model)
            device.iccid = iccid
            device.meid = meid
            device.name = name
            return device
        }else{
            return nil
        }
    }
    
    func files(device id: String, in path: String) -> [PhoneFile] {
        var result:[PhoneFile] = []
        let pipe = Pipe()
        
        let command = Process()
        command.standardOutput = pipe
        command.standardError = pipe
        command.launchPath = adb.path
        command.arguments = ["-s", id, "shell", "cd \(path); ls -f *.jpg *.jpeg *.mov *.mpg *.mpeg *.mp4"]
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            let parts = line.components(separatedBy: " ")
            
            let name = parts[parts.count - 1]
            if name == "directory" || name == "" {
                continue
            }
            let url:URL = URL(fileURLWithPath: path).appendingPathComponent(name)
            let filepath = url.path
            let filename = url.lastPathComponent
            let file = PhoneFile(filename: filename, path: filepath)
            result.append(file)
        }
        return result
    }
    
    func md5(device id: String, path:String, filename:String) -> String{
        let pipe = Pipe()
        
        let command = Process()
        command.standardOutput = pipe
        command.standardError = FileHandle.nullDevice
        command.launchPath = adb.path
        command.arguments = ["-s", id, "shell", "cd \(path); md5sum \(filename)"]
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        return string
    }
    
    func pull(device id: String, in folderPath:String, to targetPath:String) -> String{
        let pipe = Pipe()
        
        let command = Process()
        command.standardOutput = pipe
        command.standardError = FileHandle.nullDevice
        command.launchPath = adb.path
        command.arguments = ["-s", id, "pull", folderPath, targetPath]
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        let lines = string.components(separatedBy: "\n")
        return lines.count > 1 ? lines[lines.count - 2] : ""
    }
    
    func pull(device id: String, from filePath:String, to targetPath:String) -> Bool{
        let pipe = Pipe()
        
        let command = Process()
        command.standardOutput = pipe
        command.standardError = FileHandle.nullDevice
        command.launchPath = adb.path
        command.arguments = ["-s", id, "pull", filePath, targetPath]
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        let lines = string.components(separatedBy: "\n")
        let result = lines.count > 1 ? lines[lines.count - 2] : ""
        return result.range(of: "\(filePath): 1 file pulled.") != nil
    }
    
    func push(device id: String, from filePath:String, to remoteFolder:String) -> String{
        let pipe = Pipe()
        
        let command = Process()
        command.standardOutput = pipe
        command.standardError = FileHandle.nullDevice
        command.launchPath = adb.path
        command.arguments = ["-s", id, "push", filePath, remoteFolder]
        command.launch()
        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        let lines = string.components(separatedBy: "\n")
        return lines.count > 1 ? lines[lines.count - 2] : ""
    }
    
}
