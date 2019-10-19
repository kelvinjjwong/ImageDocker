//
//  Naming.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/19.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

struct Naming {
    static let Camera = CameraModelRecognizer()
    static let Source = ImageSourceRecognizer()
    static let DateTime = DateTimeRecognizer()
}

// MARK: - SOURCE

struct ImageSourceRecognizer {
    
    func recognize(url:URL) -> String {
        
        let filename = url.lastPathComponent
        return self.recognize(filename: filename)
    }
    
    func recognize(filename:String) -> String {
        var imageSource:String = ""
        if filename.starts(with: "mmexport") {
            imageSource = "WeChat"
        }else if filename.starts(with: "QQ空间视频") {
            imageSource = "QQ"
        }else if filename.starts(with: "IMG_") {
            imageSource = "Camera"
        }else if filename.starts(with: "VID_") {
            imageSource = "Camera"
        }else if filename.starts(with: "DSC") {
            imageSource = "Camera"
        }else if filename.starts(with: "Screenshot_") {
            imageSource = "ScreenShot"
        }
        if imageSource == "" {
            let parts:[String] = filename.matches(for: "[0-9a-zA-Z]{25}_[0-9]+\\.([A-Za-z0-9]{3}+)")
            if parts.count > 0 {
                imageSource = "PhoneApp"
            }
        }
        if imageSource == "" {
            let parts:[String] = filename.matches(for: "[0-9a-zA-Z]{32}\\.([A-Za-z0-9]{3}+)")
            if parts.count > 0 {
                imageSource = "PhoneApp"
            }
        }
        if imageSource == "" {
            let parts:[String] = filename.matches(for: "[0-9A-Z]{8}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{12}-[0-9A-Z]{3}-[0-9A-Z]{16}_tmp\\.([A-Za-z0-9]{3}+)")
            if parts.count > 0 {
                imageSource = "PhoneApp"
            }
        }
        return imageSource
    }
}

// MARK: - CAMERA MODEL

class CameraModelRecognizer {
    
    let models:[String : [String : String]] = [
        "HUAWEI" : [
            "H60" : "Honor 6",
            "FRD" : "Honor 8",
            "KNT" : "Honor V8",
            "STF" : "Honor 9",
            "DUK" : "Honor V9",
            "COL" : "Honor 10",
            "BKL" : "Honor V10",
            "EVA" : "Perfect 9",
            "VIE" : "Perfect 9 Plus",
            "VTR" : "Perfect 10",
            "VKY" : "Perfect 10 Plus",
            "EML" : "Perfect 20",
            "CLT" : "Perfect 20 Plus",
            "MHA" : "Mate 9",
            "LON" : "Mate 9 Pro",
            "ALP" : "Mate 10",
            "BLA" : "Mate 10 Pro",
            "WAS" : "Nova Young"
        ]
    ]
    
    func recognize(maker:String, model:String) -> String{
        guard maker != "" && model != "" else {return model}
        for m in models.keys {
            if maker == m {
                print("Recognized maker \(m), trying to get name of model \(model)")
                for mm in models[m]! {
                    if model.starts(with: mm.key) {
                        return mm.value + " (" + model + ")"
                    }
                }
                break
            }
        }
        return model
    }
    
    func getMarketName(maker:String, model:String) -> String{
        guard maker != "" && model != "" else {return model}
        for m in models.keys {
            if maker == m {
                print("Recognized maker \(m), trying to get market name of model \(model)")
                for mm in models[m]! {
                    if model.starts(with: mm.key) {
                        print("Got market name [\(mm.value)] of [\(m) \(model)]")
                        return mm.value
                    }
                }
                break
            }
        }
        return ""
    }
}

// MARK: - DATE TIME

struct DateTimeRecognizer {
    
    func get(from data:Image) -> Date? {
        var date:Date? = data.photoTakenDate
        if date != nil { return date }
        date = data.assignDateTime
        if date != nil { return date }
        date = data.exifDateTimeOriginal
        if date != nil { return date }
        date = data.exifCreateDate
        if date != nil { return date }
        date = data.exifModifyDate
        if date != nil { return date }
        date = data.videoCreateDate
        if date != nil { return date }
        date = data.trackCreateDate
        if date != nil { return date }
        date = data.filesysCreateDate
        return date
    }
    
    func recognize(url:URL) -> String {
        
        // netease photo gallery, disordered
        if url.lastPathComponent.starts(with: "photo.163.com") {
            return self.recognizeDateTimeFromPath(path: url.path)
        }
        
        // other cases
        var date = self.recognizeDateTimeFromFilename(filename: url.lastPathComponent)
        if date == "" {
            date = self.recognizeDateTimeFromPath(path: url.path)
        }
        
        return date
    }
    
    func recognizeDateTimeFromFilename(filename: String) -> String {
        
        var date = ""
        // huawei pictures
        if date == "" {
            date = self.recognizeDateTimeFromFilename(filename: filename, patterns: [
                // huawei pictures
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_([0-9]{3})\\.([A-Za-z0-9]{3}+)",
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})-([0-9]{2})\\.([A-Za-z0-9]{3}+)",
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)",
                
                // file copied
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]\\.([A-Za-z0-9]{3}+)",
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})-[0-9]\\.([A-Za-z0-9]{3}+)",
                
                // file compressed by wechat
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_comps\\.([A-Za-z0-9]{3}+)",
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[A-Za-z0-9]{32}_comps\\.([A-Za-z0-9]{3}+)",
                
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_BURST[0-9]{3}\\.([A-Za-z0-9]{3}+)",
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_BURST[0-9]{3}_COVER\\.([A-Za-z0-9]{3}+)",
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]{3}_COVER\\.([A-Za-z0-9]{3}+)",
                "IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]{3}-[0-9]+\\.([A-Za-z0-9]{3}+)",
                
                // screenshots
                "Screenshot_([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)",
                "Screenshot_([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2})-([0-9]{2})\\.([A-Za-z0-9]{3}+)",
                "Screenshot_([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})\\.([A-Za-z0-9]{3}+)",
                "pt([0-9]{4})_([0-9]{2})_([0-9]{2})_([0-9]{2})_([0-9]{2})_([0-9]{2})_([0-9]{2})\\.([A-Za-z0-9]{3}+)",
                
                // from another camera models
                "YP([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)",
                "YP([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]+\\.([A-Za-z0-9]{3}+)",
                "YP([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]+_[0-9]+\\.([A-Za-z0-9]{3}+)",
                
                // qqzone video
                "QQ空间视频_([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)",
                
                // huawei video
                "VID_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)",
                
                // face_u app
                "faceu_([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)"
                ])
        }
        
        if date == "" {
            date = self.recognizeUnixTimeFromFilename(filename: filename, patterns: [
                
                // huawei honor6 video
                "([0-9]{13})\\.([A-Za-z0-9]{3}+)",
                
                // file exported by wechat
                "mmexport([0-9]{13})\\.([A-Za-z0-9]{3}+)",
                "mmexport([0-9]{13})-[0-9]+\\.([A-Za-z0-9]{3}+)",
                
                // file compressed by wechat
                "mmexport([0-9]{13})_comps\\.([A-Za-z0-9]{3}+)",
                
                // file copied by wechat
                "mmexport([0-9]{13})\\([0-9]+\\)\\.([A-Za-z0-9]{3}+)"
                
                ])
        }
        
        if date == "" {
            date = self.recognizeUnixTime2FromFilename(filename: filename, patterns: [
                
                // file exported by wechat
                "mmexport([0-9]{13})_([0-9]+)_[0-9]+\\.([A-Za-z0-9]{3}+)"
                
                ])
        }
        
        return date
    }
    
    func recognizeDateTimeFromPath(path: String) -> String {
        var date = ""
        
        if date == "" {
            date = self.recognizeYearMonthDayFromPath(path: path, patterns: [
                
                "([0-9]{4})\\-([0-9]{2})\\-([0-9]{2})",
                "([0-9]{4})年([0-9]{2})月([0-9]{2})"
                
                ])
        }
        
        if date == "" {
            date = self.recognizeYearMonthFromPath(path: path, patterns: [
                
                "([0-9]{4})\\-([0-9]{2})",
                "([0-9]{4})年([0-9]{2})"
                
                ])
        }
        return date
    }
    
    
    
    internal func recognizeDateTimeFromFilename(filename: String, patterns:[String]) -> String {
        for pattern in patterns {
            let dateString = self.recognizeDateTimeFromFilename(filename: filename, pattern)
            if dateString != "" {
                return dateString
            }
        }
        return ""
    }
    
    internal func recognizeDateTimeFromFilename(filename: String, _ pattern:String) -> String{
        
        let parts:[String] = filename.matches(for: pattern)
        if parts.count > 0 {
            return "\(parts[1]):\(parts[2]):\(parts[3]) \(parts[4]):\(parts[5]):\(parts[6])"
        }
        return ""
    }
    
    
    
    internal func recognizeUnixTimeFromFilename(filename: String, patterns:[String]) -> String {
        for pattern in patterns {
            let dateString = self.recognizeUnixTimeFromFilename(filename: filename, pattern)
            if dateString != "" {
                return dateString
            }
        }
        return ""
    }
    
    internal func recognizeUnixTimeFromFilename(filename: String, _ pattern:String) -> String{
        let parts:[String] = filename.matches(for: pattern)
        if parts.count > 0 {
            let timestamp:String = "\(parts[1])"
            return self.convertUnixTimestampToDateString(timestamp)
        }
        return ""
    }
    
    internal func recognizeUnixTime2FromFilename(filename: String, patterns:[String]) -> String {
        for pattern in patterns {
            let dateString = self.recognizeUnixTime2FromFilename(filename: filename, pattern)
            if dateString != "" {
                return dateString
            }
        }
        return ""
    }
    
    internal func recognizeUnixTime2FromFilename(filename: String, _ pattern:String) -> String{
        let parts:[String] = filename.matches(for: pattern)
        if parts.count > 0 {
            let timestamp:String = "\(parts[1]).\(parts[2])"
            return self.convertUnixTimestampToDateString(timestamp)
        }
        return ""
    }
    
    internal func recognizeYearMonthFromPath(path: String, patterns:[String]) -> String {
        for pattern in patterns {
            let dateString = self.recognizeYearMonthFromPath(path: path, pattern)
            if dateString != "" {
                return dateString
            }
        }
        return ""
    }
    
    internal func recognizeYearMonthFromPath(path: String, _ pattern:String) -> String{
        let parts:[String] = path.matches(for: pattern)
        if parts.count > 0 {
            return "\(parts[1]):\(parts[2]):01 00:00:00"
        }
        return ""
    }
    
    internal func recognizeYearMonthDayFromPath(path: String, patterns:[String]) -> String {
        for pattern in patterns {
            let dateString = self.recognizeYearMonthDayFromPath(path: path, pattern)
            if dateString != "" {
                return dateString
            }
        }
        return ""
    }
    
    internal func recognizeYearMonthDayFromPath(path: String, _ pattern:String) -> String{
        let parts:[String] = path.matches(for: pattern)
        if parts.count > 0 {
            return "\(parts[1]):\(parts[2]):\(parts[3]) 00:00:00"
        }
        return ""
    }
    
    internal func convertUnixTimestampToDateString(_ timestamp:String, dateFormat:String = "yyyy:MM:dd HH:mm:ss") -> String {
        let date = NSDate(timeIntervalSince1970: Double(timestamp)!/1000 + 8*60*60) // GMT+8
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateTime = dateFormatter.string(from: date as Date)
        return dateTime
    }
}
