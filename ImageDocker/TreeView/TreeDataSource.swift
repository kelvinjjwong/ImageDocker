//
//  TreeCollection.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/11/2.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class TreeCollection {
    
    var name = ""
    var childrenCount = 0
    var path = ""
    
    var children:[TreeCollection] = []
    private var mapping:[String:TreeCollection] = [:]
    
    var button:NSButton?
    
    init(_ name:String) {
        self.name = name
        self.path = name
    }
    
    static func clone(from collection:TreeCollection) -> TreeCollection{
        let data = TreeCollection(collection.name)
        data.path = collection.path
        data.childrenCount = collection.childrenCount
        return data
    }
    
    func addChild(_ name:String){
        let child = TreeCollection(name)
        child.path = "\(path)/\(name)"
        self.children.append(child)
        self.mapping[name] = child
        self.childrenCount = self.children.count
        print("added \(child.path)")
    }
    
    func addChild(collection:TreeCollection) {
        self.children.append(collection)
        self.mapping[collection.name] = collection
    }
    
    func getChild(_ name:String) -> TreeCollection? {
        return self.mapping[name]
    }
    
    func getUnlimitedDepthChildren() -> [TreeCollection] {
        var result:[TreeCollection] = []
        for child in children {
            result.append(child)
            print("flatted: \(child.path)")
            result.append(contentsOf: child.getUnlimitedDepthChildren())
        }
        return result
    }
    
}

protocol TreeDataSource {
    
    func convertFlatToTree()
    func loadChildren(_ collection:TreeCollection?) -> [TreeCollection]
    func findNode(path: String) -> TreeCollection?
    func filter(keyword: String)
    func findNode(keyword: String) -> TreeCollection?
}

class StaticTreeDataSource : TreeDataSource {
    
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
    
    func loadChildren(_ collection:TreeCollection?) -> [TreeCollection] {
        
        var resultDataset:[TreeCollection] = []
        var sourceDataset:[TreeCollection] = []
        
        if let c = collection {
            let path = c.path
            print("loading children of \(path)")
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
            resultDataset.append(child)
        }
        print("loaded \(resultDataset.count) children")
        return resultDataset
    }
    
    internal func findNode(path: String) -> TreeCollection? {
        for data in flattable_all {
            if data.path == path {
                print("got it from source datas")
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
        print("find node containing \(keyword)")
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
