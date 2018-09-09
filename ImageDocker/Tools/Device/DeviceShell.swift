//
//  DeviceShell.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/13.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

enum DeviceOS:Int {
    case mac
    case android
}

struct DeviceShell {
    
    static func getFilenames(from string:String, basePath:String, excludeFilenames:Set<String>, allowedExt:Set<String>, deviceOS:DeviceOS = .android) -> [PhoneFile] {
        var result:[PhoneFile] = []
        let lines = string.components(separatedBy: "\n")
        var subFolder = ""
        for line in lines {
            if line == "" || line.starts(with: "total ") {continue}
            if line.starts(with: ".") {
                let folder = line.replacingOccurrences(of: ":", with: "")
                subFolder = folder == "." ? "" : folder
                if subFolder.starts(with: "./") {
                    let indexStartOfText = subFolder.index(subFolder.startIndex, offsetBy: 2)
                    subFolder = String(subFolder[indexStartOfText...])
                }
            }
            
            var columns:[String] = []
            let cols = line.components(separatedBy: " ")
            for col in cols {
                if col == "" || col == " " {
                    continue
                }
                columns.append(col)
            }
            
            let filename = columns[columns.count - 1]
            
            if filename == "" || excludeFilenames.contains(filename) {
                continue
            }
            
            let filenameParts = filename.components(separatedBy: ".")
            let ext = filenameParts[filenameParts.count - 1].lowercased()
            guard allowedExt.contains(ext) && columns.count > 5 else {continue}
            
            let size = deviceOS == .android ? columns[columns.count - 4] : columns[2]
            let date = deviceOS == .android ? columns[columns.count - 3] : ""
            let time = deviceOS == .android ? columns[columns.count - 2] : ""
            let url:URL = URL(fileURLWithPath: basePath).appendingPathComponent(subFolder).appendingPathComponent(filename)
            let filepath = url.path
            var file = PhoneFile(filename: filename, path: filepath)
            file.fileSize = size
            file.fileDateTime = deviceOS == .android ? "\(date) \(time)" : ""
            file.folder = subFolder
            result.append(file)
        }
        return result
    }
    
    static func getFolderNames(from string:String) -> [String] {
        var result:[String] = []
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line == "" || !line.starts(with: "./") || line.starts(with: "./.") {continue}
            
            let indexStartOfText = line.index(line.startIndex, offsetBy: 2)
            let filename = String(line[indexStartOfText...])
            
            result.append(filename.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return result.sorted()
    }
    
    static func getFilenames(from string:String) -> [String] {
        var result:[String] = []
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line == "" {continue}
            
            var columns:[String] = []
            let cols = line.components(separatedBy: " ")
            for col in cols {
                if col == "" || col == " " {
                    continue
                }
                columns.append(col)
            }
            
            let filename = columns[columns.count - 1]
            
            
            if filename == "" {
                continue
            }
            result.append(filename)
        }
        return result.sorted()
    }
    
    
    static func getFilenames(from string:String, excludeFilenames:Set<String>, allowedExt:Set<String>) -> [String] {
        var result:[String] = []
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            if line == "" {continue}
            
            var columns:[String] = []
            let cols = line.components(separatedBy: " ")
            for col in cols {
                if col == "" || col == " " {
                    continue
                }
                columns.append(col)
            }
            
            let filename = columns[columns.count - 1]
            
            if filename == "" || excludeFilenames.contains(filename)  {
                continue
            }
            
            let filenameParts = filename.components(separatedBy: ".")
            let ext = filenameParts[filenameParts.count - 1].lowercased()
            guard allowedExt.contains(ext) else {continue}
            
            result.append(filename)
        }
        return result.sorted()
    }
}
