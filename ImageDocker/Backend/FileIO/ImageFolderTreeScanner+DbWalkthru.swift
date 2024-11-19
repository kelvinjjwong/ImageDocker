//
//  ImageFolderTreeScanner+DbWalkthru.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/14.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation

extension ImageFolderTreeScanner {
    
    
    
    // not used
    func scanImageFolderFromDatabase(fast:Bool = true) -> [ImageFolder] {
        let excludedContainerPaths = DeviceDao.default.getExcludedImportedContainerPaths()
        
        var imageFolders:[ImageFolder] = [ImageFolder]()
        
        self.logger.log(.trace, "Loading containers from db ")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FOLDERSETTER_BEGIN"), object: nil)
        let containers = RepositoryDao.default.getAllContainers()
        
        self.logger.log(.trace, "Setting up containers' parent ")
        
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
                        self.logger.log(.trace, "Container does not exist in FileSys, ignore processing: \(index)/\(jall): \(container.path)")

                    }else{
                    
                        var exclude = false
                        if excludedContainerPaths.contains(container.path) {
                            exclude = true
                        }else{
                            for excludedPath in excludedContainerPaths {
                                if container.path.hasPrefix(excludedPath.withLastStash()) {
                                    exclude = true
                                    break
                                }
                            }
                        }
                    
                        if container.hideByParent || exclude {
                            // do nothing
                        }else{
//                                self.logger.log(.trace, "[Container DB Scan] Setting parent for container \(index)/\(jall) [\(container.path)]")
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
//                                            self.logger.log(.trace, "SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "") << FROM CACHE")
                                    }
                                }else{
                                    if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
                                        imageFolder.setParent(parent)
//                                            self.logger.log(.trace, "SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
                                        foldersNeedSave.insert(imageFolder)
                                    }
                                }
                                
                            }else{
                                if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
                                    imageFolder.setParent(parent)
//                                        self.logger.log(.trace, "SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
                                    foldersNeedSave.insert(imageFolder)
                                }
                            }
                            if let parent = imageFolder.parent {
                                let subPath = container.path.replacingFirstOccurrence(of: parent.url.path.withLastStash(), with: "")
                                imageFolder.name = subPath
                                
//                                    self.logger.log(.trace, "SUB PATH -> \(subPath)")
                                
                                if subPath.contains("/") {
                                    let parts = subPath.components(separatedBy: "/")
                                    var midPaths:[String] = []
                                    for part in parts {
                                        if part == "" {continue}
                                        if midPaths.count == 0 {
                                            let midPath = parent.url.appendingPathComponent(part).path
//                                                self.logger.log(.trace, "MID FOLDER EXTRACTED FROM SUB PATH: \(midPath)")
                                            midPaths.append(midPath)
                                        }else{
                                            let parentMidPath = midPaths[midPaths.count-1]
                                            let midPath = URL(fileURLWithPath: parentMidPath).appendingPathComponent(part).path
//                                                self.logger.log(.trace, "MID FOLDER EXTRACTED FROM SUB PATH: \(midPath)")
                                            midPaths.append(midPath)
                                        }
                                    }
                                    var parents:[ImageFolder] = [parent]
                                    var midFolders:[ImageFolder] = []
                                    for midPath in midPaths {
                                        if midPath.withLastStash() == container.path.withLastStash() {
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
//                                                self.logger.log(.trace, "SET PARENT FOR \(midFolder!.url.path) -> PARENT SET TO \(midFolder!.parent?.url.path ?? "") << CREATED DUMMY")
                                            
                                            // to be added to the whole set
                                            midFolders.append(midFolder!)
                                            
                                            // cache mapping
                                            urlFolders[midPath] = midFolder!
                                        }
                                        parents.append(midFolder!) // for next calculation
                                    }
                                    imageFolder.setParent(parents[parents.count - 1])
//                                        self.logger.log(.trace, "SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
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
//                            self.logger.log(.trace, "waiting for releasing memory for Setting up containers' parent, attempt: \(attempt)")
//                            continousWorking = false
//                            sleep(10)
//                        }else{
////                            self.logger.log(.trace, "continue for Setting up containers' parent, last attempt: \(attempt)")
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
//                            self.logger.log(.trace, "Container does not exist in FileSys, ignore processing: \(index)/\(jall): \(container.path)")
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
////                                self.logger.log(.trace, "[Container DB Scan] Setting parent for container \(index)/\(jall) [\(container.path)]")
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
////                                            self.logger.log(.trace, "SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "") << FROM CACHE")
//                                        }
//                                    }else{
//                                        if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
//                                            imageFolder.setParent(parent)
////                                            self.logger.log(.trace, "SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
//                                            foldersNeedSave.insert(imageFolder)
//                                        }
//                                    }
//
//                                }else{
//                                    if let parent:ImageFolder = imageFolder.getNearestParent(from: imageFolders) { // performance weaker
//                                        imageFolder.setParent(parent)
////                                        self.logger.log(.trace, "SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
//                                        foldersNeedSave.insert(imageFolder)
//                                    }
//                                }
//                                if let parent = imageFolder.parent {
//                                    let subPath = container.path.replacingFirstOccurrence(of: "\(parent.url.path.withStash())", with: "")
//                                    imageFolder.name = subPath
//
////                                    self.logger.log(.trace, "SUB PATH -> \(subPath)")
//
//                                    if subPath.contains("/") {
//                                        let parts = subPath.components(separatedBy: "/")
//                                        var midPaths:[String] = []
//                                        for part in parts {
//                                            if part == "" {continue}
//                                            if midPaths.count == 0 {
//                                                let midPath = parent.url.appendingPathComponent(part).path
////                                                self.logger.log(.trace, "MID FOLDER EXTRACTED FROM SUB PATH: \(midPath)")
//                                                midPaths.append(midPath)
//                                            }else{
//                                                let parentMidPath = midPaths[midPaths.count-1]
//                                                let midPath = URL(fileURLWithPath: parentMidPath).appendingPathComponent(part).path
////                                                self.logger.log(.trace, "MID FOLDER EXTRACTED FROM SUB PATH: \(midPath)")
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
////                                                self.logger.log(.trace, "SET PARENT FOR \(midFolder!.url.path) -> PARENT SET TO \(midFolder!.parent?.url.path ?? "") << CREATED DUMMY")
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
////                                        self.logger.log(.trace, "SET PARENT FOR \(imageFolder.url.path) -> PARENT SET TO \(imageFolder.parent?.url.path ?? "")")
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
        self.logger.log(.trace, "Setting up containers' parent: DONE ")
        
        if foldersNeedSave.count > 0 {
            self.logger.log(.trace, "Saving containers' parent")
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
                        self.logger.log(.trace, "Container does not exist in FileSys, ignore saving in DB: \(k)/\(kall): \(imageContainer.path)")
                        continue;
                    }
                    
                    let saveState = RepositoryDao.default.saveImageContainer(container: imageContainer)
                    if saveState == .OK {
                        self.logger.log(.trace, "Saved container into DB \(k)/\(kall): \(imageContainer.path)")
                    }else{
                        self.logger.log(.trace, "[\(saveState)] Unable to save container into DB \(k)/\(kall): \(imageContainer.path)")
                    }
                }
            }
            self.logger.log(.trace, "Saving containers' parent: DONE ")
        }
        foldersNeedSave.removeAll()
        
//        self.logger.log(.trace, "======================")
//        for imgf in imageFolders {
//            self.logger.log(.trace, "\(imgf.url.path) -> PARENT -> \(imgf.parent?.url.path ?? "")")
//        }
//        self.logger.log(.trace, "======================")
        
        return imageFolders
    }
}
