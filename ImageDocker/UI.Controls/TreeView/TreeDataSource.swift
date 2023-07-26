//
//  TreeCollection.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/11/2.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class TreeCollection {
    
    let logger = LoggerFactory.get(category: "TreeCollection")
    
    var name = ""
    var path = ""
    var childrenCount = 0
    var connectedCount = 0
    
    var subContainersCount = 0
    var subImagesCount = 0
    var hiddenImagesCount = 0
    
    
    var subCollectionsInCollection = 0
    var itemsInCollection = 0
    
    var children:[TreeCollection] = []
    private var mapping:[String:TreeCollection] = [:]
    
    var expandable = false
    
    var icon:NSImage?
    var titleField:NSTextField?
    var valueField:NSTextField?
    var button:NSButton?
    
    var relatedObject:Any?
    var relatedObjectId:String?
    var relatedObjectState:Int?
    
    init(_ name:String) {
        self.name = name
        self.path = name
    }
    
    convenience init(_ name:String, id:String, object:Any){
        self.init(name)
        self.relatedObjectId = id
        self.relatedObject = object
    }
    
    convenience init(_ name:String, id:String, object:Any, state:Int){
        self.init(name)
        self.relatedObjectId = id
        self.relatedObject = object
        self.relatedObjectState = state
    }
    
    static func clone(from collection:TreeCollection) -> TreeCollection{
        let data = TreeCollection(collection.name)
        data.path = collection.path
        data.childrenCount = collection.childrenCount
        data.subContainersCount = collection.subContainersCount
        data.subImagesCount = collection.subImagesCount
        data.hiddenImagesCount = collection.hiddenImagesCount
        data.expandable = collection.expandable
        return data
    }
    
    func addChild(_ name:String){
        // clone data
        let child = TreeCollection(name)
        child.path = "\(path)/\(name)"
        
        self.children.append(child)
        self.mapping[name] = child
        self.childrenCount = self.children.count
        self.logger.log("added \(child.path)")
    }
    
    func addChild(collection:TreeCollection) {
        if let exist = self.mapping[collection.name] {
            exist.relatedObjectId = collection.relatedObjectId
            exist.relatedObject = collection.relatedObject
            exist.relatedObjectState = collection.relatedObjectState
        }else{
            self.children.append(collection)
            self.mapping[collection.name] = collection
            self.childrenCount = self.children.count
        }
    }
    
    func removeAllChildren() {
        self.children.removeAll()
        self.mapping.removeAll()
        self.childrenCount = 0
    }
    
    func getChild(_ name:String) -> TreeCollection? {
        return self.mapping[name]
    }
    
    func getUnlimitedDepthChildren() -> [TreeCollection] {
        var result:[TreeCollection] = []
        for child in children {
            result.append(child)
            self.logger.log("flatted: \(child.path)")
            result.append(contentsOf: child.getUnlimitedDepthChildren())
        }
        return result
    }
    
}

protocol TreeDataSource {
    
    func loadChildren(_ collection:TreeCollection?, condition:SearchCondition?) -> ([TreeCollection], String?, String?)
    func findNode(path: String) -> TreeCollection?
    func filter(keyword: String)
    func findNode(keyword: String) -> TreeCollection?
}


// sample only
class StaticTreeDataSource : TreeDataSource {
    
    let logger = LoggerFactory.get(category: "StaticTreeDataSource")
    
    internal var tree_datas:[TreeCollection] = []
    internal var flattable_all:[TreeCollection] = []
    internal var flattable_filtered:[TreeCollection] = []
    internal var pathToNode:[String:TreeCollection] = [:]
    
    func convertFlatToTree() {
        self.tree_datas = self.convertFlatToTree(flattable_filtered)
    }
    
    func convertFlatToTree(_ collections:[TreeCollection]) -> [TreeCollection]{
        var tree:[TreeCollection] = []
        var pathToNode:[String:TreeCollection] = [:]
        for collection in collections {
            pathToNode[collection.path] = collection
            let level = self.countCharacter(in: collection.path) + 1
            if level == 1 {
                collection.children = self.getChildrenFromFlatTable(path: collection.path, flatTable: collections, recursive: true)
                tree.append(collection)
            }
        }
        self.pathToNode = pathToNode
        return tree
    }
    
    private func countCharacter(in text:String) -> Int {
        let char:Character = "/"
        let sensitiveCount = text.filter { $0 == char }.count
        return sensitiveCount
    }
    
    private func getChildrenFromFlatTable(path:String, flatTable:[TreeCollection], recursive:Bool = false) -> [TreeCollection]{
        let key = "\(path)/"
        let wantsLevel = self.countCharacter(in: key)
        
        var result:[TreeCollection] = []
        for collection in flatTable {
            let collectionLevel = self.countCharacter(in: collection.path)
            if collection.path.hasPrefix(key) && collectionLevel == wantsLevel {
                result.append(collection)
                
                if recursive {
                    collection.children = self.getChildrenFromFlatTable(path: collection.path, flatTable: flatTable, recursive: true)
                }
            }
        }
        return result
    }
    
    func loadChildren(_ collection:TreeCollection?, condition:SearchCondition?) -> ([TreeCollection], String?, String?) {
        
        if let condition = condition, !condition.isEmpty() {
            // FIXME: search images first
        }
        
        var resultDataset:[TreeCollection] = []
        var sourceDataset:[TreeCollection] = []
        
        if let c = collection {
            let path = c.path
            self.logger.log("loading children of \(path)")
            if let node = self.findNode(path: path) {
                sourceDataset = node.children
            }
        }else {
            sourceDataset = tree_datas
        }
        for data in sourceDataset {
            let child = TreeCollection(data.name)
            child.path = data.path
            child.childrenCount = data.children.count
            child.subContainersCount = data.subContainersCount
            child.subImagesCount = data.subImagesCount
            child.hiddenImagesCount = data.hiddenImagesCount
            child.expandable = data.expandable
            resultDataset.append(child)
        }
        self.logger.log("loaded \(resultDataset.count) children")
        return (resultDataset, nil, nil)
    }
    
    internal func findNode(path: String) -> TreeCollection? {
        for data in flattable_all {
            if data.path == path {
                self.logger.log("got it from source datas")
                return data
            }
        }
        return nil
    }
    
    func filter(keyword: String) {
        if keyword == "" {
            self.flattable_filtered = self.flattable_all
        }else{
            var result:[TreeCollection] = []
            
            var pathToCollection:[String:TreeCollection] = [:]
            for data in flattable_all {
                if data.path.contains(keyword) {
                    let paths = self.findParentPaths(path: data.path)
                    for path in paths {
                        if let c = self.pathToNode[path] {
                            pathToCollection[path] = c
                        }
                    }
                }
            }
            for (_, node) in pathToCollection {
                result.append(node)
            }
            result.sort { (c1, c2) -> Bool in
                return c1.path < c2.path
            }
            self.flattable_filtered = result
        }
    }
    
    func findNode(keyword: String) -> TreeCollection? {
        self.logger.log("find node containing \(keyword)")
        return nil
    }
    
    func findParentPaths(path:String) -> [String] {
        let parts = path.components(separatedBy: "/")
        var paths:[String] = []
        for part in parts {
            if paths.count == 0 {
                paths.append(part)
            }else{
                let parentPath = paths[paths.count - 1]
                let thisPath = "\(parentPath)/\(part)"
                paths.append(thisPath)
            }
        }
        return paths
    }
}
