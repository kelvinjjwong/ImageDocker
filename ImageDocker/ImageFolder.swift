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
    
    init(_ url:URL) {
        self.url = url
    }
    
    init(_ url:URL, countOfImages:Int){
        self.url = url
        self.countOfImages = countOfImages
    }
    
    func addChild(_ folder:ImageFolder) {
        children.append(folder)
    }
    
    func totalCountOfImages() -> Int {
        return self.countOfImages + sumUpImagesFromChildren(self)
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
        return url.path.starts(with: self.url.path)
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
