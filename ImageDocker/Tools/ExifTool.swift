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
    
    func patchDateForVideos(date:Date, urls:[URL]) {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormatter.string(from: date)
        
        let pipe = Pipe()
        
        let exiftool = Process()
        exiftool.standardOutput = pipe
        exiftool.standardError = pipe
        exiftool.launchPath = mainUrl.path
        exiftool.arguments = []
        exiftool.arguments?.append("-overwrite_original")
        exiftool.arguments?.append("-MediaCreateDate=\"" + dateString + "\"")
        exiftool.arguments?.append("-MediaModifyDate=\"" + dateString + "\"")
        exiftool.arguments?.append("-CreateDate=\"" + dateString + "\"")
        exiftool.arguments?.append("-ModifyDate=\"" + dateString + "\"")
        for url in urls {
            exiftool.arguments?.append(url.path)
        }
        exiftool.launch()
        exiftool.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        print(string)
    }
    
    func patchDateForVideo(date:Date, url:URL) {
        print("Changing date time for: \(url.path)")
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormatter.string(from: date)
        
        let pipe = Pipe()
        
        let exiftool = Process()
        exiftool.standardOutput = pipe
        exiftool.standardError = pipe
        exiftool.launchPath = mainUrl.path
        exiftool.arguments = []
        exiftool.arguments?.append("-overwrite_original")
        exiftool.arguments?.append("-MediaCreateDate=\"" + dateString + "\"")
        exiftool.arguments?.append("-MediaModifyDate=\"" + dateString + "\"")
        exiftool.arguments?.append("-CreateDate=\"" + dateString + "\"")
        exiftool.arguments?.append("-ModifyDate=\"" + dateString + "\"")
        exiftool.arguments?.append(url.path)
        exiftool.launch()
        exiftool.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        print(string)
    }
    
    func patchDateForPhotos(date:Date, urls:[URL]) {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormatter.string(from: date)
        
        let pipe = Pipe()
        
        let exiftool = Process()
        exiftool.standardOutput = pipe
        exiftool.standardError = pipe
        exiftool.launchPath = mainUrl.path
        exiftool.arguments = []
        exiftool.arguments?.append("-overwrite_original")
        exiftool.arguments?.append("-DateTimeOriginal=\"" + dateString + "\"")
        for url in urls {
            exiftool.arguments?.append(url.path)
        }
        exiftool.launch()
        exiftool.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        print(string)
    }
    
    func patchDateForPhoto(date:Date, url:URL) {
        print("Changing date time for: \(url.path)")
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormatter.string(from: date)
        
        let pipe = Pipe()
        
        let exiftool = Process()
        exiftool.standardOutput = pipe
        exiftool.standardError = pipe
        exiftool.launchPath = mainUrl.path
        exiftool.arguments = []
        exiftool.arguments?.append("-overwrite_original")
        exiftool.arguments?.append("-DateTimeOriginal=\"" + dateString + "\"")
        exiftool.arguments?.append(url.path)
        exiftool.launch()
        exiftool.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        print(string)
    }
    
    func patchGPSCoordinateForImages(latitude:Double, longitude:Double, urls:[URL]){
        let pipe = Pipe()
        
        let exiftool = Process()
        exiftool.standardOutput = pipe
        exiftool.standardError = pipe
        exiftool.launchPath = mainUrl.path
        exiftool.arguments = []
        exiftool.arguments?.append("-overwrite_original")
        exiftool.arguments?.append("-GPSLatitude=" + latitude.description)
        exiftool.arguments?.append("-GPSLongitude=" + longitude.description)
        for url in urls {
            exiftool.arguments?.append(url.path)
        }
        exiftool.launch()
        exiftool.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        print(string)
    }
    
    func patchGPSCoordinateForImage(latitude:Double, longitude:Double, url:URL){
        print("Changing GPS coordinate for: \(url.path)")
        let pipe = Pipe()
        
        let exiftool = Process()
        exiftool.standardOutput = pipe
        exiftool.standardError = pipe
        exiftool.launchPath = mainUrl.path
        exiftool.arguments = []
        exiftool.arguments?.append("-overwrite_original")
        exiftool.arguments?.append("-GPSLatitude=" + latitude.description)
        exiftool.arguments?.append("-GPSLongitude=" + longitude.description)
        exiftool.arguments?.append(url.path)
        exiftool.launch()
        exiftool.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        print(string)
    }
    
    func assignKeyValueForImage(key:String, value:String, url:URL){
        print("Assigning \(key) -> \(value) for: \(url.path)")
        let pipe = Pipe()
        
        let exiftool = Process()
        exiftool.standardOutput = pipe
        exiftool.standardError = pipe
        exiftool.launchPath = mainUrl.path
        exiftool.arguments = []
        exiftool.arguments?.append("-overwrite_original")
        exiftool.arguments?.append("-\(key)=\"\(value)\"")
        exiftool.arguments?.append(url.path)
        exiftool.launch()
        exiftool.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        print(string)
    }

}
