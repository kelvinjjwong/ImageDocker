//
//  RepositoryDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

class RepositoryDao {
    
    let logger = LoggerFactory.get(category: "RepositoryDao")
    
    private let impl:RepositoryDaoInterface
    
    init(_ impl:RepositoryDaoInterface){
        self.impl = impl
    }
    
    static var `default`:RepositoryDao {
        return RepositoryDao(RepositoryDaoPostgresCK())
    }
    
    func getPhysicalPath(container:ImageContainer) -> String {
        return container.path
    }
    
    // MARK: IMAGE REPOSITORY CRUD
    
    /// - caller:
    ///   - EditRepositoryViewController.saveNewRepository()
    /// - Tag: createRepository()
    func createRepository(name:String,
                          owner:String,
                                 path:String,
                                 homePath:String,
                                 storagePath:String,
                                 facePath:String,
                                 cropPath:String) -> ImageFolder {
        self.logger.log(.trace, "Creating repository with name:\(name) , path:\(path)")
        
        let (homeVolume, _homePath) = homePath.getVolumeFromThisPath()
        let (repositoryVolume, _repositoryPath) = path.getVolumeFromThisPath()
        let (storageVolume, _storagePath) = storagePath.getVolumeFromThisPath()
        let (faceVolume, _facePath) = facePath.getVolumeFromThisPath()
        let (cropVolume, _cropPath) = cropPath.getVolumeFromThisPath()
        
        let imageRepository = self.impl.createRepository(name: name,
                                                         owner: owner,
                                   homeVolume: homeVolume, homePath: _homePath,
                                   repositoryVolume: repositoryVolume, repositoryPath: _repositoryPath,
                                   storageVolume: storageVolume, storagePath: _storagePath,
                                   faceVolume: faceVolume, facePath: _facePath,
                                   cropVolume: cropVolume, cropPath: _cropPath)
        
        if let repositoryId = imageRepository?.id {
            self.logger.log(.trace, "Created ImageRepository with id: \(repositoryId)")
        }
        
        let imageFolder = ImageFolder(URL(fileURLWithPath: path),
                            name: name,
                            repositoryPath: path,
                            homePath: homePath,
                            storagePath: storagePath,
                            facePath: facePath,
                            cropPath: cropPath)
        
        if let repositoryId = imageRepository?.id {
            if let imageContainer = imageFolder.containerFolder, repositoryId > 0 {
                imageContainer.repositoryId = repositoryId
                RepositoryDao.default.saveImageContainer(container: imageContainer)
            }else{
                self.logger.log(.error, "new imageContainer is nil")
            }
            
        }else{
            self.logger.log(.error, "new repositoryId is nil")
        }
        
        return imageFolder
    }
    
    func updateRepository(id:Int, name:String,
                          owner: String,
                          homeVolume:String, homePath:String,
                          repositoryVolume:String, repositoryPath:String,
                          storageVolume:String, storagePath:String,
                          faceVolume:String, facePath:String,
                          cropVolume:String, cropPath:String
    ) {
        self.impl.updateRepository(id: id, name: name,
                                   owner: owner,
                                   homeVolume: homeVolume, homePath: homePath,
                                   repositoryVolume: repositoryVolume, repositoryPath: repositoryPath,
                                   storageVolume: storageVolume, storagePath: storagePath,
                                   faceVolume: faceVolume, facePath: facePath,
                                   cropVolume: cropVolume, cropPath: cropPath)
    }
    
    func linkRepositoryToDevice(id:Int, deviceId:String) {
        self.impl.linkRepositoryToDevice(id: id, deviceId: deviceId)
    }
    
    func unlinkRepositoryToDevice(id:Int) {
        self.impl.unlinkRepositoryToDevice(id: id)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onRemoveClicked()
    /// - version: legacy version
    /// - note: should be replaced by [deleteRepository(id:)](x-source-tag://deleteRepository(id))
    /// - Tag: deleteRepository(repositoryRoot)
    func deleteRepository(repositoryRoot:String) -> ExecuteState{
        return self.impl.deleteRepository(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onRemoveClicked()
    /// - version: future version
    /// - Tag: deleteRepository(id)
    func deleteRepository(id:Int) -> ExecuteState {
        return self.impl.deleteRepository(id: id)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onShowHideClicked()
    /// - version: legacy version
    /// - note: should be replaced by [hideRepository(id:)](x-source-tag://hideRepository(id))
    /// - Tag: hideRepository(repositoryRoot)
    func hideRepository(repositoryRoot:String) -> ExecuteState{
        return self.impl.hideRepository(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onShowHideClicked()
    /// - version: future version
    /// - note: should replace hideRepository(repositoryRoot:)
    /// - Tag: hideRepository(id)
    func hideRepository(id:Int) -> ExecuteState {
        return self.impl.hideRepository(id: id)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onShowHideClicked()
    /// - version: legacy version
    /// - note: should be replaced by [showRepository(id:)](x-source-tag://showRepository(id))
    /// - Tag: showRepository(repositoryRoot)
    func showRepository(repositoryRoot:String) -> ExecuteState{
        return self.impl.showRepository(repositoryRoot: repositoryRoot)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onShowHideClicked()
    /// - version: future version
    /// - note: should replace showRepository(repositoryRoot:)
    /// - Tag: showRepository(id)
    func showRepository(id:Int) -> ExecuteState {
        return self.impl.showRepository(id: id)
    }
    
    // MARK: IMAGE REPOSITORY QUERY
    
    /// - caller: NONE
    /// - Tag: findRepository(volume)
    func findRepository(volume:String, repositoryPath: String) -> ImageRepository? {
        return self.impl.findRepository(volume: volume, repositoryPath: repositoryPath)
    }
    
    /// - Tag: getRepository(id)
    func getRepository(id: Int) -> ImageRepository? {
        return self.impl.getRepository(id: id)
    }
    
    /// - caller:
    ///   - ImageFile.transformDomainToMetaInfo()
    ///   - RepositoryDetailViewController.initView(id)
    ///   - RepositoryDetailViewController.onDropInClicked()
    ///   - RepositoryDetailViewController.onExifClicked()
    ///   - RepositoryDetailViewController.onImportClicked()
    ///   - RepositoryDetailViewController.onLocationClicked()
    /// - version: should be replaced by [getRepository(id:)](x-source-tag://getRepository(id))
    /// - Tag: getRepository(repositoryPath)
    func getRepository(repositoryPath:String) -> ImageContainer? {
        return self.impl.getRepository(repositoryPath: repositoryPath)
    }
    
    /// - Tag: getRepositoriesV2(orderBy)
    func getRepositoriesV2(orderBy: String = "name", condition:SearchCondition? = nil) -> [ImageRepository] {
        return self.impl.getRepositoriesV2(orderBy: orderBy, condition: condition)
    }
    
    /// - caller:
    ///   - ExportConfigurationViewController.loadRepositories()
    ///   - LibrariesViewController.onCalculateClicked()
    /// - version: should be replaced by [getRepositoriesV2(orderBy)](x-source-tag://getRepositoriesV2(orderBy))
    /// - Tag: getRepositories(orderBy)
    func getRepositories(orderBy:String = "path", condition:SearchCondition? = nil) -> [ImageContainer] {
        return self.impl.getRepositories(orderBy: orderBy, condition: condition)
    }
    
    /// not-used
    /// - caller: NONE
    /// - Tag: getRepositoryPaths(imagesCondition)
    func getRepositoryPaths(imagesCondition:SearchCondition) -> [String] {
        return self.impl.getRepositoryPaths(imagesCondition: imagesCondition)
    }
    
    /// - caller:
    ///   - LibrariesViewController.onCalculateClicked()
    /// - Tag: getLastPhotoTakenDateOfRepositories()
    func getLastPhotoTakenDateOfRepositories() -> [String:String] {
        return self.impl.getLastPhotoTakenDateOfRepositories()
    }
    
    // MARK: IMAGE CONTAINER CRUD
    
    /// - caller:
    ///   - RepositoryDetailViewController.onReScanFoldersClicked()
    /// - Tag: createContainer()
    // FIXME: repositoryPath should be delete
    func createContainer(name: String, repositoryId: Int, parentId:Int, subPath: String, repositoryPath: String) -> ImageContainer? {
        return self.impl.createContainer(name: name, repositoryId: repositoryId, parentId: parentId, subPath: subPath, repositoryPath: repositoryPath)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.onReScanFoldersClicked()
    /// - Tag: createEmptyImageContainerLinkToRepository(repositoryId)
    func createEmptyImageContainerLinkToRepository(repositoryId:Int) -> ImageContainer? {
        return self.impl.createEmptyImageContainerLinkToRepository(repositoryId: repositoryId)
    }
    
    /// - caller:
    ///   - ImageFolder.[init(url)](x-source-tag://ImageFolder.init(url))
    /// - Tag: getOrCreateContainer()
    func getOrCreateContainer(name:String,
                              path:String,
                              parentPath:String = "",
                              repositoryPath:String,
                              homePath:String,
                              storagePath:String,
                              facePath:String,
                              cropPath:String,
                              subPath:String,
                              manyChildren:Bool = false,
                              hideByParent:Bool = false) -> ImageContainer {
        let (container, isNew) = self.impl.getOrCreateContainer(name: name, path: path, parentPath: parentPath, repositoryPath: repositoryPath, homePath: homePath, storagePath: storagePath, facePath: facePath, cropPath: cropPath, subPath: subPath, manyChildren: manyChildren, hideByParent: hideByParent)
        
        if isNew {
            let _ = self.updateParentContainerSubContainers(thisPath: path)
        }
        
        return container
    }
    
    /// - Tag: saveImageContainer(container)
    func saveImageContainer(container:ImageContainer) -> ExecuteState{
        return self.impl.saveImageContainer(container: container)
    }
    
    /// - version: should be replaced by [deleteContainer(id)](x-source-tag://deleteContainer(id))
    /// - Tag: deleteContainer(path)
    func deleteContainer(path: String, deleteImage:Bool = false) -> ExecuteState {
        return self.impl.deleteContainer(path: path, deleteImage: deleteImage)
    }
    
    /// - Tag: deleteContainer(id)
    func deleteContainer(id:Int, deleteImage:Bool = false) -> ExecuteState {
        return self.impl.deleteRepository(id: id)
    }
    
    /// - version: should be replaced by [hideContainer(id)](x-source-tag://hideContainer(id))
    /// - Tag: hideContainer(path)
    func hideContainer(path:String) -> ExecuteState{
        return self.impl.hideContainer(path: path)
    }
    
    /// - Tag: hideContainer(id)
    func hideContainer(id:Int) -> ExecuteState {
        return self.impl.hideContainer(id: id)
    }
    
    /// - version: should be replaced by [showContainer(id)](x-source-tag://showContainer(id))
    /// - Tag: showContainer(path)
    func showContainer(path:String) -> ExecuteState{
        return self.impl.showContainer(path: path)
    }
    
    /// - Tag: showContainer(id)
    func showContainer(id:Int) -> ExecuteState {
        return self.showContainer(id: id)
    }
    
    // MARK: IMAGE CONTAINER QUERY
    
    /// - caller:
    ///   - RepositoryDetailViewController.onReScanFoldersClicked()
    /// - Tag: findContainer(repositoryId)
    func findContainer(repositoryId:Int, subPath:String) -> ImageContainer? {
        return self.impl.findContainer(repositoryId: repositoryId, subPath: subPath)
    }
    
    /// - caller:
    ///   - RepositoryDetailViewController.onReScanFoldersClicked()
    /// - Tag: findContainer(repositoryVolume)
    func findContainer(repositoryVolume:String, repositoryPath:String, subPath:String) -> ImageContainer? {
        return self.impl.findContainer(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
    }
    
    /// - version: should be replaced by [getContainer(id)](x-source-tag://getContainer(id))
    /// - Tag: getContainer(path)
    func getContainer(path:String) -> ImageContainer? {
        return self.impl.getContainer(path: path)
    }
    
    /// - Tag: getContainer(id)
    func getContainer(id:Int) -> ImageContainer? {
        return self.impl.getContainer(id: id)
    }
    
    func getRepositoryLinkingContainer(repositoryId:Int) -> ImageContainer? {
        return self.impl.getRepositoryLinkingContainer(repositoryId: repositoryId)
    }
    
    /// - caller:
    ///   - EditRepositoryViewController.onPreviewBriefFolders()
    ///   - EditRepositoryViewController.onPreviewEventFolders()
    /// - Tag: getAllContainerPathsOfImages(rootPath)
    func getAllContainerPathsOfImages(rootPath:String? = nil) -> Set<String> {
        return self.impl.getAllContainerPathsOfImages(rootPath: rootPath)
    }
    
    func getAllContainerPathsOfImages(repositoryId:Int?) -> Set<String> {
        return self.impl.getAllContainerPathsOfImages(repositoryId: repositoryId)
    }
    
    /// not-used
    /// - caller: NONE
    /// - Tag: getAllContainerPaths(rootPath)
    func getAllContainerPaths(rootPath:String? = nil) -> Set<String> {
        return self.impl.getAllContainerPaths(rootPath: rootPath)
    }
    
    /// - Tag: getAllContainers()
    func getAllContainers() -> [ImageContainer] {
        return self.impl.getAllContainers()
    }
    
    /// - caller:
    ///   - DevicePathDetailViewController.onUpdateClicked()
    ///   - EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    /// - version: should be replaced by [getContainers(repositoryId)](x-source-tag://getContainers(repositoryId))
    /// - Tag: getContainers(rootPath)
    func getContainers(rootPath:String) -> [ImageContainer] {
        return self.impl.getContainers(rootPath: rootPath)
    }
    
    /// - Tag: getContainers(repositoryId)
    func getContainers(repositoryId:Int) -> [ImageContainer] {
        return self.impl.getContainers(repositoryId: repositoryId)
    }
    
    /// - caller:
    ///   - ImageFolderTreeScanner.[scanRepository(ImageContainer)](x-source-tag://ImageFolderTreeScanner.scanRepository(ImageContainer))
    /// - Tag: getAllContainerPaths(repositoryPath)
    func getAllContainerPaths(repositoryPath:String? = nil) -> Set<String> {
        return self.impl.getAllContainerPaths(repositoryPath: repositoryPath)
    }
    
    // MARK: SUB CONTAINER QUERY
    
    /// - Tag: getSubContainersSingleLevel(repositoryId)
    func getSubContainersSingleLevel(repositoryId:Int, condition:SearchCondition?) -> [ImageContainer] {
        return self.impl.getSubContainersSingleLevel(repositoryId: repositoryId, condition: condition)
    }
    
    /// - Tag: getSubContainersSingleLevel(containerId)
    func getSubContainersSingleLevel(containerId:Int, condition:SearchCondition?) -> [ImageContainer] {
        return self.impl.getSubContainersSingleLevel(containerId: containerId, condition: condition)
    }
    
    /// not-used
    /// - caller: NONE
    /// - Tag: getSubContainerPaths(path)
    func getSubContainerPaths(parent path:String, imagesCondition:SearchCondition) -> [String] {
        return self.impl.getSubContainerPaths(parent: path, imagesCondition: imagesCondition)
    }
    
    /// - caller:
    ///   - RepositoryTreeDataSource.[loadSubContainers(parentPath)](x-source-tag://RepositoryTreeDataSource.loadSubContainers(parentPath))
    ///   - SubContainesManageViewController.[loadSubContainers(parentPath)](x-source-tag://SubContainesManageViewController.loadSubContainers(parentPath))
    /// - Tag: getSubContainers(path)
    func getSubContainers(parent path:String, condition:SearchCondition? = nil) -> [ImageContainer] {
        return self.impl.getSubContainers(parent: path, condition: condition)
    }
    
    /// not-used
    /// - caller: NONE
    /// - Tag: countSubContainers(path)
    func countSubContainers(parent path:String) -> Int {
        return self.impl.countSubContainers(parent: path)
    }
    
    /// - Tag: countSubContainers(repositoryId)
    func countSubContainers(repositoryId:Int) -> Int {
        return self.impl.countSubContainers(repositoryId: repositoryId)
    }
    
    /// - Tag: countSubContainers(containerId)
    func countSubContainers(containerId:Int) -> Int {
        return self.impl.countSubContainers(containerId: containerId)
    }
    
    /// - Tag: countSubImages(containerId)
    func countSubImages(containerId:Int) -> Int {
        return self.impl.countSubImages(containerId: containerId)
    }
    
    /// - Tag: countSubHiddenImages(containerId)
    func countSubHiddenImages(containerId:Int) -> Int {
        return self.impl.countSubHiddenImages(containerId: containerId)
    }
    
    // MARK: GET PARENT CONTAINER
    
    /// not-used
    /// - Tag: getParentContainer(thisContainer)
    func getParentContainer(thisContainer: ImageContainer) -> ImageContainer? {
        if thisContainer.parentFolder != "" {
            if let parentContainer = self.getContainer(path: thisContainer.parentFolder) {
                return parentContainer
            }
        }
        return nil
    }
    
    /// not-used
    /// - Tag: getParentContainer(thisPath)
    func getParentContainer(thisPath: String) -> ImageContainer? {
        if let thisContainer = self.getContainer(path: thisPath) {
            return self.getParentContainer(thisContainer: thisContainer)
        }
        return nil
    }
    
    // MARK: UPDATE SUB CONTAINERS AMOUNT
    
    /// not-used
    /// - Tag: updateParentContainerSubContainers(parentPath)
    func updateParentContainerSubContainers(parentPath:String) -> Int {
        return self.updateImageContainerSubContainers(path: parentPath)
    }
    
    /// not-used
    /// - Tag: updateParentContainerSubContainers(thisPath)
    func updateParentContainerSubContainers(thisPath:String) -> Int {
        if let parentContainer = self.getParentContainer(thisPath: thisPath){
            return self.updateImageContainerSubContainers(path: parentContainer.path)
        }
        return -1
    }
    
    /// not-used
    /// - Tag: updateImageContainerSubContainers(path)
    func updateImageContainerSubContainers(path:String) -> Int {
        return self.impl.updateImageContainerSubContainers(path: path)
    }
    
    // MARK: UPDATE ID
    
    /// - Tag: updateImageContainerWithRepositoryId(containerId)
    func updateImageContainerWithRepositoryId(containerId:Int, repositoryId:Int) -> ExecuteState {
        return self.impl.updateImageContainerWithRepositoryId(containerId: containerId, repositoryId: repositoryId)
    }
    
    /// - Tag: updateImageContainerWithParentId(containerId)
    func updateImageContainerWithParentId(containerId:Int, parentId:Int) -> ExecuteState {
        return self.impl.updateImageContainerWithParentId(containerId: containerId, parentId: parentId)
    }
    
    // MARK: UPDATE PATHS
    
    /// - Tag: updateImageContainerParentFolder(path)
    func updateImageContainerParentFolder(path:String, parentFolder:String) -> ExecuteState{
        return self.impl.updateImageContainerParentFolder(path: path, parentFolder: parentFolder)
    }
    
    /// - Tag: updateImageContainerPaths(oldPath)
    func updateImageContainerPaths(oldPath:String, newPath:String, repositoryPath:String, parentFolder:String, subPath:String) -> ExecuteState{
        return self.impl.updateImageContainerPaths(oldPath: oldPath, newPath: newPath, repositoryPath: repositoryPath, parentFolder: parentFolder, subPath: subPath)
    }
    
    func updateImageContainerPaths(containerId:Int, newPath:String, repositoryPath:String, parentFolder:String, subPath:String) -> ExecuteState {
        return self.impl.updateImageContainerPaths(containerId: containerId, newPath: newPath, repositoryPath: repositoryPath, parentFolder: parentFolder, subPath: subPath)
    }
    
    /// - Tag: updateImageContainerRepositoryPaths(oldPath)
    func updateImageContainerRepositoryPaths(oldPath:String, newPath:String, repositoryPath:String) -> ExecuteState {
        return self.impl.updateImageContainerRepositoryPaths(oldPath: oldPath, newPath: newPath, repositoryPath: repositoryPath)
    }
    
    func updateImageContainerRepositoryPaths(containerId:Int, newPath:String, repositoryPath:String) -> ExecuteState {
        return self.impl.updateImageContainerRepositoryPaths(containerId: containerId, newPath: newPath, repositoryPath: repositoryPath)
    }
    
    
    // MARK: UPDATE FIELDS
    
    /// - Tag: updateImageContainerHideByParent(path)
    func updateImageContainerHideByParent(path:String, hideByParent:Bool) -> ExecuteState{
        return self.impl.updateImageContainerHideByParent(path: path, hideByParent: hideByParent)
    }
    
    /// - Tag: updateImageContainerToggleManyChildren(path)
    func updateImageContainerToggleManyChildren(path:String, state:Bool) -> ExecuteState {
        return self.impl.updateImageContainerToggleManyChildren(path: path, state: state)
    }
    
    
    
    func getOwners() -> [String] {
        return self.impl.getOwners()
    }
    
    func getRepositoryIdsByOwner(owner:String) -> [Int] {
        return self.impl.getRepositoryIdsByOwner(owner: owner)
    }
    
    func getRepositoryIdsByOwners(owners:[String]) -> [Int] {
        return self.impl.getRepositoryIdsByOwners(owners: owners)
    }
}
