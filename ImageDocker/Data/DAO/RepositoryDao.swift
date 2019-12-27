//
//  RepositoryDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class RepositoryDao {
    
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
        return ModelStore.default.getOrCreateContainer(name: name, path: path, parentPath: parentFolder, repositoryPath: repositoryPath, homePath: homePath, storagePath: storagePath, facePath: facePath, cropPath: cropPath, subPath: subPath, manyChildren: manyChildren, hideByParent: hideByParent)
    }
    
    func deleteContainer(path: String, deleteImage:Bool = false) -> ExecuteState {
        return ModelStore.default.deleteContainer(path: path, deleteImage: deleteImage)
    }
    
    func deleteRepository(repositoryRoot:String) -> ExecuteState{
        return ModelStore.default.deleteRepository(repositoryRoot: repositoryRoot)
    }
    
    func getContainer(path:String) -> ImageContainer? {
        return ModelStore.default.getContainer(path: path)
    }
    
    func getRepository(repositoryPath:String) -> ImageContainer? {
        return ModelStore.default.getRepository(repositoryPath: repositoryPath)
    }
    
    func getRepositories() -> [ImageContainer] {
        return ModelStore.default.getRepositories()
    }
    
    func getAllContainers() -> [ImageContainer] {
        return ModelStore.default.getAllContainers()
    }
    
    func getContainers(rootPath:String) -> [ImageContainer] {
        return ModelStore.default.getContainers(rootPath: rootPath)
    }
    
    func getAllContainerPathsOfImages(rootPath:String? = nil) -> Set<String> {
        return ModelStore.default.getAllContainerPathsOfImages(rootPath: rootPath)
    }
    
    func getAllContainerPaths(rootPath:String? = nil) -> Set<String> {
        return ModelStore.default.getAllContainerPaths(rootPath: rootPath)
    }
    
    func getAllContainerPaths(repositoryPath:String? = nil) -> Set<String> {
        return ModelStore.default.getAllContainerPaths(repositoryPath: repositoryPath)
    }
    
    func saveImageContainer(container:ImageContainer) -> ExecuteState{
        return ModelStore.default.saveImageContainer(container: container)
    }
    
    func updateImageContainerParentFolder(path:String, parentFolder:String) -> ExecuteState{
        return ModelStore.default.updateImageContainerParentFolder(path: path, parentFolder: parentFolder)
    }
    
    func updateImageContainerHideByParent(path:String, hideByParent:Bool) -> ExecuteState{
        return ModelStore.default.updateImageContainerHideByParent(path: path, hideByParent: hideByParent)
    }
    
    func updateImageContainerPaths(oldPath:String, newPath:String, repositoryPath:String, parentFolder:String, subPath:String) -> ExecuteState{
        return ModelStore.default.updateImageContainerPaths(oldPath: oldPath, newPath: newPath, repositoryPath: repositoryPath, parentFolder: parentFolder, subPath: subPath)
    }
    
    func updateImageContainerRepositoryPaths(oldPath:String, newPath:String, repositoryPath:String) -> ExecuteState {
        return ModelStore.default.updateImageContainerRepositoryPaths(oldPath: oldPath, newPath: newPath, repositoryPath: repositoryPath)
    }
    
    func updateImageContainerToggleManyChildren(path:String, state:Bool) -> ExecuteState {
        return ModelStore.default.updateImageContainerToggleManyChildren(path: path, state: state)
    }
    
    func hideContainer(path:String) -> ExecuteState{
        return ModelStore.default.hideContainer(path: path)
    }
    
    func showContainer(path:String) -> ExecuteState{
        return ModelStore.default.showContainer(path: path)
    }
    
    func hideRepository(repositoryRoot:String) -> ExecuteState{
        return ModelStore.default.hideRepository(repositoryRoot: repositoryRoot)
    }
    
    func showRepository(repositoryRoot:String) -> ExecuteState{
        return ModelStore.default.showRepository(repositoryRoot: repositoryRoot)
    }
    
    // MARK: - DATE
    
    func getLastPhotoTakenDateOfRepositories() -> [String:String] {
        return ModelStore.default.getLastPhotoTakenDateOfRepositories()
    }
}
