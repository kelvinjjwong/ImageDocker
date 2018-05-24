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
  
    private(set) var thumbnail: NSImage?
    private(set) var fileName: String
    private(set) var url: NSURL
    private var photoFile:PhotoFile?
    private var imageData:ImageData?

    init (url: NSURL) {
        self.url = url
        if let name = url.lastPathComponent {
            fileName = name
        } else {
            fileName = ""
        }
        
        self.saveToModelStore()
        self.setThumbnail(url as URL)
        
        

    }
    
    func photoTakenDate() -> Date? {
        return self.photoFile?.photoTakenDate
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
    
    private func saveToModelStore(){
        let filename:String = url.lastPathComponent!
        let path:String = url.path!
        let parentPath:String = (url.deletingLastPathComponent?.path)!
        print("filename: \(filename) , path: \(path) , parent: \(parentPath)")
        self.photoFile = ModelStore.getOrCreatePhoto(filename: filename, path: path, parentPath: parentPath)
        if self.photoFile?.photoTakenDate == nil {
            self.imageData = ImageData(url: url as URL)
            
            var dateTime:String? = self.imageData?.getMeta(category: "DateTime", subCategory: "", title: "DateTimeOriginal")
            if dateTime == nil {
                dateTime = self.imageData?.getMeta(category: "DateTime", subCategory: "", title: "From Filename")
            }
            if dateTime == nil {
                dateTime = self.imageData?.getMeta(category: "DateTime", subCategory: "", title: "Software Modified")
            }
            if dateTime == nil {
                self.imageData?.loadExif()
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
            if dateTime != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                let photoTakenDate = dateFormatter.date(from: dateTime!)
                self.photoFile?.photoTakenDate = photoTakenDate
                
                let calendar = NSCalendar.current
                let component = calendar.dateComponents([.year, .month, .day, .hour], from: photoTakenDate!)
                self.photoFile?.photoTakenYear = Int32(component.year!)
                self.photoFile?.photoTakenMonth = Int32(component.month!)
                self.photoFile?.photoTakenDay = Int32(component.day!)
                self.photoFile?.photoTakenHour = Int32(component.hour!)
                
                print("photo taken date is \(String(describing: dateTime))")
            }else{
                
                print("photo taken date is nil")
            }
                
            
        }
    }
    
    private func setThumbnail(_ url:URL) {
        do {
            let properties = try url.resourceValues(forKeys: [.typeIdentifierKey])
            guard let fileType = properties.typeIdentifier else { return }
            if UTTypeConformsTo(fileType as CFString, kUTTypeImage) {
                self.thumbnail = self.getThumbnailImageFromPhoto(url)
            }else if UTTypeConformsTo(fileType as CFString, kUTTypeMovie) {
                self.thumbnail = self.getThumbnailImageFromVideo(url)
            }
        }
        catch {
            print("Unexpected error occured: \(error).")
        }
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
                String(kCGImageSourceThumbnailMaxPixelSize): 160
                ] as [String : Any]
            guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) else { return nil}
            return NSImage(cgImage: thumbnailRef, size: NSSize.zero)
        }
        return nil
    }
  
}
