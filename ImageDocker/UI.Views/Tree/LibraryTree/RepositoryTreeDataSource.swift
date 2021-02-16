//
//  RepositoryTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class RepositoryTreeDataSource : TreeDataSource {
    
    func convertToTreeNode(_ container:ImageContainer) -> TreeCollection {
        //print("repo node name \(container.name)")
        let node = TreeCollection(container.name, id: container.path, object: container)
        let childCount = RepositoryDao.default.countSubContainers(parent: container.path)
        node.childrenCount = childCount
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
        let containers = RepositoryDao.default.getRepositories(orderBy: "name", condition: condition)
        if containers.count == 0 {
//            print(">>> no repository is loaded for tree")
        }
        for container in containers {
//            print(">>> loaded repo for tree: \(container.name)")
            let node = self.convertToTreeNode(container)
            nodes.append(node)
        }
        return nodes
    }
    
    func loadSubContainers(parentPath: String, condition:SearchCondition? = nil) -> [TreeCollection] {
        var nodes:[TreeCollection] = []
        let containers = RepositoryDao.default.getSubContainers(parent: parentPath, condition: condition)
        for container in containers {
            let node = self.convertToTreeNode(container)
            nodes.append(node)
        }
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
