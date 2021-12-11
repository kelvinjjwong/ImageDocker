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
        print("\(Date()) [TREE] start load repositories from database")
        let startTime = Date()
        let containers = RepositoryDao.default.getRepositories(orderBy: "name", condition: condition)
        let gap = Date().timeIntervalSince(startTime)
        print("\(Date()) [TREE] db time cost \(gap)")
        if containers.count == 0 {
//            print(">>> no repository is loaded for tree")
        }
        let startTime2 = Date()
        for container in containers {
//            print(">>> loaded repo for tree: \(container.name)")
            print("\(Date()) [TREE] converting repository container to tree node - \(container.path)")
            let node = self.convertToTreeNode(container)
            nodes.append(node)
        }
        let gap2 = Date().timeIntervalSince(startTime2)
        print("\(Date()) [TREE] collection insertion time cost \(gap2)")
        return nodes
    }
    
    func loadSubContainers(parentPath: String, condition:SearchCondition? = nil) -> [TreeCollection] {
        var nodes:[TreeCollection] = []
        print("\(Date()) [TREE] start load sub containers from database")
        let startTime = Date()
        let containers = RepositoryDao.default.getSubContainers(parent: parentPath, condition: condition)
        let gap = Date().timeIntervalSince(startTime)
        print("\(Date()) [TREE] db time cost \(gap)")
        
        let startTime2 = Date()
        for container in containers {
            print("\(Date()) [TREE] converting sub container to tree node - \(container.path)")
            let node = self.convertToTreeNode(container)
            nodes.append(node)
        }
        let gap2 = Date().timeIntervalSince(startTime2)
        print("\(Date()) [TREE] collection insertion time cost \(gap2)")
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
