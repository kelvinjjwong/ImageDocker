//
//  RepositoryTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class RepositoryTreeDataSource : TreeDataSource {
    
    let repositoryDao = RepositoryDao.default
    
    func convertToTreeNode(_ container:ImageContainer) -> TreeCollection {
        print("repo node name \(container.name)")
        let node = TreeCollection(container.name, id: container.path, object: container)
        let childCount = self.repositoryDao.countSubContainers(parent: container.path)
        node.childrenCount = childCount
        return node
    }
    
    func loadChildren(_ collection: TreeCollection?) -> ([TreeCollection], String?) {
        if collection == nil {
            return (self.loadRepositories(), nil)
        }else{
            if let container = collection?.relatedObject as? ImageContainer {
                return (self.loadSubContainers(parentPath: container.path), nil)
            }
        }
        return ([], nil)
    }
    
    func loadRepositories() -> [TreeCollection] {
        var nodes:[TreeCollection] = []
        let containers = self.repositoryDao.getRepositories(orderBy: "name")
        if containers.count == 0 {
            print(">>> no repository is loaded for tree")
        }
        for container in containers {
            print(">>> loaded repo for tree: \(container.name)")
            let node = self.convertToTreeNode(container)
            nodes.append(node)
        }
        return nodes
    }
    
    func loadSubContainers(parentPath: String) -> [TreeCollection] {
        var nodes:[TreeCollection] = []
        let containers = self.repositoryDao.getSubContainers(parent: parentPath)
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
