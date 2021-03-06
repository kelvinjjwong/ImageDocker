//
//  ImageDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/25.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

public final class ImageRecordDao {
    
    private let impl:ImageRecordDaoInterface
    
    init(_ impl:ImageRecordDaoInterface) {
        self.impl = impl
    }
    
    static var `default`:ImageRecordDao {
        let location = PreferencesController.databaseLocation()
        if location == "local" {
            return ImageRecordDao(ImageRecordDaoGRDB())
        }else{
            return ImageRecordDao(ImageRecordDaoPostgresCK())
        }
    }
    
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String? = nil) -> Image {
        return self.impl.getOrCreatePhoto(filename: filename, path: path, parentPath: parentPath, repositoryPath: repositoryPath)
    }
    
    func getImage(path:String) -> Image? {
        return self.impl.getImage(path: path)
    }
    
    func getImage(id:String) -> Image? {
        return self.impl.getImage(id: id)
    }
    
    func saveImage(image: Image) -> ExecuteState {
        return self.impl.saveImage(image: image)
    }
    
    func deletePhoto(atPath path:String, updateFlag:Bool = true) -> ExecuteState {
        return self.impl.deletePhoto(atPath: path, updateFlag: updateFlag)
    }
    
    func updateImagePaths(oldPath:String, newPath:String, repositoryPath:String, subPath:String, containerPath:String, id:String) -> ExecuteState {
        return self.impl.updateImagePaths(oldPath: oldPath, newPath: newPath, repositoryPath: repositoryPath, subPath: subPath, containerPath: containerPath, id: id)
    }
    
    func updateImageRawBase(oldRawPath:String, newRawPath:String) -> ExecuteState {
        return self.impl.updateImageRawBase(oldRawPath: oldRawPath, newRawPath: newRawPath)
    }
    
    func updateImageRawBase(repositoryPath:String, rawPath:String) -> ExecuteState {
        return self.impl.updateImageRawBase(repositoryPath: repositoryPath, rawPath: rawPath)
    }
    
    func updateImageRawBase(pathStartsWith path:String, rawPath:String) -> ExecuteState {
        return self.impl.updateImageRawBase(pathStartsWith: path, rawPath: rawPath)
    }
    
    func updateImageRepositoryBase(pathStartsWith path:String, repositoryPath:String) -> ExecuteState {
        return self.impl.updateImageRepositoryBase(pathStartsWith: path, repositoryPath: repositoryPath)
    }
    
    func updateImageRepositoryBase(oldRepositoryPath:String, newRepository:String) -> ExecuteState {
        return self.impl.updateImageRepositoryBase(oldRepositoryPath: oldRepositoryPath, newRepository: newRepository)
    }
    
    func updateImagePath(repositoryPath:String) -> ExecuteState {
        return self.impl.updateImagePath(repositoryPath: repositoryPath)
    }
    
    // MARK: - DATE
    
    func updateImageDates(path:String, date:Date, fields:Set<String>) -> ExecuteState {
        return self.impl.updateImageDates(path: path, date: date, fields: fields)
    }
    
    // MARK: - DESCRIPTION
    
    func storeImageDescription(path:String, shortDescription:String?, longDescription:String?) -> ExecuteState {
        return self.impl.storeImageDescription(path: path, shortDescription: shortDescription, longDescription: longDescription)
    }
    
    
}

class ImageSearchDao {
    
    private let impl:ImageSearchDaoInterface
    
    init(_ impl:ImageSearchDaoInterface){
        self.impl = impl
    }
    
    static var `default`:ImageSearchDao {
        let location = PreferencesController.databaseLocation()
        if location == "local" {
            return ImageSearchDao(ImageSearchDaoGRDB())
        }else{
            return ImageSearchDao(ImageSearchDaoPostgresCK())
        }
    }
    
    // MARK: - Options
    
    func getImageSources() -> [String:Bool]{
        return self.impl.getImageSources()
    }
    
    func getCameraModel() -> [String:Bool] {
        return self.impl.getCameraModel()
    }
    
    // MARK: - MOMENTS
    
    func getMoments(_ momentCondition:MomentCondition, year:Int = 0, month:Int = 0, condition:SearchCondition? = nil) -> [Moment] {
        return self.impl.getMoments(momentCondition, year: year, month: month, condition: condition)
    }
    
    func getAllMoments(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Moment] {
        return self.impl.getAllMoments(imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // MARK: - PLACES
    
    func getMomentsByPlace(_ momentCondition:MomentCondition, parent:Moment? = nil, condition:SearchCondition? = nil) -> [Moment] {
        return self.impl.getMomentsByPlace(momentCondition, parent: parent, condition: condition)
    }
    
    func getImageEvents(condition:SearchCondition?) -> [Moment] {
        return self.impl.getImageEvents(condition: condition)
    }
    
    func getMomentsByEvent(event:String, category:String, year:Int = 0, month:Int = 0, condition:SearchCondition? = nil) -> [Moment] {
        return self.impl.getMomentsByEvent(event: event, category: category, year: year, month: month, condition: condition)
    }
    
    func getYears(event:String? = nil) -> [Int] {
        return self.impl.getYears(event: event)
    }
    
    func getDatesByYear(year:Int, event:String? = nil) -> [String:[String]] {
        return self.impl.getDatesByYear(year: year, event: event)
    }
    
    // MARK: - COLLECTION
    
    // get by date & place
    func getPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return self.impl.getPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    // get by date & event & place
    func getPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return self.impl.getPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    // MARK: - SEARCH
    
    func searchImages(condition:SearchCondition, includeHidden:Bool = true, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return self.impl.searchImages(condition: condition, includeHidden: includeHidden, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    // MARK: - DATE
    
    
    func getImagesByDate(year:Int, month:Int, day:Int, event:String? = nil) -> [Image] {
        return self.impl.getImagesByDate(year: year, month: month, day: day, event: event)
    }
    
    func getImagesByYear(year:String? = nil, scannedFace:Bool? = nil, recognizedFace:Bool? = nil) -> [Image] {
        return self.impl.getImagesByYear(year: year, scannedFace: scannedFace, recognizedFace: recognizedFace)
    }
    
    func getImagesByDate(photoTakenDate:Date, event:String? = nil) -> [Image] {
        return self.impl.getImagesByDate(photoTakenDate: photoTakenDate, event: event)
    }
    
    func getImagesByHour(photoTakenDate:Date) -> [Image] {
        return self.impl.getImagesByHour(photoTakenDate: photoTakenDate)
    }
    
    // MARK: - LARGER VIEW
    
    func getMaxPhotoTakenYear() -> Int {
        return self.impl.getMaxPhotoTakenYear()
    }
    
    func getMinPhotoTakenYear() -> Int {
        return self.impl.getMinPhotoTakenYear()
    }
    
    func getSqlByTodayInPrevious() -> String {
        return self.impl.getSqlByTodayInPrevious()
    }
    
    func getYearsByTodayInPrevious() -> [Int] {
        return self.impl.getYearsByTodayInPrevious()
    }
    
    func getDatesAroundToday() -> [String] {
        return self.impl.getDatesAroundToday()
    }
    
    func getDatesByTodayInPrevious(year:Int) -> [String] {
        return self.impl.getDatesByTodayInPrevious(year: year)
    }
    
    // MARK: - EXIF
    
    func getPhotoFilesWithoutExif(limit:Int? = nil) -> [Image] {
        return self.impl.getPhotoFilesWithoutExif(limit: limit)
    }
    
    func getPhotoFilesWithoutExif(repositoryPath:String, limit:Int? = nil) -> [Image] {
        return self.impl.getPhotoFilesWithoutExif(repositoryPath: repositoryPath, limit: limit)
    }
    
    // MARK: - LOCATION
    
    func getPhotoFilesWithoutLocation(repositoryPath:String) -> [Image] {
        return self.impl.getPhotoFilesWithoutLocation(repositoryPath: repositoryPath)
    }
    
    func getPhotoFilesWithoutLocation() -> [Image] {
        return self.impl.getPhotoFilesWithoutLocation()
    }
    
    func getPhotoFiles(after date:Date) -> [Image] {
        return self.impl.getPhotoFiles(after: date)
    }
    
    // MARK: - FACE
    
    func getImagesWithoutFace(repositoryRoot:String, includeScanned:Bool = false) -> [Image] {
        return self.impl.getImagesWithoutFace(repositoryRoot: repositoryRoot, includeScanned: includeScanned)
    }
    
    // MARK: - PATH
    
    func getAllPhotoPaths(includeHidden:Bool = true) -> Set<String> {
        return self.impl.getAllPhotoPaths(includeHidden: includeHidden)
    }
    
    func getAllPhotoPaths(repositoryPath:String, includeHidden:Bool = true) -> Set<String> {
        return self.impl.getAllPhotoPaths(repositoryPath:repositoryPath, includeHidden: includeHidden)
    }
    
    func getPhotoFilesWithoutSubPath(rootPath:String) -> [Image] {
        return self.impl.getPhotoFilesWithoutSubPath(rootPath: rootPath)
    }
    
    func getPhotoFiles(parentPath:String, includeHidden:Bool = true, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false) -> [Image] {
        return self.impl.getPhotoFiles(parentPath: parentPath, includeHidden: includeHidden, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
    }
    
    func getImages(repositoryPath:String) -> [Image] {
        return self.impl.getImages(repositoryPath: repositoryPath)
    }
    
    func getPhotoFiles(rootPath:String) -> [Image] {
        return self.impl.getPhotoFiles(rootPath: rootPath)
    }
}

class ImageCountDao {
    
    private let impl:ImageCountDaoInterface
    
    init(_ impl:ImageCountDaoInterface){
        self.impl = impl
    }
    
    static var `default`:ImageCountDao {
        let location = PreferencesController.databaseLocation()
        if location == "local" {
            return ImageCountDao(ImageCountDaoGRDB())
        }else{
            return ImageCountDao(ImageCountDaoPostgresCK())
        }
    }
    
    func countCopiedFromDevice(deviceId:String) -> Int {
        return self.impl.countCopiedFromDevice(deviceId: deviceId)
    }
    
    func countImagesShouldImport(rawStoragePath:String, deviceId:String) -> Int {
        return self.impl.countImagesShouldImport(rawStoragePath: rawStoragePath, deviceId: deviceId)
    }
    
    func countImportedAsEditable(repositoryPath:String) -> Int {
        return self.impl.countImportedAsEditable(repositoryPath: repositoryPath)
    }
    
    func countExtractedExif(repositoryPath:String) -> Int {
        return self.impl.countExtractedExif(repositoryPath: repositoryPath)
    }
    
    func countRecognizedLocation(repositoryPath:String) -> Int {
        return self.impl.countRecognizedLocation(repositoryPath: repositoryPath)
    }
    
    func countRecognizedFaces(repositoryPath:String) -> Int {
        return self.impl.countRecognizedFaces(repositoryPath: repositoryPath)
    }
    
    // count by date & place
    func countPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return self.impl.countPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // count by date & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return self.impl.countHiddenPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // count by date & event & place
    func countPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return self.impl.countPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // count by date & event & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return self.impl.countHiddenPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // MARK: - FACE
    
    func countImageWithoutFace(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutFace(repositoryRoot: repositoryRoot)
    }
    
    func countImageNotYetFacialDetection(repositoryRoot:String) -> Int {
        return self.impl.countImageNotYetFacialDetection(repositoryRoot: repositoryRoot)
    }
    
    // MARK: - ID
    
    func countImageWithoutId(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutId(repositoryRoot: repositoryRoot)
    }
    
    // MARK: - PATH
    
    // count by path~
    func countPhotoFiles(rootPath:String) -> Int {
        return self.impl.countPhotoFiles(rootPath: rootPath)
    }
    
    func countImageWithoutRepositoryPath(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutRepositoryPath(repositoryRoot: repositoryRoot)
    }
    
    func countImageWithoutSubPath(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutSubPath(repositoryRoot: repositoryRoot)
    }
    
    func countImageUnmatchedRepositoryRoot(repositoryRoot:String) -> Int {
        return self.impl.countImageUnmatchedRepositoryRoot(repositoryRoot: repositoryRoot)
    }
    
    func countImages(repositoryRoot:String) -> Int {
        return self.impl.countImages(repositoryRoot: repositoryRoot)
    }
    
    func countHiddenImages(repositoryRoot:String) -> Int {
        return self.impl.countHiddenImages(repositoryRoot: repositoryRoot)
    }
    
    func countContainersWithoutRepositoryPath(repositoryRoot:String) -> Int {
        return self.impl.countContainersWithoutRepositoryPath(repositoryRoot: repositoryRoot)
    }
    
    func countContainersWithoutSubPath(repositoryRoot:String) -> Int {
        return self.impl.countContainersWithoutSubPath(repositoryRoot: repositoryRoot)
    }
}

class ImageDuplicationDao {
    
    private let impl:ImageDuplicationDaoInterface
    
    init(_ impl:ImageDuplicationDaoInterface){
        self.impl = impl
    }
    
    static var `default`:ImageDuplicationDao {
        let location = PreferencesController.databaseLocation()
        if location == "local" {
            return ImageDuplicationDao(ImageDuplicateDaoGRDB())
        }else{
            return ImageDuplicationDao(ImageDuplicateDaoPostgresCK())
        }
    }
    
    func reloadDuplicatePhotos() {
        return self.impl.reloadDuplicatePhotos()
    }
    
    func getDuplicatePhotos() -> Duplicates {
        return self.impl.getDuplicatePhotos()
    }
    
    func getDuplicatedImages(repositoryRoot:String, theOtherRepositoryRoot:String) -> [String:[Image]] {
        return self.impl.getDuplicatedImages(repositoryRoot: repositoryRoot, theOtherRepositoryRoot: theOtherRepositoryRoot)
    }
    
    func getChiefImageOfDuplicatedSet(duplicatesKey:String) -> Image? {
        return self.impl.getChiefImageOfDuplicatedSet(duplicatesKey: duplicatesKey)
    }
    
    func getFirstImageOfDuplicatedSet(duplicatesKey:String) -> Image? {
        return self.impl.getFirstImageOfDuplicatedSet(duplicatesKey: duplicatesKey)
    }
    
    func markImageDuplicated(path:String, duplicatesKey:String?, hide:Bool) {
        return self.impl.markImageDuplicated(path: path, duplicatesKey: duplicatesKey, hide: hide)
    }
}

class ImageFaceDao {
    
    private let impl:ImageFaceDaoInterface
    
    init(_ impl:ImageFaceDaoInterface){
        self.impl = impl
    }
    
    static var `default`:ImageFaceDao {
        let location = PreferencesController.databaseLocation()
        if location == "local" {
            return ImageFaceDao(ImageFaceDaoGRDB())
        }else{
            return ImageFaceDao(ImageFaceDaoPostgresCK())
        }
    }
    
    func updateImageScannedFace(imageId:String, facesCount:Int = 0) -> ExecuteState {
        return self.impl.updateImageScannedFace(imageId: imageId, facesCount: facesCount)
    }
    
    func updateImageRecognizedFace(imageId:String, recognizedPeopleIds:String = "") -> ExecuteState {
        return self.impl.updateImageRecognizedFace(imageId: imageId, recognizedPeopleIds: recognizedPeopleIds)
    }
}
