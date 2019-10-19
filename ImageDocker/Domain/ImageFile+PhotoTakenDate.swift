//
//  ImageFile+PhotoTakenDate.swift
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
    // MARK: CHOOSE PHOTO TAKEN DATE
    
    internal func choosePhotoTakenDateFromMetaInfo() -> String? {
        var dt:Date? = nil
        if let photoFile = self.imageData {
            dt = Naming.DateTime.get(from: photoFile)
        }
        
        var result:String? = nil
        if let dateTime = dt {
            result = exifDateFormat.string(from: dateTime)
        }
        return result
    }
    
    internal func storePhotoTakenDate(dateTime:String?) {
        if let dt = dateTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            let photoTakenDate = dateFormatter.date(from: dt)
            if let ptd = photoTakenDate {
                storePhotoTakenDate(dateTime: ptd)
            }
        }
    }
    
    internal func storePhotoTakenDate(dateTime photoTakenDate:Date){
        
        self.imageData?.photoTakenDate = photoTakenDate
        
        let calendar = NSCalendar.current
        let component = calendar.dateComponents([.year, .month, .day, .hour], from: photoTakenDate)
        if self.imageData != nil && component.year != nil && component.month != nil && component.day != nil && component.hour != nil {
            self.imageData?.photoTakenYear = component.year!
            self.imageData?.photoTakenMonth = component.month!
            self.imageData?.photoTakenDay = component.day!
            self.imageData?.photoTakenHour = component.hour!
            self.imageData?.updatePhotoTakenDate = Date()
        }
    }
    
    func photoTakenDate() -> Date? {
        return self.imageData?.photoTakenDate
    }
    
    func dateString(_ date:Date?, format:String = "yyyy-MM-dd") -> String {
        if date == nil {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let result = dateFormatter.string(from: date!)
        return result
    }
    
    
    func photoTakenDateString(_ format:String = "yyyy-MM-dd", forceUpdate:Bool = false) -> String {
        guard _photoTakenDateString == "" || forceUpdate else {return self._photoTakenDateString}
        if let dateTime = self.imageData?.photoTakenDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            let photoTakenDate = dateFormatter.string(from: dateTime)
            self._photoTakenDateString = photoTakenDate
            return photoTakenDate
        }else{
            self._photoTakenDateString = ""
            return ""
        }
    }
    
    func photoTakenTime(forceUpdate:Bool = false) -> String {
        guard _photoTakenTimeString == "" || forceUpdate else {return self._photoTakenTimeString}
        if let dateTime = self.imageData?.photoTakenDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let photoTakenDate = dateFormatter.string(from: dateTime)
            self._photoTakenTimeString = photoTakenDate
            return photoTakenDate
        }else{
            self._photoTakenTimeString = ""
            return ""
        }
    }
}
