//
//  RepositoryTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class RepositoryTreeDataSource : TreeDataSource {
    
    let logger = ConsoleLogger(category: "RepositoryTreeDataSource")
    
    func convertToTreeNode(_ container:ImageContainer) -> TreeCollection {
        //self.logger.log("convert to tree node - \(container.path)")
        let node = TreeCollection(container.name, id: container.path, object: container)
        if container.subContainers == -1 {
            let childCount = RepositoryDao.default.updateImageContainerSubContainers(path: container.path)
            node.childrenCount = childCount
        }else{
            node.childrenCount = container.subContainers
        }
        return node
    }
    
    func loadChildren(_ collection: TreeCollection?, condition:SearchCondition?) -> ([TreeCollection], String?) {
        
        if collection == nil {
            return (self.loadRepositories(condition: condition), nil)
        }else{
            if let container = collection?.relatedObject as? ImageContainer {
                return (self.loadSubContainers(parentPath: container.path, condition: condition), nil)
            }
        }
        return ([], nil)
    }
    
    func loadRepositories(condition:SearchCondition? = nil) -> [TreeCollection] {
        var nodes:[TreeCollection] = []
        self.logger.log("load repositories from database - START")
        let startTime = Date()
        let containers = RepositoryDao.default.getRepositories(orderBy: "name", condition: condition)
        self.logger.timecost("load repositories from database - DONE", fromDate: startTime)
        if containers.count == 0 {
//            self.logger.log(">>> no repository is loaded for tree")
        }
        let startTime2 = Date()
        for container in containers {
//            self.logger.log(">>> loaded repo for tree: \(container.name)")
            //self.logger.log("converting repository container to tree node - \(container.path)")
            let node = self.convertToTreeNode(container)
            nodes.append(node)
        }
        self.logger.timecost("convert to TreeNode(s)", fromDate: startTime2)
        return nodes
    }
    
    func loadSubContainers(parentPath: String, condition:SearchCondition? = nil) -> [TreeCollection] {
        var nodes:[TreeCollection] = []
        self.logger.log("load sub containers from database - START")
        let startTime = Date()
        let containers = RepositoryDao.default.getSubContainers(parent: parentPath, condition: condition)
        self.logger.timecost("load sub containers from database - DONE", fromDate: startTime)
        
        let startTime2 = Date()
        for container in containers {
            self.logger.log("converting sub container to tree node - \(container.path)")
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
