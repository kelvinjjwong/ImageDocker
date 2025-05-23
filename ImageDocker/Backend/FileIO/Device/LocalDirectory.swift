//
//  LocalDirectory.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/13.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import Cocoa
import LoggerFactory
import SharedDeviceLib

struct LocalDirectory {
    
    let logger = LoggerFactory.get(category: "LocalDirectory")
    
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
                self.logger.log(.error, error)
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
//        self.logger.log(.trace, "getting files from \(path)")
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
                self.logger.log(.error, error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
//        self.logger.log(string)
        
        let filenamesForReference = self.filenamesForReference(in: path)
        
        result = DeviceShell.getFilenames(from: string,
                                          refer: filenamesForReference,
                                          basePath: path,
                                          excludeFilenames: ["directory", ".", ".."],
                                          allowedExt: Naming.FileType.allowed,
                                          allowedSuffix: ["_backup_hd"], // wechat chatroom image/video thumbnails
                                          deviceOS: .mac)
//        self.logger.log(.trace, "got \(result.count) files from \(path)")
        return result
    }
    
    
    
    func folders(in path: String, unlimitedDepth:Bool = false) -> [String] {
//        self.logger.log(.trace, "getting folders from \(path)")
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
                self.logger.log(.error, error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        //self.logger.log(string)
        result = DeviceShell.getFolderNames(from: string)
//        self.logger.log(.trace, "got \(result.count) folders from \(path)")
        return result
    }
    
    fileprivate func filenamesForReference(in path: String, recursive:Bool=false) -> [String:[String]] {
//        self.logger.log(.trace, "getting folders from \(path)")
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
                self.logger.log(.error, error)
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
//        self.logger.log(.trace, "getting folders from \(path)")
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
                self.logger.log(.error, error)
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
//        self.logger.log(.trace, "got \(result.count) files from \(path)")
        return result
    }
    
    func occupiedDiskSpace(path: String) -> [String:String] {
//        self.logger.log(.trace, "getting occupied disk space of \(path)")
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
                self.logger.log(.error, error)
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
            //self.logger.log(line)
            var columns:[String] = []
            let cols = line.components(separatedBy: "\t")
            for col in cols {
                if col == "" || col == " " {
                    continue
                }
                //self.logger.log(.trace, "col -> \(col)")
                columns.append(col)
            }
            let space = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let subpath = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
            result[subpath] = space
            //self.logger.log(.trace, "\(subpath) -> \(space)")
        }
        result["console_output"] = string
        return result
    }
    
    func mountpoints() -> [String] {
        var volumes:[String] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.launchPath = "/bin/df"
            command.arguments = ["-bH"]
            do {
                try command.run()
            }catch{
                self.logger.log(.error, error)
            }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string:String = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            let lines = string.components(separatedBy: "\n")
            for line in lines {
                if line == "" || line.hasPrefix("Filesystem") {continue}
                let cols = line.components(separatedBy: " ")
                for col in cols {
                    if col == "" || col == " " {
                        continue
                    }
                    if col == "/" || col.starts(with: "/Volumes/") {
                        volumes.append(col)
                    }
                }
            }
        }
        return volumes
    }
    
    func listMountedVolumes() -> [String] {
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = "/Volumes/"
            command.launchPath = "/bin/ls"
            command.arguments = ["-1", "/Volumes/"]
            do {
                try command.run()
            }catch{
                self.logger.log(.error, error)
            }
        }
        //command.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        
        var result:[String] = []
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line == "" {continue}
            
            result.append("/Volumes/\(line)")
        }
        return result
    }
    
    func freeSpace(path: String) -> (String, String, String) {
//        self.logger.log(.trace, "getting free space of \(path)")
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
                self.logger.log(.error, error)
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
//            self.logger.log(line)
            var columns:[String] = []
            let cols = line.components(separatedBy: " ")
            for col in cols {
                if col == "" || col == " " {
                    continue
                }
                //self.logger.log(.trace, "col -> \(col)")
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
//        self.logger.log(.trace, "\(mountPoint) -> \(freeSize) / \(totalSize)")
        return (totalSize, freeSize, mountPoint.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    public func getDiskMountPointVolume(path:String) -> String {
        var isDir:ObjCBool = false
        if path.trimmingCharacters(in: .whitespacesAndNewlines) != ""
            && FileManager.default.fileExists(atPath: path.trimmingCharacters(in: .whitespacesAndNewlines), isDirectory: &isDir)
            && isDir.boolValue == true {
            let (totalSize, freeSize, mountPoint) = self.freeSpace(path: path)
            self.logger.log(.trace, "get volume of path: \(path) - volume: \(mountPoint) - total:\(totalSize), free:\(freeSize)")
            return mountPoint
        }else{
            return ""
        }
    }
    
    public func getSymbolicLinkDestination(path:String) -> String {
        let url = URL(fileURLWithPath: path)
        if let ok = try? url.checkResourceIsReachable(), ok {
            let vals = try? url.resourceValues(forKeys: [.isSymbolicLinkKey])
            if let islink = vals?.isSymbolicLink, islink {
                if let dest = try? FileManager.default.destinationOfSymbolicLink(atPath: path) {
                    return dest
                }
            }
        }
        return path
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
            self.logger.log(.trace, "get disk space of mountpoint \(mountPoint)")
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
    
    public func getRepositoryVolume(repository:ImageRepository, volumes:[String]) -> ([String], [String]) {
        var connectedVolumes:Set<String> = []
        var missingVolumes:Set<String> = []
        print("=======")
        print("check repository storage volume: id=\(repository.id) name=\(repository.name)")
        let (mountpoint_home, mp_home_symbolic, mp_home_exists) = repository.homeVolume.getPathOfSoftlink()
        print(repository.homeVolume, mountpoint_home, mp_home_symbolic, mp_home_exists)
        let (mountpoint_repository, mp_repository_symbolic, mp_repository_exists) = repository.repositoryVolume.getPathOfSoftlink()
        print(repository.repositoryVolume, mountpoint_repository, mp_repository_symbolic, mp_repository_exists)
        let (mountpoint_storage, mp_storage_symbolic, mp_storage_exists) = repository.storageVolume.getPathOfSoftlink()
        print(repository.storageVolume, mountpoint_storage, mp_storage_symbolic, mp_storage_exists)
        let (mountpoint_face, mp_face_symbolic, mp_face_exists) = repository.faceVolume.getPathOfSoftlink()
        let (mountpoint_crop, mp_crop_symbolic, mp_crop_exists) = repository.cropVolume.getPathOfSoftlink()
        print("=======")
        
        if mountpoint_home != "" && ( (mp_home_symbolic && mp_home_exists) || (volumes.contains(mountpoint_home)) ){
            connectedVolumes.insert(mountpoint_home)
        }else if mountpoint_home != ""{
            missingVolumes.insert(mountpoint_home)
        }
        if mountpoint_repository != "" && ( (mp_repository_symbolic && mp_repository_exists) || (volumes.contains(mountpoint_repository)) ) {
            connectedVolumes.insert(mountpoint_repository)
        }else if mountpoint_repository != ""{
            missingVolumes.insert(mountpoint_repository)
        }
        if mountpoint_storage != "" && ( (mp_storage_symbolic && mp_storage_exists) || (volumes.contains(mountpoint_storage)) ) {
            connectedVolumes.insert(mountpoint_storage)
        }else if mountpoint_storage != ""{
            missingVolumes.insert(mountpoint_storage)
        }
        if mountpoint_face != "" && ( (mp_face_symbolic && mp_face_exists) || (volumes.contains(mountpoint_face)) ) {
            connectedVolumes.insert(mountpoint_face)
        }else if mountpoint_face != ""{
            missingVolumes.insert(mountpoint_face)
        }
        if mountpoint_crop != "" && ( (mp_crop_symbolic && mp_crop_exists) || (volumes.contains(mountpoint_crop)) ) {
            connectedVolumes.insert(mountpoint_crop)
        }else if mountpoint_crop != ""{
            missingVolumes.insert(mountpoint_crop)
        }
        return (connectedVolumes.sorted(), missingVolumes.sorted())
    }
    
//    public func getRepositoryVolume(repository:ImageContainer) -> [String] {
//        var volumes:Set<String> = []
//        volumes.insert(getDiskMountPointVolume(path: repository.path))
//        volumes.insert(getDiskMountPointVolume(path: repository.storagePath))
//        volumes.insert(getDiskMountPointVolume(path: repository.repositoryPath))
//        volumes.insert(getDiskMountPointVolume(path: repository.facePath))
//        volumes.insert(getDiskMountPointVolume(path: repository.cropPath))
//        volumes.remove("")
//        return volumes.sorted()
//    }
    
    public func getRepositorySpaceOccupationInGB(repository:ImageRepository, diskUsage:[String:Double]? = nil) -> (Double, Double, Double, Double, [String:Double]) {
        var usage:[String:Double] = [:]
        if let u = diskUsage {
            usage = u
        }
        let (repoSize, _, repoDisk, _) = self.getDiskSpace(path: "\(repository.repositoryVolume)\(repository.repositoryPath)")
        let repoDiskUsed = usage[repoDisk]
        if repoDiskUsed == nil {
            usage[repoDisk] = repoSize
        }else{
            usage[repoDisk] = repoDiskUsed! + repoSize
        }
        
        let (backupSize, _, backupDisk, _) = self.getDiskSpace(path: "\(repository.storageVolume)\(repository.storagePath)")
        let backupDiskUsed = usage[backupDisk]
        if backupDiskUsed == nil {
            usage[backupDisk] = backupSize
        }else{
            usage[backupDisk] = backupDiskUsed! + backupSize
        }
        
        let (faceSize, _, faceDisk, _) = self.getDiskSpace(path: "\(repository.faceVolume)\(repository.facePath)")
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
