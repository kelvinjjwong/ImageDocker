//
//  ImageDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/25.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

// MARK: IMAGE RECORD DAO

public final class ImageRecordDao {
    
    let logger = LoggerFactory.get(category: "ImageRecordDao")
    
    private let impl:ImageRecordDaoInterface
    
    init(_ impl:ImageRecordDaoInterface) {
        self.impl = impl
    }
    
    static var `default`:ImageRecordDao {
        return ImageRecordDao(ImageRecordDaoPostgresCK())
    }
    
    // MARK: QUERY
    
    /// - caller:
    ///   - SelectionViewController.combineCheckedImages()
    ///   - SelectionViewController.markCheckedImageAsDuplicatedChief()
    ///   - ViewController.onCollectionViewItemShowDuplicate()
    /// - parameter path: Something like /Volumes/repository/sub/container/filename.ext
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - attention: to be deprecated
    /// - version: should be replaced by [getImage(id:)](x-source-tag://getImage(id))
    /// - Tag: getImage(path)
    func getImage(path:String) -> Image? {
        return self.impl.getImage(path: path)
    }
    
    /// A usual way to find a database record of Image by Image.id
    /// - parameter id: a UUID
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    /// - Tag: getImage(id)
    func getImage(id:String) -> Image? {
        return self.impl.getImage(id: id)
    }
    
    /// A usual way to find a database record of Image by ImageRepository.id
    /// - caller: NONE
    /// - parameter repositoryId: ImageRepository.id
    /// - parameter subPath: Something like Camera/filename.ext
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    /// - Tag: findImage(repositoryId)
    func findImage(repositoryId:Int, subPath:String) -> Image? {
        return self.impl.findImage(repositoryId: repositoryId, subPath: subPath)
    }
    
    /// An alternative way to find a database record of Image by paths
    /// - caller:
    ///   - RepositoryDetailViewController.[onReScanFoldersClicked()](x-source-tag://RepositoryDetailViewController.onReScanFoldersClicked())
    /// - parameter repositoryVolume: Something like /Volumes/Machintosh
    /// - parameter repositoryPath: Something like /repository/base/path
    /// - parameter subPath: Something like Camera/filename.ext
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    /// - Tag: findImage(repositoryVolume)
    func findImage(repositoryVolume:String, repositoryPath:String, subPath:String) -> Image? {
        return self.impl.findImage(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
    }
    
    func getImagesWithNullId(owner:String) -> [(Int, String)] { // repositoryId, subpath
        return self.impl.getImagesWithNullId(owner: owner)
    }
    
    func getImagesWithNullFileExt(owner:String) -> [(String, String)] { // imageId, subpath
        return self.impl.getImagesWithNullFileExt(owner: owner)
    }
    
    func getImagesWithNullOriginalMD5(owner:String) -> [(String, Int, String, String, String, String, String)] { // imageId, repositoryId, repositoryVolume, repositoryPath, storageVolume, storagePath, subpath
        return self.impl.getImagesWithNullOriginalMD5(owner: owner)
    }
    
    func getImageOriginalMD5HavingDuplicated(owner:String) -> [String] { // originalMD5
        return self.impl.getImageOriginalMD5HavingDuplicated(owner: owner)
    }
    
    func getImageIds(originalMD5:String, checkDuplicatesKey:Bool) -> [(String, Bool, String)] { // imageId, hidden, duplicatesKey
        return self.impl.getImageIds(originalMD5: originalMD5, checkDuplicatesKey: checkDuplicatesKey)
    }
    
    func hideImageWithDuplicateKey(imageId:String, duplicatesKey:String) -> ExecuteState {
        return self.impl.hideImageWithDuplicateKey(imageId: imageId, duplicatesKey: duplicatesKey)
    }
    
    func showImageWithDuplicateKey(imageId:String, duplicatesKey:String) -> ExecuteState {
        return self.impl.showImageWithDuplicateKey(imageId: imageId, duplicatesKey: duplicatesKey)
    }
    
    // MARK: CRUD
    
    /// - caller:
    ///   - RepositoryDetailViewController.[onReScanFoldersClicked()](x-source-tag://RepositoryDetailViewController.onReScanFoldersClicked())
    /// - parameter repositoryId: **mandatory** Integer id of ImageRepository.id
    /// - parameter containerId: **mandatory** Integer id of ImageContainer.id
    /// - parameter repositoryVolume: **optional** Something like /Volumes/Machintosh
    /// - parameter repositoryPath: **optional** Something like /repository/base/path
    /// - parameter subPath: **mandatory** Something like Camera/filename.ext
    /// - attention: so far we are still using String type *path* as primary key, in future we should use UUID *id* as primary key instead
    /// - returns: A database record of Image if successfully creates, otherwise return nil
    /// - version: 2023.1.21
    /// - Tag: createImage(repositoryId)
    // FIXME: repositoryVolume and repositoryPath should be delete
    func createImage(repositoryId:Int, containerId:Int, repositoryVolume:String, repositoryPath:String, subPath:String) -> Image? {
        return self.impl.createImage(repositoryId: repositoryId, containerId: containerId, repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
    }
    
    /// Create a database record of Image if not exists, during the procedure of handling import-gaps
    /// - caller
    ///   - ImageFolderTreeScanner.[applyImportGap(dbUrls:filesysUrls:fileUrlToRepo:excludedContainerPaths:taskId:indicator:)](x-source-tag://applyImportGap(dbUrls,filesysUrls,fileUrlToRepo))
    /// - attention: will deprecate
    /// - warning: should deprecate caller first
    /// - since: 2019.4.5
    /// - version: 2019.4.5
    /// - Tag: createImageIfAbsent(url)
    func createImageIfAbsent(url:String, fileUrlToRepo:[String:ImageContainer], indicator:Accumulator? = nil) -> ExecuteState {
        //self.logger.log(.trace, "CREATING PHOTO \(url.path)")
        if let repo = fileUrlToRepo[url]{
            self.logger.log(.info, "[createImageIfAbsent] Creating image \(url), repo: \(repo.repositoryPath)")
            let image = ImageFile(url: URL(fileURLWithPath: url),
                                  repository: repo,
                                  indicator: indicator,
                                  quickCreate: true
            )
            
            return image.save()
        }else{
            return .NO_RECORD
        }
    }
    
    /// Get a database record of Image if exists, otherwise create a new database record for it
    /// - caller:
    ///   - ImageFile.[init(url:repository:...)](x-source-tag://ImageFile.init(url))
    /// - returns: a database record of Image
    /// - attention: will deprecate
    /// - version: 2019.12.27
    /// - Tag: getOrCreatePhoto(filename)
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String? = nil) -> Image {
        return self.impl.getOrCreatePhoto(filename: filename, path: path, parentPath: parentPath, repositoryPath: repositoryPath)
    }
    
    /// Update every fields of a database record of Image
    /// - since: 2019.12.27
    /// - version: 2019.12.27
    /// - Tag: saveImage(image)
    func saveImage(image: Image) -> ExecuteState {
        return self.impl.saveImage(image: image)
    }
    
    /// Delete a database record of Image by Image.id
    /// - since: 2023.1.29
    /// - version: 2023.1.29
    /// - Tag: deleteImage(id)
    func deleteImage(id:String, updateFlag: Bool) -> ExecuteState {
        return self.impl.deleteImage(id: id, updateFlag: updateFlag)
    }
    
    /// Delete a database record of Image by Image.path
    /// - caller:
    ///   - ImageFolderTreeScanner.[applyImportGap(dbUrls:filesysUrls:fileUrlToRepo:excludedContainerPaths:taskId:indicator:)](x-source-tag://applyImportGap(dbUrls,filesysUrls,fileUrlToRepo))
    /// - since: 2019.12.27
    /// - version: 2019.12.27
    /// - attention: will be deprecated
    /// - version: should be replaced by [deleteImage(id:)](x-source-tag://deleteImage(id))
    /// - Tag: deletePhoto(path)
    func deletePhoto(atPath path:String, updateFlag:Bool = true) -> ExecuteState {
        return self.impl.deletePhoto(atPath: path, updateFlag: updateFlag)
    }
    
    // MARK: UPDATE ID
    
    /// - caller:
    ///   - RepositoryDetailViewController.onReScanFoldersClicked()
    /// - attention: will deprecate
    /// - Tag: updateImageWithContainerId(id)
    func updateImageWithContainerId(id:String, repositoryId:Int, containerId:Int) -> ExecuteState {
        return self.impl.updateImageWithContainerId(id: id, repositoryId: repositoryId, containerId: containerId)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.onReScanFoldersClicked()
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    /// - Tag: generateImageIdByPath(repositoryVolume)
    func generateImageIdByPath(repositoryVolume:String, repositoryPath:String, subPath:String) -> (ExecuteState, String) {
        return self.impl.generateImageIdByPath(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
    }
    
    /// - caller:
    ///   - ImageFile.init(image:...)
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    /// - Tag: generateImageIdByContainerIdAndSubPath(containerId)
    func generateImageIdByContainerIdAndSubPath(containerId:Int, subPath:String) -> (ExecuteState, String) {
        return self.impl.generateImageIdByContainerIdAndSubPath(containerId: containerId, subPath: subPath)
    }
    
    func generateImageIdByRepositoryIdAndSubPath(repositoryId:Int, subPath:String) -> (ExecuteState, String) {
        return self.impl.generateImageIdByRepositoryIdAndSubPath(repositoryId: repositoryId, subPath: subPath)
    }
    
    func updateImageFileExt(id:String, fileExt:String) -> ExecuteState {
        return self.impl.updateImageFileExt(id: id, fileExt: fileExt)
    }
    
    func updateImageOrginalMD5(id:String, md5:String) -> ExecuteState {
        return self.impl.updateImageOrginalMD5(id: id, md5: md5)
    }
    
    func updateImageMd5AndDeviceFileId(id:String, md5:String, deviceId:String, deviceFileId:String) -> ExecuteState {
        return self.impl.updateImageMd5AndDeviceFileId(id: id, md5: md5, deviceId: deviceId, deviceFileId: deviceFileId)
    }
    
    // MARK: UPDATE DATE
    
    /// - caller:
    ///   - ImageFile.init(image:...)
    /// - Tag: updateImageDateTimeFromFilename(id)
    func updateImageDateTimeFromFilename(id:String, dateTimeFromFilename:String) -> ExecuteState{
        return self.impl.updateImageDateTimeFromFilename(id: id, dateTimeFromFilename: dateTimeFromFilename)
    }
    
    /// - caller:
    ///   - DateTimeViewController.onOKClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: updateImageDates(path)
    func updateImageDates(path:String, date:Date, fields:Set<String>) -> ExecuteState {
        return self.impl.updateImageDates(path: path, date: date, fields: fields)
    }
    
    // MARK: UPDATE DESCRIPTION
    
    /// - caller:
    ///   - NotesViewController.onOKClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: storeImageDescription(path)
    func storeImageDescription(path:String, shortDescription:String?, longDescription:String?) -> ExecuteState {
        return self.impl.storeImageDescription(path: path, shortDescription: shortDescription, longDescription: longDescription)
    }
    
    func updateImageShortDescription(shortDescription:String, imageIds:[String]) -> ExecuteState {
        return self.impl.updateImageShortDescription(shortDescription: shortDescription, imageIds: imageIds)
    }
    
    func updateImageLongDescription(longDescription:String, imageIds:[String]) -> ExecuteState {
        return self.impl.updateImageLongDescription(longDescription: longDescription, imageIds: imageIds)
    }
    
    func updateImageShortAndLongDescription(shortDescription:String, longDescription:String, imageIds:[String]) -> ExecuteState {
        return self.impl.updateImageShortAndLongDescription(shortDescription: shortDescription, longDescription: longDescription, imageIds: imageIds)
    }
    
    // MARK: UPDATE EVENT
    
    func updateEvent(imageId:String, event:String) -> ExecuteState {
        return self.impl.updateEvent(imageId: imageId, event: event)
    }
    
    // MARK: UPDATE FAMILY
    
    func unlinkImageFamily(imageId:String, familyId:String) -> ExecuteState {
        return self.impl.unlinkImageFamily(imageId: imageId, familyId: familyId)
    }
    
    func unlinkImageFamilies(imageId:String) -> ExecuteState {
        return self.impl.unlinkImageFamilies(imageId: imageId)
    }
    
    func unlinkImageFamilies(familyId:String) -> ExecuteState {
        return self.impl.unlinkImageFamilies(familyId: familyId)
    }
    
    func storeImageFamily(imageId:String, familyId:String, ownerId:String, familyName: String, owner: String) -> ExecuteState {
        return self.impl.storeImageFamily(imageId: imageId, familyId: familyId, ownerId: ownerId, familyName: familyName, owner: owner)
    }
    
    // MARK: UPDATE ROTATION
    
    /// - caller:
    ///   - ImagePreviewController.onRotateClickwiseClicked()
    ///   - ImagePreviewController.onRotateCounterClockerwiseClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: updateImageRotation(path)
    func updateImageRotation(path:String, rotation:Int) -> ExecuteState {
        return self.impl.updateImageRotation(path: path, rotation: rotation)
    }
    
    // MARK: UPDATE PATH
    
    func updateImagePaths(id: String, newPath: String, repositoryPath: String, subPath: String, containerPath: String) -> ExecuteState {
        return self.impl.updateImagePaths(id: id, newPath: newPath, repositoryPath: repositoryPath, subPath: subPath, containerPath: containerPath)
    }
    
    func updateImagePaths(oldPath: String, newPath: String, repositoryPath: String, subPath: String, containerPath: String, id: String) -> ExecuteState {
        return self.impl.updateImagePaths(oldPath: oldPath, newPath: newPath, repositoryPath: repositoryPath, subPath: subPath, containerPath: containerPath, id: id)
    }
    
    func hideUnsupportedRecords() -> ExecuteState {
        return self.impl.hideUnsupportedRecords()
    }
    
    // MARK: TAGGING
    
    func tagImage(imageId:String, tag:String) -> ExecuteState {
        return self.impl.tagImage(imageId: imageId, tag: tag)
    }
    
    func untagImage(imageId:String, tag:String) -> ExecuteState {
        return self.impl.untagImage(imageId: imageId, tag: tag)
    }
}

// MARK: -
// MARK: IMAGE SEARCH DAO

class ImageSearchDao {
    
    private let impl:ImageSearchDaoInterface
    
    init(_ impl:ImageSearchDaoInterface){
        self.impl = impl
    }
    
    static var `default`:ImageSearchDao {
        return ImageSearchDao(ImageSearchDaoPostgresCK())
    }
    
    // MARK: QUERY FOR Options
    
    /// - caller:
    ///   - FilterViewController.viewDidLoad()
    /// - Tag: getImageSources()
    func getImageSources() -> [String:Bool]{
        return self.impl.getImageSources()
    }
    
    /// - caller:
    ///   - FilterViewController.viewDidLoad()
    /// - Tag: getCameraModel()
    func getCameraModel() -> [String:Bool] {
        return self.impl.getCameraModel()
    }
    
    // MARK: QUERY FOR MOMENTS
    
    /// - caller:
    ///   - MomentsTreeDataSource.loadChildren()
    /// - Tag: getMoments(momentCondition)
    func getMoments(_ momentCondition:MomentCondition, year:Int = 0, month:Int = 0, condition:SearchCondition? = nil) -> [Moment] {
        return self.impl.getMoments(momentCondition, year: year, month: month, condition: condition)
    }
    
    // MARK: - PLACES
    
    /// - caller:
    ///   - PlacesTreeDataSource.loadChildren()
    /// - Tag: getMomentsByPlace(momentCondition)
    func getMomentsByPlace(_ momentCondition:MomentCondition, parent:Moment? = nil, condition:SearchCondition? = nil) -> [Moment] {
        return self.impl.getMomentsByPlace(momentCondition, parent: parent, condition: condition)
    }
    
    /// - caller:
    ///   - EventsTreeDataSource.loadChildren()
    /// - Tag: getImageEvents(condition)
    func getImageEvents(condition:SearchCondition?) -> [Moment] {
        return self.impl.getImageEvents(condition: condition)
    }
    
    /// - caller:
    ///   - EventsTreeDataSource.loadChildren()
    /// - Tag: getMomentsByEvent(event)
    func getMomentsByEvent(event:String, category:String, year:Int = 0, month:Int = 0, condition:SearchCondition? = nil) -> [Moment] {
        return self.impl.getMomentsByEvent(event: event, category: category, year: year, month: month, condition: condition)
    }
    
    /// - caller:
    ///   - TheaterViewController.viewInit(image:byEvent:)
    ///   - TheaterViewController.viewInit(year:month:day:event:)
    /// - Tag: getYears(event)
    func getYears(event:String? = nil) -> [Int] {
        return self.impl.getYears(event: event)
    }
    
    /// - caller:
    ///   - TheaterViewController.changeYear(year:month:day:event:)
    ///   - TheaterViewController.viewInit(image:byEvent:)
    /// - Tag: getDatesByYear(year)
    func getDatesByYear(year:Int, event:String? = nil) -> [String:[String]] {
        return self.impl.getDatesByYear(year: year, event: event)
    }
    
    // MARK: QUERY FOR COLLECTION
    
    /// get by date & place
    /// - caller:
    ///   - CollectionViewItemsLoader.load(...)
    /// - Tag: getPhotoFiles(year)
    func getPhotoFiles(filter:CollectionFilter, year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return self.impl.getPhotoFiles(filter: filter, year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    /// get by date & event & place
    /// - caller:
    ///   - CollectionViewItemsLoader.load(...)
    /// - Tag: getPhotoFiles(event)
    func getPhotoFiles(filter:CollectionFilter, year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return self.impl.getPhotoFiles(filter: filter, year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    // MARK: SEARCH
    
    /// - caller:
    ///   - CollectionViewItemsLoader.search(conditions:...)
    /// - Tag: searchImages(condition)
    func searchImages(condition:SearchCondition, includeHidden:Bool = true, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return self.impl.searchImages(condition: condition, includeHidden: includeHidden, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    // MARK: QUERY BY DATE
    
    /// - caller:
    ///   - MemoriesViewController.reloadCollectionView(...)
    ///   - TheaterViewController.reloadCollectionView(...)
    /// - Tag: getImagesByDate(year)
    func getImagesByDate(year:Int, month:Int, day:Int, event:String? = nil) -> [Image] {
        return self.impl.getImagesByDate(year: year, month: month, day: day, event: event)
    }
    
    /// - caller:
    ///   - TheaterViewController.reloadCollectionView()
    /// - Tag: getImagesByDate(photoTakenDate)
    func getImagesByDate(photoTakenDate:Date, event:String? = nil) -> [Image] {
        return self.impl.getImagesByDate(photoTakenDate: photoTakenDate, event: event)
    }
    
    // MARK: QUERY FOR LARGER VIEW
    
    /// - caller:
    ///   - MemoriesViewController.initView()
    ///   - ViewController.showMemories()
    /// - Tag: getYearsByTodayInPrevious()
    func getYearsByTodayInPrevious() -> [Int] {
        return self.impl.getYearsByTodayInPrevious()
    }
    
    /// - caller:
    ///   - MemoriesViewController.initView()
    /// - Tag: getDatesAroundToday()
    func getDatesAroundToday() -> [String] {
        return self.impl.getDatesAroundToday()
    }
    
    /// - caller:
    ///   - MemoriesViewController.pickYear(year:)
    /// - Tag: getDatesByTodayInPrevious(year)
    func getDatesByTodayInPrevious(year:Int) -> [String] {
        return self.impl.getDatesByTodayInPrevious(year: year)
    }
    
    // MARK: QUERY BY EXIF
    
    /// - caller:
    ///   - ImageFolderTreeScanner.scanPhotosToLoadExif(taskId:...)
    /// - Tag: getPhotoFilesWithoutExif()
    func getPhotoFilesWithoutExif(limit:Int? = nil) -> [Image] {
        return self.impl.getPhotoFilesWithoutExif(limit: limit)
    }
    
    /// - caller:
    ///   - ImageFolderTreeScanner.scanPhotosToLoadExif(repository:taskId:...)
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: getPhotoFilesWithoutExif(repositoryPath)
    func getPhotoFilesWithoutExif(repositoryPath:String, limit:Int? = nil) -> [Image] {
        return self.impl.getPhotoFilesWithoutExif(repositoryPath: repositoryPath, limit: limit)
    }
    
    func getImagesWithoutExif(repositoryId:Int, limit:Int? = nil) -> [Image] {
        return self.impl.getImagesWithoutExif(repositoryId: repositoryId, limit: limit)
    }
    
    // MARK: QUERY BY LOCATION
    
    /// - caller:
    ///   - ImageFolderTreeScanner.scanPhotosToLoadExif(repository:taskId:...)
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: getPhotoFilesWithoutLocation(repositoryPath)
    func getPhotoFilesWithoutLocation(repositoryPath:String) -> [Image] {
        return self.impl.getPhotoFilesWithoutLocation(repositoryPath: repositoryPath)
    }
    
    // MARK: QUERY PATHS
    
    func getPhotoFiles(filter: CollectionFilter, containerId:Int, pageSize: Int = 0, pageNumber: Int = 0) -> [Image] {
        return self.impl.getPhotoFiles(filter: filter, containerId: containerId, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onCopyToRawClicked()
    ///   - EditRepositoryViewController.onUpdateAllBriefClicked()
    ///   - EditRepositoryViewController.onUpdateAllEventsClicked()
    ///   - EditRepositoryViewController.onUpdateEmptyBriefClicked()
    ///   - EditRepositoryViewController.onUpdateEmptyEventClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: getImages(repositoryPath)
    func getImages(repositoryPath:String) -> [Image] {
        return self.impl.getImages(repositoryPath: repositoryPath)
    }
    
    func getImages(repositoryId:Int) -> [Image] {
        return self.impl.getImages(repositoryId: repositoryId)
    }
    
    func getImages(containerId:Int) -> [Image] {
        return self.impl.getImages(containerId: containerId)
    }
    
    /// - caller:
    ///   - DevicePathDetailViewController.onupdateClicked()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: getPhotoFiles(rootPath)
    func getPhotoFiles(rootPath:String) -> [Image] {
        return self.impl.getPhotoFiles(rootPath: rootPath)
    }
}

// MARK: -
// MARK: IMAGE COUNT DAO

class ImageCountDao {
    
    private let impl:ImageCountDaoInterface
    
    init(_ impl:ImageCountDaoInterface){
        self.impl = impl
    }
    
    static var `default`:ImageCountDao {
        return ImageCountDao(ImageCountDaoPostgresCK())
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    /// - Tag: countCopiedFromDevice(deviceId)
    func countCopiedFromDevice(deviceId:String) -> Int {
        return self.impl.countCopiedFromDevice(deviceId: deviceId)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countImagesShouldImport(rawStoragePath)
    func countImagesShouldImport(deviceId:String) -> Int {
        return self.impl.countImagesShouldImport(deviceId: deviceId)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countImportedAsEditable(repositoryPath)
    func countImportedAsEditable(repositoryPath:String) -> Int {
        return self.impl.countImportedAsEditable(repositoryPath: repositoryPath)
    }
    
    func countImportedAsEditable(deviceId:String) -> Int {
        return self.impl.countImportedAsEditable(deviceId: deviceId)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countExtractedExif(repositoryPath)
    func countExtractedExif(repositoryPath:String) -> Int {
        return self.impl.countExtractedExif(repositoryPath: repositoryPath)
    }
    
    func countExtractedExif(repositoryId:Int) -> Int {
        return self.impl.countExtractedExif(repositoryId: repositoryId)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countRecognizedLocation(repositoryPath)
    func countRecognizedLocation(repositoryPath:String) -> Int {
        return self.impl.countRecognizedLocation(repositoryPath: repositoryPath)
    }
    
    func countRecognizedLocation(repositoryId:Int) -> Int {
        return self.impl.countRecognizedLocation(repositoryId: repositoryId)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countRecognizedFaces(repositoryPath)
    func countRecognizedFaces(repositoryPath:String) -> Int {
        return self.impl.countRecognizedFaces(repositoryPath: repositoryPath)
    }
    
    func countRecognizedFaces(repositoryId:Int) -> Int {
        return self.impl.countRecognizedFaces(repositoryId: repositoryId)
    }
    
    /// count by date & place
    /// - caller:
    ///   - ViewController.countImagesOfMoment(moment:)
    ///   - ViewController.countImagesOfPlace(moment:)
    /// - Tag: countPhotoFiles(year)
    func countPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?) -> Int {
        return self.impl.countPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place)
    }
    
    /// count by date & place
    /// - caller:
    ///   - ViewController.countHiddenImagesOfMoment(moment:)
    ///   - ViewController.countHiddenImagesOfPlace(moment:)
    /// - Tag: countHiddenPhotoFiles(year)
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?) -> Int {
        return self.impl.countHiddenPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place)
    }
    
    /// count by date & event & place
    /// - caller:
    ///   - ViewController.countImagesOfEvent(moment:)
    /// - Tag: countPhotoFiles(event)
    func countPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "") -> Int {
        return self.impl.countPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place)
    }
    
    /// count by date & event & place
    /// - caller:
    ///   - ViewController.countHiddenImagesOfEvent(moment:)
    /// - Tag: countHiddenPhotoFiles(event)
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "") -> Int {
        return self.impl.countHiddenPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place)
    }
    
    // MARK: COUNT BY FACE
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countImageWithoutFace(repositoryRoot)
    func countImageWithoutFace(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutFace(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countImageNotYetFacialDetection(repositoryRoot)
    func countImageNotYetFacialDetection(repositoryRoot:String) -> Int {
        return self.impl.countImageNotYetFacialDetection(repositoryRoot: repositoryRoot)
    }
    
    // MARK: COUNT BY ID
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countImageWithoutId(repositoryRoot)
    func countImageWithoutId(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutId(repositoryRoot: repositoryRoot)
    }
    
    // MARK: COUNT BY PATH
    
    /// count by path~
    /// - caller:
    ///   - ImageFolderTreeScanner.updateAllContainersFileCount()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countPhotoFiles(rootPath)
    func countPhotoFiles(rootPath:String) -> Int {
        return self.impl.countPhotoFiles(rootPath: rootPath)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countImageWithoutRepositoryPath(repositoryRoot)
    func countImageWithoutRepositoryPath(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutRepositoryPath(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countImageWithoutSubPath(repositoryRoot)
    func countImageWithoutSubPath(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutSubPath(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countImageUnmatchedRepositoryRoot(repositoryRoot)
    func countImageUnmatchedRepositoryRoot(repositoryRoot:String) -> Int {
        return self.impl.countImageUnmatchedRepositoryRoot(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - ContainerDetailViewController.countImages()
    ///   - EditRepositoryViewController.stat()
    ///   - ViewController.countImagesOfContainer(container:)
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countImages(repositoryRoot)
    func countImages(repositoryRoot:String) -> Int {
        return self.impl.countImages(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - ContainerDetailViewController.countImages()
    ///   - ViewController.countHiddenImagesOfContainer(container:)
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countHiddenImages(repositoryRoot)
    func countHiddenImages(repositoryRoot:String) -> Int {
        return self.impl.countHiddenImages(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewContoller.onUpdateRepositoryImagesClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countContainersWithoutRepositoryPath(repositoryRoot)
    func countContainersWithoutRepositoryPath(repositoryRoot:String) -> Int {
        return self.impl.countContainersWithoutRepositoryPath(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewContoller.onUpdateRepositoryImagesClicked()
    /// - attention: will be deprecated
    /// - version: legacy version
    /// - Tag: countContainersWithoutSubPath(repositoryRoot)
    func countContainersWithoutSubPath(repositoryRoot:String) -> Int {
        return self.impl.countContainersWithoutSubPath(repositoryRoot: repositoryRoot)
    }
}

// MARK: -
// MARK: IMAGE DUPLICATION DAO

class ImageDuplicationDao {
    
    private let impl:ImageDuplicationDaoInterface
    
    init(_ impl:ImageDuplicationDaoInterface){
        self.impl = impl
    }
    
    static var `default`:ImageDuplicationDao {
        return ImageDuplicationDao(ImageDuplicateDaoPostgresCK())
    }
    
    /// - caller: NONE
    /// - Tag: reloadDuplicatePhotos()
    func reloadDuplicatePhotos() {
        return self.impl.reloadDuplicatePhotos()
    }
    
    /// - caller:
    ///   - CollectionViewItemsLoader.transformToDomainItems(photoFiles:)
    ///   - CollectionViewItemsLoader.transformToDomainItems(urls:)
    ///   - SelectionViewController.combineCheckedImages()
    ///   - SelectionViewController.combineSelectedImages(...)
    ///   - SelectionViewController.markCheckedImageAsDuplicatedChief()
    ///   - ViewController.combineDuplicatesInAllLibraries()
    ///   - ViewController.combineDuplicatesInCollectionView()
    ///   - ViewController.onCollectionViewItemShowDuplicate()
    /// - Tag: getDuplicatePhotos()
    func getDuplicatePhotos() -> Duplicates {
        return self.impl.getDuplicatePhotos()
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onNormalizeHiddenClicked()
    /// - Tag: getDuplicatedImages(repositoryRoot)
    func getDuplicatedImages(repositoryRoot:String, theOtherRepositoryRoot:String) -> [String:[Image]] {
        return self.impl.getDuplicatedImages(repositoryRoot: repositoryRoot, theOtherRepositoryRoot: theOtherRepositoryRoot)
    }
    
    func getDuplicatedImages(repositoryId:Int) -> [String : [Image]] {
        return self.impl.getDuplicatedImages(repositoryId: repositoryId)
    }
    
    /// - caller:
    ///   - SelectionViewController.combineCheckedImages()
    /// - Tag: getChiefImageOfDuplicatedSet(duplicatesKey)
    func getChiefImageOfDuplicatedSet(duplicatesKey:String) -> Image? {
        return self.impl.getChiefImageOfDuplicatedSet(duplicatesKey: duplicatesKey)
    }
    
    /// - caller:
    ///   - SelectionViewController.combineCheckedImages()
    /// - Tag: getFirstImageOfDuplicatedSet(duplicatesKey)
    func getFirstImageOfDuplicatedSet(duplicatesKey:String) -> Image? {
        return self.impl.getFirstImageOfDuplicatedSet(duplicatesKey: duplicatesKey)
    }
    
    /// - caller:
    ///   - SelectionViewController.combineCheckedImages()
    ///   - SelectionViewController.combineSelectedImages(...)
    ///   - SelectionViewController.decoupleCheckedImages()
    ///   - SelectionViewController.markCheckedImageAsDuplicatedChief()
    ///   - ViewController.combineDuplicatesInAllLibraries()
    ///   - ViewController.combineDuplicatesInCollectionView()
    /// - Tag: markImageDuplicated(path)
    func markImageDuplicated(path:String, duplicatesKey:String?, hide:Bool) {
        return self.impl.markImageDuplicated(path: path, duplicatesKey: duplicatesKey, hide: hide)
    }
}

// MARK: -
// MARK: IMAGE FACE DAO

class ImageFaceDao {
    
    private let impl:ImageFaceDaoInterface
    
    init(_ impl:ImageFaceDaoInterface){
        self.impl = impl
    }
    
    static var `default`:ImageFaceDao {
        return ImageFaceDao(ImageFaceDaoPostgresCK())
    }
    
    /// - caller: NONE
    /// - Tag: updateImageScannedFace(imageId)
    func updateImageScannedFace(imageId:String, facesCount:Int = 0) -> ExecuteState {
        return self.impl.updateImageScannedFace(imageId: imageId, facesCount: facesCount)
    }
    
    /// - caller: NONE
    /// - Tag: updateImageRecognizedFace(imageId)
    func updateImageRecognizedFace(imageId:String, recognizedPeopleIds:String = "") -> ExecuteState {
        return self.impl.updateImageRecognizedFace(imageId: imageId, recognizedPeopleIds: recognizedPeopleIds)
    }
}
