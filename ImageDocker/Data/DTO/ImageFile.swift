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
//import SwiftyJSON
import AVFoundation
//import GRDB
import LoggerFactory

class ImageFile {
    
    let logger = LoggerFactory.get(category: "ImageFile", includeTypes: [])
    
    // MARK: - URL
  
    var url: URL
    public lazy var backupUrl: URL? = self.getBackupUrl()
    
    func getBackupUrl() -> URL? {
        if let img = self.imageData {
            if let repo = RepositoryDao.default.getRepository(id: img.repositoryId) {
                self.logger.log("[getBackupUrl] backup url: \(repo.storageVolume)\(repo.storagePath.withLastStash())\(img.subPath)")
                return URL(fileURLWithPath: "\(repo.storageVolume)\(repo.storagePath.withLastStash())\(img.subPath)")
            }
        }
        self.logger.log(.error, "[getBackupUrl] Unable to get raw version url of image id:\(self.imageData?.id ?? ""), repositoryId:\(self.imageData?.repositoryId ?? -999999)")
        return nil
    }
    
    var fileName: String
//    var filenamePatterns:[String:Set<String>] = [:]
//    var filenameConverters:[String:String] = [:]
    
    /// The string representation of the location of an image for copy and paste.
    /// The representation of no location is an empty string.
    var stringRepresentation: String {
        return url.path
    }
    
    // MARK: - IMAGE DATA
    
    var imageData:Image?
    
    var repositoryColor:String = ""
    
    lazy var thumbnail:NSImage? = self.setThumbnail(self.url)
    
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
//    var dateFromEpoch: TimeInterval {
//        let format = DateFormatter()
//        format.dateFormat = "yyyy:MM:dd HH:mm:ss"
//        format.timeZone = TimeZone.current
//        if let convertedDate = format.date(from: date) {
//            return convertedDate.timeIntervalSince1970
//        }
//        return 0
//    }
    
    
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
    
    var isChecked = false
    
    func check() {
        self.isChecked = true
    }
    func uncheck() {
        self.isChecked = false
    }
    
    var collectionCheckBox:NSButton?
    var collectionViewItem:CollectionViewItem?
    var threaterCollectionViewItem:TheaterCollectionViewItem?
    var memoryCollectionViewItem:MemoryCollectionViewItem?
    
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
    
    /// - Tag: ImageFile.hide()
    func hide() {
        if imageData != nil {
            imageData?.hidden = true
            self.logger.log(.trace, "[ImageFile.hide] - save image record - \(imageData?.path ?? "")")
            let _ = ImageRecordDao.default.saveImage(image: imageData!)
        }
    }
    
    /// - Tag: ImageFile.show()
    func show() {
        if imageData != nil {
            imageData?.hidden = false
            self.logger.log(.trace, "[ImageFile.show] - save image record - \(imageData?.path ?? "")")
            let _ = ImageRecordDao.default.saveImage(image: imageData!)
        }
    }
    
    
    // MARK: - UPDATE
    
    /// - Tag: ImageFile.save()
    func save() -> ExecuteState{
        if self.imageData != nil {
            self.logger.log(.trace, "[ImageFile.save] - save image record - \(self.imageData?.path ?? "")")
            return ImageRecordDao.default.saveImage(image: self.imageData!)// FIXME: try to simplify - only update necessary (changed) fields
        }else{
            return .NO_RECORD
        }
    }
    
    // MARK: - LOADER
    
    var hasLoadedMetaInfoFromDatabase = false
    
    var repositoryId:Int? = nil
    var repositoryVolume:String? = nil
    var repositoryPath:String? = nil
    var rawVolume:String? = nil
    var rawPath:String? = nil
    
    // READ FROM DATABASE
    /// - Tag: ImageFile.init(image)
    init (image:Image, repositoryId:Int? = nil, repositoryVolume:String? = nil, rawVolume:String? = nil, indicator:Accumulator? = nil, loadExifFromFile:Bool = true, metaInfoStore:MetaInfoStoreDelegate? = nil, forceReloadExif:Bool = false) {
        exifDateFormat.dateFormat = "yyyy:MM:dd HH:mm:ss"
        exifDateFormatWithTimezone.dateFormat = "yyyy:MM:dd HH:mm:ssxxx"
        
        self.repositoryId = image.repositoryId
        if let repository = RepositoryDao.default.getRepository(id: self.repositoryId ?? 0) { // FIXME: cache this
            self.repositoryVolume = repository.repositoryVolume
            self.rawVolume = repository.storageVolume
            self.repositoryPath = repository.repositoryPath
            self.rawPath = repository.storagePath
            
            let imagePath = "\(repository.repositoryVolume.removeLastStash())\(repository.repositoryPath.withLastStash())\(image.subPath)"
            self.logger.log("image full path: \(imagePath)")
            
            self.url = URL(fileURLWithPath: imagePath)
            
            self.logger.log("Loaded ImageFile url: \(self.url)")
        }else{
            self.logger.log(.error, "Unable to load ImageRepository for Image.id:\(image.id) with repositoryId:\(image.repositoryId), subPath:\(image.subPath)")
            self.url = URL(fileURLWithPath: image.path)
            self.logger.log("URL using image.path: \(image.path)")
        }
        
        self.logger.log("repositoryId:\(self.repositoryId), repositoryVolume:\(self.repositoryVolume), rawVolume:\(self.rawVolume)")
        
        self.indicator = indicator
        
//        if let repositoryVolume = repositoryVolume {
//            let (_, path) = image.path.getVolumeFromThisPath()
//            self.logger.log("Divided path: \(path)")
//            let fullPath = "\(repositoryVolume)\(path)"
//            self.url = URL(fileURLWithPath: fullPath)
//            self.logger.log("fullPath: \(fullPath)")
//        }else{
//            self.url = URL(fileURLWithPath: image.path)
//            self.logger.log("using image.path: \(image.path)")
//        }
        
        
        self.fileName = image.filename
        self.location = Location()
        
        let imageType = url.imageType()
        
        self.isPhoto = (imageType == .photo)
        self.isVideo = (imageType == .video)
        
        self.metaInfoHolder = metaInfoStore ?? MetaInfoHolder()
        self.imageData = image
        
        let startTime_loadMetaInfoFromDatabase = Date()
        loadMetaInfoFromDatabase()
        self.logger.timecost("[ImageFile.init from database][loadMetaInfoFromDatabase] time cost", fromDate: startTime_loadMetaInfoFromDatabase)
        
        
        // ensure image has id
        if let imageData = self.imageData {
            if let id = imageData.id {
            }else{
                self.logger.log(.warning, "[ImageFile.init from database] image.id is nil, path:\(image.path)")
                // generate imageId
                let (executeState_generateId, imageId) = ImageRecordDao.default.generateImageIdByContainerIdAndSubPath(containerId: imageData.containerId, subPath: imageData.subPath)
                if executeState_generateId != .OK {
                    self.logger.log(.error, "[ImageFile.init from database] Unable to generateImageIdByContainerIdAndSubPath, containerId:\(imageData.containerId), subPath:\(imageData.subPath)")
                }else{
                    self.logger.log(.trace, "[ImageFile.init from database] generated UUID for image, imageId:\(imageId), containerId:\(imageData.containerId), subPath:\(imageData.subPath)")
                    imageData.id = imageId
                    self.imageData?.id = imageId
                }
            }
        }
        
        if self.imageData?.dateTimeFromFilename == nil {
            let startTime_recognizeDateTimeFromFilename = Date()
            let dateTimeFromFilename = self.recognizeDateTimeFromFilename()
            if dateTimeFromFilename != "" {
                self.logger.log(.trace, "[ImageFile.init from database] needSave set to true due to dateTimeFromFilename is nil and called recognizeDateTimeFromFilename()")
                if let imageData = self.imageData {
                    if let id = imageData.id {
                        let executeState_updateDateTimeFromFilename = ImageRecordDao.default.updateImageDateTimeFromFilename(id: id, dateTimeFromFilename: dateTimeFromFilename)
                        if executeState_updateDateTimeFromFilename != .OK {
                            self.logger.log(.error, "[ImageFile.init from database] Unable to updateImageDateTimeFromFilename, id:\(id)")
                        }
                    }else{
                        self.logger.log(.warning, "[ImageFile.init from database] Unable to updateImageDateTimeFromFilename, id is nil, path:\(image.path)")
                        // generate imageId
                        let (executeState_generateId, imageId) = ImageRecordDao.default.generateImageIdByContainerIdAndSubPath(containerId: imageData.containerId, subPath: imageData.subPath)
                        if executeState_generateId != .OK {
                            self.logger.log(.error, "[ImageFile.init from database] Unable to generateImageIdByContainerIdAndSubPath, containerId:\(imageData.containerId), subPath:\(imageData.subPath)")
                        }else{
                            self.logger.log(.trace, "[ImageFile.init from database] generated UUID for image, imageId:\(imageId), containerId:\(imageData.containerId), subPath:\(imageData.subPath)")
                            imageData.id = imageId
                            // try again
                            let executeState_updateDateTimeFromFilename = ImageRecordDao.default.updateImageDateTimeFromFilename(id: imageId, dateTimeFromFilename: dateTimeFromFilename)
                            if executeState_updateDateTimeFromFilename != .OK {
                                self.logger.log(.error, "[ImageFile.init from database] Unable to updateImageDateTimeFromFilename, id:\(imageId)")
                            }
                        }
                    }
                }else {
                    self.logger.log(.error, "[ImageFile.init from database] Unable to updateImageDateTimeFromFilename, imageData is nil, path:\(image.path)")
                }
            }
            self.logger.timecost("[ImageFile.init from database][recognizeDateTimeFromFilename] time cost", fromDate: startTime_recognizeDateTimeFromFilename)
        }
        
        
        var needSave:Bool = false
        
        if self.imageData?.imageSource == nil {
            
            let startTime_recognizeImageSource = Date()
            self.recognizeImageSource()
            self.logger.log(.trace, "[ImageFile.init from database] needSave set to true due to imageSource is nil and called recognizeImageSource()")
            needSave = true
            self.logger.timecost("[ImageFile.init from database][recognizeImageSource] time cost", fromDate: startTime_recognizeImageSource)
        }
        
        let now = Date()
        
//        if loadExifFromFile {
            if self.imageData?.updateExifDate == nil || self.imageData?.photoTakenYear == 0 || self.imageData?.photoTakenYear == nil || self.imageData?.photoTakenDate == nil {
                
                if let data = self.imageData {
                    if let datetime = Naming.DateTime.get(from: data), datetime < now {
                        self.storePhotoTakenDate(dateTime: datetime)
                        self.logger.log(.trace, "[ImageFile.init from database] needSave set to true due to updateExifDate is nil and called storePhotoTakenDate()")
                        needSave = true
                    }else{
                        // exif not loaded yet
                        autoreleasepool { () -> Void in
                            let startTime_loadMetaInfo = Date()
                            self.loadMetaInfoFromOSX()
//                            self.loadMetaInfoFromExif() // FIXME: maybe not work
                            
                            self.logger.log(.trace, "[ImageFile.init from database] needSave set to true due to updateExifDate is nil and datetime is nil and called loadMetaInfoFromExif()")
                            needSave = true
                            self.logger.timecost("[ImageFile.init from database][loadMetaInfo] time cost", fromDate: startTime_loadMetaInfo)
                        }
                    }
                }
                
            }
        
        if(forceReloadExif){
            autoreleasepool { () -> Void in
                let startTime_loadMetaInfo = Date()
                self.loadMetaInfoFromOSX()
//                self.loadMetaInfoFromExif() // FIXME: maybe not work
                
                self.logger.log(.trace, "[ImageFile.init from database] needSave set to true due to forceReloadExif is true and called loadMetaInfoFromExif()")
                needSave = true
                self.logger.timecost("[ImageFile.init from database][forceReloadExif] time cost", fromDate: startTime_loadMetaInfo)
            }
        }
            
//            if self.imageData?.cameraMaker == nil {
//                autoreleasepool { () -> Void in
//                    self.loadMetaInfoFromOSX()
//                    self.loadMetaInfoFromExif()
//                    
//                    needSave = true
//                }
//            }
            if self.isNeedLoadLocation() {
                self.logger.log(.trace, "[ImageFile.init from database] needSave set to true due to isNeedLoadLocation is true and called loadLocation()")
                needSave = true
                autoreleasepool { () -> Void in
                    //self.logger.log("LOADING LOCATION")
                    let startTime_loadLocation = Date()
                    loadLocation(locationConsumer: self)
                    self.logger.timecost("[ImageFile.init from database][loadLocation] time cost", fromDate: startTime_loadLocation)
                }
            }
            
            if isPhoto || isVideo {
                originalCoordinate = location.coordinate
            }
            
            let startTime_recognizePlace = Date()
            self.recognizePlace()
            self.logger.timecost("[ImageFile.init from database][recognizePlace] time cost", fromDate: startTime_recognizePlace)
            
            if self.imageData?.updateExifDate == nil {
                self.imageData?.updateExifDate = Date()
            }
//        }
        
        self.logger.log(.trace, "[ImageFile.init from database] forceReloadExif=\(forceReloadExif), needSave=\(needSave)")
        if needSave || forceReloadExif { // FIXME: try to simplify
            self.logger.log(.trace, "[ImageFile.init from database] save image record - \(self.imageData?.path ?? "")")
            let _ = save()
        }
        
        //let startTime_transformToMetaInfo = Date()
        //self.transformDomainToMetaInfo()
        //self.logger.timecost("[ImageFile.init from database][transformDomainToMetaInfo] time cost", fromDate: startTime_transformToMetaInfo)
        
        self.notifyAccumulator(notifyIndicator: true)
    }

    /// IMPORT FROM FILE SYSTEM
    /// - caller:
    ///   - ImageRecordDao.[createImageIfAbsent(url)](x-source-tag://createImageIfAbsent(url))
    ///   - CollectionViewItemsLoader.[transformToDomainItems(urls)](x-source-tag://CollectionViewItemsLoader.transformToDomainItems(urls))
    ///   - ViewController.loadImage()
    /// - Tag: ImageFile.init(url)
    init (url: URL, repository:ImageContainer? = nil, indicator:Accumulator? = nil, metaInfoStore:MetaInfoStoreDelegate? = nil, quickCreate:Bool = false) {
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
            self.logger.log("repo has value, getOrCreatePhoto")
            self.imageData = ImageRecordDao.default.getOrCreatePhoto(filename: fileName,
                                                             path: url.path,
                                                             parentPath: url.deletingLastPathComponent().path,
                                                             repositoryPath: repo.repositoryPath.withLastStash())
        }else{
            self.logger.log("repo is null, getOrCreatePhoto")
            self.imageData = ImageRecordDao.default.getOrCreatePhoto(filename: fileName,
                                                                 path: url.path,
                                                                 parentPath: url.deletingLastPathComponent().path,
                                                                 repositoryPath: nil)
        }
        
        if !quickCreate {
            self.logger.log("LOAD META FROM DB BY IMAGE URL")
            loadMetaInfoFromDatabase()
            
            if self.imageData?.updateExifDate == nil || self.imageData?.photoTakenYear == 0 {
                
                autoreleasepool { () -> Void in
                    self.loadMetaInfoFromOSX()
                    self.loadMetaInfoFromExif()
                }
                
            }
            //self.logger.log("loaded image coordinate: \(self.latitudeBaidu) \(self.longitudeBaidu)")
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
        
        if let repo = repository, repo.folderAsEvent {
            self.imageData?.event = Naming.Event.recognize(from: url, level: repo.eventFolderLevel)
        }
        
        if !quickCreate {
            self.recognizePlace()
            
            self.logger.log(.info, "[ImageFile.init from url] save image record - \(url.path)")
            let _ = save()
        }
        
        self.transformDomainToMetaInfo()
        
        self.notifyAccumulator(notifyIndicator: true)

    }
    
    // MARK: - PROGRESS INDICATOR
    
    internal var indicator:Accumulator?
    
    private func notifyAccumulator(notifyIndicator:Bool = true){
        
        if notifyIndicator && self.indicator != nil {
            DispatchQueue.main.async {
                let _ = self.indicator?.add(Words.searchingImages.word())
            }
            
            
        }
        
    }
    
    
    
}


