//
//  ImageFile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//

import Foundation
import Cocoa
import AppKit
import CoreLocation
import SwiftyJSON
import AVFoundation
import GRDB

let MetaCategorySequence:[String] = ["Location", "DateTime", "Camera", "Lens", "EXIF", "Video", "Audio", "Coordinate", "Software", "System"]

class ImageFile {
    
    let exifDateFormat = DateFormatter()
    let exifDateFormatWithTimezone = DateFormatter()
    
  
    //private(set) var thumbnail: NSImage?
    private(set) var fileName: String
    private(set) var url: URL
    private(set) var place:String = "" {
        didSet {
            if imageData != nil && place != "" {
                imageData?.place = place
            }
        }
    }
    var imageData:Image?
    
    private var indicator:Accumulator?
    var collectionViewItem:CollectionViewItem?
    var threaterCollectionViewItem:TheaterCollectionViewItem?
    
    let metaInfoHolder:MetaInfoStoreDelegate
    
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
    
    var hasDuplicates:Bool = false
    var duplicatesKey = ""
    
    // image location
    //var coordinate: Coord?
    //var coordinateBD: Coord?
    var originalCoordinate: Coord?
    var location:Location
    
    lazy var image: NSImage = self.loadPreview()
    
    /// The string representation of the location of an image for copy and paste.
    /// The representation of no location is an empty string.
    var stringRepresentation: String {
        return url.path
    }
    
    var event:String {
        return imageData?.event ?? ""
    }
    
    var isHidden:Bool {
        if imageData == nil {
            return false
        }
        if imageData?.hidden == nil {
            return false
        }
        return imageData?.hidden == true
    }
    
    func hide() {
        if imageData != nil {
            imageData?.hidden = true
            ModelStore.default.saveImage(image: imageData!)
        }
    }
    
    func show() {
        if imageData != nil {
            imageData?.hidden = false
            ModelStore.default.saveImage(image: imageData!)
        }
    }
    
    var isPhoto:Bool = false
    var isVideo:Bool = false
    //var hasCoordinate:Bool = false
    
    var isStandalone:Bool = false
    var isLoadedExif:Bool = false
    var isRecognizedDateTimeFromFilename:Bool = false
    
    // MARK: SAVE IMAGE
    
    func save(){
        if self.imageData != nil {
            ModelStore.default.saveImage(image: self.imageData!)
        }
    }
    
    // MARK: INIT IMAGE
    
    // READ FROM DATABASE
    init (photoFile:Image, indicator:Accumulator? = nil, metaInfoStore:MetaInfoStoreDelegate? = nil, sharedDB:DatabaseWriter? = nil) {
        exifDateFormat.dateFormat = "yyyy:MM:dd HH:mm:ss"
        exifDateFormatWithTimezone.dateFormat = "yyyy:MM:dd HH:mm:ssxxx"
        
        self.indicator = indicator
        self.url = URL(fileURLWithPath: photoFile.path)
        self.fileName = photoFile.filename
        self.location = Location()
        
        let imageType = url.imageType()
        
        self.isPhoto = (imageType == .photo)
        self.isVideo = (imageType == .video)
        
        self.metaInfoHolder = metaInfoStore ?? MetaInfoHolder()
        self.imageData = photoFile
        
        loadMetaInfoFromDatabase()
        
        var needSave:Bool = false
        
        if self.imageData?.dateTimeFromFilename == nil {
            self.recognizeDateTimeFromFilename()
            needSave = true
        }
        
        if self.imageData?.imageSource == nil {
            self.recognizeImageSource()
            needSave = true
        }
        
        let now = Date()
        
        if self.imageData?.updateExifDate == nil || self.imageData?.photoTakenYear == 0 || self.imageData?.photoTakenYear == nil || self.imageData?.photoTakenDate == nil {
            
            // TODO:
            if let datetime = self.imageData?.assignDateTime, datetime < now {
                self.storePhotoTakenDate(dateTime: datetime)
                needSave = true
                
            }else if let datetime = self.imageData?.exifDateTimeOriginal, datetime < now {
                self.storePhotoTakenDate(dateTime: datetime)
                needSave = true
            }else if let datetime = self.imageData?.exifCreateDate, datetime < now {
                self.storePhotoTakenDate(dateTime: datetime)
                needSave = true
            }else if let datetime = self.imageData?.exifModifyDate, datetime < now {
                self.storePhotoTakenDate(dateTime: datetime)
                needSave = true
            }else if let datetime = self.imageData?.exifModifyDate, datetime < now {
                self.storePhotoTakenDate(dateTime: datetime)
                needSave = true
            }else if let datetime = self.imageData?.videoCreateDate, datetime < now {
                self.storePhotoTakenDate(dateTime: datetime)
                needSave = true
            }else if let datetime = self.imageData?.trackCreateDate, datetime < now {
                self.storePhotoTakenDate(dateTime: datetime)
                needSave = true
            }else{
                if self.imageData?.filesysCreateDate == nil { // exif not loaded yet
                    autoreleasepool { () -> Void in
                        self.loadMetaInfoFromOSX()
                        self.loadMetaInfoFromExif()
                        
                        needSave = true
                    }
                }else if let datetime = self.imageData?.filesysCreateDate, datetime < now {
                    self.storePhotoTakenDate(dateTime: datetime)
                    needSave = true
                }
            }
            
        }
        //print("loaded image coordinate: \(self.latitudeBaidu) \(self.longitudeBaidu)")
        var needLoadLocation:Bool = false
        
        // force update location
        if self.imageData != nil && self.imageData!.latitudeBD != "0.0" && self.imageData!.country == "" {
            needLoadLocation = true
        }
        
        //print("coordBD zero? \(self.location.coordinateBD?.isZero) country empty? \(self.location.country == "")")
        if self.location.coordinateBD != nil && self.location.coordinateBD!.isNotZero && self.location.country == "" {
            //print("NEED LOAD LOCATION")
            needLoadLocation = true
        }
        if self.imageData?.updateLocationDate == nil {
            if self.location.coordinate != nil && self.location.coordinate!.isNotZero {
                //BaiduLocation.queryForAddress(lat: self.latitudeBaidu, lon: self.longitudeBaidu, locationConsumer: self)
                //print("COORD NOT ZERO")
                needLoadLocation = true
            }
        }else {
            // if latitude not zero, but location is empty, update location
            if self.location.coordinate != nil && self.location.coordinate!.isNotZero && self.location.country == "" {
                print("COORD NOT ZERO BUT LOCATION IS EMPTY: \(self.url.path)")
                needLoadLocation = true
            }
        }
        if needLoadLocation {
            needSave = true
            autoreleasepool { () -> Void in
                //print("LOADING LOCATION")
                loadLocation(locationConsumer: self)
            }
        }
        if isPhoto || isVideo {
            originalCoordinate = location.coordinate
        }
        
        self.recognizePlace()
        
        if needSave {
            save()
        }
        
        self.transformDomainToMetaInfo()
        
        self.notifyAccumulator(notifyIndicator: true)
    }

    // IMPORT FROM FILE SYSTEM
    init (url: URL, repository:ImageContainer? = nil, indicator:Accumulator? = nil, metaInfoStore:MetaInfoStoreDelegate? = nil, quickCreate:Bool = false, sharedDB:DatabaseWriter? = nil) {
        exifDateFormat.dateFormat = "yyyy:MM:dd HH:mm:ss"
        exifDateFormatWithTimezone.dateFormat = "yyyy:MM:dd HH:mm:ssxxx"
        
        self.indicator = indicator
        self.url = url
        self.fileName = url.lastPathComponent
        self.location = Location()
        
        let imageType = url.imageType()
        
        self.isPhoto = (imageType == .photo)
        self.isVideo = (imageType == .video)
        
        self.metaInfoHolder = metaInfoStore ?? MetaInfoHolder()
        
        if let repo = repository {
        
            self.imageData = ModelStore.default.getOrCreatePhoto(filename: fileName,
                                                             path: url.path,
                                                             parentPath: url.deletingLastPathComponent().path,
                                                             repositoryPath: repo.repositoryPath.withStash(),
                                                             sharedDB:sharedDB)
        }else{
            self.imageData = ModelStore.default.getOrCreatePhoto(filename: fileName,
                                                                 path: url.path,
                                                                 parentPath: url.deletingLastPathComponent().path,
                                                                 repositoryPath: nil,
                                                                 sharedDB:sharedDB)
        }
        
        if !quickCreate {
            print("LOAD META FROM DB BY IMAGE URL")
            loadMetaInfoFromDatabase()
            
            if self.imageData?.updateExifDate == nil || self.imageData?.photoTakenYear == 0 {
                
                autoreleasepool { () -> Void in
                    self.loadMetaInfoFromOSX()
                    self.loadMetaInfoFromExif()
                }
                
            }
            //print("loaded image coordinate: \(self.latitudeBaidu) \(self.longitudeBaidu)")
            if self.imageData?.updateLocationDate == nil {
                if self.location.coordinate != nil && self.location.coordinate!.isNotZero {
                    //BaiduLocation.queryForAddress(lat: self.latitudeBaidu, lon: self.longitudeBaidu, locationConsumer: self)
                    autoreleasepool { () -> Void in
                        loadLocation(locationConsumer: self)
                    }
                }
            }
            if isPhoto || isVideo {
                originalCoordinate = location.coordinate
            }
        }
        
        self.recognizeDateTimeFromFilename()
        
        let photoTakenDate:String? = self.choosePhotoTakenDateFromMetaInfo()
        self.storePhotoTakenDate(dateTime: photoTakenDate)
        //self.setThumbnail(url as URL)
        
        self.recognizeImageSource()
        
        if !quickCreate {
            self.recognizePlace()
            
            save()
        }
        
        self.transformDomainToMetaInfo()
        
        self.notifyAccumulator(notifyIndicator: true)

    }
    
    deinit {
    }
    
    // MARK: THUMBNAIL
    
    lazy var thumbnail:NSImage? = self.setThumbnail(self.url as URL)
    
    private func setThumbnail(_ url:URL) -> NSImage? {
        do {
            let properties = try url.resourceValues(forKeys: [.typeIdentifierKey])
            guard let fileType = properties.typeIdentifier else { return nil }
            if UTTypeConformsTo(fileType as CFString, kUTTypeImage) {
                //DispatchQueue.global().async {
                return self.getThumbnailImageFromPhoto(url)
                //}
            }else if UTTypeConformsTo(fileType as CFString, kUTTypeMovie) {
                //DispatchQueue.global().async {
                return self.getThumbnailImageFromVideo(url)
                //}
            }
        }
        catch {
            print("Unexpected error occured: \(error).")
        }
        return nil
    }
    
    private func getThumbnailImageFromVideo(_ url:URL) -> NSImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return NSImage(cgImage: imageRef, size: NSZeroSize)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    private func getThumbnailImageFromPhoto(_ url:URL) -> NSImage? {
        let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)
        if let imageSource = imageSource {
            guard CGImageSourceGetType(imageSource) != nil else { return nil }
            
            let thumbnailOptions = [
                String(createThumbnailWithTransform): true,
                String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true,
                String(kCGImageSourceThumbnailMaxPixelSize): 180
                ] as [String : Any]
            guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) else { return nil}
            return NSImage(cgImage: thumbnailRef, size: NSSize.zero)
        }
        return nil
    }
    
    func loadNSImage() -> NSImage? {
        if FileManager.default.fileExists(atPath: url.path) {
            return NSImage(byReferencingFile: url.path)
        }else{
            return nil
        }
    }
    
    /// Load an image thumbnail
    /// - Returns: NSImage of the thumbnail
    ///
    /// If image propertied can not be accessed or if needed properties
    /// do not exist the file is assumed to be a non-image file and a zero
    /// sized empty image is returned.
    private func loadPreview() -> NSImage {
        var image = NSImage(size: NSMakeRect(0, 0, 0, 0).size)
        if self.isVideo == true { return image }
        
        var imgSrc:CGImageSource? = CGImageSourceCreateWithURL(url as CFURL, nil)
        if imgSrc == nil {
            if FileManager.default.fileExists(atPath: url.path) {
                if let img = NSImage(byReferencingFile: url.path) {
                    imgSrc = CGImageSourceCreateWithData(img.tiffRepresentation! as CFData , nil)
                }
            }
        }
        if imgSrc == nil {
            return image
        }
        let imgRef = imgSrc!
        
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
//                if orientation == 6 {
//                    image = image.rotate(degrees: 90.0)
//                }else if orientation == 3 {
//                    image = image.rotate(degrees: 180.0)
//                }
                
                image.unlockFocus()
            }
            checkSize = false
        } while checkSize
        return image
    }
    
    // MARK: PROGRESS INDICATOR
    
    private func notifyAccumulator(notifyIndicator:Bool = true){
        
        if notifyIndicator && self.indicator != nil {
            DispatchQueue.main.async {
                let _ = self.indicator?.add("Searching images ...")
            }
            
            
        }
        
    }
    
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
    
    
    private func recognizeDateTimeFromFilename(_ pattern:String){
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
    
    private func recognizeUnixTimeFromFilename(_ pattern:String){
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
    
    private func recognizeUnixTime2FromFilename(_ pattern:String){
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
    
    private func recognizeYearMonthFromPath(_ pattern:String){
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
    
    private func recognizeYearMonthDayFromPath(_ pattern:String){
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
    
    private func convertUnixTimestampToDateString(_ timestamp:String, dateFormat:String = "yyyy:MM:dd HH:mm:ss") -> String {
        let date = NSDate(timeIntervalSince1970: Double(timestamp)!/1000 + 8*60*60) // GMT+8
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let dateTime = dateFormatter.string(from: date as Date)
        return dateTime
    }
    
    
    // MARK: CHOOSE PHOTO TAKEN DATE
    
    private func choosePhotoTakenDateFromMetaInfo() -> String? {
        let now:Date = Date()
        var dt:Date? = nil
        if let photoFile = self.imageData {
            dt = photoFile.assignDateTime ?? photoFile.exifDateTimeOriginal ?? photoFile.exifCreateDate
            
            if (dt == nil || dt! > now) && photoFile.dateTimeFromFilename != nil {
                let dtFilename = exifDateFormat.date(from: photoFile.dateTimeFromFilename!)
                dt = dtFilename
            }
            if (dt == nil || dt! > now) {
                dt = photoFile.softwareModifiedTime ?? photoFile.exifModifyDate ?? photoFile.exifCreateDate
            }
            if (dt == nil || dt! > now) && self.isVideo {
                dt = photoFile.videoCreateDate ?? photoFile.videoModifyDate
            }
        }
        
        var result:String? = nil
        if let dateTime = dt {
            result = exifDateFormat.string(from: dateTime)
        }
        
        
//        var dateTime:String? = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "Assigned")
//
//        if dateTime == nil {
//            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "DateTimeOriginal")
//        }
//        if dateTime == nil {
//            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "From Filename")
//        }
//        if dateTime == nil {
//            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "Software Modified")
//        }
//        if dateTime == nil {
//            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "ExifModifyDate")
//        }
//        if dateTime == nil {
//            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "ExifCreateDate")
//        }
//        if self.isVideo {
//            if dateTime == nil {
//                dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "VideoCreateDate")
//                if dateTime == "0000:00:00 00:00:00" {
//                    dateTime = nil
//                }
//            }
//            if dateTime == nil {
//                dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "TrackCreateDate")
//                if dateTime == "0000:00:00 00:00:00" {
//                    dateTime = nil
//                }
//            }
//        }
        //if dateTime == nil {
        //    dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "FileModifyDate")
        //}
        
        //if dateTime == nil {
        //  self.loadMetaInfoFromExif()
        //}
        return result
    }
    
    private func storePhotoTakenDate(dateTime:String?) {
        if let dt = dateTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            let photoTakenDate = dateFormatter.date(from: dt)
            if let ptd = photoTakenDate {
                storePhotoTakenDate(dateTime: ptd)
            }
        }
    }
    
    private func storePhotoTakenDate(dateTime photoTakenDate:Date){
        
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
    
    // singleton
    private var _photoTakenDateString:String = ""
    
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
    
    // singleton
    private var _photoTakenTimeString:String = ""
    
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
    
    // MARK: ASSIGN
    
    func assignDate(date:Date) {
        if imageData != nil {
            imageData?.assignDateTime = date
            imageData?.updateDateTimeDate = Date()
        }
        
        let photoTakenDate:String? = self.choosePhotoTakenDateFromMetaInfo()
        self.storePhotoTakenDate(dateTime: photoTakenDate)
        
        self.transformDomainToMetaInfo()
    }
    
    func assignEvent(event:ImageEvent){
        var event = event
        if imageData != nil {
            imageData?.event = event.name
            
            if event.startDate == nil {
                event.startDate = imageData?.photoTakenDate
            }else {
                if event.startDate! > (imageData?.photoTakenDate)! {
                    event.startDate = imageData?.photoTakenDate
                }
            }
            
            if event.endDate == nil {
                event.endDate = imageData?.photoTakenDate
            }else {
                if event.endDate! < (imageData?.photoTakenDate)! {
                    event.endDate = imageData?.photoTakenDate
                }
            }
            imageData?.updateEventDate = Date()
        }
        self.transformDomainToMetaInfo()
    }
    
    func assignLocation(location:Location){
        //print("location address is \(location.address)")
        //print("location addressDesc is \(location.addressDescription)")
        //print("location place is \(location.place)")
        
        if imageData != nil {
            //print("photo file not nil")
            imageData?.assignLatitude = location.latitude?.description
            imageData?.assignLongitude = location.longitude?.description
            imageData?.assignLatitudeBD = location.latitudeBD?.description
            imageData?.assignLongitudeBD = location.longitudeBD?.description
            
            imageData?.assignCountry = location.country
            imageData?.assignProvince = location.province
            imageData?.assignCity = location.city
            imageData?.assignDistrict = location.district
            imageData?.assignStreet = location.street
            imageData?.assignBusinessCircle = location.businessCircle
            imageData?.assignAddress = location.address
            imageData?.assignAddressDescription = location.addressDescription
            imageData?.assignPlace = location.place
            
            imageData?.updateLocationDate = Date()
        }
        self.location = location
        self.recognizePlace()
        
        self.transformDomainToMetaInfo()
    }
    
    // MARK: LOAD META INFO
    
    func transformDomainToMetaInfo() {
        if let photoFile = self.imageData {
            if photoFile.imageWidth != 0 && photoFile.imageHeight != 0 {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "System", subCategory: "File", title: "Filename", value: url.lastPathComponent))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "System", subCategory: "File", title: "Full path", value: url.path.replacingOccurrences(of: url.lastPathComponent, with: "")))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "System", subCategory: "", title: "Size", value: "\(photoFile.imageWidth ?? 0) x \(photoFile.imageHeight ?? 0)"))
            }
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Manufacture", value: photoFile.cameraMaker))
            let model = CameraModelRecognizer.recognize(maker: photoFile.cameraMaker ?? "", model: photoFile.cameraModel ?? "")
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Model", value: model))
            
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Software", subCategory: "", title: "Name", value: photoFile.softwareName))
            
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
    private func loadMetaInfoFromOSX() {
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
        if needSave {
            print("UPDATE COORD TO NON ZERO")
            ModelStore.default.saveImage(image: photoFile, sharedDB: ModelStore.sharedDBPool())
        }

        //print("COORD IS ZERO ? \(location.coordinate?.isZero) - \(fileName)")
        //print("LOCATION LOADED")
    }
    
    public func loadMetaInfoFromExif() {
        guard !(isStandalone && isLoadedExif) else {return}
        
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
            imageData?.updateExifDate = Date()
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
        }
        isLoadedExif = true
    }
    
    // MARK: RECOGNIZE PLACE
    
    func recognizePlace() {
        var prefix:String = ""
        
        var country = ""
        var city = ""
        var district = ""
        var place = ""
        if let photoFile = self.imageData {
            country = photoFile.assignCountry ?? photoFile.country ?? ""
            city = photoFile.assignCity ?? photoFile.city ?? ""
            city = city.replacingOccurrences(of: "特别行政区", with: "")
            district = photoFile.assignDistrict ?? photoFile.district ?? ""
            place = photoFile.assignPlace ?? photoFile.suggestPlace ?? photoFile.businessCircle ?? ""
            place = place.replacingOccurrences(of: "特别行政区", with: "")
        }
        if country == "中国" {
            if city != "" && city.reversed().starts(with: "市") {
                city = city.replacingOccurrences(of: "市", with: "")
            }
            prefix = "\(city)"
            
            if city == "佛山" && district == "顺德区" {
                prefix = "顺德"
            }
        }
        if place != "" {
            if place.starts(with: prefix) {
                self.place = place
            }else {
                self.place = "\(prefix)\(place)"
            }
        }else{
            self.place = ""
        }
    }
    
    // MARK: LOAD LOCATION
    
    func setCoordinate(latitude:Double, longitude:Double){
        guard latitude > 0 && longitude > 0 else {return}
        
        //print("SET COORD 1: \(latitude) \(longitude) - \(fileName)")
        location.coordinate = Coord(latitude: latitude, longitude: longitude)
        
        if self.imageData != nil {
            if self.location.coordinate != nil && self.location.coordinate?.latitude != nil && self.location.coordinate?.longitude != nil {
                self.imageData?.latitude = "\(self.location.coordinate?.latitude ?? 0)"
                self.imageData?.longitude = "\(self.location.coordinate?.longitude ?? 0)"
            }
            if self.location.coordinateBD != nil && self.location.coordinateBD?.latitude != nil && self.location.coordinateBD?.longitude != nil {
                self.imageData?.latitudeBD = "\(self.location.coordinateBD?.latitude ?? 0)"
                self.imageData?.longitudeBD = "\(self.location.coordinateBD?.longitude ?? 0)"
            }
        }
        
        //hasCoordinate = true
    }
    
    public func loadLocation(locationConsumer:LocationConsumer? = nil, textConsumer:LocationConsumer? = nil) {
        if location.address != "" && location.coordinate != nil && location.coordinate!.isNotZero {
            //print("\(self.fileName) METAINFO.address: \(address ?? "")")
            //print("\(self.fileName) LOCATION.address: \(location?.address ?? "")")
            print("LOAD LOCATION 2 FROM ImageFile.location - \(fileName)")
            if locationConsumer != nil {
                //print("\(self.fileName) getting location from meta by location consumer")
                locationConsumer?.consume(location: self.location)
            }
            if textConsumer != nil {
                //print("\(self.fileName) getting location from meta by text consumer")
                textConsumer?.consume(location: self.location)
            }
        }else {
            if location.coordinateBD != nil && location.coordinateBD!.isNotZero {
                //print("------")
                //print("\(self.fileName) calling baidu location")
                print("LOAD LOCATION 2 FROM Baidu WebService - \(fileName) - \(self.location.coordinateBD?.latitude) \(self.location.coordinateBD?.longitude)")
                BaiduLocation.queryForAddress(coordinateBD: self.location.coordinateBD!, locationConsumer: locationConsumer ?? self, textConsumer: textConsumer)
            }else{
                print("LOAD LOCATION 3 FROM ImageFile.location - \(fileName)")
                if locationConsumer != nil {
                    //print("\(self.fileName) getting location from meta by location consumer")
                    locationConsumer?.consume(location: self.location)
                }
                if textConsumer != nil {
                    //print("\(self.fileName) getting location from meta by text consumer")
                    textConsumer?.consume(location: self.location)
                }
            }
        }
    }
    
}

// MARK: LOCATION CONSUMER
extension ImageFile : LocationConsumer {
    func consume(location: Location) {
        
        //self.location = location
        self.location.country = location.country
        self.location.province = location.province
        self.location.city = location.city
        self.location.district = location.district
        self.location.businessCircle = location.businessCircle
        self.location.street = location.street
        self.location.address = location.address
        self.location.addressDescription = location.addressDescription
        self.location.place = location.place
        
        if imageData != nil {
            
            imageData?.country = location.country
            imageData?.province = location.province
            imageData?.city = location.city
            imageData?.district = location.district
            imageData?.street = location.street
            imageData?.businessCircle = location.businessCircle
            imageData?.address = location.address
            imageData?.addressDescription = location.addressDescription
            imageData?.suggestPlace = location.place
        }
        
        self.recognizePlace()
        
        imageData?.updateLocationDate = Date()
        
        print("UPDATE LOCATION for image \(url.path)")
        save()
        
    }
    
    func alert(status: Int, message: String, popup: Bool) {
        print("\(status) : \(message)")
    }
    
    
}

// MARK: HELPER

enum ImageType : Int {
    case photo
    case video
    case other
}

extension URL {
    
    func imageType() -> ImageType {
        var type:ImageType = .other
        
        if lastPathComponent.split(separator: Character(".")).count > 1 {
            let fileExt:String = (lastPathComponent.split(separator: Character(".")).last?.lowercased())!
            if fileExt == "jpg" || fileExt == "jpeg" || fileExt == "png" {
                type = .photo
            }else if fileExt == "mov" || fileExt == "mp4" || fileExt == "mpeg" {
                type = .video
            }
        }
        
        if type == .other {
            do {
                let properties = try self.resourceValues(forKeys: [.typeIdentifierKey])
                guard let fileType = properties.typeIdentifier else { return type }
                if UTTypeConformsTo(fileType as CFString, kUTTypeImage) {
                    type = .photo
                }else if UTTypeConformsTo(fileType as CFString, kUTTypeMovie) {
                    type = .video
                }
            }
            catch {
                print("Unexpected error occured when recognizing image type: \(error).")
            }
        }
        
        return type
    }
}
