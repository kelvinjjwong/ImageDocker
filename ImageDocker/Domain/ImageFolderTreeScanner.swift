//
//  ImageFolderScanner.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/5.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

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
    
    func scanImageFolderFromDatabase() -> [ImageFolder] {
        var imageFolders:[ImageFolder] = [ImageFolder]()
        
        let containers = ModelStore.getAllContainers()
        for container in containers {
            let imageFolder:ImageFolder = ImageFolder(URL(fileURLWithPath: container.path!), countOfImages: Int(container.imageCount), updateModelStore: false)
            if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) {
                imageFolder.setParent(parent)
            }
            imageFolders.append(imageFolder)
        }
        return imageFolders
    }
    
    func scanImageFolder(path: String) -> [ImageFolder] {
        let url:URL = URL(string: path)!
        return scanImageFolder(startingURL: url)
    }
    
    func scanImageFolder(startingURL: URL) -> [ImageFolder] {
        var imageFolders:[ImageFolder] = [ImageFolder]()
        
        let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey, .isHiddenKey, .parentDirectoryURLKey, .isReadableKey]
        
        let countOfRootImage:Int = self.countImagesInFolder(startingURL)
        imageFolders.append(ImageFolder(startingURL, countOfImages: countOfRootImage))
        
        let enumerator = self.walkthruDirectory(at: startingURL, resourceKeys: resourceKeys)
        for case let folderURL as URL in enumerator {
            do {
                let resourceValues = try folderURL.resourceValues(forKeys: Set(resourceKeys))
                if resourceValues.isDirectory! && !resourceValues.isHidden! && resourceValues.isReadable! {
                    let countOfImage:Int = self.countImagesInFolder(folderURL)
                    if countOfImage > 0 {
                        let imageFolder:ImageFolder = ImageFolder(folderURL, countOfImages: countOfImage)
                        if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) {
                            imageFolder.setParent(parent)
                        }
                        imageFolders.append(imageFolder)
                    }
                }
            } catch {
                print(error)
            }
        }
        ModelStore.save()
        return imageFolders
    }
    
    static func scanPhotosToLoadExif(indicator:Accumulator? = nil)  {
        if suppressedScan {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return
        }
        
        let photos = ModelStore.getPhotoFilesWithoutExif()
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
                
                let url = URL(fileURLWithPath: photo.path!)
                let _ = ImageFile(url: url, indicator: indicator)
            }
            //ModelStore.save()
            print("\(Date()) UPDATING EXIF: SAVE DONE")
        }else {
            if indicator != nil {
                indicator?.forceComplete()
            }
        }
    }
    
    static func createRepository(path:String) {
        let _ = ImageFolder(URL(fileURLWithPath: path))
        ModelStore.save()
    }
    
    static func scanRepositories(indicator:Accumulator? = nil)  {
        
        if suppressedScan {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return
        }
        
        let repositories = ModelStore.getRepositories()
        
        var filesysUrls:Set<String> = Set<String>()
        for repo in repositories {
            
            if suppressedScan {
                if indicator != nil {
                    indicator?.forceComplete()
                }
                return
            }
            
            print("\(Date()) CHECKING REPO \(repo.path ?? "")")
            let startingURL = URL(fileURLWithPath: repo.path!)
            
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
                }
                catch {
                    print("Unexpected error occured: \(error).")
                }
            }
            print("\(Date()) CHECK REPO: ENUMERATING FILESYS: DONE")
        }
        
        print("\(Date()) CHECK REPO: CHECK TO BE ADDED AND REMOVED")
        if indicator != nil {
            indicator?.display(message: "Checking differences .....")
        }
        let exists = ModelStore.getAllPhotoFiles()
        var dbUrls:Set<String> = Set<String>()
        for exist in exists {
            if let path = exist.path {
                dbUrls.insert(path)
            }
        }
        
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
                let _ = ImageFile(url: URL(fileURLWithPath: url), indicator: indicator, quickCreate: true)
                
                ModelStore.save()
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
                
                ModelStore.deletePhoto(atPath: url)
                
                if indicator != nil {
                    let _ = indicator?.add()
                }
            }
            
            //DispatchQueue.main.async {
                ModelStore.save()
            //}
            print("\(Date()) PHOTOS TO REMOVED FROM DB: SAVE DONE")
        }
        print("\(Date()) CHECK REPO: EXECUTE ADD OR REMOVE: DONE")
    }
    
    static func updateContainers(onCompleted: (() -> Void)? = nil ) {
        var imageFolders:[ImageFolder] = []
        let exists = ModelStore.getAllContainers()
        if exists.count > 0 {
            for exist in exists{
                let imageFolder = ImageFolder(URL(fileURLWithPath: exist.path!), countOfImages: Int(exist.imageCount) )
                imageFolders.append(imageFolder)
                
                let photos = ModelStore.getPhotoFiles(rootPath: "\(imageFolder.url.path)/")
                let count = Int32(photos.count)
                if imageFolder.containerFolder != nil && imageFolder.containerFolder?.imageCount != count {
                    imageFolder.containerFolder?.imageCount = count
                }
            }
        }
        let containers:[[String:AnyObject]]? = ModelStore.getAllContainerPaths()
        if containers != nil && containers!.count > 0 {
            for cont in containers! {
                let path:String = cont["containerPath"] as! String
                let photoCount:Int = cont["photoCount"] as! Int
                
                let url:URL = URL(fileURLWithPath: path)
                let imageFolder = ImageFolder(url, countOfImages: photoCount)
                imageFolders.append(imageFolder)
                
                let photos = ModelStore.getPhotoFiles(rootPath: "\(imageFolder.url.path)/")
                let count = Int32(photos.count)
                if imageFolder.containerFolder != nil && imageFolder.containerFolder?.imageCount != count {
                    imageFolder.containerFolder?.imageCount = count
                }
            }
            ModelStore.save()
        }
        if onCompleted != nil {
            onCompleted!()
        }
    }
}
