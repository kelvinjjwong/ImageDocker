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
    
    let repositoryDao = RepositoryDao.default
    let deviceDao = DeviceDao.default
    let imageSearchDao = ImageSearchDao.default
    let imageRecordDao = ImageRecordDao.default
    let imageCountDao = ImageCountDao.default
    
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
    
    func scanImageFolderFromDatabase(fast:Bool = true) -> [ImageFolder] {
        let excludedContainerPaths = self.deviceDao.getExcludedImportedContainerPaths()
        
        var imageFolders:[ImageFolder] = [ImageFolder]()
        
        print("\(Date()) Loading containers from db ")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_BEGIN"), object: nil)
        let containers = self.repositoryDao.getAllContainers()
        
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
            //for container in containers { // most high memory impact
                
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
//                            print("continue for Setting up containers' parent, last attempt: \(attempt)")
                            continousWorking = true
                        }
                    }
                }
                
                if continousWorking {
                    autoreleasepool { () -> Void in
                        let container = containers[index]
                        
                        var containerExistInFileSys = false
                        var isDir:ObjCBool = false
                        if FileManager.default.fileExists(atPath: container.path, isDirectory: &isDir) {
                            if isDir.boolValue == true {
                                containerExistInFileSys = true
                            }
                        }
                        if !containerExistInFileSys {
                            print("Container does not exist in FileSys, ignore processing: \(index)/\(jall): \(container.path)")

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
//                                print("[Container DB Scan] Setting parent for container \(index)/\(jall) [\(container.path)]")
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
                                    if container.parentFolder != "" {
                                        if let parentFolder = urlFolders[container.parentFolder] {
                                            imageFolder.setParent(parentFolder)
//                                            print("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "") << FROM CACHE")
                                        }
                                    }else{
                                        if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
                                            imageFolder.setParent(parent)
//                                            print("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
                                            foldersNeedSave.insert(imageFolder)
                                        }
                                    }
                                    
                                }else{
                                    if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
                                        imageFolder.setParent(parent)
//                                        print("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
                                        foldersNeedSave.insert(imageFolder)
                                    }
                                }
                                if let parent = imageFolder.parent {
                                    let subPath = container.path.replacingFirstOccurrence(of: "\(parent.url.path.withStash())", with: "")
                                    imageFolder.name = subPath
                                    
//                                    print("SUB PATH -> \(subPath)")
                                    
                                    if subPath.contains("/") {
                                        let parts = subPath.components(separatedBy: "/")
                                        var midPaths:[String] = []
                                        for part in parts {
                                            if part == "" {continue}
                                            if midPaths.count == 0 {
                                                let midPath = parent.url.appendingPathComponent(part).path
//                                                print("MID FOLDER EXTRACTED FROM SUB PATH: \(midPath)")
                                                midPaths.append(midPath)
                                            }else{
                                                let parentMidPath = midPaths[midPaths.count-1]
                                                let midPath = URL(fileURLWithPath: parentMidPath).appendingPathComponent(part).path
//                                                print("MID FOLDER EXTRACTED FROM SUB PATH: \(midPath)")
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
//                                                print("SET PARENT FOR \(midFolder!.url.path) -> PARENT SET TO \(midFolder!.parent?.url.path ?? "") << CREATED DUMMY")
                                                
                                                // to be added to the whole set
                                                midFolders.append(midFolder!)
                                                
                                                // cache mapping
                                                urlFolders[midPath] = midFolder!
                                            }
                                            parents.append(midFolder!) // for next calculation
                                        }
                                        imageFolder.setParent(parents[parents.count - 1])
//                                        print("SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
                                        imageFolder.name = URL(fileURLWithPath: container.path).lastPathComponent
                                        
                                        imageFolders.append(contentsOf: midFolders)
                                    }
                                }
                                imageFolders.append(imageFolder)
                            } // end of if excluded
                        } // end of if containerExistInFileSys
                        
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
                    var containerExistInFileSys = false
                    var isDir:ObjCBool = false
                    if FileManager.default.fileExists(atPath: imageContainer.path, isDirectory: &isDir) {
                        if isDir.boolValue == true {
                            containerExistInFileSys = true
                        }
                    }
                    if !containerExistInFileSys {
                        print("Container does not exist in FileSys, ignore saving in DB: \(k)/\(kall): \(imageContainer.path)")
                        continue;
                    }
                    
                    let saveState = self.repositoryDao.saveImageContainer(container: imageContainer)
                    if saveState == .OK {
                        print("Saved container into DB \(k)/\(kall): \(imageContainer.path)")
                    }else{
                        print("[\(saveState)] Unable to save container into DB \(k)/\(kall): \(imageContainer.path)")
                    }
                }
            }
            print("\(Date()) Saving containers' parent: DONE ")
        }
        foldersNeedSave.removeAll()
        
//        print("======================")
//        for imgf in imageFolders {
//            print("\(imgf.url.path) -> PARENT -> \(imgf.parent?.url.path ?? "")")
//        }
//        print("======================")
        
        return imageFolders
    }
    
    func scanPhotosToLoadExif(taskId:String = "", indicator:Accumulator? = nil)  {
        if suppressedScan {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return
        }
        
        if TaskletManager.default.isTaskStopped(id: taskId) == true { return }
        
        if indicator != nil {
            DispatchQueue.main.async {
                let _ = indicator?.add("[EXIF Scan] Loading images ...")
            }
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: "[EXIF Scan] Loading images ...", increase: false)
        
        let excludedContainerPaths = self.deviceDao.getExcludedImportedContainerPaths(withStash: true)

        let photos = self.imageSearchDao.getPhotoFilesWithoutExif()
        print("PHOTOS WITHOUT EXIF: \(photos.count)")
        if photos.count > 0 {
            print("\(Date()) UPDATING EXIF: \(photos.count)")
            if indicator != nil {
                indicator?.setTarget(photos.count)
            }

            TaskletManager.default.setTotal(id: taskId, total: photos.count)
            
            for photo in photos {
                
                if suppressedScan {
                    if indicator != nil {
                        indicator?.forceComplete()
                    }
                    return
                }
                
                if TaskletManager.default.isTaskStopped(id: taskId) == true { return }
                
                var exclude = false
                for excludedPath in excludedContainerPaths {
                    if photo.path.hasPrefix(excludedPath) {
                        print("Exclude image (exclude device path): \(photo.path)")
                        exclude = true
                        break
                    }
                }
                if !exclude {
                    let _ = ImageFile(photoFile: photo, indicator: indicator)
                }else{
                    if indicator != nil {
                        DispatchQueue.main.async {
                            let _ = indicator?.add("[EXIF Scan] Loading images ...")
                        }
                    }
                    
                    TaskletManager.default.updateProgress(id: taskId, message: "[EXIF Scan] Loading images ...", increase: true)
                }
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
                                 cropPath:String) -> ImageFolder {
        print("Creating repository with name:\(name) , path:\(path)")
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
                                                                print("`directoryEnumerator` error: \(error).")
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
                print("[FileSys Scan] Getting entry: \(path)")
                
                if indicator != nil {
                    indicator?.display(message: "[FileSys Scan] \(repositoryPath) ...")
                }
                
                TaskletManager.default.updateProgress(id: taskId, message: "[FileSys Scan] \(repositoryPath) ...", increase: false)
                
                result.filesysUrls.insert(path)
                result.fileUrlToRepo[path] = repository
                let folderUrl = transformedURL.deletingLastPathComponent()
                result.foldersysUrls.insert(folderUrl.path)
            }
            catch {
                print("Unexpected error occured: \(error).")
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
            indicator?.display(message: "Scanning repository \(i)/\(totalCount) .....")
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: "Scanning repository \(i)/\(totalCount) .....", increase: false)
        
        var repoExistInFileSys = false
        var isDir:ObjCBool = false
        if FileManager.default.fileExists(atPath: repo.path, isDirectory: &isDir) {
            if isDir.boolValue == true {
                repoExistInFileSys = true
            }
        }
        
        if !repoExistInFileSys {
            print("[Repository Scan] Repository does not exist in FileSys: [\(repo.path)]")
            let deleteState = self.repositoryDao.deleteContainer(path: repo.path, deleteImage: true)
            if deleteState == .OK {
                print("[Repository Scan] Deleted non-exist repository and related images in DB: [\(repo.path)]")
            }else{
                print("[Repository Scan] [\(deleteState)] Unable to delete non-exist repository and related images in DB: [\(repo.path)]")
            }
            return (false, filesysUrls, fileUrlToRepo)// continue
        }
        
        if repo.path.withStash() != repo.repositoryPath.withStash() {
            print("[Repository Scan] Record is not a valid repository: path=[\(repo.path)] , it should belong to repositoryPath=[\(repo.repositoryPath)]")
            return (false, filesysUrls, fileUrlToRepo)// continue
        }
        
        var containers = self.repositoryDao.getAllContainerPaths(repositoryPath: repositoryPath).sorted()
        
//            var pathToDeviceSubFolder:[String:String] = [:]
        if repo.deviceId != "" {
            let devicePaths = self.deviceDao.getDevicePaths(deviceId: repo.deviceId)
            if devicePaths.count > 0 {
                for devicePath in devicePaths {
                    if !devicePath.exclude && !devicePath.excludeImported {
                        let path = URL(fileURLWithPath: repo.path).appendingPathComponent(devicePath.toSubFolder).path
//                            pathToDeviceSubFolder[path] = devicePath.toSubFolder
                        
                        print("[Repository Scan] get or create container for device [id=\(repo.deviceId)] path [\(path)]")
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
                        
                        if let container = folder.containerFolder, container.parentFolder == "" {
                            self.repositoryDao.updateImageContainerParentFolder(path: path, parentFolder: repo.path)
                        }
                        if !containers.contains(path) {
                            containers.append(path)
                        }
                    } // end of if not excluded
                } // end of loop devicePaths
            } // end of if devicePaths.count > 0
        } // end of if repo.deviceid != ""
        
        print("\(Date()) CHECKING REPO \(repo.path)")
        
        print("\(Date()) CHECK REPO: ENUMERATING FILESYS")
        
        autoreleasepool { () -> Void in
            print(">>> WALKING THRU DIRECTORY begin \(i)/\(totalCount) <<<")
            if indicator != nil {
                indicator?.display(message: "Walking thru directory [\(i)/\(totalCount)] [\(repo.name)]")
            }
            
            TaskletManager.default.updateProgress(id: taskId, message: "Walking thru directory [\(i)/\(totalCount)] [\(repo.name)]", increase: false)
                    
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
            print(">>> WALKING THRU DIRECTORY done \(i)/\(totalCount)  <<<")
        }
        
        print("\(Date()) CHECK REPO: ENUMERATING FILESYS: DONE")
        
        print("\(Date()) CHECK REPO: CHECK FOLDERS TO BE ADDED AND REMOVED")
        
        autoreleasepool { () -> Void in
            
            let folderDBUrls = self.repositoryDao.getAllContainerPaths(repositoryPath: repositoryPath)
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
                        print("Exclude container: \(path)")
                    }else{
                        for excludedPath in excludedContainerPaths {
                            if path.hasPrefix(excludedPath.withStash()) {
                                exclude = true
                                print("Exclude container: \(path)")
                                break
                            }
                        }
                    }
                    
                    print("Adding container folder \(k)/\(kall): \(path)")
                    if indicator != nil {
                        indicator?.display(message: "Adding container folder \(k)/\(kall) .....")
                    }
                    
                    TaskletManager.default.updateProgress(id: taskId, message: "Adding container folder \(k)/\(kall) .....", increase: false)
                    
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
                        print("Exclude container: \(path)")
                    }else{
                        for excludedPath in excludedContainerPaths {
                            if path.hasPrefix(excludedPath.withStash()) {
                                exclude = true
                                print("Exclude container: \(path)")
                                break
                            }
                        }
                    }
                    
                    
                    print("Getting parent folder \(j)/\(kall): \(path)")
                    if indicator != nil {
                        indicator?.display(message: "Getting parent folder \(j)/\(kall) .....")
                    }
                    
                    TaskletManager.default.updateProgress(id: taskId, message: "Getting parent folder \(j)/\(kall) .....", increase: false)
                    
                    if !exclude {
                        if let parentFolder = path.getNearestParent(from: containers) {
                            print(">>> parent folder: \(parentFolder)")
                            self.repositoryDao.updateImageContainerParentFolder(path: path, parentFolder: parentFolder)
                            
                            if let parent = self.repositoryDao.getContainer(path: parentFolder), parent.manyChildren == true {
                                self.repositoryDao.updateImageContainerHideByParent(path: path, hideByParent: true)
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
                        let deleteState = self.repositoryDao.deleteContainer(path: path, deleteImage: true)
                        
                        if deleteState == .OK {
                            print("Deleted container and related images from DB: \(path)")
                            if indicator != nil { indicator?.display(message: "Removed non-exist container [\(k)/\(folderUrlsToRemoved.count)]") }
                            
                            TaskletManager.default.updateProgress(id: taskId, message: "Removed non-exist container [\(k)/\(folderUrlsToRemoved.count)]", increase: false)

                        }else{
                            print("[\(deleteState)] Failed to delete container and related images from DB: \(path)")
                            if indicator != nil { indicator?.display(message: "[\(deleteState)] Failed to remove non-exist container [\(k)/\(folderUrlsToRemoved.count)]") }
                            
                            TaskletManager.default.updateProgress(id: taskId, message: "[\(deleteState)] Failed to remove non-exist container [\(k)/\(folderUrlsToRemoved.count)]", increase: false)

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
        print("EXISTING DB PHOTO COUNT = \(dbUrls.count)")
        print("EXISTING SYS PHOTO COUNT = \(filesysUrls.count)")
//        var dbUrls:Set<String> = Set<String>()
//        for exist in exists {
//            let path = exist.path
//            dbUrls.insert(path)
//
//        }
        print("EXISTING DB PHOTO COUNT2 = \(dbUrls.count)")
        
        if dbUrls.count == filesysUrls.count {
            if indicator != nil { indicator?.display(message: "[FileSys Scan] Images have no gap btw FileSys and DB.") }
            
            TaskletManager.default.updateProgress(id: taskId, message: "[FileSys Scan] Images have no gap btw FileSys and DB.", increase: false)
        }else if dbUrls.count < filesysUrls.count {
            let gap = dbUrls.count - filesysUrls.count
            if indicator != nil { indicator?.display(message: "[FileSys Scan] Images in DB[\(dbUrls.count)] less (\(gap)) than in FileSys[\(filesysUrls.count)].") }
            
            TaskletManager.default.updateProgress(id: taskId, message: "[FileSys Scan] Images in DB[\(dbUrls.count)] less (\(gap)) than in FileSys[\(filesysUrls.count)].", increase: false)
        }else if dbUrls.count > filesysUrls.count {
            let gap = dbUrls.count - filesysUrls.count
            if indicator != nil { indicator?.display(message: "[FileSys Scan] Images in DB[\(dbUrls.count)] more (+\(gap) than in FileSys[\(filesysUrls.count)].") }
            
            TaskletManager.default.updateProgress(id: taskId, message: "[FileSys Scan] Images in DB[\(dbUrls.count)] more (+\(gap) than in FileSys[\(filesysUrls.count)].", increase: false)
        }
        
        let urlsToAdd:[String] = filesysUrls.subtracting(dbUrls).sorted()
        let urlsToRemoved:Set<String> = dbUrls.subtracting(filesysUrls)
        
        print("\(Date()) CHECK REPO: CHECK TO BE ADDED AND REMOVED : DONE")
        
        let total = urlsToAdd.count + urlsToRemoved.count
        
        if total == 0 {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return false
        }
        
        if indicator != nil {
            indicator?.display(message: "Ready for add/remove image records...")
            
            TaskletManager.default.updateProgress(id: taskId, message: "Ready for add/remove image records...", increase: false)
        }
        
        if indicator != nil {
            indicator?.setTarget(total)
        }
        
        TaskletManager.default.setTotal(id: taskId, total: total)
        
        print("\(Date()) CHECK REPO: EXECUTE ADD OR REMOVE")
        
        if urlsToAdd.count > 0 {
            print("\(Date()) URLS TO ADD FROM FILESYS: \(urlsToAdd.count)")
//            indicator?.dataChanged()
            
            let limitRam = PreferencesController.peakMemory() * 1024
            var continousWorking = true
            var index = 0
            var attempt = 0
            
            while(index < urlsToAdd.count ){
            //for url in urlsToAdd { // most high memory impact
                
                if suppressedScan {
                    if indicator != nil {
                        indicator?.forceComplete()
                    }
                    return false
                }
                
                if TaskletManager.default.isTaskStopped(id: taskId) == true { return false }
                
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
                        
                        var exclude = false
                        if excludedContainerPaths.contains(url) {
                            print("Exclude image (excluded device path): \(url)")
                            exclude = true
                        }else{
                            for excludedPath in excludedContainerPaths {
                                if url.hasPrefix(excludedPath.withStash()) {
                                    print("Exclude image (excluded device path): \(url)")
                                    exclude = true
                                    break
                                }
                            }
                        }
                        
                        if !exclude {
                            let createState = self.createImageIfAbsent(url: url, fileUrlToRepo: fileUrlToRepo, indicator: indicator)
                            if createState == .OK {
                                DispatchQueue.main.async {
                                    print("Imported images ... (\(index)/\(urlsToAdd.count))")
                                    if indicator != nil { let _ = indicator?.add("Imported images ... (\(index)/\(urlsToAdd.count))") }
                                }
                                
                                TaskletManager.default.updateProgress(id: taskId, message: "Imported images ... (\(index)/\(urlsToAdd.count))", increase: true)
                            }else{
                                DispatchQueue.main.async {
                                    print("[\(createState)] Unable to import images ... (\(index)/\(urlsToAdd.count))")
                                    if indicator != nil { let _ = indicator?.add("[\(createState)] Unable to import images ... (\(index)/\(urlsToAdd.count))") }
                                }
                                
                                TaskletManager.default.updateProgress(id: taskId, message: "[\(createState)] Unable to import images ... (\(index)/\(urlsToAdd.count))", increase: true)
                            }
                        }else{
                        }
                        index += 1
                    }
                }
                
            }
//            if indicator != nil {
//                indicator?.dataChanged()
//            }
            print("\(Date()) URLS TO ADD FROM FILESYS: SAVE DONE")
        } // end of urlsToAdd.count > 0
        
        var k = 0
        if urlsToRemoved.count > 0 {
            print("\(Date()) PHOTOS TO REMOVED FROM DB: \(urlsToRemoved.count)")
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
                
                
                print("Deleting image from DB (delFlag): \(url)")
                let deleteState = self.imageRecordDao.deletePhoto(atPath: url)
                
                if deleteState == .OK {
                    print("Deleted images ... (\(k)/\(urlsToRemoved.count))")
                    if indicator != nil { let _ = indicator?.add("Deleted images ... (\(k)/\(urlsToRemoved.count))") }
                    
                    TaskletManager.default.updateProgress(id: taskId, message: "Deleted images ... (\(k)/\(urlsToRemoved.count))", increase: true)
                }else{
                    print("[\(deleteState)] Unable to delete images ... (\(k)/\(urlsToRemoved.count))")
                    if indicator != nil { let _ = indicator?.add("[\(deleteState)] Unable to delete images ... (\(k)/\(urlsToRemoved.count))") }
                    
                    TaskletManager.default.updateProgress(id: taskId, message: "[\(deleteState)] Unable to delete images ... (\(k)/\(urlsToRemoved.count))", increase: true)
                }
            }
            
//            if indicator != nil {
//                indicator?.dataChanged()
//            }
            //DispatchQueue.main.async {
                //ModelStore.save()
            //}
            print("\(Date()) PHOTOS TO REMOVED FROM DB: SAVE DONE")
        } // end of urlsToRemoved.count > 0
        
        print("\(Date()) CHECK REPO: EXECUTE ADD OR REMOVE: DONE")
        
        return true
    }
    
    func scanSingleRepository_asTask(repository:ImageContainer) {
        let _ = TaskletManager.default.createAndStartTask(type: "IMPORT", name: repository.name
        , exec: { task in
            DispatchQueue.global().async {
                self.scanSingleRepository(repository: repository, taskId: task.id)
            }
        }, stop: {task in
            
        })
    }
    
    // entrance method
    func scanSingleRepository(repository:ImageContainer, taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil) -> Bool {
        
        if indicator != nil {
            indicator?.display(message: "Scanning repository .....")
        }
        
        let excludedContainerPaths = self.deviceDao.getExcludedImportedContainerPaths()
        let (_, repoFileSysUrls, repoFileUrlToRepo) = self.scanRepository(repository: repository, excludedContainerPaths: excludedContainerPaths, step: 1, total: 1, taskId: taskId, indicator: indicator)
        
        print("\(Date()) CHECK REPO: CHECK TO BE ADDED AND REMOVED")
        if indicator != nil {
            indicator?.display(message: "[FileSys Scan] Checking gap between db and filesys .....")
        }
        
        let dbUrls = self.imageSearchDao.getAllPhotoPaths(repositoryPath: repository.repositoryPath)
        let shouldContinue = self.applyImportGap(dbUrls: dbUrls, filesysUrls: repoFileSysUrls, fileUrlToRepo: repoFileUrlToRepo, excludedContainerPaths: excludedContainerPaths, taskId: taskId, indicator: indicator)
        
        if !shouldContinue {
            return false
        }
        
        print("\(Date()) TRIGGER ON DATA CHANGED EVENT AFTER FINISHED SCANNING REPOSITORIES")
        if indicator != nil {
            indicator?.display(message: "[FileSys Scan] Repositories scan done.")
            indicator?.dataChanged()
        }
        if onCompleted != nil {
            onCompleted!()
        }
        return true
    }
    
    // entrance method
    func scanRepositories(indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil)  {
        
        if suppressedScan {
            if indicator != nil {
                indicator?.forceComplete()
            }
            return
        }
        
        if indicator != nil {
            indicator?.display(message: "Loading repositories from database .....")
        }
        
        let repositories = self.repositoryDao.getRepositories()
        print("REPO COUNT = \(repositories.count)")
        
        if indicator != nil {
            indicator?.display(message: "Scanning \(repositories.count) repositories .....")
        }
        
        let excludedContainerPaths = self.deviceDao.getExcludedImportedContainerPaths()
        
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
        
        print("\(Date()) CHECK REPO: CHECK TO BE ADDED AND REMOVED")
        if indicator != nil {
            indicator?.display(message: "[FileSys Scan] Checking gap between db and filesys .....")
        }
        
        let dbUrls = self.imageSearchDao.getAllPhotoPaths()
        let shouldContinue = self.applyImportGap(dbUrls: dbUrls, filesysUrls: filesysUrls, fileUrlToRepo: fileUrlToRepo, excludedContainerPaths: excludedContainerPaths, indicator: indicator)
        
        if !shouldContinue {
            return
        }
        
        print("\(Date()) TRIGGER ON DATA CHANGED EVENT AFTER FINISHED SCANNING REPOSITORIES")
        if indicator != nil {
            indicator?.display(message: "[FileSys Scan] Repositories scan done.")
            indicator?.dataChanged()
        }
        if onCompleted != nil {
            onCompleted!()
        }
    }
    
    func createImageIfAbsent(url:String, fileUrlToRepo:[String:ImageContainer], indicator:Accumulator? = nil) -> ExecuteState {
        //print("CREATING PHOTO \(url.path)")
        if let repo = fileUrlToRepo[url]{
            print(">>> Creating image \(url), repo: \(repo.repositoryPath)")
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
        let exists = self.repositoryDao.getAllContainers()
        if exists.count > 0 {
            for exist in exists{
                //print("Updating image count of container: \(exist.path)")
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
                
                let count = self.imageCountDao.countPhotoFiles(rootPath: "\(imageFolder.url.path)/")
                if var container = imageFolder.containerFolder {
                    if container.imageCount != count {
                        var countChange = ""
                        if container.imageCount > count {
                            countChange = "-\(container.imageCount - count)"
                        }else{
                            countChange = "+\(container.imageCount - count)"
                        }
                        print("= changing \(container.imageCount) to \(count)")  // don't delete this comment to avoid crash
                        container.imageCount = count
                        let updateState = self.repositoryDao.saveImageContainer(container: container)
                        if indicator != nil {
                            if updateState == .OK {
                                print("Updated image count [\(container.name) \(countChange) (\(container.parentFolder))]")
                                indicator?.display(message: "Updated [\(container.name) \(countChange) (\(container.parentFolder))]")
                            }else{
                                print("[\(updateState)] Failed to update image count [\(container.name) \(countChange) (\(container.parentFolder))]")
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
