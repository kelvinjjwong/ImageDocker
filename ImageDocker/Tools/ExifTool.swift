//
//  ExifTool.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/24.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import AppKit

/// manage GeoTag's use of exiftool
struct ExifTool {
    /// singleton instance of this class
    static let helper = ExifTool()
    
    // URL of the embedded version of ExifTool
    var mainUrl: URL
    
    // Verify access to the embedded version of ExifTool
    init() {
        if let exiftoolUrl = Bundle.main.url(forResource: "ExifTool", withExtension: nil) {
            mainUrl = exiftoolUrl.appendingPathComponent("exiftool")
        } else {
            fatalError("The Application Bundle is corrupt.")
        }
    }
    
    func getFormattedExif(url:URL) -> String{
        let pipe = Pipe()
        
        let exiftool = Process()
        exiftool.standardOutput = pipe
        exiftool.standardError = FileHandle.nullDevice
        exiftool.launchPath = mainUrl.path
        exiftool.arguments = ["-j", "-g", url.path]
        exiftool.launch()
        exiftool.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        return string
    }
    
    func getUnformattedExif(url:URL) -> String{
        let pipe = Pipe()
        
        let exiftool = Process()
        exiftool.standardOutput = pipe
        exiftool.standardError = FileHandle.nullDevice
        exiftool.launchPath = mainUrl.path
        exiftool.arguments = ["-j", "-g", "-n", url.path]
        exiftool.launch()
        exiftool.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        return string
    }

}
