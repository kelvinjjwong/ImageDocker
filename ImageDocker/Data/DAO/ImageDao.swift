//
//  ImageDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/25.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

protocol ImageDao : class {
    
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String?) -> Image
    
    func getImage(path:String) -> Image?
    
    func getImage(id:String) -> Image?
    
    func getPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool, country:String, province:String, city:String, place:String?, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)?, pageSize:Int, pageNumber:Int) -> [Image]
    
    func getPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String, province:String, city:String, place:String, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)?, pageSize:Int, pageNumber:Int) -> [Image]
    
    func searchPhotoFiles(years:[Int], months:[Int], days:[Int], peopleIds:[String], keywords:[String], includeHidden:Bool, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)?, pageSize:Int, pageNumber:Int) -> [Image]
    
    func getImagesByDate(year:Int, month:Int, day:Int, event:String?) -> [Image]
    
    func getImagesByYear(year:String?, scannedFace:Bool?, recognizedFace:Bool?) -> [Image]
    
    func getImagesByDate(photoTakenDate:Date, event:String?) -> [Image]
    
    func getImagesByHour(photoTakenDate:Date) -> [Image]
    
    func getYearsByTodayInPrevious() -> [Int]
    
    func getDatesAroundToday() -> [String]
    
    func getDatesByTodayInPrevious(year:Int) -> [String]
    
    func getPhotoFilesWithoutExif(limit:Int?) -> [Image]
    
    func getPhotoFilesWithoutLocation() -> [Image]
    
    func getPhotoFiles(after date:Date) -> [Image]
    
    func getImagesWithoutFace(repositoryRoot:String, includeScanned:Bool) -> [Image]
    
    func getAllPhotoPaths(includeHidden:Bool) -> Set<String>
    
    func getPhotoFilesWithoutSubPath(rootPath:String) -> [Image]
    
    func getPhotoFiles(parentPath:String, includeHidden:Bool, pageSize:Int, pageNumber:Int, subdirectories:Bool) -> [Image]
    
    func getImages(repositoryPath:String) -> [Image]
    
    func getPhotoFiles(rootPath:String) -> [Image]
    
    func getAllExportedImages(includeHidden:Bool) -> [Image]
    
    func getAllExportedPhotoFilenames(includeHidden:Bool) -> Set<String>
    
    func getAllPhotoFilesForExporting(after date:Date, limit:Int?) -> [Image]
    
    func getAllPhotoFilesMarkedExported() -> [Image]
    
    func saveImage(image: Image) -> ExecuteState
    
    func deletePhoto(atPath path:String, updateFlag:Bool) -> ExecuteState
    
    func updateImagePaths(oldPath:String, newPath:String, repositoryPath:String, subPath:String, containerPath:String, id:String) -> ExecuteState
    
    func updateImageRawBase(oldRawPath:String, newRawPath:String) -> ExecuteState
    
    func updateImageRawBase(repositoryPath:String, rawPath:String) -> ExecuteState
    
    func updateImageRawBase(pathStartsWith path:String, rawPath:String) -> ExecuteState
    
    func updateImageRepositoryBase(pathStartsWith path:String, repositoryPath:String) -> ExecuteState
    
    func updateImageRepositoryBase(oldRepositoryPath:String, newRepository:String) -> ExecuteState
    
    func updateImagePath(repositoryPath:String) -> ExecuteState
    
    func updateImageScannedFace(imageId:String, facesCount:Int) -> ExecuteState
    
    func updateImageRecognizedFace(imageId:String, recognizedPeopleIds:String) -> ExecuteState
    
    func updateImageDates(path:String, date:Date, fields:Set<String>) -> ExecuteState
    
    func storeImageDescription(path:String, shortDescription:String?, longDescription:String?) -> ExecuteState
    
    func cleanImageExportTime(path:String) -> ExecuteState
    
    func storeImageOriginalMD5(path:String, md5:String) -> ExecuteState
    
    func storeImageExportedMD5(path:String, md5:String) -> ExecuteState
    
    func storeImageExportSuccess(path:String, date:Date, exportToPath:String, exportedFilename:String, exportedMD5:String, exportedLongDescription:String) -> ExecuteState
    
    func storeImageExportedTime(path:String, date:Date) -> ExecuteState
    
    func storeImageExportFail(path:String, date:Date, message:String) -> ExecuteState
    
    func cleanImageExportPath(path:String) -> ExecuteState
    
    func reloadDuplicatePhotos()
    
    func getDuplicatePhotos() -> Duplicates
    
    func getDuplicatedImages(repositoryRoot:String, theOtherRepositoryRoot:String) -> [String:[Image]]
    
    func getChiefImageOfDuplicatedSet(duplicatesKey:String) -> Image?
    
    func getFirstImageOfDuplicatedSet(duplicatesKey:String) -> Image?
    
    func markImageDuplicated(path:String, duplicatesKey:String?, hide:Bool)
    
    func countPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool, country:String, province:String, city:String, place:String?, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?) -> Int
    
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool, country:String, province:String, city:String, place:String?, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?) -> Int
    
    func countPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String, province:String, city:String, place:String, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?) -> Int
    
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String, province:String, city:String, place:String, includeHidden:Bool, imageSource:[String]?, cameraModel:[String]?) -> Int
    
    func countImageWithoutFace(repositoryRoot:String) -> Int
    
    func countImageNotYetFacialDetection(repositoryRoot:String) -> Int
    
    func countImageWithoutId(repositoryRoot:String) -> Int
    
    func countPhotoFiles(rootPath:String) -> Int
    
    func countImageWithoutRepositoryPath(repositoryRoot:String) -> Int
    
    func countImageWithoutSubPath(repositoryRoot:String) -> Int
    
    func countImageUnmatchedRepositoryRoot(repositoryRoot:String) -> Int
    
    func countImages(repositoryRoot:String) -> Int
    
    func countHiddenImages(repositoryRoot:String) -> Int
    
    func countContainersWithoutRepositoryPath(repositoryRoot:String) -> Int
    
    func countContainersWithoutSubPath(repositoryRoot:String) -> Int
    
    func countAllPhotoFilesForExporting(after date:Date) -> Int
    
    func getLastPhotoTakenDateOfRepositories() -> [String:String]
    
    func getImageSources() -> [String:Bool]
    
    func getCameraModel() -> [String:Bool]
    
    func getYears(event:String?) -> [Int]
    
    func getDatesByYear(year:Int, event:String?) -> [String:[String]]
    
}
