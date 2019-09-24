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

class ImageFile {
    
    
    // MARK: - URL
  
    var url: URL
    public lazy var backupUrl: URL? = self.getBackupUrl()
    
    func getBackupUrl() -> URL? {
        if let img = self.imageData {
            let pathOfRepository = img.repositoryPath.withoutStash()
            if let repo = ModelStore.default.getContainer(path: pathOfRepository) {
                print("backup url: \(repo.storagePath.withStash())\(img.subPath)")
                return URL(fileURLWithPath: "\(repo.storagePath.withStash())\(img.subPath)")
            }
        }
        return nil
    }
    
    var fileName: String
    var filenamePatterns:[String:Set<String>] = [:]
    var filenameConverters:[String:String] = [:]
    
    /// The string representation of the location of an image for copy and paste.
    /// The representation of no location is an empty string.
    var stringRepresentation: String {
        return url.path
    }
    
    // MARK: - IMAGE DATA
    
    var imageData:Image?
    
    lazy var thumbnail:NSImage? = self.setThumbnail(self.url as URL)
    
    lazy var image: NSImage = self.loadPreview()
    
    // MARK: - META
    
    let metaInfoHolder:MetaInfoStoreDelegate
    
    var isPhoto:Bool = false
    var isVideo:Bool = false
    
    var isStandalone:Bool = false
    var isLoadedExif:Bool = false
    var isRecognizedDateTimeFromFilename:Bool = false
    
    let exifDateFormat = DateFormatter()
    let exifDateFormatWithTimezone = DateFormatter()
    
    // singleton
    internal var _photoTakenDateString:String = ""
    
    // singleton
    internal var _photoTakenTimeString:String = ""
    
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
    
    
    var name: String? {
        return url.lastPathComponent
    }
    
    var event:String {
        return imageData?.event ?? ""
    }
    
    var place:String = "" {
        didSet {
            if imageData != nil && place != "" {
                imageData?.place = place
            }
        }
    }
    
    // image location
    //var coordinate: Coord?
    //var coordinateBD: Coord?
    var originalCoordinate: Coord?
    var location:Location
    
    // MARK: - DUPLICATE
    
    var hasDuplicates:Bool = false
    var duplicatesKey = ""
    
    // MARK: - COLLECTION
    
    var collectionViewItem:CollectionViewItem?
    var threaterCollectionViewItem:TheaterCollectionViewItem?
    
    // MARK: - SHOW HIDE
    
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
    
    
    // MARK: - UPDATE
    
    func save(){
        if self.imageData != nil {
            ModelStore.default.saveImage(image: self.imageData!)
        }
    }
    
    // MARK: - LOADER
    
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
        
        if self.imageData?.updateExifDate == nil {
            self.imageData?.updateExifDate = Date()
        }
        
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
    
    // MARK: - PROGRESS INDICATOR
    
    internal var indicator:Accumulator?
    
    private func notifyAccumulator(notifyIndicator:Bool = true){
        
        if notifyIndicator && self.indicator != nil {
            DispatchQueue.main.async {
                let _ = self.indicator?.add("Searching images ...")
            }
            
            
        }
        
    }
    
    
    
}


