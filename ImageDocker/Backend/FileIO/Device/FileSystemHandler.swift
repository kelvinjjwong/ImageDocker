//
//  FileSystemHandler.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/9/11.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory


protocol FileSystemHandler {
    func createDirectory(atPath path:String) -> Bool
    func fileExists(atPath path:String) -> Bool
    func fileExists(atPath path:String, md5:String) -> FileExistState
    func deleteFile(atPath path:String) -> Bool
    func md5(pathOfFile path:String) -> String
}

public enum FileExistState:Int{
    case notExistAtPath
    case existAtPathWithDifferentMD5
    case existAtPathWithSameMD5
}

class ComputerFileManager : FileSystemHandler {
    
    let logger = LoggerFactory.get(category: "ComputerFileManager")
    
    static let `default` = ComputerFileManager()
    func createDirectory(atPath path:String) -> Bool {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }catch{
            self.logger.log("Cannot create directory: \(path)")
            self.logger.log(.error, error)
            return false
        }
        return true
    }
    
    func fileExists(atPath path:String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    func fileExists(atPath path:String, md5:String) -> FileExistState {
        if FileManager.default.fileExists(atPath: path) {
            let md5AtPath = self.md5(pathOfFile: path)
            if md5 == md5AtPath {
                return .existAtPathWithSameMD5
            }else{
                return .existAtPathWithDifferentMD5
            }
        }else{
            return .notExistAtPath
        }
    }
    
    func deleteFile(atPath path:String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: path)
        }catch {
            self.logger.log("Cannot delete original copy: \(path)")
            self.logger.log(.error, error)
            return false
        }
        return true
    }
    
    
    func md5(pathOfFile path:String) -> String {
        let pipe = Pipe()
        var string:String = ""
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = "/sbin/md5"
            cmd.arguments = []
            cmd.arguments?.append(path)
            cmd.launch()
            cmd.waitUntilExit()
            cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
        }
        self.logger.log(string)
        if string != "" && string.starts(with: "MD5 (") {
            let comp:[String] = string.components(separatedBy: " = ")
            if comp.count == 2 {
                return comp[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
        }
        return ""
    }
}

class AndroidFileManager : FileSystemHandler {
    
    let logger = LoggerFactory.get(category: "AndroidFileManager")
    
    private var deviceId:String
    
    init(deviceId:String){
        self.deviceId = deviceId
    }
    
    func createDirectory(atPath path: String) -> Bool {
        Android.bridge.mkdir(device: self.deviceId, path: path)
        return Android.bridge.exists(device: self.deviceId, path: path)
    }
    
    func fileExists(atPath path: String) -> Bool {
        return Android.bridge.existsFile(device: self.deviceId, path: path)
    }
    
    func fileExists(atPath path: String, md5: String) -> FileExistState {
        if Android.bridge.existsFile(device: self.deviceId, path: path) {
            self.logger.log("exists")
            let md5AtPath = self.md5(pathOfFile: path)
            if md5 == md5AtPath {
                self.logger.log("with same md5")
                return .existAtPathWithSameMD5
            }else{
                self.logger.log("with different md5")
                return .existAtPathWithDifferentMD5
            }
        }else{
            self.logger.log("not exist")
            return .notExistAtPath
        }
    }
    
    func deleteFile(atPath path: String) -> Bool {
        return Android.bridge.deleteFile(device: self.deviceId, path: path)
    }
    
    func md5(pathOfFile path: String) -> String {
        return Android.bridge.md5(device: self.deviceId, fileWithPath: path)
    }
    
}
