//
//  RepositoryDaoInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/18.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

protocol RepositoryDaoInterface {
    
    func getOrCreateContainer(name:String,
                              path:String,
                              parentPath parentFolder:String,
                              repositoryPath:String,
                              homePath:String,
                              storagePath:String,
                              facePath:String,
                              cropPath:String,
                              subPath:String,
                              manyChildren:Bool,
                              hideByParent:Bool) -> (ImageContainer, Bool)
    
    func deleteContainer(path: String, deleteImage:Bool) -> ExecuteState
    
    func deleteRepository(repositoryRoot:String) -> ExecuteState
    
    func getContainer(path:String) -> ImageContainer?
    
    func getRepository(repositoryPath:String) -> ImageContainer?
    
    func getRepositories(orderBy:String, condition:SearchCondition?) -> [ImageContainer]
    
    func getRepositoryPaths(imagesCondition:SearchCondition) -> [String]
    
    func getSubContainers(parent path:String, condition:SearchCondition?) -> [ImageContainer]
    
    func getSubContainerPaths(parent path:String, imagesCondition:SearchCondition) -> [String]
    
    func countSubContainers(parent path:String) -> Int
    
    func getAllContainers() -> [ImageContainer]
    
    func getContainers(rootPath:String) -> [ImageContainer]
    
    func getAllContainerPathsOfImages(rootPath:String?) -> Set<String>
    
    func getAllContainerPaths(rootPath:String?) -> Set<String>
    
    func getAllContainerPaths(repositoryPath:String?) -> Set<String>
    
    func saveImageContainer(container:ImageContainer) -> ExecuteState
    
    func updateImageContainerSubContainers(path:String) -> Int
    
    func updateImageContainerParentFolder(path:String, parentFolder:String) -> ExecuteState
    
    func updateImageContainerHideByParent(path:String, hideByParent:Bool) -> ExecuteState
    
    func updateImageContainerPaths(oldPath:String, newPath:String, repositoryPath:String, parentFolder:String, subPath:String) -> ExecuteState
    
    func updateImageContainerRepositoryPaths(oldPath:String, newPath:String, repositoryPath:String) -> ExecuteState
    
    func updateImageContainerToggleManyChildren(path:String, state:Bool) -> ExecuteState
    
    func hideContainer(path:String) -> ExecuteState
    
    func showContainer(path:String) -> ExecuteState
    
    func hideRepository(repositoryRoot:String) -> ExecuteState
    
    func showRepository(repositoryRoot:String) -> ExecuteState
    
    // MARK: - DATE
    
    func getLastPhotoTakenDateOfRepositories() -> [String:String]
}
