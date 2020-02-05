//
//  ImageDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/25.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class ImageRecordDao {
    
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String? = nil) -> Image {
        return ModelStore.default.getOrCreatePhoto(filename: filename, path: path, parentPath: parentPath, repositoryPath: repositoryPath)
    }
    
    func getImage(path:String) -> Image? {
        return ModelStore.default.getImage(path: path)
    }
    
    func getImage(id:String) -> Image? {
        return ModelStore.default.getImage(id: id)
    }
    
    func saveImage(image: Image) -> ExecuteState {
        return ModelStore.default.saveImage(image: image)
    }
    
    func deletePhoto(atPath path:String, updateFlag:Bool = true) -> ExecuteState {
        return ModelStore.default.deletePhoto(atPath: path, updateFlag: updateFlag)
    }
    
    func updateImagePaths(oldPath:String, newPath:String, repositoryPath:String, subPath:String, containerPath:String, id:String) -> ExecuteState {
        return ModelStore.default.updateImagePaths(oldPath: oldPath, newPath: newPath, repositoryPath: repositoryPath, subPath: subPath, containerPath: containerPath, id: id)
    }
    
    func updateImageRawBase(oldRawPath:String, newRawPath:String) -> ExecuteState {
        return ModelStore.default.updateImageRawBase(oldRawPath: oldRawPath, newRawPath: newRawPath)
    }
    
    func updateImageRawBase(repositoryPath:String, rawPath:String) -> ExecuteState {
        return ModelStore.default.updateImageRawBase(repositoryPath: repositoryPath, rawPath: rawPath)
    }
    
    func updateImageRawBase(pathStartsWith path:String, rawPath:String) -> ExecuteState {
        return ModelStore.default.updateImageRawBase(pathStartsWith: path, rawPath: rawPath)
    }
    
    func updateImageRepositoryBase(pathStartsWith path:String, repositoryPath:String) -> ExecuteState {
        return ModelStore.default.updateImageRepositoryBase(pathStartsWith: path, repositoryPath: repositoryPath)
    }
    
    func updateImageRepositoryBase(oldRepositoryPath:String, newRepository:String) -> ExecuteState {
        return ModelStore.default.updateImageRepositoryBase(oldRepositoryPath: oldRepositoryPath, newRepository: newRepository)
    }
    
    func updateImagePath(repositoryPath:String) -> ExecuteState {
        return ModelStore.default.updateImagePath(repositoryPath: repositoryPath)
    }
    
    // MARK: - DATE
    
    func updateImageDates(path:String, date:Date, fields:Set<String>) -> ExecuteState {
        return ModelStore.default.updateImageDates(path: path, date: date, fields: fields)
    }
    
    // MARK: - DESCRIPTION
    
    func storeImageDescription(path:String, shortDescription:String?, longDescription:String?) -> ExecuteState {
        return ModelStore.default.storeImageDescription(path: path, shortDescription: shortDescription, longDescription: longDescription)
    }
    
    
}

class ImageSearchDao {
    
    
    // MARK: - Options
    
    func getImageSources() -> [String:Bool]{
        return ModelStore.default.getImageSources()
    }
    
    func getCameraModel() -> [String:Bool] {
        return ModelStore.default.getCameraModel()
    }
    
    // MARK: - MOMENTS
    
    func getMoments(_ condition:MomentCondition, year:Int = 0, month:Int = 0) -> [Moment] {
        return ModelStore.default.getMoments(condition, year: year, month: month)
    }
    
    func getAllMoments(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Moment] {
        let result = ModelStore.default.getAllDates(imageSource: imageSource, cameraModel: cameraModel)
        return Moments().readMoments(result)
    }
    
    // MARK: - PLACES
    
    func getMomentsByPlace(_ condition:MomentCondition, parent:Moment? = nil) -> [Moment] {
        return ModelStore.default.getMomentsByPlace(condition, parent: parent)
    }
    
    func getAllPlacesWithDates(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Moment] {
        let result = ModelStore.default.getAllPlacesAndDates(imageSource: imageSource, cameraModel: cameraModel)
        return Moments().readPlaces(result)
    }
    
    func getImageEvents() -> [Moment] {
        return ModelStore.default.getImageEvents()
    }
    
    func getMomentsByEvent(event:String, category:String, year:Int = 0, month:Int = 0) -> [Moment] {
        return ModelStore.default.getMomentsByEvent(event: event, category: category, year: year, month: month)
    }
    
    func getYears(event:String? = nil) -> [Int] {
        return ModelStore.default.getYears(event: event)
    }
    
    func getDatesByYear(year:Int, event:String? = nil) -> [String:[String]] {
        return ModelStore.default.getDatesByYear(year: year, event: event)
    }
    
    // MARK: - COLLECTION
    
    // get by date & place
    func getPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return ModelStore.default.getPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    // get by date & event & place
    func getPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return ModelStore.default.getPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    // MARK: - SEARCH
    
    // search by date & people & any keywords
    func searchPhotoFiles(years:[Int], months:[Int], days:[Int], peopleIds:[String], keywords:[String], includeHidden:Bool = true, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return ModelStore.default.searchPhotoFiles(years: years, months: months, days: days, peopleIds: peopleIds, keywords: keywords, includeHidden: includeHidden, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    // MARK: - DATE
    
    
    func getImagesByDate(year:Int, month:Int, day:Int, event:String? = nil) -> [Image] {
        return ModelStore.default.getImagesByDate(year: year, month: month, day: day, event: event)
    }
    
    func getImagesByYear(year:String? = nil, scannedFace:Bool? = nil, recognizedFace:Bool? = nil) -> [Image] {
        return ModelStore.default.getImagesByYear(year: year, scannedFace: scannedFace, recognizedFace: recognizedFace)
    }
    
    func getImagesByDate(photoTakenDate:Date, event:String? = nil) -> [Image] {
        return ModelStore.default.getImagesByDate(photoTakenDate: photoTakenDate, event: event)
    }
    
    func getImagesByHour(photoTakenDate:Date) -> [Image] {
        return ModelStore.default.getImagesByHour(photoTakenDate: photoTakenDate)
    }
    
    func getYearsByTodayInPrevious() -> [Int] {
        return ModelStore.default.getYearsByTodayInPrevious()
    }
    
    func getDatesAroundToday() -> [String] {
        return ModelStore.default.getDatesAroundToday()
    }
    
    func getDatesByTodayInPrevious(year:Int) -> [String] {
        return ModelStore.default.getDatesByTodayInPrevious(year: year)
    }
    
    // MARK: - EXIF
    
    func getPhotoFilesWithoutExif(limit:Int? = nil) -> [Image] {
        return ModelStore.default.getPhotoFilesWithoutExif(limit: limit)
    }
    
    // MARK: - LOCATION
    
    func getPhotoFilesWithoutLocation() -> [Image] {
        return ModelStore.default.getPhotoFilesWithoutLocation()
    }
    
    func getPhotoFiles(after date:Date) -> [Image] {
        return ModelStore.default.getPhotoFiles(after: date)
    }
    
    // MARK: - FACE
    
    func getImagesWithoutFace(repositoryRoot:String, includeScanned:Bool = false) -> [Image] {
        return ModelStore.default.getImagesWithoutFace(repositoryRoot: repositoryRoot, includeScanned: includeScanned)
    }
    
    // MARK: - PATH
    
    func getAllPhotoPaths(includeHidden:Bool = true) -> Set<String> {
        return ModelStore.default.getAllPhotoPaths(includeHidden: includeHidden)
    }
    
    func getPhotoFilesWithoutSubPath(rootPath:String) -> [Image] {
        return ModelStore.default.getPhotoFilesWithoutSubPath(rootPath: rootPath)
    }
    
    func getPhotoFiles(parentPath:String, includeHidden:Bool = true, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false) -> [Image] {
        return ModelStore.default.getPhotoFiles(parentPath: parentPath, includeHidden: includeHidden, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
    }
    
    func getImages(repositoryPath:String) -> [Image] {
        return ModelStore.default.getImages(repositoryPath: repositoryPath)
    }
    
    func getPhotoFiles(rootPath:String) -> [Image] {
        return ModelStore.default.getPhotoFiles(rootPath: rootPath)
    }
    
    // MARK: - EXPORT
    
    func getAllExportedImages(includeHidden:Bool = true) -> [Image] {
        return ModelStore.default.getAllExportedImages(includeHidden: includeHidden)
    }
    
    func getAllExportedPhotoFilenames(includeHidden:Bool = true) -> Set<String> {
        return ModelStore.default.getAllExportedPhotoFilenames(includeHidden: includeHidden)
    }
    
    func getAllPhotoFilesForExporting(after date:Date, limit:Int? = nil) -> [Image] {
        return ModelStore.default.getAllPhotoFilesForExporting(after: date, limit: limit)
    }
    
    func getAllPhotoFilesMarkedExported() -> [Image] {
        return ModelStore.default.getAllPhotoFilesMarkedExported()
    }
}

class ImageCountDao {
    
    // count by date & place
    func countPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return ModelStore.default.countPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // count by date & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return ModelStore.default.countHiddenPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // count by date & event & place
    func countPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return ModelStore.default.countPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // count by date & event & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return ModelStore.default.countHiddenPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // MARK: - FACE
    
    func countImageWithoutFace(repositoryRoot:String) -> Int {
        return ModelStore.default.countImageWithoutFace(repositoryRoot: repositoryRoot)
    }
    
    func countImageNotYetFacialDetection(repositoryRoot:String) -> Int {
        return ModelStore.default.countImageNotYetFacialDetection(repositoryRoot: repositoryRoot)
    }
    
    // MARK: - ID
    
    func countImageWithoutId(repositoryRoot:String) -> Int {
        return ModelStore.default.countImageWithoutId(repositoryRoot: repositoryRoot)
    }
    
    // MARK: - PATH
    
    // count by path~
    func countPhotoFiles(rootPath:String) -> Int {
        return ModelStore.default.countPhotoFiles(rootPath: rootPath)
    }
    
    func countImageWithoutRepositoryPath(repositoryRoot:String) -> Int {
        return ModelStore.default.countImageWithoutRepositoryPath(repositoryRoot: repositoryRoot)
    }
    
    func countImageWithoutSubPath(repositoryRoot:String) -> Int {
        return ModelStore.default.countImageWithoutSubPath(repositoryRoot: repositoryRoot)
    }
    
    func countImageUnmatchedRepositoryRoot(repositoryRoot:String) -> Int {
        return ModelStore.default.countImageUnmatchedRepositoryRoot(repositoryRoot: repositoryRoot)
    }
    
    func countImages(repositoryRoot:String) -> Int {
        return ModelStore.default.countImages(repositoryRoot: repositoryRoot)
    }
    
    func countHiddenImages(repositoryRoot:String) -> Int {
        return ModelStore.default.countHiddenImages(repositoryRoot: repositoryRoot)
    }
    
    func countContainersWithoutRepositoryPath(repositoryRoot:String) -> Int {
        return ModelStore.default.countContainersWithoutRepositoryPath(repositoryRoot: repositoryRoot)
    }
    
    func countContainersWithoutSubPath(repositoryRoot:String) -> Int {
        return ModelStore.default.countContainersWithoutSubPath(repositoryRoot: repositoryRoot)
    }
    
    // MARK: - EXPORT
    
    func countAllPhotoFilesForExporting(after date:Date) -> Int {
        return ModelStore.default.countAllPhotoFilesForExporting(after: date)
    }
}

class ImageDuplicationDao {
    
    func reloadDuplicatePhotos() {
        return ModelStore.default.reloadDuplicatePhotos()
    }
    
    func getDuplicatePhotos() -> Duplicates {
        return ModelStore.default.getDuplicatePhotos()
    }
    
    func getDuplicatedImages(repositoryRoot:String, theOtherRepositoryRoot:String) -> [String:[Image]] {
        return ModelStore.default.getDuplicatedImages(repositoryRoot: repositoryRoot, theOtherRepositoryRoot: theOtherRepositoryRoot)
    }
    
    func getChiefImageOfDuplicatedSet(duplicatesKey:String) -> Image? {
        return ModelStore.default.getChiefImageOfDuplicatedSet(duplicatesKey: duplicatesKey)
    }
    
    func getFirstImageOfDuplicatedSet(duplicatesKey:String) -> Image? {
        return ModelStore.default.getFirstImageOfDuplicatedSet(duplicatesKey: duplicatesKey)
    }
    
    func markImageDuplicated(path:String, duplicatesKey:String?, hide:Bool) {
        return ModelStore.default.markImageDuplicated(path: path, duplicatesKey: duplicatesKey, hide: hide)
    }
}

class ImageFaceDao {
    
    func updateImageScannedFace(imageId:String, facesCount:Int = 0) -> ExecuteState {
        return ModelStore.default.updateImageScannedFace(imageId: imageId, facesCount: facesCount)
    }
    
    func updateImageRecognizedFace(imageId:String, recognizedPeopleIds:String = "") -> ExecuteState {
        return ModelStore.default.updateImageRecognizedFace(imageId: imageId, recognizedPeopleIds: recognizedPeopleIds)
    }
}

class ImageExportDao {
    
    
    func cleanImageExportTime(path:String) -> ExecuteState {
        return ModelStore.default.cleanImageExportTime(path: path)
    }
    
    func storeImageOriginalMD5(path:String, md5:String) -> ExecuteState {
        return ModelStore.default.storeImageOriginalMD5(path: path, md5: md5)
    }
    
    func storeImageExportedMD5(path:String, md5:String) -> ExecuteState {
        return ModelStore.default.storeImageExportedMD5(path: path, md5: md5)
    }
    
    func storeImageExportSuccess(path:String, date:Date, exportToPath:String, exportedFilename:String, exportedMD5:String, exportedLongDescription:String) -> ExecuteState {
        return ModelStore.default.storeImageExportSuccess(path: path, date: date, exportToPath: exportToPath, exportedFilename: exportedFilename, exportedMD5: exportedMD5, exportedLongDescription: exportedLongDescription)
    }
    
    func storeImageExportedTime(path:String, date:Date) -> ExecuteState {
        return ModelStore.default.storeImageExportedTime(path: path, date: date)
    }
    
    func storeImageExportFail(path:String, date:Date, message:String) -> ExecuteState {
        return ModelStore.default.storeImageExportFail(path: path, date: date, message: message)
    }
    
    func cleanImageExportPath(path:String) -> ExecuteState {
        return ModelStore.default.cleanImageExportPath(path: path)
    }
}
