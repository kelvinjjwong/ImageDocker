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
import GRDB

class ImageFile {
    
    let logger = ConsoleLogger(category: "ImageFile", includeTypes: [])
    
    // MARK: - URL
  
    var url: URL
    public lazy var backupUrl: URL? = self.getBackupUrl()
    
    func getBackupUrl() -> URL? {
        if let img = self.imageData {
            let pathOfRepository = img.repositoryPath.removeLastStash()
            if let repo = RepositoryDao.default.getContainer(path: pathOfRepository) {
                self.logger.log("backup url: \(repo.storagePath.withLastStash())\(img.subPath)")
                return URL(fileURLWithPath: "\(repo.storagePath.withLastStash())\(img.subPath)")
            }
        }
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
            return ImageRecordDao.default.saveImage(image: self.imageData!)
        }else{
            return .NO_RECORD
        }
    }
    
    // MARK: - LOADER
    
    var hasLoadedMetaInfoFromDatabase = false
    
    // READ FROM DATABASE
    /// - Tag: ImageFile.init(image)
    init (image:Image, indicator:Accumulator? = nil, loadExifFromFile:Bool = true, metaInfoStore:MetaInfoStoreDelegate? = nil, sharedDB:DatabaseWriter? = nil, forceReloadExif:Bool = false) {
        exifDateFormat.dateFormat = "yyyy:MM:dd HH:mm:ss"
        exifDateFormatWithTimezone.dateFormat = "yyyy:MM:dd HH:mm:ssxxx"
        
        self.indicator = indicator
        self.url = URL(fileURLWithPath: image.path)
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
        
        var needSave:Bool = false
        
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
                            self.loadMetaInfoFromExif()
                            
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
                self.loadMetaInfoFromExif()
                
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
        if needSave || forceReloadExif {
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
            self.recognizePlace() // TODO: why imageFile.quicksave no need recognize place?
            
            self.logger.log(.info, "[ImageFile.init from url] save image record - \(url.path)")
            let _ = save()
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
                let _ = self.indicator?.add(Words.searchingImages.word())
            }
            
            
        }
        
    }
    
    
    
}


