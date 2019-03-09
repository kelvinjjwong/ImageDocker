//
//  LocalDirectory.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/13.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

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
                                          allowedExt: ["jpg", "jpeg", "mp4", "mov", "mpg", "mpeg", "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "vcf", "amr"],
                                          allowedSuffix: ["_backup_hd"], // wechat chatroom image/video thumbnails
                                          deviceOS: .mac)
        print("got \(result.count) files from \(path)")
        return result
    }
    
    
    
    func folders(in path: String) -> [String] {
        print("getting folders from \(path)")
        var result:[String] = []
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let command = Process()
            command.standardOutput = pipe
            command.standardError = pipe
            command.currentDirectoryPath = path
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
    
    
    func filenames(in path: String) -> [String] {
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
                                          allowedExt: ["jpg", "jpeg", "mp4", "mov", "mpg", "mpeg", "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "vcf", "amr"],
                                          allowedSuffix: ["_backup_hd"], // wechat chatroom image/video thumbnails
                                          deviceOS: .mac)
        print("got \(result.count) files from \(path)")
        return result
    }
}
