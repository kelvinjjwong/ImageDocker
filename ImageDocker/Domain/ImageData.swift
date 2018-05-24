//
//  ImageData.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/22.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import Cocoa
import AppKit
import CoreLocation
import SwiftyJSON

// A shorter name for a type I'll often use
typealias Coord = CLLocationCoordinate2D

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

final class ImageData {

    // MARK: instance variables
    
    let url: URL                // URL of the image
    let metaInfoStore:MetaInfoStoreDelegate
    
    var name: String? {
        return url.lastPathComponent
    }
    
    // image date/time created
    var date: String = ""
    var timeZone: TimeZone?
    var dateFromEpoch: TimeInterval {
        let format = DateFormatter()
        format.dateFormat = "yyyy:MM:dd HH:mm:ss"
        format.timeZone = TimeZone.current
        if let convertedDate = format.date(from: date) {
            return convertedDate.timeIntervalSince1970
        }
        return 0
    }
    
    // image location
    var location: Coord?
    var locationBD09: Coord?
    var originalLocation: Coord?
    
    lazy var image: NSImage = self.loadImagePreview()
    
    /// The string representation of the location of an image for copy and paste.
    /// The representation of no location is an empty string.
    var stringRepresentation: String {
        if let location = location {
            return "\(location.latitude) \(location.longitude)"
        } else {
            return ""
        }
    }
    
    var isPhoto:Bool = false
    var isVideo:Bool = false
    var hasCoordinate:Bool = false
    
    var isStandalone:Bool = false
    var isLoadedExif:Bool = false
    var isRecognizedDateTimeFromFilename:Bool = false
    
    // MARK: Init
    
    /// instantiate an instance of the class
    /// - Parameter url: image file this instance represents
    ///
    /// Extract geo location metadata and build a preview image for
    /// the given URL.  If the URL isn't recognized as an image mark this
    /// instance as not being valid.
    
    init(url: URL, metaInfoStore:MetaInfoStoreDelegate? = nil) {
        self.url = url
        
        if metaInfoStore == nil {
            self.metaInfoStore = StandaloneMetaInfoStore()
            isStandalone = true
        }else{
            self.metaInfoStore = metaInfoStore!
        }
        
        self.metaInfoStore.setMetaInfo(MetaInfo(category: "System", subCategory: "File", title: "Filename", value: url.lastPathComponent))
        self.metaInfoStore.setMetaInfo(MetaInfo(category: "System", subCategory: "File", title: "Full path", value: url.path.replacingOccurrences(of: url.lastPathComponent, with: "")))
        
        if url.lastPathComponent.split(separator: Character(".")).count > 1 {
            let fileExt:String = (url.lastPathComponent.split(separator: Character(".")).last?.lowercased())!
            if fileExt == "jpg" || fileExt == "jpeg" {
                isPhoto = true
            }
            if fileExt == "mov" || fileExt == "mp4" || fileExt == "mpeg" {
                isVideo = true
            }
            
            if isPhoto {
                loadImageMetaData()
            }
            originalLocation = location
        }
        
        // huawei pictures
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_([0-9]{3})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})-([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        
        // file copied
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]\\.([A-Za-z0-9]{3}+)")
        
        // file compressed by wechat
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_comps\\.([A-Za-z0-9]{3}+)")
        // file compressed by wechat
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[A-Za-z0-9]{32}_comps\\.([A-Za-z0-9]{3}+)")
        
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_BURST[0-9]{3}\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_BURST[0-9]{3}_COVER\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("IMG_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]{3}_COVER\\.([A-Za-z0-9]{3}+)")
        
        // screenshots
        self.recognizeDateTimeFromFilename("Screenshot_([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("Screenshot_([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2})-([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("Screenshot_([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})-([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("pt([0-9]{4})_([0-9]{2})_([0-9]{2})_([0-9]{2})_([0-9]{2})_([0-9]{2})_([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        
        // from another camera models
        self.recognizeDateTimeFromFilename("YP([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]+\\.([A-Za-z0-9]{3}+)")
        self.recognizeDateTimeFromFilename("YP([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})_[0-9]+_[0-9]+\\.([A-Za-z0-9]{3}+)")
        
        // qqzone video
        self.recognizeDateTimeFromFilename("QQ空间视频_([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        
        // huawei video
        self.recognizeDateTimeFromFilename("VID_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\\.([A-Za-z0-9]{3}+)")
        
        // huawei honor6 video
        self.recognizeUnixTimeFromFilename("([0-9]{13})\\.([A-Za-z0-9]{3}+)")
        
        // file exported by wechat
        self.recognizeUnixTimeFromFilename("mmexport([0-9]{13})\\.([A-Za-z0-9]{3}+)")
        self.recognizeUnixTime2FromFilename("mmexport([0-9]{13})_([0-9]+)_[0-9]+\\.([A-Za-z0-9]{3}+)")
        
        // file compressed by wechat
        self.recognizeUnixTimeFromFilename("mmexport([0-9]{13})_comps\\.([A-Za-z0-9]{3}+)")
        
        // file copied
        self.recognizeUnixTimeFromFilename("mmexport([0-9]{13})\\([0-9]+\\)\\.([A-Za-z0-9]{3}+)")
    }
    
    private func recognizeDateTimeFromFilename(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.lastPathComponent.matches(for: pattern)
        if parts.count > 0 {
            let dateTime:String = "\(parts[1]):\(parts[2]):\(parts[3]) \(parts[4]):\(parts[5]):\(parts[6])"
            self.metaInfoStore.setMetaInfo(MetaInfo(category: "DateTime", title: "From Filename", value: dateTime))
            isRecognizedDateTimeFromFilename = true
        }
    }
    
    private func recognizeUnixTimeFromFilename(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.lastPathComponent.matches(for: pattern)
        if parts.count > 0 {
            let timestamp:String = "\(parts[1])"
            let dateTime = self.convertUnixTimestampToDateString(timestamp)
            self.metaInfoStore.setMetaInfo(MetaInfo(category: "DateTime", title: "From Filename", value: dateTime))
            isRecognizedDateTimeFromFilename = true
        }
    }
    
    private func recognizeUnixTime2FromFilename(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.lastPathComponent.matches(for: pattern)
        if parts.count > 0 {
            let timestamp:String = "\(parts[1]).\(parts[2])"
            let dateTime = self.convertUnixTimestampToDateString(timestamp)
            self.metaInfoStore.setMetaInfo(MetaInfo(category: "DateTime", title: "From Filename", value: dateTime))
            isRecognizedDateTimeFromFilename = true
        }
    }
    
    private func convertUnixTimestampToDateString(_ timestamp:String, dateFormat:String = "yyyy:MM:dd HH:mm:ss") -> String {
        let date = NSDate(timeIntervalSince1970: Double(timestamp)!/1000 + 8*60*60) // GMT+8
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateTime = dateFormatter.string(from: date as Date)
        return dateTime
    }
    
    /// remove the symbolic link created in the sandboxed document directory
    /// during instance initialization
    deinit {
    }
    
    func getMeta(category:String, subCategory:String = "", title:String) -> String? {
        return self.metaInfoStore.getMeta(category: category, subCategory: subCategory, title: title)
    }
    
    // MARK: set/revert latitude and longitude for an image
    
    /// set the latitude and longitude of an image
    /// - Parameter location: the new coordinates
    ///
    /// The location may be set to nil to delete location information from
    /// an image.
    func setLocation(_ location: Coord?) {
        self.location = location
        setTimeZoneFor(location)
    }
    
    /// restore latitude and longitude to their initial values
    ///
    /// Image location is restored to the value when location information
    /// was last saved. If the image has not been saved the restored values
    /// will be those in the image when first read.
    func revertLocation() {
        location = originalLocation
        setTimeZoneFor(location)
    }
    
    // Get the time zone for a given location
    private func setTimeZoneFor(_ location: Coord?) {
        timeZone = nil
        if #available(OSX 10.11, *) {
            if let location = location {
                let coder = CLGeocoder();
                let loc = CLLocation(latitude: location.latitude,
                                     longitude: location.longitude)
                coder.reverseGeocodeLocation(loc) {
                    (placemarks, error) in
                    let place = placemarks?.last
                    self.timeZone = place?.timeZone
                }
            }
        }
    }
    
    /// Load an image thumbnail
    /// - Returns: NSImage of the thumbnail
    ///
    /// If image propertied can not be accessed or if needed properties
    /// do not exist the file is assumed to be a non-image file and a zero
    /// sized empty image is returned.
    private func loadImagePreview() -> NSImage {
        var image = NSImage(size: NSMakeRect(0, 0, 0, 0).size)
        if self.isVideo == true { return image }
        
        guard let imgRef = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return image
        }
        // Create a "preview" of the image. If the image is larger than
        // 512x512 constrain the preview to that size.  512x512 is an
        // arbitrary limit.   Preview generation is used to work around a
        // performance hit when using large raw images
        let maxDimension = 512
        var imgOpts: [String: AnyObject] = [
            createThumbnailWithTransform : kCFBooleanTrue,
            createThumbnailFromImageIfAbsent : kCFBooleanTrue,
            thumbnailMaxPixelSize : maxDimension as AnyObject
        ]
        var checkSize = true
        repeat {
            if let imgPreview = CGImageSourceCreateThumbnailAtIndex(imgRef, 0, imgOpts as NSDictionary) {
                // Create an NSImage from the preview
                let imgHeight = CGFloat(imgPreview.height)
                let imgWidth = CGFloat(imgPreview.width)
                if imgOpts[createThumbnailFromImageAlways] == nil &&
                    imgHeight < 512 && imgWidth < 512 {
                    // thumbnail too small.   Build a larger thumbnail
                    imgOpts[createThumbnailFromImageIfAbsent] = nil
                    imgOpts[createThumbnailFromImageAlways] = kCFBooleanTrue
                    continue
                }
                let imgRect = NSMakeRect(0.0, 0.0, imgWidth, imgHeight)
                image = NSImage(size: imgRect.size)
                image.lockFocus()
                if let currentContext = NSGraphicsContext.current {
                    let context = currentContext.cgContext
                    context.draw(imgPreview, in: imgRect)
                }
                image.unlockFocus()
            }
            checkSize = false
        } while checkSize
        return image
    }
    
    // MARK: extract image metadata
    
    /// obtain image metadata
    /// - Returns: true if successful
    ///
    /// If image propertied can not be accessed or if needed properties
    /// do not exist the file is assumed to be a non-image file
    private func loadImageMetaData() {
        if self.isVideo == true { return }
        
        guard let imgRef = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            print("Failed CGImageSourceCreateWithURL \(url)")
            return
        }
        
        // grab the image properties and extract height and width
        // if there are no image properties there is nothing to do.
        guard let imgProps = CGImageSourceCopyPropertiesAtIndex(imgRef, 0, nil) as NSDictionary? else {
            return
        }
        
        if let pxWidth = imgProps[pixelWidth] as? Int,
            let pxHeight = imgProps[pixelHeight] as? Int{
            metaInfoStore.setMetaInfo(MetaInfo(category: "System", subCategory: "", title: "Size", value: "\(pxWidth) x \(pxHeight)"))
        }
        
        if let tiffData = imgProps[TIFFDictionary] as? [String: AnyObject] {
            if let cameraMake = tiffData[CameraMake] as? String {
                metaInfoStore.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Manufacture", value: cameraMake))
            }
            if let cameraModel = tiffData[CameraModel] as? String {
                metaInfoStore.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Model", value: cameraModel))
            }
        }
        
        // extract image date/time created
        if let exifData = imgProps[exifDictionary] as? [String: AnyObject] {
            if let cameraSerialNo = exifData[CameraSerialNumber] as? String {
                metaInfoStore.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Serial Number", value: cameraSerialNo))
            }
            if let lensMake = exifData[LensMake] as? String {
                metaInfoStore.setMetaInfo(MetaInfo(category: "Lens", subCategory: "", title: "Manufacture", value: lensMake))
            }
            if let lensModel = exifData[LensModel] as? String {
                metaInfoStore.setMetaInfo(MetaInfo(category: "Lens", subCategory: "", title: "Model", value: lensModel))
            }
            if let lensSerialNo = exifData[LensSerialNumber] as? String {
                metaInfoStore.setMetaInfo(MetaInfo(category: "Lens", subCategory: "", title: "Serial Number", value: lensSerialNo))
            }
        }
        
        if let tiffData = imgProps[TIFFDictionary] as? [String: AnyObject],
            let software = tiffData[Software] as? String {
            metaInfoStore.setMetaInfo(MetaInfo(category: "Software", subCategory: "", title: "Name", value: software))
        }
        
        if let exifData = imgProps[exifDictionary] as? [String: AnyObject],
            let dto = exifData[exifDateTimeOriginal] as? String {
            date = dto
            metaInfoStore.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "DateTimeOriginal", value: date))
        }
        
        if let tiffData = imgProps[TIFFDictionary] as? [String: AnyObject] {
            if let softwareDateTime = tiffData[SoftwareDateTime] as? String {
                metaInfoStore.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "Software Modified", value: softwareDateTime))
            }
        }
        
        if let gpsData = imgProps[GPSDictionary] as? [String: AnyObject],
            let gpsDateUTC = gpsData[GPSDateUTC] as? String,
            let gpsTimeUTC = gpsData[GPSTimestampUTC] as? String{
            metaInfoStore.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "GPS Date", value: "\(gpsDateUTC) \(gpsTimeUTC) UTC"))
        }
        
        if let colorModel = imgProps[ColorModel] as? String {
            metaInfoStore.setMetaInfo(MetaInfo(category: "ColorSpace", subCategory: "", title: "Model", value: colorModel))
        }
        
        if let colorModelProfile = imgProps[ColorModelProfile] as? String {
            metaInfoStore.setMetaInfo(MetaInfo(category: "ColorSpace", subCategory: "", title: "Profile", value: colorModelProfile))
        }
        
        // extract image existing gps info
        if let gpsData = imgProps[GPSDictionary] as? [String: AnyObject] {
            
            // some Leica write GPS tags with a status tag of "V" (void) when no
            // GPS info is available.   If a status tag exists and its value
            // is "V" ignore the GPS data.
            if let status = gpsData[GPSStatus] as? String {
                if status == "V" {
                    return
                }
            }
            
            if let altitude = gpsData[GPSAltitude] as? String,
                let altitudeRef = gpsData[GPSAltitudeRef] as? String {
                metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "", title: "Altitude", value: "\(altitude) \(altitudeRef)"))
            }
            
            if let gpsSpeed = gpsData[GPSSpeed] as? String {
                metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "", title: "Speed", value: gpsSpeed))
            }
            
            if let gpsArea = gpsData[GPSArea] as? String {
                metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "", title: "Area", value: gpsArea))
            }
            if let lat = gpsData[GPSLatitude] as? Double,
                let latRef = gpsData[GPSLatitudeRef] as? String,
                let lon = gpsData[GPSLongitude] as? Double,
                let lonRef = gpsData[GPSLongitudeRef] as? String {
                setCoordinate(latitude: latRef == "N" ? lat : -lat,
                              longitude: lonRef == "E" ? lon : -lon)
            }
        }
    }
    
    func setCoordinate(latitude:Double, longitude:Double){
        guard latitude > 0 && longitude > 0 else {return}
        location = Coord(latitude: latitude, longitude: longitude)
        locationBD09 = location?.fromWGS84toBD09()
        
        metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Latitude (WGS84)", value: String(format: "%3.6f", self.latitude).paddingLeft(12)))
        metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Longitude (WGS84)", value: String(format: "%3.6f", self.longitude).paddingLeft(12)))
        metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Latitude (BD09)", value: String(format: "%3.6f", self.latitudeBaidu).paddingLeft(12)))
        metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Longitude (BD09)", value: String(format: "%3.6f", self.longitudeBaidu).paddingLeft(12)))
        
        hasCoordinate = true
    }
    
    public func loadExif(){
        guard !(isStandalone && isLoadedExif) else {return}
        
        let jsonStr:String = ExifTool.helper.getFormattedExif(url: url)
        print(jsonStr)
        let json:JSON = JSON(parseJSON: jsonStr)
        if json != JSON(NSNull()) {
            metaInfoStore.setMetaInfo(MetaInfo(category: "System", title: "Size", value: json[0]["Composite"]["ImageSize"].description), ifNotExists: true)
            
            metaInfoStore.setMetaInfo(MetaInfo(category: "Camera", title: "ISO", value: json[0]["EXIF"]["ISO"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Camera", title: "ExposureTime", value: json[0]["EXIF"]["ExposureTime"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Camera", title: "Aperture", value: json[0]["EXIF"]["ApertureValue"].description))
            
            
            metaInfoStore.setMetaInfo(MetaInfo(category: "DateTime", title: "FileModifyDate", value: json[0]["File"]["CreateDate"].description))
            
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "Format", value: json[0]["QuickTime"]["MajorBrand"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "CreateDate", value: json[0]["QuickTime"]["CreateDate"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "ModifyDate", value: json[0]["QuickTime"]["ModifyDate"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "TrackCreateDate", value: json[0]["QuickTime"]["TrackCreateDate"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "TrackModifyDate", value: json[0]["QuickTime"]["TrackModifyDate"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "Frame Rate", value: json[0]["QuickTime"]["VideoFrameRate"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "Image Width", value: json[0]["QuickTime"]["ImageWidth"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "Image Height", value: json[0]["QuickTime"]["ImageHeight"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "Duration", value: json[0]["QuickTime"]["Duration"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "Size", value: json[0]["QuickTime"]["MovieDataSize"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "Avg Bitrate", value: json[0]["Composite"]["AvgBitrate"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Video", title: "Rotation", value: json[0]["Composite"]["Rotation"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Audio", title: "Channels", value: json[0]["QuickTime"]["AudioChannels"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Audio", title: "BitsPerSample", value: json[0]["QuickTime"]["AudioBitsPerSample"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Audio", title: "SampleRate", value: json[0]["QuickTime"]["AudioSampleRate"].description))
        }
        
        let jsonStr2:String = ExifTool.helper.getUnformattedExif(url: url)
        let json2:JSON = JSON(parseJSON: jsonStr2)
        
        if json2 != JSON(NSNull()) {
            
            let latitude:String = json2[0]["Composite"]["GPSLatitude"].description
            let longitude:String = json2[0]["Composite"]["GPSLongitude"].description
            
            if latitude != "0" || longitude != "0" {
            
                metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Latitude (WGS84)", value: latitude))
                metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Longitude (WGS84)", value: longitude))
                
                if let lat:Double = json2[0]["Composite"]["GPSLatitude"].double,
                    let lon:Double = json2[0]["Composite"]["GPSLongitude"].double {
                    setCoordinate(latitude: lat, longitude: lon)
                }
            }
        }
        isLoadedExif = true
    }
    
    public func getBaiduLocation(consumer:MetaInfoConsumeDelegate? = nil) {
        if self.latitudeBaidu == 0 || self.longitudeBaidu == 0 {
            if consumer != nil {
                consumer?.consume(self.metaInfoStore.getInfos())
            }
        }else {
            BaiduLocation.queryForAddress(lat: self.latitudeBaidu, lon: self.longitudeBaidu, metaInfoStore: self.metaInfoStore, consumer: consumer)
        }
    }
    
    static let metaCategorySequence:[String] = ["Location", "DateTime", "Camera", "Lens", "EXIF", "Video", "Audio", "Coordinate", "Software", "System"]
}



/// Key-value names for tableview column sorting
extension ImageData {
    @objc var imageName: String {
        return name ?? ""
    }
    @objc var dateTime: Double {
        return dateFromEpoch
    }
    @objc var latitude: Double {
        return location?.latitude ?? 0
    }
    @objc var longitude: Double {
        return location?.longitude ?? 0
    }
    @objc var latitudeBaidu: Double {
        return locationBD09?.latitude ?? 0
    }
    @objc var longitudeBaidu: Double {
        return locationBD09?.longitude ?? 0
    }
    
}

class StandaloneMetaInfoStore: MetaInfoStoreDelegate {
    
    var metaInfo:[MetaInfo] = [MetaInfo]()
    
    func setMetaInfo(_ info:MetaInfo){
        setMetaInfo(info, ifNotExists: false)
    }
    
    func setMetaInfo(_ info:MetaInfo, ifNotExists: Bool){
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

