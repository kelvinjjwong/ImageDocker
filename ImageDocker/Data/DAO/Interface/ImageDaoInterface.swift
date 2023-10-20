//
//  ImageDaoInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/18.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

protocol ImageRecordDaoInterface {
    
    // MARK: QUERY
    
    /// - parameter path: Something like /Volumes/repository/sub/container/filename.ext
    /// - important: replaced by *getImage(id:)*
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - attention: to be deprecated
    func getImage(path:String) -> Image?
    
    /// A usual way to find a database record of Image by Image.id
    /// - parameter id: a UUID
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    func getImage(id:String) -> Image?
    
    /// An alternative way to find a database record of Image by paths
    /// - parameter repositoryVolume: Something like /Volumes/Machintosh
    /// - parameter repositoryPath: Something like /repository/base/path
    /// - parameter subPath: Something like Camera/filename.ext
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    func findImage(repositoryVolume:String, repositoryPath:String, subPath:String) -> Image?
    
    /// A usual way to find a database record of Image by ImageRepository.id
    /// - parameter repositoryId:
    /// - parameter subPath:
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    func findImage(repositoryId:Int, subPath:String) -> Image?
    
    // MARK: CRUD
    
    /// - parameter repositoryId: **mandatory** Integer id of ImageRepository.id
    /// - parameter containerId: **mandatory** Integer id of ImageContainer.id
    /// - parameter repositoryVolume: **optional** Something like /Volumes/Machintosh
    /// - parameter repositoryPath: **optional** Something like /repository/base/path
    /// - parameter subPath: **mandatory** Something like Camera/filename.ext
    /// - attention: so far we are still using String type *path* as primary key, in future we should use UUID *id* as primary key instead
    /// - returns: A database record of Image if successfully creates, otherwise return nil
    /// - version: 2023.1.21
    func createImage(repositoryId:Int, containerId:Int, repositoryVolume:String, repositoryPath:String, subPath:String) -> Image?
    
    /// Get a database record of Image if exists, otherwise create a new database record for it
    /// - returns: a database record of Image
    /// - attention: will deprecate
    /// - version: 2019.12.27
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String?) -> Image
    
    
    /// Update every fields of a database record of Image
    /// - version: 2019.12.27
    func saveImage(image: Image) -> ExecuteState
    
    /// Delete a database record of Image by Image.path
    /// - important: will deprecate
    /// - version: 2019.12.27
    func deletePhoto(atPath path:String, updateFlag:Bool) -> ExecuteState
    
    
    /// Delete a database record of Image by Image.id
    /// - since: 2023.1.29
    /// - version: 2023.1.29
    func deleteImage(id:String, updateFlag: Bool) -> ExecuteState
    
    // MARK: UPDATE ID
    
    func generateImageIdByPath(repositoryVolume:String, repositoryPath:String, subPath:String) -> (ExecuteState, String)
    
    func generateImageIdByContainerIdAndSubPath(containerId:Int, subPath:String) -> (ExecuteState, String)
    
    /// - attention: will deprecate
    func updateImageWithContainerId(id:String, repositoryId:Int, containerId:Int) -> ExecuteState
    
    // MARK: - DATE
    
    func updateImageDateTimeFromFilename(path:String, dateTimeFromFilename:String) -> ExecuteState
    
    func updateImageDateTimeFromFilename(id:String, dateTimeFromFilename:String) -> ExecuteState
    
    func updateImageDates(path:String, date:Date, fields:Set<String>) -> ExecuteState
    
    // MARK: - DESCRIPTION
    
    func storeImageDescription(path:String, shortDescription:String?, longDescription:String?) -> ExecuteState
    
    func updateImageRotation(path:String, rotation:Int) -> ExecuteState
    
    func storeImageFamily(imageId:String, familyId:String, ownerId:String, familyName: String, owner: String) -> ExecuteState
    
    func updateImagePaths(id: String, newPath: String, repositoryPath: String, subPath: String, containerPath: String) -> ExecuteState
    
    func updateImagePaths(oldPath: String, newPath: String, repositoryPath: String, subPath: String, containerPath: String, id: String) -> ExecuteState
    
    func hideUnsupportedRecords() -> ExecuteState
}

protocol ImageSearchDaoInterface {
    
    // MARK: - Options
    
    func getImageSources() -> [String:Bool]
    
    func getCameraModel() -> [String:Bool]
    
    // MARK: - MOMENTS
    
    func getMoments(_ momentCondition:MomentCondition, year:Int, month:Int, condition:SearchCondition?) -> [Moment]
    
    // MARK: - PLACES
    
    func getMomentsByPlace(_ momentCondition:MomentCondition, parent:Moment?, condition:SearchCondition?) -> [Moment]
    
    func getImageEvents(condition:SearchCondition?) -> [Moment]
    
    func getMomentsByEvent(event:String, category:String, year:Int, month:Int, condition:SearchCondition?) -> [Moment]
    
    func getYears(event:String?) -> [Int]
    
    func getDatesByYear(year:Int, event:String?) -> [String:[String]]
    
    // MARK: - COLLECTION
    
    // get by date & place
    func getPhotoFiles(filter:CollectionFilter, year:Int, month:Int, day:Int, ignoreDate:Bool, country:String, province:String, city:String, place:String?, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? , pageSize:Int, pageNumber:Int) -> [Image]
    
    // get by date & event & place
    func getPhotoFiles(filter:CollectionFilter, year:Int, month:Int, day:Int, event:String, country:String, province:String, city:String, place:String, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)?, pageSize:Int, pageNumber:Int) -> [Image]
    
    // MARK: - SEARCH
    func searchImages(condition:SearchCondition, includeHidden:Bool, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)?, pageSize:Int, pageNumber:Int) -> [Image]
    
    // MARK: - DATE
    
    
    func getImagesByDate(year:Int, month:Int, day:Int, event:String?) -> [Image]
    
    func getImagesByDate(photoTakenDate:Date, event:String?) -> [Image]
    
    // MARK: - LARGET VIEW
    
    func getYearsByTodayInPrevious() -> [Int]
    
    func getDatesAroundToday() -> [String]
    
    func getDatesByTodayInPrevious(year:Int) -> [String]
    
    // MARK: - EXIF
    
    func getPhotoFilesWithoutExif(limit:Int?) -> [Image]
    
    func getPhotoFilesWithoutExif(repositoryPath:String, limit:Int?) -> [Image]
    
    // MARK: - LOCATION
    
    func getPhotoFilesWithoutLocation(repositoryPath:String) -> [Image]
    
    // MARK: - PATH
    
    func getPhotoFiles(filter: CollectionFilter, containerId:Int, pageSize: Int, pageNumber: Int) -> [Image]
    
    func getImages(repositoryPath:String) -> [Image]
    
    func getImages(repositoryId:Int) -> [Image]
    
    func getImages(containerId:Int) -> [Image]
    
    func getPhotoFiles(rootPath:String) -> [Image]
}

protocol ImageCountDaoInterface {
    
    
    
    func countCopiedFromDevice(deviceId:String) -> Int
    
    func countImagesShouldImport(deviceId:String) -> Int
    
    func countImportedAsEditable(repositoryPath:String) -> Int
    
    func countImportedAsEditable(deviceId:String) -> Int
    
    func countExtractedExif(repositoryPath:String) -> Int
    
    func countExtractedExif(repositoryId:Int) -> Int
    
    func countRecognizedLocation(repositoryPath:String) -> Int
    
    func countRecognizedLocation(repositoryId:Int) -> Int
    
    func countRecognizedFaces(repositoryPath:String) -> Int
    
    func countRecognizedFaces(repositoryId:Int) -> Int
    
    // count by date & place
    func countPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool, country:String, province:String, city:String, place:String?) -> Int
    
    // count by date & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool, country:String, province:String, city:String, place:String?) -> Int
    
    // count by date & event & place
    func countPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String, province:String, city:String, place:String) -> Int
    
    // count by date & event & place
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String, province:String, city:String, place:String) -> Int
    
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
    
    func getDuplicatedImages(repositoryId:Int) -> [String : [Image]]
    
    func getChiefImageOfDuplicatedSet(duplicatesKey:String) -> Image?
    
    func getFirstImageOfDuplicatedSet(duplicatesKey:String) -> Image?
    
    func markImageDuplicated(path:String, duplicatesKey:String?, hide:Bool) 
}

protocol ImageFaceDaoInterface {
    
    func updateImageScannedFace(imageId:String, facesCount:Int) -> ExecuteState
    
    func updateImageRecognizedFace(imageId:String, recognizedPeopleIds:String) -> ExecuteState
}
