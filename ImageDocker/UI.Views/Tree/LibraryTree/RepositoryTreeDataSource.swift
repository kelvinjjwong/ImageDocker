//
//  RepositoryTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

class RepositoryTreeDataSource : TreeDataSource {
    
    let logger = LoggerFactory.get(category: "RepositoryTreeDataSource", types: [])
    
    func containsNode(id:String, in nodes:[TreeCollection]) -> Bool {
        return self.findNode(id: id, in: nodes) != nil
    }
    
    func findNode(id:String, in nodes:[TreeCollection]) -> TreeCollection? {
        for n in nodes {
            if let nodeId = n.relatedObjectId {
                if nodeId.contains(find: "_\(id)") {
                    return n
                }
            }
        }
        return nil
    }
    
    func convertToTreeNode(ownerId:String, ownerName:String) -> TreeCollection {
        let id = "OWNER_\(ownerId)"
        let node = TreeCollection(ownerName, id:id, object: ownerId)
        node.childrenCount = 0
        node.subContainersCount = 0
        return node
    }
    
    func convertToTreeNode(_ repository:ImageRepository) -> TreeCollection {
        self.logger.log(.trace, "convert repository to tree node - repositoryId:\(repository.id)")
        let id = "REPO_\(repository.id)"
        let subContainersCount = RepositoryDao.default.countSubContainers(repositoryId: repository.id)
        let node = TreeCollection(repository.name, id: id, object: repository)
        self.logger.log(.debug, "repository \(repository.id) sub containers count: \(subContainersCount), name: \(repository.name)")
        node.childrenCount = subContainersCount
        node.subContainersCount = subContainersCount
        return node
    }
    
    func convertToTreeNode(_ container:ImageContainer) -> TreeCollection {
        self.logger.log(.info, "convert container to tree node - containerId:\(container.id), repositoryId:\(container.repositoryId), parentId:\(container.parentId) path:\(container.path)")
        let node = TreeCollection(container.name, id: "CONT_\(container.id)", object: container)
        let subContainersCount = RepositoryDao.default.countSubContainers(containerId: container.id)
        let subImagesCount = RepositoryDao.default.countSubImages(containerId: container.id)
        let childCount = subContainersCount + subImagesCount
        self.logger.log(.debug, "container \(container.id) sub containers count: \(subContainersCount), sub images count: \(subImagesCount), total sub count: \(childCount), name: \(container.name)")
        node.childrenCount = childCount
        node.subContainersCount = subContainersCount
        node.subImagesCount = subImagesCount
        return node
    }
    
    func loadChildren(_ collection: TreeCollection?, condition:SearchCondition?) -> ([TreeCollection], String?, String?) {
        
        if collection == nil {
            return (self.loadRepositories(condition: condition), nil, nil)
        }else{
            if let repository = collection?.relatedObject as? ImageRepository {
                let path = Naming.Image.generateFullAbsoluteRepositoryPath(repositoryVolume: repository.repositoryVolume, repositoryPath: repository.repositoryPath)
                return (self.loadSubContainers(repositoryId: repository.id), nil, nil)  //.loadSubContainers(parentPath: path, condition: condition), nil)
            }else if let container = collection?.relatedObject as? ImageContainer {
                    return (self.loadSubContainers(containerId: container.id), nil, nil) //.loadSubContainers(parentPath: container.path, condition: condition), nil)
            }
        }
        return ([], nil, nil)
    }
    
    func loadRepositories(condition:SearchCondition? = nil) -> [TreeCollection] {
        var nodes:[TreeCollection] = []
        self.logger.log(.trace, "load repositories from database - START")
        let startTime = Date()
        
        var coreMembers:[String:String] = [:]
        coreMembers["shared"] = Words.owner_public_shared.word()
        var ppl = FaceDao.default.getCoreMembers()
        for p in ppl {
            coreMembers[p.id] = p.shortName ?? p.name
        }
        
        let containers = RepositoryDao.default.getRepositoriesV2(orderBy: "owner, \"sequenceOrder\" desc", condition: condition)
        self.logger.timecost("load repositories from database - DONE", fromDate: startTime)
        if containers.count == 0 {
//            self.logger.log(.trace, ">>> no repository is loaded for tree")
        }
        let startTime2 = Date()
        for container in containers {
//            self.logger.log(.trace, ">>> loaded repo for tree: \(container.name)")
            self.logger.log(.trace, "converting repository to tree node - id:\(container.id) , owner:\(container.owner)")
            
            let ownerNode = self.findNode(id: container.owner, in: nodes) ?? self.convertToTreeNode(ownerId: container.owner, ownerName: coreMembers[container.owner] ?? container.owner)
            if !self.containsNode(id: container.owner, in: nodes) {
                nodes.append(ownerNode)
            }
            
            let node = self.convertToTreeNode(container)
            ownerNode.children.append(node)
            
            ownerNode.childrenCount = ownerNode.children.count
            ownerNode.subContainersCount = ownerNode.children.count
        }
        self.logger.timecost("convert image repository to TreeNode(s)", fromDate: startTime2)
        return nodes
    }
    
    func loadSubContainers(repositoryId: Int, condition:SearchCondition? = nil) -> [TreeCollection] {
        var nodes:[TreeCollection] = []
        self.logger.log(.trace, "load sub containers from database - START - repositoryId: \(repositoryId)")
        let startTime = Date()
        let containers = RepositoryDao.default.getSubContainersSingleLevel(repositoryId: repositoryId, condition: condition)
        self.logger.timecost("load sub containers from database - DONE - repositoryId: \(repositoryId)", fromDate: startTime)
        
        let startTime2 = Date()
        for container in containers {
            container.repositoryId = repositoryId
            self.logger.log(.trace, "converting sub container to tree node - \(container.path)")
            let node = self.convertToTreeNode(container)
            nodes.append(node)
        }
        self.logger.timecost("collection to TreeNode(s)", fromDate: startTime2)
        return nodes
    }
    
    func loadSubContainers(containerId: Int, condition:SearchCondition? = nil) -> [TreeCollection] {
        var nodes:[TreeCollection] = []
        self.logger.log(.trace, "load sub containers from database - START - containerId: \(containerId)")
        let startTime = Date()
        let containers = RepositoryDao.default.getSubContainersSingleLevel(containerId: containerId, condition: condition)
        self.logger.timecost("load sub containers from database - DONE - containerId: \(containerId)", fromDate: startTime)
        
        let startTime2 = Date()
        for container in containers {
            self.logger.log(.trace, "converting sub container to tree node - \(container.path)")
            let node = self.convertToTreeNode(container)
            nodes.append(node)
        }
        self.logger.timecost("collection to TreeNode(s)", fromDate: startTime2)
        return nodes
    }
    
    /// - Tag: RepositoryTreeDataSource.loadSubContainers(parentPath)
    func loadSubContainers(parentPath: String, condition:SearchCondition? = nil) -> [TreeCollection] {
        var nodes:[TreeCollection] = []
        self.logger.log(.trace, "load sub containers from database - START - parentFolder: \(parentPath.removeLastStash())")
        let startTime = Date()
        let containers = RepositoryDao.default.getSubContainers(parent: parentPath.removeLastStash(), condition: condition)
        self.logger.timecost("load sub containers from database - DONE - parentFolder: \(parentPath.removeLastStash())", fromDate: startTime)
        
        let startTime2 = Date()
        for container in containers {
            self.logger.log(.trace, "converting sub container to tree node - \(container.path)")
            let node = self.convertToTreeNode(container)
            nodes.append(node)
        }
        self.logger.timecost("collection to TreeNode(s)", fromDate: startTime2)
        return nodes
    }
    
    
    
    func findNode(path: String) -> TreeCollection? {
        return nil
    }
    
    func filter(keyword: String) {
        
    }
    
    func findNode(keyword: String) -> TreeCollection? {
        return nil
    }
    
    
}
