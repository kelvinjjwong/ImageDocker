//
//  LocalDirectory.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/13.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import Cocoa

struct LocalDirectory {
    
    static let bridge = LocalDirectory()
    
    func datetime(of filename: String, in path:String) -> String {
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = path
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
    
    func files(in path: String) -> [PhoneFile] {
        print("getting files from \(path)")
        var result:[PhoneFile] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = path
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
        
        let filenamesForReference = self.filenamesForReference(in: path)
        
        result = DeviceShell.getFilenames(from: string,
                                          refer: filenamesForReference,
                                          basePath: path,
                                          excludeFilenames: ["directory", ".", ".."],
                                          allowedExt: Naming.FileType.allowed,
                                          allowedSuffix: ["_backup_hd"], // wechat chatroom image/video thumbnails
                                          deviceOS: .mac)
        print("got \(result.count) files from \(path)")
        return result
    }
    
    
    
    func folders(in path: String, unlimitedDepth:Bool = false) -> [String] {
        print("getting folders from \(path)")
        var result:[String] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = path
            command.launchPath = "/usr/bin/find"
            if unlimitedDepth {
                command.arguments = [".", "-type", "d"]
            }else{
                command.arguments = [".", "-type", "d","-maxdepth", "1"]
            }
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
        print("got \(result.count) folders from \(path)")
        return result
    }
    
    fileprivate func filenamesForReference(in path: String, recursive:Bool=false) -> [String:[String]] {
        print("getting folders from \(path)")
        var result:[String:[String]] = [:]
        let param = recursive ? "-1tR" : "-1"
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = path
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
    
    
    func filenames(in path: String, ext:Set<String>? = nil) -> [String] {
        print("getting folders from \(path)")
        var result:[String] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = path
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
        
        let filenamesForReference = self.filenamesForReference(in: path)
        
        result = DeviceShell.getFilenames(from: string,
                                          refer: filenamesForReference,
                                          excludeFilenames: ["directory", ".", ".."],
                                          allowedExt: ext ?? Naming.FileType.allowed,
                                          allowedSuffix: ["_backup_hd"], // wechat chatroom image/video thumbnails
                                          deviceOS: .mac)
        print("got \(result.count) files from \(path)")
        return result
    }
    
    func occupiedDiskSpace(path: String) -> [String:String] {
        print("getting occupied disk space of \(path)")
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = path
            command.launchPath = "/usr/bin/du"
            command.arguments = ["-h", "."]
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
        
        var result:[String:String] = [:]
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line == "" {continue}
            //print(line)
            var columns:[String] = []
            let cols = line.components(separatedBy: "\t")
            for col in cols {
                if col == "" || col == " " {
                    continue
                }
                //print("col -> \(col)")
                columns.append(col)
            }
            let space = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let subpath = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
            result[subpath] = space
            //print("\(subpath) -> \(space)")
        }
        result["console_output"] = string
        return result
    }
    
    func freeSpace(path: String) -> (String, String, String) {
        print("getting free space of \(path)")
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = path
            command.launchPath = "/bin/df"
            command.arguments = ["-bH", "."]
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
        
        var totalSize = ""
        var freeSize = ""
        var mountPoint = ""
        
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line == "" || line.hasPrefix("Filesystem") {continue}
            print(line)
            var columns:[String] = []
            let cols = line.components(separatedBy: " ")
            for col in cols {
                if col == "" || col == " " {
                    continue
                }
                //print("col -> \(col)")
                columns.append(col)
            }
            if columns.count >= 6 {
                totalSize = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                freeSize = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                for i in 5...(columns.count-1) {
                    mountPoint += columns[i]
                    mountPoint += " "
                }
            }
        }
        print("\(mountPoint) -> \(freeSize) / \(totalSize)")
        return (totalSize, freeSize, mountPoint.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    public func getDiskSpace(path:String, lblDiskFree:NSTextField? = nil, lblDiskOccupied:NSTextField? = nil) -> (Double, String, String, [String:String]){
        var spaceDetail:[String:String] = [:]
        var spaceFree = "0M / 0T"
        var mountPoint = ""
        if path != "" && FileManager.default.fileExists(atPath: path) {
            spaceDetail = self.occupiedDiskSpace(path: path)
            
            var diskFree = ""
            var diskTotal = ""
            (diskTotal, diskFree, mountPoint) = self.freeSpace(path: path)
            if diskTotal != "" && diskFree != "" {
                spaceFree = "\(diskFree) / \(diskTotal)"
                if let lbl = lblDiskFree {
                    DispatchQueue.main.async {
                        lbl.stringValue = spaceFree
                    }
                }
            }
        }else{
            spaceDetail = [:]
        }
        
        var sizeGB = 0.0
        if let size = spaceDetail["."] {
            if let lbl = lblDiskOccupied {
                DispatchQueue.main.async {
                    lbl.stringValue = size
                }
            }
            sizeGB = self.getSizeInGB(size: size)
        }
        return (sizeGB, spaceFree, mountPoint, spaceDetail)
    }
    
    public func getSizeInGB(size:String) -> Double{
        var sizeAmount = 0.0
        sizeAmount = Double(size.substring(from: 0, to: -1)) ?? 0
        if size.hasSuffix("T") {
            sizeAmount = sizeAmount * 1000 * 1000
        }
        if size.hasSuffix("G") {
            sizeAmount = sizeAmount * 1000
        }
        if size.hasSuffix("B") || size.hasSuffix("K") {
            sizeAmount = 0
        }
        let sizeGB:Double = sizeAmount / 1000
        return sizeGB
    }
    
    public func getRepositorySpaceOccupationInGB(repository:ImageContainer, diskUsage:[String:Double]? = nil) -> (Double, Double, Double, Double, [String:Double]) {
        var usage:[String:Double] = [:]
        if let u = diskUsage {
            usage = u
        }
        let (repoSize, _, repoDisk, _) = self.getDiskSpace(path: repository.repositoryPath)
        let repoDiskUsed = usage[repoDisk]
        if repoDiskUsed == nil {
            usage[repoDisk] = repoSize
        }else{
            usage[repoDisk] = repoDiskUsed! + repoSize
        }
        
        let (backupSize, _, backupDisk, _) = self.getDiskSpace(path: repository.storagePath)
        let backupDiskUsed = usage[backupDisk]
        if backupDiskUsed == nil {
            usage[backupDisk] = backupSize
        }else{
            usage[backupDisk] = backupDiskUsed! + backupSize
        }
        
        let (faceSize, _, faceDisk, _) = self.getDiskSpace(path: repository.cropPath)
        let faceDiskUsed = usage[faceDisk]
        if faceDiskUsed == nil {
            usage[faceDisk] = faceSize
        }else{
            usage[faceDisk] = faceDiskUsed! + faceSize
        }
        
        let totalSize = repoSize + backupSize + faceSize
        
        return (repoSize, backupSize, faceSize, totalSize, usage)
    }
}
