//
//  ImageFile+SourceFilename.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/23.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import Cocoa
import AppKit
import CoreLocation
import SwiftyJSON
import AVFoundation
import GRDB

extension ImageFile {
    
    
    
    // MARK: RECOGNIZE IMAGE SOURCE
    
    func recognizeImageSource(){
        guard imageData != nil && imageData?.imageSource == nil else {return}
        var imageSource:String = ""
        let filename = url.lastPathComponent
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
        
        if imageData != nil && imageSource != "" {
            imageData?.imageSource = imageSource
        }
    }
    
    // MARK: RECOGNIZE DATETIME
    
    func recognizeDateTimeFromFilename() {
        // huawei pictures
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_([0-9]{3})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})-([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        
        // file copied
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})-[0-9]\\.([A-Za-z0-9]{3}+)")
        
        // file compressed by wechat
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_comps\\.([A-Za-z0-9]{3}+)")
        // file compressed by wechat
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[A-Za-z0-9]{32}_comps\\.([A-Za-z0-9]{3}+)")
        
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_BURST[0-9]{3}\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_BURST[0-9]{3}_COVER\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]{3}_COVER\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]{3}-[0-9]+\\.([A-Za-z0-9]{3}+)")
        
        // screenshots
        self.recognizeDateTimeFromFilename("Screenshot_([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("Screenshot_([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2})-([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("Screenshot_([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("pt([0-9]{4})_([0-9]{2})_([0-9]{2})_([0-9]{2})_([0-9]{2})_([0-9]{2})_([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        
        // from another camera models
        self.recognizeDateTimeFromFilename("YP([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("YP([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]+\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("YP([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]+_[0-9]+\\.([A-Za-z0-9]{3}+)")
        
        // qqzone video
        self.recognizeDateTimeFromFilename("QQ空间视频_([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        
        // huawei video
        self.recognizeDateTimeFromFilename("VID_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        
        
        
        // file exported by wechat
        self.recognizeUnixTimeFromFilename("mmexport([0-9]{13})\\.([A-Za-z0-9]{3}+)")
        self.recognizeUnixTimeFromFilename("mmexport([0-9]{13})-[0-9]+\\.([A-Za-z0-9]{3}+)")
        self.recognizeUnixTime2FromFilename("mmexport([0-9]{13})_([0-9]+)_[0-9]+\\.([A-Za-z0-9]{3}+)")
        
        // file compressed by wechat
        self.recognizeUnixTimeFromFilename("mmexport([0-9]{13})_comps\\.([A-Za-z0-9]{3}+)")
        
        // file copied
        self.recognizeUnixTimeFromFilename("mmexport([0-9]{13})\\([0-9]+\\)\\.([A-Za-z0-9]{3}+)")
        
        // face_u app
        self.recognizeDateTimeFromFilename("faceu_([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        
        
        if url.lastPathComponent.starts(with: "photo.163.com") {
            return
        }
        
        self.recognizeYearMonthDayFromPath("([0-9]{4})\\-([0-9]{2})\\-([0-9]{2})")
        self.recognizeYearMonthDayFromPath("([0-9]{4})年([0-9]{2})月([0-9]{2})")
        self.recognizeYearMonthFromPath("([0-9]{4})\\-([0-9]{2})")
        self.recognizeYearMonthFromPath("([0-9]{4})年([0-9]{2})")
        
        // huawei honor6 video
        self.recognizeUnixTimeFromFilename("([0-9]{13})\\.([A-Za-z0-9]{3}+)")
    }
    
    // TODO: cache datetime patterns with names for re-used by front-end operation
    
    internal func recognizeDateTimeFromFilename(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.lastPathComponent.matches(for: pattern)
        if parts.count > 0 {
            let dateTime:String = "\(parts[1]):\(parts[2]):\(parts[3]) \(parts[4]):\(parts[5]):\(parts[6])"
            if self.imageData != nil {
                self.imageData?.dateTimeFromFilename = dateTime
            }
            isRecognizedDateTimeFromFilename = true
        }
    }
    
    internal func recognizeUnixTimeFromFilename(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.lastPathComponent.matches(for: pattern)
        if parts.count > 0 {
            let timestamp:String = "\(parts[1])"
            let dateTime = self.convertUnixTimestampToDateString(timestamp)
            if self.imageData != nil {
                self.imageData?.dateTimeFromFilename = dateTime
            }
            isRecognizedDateTimeFromFilename = true
        }
    }
    
    internal func recognizeUnixTime2FromFilename(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.lastPathComponent.matches(for: pattern)
        if parts.count > 0 {
            let timestamp:String = "\(parts[1]).\(parts[2])"
            let dateTime = self.convertUnixTimestampToDateString(timestamp)
            if self.imageData != nil {
                self.imageData?.dateTimeFromFilename = dateTime
            }
            isRecognizedDateTimeFromFilename = true
        }
    }
    
    internal func recognizeYearMonthFromPath(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.path.matches(for: pattern)
        if parts.count > 0 {
            let dateString:String = "\(parts[1]):\(parts[2]):01 00:00:00"
            if self.imageData != nil {
                self.imageData?.dateTimeFromFilename = dateString
            }
            isRecognizedDateTimeFromFilename = true
        }
    }
    
    internal func recognizeYearMonthDayFromPath(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.path.matches(for: pattern)
        if parts.count > 0 {
            let dateString:String = "\(parts[1]):\(parts[2]):\(parts[3]) 00:00:00"
            if self.imageData != nil {
                self.imageData?.dateTimeFromFilename = dateString
            }
            isRecognizedDateTimeFromFilename = true
        }
    }
    
    internal func convertUnixTimestampToDateString(_ timestamp:String, dateFormat:String = "yyyy:MM:dd HH:mm:ss") -> String {
        let date = NSDate(timeIntervalSince1970: Double(timestamp)!/1000 + 8*60*60) // GMT+8
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateTime = dateFormatter.string(from: date as Date)
        return dateTime
    }

}
