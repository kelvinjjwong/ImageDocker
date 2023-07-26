//
//  Android.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/20.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

struct Android {
    
    let logger = LoggerFactory.get(category: "Android")
    
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
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return []
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return []
        }
        var result:[String] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = FileHandle.nullDevice
            command.launchPath = adb.path
            command.arguments = ["devices", "-l"]
            command.launch()
            command.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
//        self.logger.log(string)
        if string.range(of: "* failed to start daemon") != nil || string.range(of: "error: cannot connect to daemon") != nil {
            return []
        }
        let lines = string.components(separatedBy: "\n")
        for line in lines {
//            self.logger.log(line)
            if line.range(of: "device usb") != nil {
//                self.logger.log(line)
                let parts = line.components(separatedBy: " ")
                if parts[0] != "" {
                    result.append(parts[0])
                }
            }
        }
//        self.logger.log(result)
        return result
    }
    
    func device(id:String) -> PhoneDevice? {
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return nil
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return nil
        }
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = FileHandle.nullDevice
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "getprop"]
            command.launch()
            command.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        if string.starts(with: "error: device") || string.range(of: "not found") != nil {
            return nil
        }
        var device:PhoneDevice
        var manufacture:String = ""
        var model:String = ""
        var iccid:String = ""
        var meid:String = ""
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line.starts(with: "[ro.product.manufacturer]:") {
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
            }else if line.starts(with: "[ro.config.marketing_name]:") && model == "" {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    model = parts[1].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "_", with: " ")
                }
            }else if line.starts(with: "[ro.product.model]:") && model == "" {
                let parts = line.components(separatedBy: " ")
                if parts.count == 2 {
                    model = parts[1].replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                }
            }
                
        }
        if model != "" && manufacture != "" {
            device = PhoneDevice(type: .Android, deviceId: id, manufacture: manufacture, model: model)
            device.iccid = iccid
            device.meid = meid
            self.logger.log("Android connected: \(manufacture) \(model)")
            return device
        }else{
            return nil
        }
    }
    
    func memory(device:PhoneDevice) -> PhoneDevice {
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return PhoneDevice(type: .Unknown, deviceId: "n/a", manufacture: "n/a", model: "n/a")
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return PhoneDevice(type: .Unknown, deviceId: "n/a", manufacture: "n/a", model: "n/a")
        }
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = FileHandle.nullDevice
            command.launchPath = adb.path
            command.arguments = ["-s", device.deviceId, "shell", "df -h /storage/emulated"]
            command.launch()
            command.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        if string.starts(with: "error: device") || string.range(of: "not found") != nil {
            return device
        }
        var dev = device
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line.starts(with: "/") {
                let parts = line.components(separatedBy: " ")
                if parts.count > 2 {
                    var i=0
                    for part in parts {
                        if part != "" {
                            i += 1
                            if i == 2 {
                                dev.totalSize = part
                            }else if i == 4 {
                                dev.availSize = part
                            }else if i == 5 {
                                dev.usedPercent = part
                            }
                        }
                    }
                }
            }
        }
        return dev
    }
    
    func existsFile(device id: String, path: String) -> Bool {
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return false
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return false
        }
        self.logger.log("checking if exists \(id) \(path)")
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "ls '\(path)'"]
            //command.launch()
            //self.logger.log(command.isRunning)
            do {
                try command.run()
            }catch{
                self.logger.log(error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        self.logger.log(string)
        if string.starts(with: "ls: \(path): No such file or directory") {
            return false
        }
        return true
    }
    
    func exists(device id: String, path: String) -> Bool {
        self.logger.log("checking if exists \(id) \(path)")
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return false
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return false
        }
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "cd '\(path)'"]
            //command.launch()
            //self.logger.log(command.isRunning)
            do {
                try command.run()
            }catch{
                self.logger.log(error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        //self.logger.log(string)
        if string.range(of: "No such file or directory") != nil {
            return false
        }
        return true
    }
    
    func files(device id: String, in path: String) -> [PhoneFile] {
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return []
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return []
        }
        self.logger.log("getting files from \(id) \(path)")
        var result:[PhoneFile] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "cd '\(path)'; ls -gotR"]
            //command.launch()
            //self.logger.log(command.isRunning)
            do {
                try command.run()
            }catch{
                self.logger.log(error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        //self.logger.log(string)
        if string == "error: device '\(id)' not found" {
            return []
        }
        
        let filenamesForReference = self.filenamesForReference(device: id, in: path, recursive: true)
        
        result = DeviceShell.getFilenames(from: string,
                                          refer: filenamesForReference,
                                          basePath: path,
                                            excludeFilenames: ["directory", "killing...", "successfully"],
                                            allowedExt: Naming.FileType.allowed,
                                            allowedSuffix: ["_backup_hd"], // wechat chatroom image/video thumbnails
                                            deviceOS: .android)
        self.logger.log("got \(result.count) files from \(id) \(path)")
        //self.logger.log("done files")
        return result
    }
    
    func md5(device id: String, fileWithPath:String) -> String{
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return ""
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return ""
        }
        let pipe = Pipe()
        autoreleasepool { () -> Void in
        let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "md5sum '\(fileWithPath)'"]
            command.launch()
            command.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        self.logger.log(string)
        if string != "" {
            let parts = string.components(separatedBy: " ")
            if parts.count > 1 {
                return parts[0]
            }
        }
        return ""
    }
    
    func md5(device id: String, path:String, filename:String) -> String{
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return ""
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return ""
        }
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "cd '\(path)'; md5sum '\(filename)'"]
            command.launch()
            command.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        self.logger.log(string)
        if string != "" {
            let parts = string.components(separatedBy: " ")
            if parts.count > 1 {
                return parts[0]
            }
        }
        return ""
    }
    
    func pull(device id: String, in folderPath:String, to targetPath:String) -> String{
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return ""
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return ""
        }
        let pipe = Pipe()
        autoreleasepool { () -> Void in
        let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "pull", folderPath, targetPath]
            do {
                try command.run()
            }catch{
                self.logger.log(error)
            }
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        let lines = string.components(separatedBy: "\n")
        return lines.count > 1 ? lines[lines.count - 2] : ""
    }
    
    func pull(device id: String, from filePath:String, to targetPath:String) -> (Bool, Error?){
        self.logger.log("pulling from \(filePath) to \(targetPath)")
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return (false, nil)
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return (false, nil)
        }
        let pipe = Pipe()
        var err:Error?
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "pull", filePath, targetPath]
            do {
                try command.run()
            }catch{
                self.logger.log(error)
                err = error
            }
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        self.logger.log(string)
        pipe.fileHandleForReading.closeFile()
        let lines = string.components(separatedBy: "\n")
        let result = lines.count > 1 ? lines[lines.count - 2] : ""
        let rtn = result.range(of: "\(filePath): 1 file pulled.") != nil
        return (rtn, err)
    }
    
    func push(device id: String, from filePath:String, to remoteFolder:String) -> (String, Error?){
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return ("", nil)
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return ("", nil)
        }
        let pipe = Pipe()
        var err:Error?
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "push", filePath, remoteFolder]
            do {
                try command.run()
            }catch{
                self.logger.log(error)
                err = error
            }
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        self.logger.log(string)
        let lines = string.components(separatedBy: "\n")
        let rtn = lines.count > 1 ? lines[lines.count - 2] : ""
        return (rtn, err)
    }
    
    
    
    func mkdir(device id: String, path:String){
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return
        }
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = FileHandle.nullDevice
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "mkdir -p '\(path)'"]
            do {
                try command.run()
            }catch{
                self.logger.log(error)
            }
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let _ = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
    }
    
    func folders(device id: String, in path: String) -> [String] {
        self.logger.log("getting folders from \(path)")
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return []
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return []
        }
        var result:[String] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "cd '\(path)'; find . -type d -maxdepth 1"]
            do {
                try command.run()
            }catch{
                self.logger.log(error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        result = DeviceShell.getFolderNames(from: string)
        self.logger.log("got \(result.count) folders from \(path)")
        return result
    }
    
    fileprivate func filenamesForReference(device id: String, in path: String, recursive:Bool=false) -> [String:[String]] {
        self.logger.log("getting folders from \(path)")
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return [:]
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return [:]
        }
        var result:[String:[String]] = [:]
        let param = recursive ? " -tR" : ""
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "cd '\(path)'; ls\(param)"]
            do {
                try command.run()
            }catch{
                self.logger.log(error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        
        let lines = string.components(separatedBy: "\n")
        var subFolder = ""
        for line in lines {
            if line == "" {
                continue
            }
            if line.hasPrefix(".") && line.hasSuffix(":") {
                if line == ".:" {
                    subFolder = ""
                }else{
                    let indexStartOfText = line.index(line.startIndex, offsetBy: 2)
                    let indexEndOfText = line.index(line.endIndex, offsetBy: -1)
                    subFolder = String(line[indexStartOfText..<indexEndOfText])
                }
                continue
            }
            let folder = subFolder == "" ? "." : subFolder
            var filenames = result[folder]
            if filenames == nil {
                filenames = [line]
                result[folder] = filenames
            }else{
                filenames!.append(line)
                result[folder] = filenames
            }
        }
        return result
    }
    
    func filenames(device id: String, in path: String) -> [String] {
        self.logger.log("getting folders from \(path)")
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return []
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return []
        }
        var result:[String] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "cd '\(path)'; ls -go"]
            do {
                try command.run()
            }catch{
                self.logger.log(error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        
        let filenamesForReference = self.filenamesForReference(device: id, in: path)
        
        result = DeviceShell.getFilenames(from: string,
                                          refer: filenamesForReference,
                                          excludeFilenames: ["directory", ".", ".."],
                                          allowedExt: Naming.FileType.allowed,
                                          allowedSuffix: ["_backup_hd"], // wechat chatroom image/video thumbnails
                                          deviceOS: .android)
        self.logger.log("got \(result.count) files from \(path)")
        return result
    }
    
    func deleteFile(device id: String, path:String) -> Bool{
        if adb.path == "" {
            self.logger.log(.error, "adb path is empty !!!")
            return false
        }
        if !adb.path.isFileExists() {
            self.logger.log(.error, "adb has not installed !!!")
            return false
        }
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = FileHandle.nullDevice
            command.launchPath = adb.path
            command.arguments = ["-s", id, "shell", "rm '\(path)'"]
            do {
                try command.run()
            }catch{
                self.logger.log(error)
            }
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        return (string == "")
    }
}
