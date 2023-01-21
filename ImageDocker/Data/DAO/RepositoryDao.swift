//
//  RepositoryDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class RepositoryDao {
    
    let logger = ConsoleLogger(category: "RepositoryDao")
    
    private let impl:RepositoryDaoInterface
    
    init(_ impl:RepositoryDaoInterface){
        self.impl = impl
    }
    
    static var `default`:RepositoryDao {
        let location = Setting.database.databaseLocation()
        if location == "local" {
            return RepositoryDao(RepositoryDaoGRDB())
        }else{
            return RepositoryDao(RepositoryDaoPostgresCK())
        }
    }
    
    func getPhysicalPath(container:ImageContainer) -> String {
        return container.path
    }
    
    // MARK: IMAGE REPOSITORY CRUD
    
    func createRepository(name:String,
                                 path:String,
                                 homePath:String,
                                 storagePath:String,
                                 facePath:String,
                                 cropPath:String) -> ImageFolder {
        self.logger.log("Creating repository with name:\(name) , path:\(path)")
        return ImageFolder(URL(fileURLWithPath: path),
                            name: name,
                            repositoryPath: path,
                            homePath: homePath,
                            storagePath: storagePath,
                            facePath: facePath,
                            cropPath: cropPath)
    }
    
    func deleteRepository(repositoryRoot:String) -> ExecuteState{
        return self.impl.deleteRepository(repositoryRoot: repositoryRoot)
    }
    
    func hideRepository(repositoryRoot:String) -> ExecuteState{
        return self.impl.hideRepository(repositoryRoot: repositoryRoot)
    }
    
    func showRepository(repositoryRoot:String) -> ExecuteState{
        return self.impl.showRepository(repositoryRoot: repositoryRoot)
    }
    
    // MARK: IMAGE REPOSITORY QUERY
    
    func findRepository(volume:String, repositoryPath: String) -> ImageRepository? {
        return self.impl.findRepository(volume: volume, repositoryPath: repositoryPath)
    }
    
    func getRepository(id: Int) -> ImageRepository? {
        return self.impl.getRepository(id: id)
    }
    
    func getRepository(repositoryPath:String) -> ImageContainer? {
        return self.impl.getRepository(repositoryPath: repositoryPath)
    }
    
    func getRepositoriesV2(orderBy: String = "path", condition:SearchCondition?) -> [ImageRepository] {
        return self.impl.getRepositoriesV2(orderBy: orderBy, condition: condition)
    }
    
    func getRepositories(orderBy:String = "path", condition:SearchCondition? = nil) -> [ImageContainer] {
        return self.impl.getRepositories(orderBy: orderBy, condition: condition)
    }
    
    func getRepositoryPaths(imagesCondition:SearchCondition) -> [String] {
        return self.impl.getRepositoryPaths(imagesCondition: imagesCondition)
    }
    
    func getLastPhotoTakenDateOfRepositories() -> [String:String] {
        return self.impl.getLastPhotoTakenDateOfRepositories()
    }
    
    // MARK: IMAGE CONTAINER CRUD
    
    func createContainer(name: String, repositoryId: Int, parentId:Int, subPath: String, repositoryPath: String) -> ImageContainer? {
        return self.impl.createContainer(name: name, repositoryId: repositoryId, parentId: parentId, subPath: subPath, repositoryPath: repositoryPath)
    }
    
    func createEmptyImageContainerLinkToRepository(repositoryId:Int) -> ImageContainer? {
        return self.impl.createEmptyImageContainerLinkToRepository(repositoryId: repositoryId)
    }
    
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
    
    func saveImageContainer(container:ImageContainer) -> ExecuteState{
        return self.impl.saveImageContainer(container: container)
    }
    
    func deleteContainer(path: String, deleteImage:Bool = false) -> ExecuteState {
        return self.impl.deleteContainer(path: path, deleteImage: deleteImage)
    }
    
    func hideContainer(path:String) -> ExecuteState{
        return self.impl.hideContainer(path: path)
    }
    
    func showContainer(path:String) -> ExecuteState{
        return self.impl.showContainer(path: path)
    }
    
    // MARK: IMAGE CONTAINER QUERY
    
    func findContainer(repositoryId:Int, subPath:String) -> ImageContainer? {
        return self.impl.findContainer(repositoryId: repositoryId, subPath: subPath)
    }
    
    func findContainer(repositoryVolume:String, repositoryPath:String, subPath:String) -> ImageContainer? {
        return self.impl.findContainer(repositoryVolume: repositoryVolume, repositoryPath: repositoryPath, subPath: subPath)
    }
    
    func getContainer(path:String) -> ImageContainer? {
        return self.impl.getContainer(path: path)
    }
    
    func getAllContainerPathsOfImages(rootPath:String? = nil) -> Set<String> {
        return self.impl.getAllContainerPathsOfImages(rootPath: rootPath)
    }
    
    func getAllContainerPaths(rootPath:String? = nil) -> Set<String> {
        return self.impl.getAllContainerPaths(rootPath: rootPath)
    }
    
    func getAllContainers() -> [ImageContainer] {
        return self.impl.getAllContainers()
    }
    
    func getContainers(rootPath:String) -> [ImageContainer] {
        return self.impl.getContainers(rootPath: rootPath)
    }
    
    func getAllContainerPaths(repositoryPath:String? = nil) -> Set<String> {
        return self.impl.getAllContainerPaths(repositoryPath: repositoryPath)
    }
    
    // MARK: SUB CONTAINER QUERY
    
    func getSubContainersSingleLevel(repositoryId:Int, condition:SearchCondition?) -> [ImageContainer] {
        return self.impl.getSubContainersSingleLevel(repositoryId: repositoryId, condition: condition)
    }
    
    func getSubContainersSingleLevel(containerId:Int, condition:SearchCondition?) -> [ImageContainer] {
        return self.impl.getSubContainersSingleLevel(containerId: containerId, condition: condition)
    }
    
    func getSubContainerPaths(parent path:String, imagesCondition:SearchCondition) -> [String] {
        return self.impl.getSubContainerPaths(parent: path, imagesCondition: imagesCondition)
    }
    
    func getSubContainers(parent path:String, condition:SearchCondition? = nil) -> [ImageContainer] {
        return self.impl.getSubContainers(parent: path, condition: condition)
    }
    
    func countSubContainers(parent path:String) -> Int {
        return self.impl.countSubContainers(parent: path)
    }
    
    func countSubContainers(repositoryId:Int) -> Int {
        return self.impl.countSubContainers(repositoryId: repositoryId)
    }
    
    func countSubContainers(containerId:Int) -> Int {
        return self.impl.countSubContainers(containerId: containerId)
    }
    
    func countSubImages(containerId:Int) -> Int {
        return self.impl.countSubImages(containerId: containerId)
    }
    
    // MARK: GET PARENT CONTAINER
    
    func getParentContainer(thisContainer: ImageContainer) -> ImageContainer? {
        if thisContainer.parentFolder != "" {
            if let parentContainer = self.getContainer(path: thisContainer.parentFolder) {
                return parentContainer
            }
        }
        return nil
    }
    
    func getParentContainer(thisPath: String) -> ImageContainer? {
        if let thisContainer = self.getContainer(path: thisPath) {
            return self.getParentContainer(thisContainer: thisContainer)
        }
        return nil
    }
    
    // MARK: UPDATE SUB CONTAINERS AMOUNT
    
    func updateParentContainerSubContainers(parentPath:String) -> Int {
        return self.updateImageContainerSubContainers(path: parentPath)
    }
    
    func updateParentContainerSubContainers(thisPath:String) -> Int {
        if let parentContainer = self.getParentContainer(thisPath: thisPath){
            return self.updateImageContainerSubContainers(path: parentContainer.path)
        }
        return -1
    }
    
    func updateImageContainerSubContainers(path:String) -> Int {
        return self.impl.updateImageContainerSubContainers(path: path)
    }
    
    // MARK: UPDATE ID
    
    func updateImageContainerWithRepositoryId(containerId:Int, repositoryId:Int) -> ExecuteState {
        return self.impl.updateImageContainerWithRepositoryId(containerId: containerId, repositoryId: repositoryId)
    }
    
    func updateImageContainerWithParentId(containerId:Int, parentId:Int) -> ExecuteState {
        return self.impl.updateImageContainerWithParentId(containerId: containerId, parentId: parentId)
    }
    
    // MARK: UPDATE PATHS
    
    func updateImageContainerParentFolder(path:String, parentFolder:String) -> ExecuteState{
        return self.impl.updateImageContainerParentFolder(path: path, parentFolder: parentFolder)
    }
    
    func updateImageContainerPaths(oldPath:String, newPath:String, repositoryPath:String, parentFolder:String, subPath:String) -> ExecuteState{
        return self.impl.updateImageContainerPaths(oldPath: oldPath, newPath: newPath, repositoryPath: repositoryPath, parentFolder: parentFolder, subPath: subPath)
    }
    
    func updateImageContainerRepositoryPaths(oldPath:String, newPath:String, repositoryPath:String) -> ExecuteState {
        return self.impl.updateImageContainerRepositoryPaths(oldPath: oldPath, newPath: newPath, repositoryPath: repositoryPath)
    }
    
    
    // MARK: UPDATE FIELDS
    
    func updateImageContainerHideByParent(path:String, hideByParent:Bool) -> ExecuteState{
        return self.impl.updateImageContainerHideByParent(path: path, hideByParent: hideByParent)
    }
    
    func updateImageContainerToggleManyChildren(path:String, state:Bool) -> ExecuteState {
        return self.impl.updateImageContainerToggleManyChildren(path: path, state: state)
    }
}
