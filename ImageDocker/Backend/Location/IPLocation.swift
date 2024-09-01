//
//  IPLocation.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/1.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Foundation

public class IPLocation {
    
    public static func get() -> String{
        let pipe = Pipe()
        let pipe2 = Pipe()
        
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe2
            exiftool.launchPath = "/bin/bash"
            exiftool.arguments = ["-c", "curl -fsSL https://zh-hans.ipshu.com/my_info | grep '<li>' | egrep '名称:|地址:' | grep -v '<img' | tail -4 | sed 's/\\/a>//' | tr '</>' ' ' | awk -F' ' '{print $(NF-1)}'"]
            exiftool.launch()
            exiftool.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        
        let data2 = pipe2.fileHandleForReading.readDataToEndOfFile()
        let string2:String = String(data: data2, encoding: String.Encoding.utf8)!
        pipe2.fileHandleForReading.closeFile()
        
        print(string)
        print(string2)
        return string
    }
}
