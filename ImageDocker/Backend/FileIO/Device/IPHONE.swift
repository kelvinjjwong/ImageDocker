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
    fileprivate var umount: URL
    
    // Verify access to the embedded version of ExifTool
    init() {
        ideviceid = URL(fileURLWithPath: "/usr/local/bin/idevice_id")
        ideviceinfo = URL(fileURLWithPath: "/usr/local/bin/ideviceinfo")
        ifuse = URL(fileURLWithPath: "/usr/local/bin/ifuse")
        df = URL(fileURLWithPath: "/bin/df")
        umount = URL(fileURLWithPath: "/sbin/umount")
    }
    
    func validCommands() -> Bool {
        if !FileManager.default.fileExists(atPath: ideviceid.path) {
            return false
        }
        if !FileManager.default.fileExists(atPath: ideviceinfo.path) {
            return false
        }
        if !FileManager.default.fileExists(atPath: ifuse.path) {
            return false
        }
        if !FileManager.default.fileExists(atPath: df.path) {
            return false
        }
        if !FileManager.default.fileExists(atPath: umount.path) {
            return false
        }
        return true
    }
    
    func devices() -> [String]{
        var result:[String] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = FileHandle.nullDevice
            command.launchPath = ideviceid.path
            command.arguments = ["-l"]
            command.launch()
            command.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line != "" {
                result.append(line)
            }
        }
        return result
    }
    
    func mount(path:String) -> Bool{
        print("START TO MOUNT")
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = ifuse.path
            command.arguments = [path]
            do {
                try command.run()
            }catch{
                print(error)
            }
        }
        print("RUN MOUNT")
//        command.launch()
//        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        print(string)
        if string.range(of: "No device found") != nil || string.range(of: "Input/output error") != nil {
            return false
        }else{
            return true
        }
    }
    
    func unmountFuse(){
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = FileHandle.nullDevice
            command.launchPath = umount.path
            command.arguments = ["ifuse@osxfuse0"]
            do {
                try command.run()
            }catch{
                print(error)
            }
        }
        //        command.launch()
        //        command.waitUntilExit()
        let _ = pipe.fileHandleForReading.readDataToEndOfFile()
        pipe.fileHandleForReading.closeFile()
        //let _ = String(data: data, encoding: String.Encoding.utf8)!
        
    }
    
    func unmount(path:String){
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = FileHandle.nullDevice
            command.launchPath = umount.path
            command.arguments = [path]
            do {
                try command.run()
            }catch{
                print(error)
            }
        }
//        command.launch()
//        command.waitUntilExit()
        let _ = pipe.fileHandleForReading.readDataToEndOfFile()
        pipe.fileHandleForReading.closeFile()
        //let _ = String(data: data, encoding: String.Encoding.utf8)!
        self.unmountFuse()

    }
    
    func mounted(path:String) -> Bool {
        guard devices().count > 0 else {return false}
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = FileHandle.nullDevice
            command.launchPath = df.path
            command.arguments = ["-H", path]
            do {
                try command.run()
            }catch{
                print(error)
            }
        }
//        command.launch()
//        command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        print(string)
        let lines = string.components(separatedBy: "\n")
        print("lines = \(lines.count)")
        for line in lines {
            if line.starts(with: "ifuse@osxfuse") && line.range(of: path) != nil {
                print("mounted")
                return true
            }
        }
        print("no mount record")
        return false
    }
    
    func device() -> PhoneDevice? {
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = ideviceinfo.path
            command.arguments = ["-s"]
            command.launch()
            command.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        print(string)
        if string.starts(with: "ERROR: Could not connect to lockdownd") {
            print("Please unlock the screen of iOS device")
            print("If failed again, refer to https://github.com/libimobiledevice/libimobiledevice/issues/717 , please reinstall libimobiledevice and ideviceinstaller by brew")
            return nil
        }
        if string.starts(with: "ERROR") || string.starts(with: "No device found") || string.range(of: "Input/output error") != nil {
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
            autoreleasepool { () -> Void in
            let cmd = Process()
                cmd.standardOutput = pipe
                cmd.standardError = pipe
                cmd.launchPath = "/sbin/md5"
                cmd.arguments = []
                cmd.arguments?.append(remoteUrl.path)
                cmd.launch()
                cmd.waitUntilExit()
            }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string:String = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
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
    
    func pull(mountPoint:String, sourcePath:String, from remoteFile:String, to targetPath:String) -> Bool{
        //guard mounted(path: mountPoint) else {return false}
        let remoteUrl:URL = URL(fileURLWithPath: mountPoint).appendingPathComponent(remoteFile)
        let localUrl:URL = URL(fileURLWithPath: targetPath)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: remoteUrl.path) && fileManager.fileExists(atPath: localUrl.path) {
            let targetFilename = remoteFile.replacingOccurrences(of: sourcePath, with: "", options: .literal, range: remoteFile.range(of: sourcePath))
            let targetFile = localUrl.appendingPathComponent(targetFilename)
            let targetPath = targetFile.deletingLastPathComponent()
            if !fileManager.fileExists(atPath: targetPath.path) {
                do {
                    try fileManager.createDirectory(at: targetPath, withIntermediateDirectories: true, attributes: nil)
                }catch{
                    print("Unable to create target path: \(targetPath.path)")
                    print(error)
                }
            }
            if !fileManager.fileExists(atPath: targetFile.path) {
                do{
                    print("\(Date()) Pulling from \(remoteUrl.path) to \(targetFile.path)")
                    try fileManager.copyItem(at: remoteUrl, to: targetFile)
                    return true
                }catch{
                    print(error)
                    return false
                }
            }else{
                print("TARGET FILE EXISTS: \(targetFile.path)")
                return false
            }
        }else{
            print("\(Date()) URL not exists: \(remoteUrl.path) OR \(localUrl.path)")
            return false
        }
    }
    
    func push(mountPoint:String, from filePath:String, to remoteFolder:String) -> Bool{
        //guard mounted(path: mountPoint) else {return false}
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
    
    
    func datetime(of filename: String, in path:String, mountPoint:String) -> String {
        let workpath = URL(fileURLWithPath: mountPoint).appendingPathComponent(path).path
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = workpath
            command.launchPath = "/usr/bin/stat"
            command.arguments = ["-l","-t","'%F %T'", filename]
            do {
                try command.run()
            }catch{
                print(error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        if string != "" {
            let columns = string.components(separatedBy: " ")
            if columns.count > 7 {
                let date = columns[5]
                let time = columns[6]
                let datetime = "\(date) \(time)"
                return datetime
            }
        }
        return ""
    }
    
    func files(mountPoint:String, in path: String) -> [PhoneFile] {
        let workURL = URL(fileURLWithPath: mountPoint).appendingPathComponent(path)
        if !FileManager.default.fileExists(atPath: workURL.path) {
            return []
        }
        let workpath = workURL.path
        print("getting files from \(workpath)")
        var result:[PhoneFile] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = workpath
            command.launchPath = "/bin/ls"
            command.arguments = ["-goR"]
            do {
                try command.run()
            }catch{
                print(error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        print(string)
        
        let filenamesForReference = self.filenamesForReference(mountPoint: mountPoint, in: path)
        
        result = DeviceShell.getFilenames(from: string,
                                          refer: filenamesForReference,
                                          basePath: path,
                                          excludeFilenames: ["directory", ".", ".."],
                                          allowedExt: Naming.FileType.allowed,
                                          allowedSuffix: ["_backup_hd"], // wechat chatroom image/video thumbnails
                                          deviceOS: .mac)
        print("got \(result.count) files from \(workpath)")
        return result
    }
    
    
    
    func folders(mountPoint:String, in path: String) -> [String] {
        let workpath = URL(fileURLWithPath: mountPoint).appendingPathComponent(path).path
        print("getting folders from \(workpath)")
        var result:[String] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = workpath
            command.launchPath = "/usr/bin/find"
            command.arguments = [".", "-type", "d","-maxdepth", "1"]
            do {
                try command.run()
            }catch{
                print(error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        //print(string)
        result = DeviceShell.getFolderNames(from: string)
        print("got \(result.count) folders from \(workpath)")
        return result
    }
    
    
    fileprivate func filenamesForReference(mountPoint:String, in path: String, recursive:Bool=false) -> [String:[String]] {
        let workpath = URL(fileURLWithPath: mountPoint).appendingPathComponent(path).path
        print("getting folders from \(path)")
        var result:[String:[String]] = [:]
        let param = recursive ? "-1tR" : "-1"
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = workpath
            command.launchPath = "/bin/ls"
            command.arguments = [param]
            do {
                try command.run()
            }catch{
                print(error)
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
    
    
    func filenames(mountPoint:String, in path: String) -> [String] {
        let workpath = URL(fileURLWithPath: mountPoint).appendingPathComponent(path).path
        print("getting folders from \(workpath)")
        var result:[String] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = workpath
            command.launchPath = "/bin/ls"
            command.arguments = ["-go"]
            do {
                try command.run()
            }catch{
                print(error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        
        let filenamesForReference = self.filenamesForReference(mountPoint: mountPoint, in: path)
        
        result = DeviceShell.getFilenames(from: string,
                                          refer: filenamesForReference,
                                          excludeFilenames: ["directory", ".", ".."],
                                          allowedExt: Naming.FileType.allowed,
                                          allowedSuffix: ["_backup_hd"], // wechat chatroom image/video thumbnails
                                          deviceOS: .mac)
        print("got \(result.count) files from \(workpath)")
        return result
    }
}
