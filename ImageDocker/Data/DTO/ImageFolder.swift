//
//  ImageFolder.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/3.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class ImageFolder : NSObject {
    
    var url:URL
    var countOfImages:Int = 0
    var children:[ImageFolder] = []
    var sumOfImages:Int = 0
    var parent:ImageFolder? = nil
    var containerFolder:ImageContainer? = nil
    var name:String = ""
    
    override init(){
        self.url = URL(fileURLWithPath: "/")
        super.init()
    }
    
    /// Create a dummy ImageFolder certainly without container data
    convenience init(_ url:URL, name:String) {
        self.init()
        self.url = url
        self.name = name
    }
    
    /// Create a normal ImageFolder from container data
    /// - Tag:  ImageFolder.init(url)
    convenience init(_ url:URL,
         name:String,
         repositoryPath:String,
         homePath:String,
         storagePath:String,
         facePath:String,
         cropPath:String,
         countOfImages:Int = 0,
         manyChildren:Bool = false,
         withContainer:Bool = true,
         sharedDB:DatabaseWriter? = nil){
        
        self.init()
        
        self.url = url
        self.countOfImages = countOfImages
        
        let path:String = url.path
        var folderName:String = name
        if folderName == "" {
            folderName = url.lastPathComponent
        }
        self.name = folderName
        
        var repoPath = repositoryPath
        if !repoPath.hasSuffix("/") {
            repoPath = "\(repoPath)/"
        }
        let subPath = url.path.replacingFirstOccurrence(of: repoPath, with: "")
        //self.logger.log("LOAD FOLDER 2 \(name) \(path)")
        if withContainer {
            self.containerFolder = RepositoryDao.default.getOrCreateContainer(name: folderName,
                                                                       path: path,
                                                                       repositoryPath: repositoryPath,
                                                                       homePath: homePath,
                                                                       storagePath: storagePath,
                                                                       facePath: facePath,
                                                                       cropPath: cropPath,
                                                                       subPath: subPath,
                                                                       manyChildren: manyChildren)
        }
        //self.logger.log("Got or Created container: \(path)")
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
        if parent == nil {
            if url.lastPathComponent != "repository" {
                return "\(url.lastPathComponent) [\(url.path)]"
            }else{
                return "\(url.pathComponents.reversed()[1]) [\(url.path)]"
            }
            
        }
        return String(url.path.dropFirst(parent!.url.path.count + 1))
    }
}
