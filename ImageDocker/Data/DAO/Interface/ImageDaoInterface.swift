//
//  ImageDaoInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/18.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

protocol ImageRecordDaoInterface {
    
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String?) -> Image
    
    func getImage(path:String) -> Image?
    
    func getImage(id:String) -> Image?
    
    func saveImage(image: Image) -> ExecuteState
    
    func deletePhoto(atPath path:String, updateFlag:Bool) -> ExecuteState
    
    func updateImagePaths(oldPath:String, newPath:String, repositoryPath:String, subPath:String, containerPath:String, id:String) -> ExecuteState
    
    func updateImageRawBase(oldRawPath:String, newRawPath:String) -> ExecuteState
    
    func updateImageRawBase(repositoryPath:String, rawPath:String) -> ExecuteState
    
    func updateImageRawBase(pathStartsWith path:String, rawPath:String) -> ExecuteState
    
    func updateImageRepositoryBase(pathStartsWith path:String, repositoryPath:String) -> ExecuteState
    
    func updateImageRepositoryBase(oldRepositoryPath:String, newRepository:String) -> ExecuteState
    
    func updateImagePath(repositoryPath:String) -> ExecuteState
    
    // MARK: - DATE
    
    func updateImageDates(path:String, date:Date, fields:Set<String>) -> ExecuteState
    
    // MARK: - DESCRIPTION
    
    func storeImageDescription(path:String, shortDescription:String?, longDescription:String?) -> ExecuteState
}

protocol ImageSearchDaoInterface {
    
    func getAllPlacesAndDates(imageSource: [String]?, cameraModel: [String]?) -> [Moment]
    
    // MARK: - Options
    
    func getImageSources() -> [String:Bool]
    
    func getCameraModel() -> [String:Bool]
    
    // MARK: - MOMENTS
    
    func getMoments(_ condition:MomentCondition, year:Int, month:Int) -> [Moment]
    
    func getAllMoments(imageSource:[String]?, cameraModel:[String]?) -> [Moment]
    
    // MARK: - PLACES
    
    func getMomentsByPlace(_ condition:MomentCondition, parent:Moment?) -> [Moment]
    
    func getImageEvents() -> [Moment]
    
    func getMomentsByEvent(event:String, category:String, year:Int, month:Int) -> [Moment]
    
    func getYears(event:String?) -> [Int]
    
    func getDatesByYear(year:Int, event:String?) -> [String:[String]]
    
    // MARK: - COLLECTION
    
    // get by date & place
    func getPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool, country:String, province:String, city:String, place:String?, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? , pageSize:Int, pageNumber:Int) -> [Image]
    
    // get by date & event & place
    func getPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String, province:String, city:String, place:String, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)?, pageSize:Int, pageNumber:Int) -> [Image]
    
    // MARK: - SEARCH
    
    // search by date & people & any keywords
    func searchPhotoFiles(years:[Int], months:[Int], days:[Int], peopleIds:[String], keywords:[String], includeHidden:Bool, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? , pageSize:Int, pageNumber:Int) -> [Image]
    
    // MARK: - DATE
    
    
    func getImagesByDate(year:Int, month:Int, day:Int, event:String?) -> [Image]
    
    func getImagesByYear(year:String?, scannedFace:Bool?, recognizedFace:Bool?) -> [Image]
    
    func getImagesByDate(photoTakenDate:Date, event:String?) -> [Image]
    
    func getImagesByHour(photoTakenDate:Date) -> [Image]
    
    // MARK: - LARGET VIEW
    
    func getMaxPhotoTakenYear() -> Int
    
    func getMinPhotoTakenYear() -> Int
    
    func getSqlByTodayInPrevious() -> String
    
    func getYearsByTodayInPrevious() -> [Int]
    
    func getDatesAroundToday() -> [String]
    
    func getDatesByTodayInPrevious(year:Int) -> [String]
    
    // MARK: - EXIF
    
    func getPhotoFilesWithoutExif(limit:Int?) -> [Image]
    
    func getPhotoFilesWithoutExif(repositoryPath:String, limit:Int?) -> [Image]
    
    // MARK: - LOCATION
    
    func getPhotoFilesWithoutLocation() -> [Image]
    
    func getPhotoFiles(after date:Date) -> [Image]
    
    // MARK: - FACE
    
    func getImagesWithoutFace(repositoryRoot:String, includeScanned:Bool) -> [Image]
    
    // MARK: - PATH
    
    func getAllPhotoPaths(includeHidden:Bool) -> Set<String>
    
    func getAllPhotoPaths(repositoryPath:String, includeHidden:Bool) -> Set<String>
    
    func getPhotoFilesWithoutSubPath(rootPath:String) -> [Image]
    
    func getPhotoFiles(parentPath:String, includeHidden:Bool, pageSize:Int, pageNumber:Int, subdirectories:Bool) -> [Image]
    
    func getImages(repositoryPath:String) -> [Image]
    
    func getPhotoFiles(rootPath:String) -> [Image]
}

protocol ImageCountDaoInterface {
    
    
    
    func countCopiedFromDevice(deviceId:String) -> Int
    
    func countImagesShouldImport(rawStoragePath:String, deviceId:String) -> Int
    
    func countImportedAsEditable(repositoryPath:String) -> Int
    
    func countExtractedExif(repositoryPath:String) -> Int
    
    func countRecognizedLocation(repositoryPath:String) -> Int
    
    func countRecognizedFaces(repositoryPath:String) -> Int
    
    // count by date & place
    func countPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool, country:String, province:String, city:String, place:String?, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?) -> Int
    
    // count by date & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool, country:String, province:String, city:String, place:String?, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?) -> Int
    
    // count by date & event & place
    func countPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String, province:String, city:String, place:String, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?) -> Int
    
    // count by date & event & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String, province:String, city:String, place:String, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?) -> Int
    
    // MARK: - FACE
    
    func countImageWithoutFace(repositoryRoot:String) -> Int
    
    func countImageNotYetFacialDetection(repositoryRoot:String) -> Int
    
    // MARK: - ID
    
    func countImageWithoutId(repositoryRoot:String) -> Int
    
    // MARK: - PATH
    
    // count by path~
    func countPhotoFiles(rootPath:String) -> Int
    
    func countImageWithoutRepositoryPath(repositoryRoot:String) -> Int
    
    func countImageWithoutSubPath(repositoryRoot:String) -> Int
    
    func countImageUnmatchedRepositoryRoot(repositoryRoot:String) -> Int
    
    func countImages(repositoryRoot:String) -> Int
    
    func countHiddenImages(repositoryRoot:String) -> Int
    
    func countContainersWithoutRepositoryPath(repositoryRoot:String) -> Int
    
    func countContainersWithoutSubPath(repositoryRoot:String) -> Int
}

protocol ImageDuplicationDaoInterface {
    
    func reloadDuplicatePhotos()
    
    func getDuplicatePhotos() -> Duplicates
    
    func getDuplicatePhotos(forceReload:Bool) -> Duplicates
    
    func getDuplicatedImages(repositoryRoot:String, theOtherRepositoryRoot:String) -> [String:[Image]]
    
    func getChiefImageOfDuplicatedSet(duplicatesKey:String) -> Image?
    
    func getFirstImageOfDuplicatedSet(duplicatesKey:String) -> Image?
    
    func markImageDuplicated(path:String, duplicatesKey:String?, hide:Bool) 
}

protocol ImageFaceDaoInterface {
    
    func updateImageScannedFace(imageId:String, facesCount:Int) -> ExecuteState
    
    func updateImageRecognizedFace(imageId:String, recognizedPeopleIds:String) -> ExecuteState
}
