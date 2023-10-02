//
//  ImageFolderScanner.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/5.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
//import GRDB
import LoggerFactory

class DirectoryPaths : NSObject {
    var filesysUrls:Set<String> = Set<String>()
    var fileUrlToRepo:[String:ImageContainer] = [:]
    var foldersysUrls:Set<String> = Set<String>()
}

class ImageFolderTreeScanner {
    
    let logger = LoggerFactory.get(category: "ImageFolderTreeScanner", includeTypes: [.debug, .trace])
    
    static let `default` = ImageFolderTreeScanner()
    var suppressedScan:Bool = false
    
    // MARK: SHARED SCANNER new
    /// - Tag: ImageFolderTreeScanner.scanRepository(ImageRepository)
    func scanRepository(repository:ImageRepository) {
        
    }
    
    // MARK: SHARED SCANNER old
    /// - caller:
    ///   - ImageFolderTreeScanner.[scanSingleRepository(ImageContainer,taskId)](x-source-tag://ImageFolderTreeScanner.scanSingleRepository(ImageContainer,taskId))
    /// - Tag: ImageFolderTreeScanner.scanRepository(ImageContainer)
    fileprivate func scanRepository(repository repo:ImageContainer, excludedContainerPaths:Set<String>, step i:Int, total totalCount:Int, taskId:String = "", indicator:Accumulator? = nil) -> (Bool, Set<String>, [String:ImageContainer]) {
        
        // for return:
        var filesysUrls:Set<String> = Set<String>()
        var fileUrlToRepo:[String:ImageContainer] = [:]
        
        // for local use:
        var foldersysUrls:Set<String> = Set<String>()
        let repositoryPath = repo.path.withLastStash()
        
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
        
        var repoExistInFileSys = repo.path.isDirectoryExists()
        
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
        
        if repo.path.withLastStash() != repo.repositoryPath.withLastStash() {
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
                        
                        if let container = RepositoryDao.default.getContainer(path: path) {
                            if container.path == repo.path {
                                print("[REPOSITORY] Setting a ROOT repository: \(path)")
                                let _ = RepositoryDao.default.updateImageContainerParentFolder(path: path, parentFolder: "")
                            }else{
                                print("[REPOSITORY] Binding a SUB container to repository: \(path) ==> \(repo.path)")
                                let _ = RepositoryDao.default.updateImageContainerParentFolder(path: path, parentFolder: repo.path)
                            }
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
                            if path.hasPrefix(excludedPath.withLastStash()) {
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
                            if path.hasPrefix(excludedPath.withLastStash()) {
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
                        if let parentFolder = path.getNearestParent(from: containers) { //FIXME: deprecate
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
    
    // MARK: HANDLE GAP
    // TODO: deprecate this function
    /// - caller: NONE
    ///   - ImageFolderTreeScanner.[scanSingleRepository(ImageContainer,taskId)](x-source-tag://ImageFolderTreeScanner.scanSingleRepository(ImageContainer,taskId))
    /// - Tag: applyImportGap(dbUrls,filesysUrls,fileUrlToRepo)
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
                        if url.hasPrefix(excludedPath.withLastStash()) {
                            self.logger.log("Exclude image (excluded device path): \(url)")
                            exclude = true
                            break
                        }
                    }
                }
                
                if !exclude {
                    let createState = ImageRecordDao.default.createImageIfAbsent(url: url, fileUrlToRepo: fileUrlToRepo, indicator: indicator)
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
    
    // MARK: TASK - SCAN SINGLE REPO
    /// - caller:
    ///   - RepositoryDetailViewController.[onImportClicked()](x-source-tag://RepositoryDetailViewController.onImportClicked())
    /// - Tag: ImageFolderTreeScanner.scanSingleRepository_asTask(ImageContainer)
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
    
    // MARK: ENTRY - SCAN SINGLE REPO
    // FIXME: use "Re-Scan repository" function instead
    // TODO: deprecate "import-gap"
    ///
    /// Scan a repository, discover not-recorded image files, create Image record in database accordingly;
    /// discover recorded-but-deleted files/folders, delete them from database accordingly
    ///
    /// - caller:
    ///   - ImageFolderTreeScanner.[scanSingleRepository_asTask(ImageContainer,taskId)](x-source-tag://ImageFolderTreeScanner.scanSingleRepository_asTask(ImageContainer))
    /// - version: should be replaced by [RepositoryDetailViewController.onReScanFoldersClicked()](x-source-tag://RepositoryDetailViewController.onReScanFoldersClicked())
    /// - Tag: ImageFolderTreeScanner.scanSingleRepository(ImageContainer,taskId)
    func scanSingleRepository(repository:ImageContainer, taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil) -> Bool {
        
        if TaskletManager.default.isTaskStopped(id: taskId) == true { return false }
        
        if indicator != nil { indicator?.display(message: Words.scanning_repository.word()) }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.scanning_repository.word(), increase: false)
        
        let excludedContainerPaths = DeviceDao.default.getExcludedImportedContainerPaths()
        let (_, repoFileSysUrls, repoFileUrlToRepo) = self.scanRepository(repository: repository, excludedContainerPaths: excludedContainerPaths, step: 1, total: 1, taskId: taskId, indicator: indicator)
        
//        self.logger.log("CHECK REPO: CHECK TO BE ADDED AND REMOVED")
//        if indicator != nil { indicator?.display(message: Words.checking_gap_between_db_and_filesys.word()) }
//
//        TaskletManager.default.updateProgress(id: taskId, message: Words.filesys_scan_loading_all_images_from_db.word(), increase: false)
//
//        let dbUrls = ImageSearchDao.default.getAllPhotoPaths(repositoryPath: repository.repositoryPath)
//
//        TaskletManager.default.updateProgress(id: taskId, message: Words.checking_gap_between_db_and_filesys.word(), increase: false)
//
//        let shouldContinue = self.applyImportGap(dbUrls: dbUrls, filesysUrls: repoFileSysUrls, fileUrlToRepo: repoFileUrlToRepo, excludedContainerPaths: excludedContainerPaths, taskId: taskId, indicator: indicator)
//
//        if !shouldContinue {
//            return false
//        }
        
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
    
}
