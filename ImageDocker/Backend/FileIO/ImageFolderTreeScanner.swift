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
    
    let logger = ConsoleLogger(category: "ImageFolderTreeScanner")
    
    static let `default` = ImageFolderTreeScanner()
    var suppressedScan:Bool = false
    
    func walkthruDirectory(at folder:URL, resourceKeys: [URLResourceKey] = []) -> FileManager.DirectoryEnumerator{
        let enumerator = FileManager.default.enumerator(at: folder,
                                                        includingPropertiesForKeys: resourceKeys,
                                                        options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                            self.logger.log("directoryEnumerator error at \(url): ", error)
                                                            return true
        })!
        return enumerator
    }
    
    func isImageFile(_ file: URL) -> Bool {
        if Naming.FileType.recognize(from: file) != .other {
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
    
    // deprecated?
    func scanImageFolderFromDatabase(fast:Bool = true) -> [ImageFolder] {
        let excludedContainerPaths = DeviceDao.default.getExcludedImportedContainerPaths()
        
        var imageFolders:[ImageFolder] = [ImageFolder]()
        
        self.logger.log("Loading containers from db ")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_BEGIN"), object: nil)
        let containers = RepositoryDao.default.getAllContainers()
        
        self.logger.log("Setting up containers' parent ")
        
//        let limitRam = PreferencesController.peakMemory() * 1024
//        var continousWorking = true
//        var index = 0
//        var attempt = 0
            
        var urlFolders:[String:ImageFolder] = [:]
        var foldersNeedSave:Set<ImageFolder> = []
        
        let jall = containers.count
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_TOTAL"), object: containers.count)
        if containers.count == 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_INCREMENT"), object: nil)
        }else{
            
            var index = 0
            MemoryReleasable.default.run(
                when: {return index < containers.count},
                shouldStop: {return false},
                do: {
                    let container = containers[index]
                    
                    var containerExistInFileSys = false
                    var isDir:ObjCBool = false
                    if FileManager.default.fileExists(atPath: container.path, isDirectory: &isDir) {
                        if isDir.boolValue == true {
                            containerExistInFileSys = true
                        }
                    }
                    if !containerExistInFileSys {
                        self.logger.log("Container does not exist in FileSys, ignore processing: \(index)/\(jall): \(container.path)")

                    }else{
                    
                        var exclude = false
                        if excludedContainerPaths.contains(container.path) {
                            exclude = true
                        }else{
                            for excludedPath in excludedContainerPaths {
                                if container.path.hasPrefix(excludedPath.withStash()) {
                                    exclude = true
                                    break
                                }
                            }
                        }
                    
                        if container.hideByParent || exclude {
                            // do nothing
                        }else{
//                                self.logger.log("[Container DB Scan] Setting parent for container \(index)/\(jall) [\(container.path)]")
                            let imageFolder:ImageFolder = ImageFolder(URL(fileURLWithPath: container.path),
                                                                      name:container.name,
                                                                      repositoryPath: container.repositoryPath,
                                                                      homePath: container.homePath,
                                                                      storagePath: container.storagePath,
                                                                      facePath: container.facePath,
                                                                      cropPath: container.cropPath,
                                                                      countOfImages: Int(container.imageCount),
                                                                      withContainer: true)
                            urlFolders[container.path] = imageFolder
                            if fast { // fast
                                if container.hasParentContainer() {
                                    if let parentFolder = urlFolders[container.parentFolder] {
                                        imageFolder.setParent(parentFolder)
//                                            self.logger.log("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "") << FROM CACHE")
                                    }
                                }else{
                                    if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
                                        imageFolder.setParent(parent)
//                                            self.logger.log("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
                                        foldersNeedSave.insert(imageFolder)
                                    }
                                }
                                
                            }else{
                                if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
                                    imageFolder.setParent(parent)
//                                        self.logger.log("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
                                    foldersNeedSave.insert(imageFolder)
                                }
                            }
                            if let parent = imageFolder.parent {
                                let subPath = container.path.replacingFirstOccurrence(of: parent.url.path.withStash(), with: "")
                                imageFolder.name = subPath
                                
//                                    self.logger.log("SUB PATH -> \(subPath)")
                                
                                if subPath.contains("/") {
                                    let parts = subPath.components(separatedBy: "/")
                                    var midPaths:[String] = []
                                    for part in parts {
                                        if part == "" {continue}
                                        if midPaths.count == 0 {
                                            let midPath = parent.url.appendingPathComponent(part).path
//                                                self.logger.log("MID FOLDER EXTRACTED FROM SUB PATH: \(midPath)")
                                            midPaths.append(midPath)
                                        }else{
                                            let parentMidPath = midPaths[midPaths.count-1]
                                            let midPath = URL(fileURLWithPath: parentMidPath).appendingPathComponent(part).path
//                                                self.logger.log("MID FOLDER EXTRACTED FROM SUB PATH: \(midPath)")
                                            midPaths.append(midPath)
                                        }
                                    }
                                    var parents:[ImageFolder] = [parent]
                                    var midFolders:[ImageFolder] = []
                                    for midPath in midPaths {
                                        if midPath.withStash() == container.path.withStash() {
                                            continue
                                        }
                                        // create imagefolder without container data
                                        let midUrl = URL(fileURLWithPath: midPath)
                                        
                                        // get middle dummy ImageFolder from cache if it exists
                                        var midFolder = urlFolders[midPath]
                                        if midFolder == nil {
                                            // create dummy ImageFolder in the middle
                                            midFolder = ImageFolder(midUrl, name: midUrl.lastPathComponent)
                                            midFolder!.setParent(parents[parents.count - 1])
//                                                self.logger.log("SET PARENT FOR \(midFolder!.url.path) -> PARENT SET TO \(midFolder!.parent?.url.path ?? "") << CREATED DUMMY")
                                            
                                            // to be added to the whole set
                                            midFolders.append(midFolder!)
                                            
                                            // cache mapping
                                            urlFolders[midPath] = midFolder!
                                        }
                                        parents.append(midFolder!) // for next calculation
                                    }
                                    imageFolder.setParent(parents[parents.count - 1])
//                                        self.logger.log("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
                                    imageFolder.name = URL(fileURLWithPath: container.path).lastPathComponent
                                    
                                    imageFolders.append(contentsOf: midFolders)
                                }
                            }
                            imageFolders.append(imageFolder)
                        } // end of if excluded
                    } // end of if containerExistInFileSys
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_INCREMENT"), object: nil)
                    index += 1
                })
            
//            while(index < containers.count ){
//            //for container in containers { // most high memory impact
//
//                if limitRam > 0 {
//                    var taskInfo = mach_task_basic_info()
//                    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
//                    let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
//                        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
//                            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
//                        }
//                    }
//
//                    if kerr == KERN_SUCCESS {
//                        let usedRam = taskInfo.resident_size / 1024 / 1024
//
//                        if usedRam >= limitRam {
//                            attempt += 1
//                            self.logger.log("waiting for releasing memory for Setting up containers' parent, attempt: \(attempt)")
//                            continousWorking = false
//                            sleep(10)
//                        }else{
////                            self.logger.log("continue for Setting up containers' parent, last attempt: \(attempt)")
//                            continousWorking = true
//                        }
//                    }
//                }
//
//                if continousWorking {
//                    autoreleasepool { () -> Void in
//                        let container = containers[index]
//
//                        var containerExistInFileSys = false
//                        var isDir:ObjCBool = false
//                        if FileManager.default.fileExists(atPath: container.path, isDirectory: &isDir) {
//                            if isDir.boolValue == true {
//                                containerExistInFileSys = true
//                            }
//                        }
//                        if !containerExistInFileSys {
//                            self.logger.log("Container does not exist in FileSys, ignore processing: \(index)/\(jall): \(container.path)")
//
//                        }else{
//
//                            var exclude = false
//                            if excludedContainerPaths.contains(container.path) {
//                                exclude = true
//                            }else{
//                                for excludedPath in excludedContainerPaths {
//                                    if container.path.hasPrefix(excludedPath.withStash()) {
//                                        exclude = true
//                                        break
//                                    }
//                                }
//                            }
//
//                            if container.hideByParent || exclude {
//                                // do nothing
//                            }else{
////                                self.logger.log("[Container DB Scan] Setting parent for container \(index)/\(jall) [\(container.path)]")
//                                let imageFolder:ImageFolder = ImageFolder(URL(fileURLWithPath: container.path),
//                                                                          name:container.name,
//                                                                          repositoryPath: container.repositoryPath,
//                                                                          homePath: container.homePath,
//                                                                          storagePath: container.storagePath,
//                                                                          facePath: container.facePath,
//                                                                          cropPath: container.cropPath,
//                                                                          countOfImages: Int(container.imageCount),
//                                                                          withContainer: true)
//                                urlFolders[container.path] = imageFolder
//                                if fast { // fast
//                                    if container.parentFolder != "" {
//                                        if let parentFolder = urlFolders[container.parentFolder] {
//                                            imageFolder.setParent(parentFolder)
////                                            self.logger.log("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "") << FROM CACHE")
//                                        }
//                                    }else{
//                                        if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
//                                            imageFolder.setParent(parent)
////                                            self.logger.log("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
//                                            foldersNeedSave.insert(imageFolder)
//                                        }
//                                    }
//
//                                }else{
//                                    if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
//                                        imageFolder.setParent(parent)
////                                        self.logger.log("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
//                                        foldersNeedSave.insert(imageFolder)
//                                    }
//                                }
//                                if let parent = imageFolder.parent {
//                                    let subPath = container.path.replacingFirstOccurrence(of: "\(parent.url.path.withStash())", with: "")
//                                    imageFolder.name = subPath
//
////                                    self.logger.log("SUB PATH -> \(subPath)")
//
//                                    if subPath.contains("/") {
//                                        let parts = subPath.components(separatedBy: "/")
//                                        var midPaths:[String] = []
//                                        for part in parts {
//                                            if part == "" {continue}
//                                            if midPaths.count == 0 {
//                                                let midPath = parent.url.appendingPathComponent(part).path
////                                                self.logger.log("MID FOLDER EXTRACTED FROM SUB PATH: \(midPath)")
//                                                midPaths.append(midPath)
//                                            }else{
//                                                let parentMidPath = midPaths[midPaths.count-1]
//                                                let midPath = URL(fileURLWithPath: parentMidPath).appendingPathComponent(part).path
////                                                self.logger.log("MID FOLDER EXTRACTED FROM SUB PATH: \(midPath)")
//                                                midPaths.append(midPath)
//                                            }
//                                        }
//                                        var parents:[ImageFolder] = [parent]
//                                        var midFolders:[ImageFolder] = []
//                                        for midPath in midPaths {
//                                            if midPath.withStash() == container.path.withStash() {
//                                                continue
//                                            }
//                                            // create imagefolder without container data
//                                            let midUrl = URL(fileURLWithPath: midPath)
//
//                                            // get middle dummy ImageFolder from cache if it exists
//                                            var midFolder = urlFolders[midPath]
//                                            if midFolder == nil {
//                                                // create dummy ImageFolder in the middle
//                                                midFolder = ImageFolder(midUrl, name: midUrl.lastPathComponent)
//                                                midFolder!.setParent(parents[parents.count - 1])
////                                                self.logger.log("SET PARENT FOR \(midFolder!.url.path) -> PARENT SET TO \(midFolder!.parent?.url.path ?? "") << CREATED DUMMY")
//
//                                                // to be added to the whole set
//                                                midFolders.append(midFolder!)
//
//                                                // cache mapping
//                                                urlFolders[midPath] = midFolder!
//                                            }
//                                            parents.append(midFolder!) // for next calculation
//                                        }
//                                        imageFolder.setParent(parents[parents.count - 1])
////                                        self.logger.log("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
//                                        imageFolder.name = URL(fileURLWithPath: container.path).lastPathComponent
//
//                                        imageFolders.append(contentsOf: midFolders)
//                                    }
//                                }
//                                imageFolders.append(imageFolder)
//                            } // end of if excluded
//                        } // end of if containerExistInFileSys
//
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_INCREMENT"), object: nil)
//                        index += 1
//                    } // end of autorelease
//
//                } // end of continuous working
//            } // end of while loop
        }// end of if-containers-is-empty
        urlFolders.removeAll()
        self.logger.log("Setting up containers' parent: DONE ")
        
        if foldersNeedSave.count > 0 {
            self.logger.log("Saving containers' parent")
            var k = 0
            let kall = foldersNeedSave.count
            for imageFolder in foldersNeedSave {
                k += 1
                if let imageContainer = imageFolder.containerFolder {
                    var containerExistInFileSys = false
                    var isDir:ObjCBool = false
                    if FileManager.default.fileExists(atPath: imageContainer.path, isDirectory: &isDir) {
                        if isDir.boolValue == true {
                            containerExistInFileSys = true
                        }
                    }
                    if !containerExistInFileSys {
                        self.logger.log("Container does not exist in FileSys, ignore saving in DB: \(k)/\(kall): \(imageContainer.path)")
                        continue;
                    }
                    
                    let saveState = RepositoryDao.default.saveImageContainer(container: imageContainer)
                    if saveState == .OK {
                        self.logger.log("Saved container into DB \(k)/\(kall): \(imageContainer.path)")
                    }else{
                        self.logger.log("[\(saveState)] Unable to save container into DB \(k)/\(kall): \(imageContainer.path)")
                    }
                }
            }
            self.logger.log("Saving containers' parent: DONE ")
        }
        foldersNeedSave.removeAll()
        
//        self.logger.log("======================")
//        for imgf in imageFolders {
//            self.logger.log("\(imgf.url.path) -> PARENT -> \(imgf.parent?.url.path ?? "")")
//        }
//        self.logger.log("======================")
        
        return imageFolders
    }
    
    fileprivate func scanPhotosToLoadExif(images:[Image], taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil) {
//        if suppressedScan {
//            if indicator != nil {
//                indicator?.forceComplete()
//            }
//            return
//        }
        
        self.logger.log("checking stop flag for task id \(taskId)")
        
        if TaskletManager.default.isTaskStopped(id: taskId) == true { return }
        
        self.logger.log("continue load exif")
        
        if indicator != nil {
            DispatchQueue.main.async {
                let _ = indicator?.add(Words.progress_meta_scan_loading_rules.word())
            }
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.progress_meta_scan_loading_rules.word(), increase: false)
        
        let excludedContainerPaths = DeviceDao.default.getExcludedImportedContainerPaths(withStash: true)
        
        self.logger.log("loaded excluded container paths")
        
        let photoCount = images.count
        
        if photoCount > 0 {
            self.logger.log("UPDATING EXIF: \(images.count)")
            if indicator != nil {
                indicator?.setTarget(photoCount)
            }

            TaskletManager.default.setTotal(id: taskId, total: photoCount)
            
            self.logger.log("set total \(photoCount)")
            
            var i = 0
            
            for photo in images {
                
                i += 1
                
//                if suppressedScan {
//                    if indicator != nil {
//                        indicator?.forceComplete()
//                    }
//                    return
//                }
                
                if TaskletManager.default.isTaskStopped(id: taskId) == true { return }
                
                var exclude = false
                for excludedPath in excludedContainerPaths {
                    if photo.path.hasPrefix(excludedPath) {
                        self.logger.log("Exclude image (exclude device path): \(photo.path)")
                        exclude = true
                        break
                    }
                }
                if !exclude {
                    let _ = ImageFile(image: photo, indicator: indicator, forceReloadExif: true)
                }else{
                    if indicator != nil {
                        DispatchQueue.main.async {
                            let _ = indicator?.add(Words.progress_meta_scan_loading_images.word())
                        }
                    }
                }
                
                TaskletManager.default.updateProgress(id: taskId, message: Words.progress_meta_scan_images.fill(arguments: "\(i)", "\(photoCount)", photo.subPath), increase: true)
                self.logger.log("finished exif \(photo.subPath)")
            } // end of images-loop
            //ModelStore.save()
            self.logger.log("UPDATING EXIF: SAVE DONE")
        }else {
            if indicator != nil {
                indicator?.forceComplete()
            }
            TaskletManager.default.updateProgress(id: taskId, message: Words.extract_meta_no_need.word(), increase: false)
        }
        
        TaskletManager.default.forceComplete(id: taskId)
        
        if onCompleted != nil {
            onCompleted!()
        }
    }
    
    func scanPhotosToLoadExif(repository:ImageContainer, taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil)  {
        if indicator != nil {
            DispatchQueue.main.async {
                let _ = indicator?.add(Words.exif_scan_loading_images.word())
            }
        }
        TaskletManager.default.updateProgress(id: taskId, message: Words.exif_scan_loading_images.word(), increase: false)
        let images = ImageSearchDao.default.getPhotoFilesWithoutExif(repositoryPath: repository.repositoryPath)
        self.logger.log("PHOTOS WITHOUT EXIF: \(images.count) - \(repository.name)")
        self.scanPhotosToLoadExif(images: images, taskId: taskId, indicator: indicator, onCompleted: onCompleted)
    }
    
    func scanPhotosToLoadExif(taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil)  {
        if indicator != nil {
            DispatchQueue.main.async {
                let _ = indicator?.add(Words.exif_scan_loading_images.word())
            }
        }
        TaskletManager.default.updateProgress(id: taskId, message: Words.exif_scan_loading_images.word(), increase: false)
        let images = ImageSearchDao.default.getPhotoFilesWithoutExif()
        self.logger.log("PHOTOS WITHOUT EXIF: \(images.count)")
        self.scanPhotosToLoadExif(images: images, taskId: taskId, indicator: indicator, onCompleted: onCompleted)
    }
    
    func scanPhotosToLoadExif_asTask(repository:ImageContainer, indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil) {
        let _ = TaskletManager.default.createAndStartTask(type: "EXIF", name: repository.name
        , exec: { task in
            DispatchQueue.global().async {
                self.scanPhotosToLoadExif(repository: repository, taskId: task.id, indicator: indicator, onCompleted: onCompleted)
            }
        }, stop: {task in
            
        })
    }
    
    func scanPhotosToLoadLocation(repository:ImageContainer, taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil)  {
        if indicator != nil {
            DispatchQueue.main.async {
                let _ = indicator?.add(Words.location_scan_loading_images.word())
            }
        }
        TaskletManager.default.updateProgress(id: taskId, message: Words.location_scan_loading_images.word(), increase: false)
        let images = ImageSearchDao.default.getPhotoFilesWithoutLocation(repositoryPath: repository.repositoryPath)
        self.logger.log("PHOTOS WITHOUT LOCATION: \(images.count) - \(repository.name)")
        self.scanPhotosToLoadExif(images: images, taskId: taskId, indicator: indicator, onCompleted: onCompleted)
    }
    
    func scanPhotosToLoadLocation_asTask(repository:ImageContainer, indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil) {
        let _ = TaskletManager.default.createAndStartTask(type: "LOCATION", name: repository.name
        , exec: { task in
            DispatchQueue.global().async {
                self.scanPhotosToLoadLocation(repository: repository, taskId: task.id, indicator: indicator, onCompleted: onCompleted)
            }
        }, stop: {task in
            
        })
    }
    
    func createRepository(name:String,
                                 path:String,
                                 homePath:String,
                                 storagePath:String,
                                 facePath:String,
                                 cropPath:String) -> ImageFolder {
        self.logger.log("Creating repository with name:\(name) , path:\(path)")
        return ImageFolder(URL(fileURLWithPath: path),
                            name: name,
                            repositoryPath: path,
                            homePath: homePath,
                            storagePath: storagePath,
                            facePath: facePath,
                            cropPath: cropPath)
    }
    
    func walkthruDirectoryForPaths(repository:ImageContainer, taskId:String = "", indicator:Accumulator? = nil) -> DirectoryPaths{
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
                                                                self.logger.log("`directoryEnumerator` error: \(error).")
                                                                return true
        }
            ) else { return result}
        
        for case let url as NSURL in directoryEnumerator {
            do {
                if ImageFolderTreeScanner.default.suppressedScan {
                    break
                }
                let resourceValues = try url.resourceValues(forKeys: resourceValueKeys)
                guard let isRegularFileResourceValue = resourceValues[URLResourceKey.isRegularFileKey] as? NSNumber else { continue }
                guard isRegularFileResourceValue.boolValue else { continue }
                guard let fileType = resourceValues[URLResourceKey.typeIdentifierKey] as? String else { continue }
                guard (UTTypeConformsTo(fileType as CFString, kUTTypeImage) || UTTypeConformsTo(fileType as CFString, kUTTypeMovie)) else { continue }
                let url = url as URL
                
                // to support soft link
                let path = url.path.replacingFirstOccurrence(of: realPhysicalPath, with: repositoryPath)
                let transformedURL = URL(fileURLWithPath: path)
                self.logger.log("[FileSys Scan] Getting entry: \(path)")
                
                if indicator != nil {
                    indicator?.display(message: Words.filesys_scan_repository.fill(arguments: repositoryPath))
                }
                
                TaskletManager.default.updateProgress(id: taskId, message: Words.filesys_scan_repository.fill(arguments: repositoryPath), increase: false)
                
                result.filesysUrls.insert(path)
                result.fileUrlToRepo[path] = repository
                let folderUrl = transformedURL.deletingLastPathComponent()
                result.foldersysUrls.insert(folderUrl.path)
            }
            catch {
                self.logger.log("Unexpected error occured: \(error).")
            }
        }
        if indicator != nil {
            indicator?.display(message: "")
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: "", increase: false)
        return result
    }
    
    fileprivate func scanRepository(repository repo:ImageContainer, excludedContainerPaths:Set<String>, step i:Int, total totalCount:Int, taskId:String = "", indicator:Accumulator? = nil) -> (Bool, Set<String>, [String:ImageContainer]) {
        
        // for return:
        var filesysUrls:Set<String> = Set<String>()
        var fileUrlToRepo:[String:ImageContainer] = [:]
        
        // for local use:
        var foldersysUrls:Set<String> = Set<String>()
        let repositoryPath = repo.path.withStash()
        
        if suppressedScan {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return (false, filesysUrls, fileUrlToRepo)
        }
        
        if TaskletManager.default.isTaskStopped(id: taskId) == true { return (false, filesysUrls, fileUrlToRepo) }
        
        if indicator != nil {
            indicator?.display(message: Words.scanning_repository.fill(arguments: i, totalCount))
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.scanning_repository.fill(arguments: i, totalCount), increase: false)
        
        var repoExistInFileSys = false
        var isDir:ObjCBool = false
        if FileManager.default.fileExists(atPath: repo.path, isDirectory: &isDir) {
            if isDir.boolValue == true {
                repoExistInFileSys = true
            }
        }
        
        if !repoExistInFileSys {
            self.logger.log("[Repository Scan] Repository does not exist in FileSys: [\(repo.path)]")
            let deleteState = RepositoryDao.default.deleteContainer(path: repo.path, deleteImage: true)
            if deleteState == .OK {
                self.logger.log("[Repository Scan] Deleted non-exist repository and related images in DB: [\(repo.path)]")
            }else{
                self.logger.log("[Repository Scan] [\(deleteState)] Unable to delete non-exist repository and related images in DB: [\(repo.path)]")
            }
            return (false, filesysUrls, fileUrlToRepo)// continue
        }
        
        if repo.path.withStash() != repo.repositoryPath.withStash() {
            self.logger.log("[Repository Scan] Record is not a valid repository: path=[\(repo.path)] , it should belong to repositoryPath=[\(repo.repositoryPath)]")
            return (false, filesysUrls, fileUrlToRepo)// continue
        }
        
        var containers = RepositoryDao.default.getAllContainerPaths(repositoryPath: repositoryPath).sorted()
        
//            var pathToDeviceSubFolder:[String:String] = [:]
        if repo.deviceId != "" {
            let devicePaths = DeviceDao.default.getDevicePaths(deviceId: repo.deviceId)
            if devicePaths.count > 0 {
                for devicePath in devicePaths {
                    if !devicePath.exclude && !devicePath.excludeImported {
                        let path = URL(fileURLWithPath: repo.path).appendingPathComponent(devicePath.toSubFolder).path
//                            pathToDeviceSubFolder[path] = devicePath.toSubFolder
                        
                        self.logger.log("[Repository Scan] get or create container for device [id=\(repo.deviceId)] path [\(path)]")
                        let folder = ImageFolder(URL(fileURLWithPath: path),
                                                      name: devicePath.toSubFolder,
                                                      repositoryPath: repositoryPath,
                                                      homePath: "",
                                                      storagePath: "",
                                                      facePath: "",
                                                      cropPath: "",
                                                      countOfImages: 0,
                                                      manyChildren: devicePath.manyChildren
                        )
                        
                        if let container = folder.containerFolder, container.parentFolder == "", container.path != repo.path {
                            let _ = RepositoryDao.default.updateImageContainerParentFolder(path: path, parentFolder: repo.path)
                        }
                        if !containers.contains(path) {
                            containers.append(path)
                        }
                    } // end of if not excluded
                } // end of loop devicePaths
                let _ = RepositoryDao.default.updateImageContainerSubContainers(path: repo.path)
            } // end of if devicePaths.count > 0
        } // end of if repo.deviceid != ""
        
        self.logger.log("CHECKING REPO \(repo.path)")
        
        self.logger.log("CHECK REPO: ENUMERATING FILESYS")
        
        autoreleasepool { () -> Void in
            self.logger.log(">>> WALKING THRU DIRECTORY begin \(i)/\(totalCount) <<<")
            if indicator != nil {
                indicator?.display(message: Words.walking_thru_directory.fill(arguments: "\(i)", "\(totalCount)", repo.name))
            }
            
            TaskletManager.default.updateProgress(id: taskId, message: Words.walking_thru_directory.fill(arguments: "\(i)", "\(totalCount)", repo.name), increase: false)
                    
            let directoryPaths = self.walkthruDirectoryForPaths(repository: repo, indicator: indicator)
            for filesysUrl in directoryPaths.filesysUrls {
                filesysUrls.insert(filesysUrl)
            }
            for key in directoryPaths.fileUrlToRepo.keys {
                fileUrlToRepo[key] = directoryPaths.fileUrlToRepo[key]
            }
            for folderUrl in directoryPaths.foldersysUrls {
                foldersysUrls.insert(folderUrl)
            }
            self.logger.log(">>> WALKING THRU DIRECTORY done \(i)/\(totalCount)  <<<")
        }
        
        self.logger.log("CHECK REPO: ENUMERATING FILESYS: DONE")
        
        self.logger.log("CHECK REPO: CHECK FOLDERS TO BE ADDED AND REMOVED")
        
        autoreleasepool { () -> Void in
            
            let folderDBUrls = RepositoryDao.default.getAllContainerPaths(repositoryPath: repositoryPath)
            let folderUrlsToAdd:[String] = foldersysUrls.subtracting(folderDBUrls).sorted()
            let folderUrlsToRemoved:Set<String> = folderDBUrls.subtracting(foldersysUrls)
            
            // urlsToAdd should minus those excluded device paths
            if folderUrlsToAdd.count > 0 {
                
                var k = 0
                let kall = folderUrlsToAdd.count
                for path in folderUrlsToAdd {
                    
                    if suppressedScan {
                        if indicator != nil {
                            indicator?.forceComplete()
                        }
                        return
                    }
                    
                    if TaskletManager.default.isTaskStopped(id: taskId) == true { return }
                    
                    k += 1
                    
                    var exclude = false
                    if excludedContainerPaths.contains(path) {
                        exclude = true
                        self.logger.log("Exclude container: \(path)")
                    }else{
                        for excludedPath in excludedContainerPaths {
                            if path.hasPrefix(excludedPath.withStash()) {
                                exclude = true
                                self.logger.log("Exclude container: \(path)")
                                break
                            }
                        }
                    }
                    
                    self.logger.log("Adding container folder \(k)/\(kall): \(path)")
                    if indicator != nil {
                        indicator?.display(message: Words.adding_container_folder.fill(arguments: k, kall))
                    }
                    
                    TaskletManager.default.updateProgress(id: taskId, message: Words.adding_container_folder.fill(arguments: k, kall), increase: false)
                    
                    if !exclude {
                    
                        let url = URL(fileURLWithPath: path)
                        let name = url.lastPathComponent
                        
                        // create container db record
                        let _ = ImageFolder(url,
                                            name: name,
                                            repositoryPath: repositoryPath,
                                            homePath: "",
                                            storagePath: "",
                                            facePath: "",
                                            cropPath: "")
                        
                        // FIXME: update parentFolder field
                        
                        if !containers.contains(path) {
                            containers.append(path)
                        }
                    } // end of not excluded\
                } // end of loop folderUrlsToAdd
                
                // current + added containers used for each container to get nearest parent
                containers = containers.sorted().reversed() // put the shortest root to bottom, make it hardest to be found
                var j = 0
                for path in folderUrlsToAdd {
                    
                    if suppressedScan {
                        if indicator != nil {
                            indicator?.forceComplete()
                        }
                        return
                    }
                    
                    if TaskletManager.default.isTaskStopped(id: taskId) == true { return }
                    
                    j += 1
                    
                    var exclude = false
                    if excludedContainerPaths.contains(path) {
                        exclude = true
                        self.logger.log("Exclude container: \(path)")
                    }else{
                        for excludedPath in excludedContainerPaths {
                            if path.hasPrefix(excludedPath.withStash()) {
                                exclude = true
                                self.logger.log("Exclude container: \(path)")
                                break
                            }
                        }
                    }
                    
                    
                    self.logger.log("Getting parent folder \(j)/\(kall): \(path)")
                    if indicator != nil {
                        indicator?.display(message: Words.getting_parent_folder.fill(arguments: j, kall))
                    }
                    
                    TaskletManager.default.updateProgress(id: taskId, message: Words.getting_parent_folder.fill(arguments: j, kall), increase: false)
                    
                    if !exclude {
                        if let parentFolder = path.getNearestParent(from: containers) { //FIXME: has bug here
                            self.logger.log("### FIND PARENT >>> \(path) >>> parent folder: \(parentFolder)")
                            
                            let _ = RepositoryDao.default.updateImageContainerParentFolder(path: path, parentFolder: parentFolder)
                            
                            if let parent = RepositoryDao.default.getContainer(path: parentFolder), parent.manyChildren == true {
                                let _ = RepositoryDao.default.updateImageContainerHideByParent(path: path, hideByParent: true)
                            }
                        }
                    } // end of not excluded
                    
                } // end of loop folderUrlsToAdd
                
//                    if indicator != nil {
//                        indicator?.dataChanged()
//                    }
            }// end of folderUrlsToAdd.count > 0
            
            if folderUrlsToRemoved.count > 0 {
                var k=0
                for path in folderUrlsToRemoved {
                    k+=1
                    // REMOVE sub CONTAINER FROM DB
                    if !FileManager.default.fileExists(atPath: path) {
                        let deleteState = RepositoryDao.default.deleteContainer(path: path, deleteImage: true)
                        
                        if deleteState == .OK {
                            self.logger.log("Deleted container and related images from DB: \(path)")
                            if indicator != nil { indicator?.display(message: Words.removed_non_exist_container.fill(arguments: k, folderUrlsToRemoved.count)) }
                            
                            TaskletManager.default.updateProgress(id: taskId, message: Words.removed_non_exist_container.fill(arguments: k, folderUrlsToRemoved.count), increase: false)

                        }else{
                            self.logger.log("[\(deleteState)] Failed to delete container and related images from DB: \(path)")
                            if indicator != nil { indicator?.display(message: Words.failed_to_remove_non_exist_container.fill(arguments: "\(deleteState)", "\(k)", "\(folderUrlsToRemoved.count)")) }
                            
                            TaskletManager.default.updateProgress(id: taskId, message: Words.failed_to_remove_non_exist_container.fill(arguments: "\(deleteState)", "\(k)", "\(folderUrlsToRemoved.count)"), increase: false)

                        }
                    }
                }
                
//                    if indicator != nil {
//                        indicator?.dataChanged()
//                    }
            } // end of folderUrlsToRemoved.count > 0
        } // end of autorelease
        
        return (true, filesysUrls, fileUrlToRepo)
    }
    
    fileprivate func applyImportGap(dbUrls:Set<String>, filesysUrls:Set<String>, fileUrlToRepo:[String:ImageContainer], excludedContainerPaths:Set<String>, taskId:String = "",  indicator:Accumulator? = nil) -> Bool {
        self.logger.log("EXISTING DB PHOTO COUNT = \(dbUrls.count)")
        self.logger.log("EXISTING SYS PHOTO COUNT = \(filesysUrls.count)")
//        var dbUrls:Set<String> = Set<String>()
//        for exist in exists {
//            let path = exist.path
//            dbUrls.insert(path)
//
//        }
        self.logger.log("EXISTING DB PHOTO COUNT2 = \(dbUrls.count)")
        
        if dbUrls.count == filesysUrls.count {
            if indicator != nil { indicator?.display(message: Words.filesys_scan_no_gap_between_db_and_filesys.word()) }
            
            TaskletManager.default.updateProgress(id: taskId, message: Words.filesys_scan_no_gap_between_db_and_filesys.word(), increase: false)
            
            return true
        }else if dbUrls.count < filesysUrls.count {
            let gap = dbUrls.count - filesysUrls.count
            if indicator != nil { indicator?.display(message: Words.filesys_scan_db_less_than_filesys.fill(arguments: dbUrls.count, gap, filesysUrls.count)) }
            
            TaskletManager.default.updateProgress(id: taskId, message: Words.filesys_scan_db_less_than_filesys.fill(arguments: dbUrls.count, gap, filesysUrls.count), increase: false)
        }else if dbUrls.count > filesysUrls.count {
            let gap = dbUrls.count - filesysUrls.count
            if indicator != nil { indicator?.display(message: Words.filesys_scan_db_more_than_filesys.fill(arguments: dbUrls.count, gap, filesysUrls.count)) }
            
            TaskletManager.default.updateProgress(id: taskId, message: Words.filesys_scan_db_more_than_filesys.fill(arguments: dbUrls.count, gap, filesysUrls.count), increase: false)
        }
        
        let urlsToAdd:[String] = filesysUrls.subtracting(dbUrls).sorted()
        let urlsToRemoved:Set<String> = dbUrls.subtracting(filesysUrls)
        
        self.logger.log("CHECK REPO: CHECK TO BE ADDED AND REMOVED : DONE")
        
        let total = urlsToAdd.count + urlsToRemoved.count
        
        if total == 0 {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return false
        }
        
        if indicator != nil {
            indicator?.display(message: Words.ready_to_add_remove_images.word())
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.ready_to_add_remove_images.word(), increase: false)
        
        if indicator != nil {
            indicator?.setTarget(total)
        }
        
        TaskletManager.default.setTotal(id: taskId, total: total)
        
        self.logger.log("CHECK REPO: EXECUTE ADD OR REMOVE")
        
        if urlsToAdd.count > 0 {
            self.logger.log("URLS TO ADD FROM FILESYS: \(urlsToAdd.count)")
//            indicator?.dataChanged()
            
            var index = 0
            MemoryReleasable.default.run(
            when: { return index < urlsToAdd.count },
            shouldStop: {
                if suppressedScan {
                    if indicator != nil {
                        indicator?.forceComplete()
                    }
                    return true
                }
                
                if TaskletManager.default.isTaskStopped(id: taskId) == true { return true }
                
                return false
            },
            do: {
                let url = urlsToAdd[index]
                
                var exclude = false
                if excludedContainerPaths.contains(url) {
                    self.logger.log("Exclude image (excluded device path): \(url)")
                    exclude = true
                }else{
                    for excludedPath in excludedContainerPaths {
                        if url.hasPrefix(excludedPath.withStash()) {
                            self.logger.log("Exclude image (excluded device path): \(url)")
                            exclude = true
                            break
                        }
                    }
                }
                
                if !exclude {
                    let createState = self.createImageIfAbsent(url: url, fileUrlToRepo: fileUrlToRepo, indicator: indicator)
                    if createState == .OK {
                        DispatchQueue.main.async {
                            self.logger.log("Imported images ... (\(index)/\(urlsToAdd.count))")
                            if indicator != nil { let _ = indicator?.add(Words.imported_images.fill(arguments: index, urlsToAdd.count)) }
                        }
                        
                        TaskletManager.default.updateProgress(id: taskId, message: Words.imported_images.fill(arguments: index, urlsToAdd.count), increase: true)
                    }else{
                        DispatchQueue.main.async {
                            self.logger.log("[\(createState)] Unable to import images ... (\(index)/\(urlsToAdd.count))")
                            if indicator != nil { let _ = indicator?.add(Words.failed_to_import_images.fill(arguments: "\(createState)", "\(index)", "\(urlsToAdd.count)")) }
                        }
                        
                        TaskletManager.default.updateProgress(id: taskId, message: Words.failed_to_import_images.fill(arguments: "\(createState)", "\(index)", "\(urlsToAdd.count)"), increase: true)
                    }
                }else{
                }
                index += 1
            })

            
//            let limitRam = PreferencesController.peakMemory() * 1024
//            var continousWorking = true
//            var index = 0
//            var attempt = 0
//
//            while(index < urlsToAdd.count ){
//            //for url in urlsToAdd { // most high memory impact
//
//                if suppressedScan {
//                    if indicator != nil {
//                        indicator?.forceComplete()
//                    }
//                    return false
//                }
//
//                if TaskletManager.default.isTaskStopped(id: taskId) == true { return false }
//
//                if limitRam > 0 {
//                    var taskInfo = mach_task_basic_info()
//                    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
//                    let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
//                        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
//                            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
//                        }
//                    }
//
//                    if kerr == KERN_SUCCESS {
//                        let usedRam = taskInfo.resident_size / 1024 / 1024
//
//                        if usedRam >= limitRam {
//                            continousWorking = false
//                            attempt += 1
//                            self.logger.log(">>> waiting for releasing memory for URLS TO ADD FROM FILESYS, attempt:\(attempt)")
//                            sleep(10)
//                        }else{
//                            self.logger.log(">>> continue for URLS TO ADD FROM FILESYS, last attempt:\(attempt)")
//                            continousWorking = true
//                        }
//                    }
//                }
//                if continousWorking {
//                    autoreleasepool { () -> Void in
//                        let url = urlsToAdd[index]
//
//                        var exclude = false
//                        if excludedContainerPaths.contains(url) {
//                            self.logger.log("Exclude image (excluded device path): \(url)")
//                            exclude = true
//                        }else{
//                            for excludedPath in excludedContainerPaths {
//                                if url.hasPrefix(excludedPath.withStash()) {
//                                    self.logger.log("Exclude image (excluded device path): \(url)")
//                                    exclude = true
//                                    break
//                                }
//                            }
//                        }
//
//                        if !exclude {
//                            let createState = self.createImageIfAbsent(url: url, fileUrlToRepo: fileUrlToRepo, indicator: indicator)
//                            if createState == .OK {
//                                DispatchQueue.main.async {
//                                    self.logger.log("Imported images ... (\(index)/\(urlsToAdd.count))")
//                                    if indicator != nil { let _ = indicator?.add("Imported images ... (\(index)/\(urlsToAdd.count))") }
//                                }
//
//                                TaskletManager.default.updateProgress(id: taskId, message: "Imported images ... (\(index)/\(urlsToAdd.count))", increase: true)
//                            }else{
//                                DispatchQueue.main.async {
//                                    self.logger.log("[\(createState)] Unable to import images ... (\(index)/\(urlsToAdd.count))")
//                                    if indicator != nil { let _ = indicator?.add("[\(createState)] Unable to import images ... (\(index)/\(urlsToAdd.count))") }
//                                }
//
//                                TaskletManager.default.updateProgress(id: taskId, message: "[\(createState)] Unable to import images ... (\(index)/\(urlsToAdd.count))", increase: true)
//                            }
//                        }else{
//                        }
//                        index += 1
//                    }
//                }
//
//            }
//            if indicator != nil {
//                indicator?.dataChanged()
//            }
            self.logger.log("URLS TO ADD FROM FILESYS: SAVE DONE")
        } // end of urlsToAdd.count > 0
        
        var k = 0
        if urlsToRemoved.count > 0 {
            self.logger.log("PHOTOS TO REMOVED FROM DB: \(urlsToRemoved.count)")
            k += 1
//            indicator?.dataChanged()
            for url in urlsToRemoved {
                
                if suppressedScan {
                    if indicator != nil {
                        indicator?.forceComplete()
                    }
                    return false
                }
                
                if TaskletManager.default.isTaskStopped(id: taskId) == true { return false }
                
                
                self.logger.log("Deleting image from DB (delFlag): \(url)")
                let deleteState = ImageRecordDao.default.deletePhoto(atPath: url)
                
                if deleteState == .OK {
                    self.logger.log("Deleted images ... (\(k)/\(urlsToRemoved.count))")
                    if indicator != nil { let _ = indicator?.add(Words.deleted_images.fill(arguments: k, urlsToRemoved.count)) }
                    
                    TaskletManager.default.updateProgress(id: taskId, message: Words.deleted_images.fill(arguments: k, urlsToRemoved.count), increase: true)
                }else{
                    self.logger.log("[\(deleteState)] Unable to delete images ... (\(k)/\(urlsToRemoved.count))")
                    if indicator != nil { let _ = indicator?.add(Words.failed_to_delete_images.fill(arguments: "\(deleteState)", "\(k)", "\(urlsToRemoved.count)")) }
                    
                    TaskletManager.default.updateProgress(id: taskId, message: Words.failed_to_delete_images.fill(arguments: "\(deleteState)", "\(k)", "\(urlsToRemoved.count)"), increase: true)
                }
            }
            
//            if indicator != nil {
//                indicator?.dataChanged()
//            }
            //DispatchQueue.main.async {
                //ModelStore.save()
            //}
            self.logger.log("PHOTOS TO REMOVED FROM DB: SAVE DONE")
        } // end of urlsToRemoved.count > 0
        
        self.logger.log("CHECK REPO: EXECUTE ADD OR REMOVE: DONE")
        
        return true
    }
    
    func scanSingleRepository_asTask(repository:ImageContainer, indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil) {
        let _ = TaskletManager.default.createAndStartTask(type: "IMPORT", name: repository.name
        , exec: { task in
            DispatchQueue.global().async {
                let _ = self.scanSingleRepository(repository: repository, taskId: task.id, indicator: indicator, onCompleted: onCompleted)
                TaskletManager.default.forceComplete(id: task.id)
            }
        }, stop: {task in
            
        })
    }
    
    // entrance method
    func scanSingleRepository(repository:ImageContainer, taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil) -> Bool {
        
        if TaskletManager.default.isTaskStopped(id: taskId) == true { return false }
        
        if indicator != nil { indicator?.display(message: Words.scanning_repository.word()) }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.scanning_repository.word(), increase: false)
        
        let excludedContainerPaths = DeviceDao.default.getExcludedImportedContainerPaths()
        let (_, repoFileSysUrls, repoFileUrlToRepo) = self.scanRepository(repository: repository, excludedContainerPaths: excludedContainerPaths, step: 1, total: 1, taskId: taskId, indicator: indicator)
        
        self.logger.log("CHECK REPO: CHECK TO BE ADDED AND REMOVED")
        if indicator != nil { indicator?.display(message: Words.checking_gap_between_db_and_filesys.word()) }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.filesys_scan_loading_all_images_from_db.word(), increase: false)
        
        let dbUrls = ImageSearchDao.default.getAllPhotoPaths(repositoryPath: repository.repositoryPath)
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.checking_gap_between_db_and_filesys.word(), increase: false)
        
        let shouldContinue = self.applyImportGap(dbUrls: dbUrls, filesysUrls: repoFileSysUrls, fileUrlToRepo: repoFileUrlToRepo, excludedContainerPaths: excludedContainerPaths, taskId: taskId, indicator: indicator)
        
        if !shouldContinue {
            return false
        }
        
        self.logger.log("TRIGGER ON DATA CHANGED EVENT AFTER FINISHED SCANNING REPOSITORIES")
        if indicator != nil {
            indicator?.display(message: Words.filesys_scan_repository_scan_done.word())
            indicator?.dataChanged()
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.filesys_scan_repository_scan_done.word(), increase: false)
        
        if onCompleted != nil {
            onCompleted!()
        }
        return true
    }
    
    // entrance method
    func scanRepositories(taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil)  {
        
        if suppressedScan {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return
        }
        
        if TaskletManager.default.isTaskStopped(id: taskId) == true { return }
        
        if indicator != nil {
            indicator?.display(message: Words.progress_loading_repoistories_from_db.word())
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.progress_loading_repoistories_from_db.word(), increase: false)
        
        let repositories = RepositoryDao.default.getRepositories()
        self.logger.log("REPO COUNT = \(repositories.count)")
        
        if indicator != nil {
            indicator?.display(message: Words.progress_scanning_n_repoistories.fill(arguments: repositories.count))
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.progress_scanning_n_repoistories.fill(arguments: repositories.count), increase: false)
        
        let excludedContainerPaths = DeviceDao.default.getExcludedImportedContainerPaths()
        
        var filesysUrls:Set<String> = Set<String>()
        var fileUrlToRepo:[String:ImageContainer] = [:]
        let totalCount = repositories.count
        var i = 0
        for repo in repositories {
            
            i += 1
            let (isContinue, repoFileSysUrls, repoFileUrlToRepo) = self.scanRepository(repository: repo, excludedContainerPaths: excludedContainerPaths, step: i, total: totalCount, indicator: indicator)
            
            filesysUrls = filesysUrls.union(repoFileSysUrls)
            fileUrlToRepo = fileUrlToRepo.merging(repoFileUrlToRepo, uniquingKeysWith: { (container1, container2) -> ImageContainer in
                return container1
            })
            
            if !isContinue {
                return
            }
        } // end of loop repositories
        
        self.logger.log("CHECK REPO: CHECK TO BE ADDED AND REMOVED")
        if indicator != nil {
            indicator?.display(message: Words.checking_gap_between_db_and_filesys.word())
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.checking_gap_between_db_and_filesys.word(), increase: false)
        
        let dbUrls = ImageSearchDao.default.getAllPhotoPaths()
        let shouldContinue = self.applyImportGap(dbUrls: dbUrls, filesysUrls: filesysUrls, fileUrlToRepo: fileUrlToRepo, excludedContainerPaths: excludedContainerPaths, indicator: indicator)
        
        if !shouldContinue {
            return
        }
        
        self.logger.log("TRIGGER ON DATA CHANGED EVENT AFTER FINISHED SCANNING REPOSITORIES")
        if indicator != nil {
            indicator?.display(message: Words.filesys_scan_repository_scan_done.word())
            indicator?.dataChanged()
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.filesys_scan_repository_scan_done.word(), increase: false)
        
        if onCompleted != nil {
            onCompleted!()
        }
    }
    
    func createImageIfAbsent(url:String, fileUrlToRepo:[String:ImageContainer], indicator:Accumulator? = nil) -> ExecuteState {
        //self.logger.log("CREATING PHOTO \(url.path)")
        if let repo = fileUrlToRepo[url]{
            self.logger.log(">>> Creating image \(url), repo: \(repo.repositoryPath)")
            let image = ImageFile(url: URL(fileURLWithPath: url),
                                  repository: repo,
                                  indicator: indicator,
                                  quickCreate: true
            )
            
            return image.save()
        }else{
            return .NO_RECORD
        }
    }
    
    // TODO: this procedure keep running in background for a long long time, keep getting and counting db records, need consider performance issue, or need change data structure
    func updateContainers(onCompleted: (() -> Void)? = nil , indicator:Accumulator? = nil) {
        var imageFolders:[ImageFolder] = []
        let exists = RepositoryDao.default.getAllContainers()
        if exists.count > 0 {
            for exist in exists{
                //self.logger.log("Updating image count of container: \(exist.path)")
                let imageFolder = ImageFolder(URL(fileURLWithPath: exist.path),
                                              name: exist.name,
                                              repositoryPath: exist.repositoryPath,
                                              homePath: exist.homePath,
                                              storagePath: exist.storagePath,
                                              facePath: exist.facePath,
                                              cropPath: exist.cropPath,
                                              countOfImages: Int(exist.imageCount)
                )
                imageFolders.append(imageFolder)
                
                let count = ImageCountDao.default.countPhotoFiles(rootPath: "\(imageFolder.url.path)/")
                if let container = imageFolder.containerFolder {
                    if container.imageCount != count {
                        var countChange = ""
                        if container.imageCount > count {
                            countChange = "-\(container.imageCount - count)"
                        }else{
                            countChange = "+\(container.imageCount - count)"
                        }
                        self.logger.log("= changing \(container.imageCount) to \(count)")  // don't delete this comment to avoid crash
                        container.imageCount = count
                        let updateState = RepositoryDao.default.saveImageContainer(container: container)
                        if indicator != nil {
                            if updateState == .OK {
                                self.logger.log("Updated image count [\(container.name) \(countChange) (\(container.parentFolder))]")
                                indicator?.display(message: "Updated [\(container.name) \(countChange) (\(container.parentFolder))]")
                            }else{
                                self.logger.log("[\(updateState)] Failed to update image count [\(container.name) \(countChange) (\(container.parentFolder))]")
                                indicator?.display(message: "Failed to update [\(container.name) \(countChange) (\(container.parentFolder))]")
                            }
                        }
                    }
                }
            }
            //ModelStore.save()
        }
        if onCompleted != nil {
            onCompleted!()
        }
    }
}
