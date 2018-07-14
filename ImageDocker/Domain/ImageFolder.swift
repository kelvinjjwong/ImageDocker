//
//  ImageFolder.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/3.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

class ImageFolder : NSObject {
    
    var url:URL
    var countOfImages:Int = 0
    var children:[ImageFolder] = []
    var sumOfImages:Int = 0
    var parent:ImageFolder? = nil
    var photoCollection:PhotoCollection? = nil
    var containerFolder:ImageContainer? = nil
    
    init(_ url:URL, countOfImages:Int = 0, updateModelStore:Bool = true){
        self.url = url
        self.countOfImages = countOfImages
        
        let path:String = url.path
        let name:String = url.lastPathComponent
        //print("LOAD FOLDER 2 \(name) \(path)")
        
        self.containerFolder = ModelStore.default.getOrCreateContainer(name: name, path: path)
        if self.containerFolder?.imageCount == nil {
            self.containerFolder?.imageCount = countOfImages
        }
        
    }
    
    func setParent(_ parent:ImageFolder) {
        self.parent = parent
        if containerFolder != nil && containerFolder?.parentFolder == "" {
            containerFolder?.parentFolder = parent.url.path
        }
        
        parent.addChild(self)
    }
    
    func addChild(_ folder:ImageFolder) {
        children.append(folder)
    }
    
    func totalCountOfImages() -> Int {
        let count:Int = self.countOfImages + sumUpImagesFromChildren(self)
        if containerFolder != nil {
            containerFolder?.imageCount = count
        }
        return count
    }
    
    fileprivate func sumUpImagesFromChildren(_ startsAt:ImageFolder) -> Int {
        var sum:Int = 0
        if startsAt.children.count > 0 {
            for child:ImageFolder in startsAt.children {
                sum += child.countOfImages
                sum += sumUpImagesFromChildren(child)
            }
        }
        return sum
        
    }
    
    func isParentOf(_ url:URL) -> Bool {
        let theOtherPath = "\(url.path)/"
        let myPath = "\(self.url.path)/"
        return theOtherPath.starts(with: myPath)
    }
    
    func isSiblingOf(_ other:URL) -> Bool {
        return url.deletingLastPathComponent().path == other.deletingLastPathComponent().path
    }
    
    func getNearestParent(from folders: [ImageFolder]) -> ImageFolder?{
        if folders.count == 0 { return nil }
        for folder:ImageFolder in folders.reversed() {
            if folder.isParentOf(url) {
                return folder
            }
        }
        return nil
    }
    
    func getPathExcludeParent() -> String {
        if parent == nil {return url.path}
        return String(url.path.dropFirst(parent!.url.path.count + 1))
    }
}
