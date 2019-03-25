//
//  ImageFolderScanner.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/5.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class ImageFolderTreeScanner {
    
    static let `default` = ImageFolderTreeScanner()
    static var suppressedScan:Bool = false
    
    func walkthruDirectory(at folder:URL, resourceKeys: [URLResourceKey] = []) -> FileManager.DirectoryEnumerator{
        let enumerator = FileManager.default.enumerator(at: folder,
                                                        includingPropertiesForKeys: resourceKeys,
                                                        options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                            print("directoryEnumerator error at \(url): ", error)
                                                            return true
        })!
        return enumerator
    }
    
    func isImageFile(_ file: URL) -> Bool {
        if file.pathExtension == "jpg" || file.pathExtension == "JPG"
            || file.pathExtension == "jpeg" || file.pathExtension == "JPEG"
            || file.pathExtension == "mp4" || file.pathExtension == "MP4"
            || file.pathExtension == "MOV" || file.pathExtension == "MOV"
            || file.pathExtension == "mpg" || file.pathExtension == "MPG" {
            return true
        }
        return false
    }
    
    func countImagesInFolder(_ folder: URL) -> Int {
        var count:Int = 0
        let enumeratorFiles = self.walkthruDirectory(at: folder)
        for case let file as URL in enumeratorFiles {
            if isImageFile(file) {
                count += 1
            }
        }
        return count
    }
    
    func scanImageFolderFromDatabase(fast:Bool = true) -> [ImageFolder] {
        var imageFolders:[ImageFolder] = [ImageFolder]()
        
        print("\(Date()) Loading containers from db ")
        let containers = ModelStore.default.getAllContainers()
        
        print("\(Date()) Setting up containers' parent ")
        var urlFolders:[String:ImageFolder] = [:]
        var foldersNeedSave:Set<ImageFolder> = []
        for container in containers {
            let imageFolder:ImageFolder = ImageFolder(URL(fileURLWithPath: container.path),
                                                      name:container.name,
                                                      repositoryPath: container.repositoryPath,
                                                      homePath: container.homePath,
                                                      storagePath: container.storagePath,
                                                      facePath: container.facePath,
                                                      cropPath: container.cropPath,
                                                      countOfImages: Int(container.imageCount),
                                                      updateModelStore: false,
                                                      sharedDB: ModelStore.sharedDBPool())
            urlFolders[container.path] = imageFolder
            if fast { // fast
                if container.parentFolder != "" {
                    if let parentFolder = urlFolders[container.parentFolder] {
                        imageFolder.setParent(parentFolder)
                    }
                }else{
                    if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
                        imageFolder.setParent(parent)
                        foldersNeedSave.insert(imageFolder)
                    }
                }
                
            }else{
                if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
                    imageFolder.setParent(parent)
                    foldersNeedSave.insert(imageFolder)
                }
            }
            imageFolders.append(imageFolder)
        }
        print("\(Date()) Setting up containers' parent: DONE ")
        
        if foldersNeedSave.count > 0 {
            print("\(Date()) Saving containers' parent")
            for imageFolder in foldersNeedSave {
                if let imageContainer = imageFolder.containerFolder {
                    ModelStore.default.saveImageContainer(container: imageContainer)
                }
            }
            print("\(Date()) Saving containers' parent: DONE ")
        }
        
        return imageFolders
    }
    
//    func scanImageFolder(name:String, path: String, smallSizePath:String) -> [ImageFolder] {
//        let url:URL = URL(string: path)!
//        return scanImageFolder(name: name, startingURL: url, smallSizePath: smallSizePath)
//    }
//
//    func scanImageFolder(name:String, startingURL: URL, smallSizePath:String) -> [ImageFolder] {
//        var imageFolders:[ImageFolder] = [ImageFolder]()
//
//        let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey, .isHiddenKey, .parentDirectoryURLKey, .isReadableKey]
//
//        let countOfRootImage:Int = self.countImagesInFolder(startingURL)
//        imageFolders.append(ImageFolder(startingURL,
//                                        name: name,
//                                        repositoryPath: startingURL.path,
//                                        homePath: "",
//                                        storagePath: "",
//                                        facePath: "",
//                                        cropPath: "",
//                                        countOfImages: countOfRootImage))
//
//        let enumerator = self.walkthruDirectory(at: startingURL, resourceKeys: resourceKeys)
//        for case let folderURL as URL in enumerator {
//            do {
//                let resourceValues = try folderURL.resourceValues(forKeys: Set(resourceKeys))
//                if resourceValues.isDirectory! && !resourceValues.isHidden! && resourceValues.isReadable! {
//                    let countOfImage:Int = self.countImagesInFolder(folderURL)
//                    if countOfImage > 0 {
//                        let imageFolder:ImageFolder = ImageFolder(folderURL,
//                                                                  name: "",
//                                                                  repositoryPath: startingURL.path,
//                                                                  homePath: "",
//                                                                  storagePath: "",
//                                                                  facePath: "",
//                                                                  cropPath: "",
//                                                                  countOfImages: countOfImage)
//                        if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) {
//                            imageFolder.setParent(parent)
//                        }
//                        imageFolders.append(imageFolder)
//                    }
//                }
//            } catch {
//                print(error)
//            }
//        }
//        //ModelStore.save()
//        return imageFolders
//    }
    
    static func scanPhotosToLoadExif(indicator:Accumulator? = nil)  {
        if suppressedScan {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return
        }
        
        let photos = ModelStore.default.getPhotoFilesWithoutExif()
        print("PHOTOS WITHOUT EXIF: \(photos.count)")
        if photos.count > 0 {
            print("\(Date()) UPDATING EXIF: \(photos.count)")
            if indicator != nil {
                indicator?.setTarget(photos.count)
            }
            for photo in photos {
                
                if suppressedScan {
                    if indicator != nil {
                        indicator?.forceComplete()
                    }
                    return
                }
                let _ = ImageFile(photoFile: photo, indicator: indicator, sharedDB: ModelStore.sharedDBPool())
            }
            //ModelStore.save()
            print("\(Date()) UPDATING EXIF: SAVE DONE")
        }else {
            if indicator != nil {
                indicator?.forceComplete()
            }
        }
    }
    
    static func createRepository(name:String,
                                 path:String,
                                 homePath:String,
                                 storagePath:String,
                                 facePath:String,
                                 cropPath:String) {
        let _ = ImageFolder(URL(fileURLWithPath: path),
                            name: name,
                            repositoryPath: path,
                            homePath: homePath,
                            storagePath: storagePath,
                            facePath: facePath,
                            cropPath: cropPath)
    }
    
    static func scanRepositories(indicator:Accumulator? = nil)  {
        
        if suppressedScan {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return
        }
        
        let repositories = ModelStore.default.getRepositories()
        print("REPO COUNT = \(repositories.count)")
        var filesysUrls:Set<String> = Set<String>()
        var fileUrlToRepo:[String:ImageContainer] = [:]
        for repo in repositories {
            var foldersysUrls:Set<String> = Set<String>()
            
            if suppressedScan {
                if indicator != nil {
                    indicator?.forceComplete()
                }
                return
            }
            
            print("\(Date()) CHECKING REPO \(repo.path)")
            let startingURL = URL(fileURLWithPath: repo.path)
            
            let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
            let fileManager = FileManager.default
            let resourceValueKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.typeIdentifierKey, URLResourceKey.isDirectoryKey]
            
            print("\(Date()) CHECK REPO: ENUMERATING FILESYS")
            guard let directoryEnumerator = fileManager.enumerator(at: startingURL as URL,
                                                                   includingPropertiesForKeys: resourceValueKeys,
                                                                   options: options,
                                                                   errorHandler: { url, error in
                                                                    print("`directoryEnumerator` error: \(error).")
                                                                    return true
                                                                    }
            ) else { return }
            
            for case let url as NSURL in directoryEnumerator {
                do {
                    let resourceValues = try url.resourceValues(forKeys: resourceValueKeys)
                    guard let isRegularFileResourceValue = resourceValues[URLResourceKey.isRegularFileKey] as? NSNumber else { continue }
                    guard isRegularFileResourceValue.boolValue else { continue }
                    guard let fileType = resourceValues[URLResourceKey.typeIdentifierKey] as? String else { continue }
                    guard (UTTypeConformsTo(fileType as CFString, kUTTypeImage) || UTTypeConformsTo(fileType as CFString, kUTTypeMovie)) else { continue }
                    let url = url as URL
                    filesysUrls.insert(url.path)
                    fileUrlToRepo[url.path] = repo
                    let folderUrl = url.deletingLastPathComponent()
                    foldersysUrls.insert(folderUrl.path)
                }
                catch {
                    print("Unexpected error occured: \(error).")
                }
            }
            print("\(Date()) CHECK REPO: ENUMERATING FILESYS: DONE")
            
            print("\(Date()) CHECK REPO: CHECK FOLDERS TO BE ADDED AND REMOVED")
            
            let folderDBUrls = ModelStore.default.getAllContainerPaths(rootPath: repo.path)
            let folderUrlsToAdd:[String] = foldersysUrls.subtracting(folderDBUrls).sorted()
            let folderUrlsToRemoved:Set<String> = folderDBUrls.subtracting(foldersysUrls)
            
            if folderUrlsToAdd.count > 0 {
                for path in folderUrlsToAdd {
                    let url = URL(fileURLWithPath: path)
                    print("Adding container folder: \(path)")
                    let name = url.lastPathComponent
                    let _ = ImageFolder(url,
                                        name: name,
                                        repositoryPath: repo.path,
                                        homePath: "",
                                        storagePath: "",
                                        facePath: "",
                                        cropPath: "")
                }
                
                if indicator != nil {
                    indicator?.dataChanged()
                }
            }
            
            if folderUrlsToRemoved.count > 0 {
                for path in folderUrlsToRemoved {
                    //let url = URL(fileURLWithPath: path)
                    // TODO: REMOVE CONTAINER FROM DB
                    print("Should be REMOVE container folder: \(path)")
                }
                
                if indicator != nil {
                    indicator?.dataChanged()
                }
            }
        }
        
        print("\(Date()) CHECK REPO: CHECK TO BE ADDED AND REMOVED")
        if indicator != nil {
            indicator?.display(message: "Checking differences .....")
        }
        
        let dbUrls = ModelStore.default.getAllPhotoPaths(sharedDB: ModelStore.sharedDBPool())
        print("EXISTING DB PHOTO COUNT = \(dbUrls.count)")
        print("EXISTING SYS PHOTO COUNT = \(filesysUrls.count)")
//        var dbUrls:Set<String> = Set<String>()
//        for exist in exists {
//            let path = exist.path
//            dbUrls.insert(path)
//
//        }
        print("EXISTING DB PHOTO COUNT2 = \(dbUrls.count)")
        
        let urlsToAdd:[String] = filesysUrls.subtracting(dbUrls).sorted()
        let urlsToRemoved:Set<String> = dbUrls.subtracting(filesysUrls)
        
        if indicator != nil {
            indicator?.display(message: "")
        }
        
        print("\(Date()) CHECK REPO: CHECK TO BE ADDED AND REMOVED : DONE")
        
        let total = urlsToAdd.count + urlsToRemoved.count
        
        if total == 0 {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return
        }
        
        if indicator != nil {
            indicator?.setTarget(total)
        }
        
        print("\(Date()) CHECK REPO: EXECUTE ADD OR REMOVE")
        
        if urlsToAdd.count > 0 {
            print("\(Date()) URLS TO ADD FROM FILESYS: \(urlsToAdd.count)")
            indicator?.dataChanged()
            for url in urlsToAdd {
                
                if suppressedScan {
                    if indicator != nil {
                        indicator?.forceComplete()
                    }
                    return
                }
                
                //print("CREATING PHOTO \(url.path)")
                if let repo = fileUrlToRepo[url]{
                    let image = ImageFile(url: URL(fileURLWithPath: url),
                                          repository: repo,
                                          indicator: indicator,
                                          quickCreate: true,
                                          sharedDB: ModelStore.sharedDBPool())
                    
                    image.save()
                }
                
            }
            if indicator != nil {
                indicator?.dataChanged()
            }
            print("\(Date()) URLS TO ADD FROM FILESYS: SAVE DONE")
        }
        
        if urlsToRemoved.count > 0 {
            print("\(Date()) PHOTOS TO REMOVED FROM DB: \(urlsToRemoved.count)")
            indicator?.dataChanged()
            for url in urlsToRemoved {
                
                if suppressedScan {
                    if indicator != nil {
                        indicator?.forceComplete()
                    }
                    return
                }
                
                ModelStore.default.deletePhoto(atPath: url)
                
                if indicator != nil {
                    let _ = indicator?.add()
                }
            }
            
            if indicator != nil {
                indicator?.dataChanged()
            }
            //DispatchQueue.main.async {
                //ModelStore.save()
            //}
            print("\(Date()) PHOTOS TO REMOVED FROM DB: SAVE DONE")
        }
        print("\(Date()) CHECK REPO: EXECUTE ADD OR REMOVE: DONE")
    }
    
    static func updateContainers(onCompleted: (() -> Void)? = nil ) {
        var imageFolders:[ImageFolder] = []
        let exists = ModelStore.default.getAllContainers()
        if exists.count > 0 {
            for exist in exists{
                let imageFolder = ImageFolder(URL(fileURLWithPath: exist.path),
                                              name: exist.name,
                                              repositoryPath: exist.repositoryPath,
                                              homePath: exist.homePath,
                                              storagePath: exist.storagePath,
                                              facePath: exist.facePath,
                                              cropPath: exist.cropPath,
                                              countOfImages: Int(exist.imageCount),
                                              sharedDB: ModelStore.sharedDBPool())
                imageFolders.append(imageFolder)
                
                let count = ModelStore.default.countPhotoFiles(rootPath: "\(imageFolder.url.path)/")
                if var container = imageFolder.containerFolder {
                    if container.imageCount != count {
                        print("= changing \(container.imageCount) to \(count)")  // don't delete this comment to avoid crash
                        container.imageCount = count
                        ModelStore.default.saveImageContainer(container: container)
                    }
                }
            }
            //ModelStore.save()
        }
//        let containers:[Row] = ModelStore.default.getAllContainerPaths()
//        if containers.count > 0 {
//            for cont in containers {
//                let path:String = cont["containerPath"] as! String
//                let photoCount:Int = cont["photoCount"] as Int
//
//                let url:URL = URL(fileURLWithPath: path)
//                let imageFolder = ImageFolder(url, name: exist.name, repositoryPath: exist.repositoryPath, smallSizePath: exist.smallSizePath, countOfImages: photoCount, sharedDB: ModelStore.sharedDBPool())
//                imageFolders.append(imageFolder)
//                /--
//                let photos = ModelStore.getPhotoFiles(rootPath: "\(imageFolder.url.path)/")
//                let count = Int32(photos.count)
//                if let container = imageFolder.containerFolder {
//                    if imageFolder.containerFolder?.imageCount != count {
//                        container.imageCount = count
//                    }
//                }
//                --/
//            }
//            //ModelStore.save()
//        }
        if onCompleted != nil {
            onCompleted!()
        }
    }
}
