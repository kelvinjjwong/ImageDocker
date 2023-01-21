//
//  StandaloneMetaInfoStore.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/31.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import ImageIO


// CFString to (NS)*String casts
let pixelHeight = kCGImagePropertyPixelHeight as NSString
let pixelWidth = kCGImagePropertyPixelWidth as NSString

let createThumbnailWithTransform = kCGImageSourceCreateThumbnailWithTransform as String
let createThumbnailFromImageAlways = kCGImageSourceCreateThumbnailFromImageAlways as String
let createThumbnailFromImageIfAbsent = kCGImageSourceCreateThumbnailFromImageIfAbsent as String
let thumbnailMaxPixelSize = kCGImageSourceThumbnailMaxPixelSize as String

let exifDictionary = kCGImagePropertyExifDictionary as NSString
let exifDateTimeOriginal = kCGImagePropertyExifDateTimeOriginal as String

let GPSDictionary = kCGImagePropertyGPSDictionary as NSString
let GPSStatus = kCGImagePropertyGPSStatus as String
let GPSLatitude = kCGImagePropertyGPSLatitude as String
let GPSLatitudeRef = kCGImagePropertyGPSLatitudeRef as String
let GPSLongitude = kCGImagePropertyGPSLongitude as String
let GPSLongitudeRef = kCGImagePropertyGPSLongitudeRef as String
let GPSAltitude = kCGImagePropertyGPSAltitude as String
let GPSAltitudeRef = kCGImagePropertyGPSAltitudeRef as String
let GPSSpeed = kCGImagePropertyGPSSpeed as String
let GPSArea = kCGImagePropertyGPSAreaInformation as String
let GPSDateUTC = kCGImagePropertyGPSDateStamp as String
let GPSTimestampUTC = kCGImagePropertyGPSTimeStamp as String

let LensMake = kCGImagePropertyExifLensMake as String
let LensModel = kCGImagePropertyExifLensModel as String
let LensSerialNumber = kCGImagePropertyExifLensSerialNumber as String
let TIFFDictionary = kCGImagePropertyTIFFDictionary as NSString
let CameraMake = kCGImagePropertyTIFFMake as String
let CameraModel = kCGImagePropertyTIFFModel as String
let CameraSerialNumber = kCGImagePropertyExifBodySerialNumber as String
let Software = kCGImagePropertyTIFFSoftware as String
let SoftwareDateTime = kCGImagePropertyTIFFDateTime as String
let ColorModel = kCGImagePropertyColorModel as String
let ColorModelProfile = kCGImagePropertyProfileName as String
let CameraOrientation = kCGImagePropertyOrientation as String


class MetaInfoHolder: MetaInfoStoreDelegate {
    
    var metaInfo:[MetaInfo] = [MetaInfo]()
    
    func setMetaInfo(_ info:MetaInfo?){
        guard info != nil && info?.value != nil else {return}
        setMetaInfo(info, ifNotExists: false)
    }
    
    func setMetaInfo(_ info:MetaInfo?, ifNotExists: Bool){
        guard info != nil && info?.value != nil else {return}
        let info = info!
        if info.value == nil || info.value == "" || info.value == "null" {return}
        var exists:Int = 0
        for exist:MetaInfo in self.metaInfo {
            if exist.category == info.category && exist.subCategory == info.subCategory && exist.title == info.title {
                if ifNotExists == false {
                    exist.value = info.value
                }
                exists = 1
            }
        }
        if exists == 0 {
            self.metaInfo.append(info)
        }
    }
    
    func updateMetaInfoView() {
        // do nothing
    }
    
    func getMeta(category:String, subCategory:String = "", title:String) -> String? {
        for meta in metaInfo {
            if meta.category == category && meta.subCategory == subCategory && meta.title == title {
                return meta.value
            }
        }
        return nil
    }
    
    func getInfos() -> [MetaInfo] {
        return self.metaInfo
    }
    
    func clearInfos() {
        self.metaInfo.removeAll()
    }
    
    func sort(by categorySequence:[String]) {
        let originalArray = self.metaInfo
        
        var arrays = [String : [MetaInfo]]()
        
        for meta:MetaInfo in originalArray {
            if var arr:[MetaInfo] = arrays[meta.category]{
                arr.append(meta)
                arrays.updateValue(arr, forKey: meta.category)
            }else{
                var arr:[MetaInfo] = [MetaInfo]()
                arr.append(meta)
                arrays.updateValue(arr, forKey: meta.category)
            }
        }
        
        var sortedArray = [MetaInfo]()
        
        for key in categorySequence {
            if let arr:[MetaInfo] = arrays[key] {
                sortedArray.append(contentsOf: arr)
            }
        }
        
        self.metaInfo = sortedArray
        
    }
}

class MetaInfoReader {
    
    public static func getMeta(info:[MetaInfo], category:String, subCategory:String = "", title:String) -> String? {
        for meta in info {
            if meta.category == category && meta.subCategory == subCategory && meta.title == title {
                return meta.value
            }
        }
        return nil
    }
}



