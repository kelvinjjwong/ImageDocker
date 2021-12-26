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
    
    let logger = ConsoleLogger(category: "ExifTool")
    
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
        
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = FileHandle.nullDevice
            exiftool.launchPath = mainUrl.path
            exiftool.arguments = ["-j", "-g", url.path]
            exiftool.launch()
            exiftool.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        return string
    }
    
    func getUnformattedExif(url:URL) -> String{
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = FileHandle.nullDevice
            exiftool.launchPath = mainUrl.path
            exiftool.arguments = ["-j", "-g", "-n", url.path]
            exiftool.launch()
            exiftool.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        return string
    }
    
    func patchDateForVideos(date:Date, urls:[URL], tags:Set<String>) {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormatter.string(from: date)
        
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe
            exiftool.launchPath = mainUrl.path
            exiftool.arguments = []
            exiftool.arguments?.append("-overwrite_original")
            exiftool.arguments?.append("-MediaCreateDate=\"" + dateString + "\"")
            exiftool.arguments?.append("-MediaModifyDate=\"" + dateString + "\"")
            for tag in tags{
                exiftool.arguments?.append("-\(tag)=\"" + dateString + "\"")
            }
            for url in urls {
                exiftool.arguments?.append(url.path)
            }
            exiftool.launch()
            exiftool.waitUntilExit()
            exiftool.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string:String = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            self.logger.log(string)
        }
    }
    
    func patchDateForVideo(date:Date, url:URL, tags:Set<String>) {
        self.logger.log("Changing date time for: \(url.path)")
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormatter.string(from: date)
        
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe
            exiftool.launchPath = mainUrl.path
            exiftool.arguments = []
            exiftool.arguments?.append("-overwrite_original")
            exiftool.arguments?.append("-MediaCreateDate=\"" + dateString + "\"")
            exiftool.arguments?.append("-MediaModifyDate=\"" + dateString + "\"")
            for tag in tags{
                exiftool.arguments?.append("-\(tag)=\"" + dateString + "\"")
            }
            exiftool.arguments?.append(url.path)
            exiftool.launch()
            exiftool.waitUntilExit()
            exiftool.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string:String = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            self.logger.log(string)
        }
    }
    
    func patchDateForPhotos(date:Date, urls:[URL], tags:Set<String>) {
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormatter.string(from: date)
        
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe
            exiftool.launchPath = mainUrl.path
            exiftool.arguments = []
            exiftool.arguments?.append("-overwrite_original")
            for tag in tags{
                exiftool.arguments?.append("-\(tag)=\"" + dateString + "\"")
            }
            for url in urls {
                exiftool.arguments?.append(url.path)
            }
            exiftool.launch()
            exiftool.waitUntilExit()
            exiftool.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string:String = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            self.logger.log(string)
        }
    }
    
    func patchDateForPhoto(date:Date, url:URL, tags:Set<String>) {
        self.logger.log("Changing date time for: \(url.path)")
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString:String = dateFormatter.string(from: date)
        
        let pipe = Pipe()
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe
            exiftool.launchPath = mainUrl.path
            exiftool.arguments = []
            exiftool.arguments?.append("-overwrite_original")
            for tag in tags{
                exiftool.arguments?.append("-\(tag)=\"" + dateString + "\"")
            }
            exiftool.arguments?.append(url.path)
            exiftool.launch()
            exiftool.waitUntilExit()
            exiftool.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string:String = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            self.logger.log(string)
        }
    }
    
    func patchGPSCoordinateForImages(latitude:Double, longitude:Double, urls:[URL]){
        let pipe = Pipe()
        autoreleasepool { () -> Void in
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
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        self.logger.log(string)
    }
    
    func patchGPSCoordinateForImage(latitude:Double, longitude:Double, url:URL){
        self.logger.log("Changing GPS coordinate for: \(url.path)")
        let pipe = Pipe()
        autoreleasepool { () -> Void in
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
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        self.logger.log(string)
    }
    
    func patchImageDescription(description:String, url:URL) {
        self.logger.log("Changing ImageDescription for: \(url.path)")
        
        autoreleasepool { () -> Void in
            let pipe = Pipe()
            
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe
            exiftool.launchPath = mainUrl.path
            exiftool.arguments = []
            exiftool.arguments?.append("-overwrite_original")
            exiftool.arguments?.append("-ImageDescription=\"" + description + "\"")
            exiftool.arguments?.append(url.path)
            exiftool.launch()
            exiftool.waitUntilExit()
            exiftool.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string:String = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            self.logger.log(string)
        }
    }
    
    func assignKeyValueForImage(key:String, value:String, url:URL){
        self.logger.log("Assigning \(key) -> \(value) for: \(url.path)")
        let pipe = Pipe()
        autoreleasepool { () -> Void in
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
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        self.logger.log(string)
    }
    
    func getImageDescription(url:URL) -> String {
        let pipe = Pipe()
        var string = ""
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe
            exiftool.launchPath = mainUrl.path
            exiftool.arguments = []
            exiftool.arguments?.append("-ImageDescription")
            exiftool.arguments?.append(url.path)
            exiftool.launch()
            exiftool.waitUntilExit()
            exiftool.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
        }
        if string == "" || !string.hasPrefix("Image Description               : "){
            return ""
        }
        var result = string.replacingOccurrences(of: "Image Description               : ", with: "")
        
        if result.hasPrefix("\"") && result.hasSuffix("\"") && result != "\"" {
            let prefixIndex = result.index(result.startIndex, offsetBy: 1)
            let suffixIndex = result.index(result.endIndex, offsetBy: -1)
            result = String(result[prefixIndex..<suffixIndex])
        }
        return result
    }

}
