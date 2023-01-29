//
//  ImageDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/25.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

// MARK: IMAGE RECORD DAO

public final class ImageRecordDao {
    
    let logger = ConsoleLogger(category: "ImageRecordDao")
    
    private let impl:ImageRecordDaoInterface
    
    init(_ impl:ImageRecordDaoInterface) {
        self.impl = impl
    }
    
    static var `default`:ImageRecordDao {
        let location = Setting.database.databaseLocation()
        if location == "local" {
            return ImageRecordDao(ImageRecordDaoGRDB())
        }else{
            return ImageRecordDao(ImageRecordDaoPostgresCK())
        }
    }
    
    // MARK: QUERY
    
    /// - parameter path: Something like /Volumes/repository/sub/container/filename.ext
    /// - important: replaced by *getImage(id:)*
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - attention: to be deprecated
    func getImage(path:String) -> Image? {
        return self.impl.getImage(path: path)
    }
    
    /// A usual way to find a database record of Image by Image.id
    /// - parameter id: a UUID
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    func getImage(id:String) -> Image? {
        return self.impl.getImage(id: id)
    }
    
    /// An alternative way to find a database record of Image by paths
    /// - seeAlso: 1234
    /// - parameter repositoryVolume: Something like /Volumes/Machintosh
    /// - parameter repositoryPath: Something like /repository/base/path
    /// - parameter subPath: Something like Camera/filename.ext
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    func findImage(repositoryVolume:String, repositoryPath:String, subPath:String) -> Image? {
        return self.impl.findImage(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
    }
    
    /// A usual way to find a database record of Image by ImageRepository.id
    /// - parameter repositoryId:
    /// - parameter subPath:
    /// - returns: A database record of Image if exists, otherwise return nil
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    func findImage(repositoryId:Int, subPath:String) -> Image? {
        return self.impl.findImage(repositoryId: repositoryId, subPath: subPath)
    }
    
    // MARK: CRUD
    
    /// - parameter repositoryId: **mandatory** Integer id of ImageRepository.id
    /// - parameter containerId: **mandatory** Integer id of ImageContainer.id
    /// - parameter repositoryVolume: **optional** Something like /Volumes/Machintosh
    /// - parameter repositoryPath: **optional** Something like /repository/base/path
    /// - parameter subPath: **mandatory** Something like Camera/filename.ext
    /// - attention: so far we are still using String type *path* as primary key, in future we should use UUID *id* as primary key instead
    /// - returns: A database record of Image if successfully creates, otherwise return nil
    /// - version: 2023.1.21
    func createImage(repositoryId:Int, containerId:Int, repositoryVolume:String, repositoryPath:String, subPath:String) -> Image? {
        return self.impl.createImage(repositoryId: repositoryId, containerId: containerId, repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
    }
    
    /// Create a database record of Image if not exists, during the procedure of handling import-gaps
    /// - caller
    ///   - ImageFolderTreeScanner.applyImportGap(dbUrls:filesysUrls:fileUrlToRepo:excludedContainerPaths:taskId:indicator:)
    /// - attention: will deprecate
    /// - warning: should deprecate caller first
    /// - since: 2019.4.5
    /// - version: 2019.4.5
    func createImageIfAbsent(url:String, fileUrlToRepo:[String:ImageContainer], indicator:Accumulator? = nil) -> ExecuteState {
        //self.logger.log("CREATING PHOTO \(url.path)")
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
    ///   - ImageFile.init(url:repository:...)
    /// - returns: a database record of Image
    /// - attention: will deprecate
    /// - version: 2019.12.27
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String? = nil) -> Image {
        return self.impl.getOrCreatePhoto(filename: filename, path: path, parentPath: parentPath, repositoryPath: repositoryPath)
    }
    
    /// Update every fields of a database record of Image
    /// - since: 2019.12.27
    /// - version: 2019.12.27
    func saveImage(image: Image) -> ExecuteState {
        return self.impl.saveImage(image: image)
    }
    
    /// Delete a database record of Image by Image.id
    /// - since: 2023.1.29
    /// - version: 2023.1.29
    func deleteImage(id:String) -> ExecuteState {
        return self.impl.deleteImage(id: id)
    }
    
    /// Delete a database record of Image by Image.path
    /// - caller:
    ///   - ImageFolderTreeScanner.applyImportGap(...)
    /// - since: 2019.12.27
    /// - version: 2019.12.27
    /// - attention: will deprecate
    func deletePhoto(atPath path:String, updateFlag:Bool = true) -> ExecuteState {
        return self.impl.deletePhoto(atPath: path, updateFlag: updateFlag)
    }
    
    // MARK: UPDATE ID
    
    /// - caller:
    ///   - RepositoryDetailViewController.onReScanFoldersClicked()
    /// - attention: will deprecate
    func updateImageWithContainerId(id:String, repositoryId:Int, containerId:Int) -> ExecuteState {
        return self.impl.updateImageWithContainerId(id: id, repositoryId: repositoryId, containerId: containerId)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.onReScanFoldersClicked()
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    func generateImageIdByPath(repositoryVolume:String, repositoryPath:String, subPath:String) -> (ExecuteState, String) {
        return self.impl.generateImageIdByPath(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
    }
    
    /// - caller:
    ///   - ImageFile.init(image:...)
    /// - since: 2023.1.21
    /// - version: 2023.1.21
    func generateImageIdByContainerIdAndSubPath(containerId:Int, subPath:String) -> (ExecuteState, String) {
        return self.impl.generateImageIdByContainerIdAndSubPath(containerId: containerId, subPath: subPath)
    }
    
    // MARK: UPDATE PATH
    
    /// - caller:
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    /// - attention: will deprecate
    func updateImagePaths(oldPath:String, newPath:String, repositoryPath:String, subPath:String, containerPath:String, id:String) -> ExecuteState {
        return self.impl.updateImagePaths(oldPath: oldPath, newPath: newPath, repositoryPath: repositoryPath, subPath: subPath, containerPath: containerPath, id: id)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onUpdateStorageImagesClicked()
    /// - attention: will deprecate
    func updateImageRawBase(oldRawPath:String, newRawPath:String) -> ExecuteState {
        return self.impl.updateImageRawBase(oldRawPath: oldRawPath, newRawPath: newRawPath)
    }
    
    /// - caller: NONE
    /// - attention: will deprecate
    func updateImageRawBase(repositoryPath:String, rawPath:String) -> ExecuteState {
        return self.impl.updateImageRawBase(repositoryPath: repositoryPath, rawPath: rawPath)
    }
    
    /// - caller: NONE
    /// - attention: will deprecate
    func updateImageRawBase(pathStartsWith path:String, rawPath:String) -> ExecuteState {
        return self.impl.updateImageRawBase(pathStartsWith: path, rawPath: rawPath)
    }
    
    /// - caller: NONE
    /// - attention: will deprecate
    func updateImageRepositoryBase(pathStartsWith path:String, repositoryPath:String) -> ExecuteState {
        return self.impl.updateImageRepositoryBase(pathStartsWith: path, repositoryPath: repositoryPath)
    }
    
    /// - caller: NONE
    /// - attention: will deprecate
    func updateImageRepositoryBase(oldRepositoryPath:String, newRepository:String) -> ExecuteState {
        return self.impl.updateImageRepositoryBase(oldRepositoryPath: oldRepositoryPath, newRepository: newRepository)
    }
    
    /// - caller: NONE
    /// - attention: will deprecate
    func updateImagePath(repositoryPath:String) -> ExecuteState {
        return self.impl.updateImagePath(repositoryPath: repositoryPath)
    }
    
    // MARK: UPDATE DATE
    
    /// - caller: NONE
    func updateImageDateTimeFromFilename(path:String, dateTimeFromFilename:String) -> ExecuteState{
        return self.impl.updateImageDateTimeFromFilename(path: path, dateTimeFromFilename: dateTimeFromFilename)
    }
    
    /// - caller:
    ///   - ImageFile.init(image:...)
    func updateImageDateTimeFromFilename(id:String, dateTimeFromFilename:String) -> ExecuteState{
        return self.impl.updateImageDateTimeFromFilename(id: id, dateTimeFromFilename: dateTimeFromFilename)
    }
    
    /// - caller:
    ///   - DateTimeViewController.onOKClicked()
    func updateImageDates(path:String, date:Date, fields:Set<String>) -> ExecuteState {
        return self.impl.updateImageDates(path: path, date: date, fields: fields)
    }
    
    // MARK: UPDATE DESCRIPTION
    
    /// - caller:
    ///   - NotesViewController.onOKClicked()
    func storeImageDescription(path:String, shortDescription:String?, longDescription:String?) -> ExecuteState {
        return self.impl.storeImageDescription(path: path, shortDescription: shortDescription, longDescription: longDescription)
    }
    
    /// - caller:
    ///   - ImagePreviewController.onRotateClickwiseClicked()
    ///   - ImagePreviewController.onRotateCounterClockerwiseClicked()
    func updateImageRotation(path:String, rotation:Int) -> ExecuteState {
        return self.impl.updateImageRotation(path: path, rotation: rotation)
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
        let location = Setting.database.databaseLocation()
        if location == "local" {
            return ImageSearchDao(ImageSearchDaoGRDB())
        }else{
            return ImageSearchDao(ImageSearchDaoPostgresCK())
        }
    }
    
    // MARK: QUERY FOR Options
    
    /// - caller:
    ///   - FilterViewController.viewDidLoad()
    func getImageSources() -> [String:Bool]{
        return self.impl.getImageSources()
    }
    
    /// - caller:
    ///   - FilterViewController.viewDidLoad()
    func getCameraModel() -> [String:Bool] {
        return self.impl.getCameraModel()
    }
    
    // MARK: QUERY FOR MOMENTS
    
    /// - caller:
    ///   - MomentsTreeDataSource.loadChildren()
    func getMoments(_ momentCondition:MomentCondition, year:Int = 0, month:Int = 0, condition:SearchCondition? = nil) -> [Moment] {
        return self.impl.getMoments(momentCondition, year: year, month: month, condition: condition)
    }
    
    /// - caller: NONE
    func getAllMoments(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Moment] {
        return self.impl.getAllMoments(imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // MARK: - PLACES
    
    /// - caller:
    ///   - PlacesTreeDataSource.loadChildren()
    func getMomentsByPlace(_ momentCondition:MomentCondition, parent:Moment? = nil, condition:SearchCondition? = nil) -> [Moment] {
        return self.impl.getMomentsByPlace(momentCondition, parent: parent, condition: condition)
    }
    
    /// - caller:
    ///   - EventsTreeDataSource.loadChildren()
    func getImageEvents(condition:SearchCondition?) -> [Moment] {
        return self.impl.getImageEvents(condition: condition)
    }
    
    /// - caller:
    ///   - EventsTreeDataSource.loadChildren()
    func getMomentsByEvent(event:String, category:String, year:Int = 0, month:Int = 0, condition:SearchCondition? = nil) -> [Moment] {
        return self.impl.getMomentsByEvent(event: event, category: category, year: year, month: month, condition: condition)
    }
    
    /// - caller:
    ///   - TheaterViewController.viewInit(image:byEvent:)
    ///   - TheaterViewController.viewInit(year:month:day:event:)
    func getYears(event:String? = nil) -> [Int] {
        return self.impl.getYears(event: event)
    }
    
    /// - caller:
    ///   - TheaterViewController.changeYear(year:month:day:event:)
    ///   - TheaterViewController.viewInit(image:byEvent:)
    func getDatesByYear(year:Int, event:String? = nil) -> [String:[String]] {
        return self.impl.getDatesByYear(year: year, event: event)
    }
    
    // MARK: QUERY FOR COLLECTION
    
    /// get by date & place
    /// - caller:
    ///   - CollectionViewItemsLoader.load(...)
    func getPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return self.impl.getPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    /// get by date & event & place
    /// - caller:
    ///   - CollectionViewItemsLoader.load(...)
    func getPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return self.impl.getPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    // MARK: SEARCH
    
    /// - caller:
    ///   - CollectionViewItemsLoader.search(conditions:...)
    func searchImages(condition:SearchCondition, includeHidden:Bool = true, hiddenCountHandler: ((_ hiddenCount:Int) -> Void)? = nil , pageSize:Int = 0, pageNumber:Int = 0) -> [Image] {
        return self.impl.searchImages(condition: condition, includeHidden: includeHidden, hiddenCountHandler: hiddenCountHandler, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    // MARK: QUERY BY DATE
    
    /// - caller:
    ///   - MemoriesViewController.reloadCollectionView(...)
    ///   - TheaterViewController.reloadCollectionView(...)
    func getImagesByDate(year:Int, month:Int, day:Int, event:String? = nil) -> [Image] {
        return self.impl.getImagesByDate(year: year, month: month, day: day, event: event)
    }
    
    /// - caller: NONE
    func getImagesByYear(year:String? = nil, scannedFace:Bool? = nil, recognizedFace:Bool? = nil) -> [Image] {
        return self.impl.getImagesByYear(year: year, scannedFace: scannedFace, recognizedFace: recognizedFace)
    }
    
    /// - caller:
    ///   - TheaterViewController.reloadCollectionView()
    func getImagesByDate(photoTakenDate:Date, event:String? = nil) -> [Image] {
        return self.impl.getImagesByDate(photoTakenDate: photoTakenDate, event: event)
    }
    
    /// - caller: NONE
    func getImagesByHour(photoTakenDate:Date) -> [Image] {
        return self.impl.getImagesByHour(photoTakenDate: photoTakenDate)
    }
    
    // MARK: QUERY FOR LARGER VIEW
    
    /// - caller: NONE
    func getMaxPhotoTakenYear() -> Int {
        return self.impl.getMaxPhotoTakenYear()
    }
    
    /// - caller: NONE
    func getMinPhotoTakenYear() -> Int {
        return self.impl.getMinPhotoTakenYear()
    }
    
    /// - caller: NONE
    func getSqlByTodayInPrevious() -> String {
        return self.impl.getSqlByTodayInPrevious()
    }
    
    /// - caller:
    ///   - MemoriesViewController.initView()
    ///   - ViewController.showMemories()
    func getYearsByTodayInPrevious() -> [Int] {
        return self.impl.getYearsByTodayInPrevious()
    }
    
    /// - caller:
    ///   - MemoriesViewController.initView()
    func getDatesAroundToday() -> [String] {
        return self.impl.getDatesAroundToday()
    }
    
    /// - caller:
    ///   - MemoriesViewController.pickYear(year:)
    func getDatesByTodayInPrevious(year:Int) -> [String] {
        return self.impl.getDatesByTodayInPrevious(year: year)
    }
    
    // MARK: QUERY BY EXIF
    
    /// - caller:
    ///   - ImageFolderTreeScanner.scanPhotosToLoadExif(taskId:...)
    func getPhotoFilesWithoutExif(limit:Int? = nil) -> [Image] {
        return self.impl.getPhotoFilesWithoutExif(limit: limit)
    }
    
    /// - caller:
    ///   - ImageFolderTreeScanner.scanPhotosToLoadExif(repository:taskId:...)
    func getPhotoFilesWithoutExif(repositoryPath:String, limit:Int? = nil) -> [Image] {
        return self.impl.getPhotoFilesWithoutExif(repositoryPath: repositoryPath, limit: limit)
    }
    
    // MARK: QUERY BY LOCATION
    
    /// - caller:
    ///   - ImageFolderTreeScanner.scanPhotosToLoadExif(repository:taskId:...)
    func getPhotoFilesWithoutLocation(repositoryPath:String) -> [Image] {
        return self.impl.getPhotoFilesWithoutLocation(repositoryPath: repositoryPath)
    }
    
    /// - caller: NONE
    func getPhotoFilesWithoutLocation() -> [Image] {
        return self.impl.getPhotoFilesWithoutLocation()
    }
    
    /// - caller: NONE
    func getPhotoFiles(after date:Date) -> [Image] {
        return self.impl.getPhotoFiles(after: date)
    }
    
    // MARK: QUERY BY FACE
    
    /// - caller: NONE
    func getImagesWithoutFace(repositoryRoot:String, includeScanned:Bool = false) -> [Image] {
        return self.impl.getImagesWithoutFace(repositoryRoot: repositoryRoot, includeScanned: includeScanned)
    }
    
    // MARK: QUERY PATHS
    
    /// - caller:
    ///   - ImageFolderTreeScanner.scanRepositories(taskId:indicator:)
    /// - attention: will deprecate
    /// - warning: should deprecate caller first
    func getAllPhotoPaths(includeHidden:Bool = true) -> Set<String> {
        return self.impl.getAllPhotoPaths(includeHidden: includeHidden)
    }
    
    /// - caller:
    ///   - ImageFolderTreeScanner.scanSingleRepository(repository:taskId:indicator:)
    /// - attention: will deprecate
    func getAllPhotoPaths(repositoryPath:String, includeHidden:Bool = true) -> Set<String> {
        return self.impl.getAllPhotoPaths(repositoryPath:repositoryPath, includeHidden: includeHidden)
    }
    
    /// - caller: NONE
    /// - attention: will deprecate
    func getPhotoFilesWithoutSubPath(rootPath:String) -> [Image] {
        return self.impl.getPhotoFilesWithoutSubPath(rootPath: rootPath)
    }
    
    /// - caller:
    ///   - CollectionViewItemsLoader.walkthruDatabaseForFileurls
    ///   - CollectionViewItemsLoader.walkthruDatabaseForPhotoFiles
    /// - attention: will deprecate
    func getPhotoFiles(parentPath:String, includeHidden:Bool = true, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false) -> [Image] {
        return self.impl.getPhotoFiles(parentPath: parentPath, includeHidden: includeHidden, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onCopyToRawClicked()
    ///   - EditRepositoryViewController.onUpdateAllBriefClicked()
    ///   - EditRepositoryViewController.onUpdateAllEventsClicked()
    ///   - EditRepositoryViewController.onUpdateEmptyBriefClicked()
    ///   - EditRepositoryViewController.onUpdateEmptyEventClicked()
    /// - attention: will deprecate
    func getImages(repositoryPath:String) -> [Image] {
        return self.impl.getImages(repositoryPath: repositoryPath)
    }
    
    /// - caller:
    ///   - DevicePathDetailViewController.onupdateClicked()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    /// - attention: will deprecate
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
        let location = Setting.database.databaseLocation()
        if location == "local" {
            return ImageCountDao(ImageCountDaoGRDB())
        }else{
            return ImageCountDao(ImageCountDaoPostgresCK())
        }
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    func countCopiedFromDevice(deviceId:String) -> Int {
        return self.impl.countCopiedFromDevice(deviceId: deviceId)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    func countImagesShouldImport(rawStoragePath:String, deviceId:String) -> Int {
        return self.impl.countImagesShouldImport(rawStoragePath: rawStoragePath, deviceId: deviceId)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    func countImportedAsEditable(repositoryPath:String) -> Int {
        return self.impl.countImportedAsEditable(repositoryPath: repositoryPath)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    func countExtractedExif(repositoryPath:String) -> Int {
        return self.impl.countExtractedExif(repositoryPath: repositoryPath)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    func countRecognizedLocation(repositoryPath:String) -> Int {
        return self.impl.countRecognizedLocation(repositoryPath: repositoryPath)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.initView(id:path:...)
    func countRecognizedFaces(repositoryPath:String) -> Int {
        return self.impl.countRecognizedFaces(repositoryPath: repositoryPath)
    }
    
    /// count by date & place
    /// - caller:
    ///   - ViewController.countImagesOfMoment(moment:)
    ///   - ViewController.countImagesOfPlace(moment:)
    func countPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return self.impl.countPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    /// count by date & place
    /// - caller:
    ///   - ViewController.countHiddenImagesOfMoment(moment:)
    ///   - ViewController.countHiddenImagesOfPlace(moment:)
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, ignoreDate:Bool = false, country:String = "", province:String = "", city:String = "", place:String?, includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return self.impl.countHiddenPhotoFiles(year: year, month: month, day: day, ignoreDate: ignoreDate, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    /// count by date & event & place
    /// - caller:
    ///   - ViewController.countImagesOfEvent(moment:)
    func countPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return self.impl.countPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    /// count by date & event & place
    /// - caller:
    ///   - ViewController.countHiddenImagesOfEvent(moment:)
    func countHiddenPhotoFiles(year:Int, month:Int, day:Int, event:String, country:String = "", province:String = "", city:String = "", place:String = "", includeHidden:Bool = true, imageSource:[String]? = nil, cameraModel:[String]? = nil) -> Int {
        return self.impl.countHiddenPhotoFiles(year: year, month: month, day: day, event: event, country: country, province: province, city: city, place: place, includeHidden: includeHidden, imageSource: imageSource, cameraModel: cameraModel)
    }
    
    // MARK: COUNT BY FACE
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    func countImageWithoutFace(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutFace(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    func countImageNotYetFacialDetection(repositoryRoot:String) -> Int {
        return self.impl.countImageNotYetFacialDetection(repositoryRoot: repositoryRoot)
    }
    
    // MARK: COUNT BY ID
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    func countImageWithoutId(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutId(repositoryRoot: repositoryRoot)
    }
    
    // MARK: COUNT BY PATH
    
    /// count by path~
    /// - caller:
    ///   - ImageFolderTreeScanner.updateAllContainersFileCount()
    func countPhotoFiles(rootPath:String) -> Int {
        return self.impl.countPhotoFiles(rootPath: rootPath)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    func countImageWithoutRepositoryPath(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutRepositoryPath(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    func countImageWithoutSubPath(repositoryRoot:String) -> Int {
        return self.impl.countImageWithoutSubPath(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    func countImageUnmatchedRepositoryRoot(repositoryRoot:String) -> Int {
        return self.impl.countImageUnmatchedRepositoryRoot(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - ContainerDetailViewController.countImages()
    ///   - EditRepositoryViewController.stat()
    ///   - ViewController.countImagesOfContainer(container:)
    func countImages(repositoryRoot:String) -> Int {
        return self.impl.countImages(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - ContainerDetailViewController.countImages()
    ///   - ViewController.countHiddenImagesOfContainer(container:)
    func countHiddenImages(repositoryRoot:String) -> Int {
        return self.impl.countHiddenImages(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewContoller.onUpdateRepositoryImagesClicked()
    func countContainersWithoutRepositoryPath(repositoryRoot:String) -> Int {
        return self.impl.countContainersWithoutRepositoryPath(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.stat()
    ///   - EditRepositoryViewContoller.onUpdateRepositoryImagesClicked()
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
        let location = Setting.database.databaseLocation()
        if location == "local" {
            return ImageDuplicationDao(ImageDuplicateDaoGRDB())
        }else{
            return ImageDuplicationDao(ImageDuplicateDaoPostgresCK())
        }
    }
    
    /// - caller: NONE
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
    func getDuplicatePhotos() -> Duplicates {
        return self.impl.getDuplicatePhotos()
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onNormalizeHiddenClicked()
    func getDuplicatedImages(repositoryRoot:String, theOtherRepositoryRoot:String) -> [String:[Image]] {
        return self.impl.getDuplicatedImages(repositoryRoot: repositoryRoot, theOtherRepositoryRoot: theOtherRepositoryRoot)
    }
    
    /// - caller:
    ///   - SelectionViewController.combineCheckedImages()
    func getChiefImageOfDuplicatedSet(duplicatesKey:String) -> Image? {
        return self.impl.getChiefImageOfDuplicatedSet(duplicatesKey: duplicatesKey)
    }
    
    /// - caller:
    ///   - SelectionViewController.combineCheckedImages()
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
        let location = Setting.database.databaseLocation()
        if location == "local" {
            return ImageFaceDao(ImageFaceDaoGRDB())
        }else{
            return ImageFaceDao(ImageFaceDaoPostgresCK())
        }
    }
    
    /// - caller: NONE
    func updateImageScannedFace(imageId:String, facesCount:Int = 0) -> ExecuteState {
        return self.impl.updateImageScannedFace(imageId: imageId, facesCount: facesCount)
    }
    
    /// - caller: NONE
    func updateImageRecognizedFace(imageId:String, recognizedPeopleIds:String = "") -> ExecuteState {
        return self.impl.updateImageRecognizedFace(imageId: imageId, recognizedPeopleIds: recognizedPeopleIds)
    }
}
