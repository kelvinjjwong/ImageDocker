//
//  DeviceShell.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/13.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

struct DeviceShell {
    
    static func getFilenames(from string:String, basePath:String, excludeFilenames:[String], allowedExt:[String]) -> [PhoneFile] {
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
            let columns = line.components(separatedBy: " ")
            
            let filename = columns[columns.count - 1]
            
            
            if filename == "" || excludeFilenames.index(where: {$0 == filename}) != nil {
                continue
            }
            
            let filenameParts = filename.components(separatedBy: ".")
            let ext = filenameParts[filenameParts.count - 1].lowercased()
            guard allowedExt.index(where: {$0 == ext}) != nil else {continue}
            
            let size = columns[columns.count - 4]
            let date = columns[columns.count - 3]
            let time = columns[columns.count - 2]
            let url:URL = URL(fileURLWithPath: basePath).appendingPathComponent(subFolder).appendingPathComponent(filename)
            let filepath = url.path
            var file = PhoneFile(filename: filename, path: filepath)
            file.fileSize = size
            file.fileDateTime = "\(date) \(time)"
            //print("processed file \(name)")
            result.append(file)
        }
        return result
    }
}
