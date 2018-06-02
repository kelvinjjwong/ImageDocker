//
//  ImageFile.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//

import Cocoa
import AVFoundation

class ImageFile {
  
    //private(set) var thumbnail: NSImage?
    private(set) var fileName: String
    private(set) var url: NSURL
    private(set) var place:String = ""
    private var photoFile:PhotoFile?
    private var imageData:ImageData?
    
    private var indicator:Accumulator?
    var collectionViewItem:CollectionViewItem?

    init (url: NSURL, indicator:Accumulator? = nil) {
        self.indicator = indicator
        self.url = url
        if let name = url.lastPathComponent {
            fileName = name
        } else {
            fileName = ""
        }
        
        self.saveToModelStore(notifyIndicator: true)
        let photoTakenDate:String? = self.choosePhotoTakenDateFromMetaInfo()
        self.storePhotoTakenDate(dateTime: photoTakenDate)
        //self.setThumbnail(url as URL)
        
        

    }
    
    lazy var thumbnail:NSImage? = self.setThumbnail(self.url as URL)
    
    func loadLocation(consumer:MetaInfoConsumeDelegate) {
        if imageData == nil {
            self.imageData = ImageData(url: url as URL)
        }
        self.imageData?.getBaiduLocation(consumer: consumer)
    }
    
    func recognizePlace() {
        var place:String? = self.imageData?.getMeta(category: "Location", subCategory: "Assigned", title: "Place")
        if place != nil {
            self.place = place!
            return
        }
        place = self.imageData?.getMeta(category: "Location", subCategory: "Baidu", title: "Suggest Place")
        if place != nil {
            self.place = place!
            return
        }
        place = self.imageData?.getMeta(category: "Location", subCategory: "Baidu", title: "Address")
        if place != nil {
            self.place = place!
            return
        }
        self.place = ""
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
        self.imageData = ImageData(url: url as URL)
        
        
        var dateTime:String? = self.imageData?.getMeta(category: "DateTime", subCategory: "", title: "Assigned")
        
        if dateTime == nil {
            dateTime = self.imageData?.getMeta(category: "DateTime", subCategory: "", title: "DateTimeOriginal")
        }
        if dateTime == nil {
            dateTime = self.imageData?.getMeta(category: "DateTime", subCategory: "", title: "From Filename")
        }
        if dateTime == nil {
            dateTime = self.imageData?.getMeta(category: "DateTime", subCategory: "", title: "Software Modified")
        }
        if dateTime == nil {
            self.imageData?.loadMetaInfoFromExif()
        }
        
        if dateTime == nil {
            dateTime = self.imageData?.getMeta(category: "Video", subCategory: "", title: "CreateDate")
            if dateTime == "0000:00:00 00:00:00" {
                dateTime = nil
            }
        }
        if dateTime == nil {
            dateTime = self.imageData?.getMeta(category: "Video", subCategory: "", title: "TrackCreateDate")
            if dateTime == "0000:00:00 00:00:00" {
                dateTime = nil
            }
        }
        return dateTime
    }
    
    private func storePhotoTakenDate(dateTime:String?) {
        if dateTime != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            let photoTakenDate = dateFormatter.date(from: dateTime!)
            storePhotoTakenDate(dateTime: photoTakenDate!)
        }
    }
    
    private func storePhotoTakenDate(dateTime photoTakenDate:Date){
        
        self.photoFile?.photoTakenDate = photoTakenDate
        
        let calendar = NSCalendar.current
        let component = calendar.dateComponents([.year, .month, .day, .hour], from: photoTakenDate)
        self.photoFile?.photoTakenYear = Int32(component.year!)
        self.photoFile?.photoTakenMonth = Int32(component.month!)
        self.photoFile?.photoTakenDay = Int32(component.day!)
        self.photoFile?.photoTakenHour = Int32(component.hour!)
    }
    
    func saveToModelStore(notifyIndicator:Bool = true){
        let filename:String = url.lastPathComponent!
        let path:String = url.path!
        let parentPath:String = (url.deletingLastPathComponent?.path)!
        
        if notifyIndicator && self.indicator != nil {
            DispatchQueue.main.async {
                let _ = self.indicator?.add("Searching images ...")
            }
            
            
        }
        
        self.photoFile = ModelStore.getOrCreatePhoto(filename: filename, path: path, parentPath: parentPath)
        
        
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
        let df = DateFormatter()
        df.dateFormat = "yyyy:MM:dd HH:mm:ss"
        let dateString:String = df.string(from: date)
        if imageData != nil {
            imageData?.metaInfoStore.setMetaInfo(MetaInfo(category: "DateTime", subCategory: "", title: "Assigned", value: dateString))
        }
        if photoFile != nil {
            photoFile?.assignDateTime = date
        }
    }
    
    func assignLocation(location:Location){
        print("location address is \(location.address)")
        print("location addressDesc is \(location.addressDescription)")
        print("location place is \(location.place)")
        if imageData != nil {
            print("image data not nil")
            imageData?.metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Latitude (WGS84)", value: (location.latitude?.description)!))
            imageData?.metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Longitude (WGS84)", value: (location.longitude?.description)!))
            imageData?.metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Latitude (BD09)", value: (location.latitudeBD?.description)!))
            imageData?.metaInfoStore.setMetaInfo(MetaInfo(category: "Coordinate", subCategory: "Assigned", title: "Longitude (BD09)", value: (location.longitudeBD?.description)!))
            imageData?.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Address", value: location.address))
            imageData?.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Description", value: location.addressDescription))
            imageData?.metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Assigned", title: "Place", value: location.place))
        }
        
        if photoFile != nil {
            print("photo file not nil")
            photoFile?.assignLatitude = location.latitude?.description
            photoFile?.assignLongitude = location.longitude?.description
            photoFile?.assignLatitudeBD = location.latitudeBD?.description
            photoFile?.assignLongitudeBD = location.longitudeBD?.description
            photoFile?.assignAddress = location.address
            photoFile?.assignAddressDescription = location.addressDescription
            photoFile?.assignPlace = location.place
        }
        self.recognizePlace()
    }
  
}
