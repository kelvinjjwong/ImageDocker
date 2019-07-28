//
//  ImageFolderScanner.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/5.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class DirectoryPaths : NSObject {
    var filesysUrls:Set<String> = Set<String>()
    var fileUrlToRepo:[String:ImageContainer] = [:]
    var foldersysUrls:Set<String> = Set<String>()
}

class ImageFolderTreeScanner {
    
    static let `default` = ImageFolderTreeScanner()
    var suppressedScan:Bool = false
    
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
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_BEGIN"), object: nil)
        let containers = ModelStore.default.getAllContainers()
        
        print("\(Date()) Setting up containers' parent ")
        
        let limitRam = PreferencesController.peakMemory() * 1024
        var continousWorking = true
        var index = 0
        var attempt = 0
            
        var urlFolders:[String:ImageFolder] = [:]
        var foldersNeedSave:Set<ImageFolder> = []
        
        let jall = containers.count
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_TOTAL"), object: containers.count)
        if containers.count == 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_INCREMENT"), object: nil)
        }else{
            while(index < containers.count ){
            //for container in containers { // TODO: most high memory impact
                
                if limitRam > 0 {
                    var taskInfo = mach_task_basic_info()
                    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
                    let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
                        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                        }
                    }
                    
                    if kerr == KERN_SUCCESS {
                        let usedRam = taskInfo.resident_size / 1024 / 1024
                        
                        if usedRam >= limitRam {
                            attempt += 1
                            print("waiting for releasing memory for Setting up containers' parent, attempt: \(attempt)")
                            continousWorking = false
                            sleep(10)
                        }else{
                            print("continue for Setting up containers' parent, last attempt: \(attempt)")
                            continousWorking = true
                        }
                    }
                }
                
                if continousWorking {
                    autoreleasepool { () -> Void in
                        let container = containers[index]
                        if container.hideByParent {
                            // do nothing
                        }else{
                            print("Setting for container \(index)/\(jall) [\(container.path)]")
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
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_INCREMENT"), object: nil)
                        index += 1
                    } // end of autorelease
                    
                } // end of continuous working
            } // end of while loop
        }// end of if-containers-is-empty
        urlFolders.removeAll()
        print("\(Date()) Setting up containers' parent: DONE ")
        
        if foldersNeedSave.count > 0 {
            print("\(Date()) Saving containers' parent")
            var k = 0
            let kall = foldersNeedSave.count
            for imageFolder in foldersNeedSave {
                k += 1
                if let imageContainer = imageFolder.containerFolder {
                    print("Saving container into DB \(k)/\(kall): \(imageContainer.path)")
                    ModelStore.default.saveImageContainer(container: imageContainer)
                }
            }
            print("\(Date()) Saving containers' parent: DONE ")
        }
        foldersNeedSave.removeAll()
        
        return imageFolders
    }
    
    func scanPhotosToLoadExif(indicator:Accumulator? = nil)  {
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
    
    func createRepository(name:String,
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
    
    func walkthruDirectoryForPaths(repository:ImageContainer) -> DirectoryPaths{
        let result = DirectoryPaths()
        let startingURL = URL(fileURLWithPath: repository.path)
        let realPhysicalPath = startingURL.resolvingSymlinksInPath().path.withStash()
        let repositoryPath = repository.path.withStash()
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        let resourceValueKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.typeIdentifierKey, URLResourceKey.isDirectoryKey]
        guard let directoryEnumerator = FileManager.default.enumerator(at: startingURL,
                                                               includingPropertiesForKeys: resourceValueKeys,
                                                               options: options,
                                                               errorHandler: { url, error in
                                                                print("`directoryEnumerator` error: \(error).")
                                                                return true
        }
            ) else { return result}
        
        for case let url as NSURL in directoryEnumerator {
            do {
                let resourceValues = try url.resourceValues(forKeys: resourceValueKeys)
                guard let isRegularFileResourceValue = resourceValues[URLResourceKey.isRegularFileKey] as? NSNumber else { continue }
                guard isRegularFileResourceValue.boolValue else { continue }
                guard let fileType = resourceValues[URLResourceKey.typeIdentifierKey] as? String else { continue }
                guard (UTTypeConformsTo(fileType as CFString, kUTTypeImage) || UTTypeConformsTo(fileType as CFString, kUTTypeMovie)) else { continue }
                let url = url as URL
                
                // to support soft link
                let path = url.path.replacingFirstOccurrence(of: realPhysicalPath, with: repositoryPath)
                let transformedURL = URL(fileURLWithPath: path)
                print("Getting entry: \(path)")
                
                result.filesysUrls.insert(path)
                result.fileUrlToRepo[path] = repository
                let folderUrl = transformedURL.deletingLastPathComponent()
                result.foldersysUrls.insert(folderUrl.path)
            }
            catch {
                print("Unexpected error occured: \(error).")
            }
        }
        return result
    }
    
    func scanRepositories(indicator:Accumulator? = nil)  {
        
        if suppressedScan {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return
        }
        
        if indicator != nil {
            indicator?.display(message: "Loading repositories from database .....")
        }
        
        let repositories = ModelStore.default.getRepositories()
        print("REPO COUNT = \(repositories.count)")
        
        if indicator != nil {
            indicator?.display(message: "Scanning \(repositories.count) repositories .....")
        }
        
        var filesysUrls:Set<String> = Set<String>()
        var fileUrlToRepo:[String:ImageContainer] = [:]
        let totalCount = repositories.count
        var i = 0
        for repo in repositories {
            var foldersysUrls:Set<String> = Set<String>()
            let repositoryPath = repo.path.withStash()
            
            
            i += 1
            
            if suppressedScan {
                if indicator != nil {
                    indicator?.forceComplete()
                }
                return
            }
            
            if indicator != nil {
                indicator?.display(message: "Scanning repository \(i)/\(totalCount) .....")
            }
            
            
            var containers = ModelStore.default.getAllContainerPaths(repositoryPath: repositoryPath).sorted()
            
//            var pathToDeviceSubFolder:[String:String] = [:]
            if repo.deviceId != "" {
                let devicePaths = ModelStore.default.getDevicePaths(deviceId: repo.deviceId)
                if devicePaths.count > 0 {
                    for devicePath in devicePaths {
                        if !devicePath.exclude && !devicePath.excludeImported {
                            let path = URL(fileURLWithPath: repo.path).appendingPathComponent(devicePath.toSubFolder).path
//                            pathToDeviceSubFolder[path] = devicePath.toSubFolder
                            
                            let folder = ImageFolder(URL(fileURLWithPath: path),
                                                          name: devicePath.toSubFolder,
                                                          repositoryPath: repositoryPath,
                                                          homePath: "",
                                                          storagePath: "",
                                                          facePath: "",
                                                          cropPath: "",
                                                          countOfImages: 0,
                                                          manyChildren: devicePath.manyChildren,
                                                          sharedDB: ModelStore.sharedDBPool())
                            
                            if let container = folder.containerFolder, container.parentFolder == "" {
                                ModelStore.default.updateImageContainerParentFolder(path: path, parentFolder: repo.path)
                            }
                            if !containers.contains(path) {
                                containers.append(path)
                            }
                        }
                    }
                }
            }
            
            print("\(Date()) CHECKING REPO \(repo.path)")
            
            print("\(Date()) CHECK REPO: ENUMERATING FILESYS")
            
            autoreleasepool { () -> Void in
                print(">>> WALKING THRU DIRECTORY begin \(i)/\(totalCount) <<<")
                if indicator != nil {
                    indicator?.display(message: "Walking thru directory \(i)/\(totalCount) .....")
                }
                let directoryPaths = self.walkthruDirectoryForPaths(repository: repo)
                for filesysUrl in directoryPaths.filesysUrls {
                    filesysUrls.insert(filesysUrl)
                }
                for key in directoryPaths.fileUrlToRepo.keys {
                    fileUrlToRepo[key] = directoryPaths.fileUrlToRepo[key]
                }
                for folderUrl in directoryPaths.foldersysUrls {
                    foldersysUrls.insert(folderUrl)
                }
                print(">>> WALKING THRU DIRECTORY done \(i)/\(totalCount)  <<<")
            }
            
            print("\(Date()) CHECK REPO: ENUMERATING FILESYS: DONE")
            
            print("\(Date()) CHECK REPO: CHECK FOLDERS TO BE ADDED AND REMOVED")
            
            autoreleasepool { () -> Void in
                
                let folderDBUrls = ModelStore.default.getAllContainerPaths(repositoryPath: repositoryPath)
                let folderUrlsToAdd:[String] = foldersysUrls.subtracting(folderDBUrls).sorted()
                let folderUrlsToRemoved:Set<String> = folderDBUrls.subtracting(foldersysUrls)
                
                if folderUrlsToAdd.count > 0 {
                    var k = 0
                    let kall = folderUrlsToAdd.count
                    for path in folderUrlsToAdd {
                        k += 1
                        let url = URL(fileURLWithPath: path)
                        print("Adding container folder \(k)/\(kall): \(path)")
                        if indicator != nil {
                            indicator?.display(message: "Adding container folder \(k)/\(kall) .....")
                        }
                        let name = url.lastPathComponent
                        let _ = ImageFolder(url,
                                            name: name,
                                            repositoryPath: repositoryPath,
                                            homePath: "",
                                            storagePath: "",
                                            facePath: "",
                                            cropPath: "")
                        
                        if !containers.contains(path) {
                            containers.append(path)
                        }
                    }
                    
                    containers = containers.sorted().reversed() // put the shortest root to bottom, make it hardest to be found
                    var j = 0
                    for path in folderUrlsToAdd {
                        j += 1
                        print("Getting parent folder \(j)/\(kall): \(path)")
                        if indicator != nil {
                            indicator?.display(message: "Getting parent folder \(j)/\(kall) .....")
                        }
                        if let parentFolder = path.getNearestParent(from: containers) {
                            print(">>> parent folder: \(parentFolder)")
                            ModelStore.default.updateImageContainerParentFolder(path: path, parentFolder: parentFolder)
                            
                            if let parent = ModelStore.default.getContainer(path: parentFolder), parent.manyChildren == true {
                                ModelStore.default.updateImageContainerHideByParent(path: path, hideByParent: true)
                            }
                        }
                        
                    }
                    
//                    if indicator != nil {
//                        indicator?.dataChanged()
//                    }
                }
                
                if folderUrlsToRemoved.count > 0 {
                    for path in folderUrlsToRemoved {
                        //let url = URL(fileURLWithPath: path)
                        // TODO: REMOVE CONTAINER FROM DB
                        print("Should be REMOVE container folder: \(path)")
                    }
                    
//                    if indicator != nil {
//                        indicator?.dataChanged()
//                    }
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
//            indicator?.dataChanged()
            
            let limitRam = PreferencesController.peakMemory() * 1024
            var continousWorking = true
            var index = 0
            var attempt = 0
            
            while(index < urlsToAdd.count ){
            //for url in urlsToAdd { // TODO: most high memory impact
                
                if suppressedScan {
                    if indicator != nil {
                        indicator?.forceComplete()
                    }
                    return
                }
                
                if limitRam > 0 {
                    var taskInfo = mach_task_basic_info()
                    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
                    let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
                        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
                        }
                    }
                    
                    if kerr == KERN_SUCCESS {
                        let usedRam = taskInfo.resident_size / 1024 / 1024
                        
                        if usedRam >= limitRam {
                            continousWorking = false
                            attempt += 1
                            print(">>> waiting for releasing memory for URLS TO ADD FROM FILESYS, attempt:\(attempt)")
                            sleep(10)
                        }else{
                            print(">>> continue for URLS TO ADD FROM FILESYS, last attempt:\(attempt)")
                            continousWorking = true
                        }
                    }
                }
                if continousWorking {
                    autoreleasepool { () -> Void in
                        let url = urlsToAdd[index]
                        self.createImageIfAbsent(url: url, fileUrlToRepo: fileUrlToRepo, indicator: indicator)
                        index += 1
                    }
                }
                
            }
//            if indicator != nil {
//                indicator?.dataChanged()
//            }
            print("\(Date()) URLS TO ADD FROM FILESYS: SAVE DONE")
        }
        
        if urlsToRemoved.count > 0 {
            print("\(Date()) PHOTOS TO REMOVED FROM DB: \(urlsToRemoved.count)")
//            indicator?.dataChanged()
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
            
//            if indicator != nil {
//                indicator?.dataChanged()
//            }
            //DispatchQueue.main.async {
                //ModelStore.save()
            //}
            print("\(Date()) PHOTOS TO REMOVED FROM DB: SAVE DONE")
        }
        
        print("\(Date()) CHECK REPO: EXECUTE ADD OR REMOVE: DONE")
        
        print("\(Date()) TRIGGER ON DATA CHANGED EVENT AFTER FINISHED SCANNING REPOSITORIES")
        if indicator != nil {
            indicator?.dataChanged()
        }
    }
    
    func createImageIfAbsent(url:String, fileUrlToRepo:[String:ImageContainer], indicator:Accumulator? = nil) {
        //print("CREATING PHOTO \(url.path)")
        if let repo = fileUrlToRepo[url]{
            print(">>> Creating image \(url), repo: \(repo.repositoryPath)")
            let image = ImageFile(url: URL(fileURLWithPath: url),
                                  repository: repo,
                                  indicator: indicator,
                                  quickCreate: true,
                                  sharedDB: ModelStore.sharedDBPool())
            
            image.save()
        }
    }
    
    func updateContainers(onCompleted: (() -> Void)? = nil ) {
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
