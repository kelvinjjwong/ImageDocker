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
        let location = PreferencesController.databaseLocation()
        if location == "local" {
            return RepositoryDao(RepositoryDaoGRDB())
        }else{
            return RepositoryDao(RepositoryDaoPostgresCK())
        }
    }
    
    func getPhysicalPath(container:ImageContainer) -> String {
        return container.path
    }
    
    // MARK: CRUD
    
    func getOrCreateContainer(name:String,
                              path:String,
                              parentPath parentFolder:String = "",
                              repositoryPath:String,
                              homePath:String,
                              storagePath:String,
                              facePath:String,
                              cropPath:String,
                              subPath:String,
                              manyChildren:Bool = false,
                              hideByParent:Bool = false) -> ImageContainer {
        let (container, isNew) = self.impl.getOrCreateContainer(name: name, path: path, parentPath: parentFolder, repositoryPath: repositoryPath, homePath: homePath, storagePath: storagePath, facePath: facePath, cropPath: cropPath, subPath: subPath, manyChildren: manyChildren, hideByParent: hideByParent)
        
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
    
    func deleteRepository(repositoryRoot:String) -> ExecuteState{
        return self.impl.deleteRepository(repositoryRoot: repositoryRoot)
    }
    
    func getContainer(path:String) -> ImageContainer? {
        return self.impl.getContainer(path: path)
    }
    
    func getRepository(repositoryPath:String) -> ImageContainer? {
        return self.impl.getRepository(repositoryPath: repositoryPath)
    }
    
    // MARK: GET PATHS
    
    func getRepositoryPaths(imagesCondition:SearchCondition) -> [String] {
        return self.impl.getRepositoryPaths(imagesCondition: imagesCondition)
    }
    
    func getAllContainerPathsOfImages(rootPath:String? = nil) -> Set<String> {
        return self.impl.getAllContainerPathsOfImages(rootPath: rootPath)
    }
    
    func getAllContainerPaths(rootPath:String? = nil) -> Set<String> {
        return self.impl.getAllContainerPaths(rootPath: rootPath)
    }
    
    func getSubContainerPaths(parent path:String, imagesCondition:SearchCondition) -> [String] {
        return self.impl.getSubContainerPaths(parent: path, imagesCondition: imagesCondition)
    }
    
    // MARK: GET CONTAINERS SET
    
    func getRepositories(orderBy:String = "path", condition:SearchCondition? = nil) -> [ImageContainer] {
        return self.impl.getRepositories(orderBy: orderBy, condition: condition)
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
    
    func getSubContainers(parent path:String, condition:SearchCondition? = nil) -> [ImageContainer] {
        return self.impl.getSubContainers(parent: path, condition: condition)
    }
    
    func countSubContainers(parent path:String) -> Int {
        return self.impl.countSubContainers(parent: path)
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
    
    func hideContainer(path:String) -> ExecuteState{
        return self.impl.hideContainer(path: path)
    }
    
    func showContainer(path:String) -> ExecuteState{
        return self.impl.showContainer(path: path)
    }
    
    func hideRepository(repositoryRoot:String) -> ExecuteState{
        return self.impl.hideRepository(repositoryRoot: repositoryRoot)
    }
    
    func showRepository(repositoryRoot:String) -> ExecuteState{
        return self.impl.showRepository(repositoryRoot: repositoryRoot)
    }
    
    // MARK: - STAT DATE
    
    func getLastPhotoTakenDateOfRepositories() -> [String:String] {
        return self.impl.getLastPhotoTakenDateOfRepositories()
    }
}
