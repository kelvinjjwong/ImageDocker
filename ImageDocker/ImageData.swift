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

final class ImageData: NSObject {

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
    
    var validImage = false  // does URL point to a valid image file?
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
    var isVideo:Bool = true
    
    // MARK: Init
    
    /// instantiate an instance of the class
    /// - Parameter url: image file this instance represents
    ///
    /// Extract geo location metadata and build a preview image for
    /// the given URL.  If the URL isn't recognized as an image mark this
    /// instance as not being valid.
    init(url: URL, metaInfoStore:MetaInfoStoreDelegate, video:Bool = false) {
        // create a symlink for the URL in our sandbox
        self.metaInfoStore = metaInfoStore
        self.isVideo = video
        self.url = url
        super.init()
        metaInfoStore.setMetaInfo(MetaInfo(category: "System", subCategory: "File", title: "Filename", value: url.lastPathComponent))
        metaInfoStore.setMetaInfo(MetaInfo(category: "System", subCategory: "File", title: "Full path", value: url.path.replacingOccurrences(of: url.lastPathComponent, with: "")))
        
        validImage = loadImageMetaData()
        originalLocation = location
        
        
    }
    
    /// remove the symbolic link created in the sandboxed document directory
    /// during instance initialization
    deinit {
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
    private func loadImageMetaData() -> Bool {
        if self.isVideo == true { return false }
        
        guard let imgRef = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            print("Failed CGImageSourceCreateWithURL \(url)")
            return false
        }
        
        // grab the image properties and extract height and width
        // if there are no image properties there is nothing to do.
        guard let imgProps = CGImageSourceCopyPropertiesAtIndex(imgRef, 0, nil) as NSDictionary? else {
            return false
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
                    return true
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
        return true
    }
    
    func setCoordinate(latitude:Double, longitude:Double){
        location = Coord(latitude: latitude, longitude: longitude)
        locationBD09 = location?.fromWGS84toBD09()
        
        metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "WGS84", title: "Latitude", value: String(format: "%3.6f", self.latitude).paddingLeft(12)))
        metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "WGS84", title: "Longitude", value: String(format: "%3.6f", self.longitude).paddingLeft(12)))
        metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "BD09", title: "Latitude", value: String(format: "%3.6f", self.latitudeBaidu).paddingLeft(12)))
        metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "BD09", title: "Longitude", value: String(format: "%3.6f", self.longitudeBaidu).paddingLeft(12)))
        
    }
    
    public func loadExif(){
        let jsonStr:String = ExifTool.helper.getFormattedExif(url: url)
        print(jsonStr)
        let json:JSON = JSON(parseJSON: jsonStr)
        if json != JSON(NSNull()) {
            metaInfoStore.setMetaInfo(MetaInfo(category: "System", title: "Size", value: json[0]["Composite"]["ImageSize"].description), ifNotExists: true)
            
            metaInfoStore.setMetaInfo(MetaInfo(category: "Camera", title: "ISO", value: json[0]["EXIF"]["ISO"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Camera", title: "ExposureTime", value: json[0]["EXIF"]["ExposureTime"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Camera", title: "Aperture", value: json[0]["EXIF"]["ApertureValue"].description))
            
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
        print(jsonStr2)
        let json2:JSON = JSON(parseJSON: jsonStr2)
        
        if json2 != JSON(NSNull()) {
            
            metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "WGS84", title: "Latitude", value: json2[0]["Composite"]["GPSLatitude"].description))
            metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "WGS84", title: "Longitude", value: json2[0]["Composite"]["GPSLongitude"].description))
            
            if let lat:Double = json2[0]["Composite"]["GPSLatitude"].double,
                let lon:Double = json2[0]["Composite"]["GPSLongitude"].double {
                setCoordinate(latitude: lat, longitude: lon)
            }
        }
    }
    
    public func getBaiduLocation() {
        
        let urlString:String = BaiduLocation.urlForAddress(lat: latitudeBaidu, lon: longitudeBaidu)
        guard let requestUrl = URL(string:urlString) else { return }
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil,let usableData = data {
                // let jsonString:String = String(data: data!, encoding: String.Encoding.utf8)!
                
                let json = try? JSON(data: usableData)
                let status:String = json!["status"].description
                let message:String = json!["message"].description
                if status != "0" {
                    DispatchQueue.main.async {
                        self.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Status", value: status))
                        self.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Message", value: message))
                        self.metaInfoStore.updateMetaInfoView()
                    }
                }else{
                    
                    let address:String = json!["result"]["formatted_address"].description
                    let businessCircle:String = json!["result"]["business"].description
                    let country:String = json!["result"]["addressComponent"]["country"].description
                    let province:String = json!["result"]["addressComponent"]["province"].description
                    let city:String = json!["result"]["addressComponent"]["city"].description
                    let district:String = json!["result"]["addressComponent"]["district"].description
                    let street:String = json!["result"]["addressComponent"]["street"].description
                    let description:String = json!["result"]["sematic_description"].description
                    
                    if address != "" {
                        DispatchQueue.main.async {
                            self.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Country", value: country))
                            self.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Province", value: province))
                            self.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "City", value: city))
                            self.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "District", value: district))
                            self.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Street", value: street))
                            self.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "BusinessCircle", value: businessCircle))
                            self.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Address", value: address))
                            self.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Description", value: description))
                            self.metaInfoStore.updateMetaInfoView()
                        }
                    }
                }
                
            }
        }
        task.resume()
    }
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

