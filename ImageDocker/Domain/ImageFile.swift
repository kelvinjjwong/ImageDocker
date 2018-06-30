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

let MetaCategorySequence:[String] = ["Location", "DateTime", "Camera", "Lens", "EXIF", "Video", "Audio", "Coordinate", "Software", "System"]

class ImageFile {
    
    let exifDateFormat = DateFormatter()
    
  
    //private(set) var thumbnail: NSImage?
    private(set) var fileName: String
    private(set) var url: URL
    private(set) var place:String = "" {
        didSet {
            if photoFile != nil {
                photoFile!.place = place
            }
        }
    }
    private var photoFile:PhotoFile?
    
    private var indicator:Accumulator?
    var collectionViewItem:CollectionViewItem?
    
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
        return photoFile?.event ?? ""
    }
    
    var isHidden:Bool {
        if photoFile == nil {
            return false
        }
        if photoFile?.hidden == nil {
            return false
        }
        return photoFile?.hidden == true
    }
    
    func hide() {
        if photoFile != nil {
            photoFile?.hidden = true
        }
    }
    
    func show() {
        if photoFile != nil {
            photoFile?.hidden = false
        }
    }
    
    var isPhoto:Bool = false
    var isVideo:Bool = false
    //var hasCoordinate:Bool = false
    
    var isStandalone:Bool = false
    var isLoadedExif:Bool = false
    var isRecognizedDateTimeFromFilename:Bool = false

    init (url: URL, indicator:Accumulator? = nil, metaInfoStore:MetaInfoStoreDelegate? = nil, quickCreate:Bool = false) {
        exifDateFormat.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        self.indicator = indicator
        self.url = url
        self.fileName = url.lastPathComponent
        self.location = Location()
        self.isPhoto = url.isPhoto()
        self.isVideo = url.isVideo()
        
        self.metaInfoHolder = metaInfoStore ?? MetaInfoHolder()
        
        self.photoFile = ModelStore.getOrCreatePhoto(filename: fileName, path: url.path, parentPath: url.deletingLastPathComponent().path)
        
        self.metaInfoHolder.setMetaInfo(MetaInfo(category: "System", subCategory: "File", title: "Filename", value: url.lastPathComponent))
        self.metaInfoHolder.setMetaInfo(MetaInfo(category: "System", subCategory: "File", title: "Full path", value: url.path.replacingOccurrences(of: url.lastPathComponent, with: "")))
        
        if !quickCreate {
            loadMetaInfoFromDatabase()
            
            if self.photoFile?.updateExifDate == nil || self.photoFile?.photoTakenYear == 0 {
                
                autoreleasepool { () -> Void in
                    self.loadMetaInfoFromOSX()
                    self.loadMetaInfoFromExif()
                }
                
            }
            //print("loaded image coordinate: \(self.latitudeBaidu) \(self.longitudeBaidu)")
            if self.photoFile?.updateLocationDate == nil {
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
        
        
        let photoTakenDate:String? = self.choosePhotoTakenDateFromMetaInfo()
        self.storePhotoTakenDate(dateTime: photoTakenDate)
        //self.setThumbnail(url as URL)
        
        if !quickCreate {
            self.recognizePlace()
            
            save()
        }
        self.notifyAccumulator(notifyIndicator: true)

    }
    
    func save(){
        AppDelegate.current.saveModelStore()
    }
    
    lazy var thumbnail:NSImage? = self.setThumbnail(self.url as URL)
    
    /*
    func loadLocation(consumer:LocationConsumer?) {
        if location != nil && location?.address != "" && location?.coordinate != nil && (location?.coordinate?.isNotZero)! {
            if consumer != nil {
                //print("\(fileName) will not get location from Baidu")
                print("LOAD LOCATION 1 FROM ImageFile.location - \(fileName)")
                consumer?.consume(location: self.location ?? Location())
            }
        }else {
            self.getBaiduLocation(locationConsumer: consumer)
            //print("DONE LOAD LOCATION")
        }
    }
 */
    
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
                //print("LOAD LOCATION 2 FROM Baidu WebService - \(fileName) - \(self.location.coordinateBD?.latitude) \(self.location.coordinateBD?.longitude)")
                BaiduLocation.queryForAddress(coordinateBD: self.location.coordinateBD!, locationConsumer: locationConsumer ?? self, textConsumer: textConsumer)
            }else{
                //print("LOAD LOCATION 3 FROM ImageFile.location - \(fileName)")
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
    
    func recognizePlace() {
        var prefix:String = ""
        
        var country = ""
        var city = ""
        var district = ""
        if country == "" {
            country = self.metaInfoHolder.getMeta(category: "Location", subCategory: "Assign", title: "Country") ?? ""
        }
        if city == "" {
            city = self.metaInfoHolder.getMeta(category: "Location", subCategory: "Assign", title: "City") ?? ""
        }
        if district == "" {
            district = self.metaInfoHolder.getMeta(category: "Location", subCategory: "Assign", title: "District") ?? ""
        }
        if country == "" {
            country = self.metaInfoHolder.getMeta(category: "Location", subCategory: "Baidu", title: "Country") ?? ""
        }
        if city == "" {
            city = self.metaInfoHolder.getMeta(category: "Location", subCategory: "Baidu", title: "City") ?? ""
        }
        if district == "" {
            district = self.metaInfoHolder.getMeta(category: "Location", subCategory: "Baidu", title: "District") ?? ""
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
        
        var place:String? = self.metaInfoHolder.getMeta(category: "Location", subCategory: "Assigned", title: "Place")
        if place != nil {
            if prefix != "" && (place?.starts(with: prefix))! {
                self.place = place!
            }else{
                self.place = "\(prefix)\(place!)"
            }
            return
        }
        place = self.metaInfoHolder.getMeta(category: "Location", subCategory: "Baidu", title: "Suggest Place")
        if place != nil {
            if prefix != "" && (place?.starts(with: prefix))! {
                self.place = place!
            }else{
                self.place = "\(prefix)\(place!)"
            }
            return
        }
        place = self.metaInfoHolder.getMeta(category: "Location", subCategory: "Baidu", title: "BusinessCircle")
        if place != nil {
            if prefix != "" && (place?.starts(with: prefix))! {
                self.place = place!
            }else{
                self.place = "\(prefix)\(place!)"
            }
            return
        }
        self.place = ""
        //print("\(self.fileName) recognized place: \(place ?? "")")
    }
    
    func photoTakenDate() -> Date? {
        return self.photoFile?.photoTakenDate
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
        if let dateTime = self.photoFile?.photoTakenDate {
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
        if let dateTime = self.photoFile?.photoTakenDate {
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
    
    private func choosePhotoTakenDateFromMetaInfo() -> String? {
        var dateTime:String? = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "Assigned")
        
        if dateTime == nil {
            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "DateTimeOriginal")
        }
        if dateTime == nil {
            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "From Filename")
        }
        if dateTime == nil {
            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "Software Modified")
        }
        if dateTime == nil {
            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "ExifModifyDate")
        }
        if dateTime == nil {
            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "ExifCreateDate")
        }
        if self.isVideo {
            if dateTime == nil {
                dateTime = self.metaInfoHolder.getMeta(category: "Video", subCategory: "", title: "CreateDate")
                if dateTime == "0000:00:00 00:00:00" {
                    dateTime = nil
                }
            }
            if dateTime == nil {
                dateTime = self.metaInfoHolder.getMeta(category: "Video", subCategory: "", title: "TrackCreateDate")
                if dateTime == "0000:00:00 00:00:00" {
                    dateTime = nil
                }
            }
        }
        if dateTime == nil {
            dateTime = self.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "FileModifyDate")
        }
        
        //if dateTime == nil {
          //  self.loadMetaInfoFromExif()
        //}
        return dateTime
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
        
        self.photoFile?.photoTakenDate = photoTakenDate
        
        let calendar = NSCalendar.current
        let component = calendar.dateComponents([.year, .month, .day, .hour], from: photoTakenDate)
        if self.photoFile != nil && component.year != nil && component.month != nil && component.day != nil && component.hour != nil {
            self.photoFile?.photoTakenYear = Int32(component.year!)
            self.photoFile?.photoTakenMonth = Int32(component.month!)
            self.photoFile?.photoTakenDay = Int32(component.day!)
            self.photoFile?.photoTakenHour = Int32(component.hour!)
            self.photoFile?.updatePhotoTakenDate = Date()
        }
    }
    
    private func notifyAccumulator(notifyIndicator:Bool = true){
        
        if notifyIndicator && self.indicator != nil {
            DispatchQueue.main.async {
                let _ = self.indicator?.add("Searching images ...")
            }
            
            
        }
        
    }
    
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
                String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true,
                String(kCGImageSourceThumbnailMaxPixelSize): 180
                ] as [String : Any]
            guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) else { return nil}
            return NSImage(cgImage: thumbnailRef, size: NSSize.zero)
        }
        return nil
    }
    
    func assignDate(date:Date) {
        let dateString:String = exifDateFormat.string(from: date)
        metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "Assigned", value: dateString))
        if photoFile != nil {
            photoFile?.assignDateTime = date
            photoFile?.updateDateTimeDate = Date()
        }
        
        let photoTakenDate:String? = self.choosePhotoTakenDateFromMetaInfo()
        self.storePhotoTakenDate(dateTime: photoTakenDate)
        
    }
    
    func assignEvent(event:PhotoEvent){
        if photoFile != nil {
            photoFile?.event = event.name ?? ""
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Event", subCategory: "", title: "Assigned", value: event.name ?? ""))
            
            if event.startDate == nil {
                event.startDate = photoFile?.photoTakenDate
            }else {
                if event.startDate! > (photoFile?.photoTakenDate)! {
                    event.startDate = photoFile?.photoTakenDate
                }
            }
            
            if event.endDate == nil {
                event.endDate = photoFile?.photoTakenDate
            }else {
                if event.endDate! < (photoFile?.photoTakenDate)! {
                    event.endDate = photoFile?.photoTakenDate
                }
            }
            photoFile?.updateEventDate = Date()
            
        }
    }
    
    func assignLocation(location:Location){
        //print("location address is \(location.address)")
        //print("location addressDesc is \(location.addressDescription)")
        //print("location place is \(location.place)")
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Latitude (WGS84)", value: (location.latitude?.description)!))
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Longitude (WGS84)", value: (location.longitude?.description)!))
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Latitude (BD09)", value: (location.latitudeBD?.description)!))
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Longitude (BD09)", value: (location.longitudeBD?.description)!))
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Address", value: location.address))
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Description", value: location.addressDescription))
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Place", value: location.place))
        
        if photoFile != nil {
            //print("photo file not nil")
            photoFile?.assignLatitude = location.latitude?.description
            photoFile?.assignLongitude = location.longitude?.description
            photoFile?.assignLatitudeBD = location.latitudeBD?.description
            photoFile?.assignLongitudeBD = location.longitudeBD?.description
            photoFile?.assignAddress = location.address
            photoFile?.assignAddressDescription = location.addressDescription
            photoFile?.assignPlace = location.place
            
            photoFile?.updateLocationDate = Date()
        }
        self.recognizePlace()
    }
    
    
    private func recognizeDateTimeFromFilename(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.lastPathComponent.matches(for: pattern)
        if parts.count > 0 {
            let dateTime:String = "\(parts[1]):\(parts[2]):\(parts[3]) \(parts[4]):\(parts[5]):\(parts[6])"
            self.metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "From Filename", value: dateTime))
            isRecognizedDateTimeFromFilename = true
        }
    }
    
    private func recognizeUnixTimeFromFilename(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.lastPathComponent.matches(for: pattern)
        if parts.count > 0 {
            let timestamp:String = "\(parts[1])"
            let dateTime = self.convertUnixTimestampToDateString(timestamp)
            self.metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "From Filename", value: dateTime))
            isRecognizedDateTimeFromFilename = true
        }
    }
    
    private func recognizeUnixTime2FromFilename(_ pattern:String){
        guard !isRecognizedDateTimeFromFilename else {return}
        let parts:[String] = url.lastPathComponent.matches(for: pattern)
        if parts.count > 0 {
            let timestamp:String = "\(parts[1]).\(parts[2])"
            let dateTime = self.convertUnixTimestampToDateString(timestamp)
            self.metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "From Filename", value: dateTime))
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
    
    // MARK: set/revert latitude and longitude for an image
    
    /// set the latitude and longitude of an image
    /// - Parameter location: the new coordinates
    ///
    /// The location may be set to nil to delete location information from
    /// an image.
    func setLocation(_ location: Coord?) {
        self.location.coordinate = location
        setTimeZoneFor(location)
    }
    
    /// restore latitude and longitude to their initial values
    ///
    /// Image location is restored to the value when location information
    /// was last saved. If the image has not been saved the restored values
    /// will be those in the image when first read.
    func revertLocation() {
        self.location.coordinate = originalCoordinate
        setTimeZoneFor(self.location.coordinate)
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
    private func loadPreview() -> NSImage {
        var image = NSImage(size: NSMakeRect(0, 0, 0, 0).size)
        if self.isVideo == true { return image }
        
        var imgSrc:CGImageSource? = CGImageSourceCreateWithURL(url as CFURL, nil)
        if imgSrc == nil {
            if let img = NSImage(byReferencingFile: url.path) {
                imgSrc = CGImageSourceCreateWithData(img.tiffRepresentation! as CFData , nil)
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
                image.unlockFocus()
            }
            checkSize = false
        } while checkSize
        return image
    }
    
    func setCoordinate(latitude:Double, longitude:Double){
        guard latitude > 0 && longitude > 0 else {return}
        
        //print("SET COORD 1: \(latitude) \(longitude) - \(fileName)")
        location.coordinate = Coord(latitude: latitude, longitude: longitude)
        
        if self.photoFile != nil {
            if self.location.coordinate != nil && self.location.coordinate?.latitude != nil && self.location.coordinate?.longitude != nil {
                self.photoFile?.latitude = "\(self.location.coordinate?.latitude ?? 0)"
                self.photoFile?.longitude = "\(self.location.coordinate?.longitude ?? 0)"
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Latitude (WGS84)", value: String(format: "%3.6f", self.location.coordinate!.latitude).paddingLeft(12)))
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Longitude (WGS84)", value: String(format: "%3.6f", self.location.coordinate!.longitude).paddingLeft(12)))
            }
            if self.location.coordinateBD != nil && self.location.coordinateBD?.latitude != nil && self.location.coordinateBD?.longitude != nil {
                self.photoFile?.latitudeBD = "\(self.location.coordinateBD?.latitude ?? 0)"
                self.photoFile?.longitudeBD = "\(self.location.coordinateBD?.longitude ?? 0)"
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Latitude (BD09)", value: String(format: "%3.6f", self.location.coordinateBD!.latitude).paddingLeft(12)))
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Longitude (BD09)", value: String(format: "%3.6f", self.location.coordinateBD!.longitude).paddingLeft(12)))
            }
        }

        //hasCoordinate = true
    }
    
    // MARK: extract image metadata
    
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
                if self.photoFile != nil {
                    self.photoFile?.imageWidth = Int32(pxWidth)
                    self.photoFile?.imageHeight = Int32(pxHeight)
                }
                metaInfoHolder.setMetaInfo(MetaInfo(category: "System", subCategory: "", title: "Size", value: "\(pxWidth) x \(pxHeight)"))
            }
        }
        
        if let tiffData = imgProps[TIFFDictionary] as? [String: AnyObject] {
            let cameraMake = tiffData[CameraMake] as? String ?? ""
            if cameraMake != "" {
                if self.photoFile != nil {
                    self.photoFile?.cameraMaker = cameraMake
                }
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Manufacture", value: cameraMake))
            }
            let cameraModel = tiffData[CameraModel] as? String ?? ""
            if cameraModel != "" {
                if self.photoFile != nil {
                    self.photoFile?.cameraModel = cameraModel
                }
                let model = CameraModelRecognizer.recognize(maker: cameraMake, model: cameraModel)
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Model", value: model))
            }
            
            
        }
        
        // extract image date/time created
        if let exifData = imgProps[exifDictionary] as? [String: AnyObject] {
            if let cameraSerialNo = exifData[CameraSerialNumber] as? String {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Serial Number", value: cameraSerialNo))
            }
            if let lensMake = exifData[LensMake] as? String {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Lens", subCategory: "", title: "Manufacture", value: lensMake))
            }
            if let lensModel = exifData[LensModel] as? String {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Lens", subCategory: "", title: "Model", value: lensModel))
            }
            if let lensSerialNo = exifData[LensSerialNumber] as? String {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Lens", subCategory: "", title: "Serial Number", value: lensSerialNo))
            }
        }
        
        if let tiffData = imgProps[TIFFDictionary] as? [String: AnyObject],
            let software = tiffData[Software] as? String {
            if self.photoFile != nil {
                self.photoFile?.softwareName = software
            }
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Software", subCategory: "", title: "Name", value: software))
        }
        
        if let exifData = imgProps[exifDictionary] as? [String: AnyObject],
            let dto = exifData[exifDateTimeOriginal] as? String {
            date = dto
            if self.photoFile != nil {
                self.photoFile?.exifDateTimeOriginal = exifDateFormat.date(from: date)
            }
            metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "DateTimeOriginal", value: date))
        }
        
        if let tiffData = imgProps[TIFFDictionary] as? [String: AnyObject] {
            if let softwareDateTime = tiffData[SoftwareDateTime] as? String {
                if self.photoFile != nil {
                    self.photoFile?.softwareModifiedTime = exifDateFormat.date(from: softwareDateTime)
                }
                metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "Software Modified", value: softwareDateTime))
            }
        }
        
        if let gpsData = imgProps[GPSDictionary] as? [String: AnyObject],
            let gpsDateUTC = gpsData[GPSDateUTC] as? String,
            let gpsTimeUTC = gpsData[GPSTimestampUTC] as? String{
            if self.photoFile != nil {
                self.photoFile?.gpsDate = "\(gpsDateUTC) \(gpsTimeUTC) UTC"
            }
            metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "GPS Date", value: "\(gpsDateUTC) \(gpsTimeUTC) UTC"))
        }
        
        if let colorModel = imgProps[ColorModel] as? String {
            metaInfoHolder.setMetaInfo(MetaInfo(category: "ColorSpace", subCategory: "", title: "Model", value: colorModel))
        }
        
        if let colorModelProfile = imgProps[ColorModelProfile] as? String {
            metaInfoHolder.setMetaInfo(MetaInfo(category: "ColorSpace", subCategory: "", title: "Profile", value: colorModelProfile))
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
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "", title: "Altitude", value: "\(altitude) \(altitudeRef)"))
            }
            
            if let gpsSpeed = gpsData[GPSSpeed] as? String {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "", title: "Speed", value: gpsSpeed))
            }
            
            if let gpsArea = gpsData[GPSArea] as? String {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "", title: "Area", value: gpsArea))
            }
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
        let filename:String = url.lastPathComponent
        let path:String = url.path
        let parentPath:String = (url.deletingLastPathComponent().path)
        
        let photoFile = ModelStore.getOrCreatePhoto(filename: filename, path: path, parentPath: parentPath)
        //print("loaded PhotoFile for \(filename)")
        
        
        if photoFile.imageWidth != 0 && photoFile.imageHeight != 0 {
            metaInfoHolder.setMetaInfo(MetaInfo(category: "System", subCategory: "", title: "Size", value: "\(photoFile.imageWidth) x \(photoFile.imageHeight)"))
        }
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Manufacture", value: photoFile.cameraMaker))
        
        let model = CameraModelRecognizer.recognize(maker: photoFile.cameraMaker ?? "", model: photoFile.cameraModel ?? "")
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", subCategory: "", title: "Model", value: model))
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Software", subCategory: "", title: "Name", value: photoFile.softwareName))
        if photoFile.exifDateTimeOriginal != nil {
            metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "DateTimeOriginal", value: exifDateFormat.string(from: photoFile.exifDateTimeOriginal!)))
        }
        
        if photoFile.exifCreateDate != nil {
            metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "FileCreateDate", value: exifDateFormat.string(from: photoFile.exifCreateDate!)))
        }
        
        if photoFile.exifModifyDate != nil {
            metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "FileModifyDate", value: exifDateFormat.string(from: photoFile.exifModifyDate!)))
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
        
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Frame Rate", value: photoFile.videoFrameRate.description))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Image Width", value: photoFile.imageWidth.description))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Image Height", value: photoFile.imageHeight.description))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Duration", value: photoFile.videoDuration))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Size", value: photoFile.fileSize))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Avg Bitrate", value: photoFile.videoBitRate))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Rotation", value: photoFile.rotation.description))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Audio", title: "Channels", value: photoFile.audioChannels.description))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Audio", title: "BitsPerSample", value: photoFile.videoBitRate))
            metaInfoHolder.setMetaInfo(MetaInfo(category: "Audio", title: "SampleRate", value: photoFile.audioRate.description))
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
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Address", value: photoFile.assignAddress))
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Description", value: photoFile.assignAddressDescription))
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Place", value: photoFile.assignPlace))
        
        location.country = photoFile.country ?? ""
        location.province = photoFile.province ?? ""
        location.city = photoFile.city ?? ""
        location.district = photoFile.district ?? ""
        location.street = photoFile.street ?? ""
        location.businessCircle = photoFile.businessCircle ?? ""
        location.address = photoFile.assignAddress ?? photoFile.address ?? ""
        location.addressDescription = photoFile.assignAddressDescription ?? photoFile.addressDescription ?? ""
        location.place = photoFile.assignPlace ?? photoFile.suggestPlace ?? photoFile.businessCircle ?? ""
        
        if photoFile.latitude != nil && photoFile.longitude != nil {
            location.coordinate = Coord(latitude: Double(photoFile.latitude ?? "0") ?? 0, longitude: Double(photoFile.longitude ?? "0") ?? 0)
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
            metaInfoHolder.setMetaInfo(MetaInfo(category: "System", title: "Size", value: json[0]["Composite"]["ImageSize"].description), ifNotExists: true)
            
            metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "ExifCreateDate", value: json[0]["File"]["CreateDate"].description))
            photoFile?.exifCreateDate = exifDateFormat.date(from: json[0]["EXIF"]["CreateDate"].description)
            
            metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "ExifModifyDate", value: json[0]["File"]["ModifyDate"].description))
            photoFile?.exifModifyDate = exifDateFormat.date(from: json[0]["EXIF"]["ModifyDate"].description)
            
            if photoFile?.exifModifyDate == nil {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "FileModifyDate", value: json[0]["File"]["ModifyDate"].description))
                photoFile?.exifModifyDate = exifDateFormat.date(from: json[0]["File"]["FileModifyDate"].description)
            }
            
            let dateTimeOriginal = json[0]["EXIF"]["DateTimeOriginal"].stringValue
            photoFile?.exifDateTimeOriginal = exifDateFormat.date(from: dateTimeOriginal)
            if photoFile?.exifDateTimeOriginal != nil {
                metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "DateTimeOriginal", value: exifDateFormat.string(from: (photoFile?.exifDateTimeOriginal)!)))
            }
            
            if isPhoto {
                if json[0]["EXIF"]["ISO"] != JSON.null {
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", title: "ISO", value: json[0]["EXIF"]["ISO"].description))
                    photoFile?.iso = json[0]["EXIF"]["ISO"].description
                }
                
                if json[0]["EXIF"]["ExposureTime"] != JSON.null {
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", title: "ExposureTime", value: json[0]["EXIF"]["ExposureTime"].description))
                    photoFile?.exposureTime = json[0]["EXIF"]["ExposureTime"].description
                }
                
                if json[0]["EXIF"]["ApertureValue"] != JSON.null {
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "Camera", title: "Aperture", value: json[0]["EXIF"]["ApertureValue"].description))
                    photoFile?.aperture = json[0]["EXIF"]["ApertureValue"].description
                }
            }
            
            if isVideo {
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Format", value: json[0]["QuickTime"]["MajorBrand"].description))
                photoFile?.videoFormat = json[0]["QuickTime"]["MajorBrand"].description
                
                if json[0]["QuickTime"]["CreateDate"] != "0000:00:00 00:00:00" {
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "VideoCreateDate", value: json[0]["QuickTime"]["CreateDate"].description))
                    photoFile?.videoCreateDate = exifDateFormat.date(from: json[0]["QuickTime"]["CreateDate"].description)
                }
                
                if json[0]["QuickTime"]["ModifyDate"] != "0000:00:00 00:00:00" {
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "VideoModifyDate", value: json[0]["QuickTime"]["ModifyDate"].description))
                    photoFile?.videoModifyDate = exifDateFormat.date(from: json[0]["QuickTime"]["ModifyDate"].description)
                }
                
                if json[0]["QuickTime"]["TrackCreateDate"] != "0000:00:00 00:00:00" {
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "TrackCreateDate", value: json[0]["QuickTime"]["TrackCreateDate"].description))
                    photoFile?.trackCreateDate = exifDateFormat.date(from: json[0]["QuickTime"]["TrackCreateDate"].description)
                }
                
                if json[0]["QuickTime"]["TrackModifyDate"] != "0000:00:00 00:00:00" {
                    metaInfoHolder.setMetaInfo(MetaInfo(category: "DateTime", title: "TrackModifyDate", value: json[0]["QuickTime"]["TrackModifyDate"].description))
                    photoFile?.trackModifyDate = exifDateFormat.date(from: json[0]["QuickTime"]["TrackModifyDate"].description)
                }
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Frame Rate", value: json[0]["QuickTime"]["VideoFrameRate"].description))
                photoFile?.videoFrameRate = json[0]["QuickTime"]["VideoFrameRate"].doubleValue
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Image Width", value: json[0]["QuickTime"]["ImageWidth"].description))
                photoFile?.imageWidth = json[0]["QuickTime"]["ImageWidth"].int32 ?? 0
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Image Height", value: json[0]["QuickTime"]["ImageHeight"].description))
                photoFile?.imageHeight = json[0]["QuickTime"]["ImageHeight"].int32 ?? 0
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Duration", value: json[0]["QuickTime"]["Duration"].description))
                photoFile?.videoDuration = json[0]["QuickTime"]["Duration"].description
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Size", value: json[0]["QuickTime"]["MovieDataSize"].description))
                photoFile?.fileSize = json[0]["QuickTime"]["MovieDataSize"].description
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Avg Bitrate", value: json[0]["Composite"]["AvgBitrate"].description))
                photoFile?.videoBitRate = json[0]["Composite"]["AvgBitrate"].description
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Video", title: "Rotation", value: json[0]["Composite"]["Rotation"].description))
                photoFile?.rotation = json[0]["Composite"]["Rotation"].int32 ?? 0
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Audio", title: "Channels", value: json[0]["QuickTime"]["AudioChannels"].description))
                photoFile?.audioChannels = json[0]["QuickTime"]["AudioChannels"].int32 ?? 0
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Audio", title: "BitsPerSample", value: json[0]["QuickTime"]["AudioBitsPerSample"].description))
                photoFile?.audioBits = json[0]["QuickTime"]["AudioBitsPerSample"].int32 ?? 0
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Audio", title: "SampleRate", value: json[0]["QuickTime"]["AudioSampleRate"].description))
                photoFile?.audioRate = json[0]["QuickTime"]["AudioSampleRate"].int32 ?? 0
            }
            photoFile?.updateExifDate = Date()
        }
        
        let jsonStr2:String = ExifTool.helper.getUnformattedExif(url: url)
        let json2:JSON = JSON(parseJSON: jsonStr2)
        
        if json2 != JSON(NSNull()) {
            
            let latitude:String = json2[0]["Composite"]["GPSLatitude"].description
            let longitude:String = json2[0]["Composite"]["GPSLongitude"].description
            
            if json2[0]["Composite"]["GPSLatitude"] != JSON.null && json2[0]["Composite"]["GPSLongitude"] != JSON.null && latitude != "0" && longitude != "0" && latitude != "null" && longitude != "null" {
                
                //print("SET COORD 3: \(latitude) \(longitude) - \(fileName)")
                
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Latitude (WGS84)", value: latitude))
                metaInfoHolder.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Original", title: "Longitude (WGS84)", value: longitude))
                
                if let lat:Double = json2[0]["Composite"]["GPSLatitude"].double,
                    let lon:Double = json2[0]["Composite"]["GPSLongitude"].double {
                    setCoordinate(latitude: lat, longitude: lon)
                }
            }
        }
        isLoadedExif = true
    }
    
}

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
        
        if photoFile != nil {
            
            photoFile?.country = location.country
            photoFile?.province = location.province
            photoFile?.city = location.city
            photoFile?.district = location.district
            photoFile?.street = location.street
            photoFile?.businessCircle = location.businessCircle
            photoFile?.address = location.address
            photoFile?.addressDescription = location.addressDescription
            photoFile?.suggestPlace = location.place
        }
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Country", value: location.country))
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Province", value: location.province))
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "City", value: location.city))
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "District", value: location.district))
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Street", value: location.street))
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "BusinessCircle", value: location.businessCircle))
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Address", value: location.address))
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Description", value: location.addressDescription))
        
        metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Suggest Place", value: location.place))
        
        self.recognizePlace()
        
        photoFile?.updateLocationDate = Date()
        
    }
    
    func alert(status: Int, message: String, popup: Bool) {
        print("\(status) : \(message)")
    }
    
    
}


extension URL {
    
    func isPhoto() -> Bool{
        
        if lastPathComponent.split(separator: Character(".")).count > 1 {
            let fileExt:String = (lastPathComponent.split(separator: Character(".")).last?.lowercased())!
            if fileExt == "jpg" || fileExt == "jpeg" {
                return true
            }
        }
        return false
        
    }
    
    func isVideo() -> Bool{
        
        if lastPathComponent.split(separator: Character(".")).count > 1 {
            let fileExt:String = (lastPathComponent.split(separator: Character(".")).last?.lowercased())!
            if fileExt == "mov" || fileExt == "mp4" || fileExt == "mpeg" {
                return true
            }
        }
        return false
        
    }
}
