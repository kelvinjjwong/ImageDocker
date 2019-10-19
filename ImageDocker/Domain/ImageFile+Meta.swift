//
//  ImageFile+Meta.swift
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

let MetaCategorySequence:[String] = ["Location", "DateTime", "Camera", "Lens", "EXIF", "Video", "Audio", "Coordinate", "Software", "System"]

extension ImageFile {
    
    func transformDomainToMetaInfo() {
        if let photoFile = self.imageData {
            if photoFile.imageWidth != 0 && photoFile.imageHeight != 0 {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "System", subCategory: "File", title: "Filename", value: url.lastPathComponent))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "System", subCategory: "File", title: "Full path", value: url.path.replacingOccurrences(of: url.lastPathComponent, with: "")))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "System", subCategory: "", title: "Size", value: "\(photoFile.imageWidth ?? 0) x \(photoFile.imageHeight ?? 0)"))
            }
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Manufacture", value: photoFile.cameraMaker))
            let model = Naming.Camera.recognize(maker: photoFile.cameraMaker ?? "", model: photoFile.cameraModel ?? "")
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Model", value: model))
            
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Software", subCategory: "", title: "Name", value: photoFile.softwareName))
            
            if let imgSrc = photoFile.imageSource {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Software", subCategory: "", title: "Source", value: imgSrc))
            }
            if photoFile.dateTimeFromFilename != nil {
                self.metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "From Filename", value: photoFile.dateTimeFromFilename))
            }
            if photoFile.exifDateTimeOriginal != nil {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "DateTimeOriginal", value: exifDateFormat.string(from: photoFile.exifDateTimeOriginal!)))
            }
            
            if photoFile.exifCreateDate != nil {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "FileCreateDate", value: exifDateFormat.string(from: photoFile.exifCreateDate!)))
            }
            
            if photoFile.exifModifyDate != nil {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "FileModifyDate", value: exifDateFormat.string(from: photoFile.exifModifyDate!)))
            }
            if photoFile.filesysCreateDate != nil {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "FileSysCreateDate", value: exifDateFormat.string(from: photoFile.filesysCreateDate!)))
            }
            if photoFile.softwareModifiedTime != nil {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "Software Modified", value: exifDateFormat.string(from: photoFile.softwareModifiedTime!)))
            }
            metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "GPS Date", value: photoFile.gpsDate))
            
            //print("SET COORD 2: \(photoFile.latitude ?? "") \(photoFile.longitude ?? "") - \(fileName)")
            
            
            
            if photoFile.latitude != nil && photoFile.latitude != "" {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Latitude (WGS84)", value: String(format: "%3.6f", Double(photoFile.latitude!) ?? 0).paddingLeft(12)))
            }
            
            if photoFile.longitude != nil && photoFile.longitude != "" {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Longitude (WGS84)", value: String(format: "%3.6f", Double(photoFile.longitude!) ?? 0).paddingLeft(12)))
            }
            
            if photoFile.latitudeBD != nil && photoFile.latitudeBD != "" {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Latitude (BD09)", value: String(format: "%3.6f", Double(photoFile.latitudeBD!) ?? 0).paddingLeft(12)))
            }
            
            if photoFile.longitudeBD != nil && photoFile.longitudeBD != "" {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Longitude (BD09)", value: String(format: "%3.6f", Double(photoFile.longitudeBD!) ?? 0).paddingLeft(12)))
            }
            
            if photoFile.assignLatitude != nil && photoFile.assignLatitude != "" {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Latitude (WGS84)", value: String(format: "%3.6f", Double(photoFile.assignLatitude!) ?? 0).paddingLeft(12)))
            }
            
            if photoFile.assignLongitude != nil && photoFile.assignLongitude != "" {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Longitude (WGS84)", value: String(format: "%3.6f", Double(photoFile.assignLongitude!) ?? 0).paddingLeft(12)))
            }
            
            if photoFile.assignLatitudeBD != nil && photoFile.assignLatitudeBD != "" {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Latitude (BD09)", value: String(format: "%3.6f", Double(photoFile.assignLatitudeBD!) ?? 0).paddingLeft(12)))
            }
            
            if photoFile.assignLongitudeBD != nil && photoFile.assignLongitudeBD != "" {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Longitude (BD09)", value: String(format: "%3.6f", Double(photoFile.assignLongitudeBD!) ?? 0).paddingLeft(12)))
            }
            
            if isPhoto {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", title: "ISO", value: photoFile.iso))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", title: "ExposureTime", value: photoFile.exposureTime))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", title: "Aperture", value: photoFile.aperture))
            }
            
            
            if self.isVideo {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Format", value: photoFile.videoFormat))
                
                if photoFile.videoCreateDate != nil {
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "VideoCreateDate", value: exifDateFormat.string(from: photoFile.videoCreateDate!)))
                }
                if photoFile.videoModifyDate != nil {
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "VideoModifyDate", value: exifDateFormat.string(from: photoFile.videoModifyDate!)))
                }
                if photoFile.trackCreateDate != nil {
                    //print("TRACK CREATE DATE \(photoFile.trackCreateDate)")
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "TrackCreateDate", value: exifDateFormat.string(from: photoFile.trackCreateDate!)))
                }
                if photoFile.trackModifyDate != nil {
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "TrackModifyDate", value: exifDateFormat.string(from: photoFile.trackModifyDate!)))
                }
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Format", value: photoFile.videoFormat?.description))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Frame Rate", value: photoFile.videoFrameRate?.description))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Image Width", value: photoFile.imageWidth?.description))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Image Height", value: photoFile.imageHeight?.description))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Duration", value: photoFile.videoDuration))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Size", value: photoFile.fileSize))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Avg Bitrate", value: photoFile.videoBitRate))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Rotation", value: photoFile.rotation?.description))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Audio", title: "Channels", value: photoFile.audioChannels?.description))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Audio", title: "BitsPerSample", value: photoFile.videoBitRate))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Audio", title: "SampleRate", value: photoFile.audioRate?.description))
            }
            
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Country", value: photoFile.country))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Province", value: photoFile.province))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "City", value: photoFile.city))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "District", value: photoFile.district))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Street", value: photoFile.street))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "BusinessCircle", value: photoFile.businessCircle))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Address", value: photoFile.address))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Description", value: photoFile.addressDescription))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Suggest Place", value: photoFile.suggestPlace))
            
            
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Country", value: photoFile.assignCountry))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Province", value: photoFile.assignProvince))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "City", value: photoFile.assignCity))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "District", value: photoFile.assignDistrict))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Street", value: photoFile.assignStreet))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "BusinessCircle", value: photoFile.assignBusinessCircle))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Address", value: photoFile.assignAddress))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Description", value: photoFile.assignAddressDescription))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Place", value: photoFile.assignPlace))
            
        }
    }
    
    /// obtain image metadata
    /// - Returns: true if successful
    ///
    /// If image propertied can not be accessed or if needed properties
    /// do not exist the file is assumed to be a non-image file
    internal func loadMetaInfoFromOSX() {
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
            
            if pxWidth != 0 && pxHeight != 0 {
                if self.imageData != nil {
                    self.imageData?.imageWidth = pxWidth
                    self.imageData?.imageHeight = pxHeight
                }
            }
        }
        
        if let tiffData = imgProps[TIFFDictionary] as? [String: AnyObject] {
            let cameraMake = tiffData[CameraMake] as? String ?? ""
            if cameraMake != "" {
                if self.imageData != nil {
                    self.imageData?.cameraMaker = cameraMake
                }
            }
            let cameraModel = tiffData[CameraModel] as? String ?? ""
            if cameraModel != "" {
                if self.imageData != nil {
                    self.imageData?.cameraModel = cameraModel
                }
            }
            
            
        }
        
        // extract image date/time created
        //        if let exifData = imgProps[exifDictionary] as? [String: AnyObject] {
        //            if let cameraSerialNo = exifData[CameraSerialNumber] as? String {
        //                //metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Serial Number", value: cameraSerialNo))
        //            }
        //            if let lensMake = exifData[LensMake] as? String {
        //                //metaInfoHolder.setMetaInfo(MetaInfo(category: "Lens", subCategory: "", title: "Manufacture", value: lensMake))
        //            }
        //            if let lensModel = exifData[LensModel] as? String {
        //                //metaInfoHolder.setMetaInfo(MetaInfo(category: "Lens", subCategory: "", title: "Model", value: lensModel))
        //            }
        //            if let lensSerialNo = exifData[LensSerialNumber] as? String {
        //                //metaInfoHolder.setMetaInfo(MetaInfo(category: "Lens", subCategory: "", title: "Serial Number", value: lensSerialNo))
        //            }
        //        }
        
        if let tiffData = imgProps[TIFFDictionary] as? [String: AnyObject],
            let software = tiffData[Software] as? String {
            if self.imageData != nil {
                self.imageData?.softwareName = software
            }
        }
        
        if let exifData = imgProps[exifDictionary] as? [String: AnyObject],
            let dto = exifData[exifDateTimeOriginal] as? String {
            date = dto
            if self.imageData != nil {
                self.imageData?.exifDateTimeOriginal = exifDateFormat.date(from: date)
            }
        }
        
        if let tiffData = imgProps[TIFFDictionary] as? [String: AnyObject] {
            if let softwareDateTime = tiffData[SoftwareDateTime] as? String {
                if self.imageData != nil {
                    self.imageData?.softwareModifiedTime = exifDateFormat.date(from: softwareDateTime)
                }
            }
        }
        
        if let gpsData = imgProps[GPSDictionary] as? [String: AnyObject],
            let gpsDateUTC = gpsData[GPSDateUTC] as? String,
            let gpsTimeUTC = gpsData[GPSTimestampUTC] as? String{
            if self.imageData != nil {
                self.imageData?.gpsDate = "\(gpsDateUTC) \(gpsTimeUTC) UTC"
            }
        }
        //
        //        if let colorModel = imgProps[ColorModel] as? String {
        //            //metaInfoHolder.setMetaInfo(MetaInfo(category: "ColorSpace", subCategory: "", title: "Model", value: colorModel))
        //        }
        //
        //        if let colorModelProfile = imgProps[ColorModelProfile] as? String {
        //            //metaInfoHolder.setMetaInfo(MetaInfo(category: "ColorSpace", subCategory: "", title: "Profile", value: colorModelProfile))
        //        }
        
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
            
            //            if let altitude = gpsData[GPSAltitude] as? String,
            //                let altitudeRef = gpsData[GPSAltitudeRef] as? String {
            //                //metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "", title: "Altitude", value: "\(altitude) \(altitudeRef)"))
            //            }
            //
            //            if let gpsSpeed = gpsData[GPSSpeed] as? String {
            //                //metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "", title: "Speed", value: gpsSpeed))
            //            }
            //
            //            if let gpsArea = gpsData[GPSArea] as? String {
            //                //metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "", title: "Area", value: gpsArea))
            //            }
            if let lat = gpsData[GPSLatitude] as? Double,
                let latRef = gpsData[GPSLatitudeRef] as? String,
                let lon = gpsData[GPSLongitude] as? Double,
                let lonRef = gpsData[GPSLongitudeRef] as? String {
                
                //print("TRACK COORD 1 \(lat) \(latRef) \(lon) \(lonRef)")
                setCoordinate(latitude: latRef == "N" ? lat : -lat,
                              longitude: lonRef == "E" ? lon : -lon)
            }
        }
    }
    
    public func loadMetaInfoFromDatabase() {
        if self.imageData == nil {
            print("ERROR: IMAGE DATA IS NIL, unable to [loadMetaInfoFromDatabase]")
            return
        }
        let filename:String = url.lastPathComponent
        let path:String = url.path
        let parentPath:String = (url.deletingLastPathComponent().path)
        
        var photoFile = self.imageData!
        //print("loaded PhotoFile for \(filename)")
        
        let now = Date()
        let nowToSeconds = Int(now.timeIntervalSince1970)
        
        location.country = photoFile.assignCountry ?? photoFile.country ?? ""
        location.province = photoFile.assignProvince ?? photoFile.province ?? ""
        location.city = photoFile.assignCity ?? photoFile.city ?? ""
        location.district = photoFile.assignDistrict ?? photoFile.district ?? ""
        location.street = photoFile.assignStreet ?? photoFile.street ?? ""
        location.businessCircle = photoFile.assignBusinessCircle ?? photoFile.businessCircle ?? ""
        location.address = photoFile.assignAddress ?? photoFile.address ?? ""
        location.addressDescription = photoFile.assignAddressDescription ?? photoFile.addressDescription ?? ""
        location.place = photoFile.assignPlace ?? photoFile.suggestPlace ?? photoFile.businessCircle ?? ""
        
        var needSave:Bool = false
        
        var savedCoord = Coord(latitude: Double(photoFile.latitude ?? "0") ?? 0, longitude: Double(photoFile.longitude ?? "0") ?? 0)
        var savedCoordBD = Coord(latitude: Double(photoFile.latitudeBD ?? "0") ?? 0, longitude: Double(photoFile.longitudeBD ?? "0") ?? 0)
        
        // SYNC COORD
        if savedCoord.isNotZero && savedCoordBD.isZero {
            savedCoordBD = savedCoord.fromWGS84toBD09()
            
            photoFile.latitudeBD = savedCoordBD.latitude.description
            photoFile.longitudeBD = savedCoordBD.longitude.description
            
            needSave = true
        } else if savedCoordBD.isNotZero && savedCoord.isZero {
            savedCoord = savedCoordBD.fromBD09toWGS84()
            
            photoFile.latitude = savedCoord.latitude.description
            photoFile.longitude = savedCoord.longitude.description
            
            needSave = true
        }
        
        let coord = Coord(latitude: Double(photoFile.assignLatitude ?? photoFile.latitude ?? "0") ?? 0, longitude: Double(photoFile.assignLongitude ?? photoFile.longitude ?? "0") ?? 0)
        let coordBD = Coord(latitude: Double(photoFile.assignLatitudeBD ?? photoFile.latitudeBD ?? "0") ?? 0, longitude: Double(photoFile.assignLongitudeBD ?? photoFile.longitudeBD ?? "0") ?? 0)
        
        location.setCoordinateWithoutConvert(coord: coord, coordBD: coordBD)
        
        self.imageData = photoFile
        
        if photoFile.lastTimeExtractExif == nil {
            photoFile.lastTimeExtractExif = nowToSeconds
            needSave = true
        }
        
        if needSave {
            print("UPDATE COORD TO NON ZERO")
            ModelStore.default.saveImage(image: photoFile, sharedDB: ModelStore.sharedDBPool())
        }
        
        //print("COORD IS ZERO ? \(location.coordinate?.isZero) - \(fileName)")
        //print("LOCATION LOADED")
    }
    
    public func loadMetaInfoFromExif() {
        guard !(isStandalone && isLoadedExif) else {return}
        
        let now = Date()
        let nowToSeconds = Int(now.timeIntervalSince1970)
        
        let jsonStr:String = ExifTool.helper.getFormattedExif(url: url)
        //print(jsonStr)
        let json:JSON = JSON(parseJSON: jsonStr)
        if json != JSON(NSNull()) {
            //metaInfoHolder.setMetaInfo(MetaInfo(category: "System", title: "Size", value: json[0]["Composite"]["ImageSize"].description), ifNotExists: true)
            
            
            let dateTimeOriginal = json[0]["EXIF"]["DateTimeOriginal"].description
            imageData?.exifDateTimeOriginal = exifDateFormat.date(from: dateTimeOriginal)
            
            //if photoFile?.exifCreateDate == nil {
            imageData?.exifCreateDate = exifDateFormat.date(from: json[0]["EXIF"]["CreateDate"].description)
            //}
            //if photoFile?.exifModifyDate == nil {
            imageData?.exifModifyDate = exifDateFormat.date(from: json[0]["EXIF"]["ModifyDate"].description)
            //}
            //if photoFile?.filesysCreateDate == nil {
            imageData?.filesysCreateDate = exifDateFormat.date(from: json[0]["File"]["FileModifyDate"].description)
            //}
            //if photoFile?.filesysCreateDate == nil {
            imageData?.filesysCreateDate = exifDateFormatWithTimezone.date(from: json[0]["File"]["FileModifyDate"].description)
            //}
            
            
            if isPhoto {
                if json[0]["EXIF"]["ISO"] != JSON.null {
                    imageData?.iso = json[0]["EXIF"]["ISO"].description
                }
                
                if json[0]["EXIF"]["ExposureTime"] != JSON.null {
                    imageData?.exposureTime = json[0]["EXIF"]["ExposureTime"].description
                }
                
                if json[0]["EXIF"]["ApertureValue"] != JSON.null {
                    imageData?.aperture = json[0]["EXIF"]["ApertureValue"].description
                }
            }
            
            if isVideo {
                
                imageData?.videoFormat = json[0]["QuickTime"]["MajorBrand"].description
                
                if json[0]["QuickTime"]["CreateDate"] != "0000:00:00 00:00:00" {
                    imageData?.videoCreateDate = exifDateFormat.date(from: json[0]["QuickTime"]["CreateDate"].description)
                }
                
                if json[0]["QuickTime"]["ModifyDate"] != "0000:00:00 00:00:00" {
                    imageData?.videoModifyDate = exifDateFormat.date(from: json[0]["QuickTime"]["ModifyDate"].description)
                }
                
                if json[0]["QuickTime"]["TrackCreateDate"] != "0000:00:00 00:00:00" {
                    imageData?.trackCreateDate = exifDateFormat.date(from: json[0]["QuickTime"]["TrackCreateDate"].description)
                }
                
                if json[0]["QuickTime"]["TrackModifyDate"] != "0000:00:00 00:00:00" {
                    imageData?.trackModifyDate = exifDateFormat.date(from: json[0]["QuickTime"]["TrackModifyDate"].description)
                }
                
                imageData?.videoFrameRate = json[0]["QuickTime"]["VideoFrameRate"].doubleValue
                
                imageData?.imageWidth = json[0]["QuickTime"]["ImageWidth"].int ?? 0
                
                imageData?.imageHeight = json[0]["QuickTime"]["ImageHeight"].int ?? 0
                
                imageData?.videoDuration = json[0]["QuickTime"]["Duration"].description
                
                imageData?.fileSize = json[0]["QuickTime"]["MovieDataSize"].description
                
                imageData?.videoBitRate = json[0]["Composite"]["AvgBitrate"].description
                
                imageData?.rotation = json[0]["Composite"]["Rotation"].int ?? 0
                
                imageData?.audioChannels = json[0]["QuickTime"]["AudioChannels"].int ?? 0
                
                imageData?.audioBits = json[0]["QuickTime"]["AudioBitsPerSample"].int ?? 0
                
                imageData?.audioRate = json[0]["QuickTime"]["AudioSampleRate"].int ?? 0
            }
            imageData?.updateExifDate = now
            imageData?.lastTimeExtractExif = nowToSeconds
            imageData?.noneExif = false
        }else{
            imageData?.lastTimeExtractExif = nowToSeconds
            imageData?.noneExif = true
        }
        
        let jsonStr2:String = ExifTool.helper.getUnformattedExif(url: url)
        let json2:JSON = JSON(parseJSON: jsonStr2)
        
        if json2 != JSON(NSNull()) {
            
            let latitude:String = json2[0]["Composite"]["GPSLatitude"].description
            let longitude:String = json2[0]["Composite"]["GPSLongitude"].description
            
            if json2[0]["Composite"]["GPSLatitude"] != JSON.null && json2[0]["Composite"]["GPSLongitude"] != JSON.null && latitude != "0" && longitude != "0" && latitude != "null" && longitude != "null" {
                
                //print("SET COORD 3: \(latitude) \(longitude) - \(fileName)")
                
                if let lat:Double = json2[0]["Composite"]["GPSLatitude"].double,
                    let lon:Double = json2[0]["Composite"]["GPSLongitude"].double {
                    setCoordinate(latitude: lat, longitude: lon)
                }
            }
            imageData?.updateExifDate = Date()
            imageData?.lastTimeExtractExif = nowToSeconds
            imageData?.noneExif = false
        }else{
            imageData?.lastTimeExtractExif = nowToSeconds
            imageData?.noneExif = true
        }
        isLoadedExif = true
    }
}
