//
//  ExifTool.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/24.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import AppKit
import LoggerFactory

/// manage GeoTag's use of exiftool
class ExifTool {
    
    let logger = LoggerFactory.get(category: "ExifTool")
    static let _logger = LoggerFactory.get(category: "ExifTool")
    
    /// singleton instance of this class
    static let helper = ExifTool()
    
    // URL of ExifTool
    var mainUrl: URL
    
    // Verify access to the embedded version of ExifTool
    init() {
        let exiftoolUrl = Setting.localEnvironment.exiftoolPath()
        if exiftoolUrl != "" && exiftoolUrl.isFileExists() {
            mainUrl = URL(fileURLWithPath: exiftoolUrl)
            self.logger.log(.trace, "[EXIFTOOL-INIT] Detected ExifTool commandline exists at \(mainUrl.path)")
        } else {
            mainUrl = URL(fileURLWithPath: "")
            self.logger.log(.error, "[EXIFTOOL-INIT] ExifTool command path has not setup or does not exist.")
        }
    }
    
    func reinitMainUrlIfEmpty() {
        if mainUrl.path == "" {
            let exiftoolUrl = Setting.localEnvironment.exiftoolPath()
            if exiftoolUrl != "" && exiftoolUrl.isFileExists() {
                self.mainUrl = URL(fileURLWithPath: exiftoolUrl)
                self.logger.log(.trace, "[EXIFTOOL-INIT] Detected ExifTool commandline exists at \(mainUrl.path)")
            }
        }
    }
    
    public static func getVersion(path:String) -> String{
        let pipe = Pipe()
        let pipe2 = Pipe()
        
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe2
            exiftool.launchPath = "/bin/bash"
            exiftool.arguments = ["-c", "\(path) -ver"]
            exiftool.launch()
            exiftool.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        
        let data2 = pipe2.fileHandleForReading.readDataToEndOfFile()
        let string2:String = String(data: data2, encoding: String.Encoding.utf8)!
        pipe2.fileHandleForReading.closeFile()
        
        _logger.log(.trace, string)
        _logger.log(.trace, string2)
        return string
    }
    
    public static func getLatestVersionUrl() -> String{
        let pipe = Pipe()
        let pipe2 = Pipe()
        
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe2
            exiftool.launchPath = "/bin/bash"
            exiftool.arguments = ["-c", "curl -fsSL https://exiftool.org/rss.xml | grep enclosure | head -1 | awk -F\\' '{print $2}'"]
            exiftool.launch()
            exiftool.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        
        let data2 = pipe2.fileHandleForReading.readDataToEndOfFile()
        let string2:String = String(data: data2, encoding: String.Encoding.utf8)!
        pipe2.fileHandleForReading.closeFile()
        
        _logger.log(.trace, string)
        _logger.log(.trace, string2)
        return string
    }
    
    public static func untarExiftoolPackage(filePath:String) -> String{
        let filename = URL(fileURLWithPath: filePath).lastPathComponent
        let filenameWithoutExt = filename.replacingOccurrences(of: ".tar.gz", with: "")
        let folder = URL(fileURLWithPath: filePath).deletingLastPathComponent().path.replacingFirstOccurrence(of: "file://", with: "")
        
        let pipe = Pipe()
        let pipe2 = Pipe()
        
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe2
            exiftool.launchPath = "/bin/bash"
            exiftool.arguments = ["-c", "cd \(folder);tar -xzf \(filename); rm -f current; ln -s \(filenameWithoutExt) current;"]
            exiftool.launch()
            exiftool.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        
        let data2 = pipe2.fileHandleForReading.readDataToEndOfFile()
        let string2:String = String(data: data2, encoding: String.Encoding.utf8)!
        pipe2.fileHandleForReading.closeFile()
        
        _logger.log(.trace, string)
        _logger.log(.trace, string2)
        return filename
    }
    
    func getFormattedExif(url:URL) -> String{
        // need install exiftool to macos first
        // https://exiftool.org
        // verification: "which exiftool"
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return ""
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return ""
        }
        
        let pipe = Pipe()
        let pipe2 = Pipe()
        
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe2
            exiftool.launchPath = mainUrl.path
            exiftool.arguments = ["-j", "-g", url.path]
            exiftool.launch()
            exiftool.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let err = pipe2.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        let errStr:String = String(data: err, encoding: .utf8)!
        if errStr.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            self.logger.log(.warning, "[EXIFTOOL-ERROR] \(url.path) : \(errStr)")
            NotificationMessageManager.default.createNotificationMessage(type: "EXIF", name: url.path, message: errStr)
        }
        // if errStr contains "exiftool err: Illegal declaration of subroutine" need install exiftool.dmg
        pipe.fileHandleForReading.closeFile()
        return string
    }
    
    func getUnformattedExif(url:URL) -> String{
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return ""
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return ""
        }
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
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return
        }
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
        self.logger.log(.trace, "Changing date time for: \(url.path)")
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return
        }
        
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
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return
        }
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
        self.logger.log(.trace, "Changing date time for: \(url.path)")
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return
        }
        
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
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return
        }
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
        self.logger.log(.trace, "Changing GPS coordinate for: \(url.path)")
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return
        }
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
        self.logger.log(.trace, "Changing ImageDescription for: \(url.path)")
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return
        }
        
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
        self.logger.log(.trace, "Assigning \(key) -> \(value) for: \(url.path)")
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return
        }
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
        self.reinitMainUrlIfEmpty()
        if mainUrl.path == "" {
            self.logger.log(.error, "exiftool path is empty !!!")
            return ""
        }
        if !mainUrl.path.isFileExists() {
            self.logger.log(.error, "exiftool has not installed !!!")
            return ""
        }
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
