//
//  RepositoryDaoInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/18.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

protocol RepositoryDaoInterface {
    
    // MARK: IMAGE REPOSITORY CRUD
    
    func deleteRepository(repositoryRoot:String) -> ExecuteState
    
    // MARK: IMAGE REPOSITORY QUERY
    
    func findRepository(volume:String, repositoryPath: String) -> ImageRepository?
    
    func getRepository(id: Int) -> ImageRepository?
    
    func getRepository(repositoryPath:String) -> ImageContainer?
    
    func getRepositoriesV2(orderBy: String, condition:SearchCondition?) -> [ImageRepository]
    
    func getRepositories(orderBy:String, condition:SearchCondition?) -> [ImageContainer]
    
    func getRepositoryPaths(imagesCondition:SearchCondition) -> [String]
    
    // MARK: IMAGE REPOSITORY UPDATE
    
    func hideRepository(repositoryRoot:String) -> ExecuteState
    
    func showRepository(repositoryRoot:String) -> ExecuteState
    
    func getLastPhotoTakenDateOfRepositories() -> [String:String]
    
    // MARK: IMAGE CONTAINER QUERY
    
    func findContainer(repositoryId:Int, subPath:String) -> ImageContainer?
    
    func findContainer(repositoryVolume:String, repositoryPath:String, subPath:String) -> ImageContainer? 
    
    func getContainer(path:String) -> ImageContainer?
    
    func getAllContainers() -> [ImageContainer]
    
    func getContainers(rootPath:String) -> [ImageContainer]
    
    func getAllContainerPathsOfImages(rootPath:String?) -> Set<String>
    
    func getAllContainerPaths(rootPath:String?) -> Set<String>
    
    func getAllContainerPaths(repositoryPath:String?) -> Set<String>
    
    // MARK: IMAGE CONTAINER CRUD
    
    func createContainer(name: String, repositoryId: Int, parentId:Int, subPath: String, repositoryPath: String) -> ImageContainer?
    
    func createEmptyImageContainerLinkToRepository(repositoryId:Int) -> ImageContainer?
    
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
    
    func saveImageContainer(container:ImageContainer) -> ExecuteState
    
    func hideContainer(path:String) -> ExecuteState
    
    func showContainer(path:String) -> ExecuteState
    
    // MARK: SUB CONTAINER QUERY
    
    func getSubContainersSingleLevel(repositoryId:Int, condition:SearchCondition?) -> [ImageContainer]
    
    func getSubContainersSingleLevel(containerId:Int, condition:SearchCondition?) -> [ImageContainer]
    
    func getSubContainers(parent path:String, condition:SearchCondition?) -> [ImageContainer]
    
    func getSubContainerPaths(parent path:String, imagesCondition:SearchCondition) -> [String]
    
    func countSubContainers(parent path:String) -> Int
    
    func countSubContainers(repositoryId:Int) -> Int
    
    func countSubContainers(containerId:Int) -> Int
    
    func countSubImages(containerId:Int) -> Int
    
    // MARK: SUB CONTAINER UPDATE
    
    func updateImageContainerSubContainers(path:String) -> Int
    
    func updateImageContainerWithRepositoryId(containerId:Int, repositoryId:Int) -> ExecuteState
    
    func updateImageContainerWithParentId(containerId:Int, parentId:Int) -> ExecuteState
    
    func updateImageContainerParentFolder(path:String, parentFolder:String) -> ExecuteState
    
    func updateImageContainerHideByParent(path:String, hideByParent:Bool) -> ExecuteState
    
    func updateImageContainerPaths(oldPath:String, newPath:String, repositoryPath:String, parentFolder:String, subPath:String) -> ExecuteState
    
    func updateImageContainerRepositoryPaths(oldPath:String, newPath:String, repositoryPath:String) -> ExecuteState
    
    func updateImageContainerToggleManyChildren(path:String, state:Bool) -> ExecuteState
}
