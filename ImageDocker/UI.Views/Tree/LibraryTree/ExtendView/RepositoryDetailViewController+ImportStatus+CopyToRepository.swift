//
//  RepositoryDetailViewController+ImportStatus+CopyToRepository.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/26.
//  Copyright © 2026 nonamecat. All rights reserved.
//


import Cocoa
import SharedDeviceLib

extension RepositoryDetailViewController {
    
    // currently using
    public func scanImageRepository() {
        self.logger.log(.trace, "scanImageRepository")
        if(self.working) {
            self.logger.log(.error, "Another long task is working.")
            NotificationMessageManager.default.createNotificationMessage(type: "Import for editing", name: self._repositoryName, message: "Another long task is working.")
            return
        }
        self.forceStop = false
        self.working = true
        self.toggleButtons(false)
        self.lblMessage.stringValue = "Re-Scanning folders ..."
        
        logger.log(.debug, "repo path: \(self._repositoryPath)")
//        let (volume, path) = _repositoryPath.getVolumeFromThisPath()
        
        
        if let imageRepository = RepositoryDao.default.getRepository(id: self._repositoryId) {
            let volume = imageRepository.repositoryVolume
            let path = imageRepository.repositoryPath
            logger.log(.debug, "DB record found for ImageRepository: id=\(imageRepository.id), name=\(imageRepository.name), volume=\(volume), path=\(path)")
            
            let _ = TaskletManager.default.createAndStartTask(type: "Re-Scan repository", name: "\(imageRepository.name)"
                                                              , exec: { task in
                
                
                TaskletManager.default.updateProgress(id: task.id, message: "Re-Scanning folders ...", increase: false)
                
                DispatchQueue.global().async {
                    
                    // MARK: ImageRepository linked with an ImageContainer
                    
                    if let repositoryLinkedContainer = RepositoryDao.default.findContainer(repositoryId: imageRepository.id, subPath: "") {
                        self.logger.log(.trace, "ImageRepository linked with an ImageContainer, repositoryId:\(imageRepository.id), containerId:\(repositoryLinkedContainer.id)")
                    }else{
                        self.logger.log(.error, "Unable to find ImageRepository's linked ImageContainer record in database, repositoryId:\(imageRepository.id)")
                        if let createdLinkedContainer = RepositoryDao.default.createEmptyImageContainerLinkToRepository(repositoryId: imageRepository.id) {
                            self.logger.log(.info, "Created an empty ImageContainer linking to ImageRepository, repositoryId:\(imageRepository.id), containerId:\(createdLinkedContainer.id)")
                        }else{
                            self.logger.log(.error, "Unable to create an empty ImageContainer linking to ImageRepository, repositoryId:\(imageRepository.id)")
                            DispatchQueue.main.async {
                                self.working = false
                                self.toggleButtons(true)
                                self.lblMessage.stringValue = "Database error: Unable to create an empty ImageContainer linking to this repository."
                            }
                            return
                        }
                    }
                    
                    if TaskletManager.default.isTaskStopped(id: task.id) == true {
                        DispatchQueue.main.async {
                            self.working = false
                            self.toggleButtons(true)
                            self.lblMessage.stringValue = "User stopped task: re-scan folders."
                        }
                        return
                    }
                    
                    // MARK: - loop folder directory
                    
                    self.logger.log(.debug, "Scanning: \(URL(fileURLWithPath: "\(volume)\(path)"))")
                    
                    let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
                    let resourceValueKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.typeIdentifierKey, URLResourceKey.isDirectoryKey]
                    if let directoryEnumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: "\(volume)\(path)"),
                                                                                includingPropertiesForKeys: resourceValueKeys,
                                                                                options: options,
                                                                                errorHandler: { url, error in
                        self.logger.log(.error, "`directoryEnumerator` error: \(error).")
                        self.forceStop = false
                        self.working = false
                        self.toggleButtons(true)
                        return true
                    }) {
                        var urls:[NSURL] = []
                        let startTime_loopUrls = Date()
                        for case let url as NSURL in directoryEnumerator {
                            urls.append(url)
                        }
                        let total = urls.count
                        TaskletManager.default.setTotal(id: task.id, total: total)
                        self.logger.timecost("[ReScanFolders][loopUrls]", fromDate: startTime_loopUrls)
                        self.logger.log(.debug, "total urls: \(total)")
                        
                        DispatchQueue.main.async {
                            self.accumulator = Accumulator(target: total, indicator: self.indProgress, suspended: false, lblMessage: self.lblMessage)
                        }
                        
                        var z = 0
                        var currentContainer:ImageContainer? = nil
                        for case let url in urls {
                            if let urlPath = url.path {
                                z += 1
                                
                                guard (!self.forceStop) && (TaskletManager.default.isTaskStopped(id: task.id) == false) else {
                                    self.logger.log(.info, "[onReScanFoldersClicked] for-loop terminated as user clicked stop button.")
                                    DispatchQueue.main.async {
                                        self.accumulator?.forceComplete()
                                    }
                                    break
                                }
                                
                                // MARK: define subPath
                                
                                self.logger.log(.debug, "Found urlPath: \(urlPath)")
                                self.logger.log(.debug, "Reusing repository: id=\(imageRepository.id), volume=\(imageRepository.repositoryVolume), repositoryPath=\(imageRepository.repositoryPath)")
                                self.logger.log(.debug, "Real physcial volume path: \(imageRepository.repositoryVolume.getPathOfSoftlink() )")
                                
                                let repositoryBasePath = "\(imageRepository.repositoryVolume.getPathOfSoftlink().0)\(imageRepository.repositoryPath.withFirstStash())"
                                
                                self.logger.log(.debug, "Repository base path: \(repositoryBasePath)")
                                
                                let subPath = urlPath.replacingFirstOccurrence(of: repositoryBasePath, with: "").removeFirstStash().removeLastStash()
                                
                                self.logger.log(.debug, "Found subPath: \(subPath)")
                                
                                DispatchQueue.main.async {
                                    let _ = self.accumulator?.add("Found: \(subPath)")
                                }
                                TaskletManager.default.updateProgress(id: task.id, message: "Found: \(subPath) (\(z)/\(task.total))", increase: true)
                                
                                do {
                                    let resourceValues = try url.resourceValues(forKeys: resourceValueKeys)
                                    if let isDirectory = resourceValues[URLResourceKey.isDirectoryKey] as? NSNumber {
                                        if isDirectory.boolValue {
                                            self.logger.log(.debug, "Importing subPath [\(subPath)] into repository id [\(self._repositoryId)], it is a folder")
                                            
                                            // find parent container of current container
                                            let folderName = subPath.lastPartOfUrl()
                                            
                                            let parentSubPath = subPath.parentPath()
                                            self.logger.log(.debug, "Folder subPath [\(subPath)]'s parentSubPath is [\(parentSubPath)] in repository id \(self._repositoryId)")
                                            
                                            // MARK: define parentId
                                            
                                            var parentId = 0
                                            if let parentContainer = RepositoryDao.default.findContainer(repositoryId: self._repositoryId, subPath: parentSubPath) {
                                                parentId = parentContainer.id
                                            }
                                            self.logger.log(.debug, "Folder subPath [\(subPath)]'s parentSubPath is [\(parentSubPath)] in repository id \(self._repositoryId), its container.id is \(parentId)")

                                            
                                            // ensure parentId != 0
                                            if parentId == 0 { // FIXME: maybe top level folder
                                                self.logger.log(.error, "Cannot find matching parent ImageContainer with parentSubPath [\(parentSubPath)] in repository id [\(self._repositoryId)], ignore import this folder [\(subPath)]")
                                                fatalError("check above SQL with parameter")
                                                break
                                            }
                                            
                                            // if image container record exist in database
                                            self.logger.log(.info, "Check if exist ImageContainer with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                            if let existingContainerInDB = RepositoryDao.default.findContainer(repositoryId: self._repositoryId, subPath: subPath) {
                                                
                                                self.logger.log(.info, "Exist ImageContainer with subPath [\(subPath)] in repository id [\(self._repositoryId)], its container.id is \(existingContainerInDB.id)")
                                                
                                                // update repositoryId if repositoryId=0
                                                if existingContainerInDB.repositoryId == 0 {
                                                    let executeState_updateRepoId = RepositoryDao.default.updateImageContainerWithRepositoryId(containerId: existingContainerInDB.id, repositoryId: imageRepository.id)
                                                    if executeState_updateRepoId == .OK {
                                                        self.logger.log(.trace, "Updated ImageContainer.repositoryId, containerId=\(existingContainerInDB.id), repositoryId=\(imageRepository.id)")
                                                    }else{
                                                        self.logger.log(.error, "Unable to update ImageContainer.repositoryId, containerId=\(existingContainerInDB.id), repositoryId=\(imageRepository.id)")
                                                    }
                                                    existingContainerInDB.repositoryId = imageRepository.id
                                                }
                                                
                                                // update parentId if parentId not matched
                                                if existingContainerInDB.parentId != parentId {
                                                    let executeState_updateParentId = RepositoryDao.default.updateImageContainerWithParentId(containerId: existingContainerInDB.id, parentId: parentId)
                                                    if executeState_updateParentId == .OK {
                                                        self.logger.log(.trace, "Updated ImageContainer.parentId, containerId=\(existingContainerInDB.id), parentId=\(parentId)")
                                                    }else{
                                                        self.logger.log(.error, "Unable to update ImageContainer.parentId, containerId=\(existingContainerInDB.id), parentId=\(parentId)")
                                                    }
                                                    existingContainerInDB.parentId = parentId
                                                }
                                                
                                                currentContainer = existingContainerInDB
                                                self.logger.log(.debug, "Found ImageContainer id [\(existingContainerInDB.id)] for subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                            }
                                            else{ // if image container record does not exist in database
                                                
                                                self.logger.log(.info, "Not exist ImageContainer with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                
                                                // MARK: create ImageContainer
                                                
                                                // FIXME: repositoryPath should be delete
                                                if let createdContainer = RepositoryDao.default.createContainer(name: folderName,
                                                                                                                repositoryId: self._repositoryId,
                                                                                                                parentId: parentId,
                                                                                                                subPath: subPath,
                                                                                                                repositoryPath: "\(self._repositoryPath)") {
                                                    self.logger.log(.info, "Created ImageContainer id=\(createdContainer.id), parentId=\(createdContainer.parentId), repositoryId=\(self._repositoryId), subPath=\(subPath), path=\(createdContainer.path)")
                                                    currentContainer = createdContainer
                                                }else{
                                                    self.logger.log(.error, "Cannot create ImageContainer DB record, subPath=\(subPath)")
                                                }
                                            }
                                        }else{
                                            self.logger.log(.trace, "Importing subPath [\(subPath)] into repository id [\(self._repositoryId)], it is a file")
                                            if let currentContainer = currentContainer {
                                                
                                                var currentImage:Image? = nil
                                                
                                                var importedImageId = ""
                                                
                                                // check if Image exist
                                                self.logger.log(.info, "Check if exist Image with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                if let existingImageInDB = ImageRecordDao.default.findImage(repositoryId: self._repositoryId, subPath: subPath) {
                                                    
                                                    self.logger.log(.info, "Exist Image with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                    
                                                    // maintenance if imageId is null or imageId == ""
                                                    if let imageId = existingImageInDB.id, imageId != "" {
                                                        
                                                    }else{
                                                        self.logger.log(.warning, "Image.id is nil, try to generate UUID, subPath=\(subPath), repositoryId=\(self._repositoryId)")
                                                        let (executeState_generateId, imageId) = ImageRecordDao.default.generateImageIdByRepositoryIdAndSubPath(repositoryId: self._repositoryId, subPath: subPath)
                                                        
                                                        if executeState_generateId == .OK {
                                                            existingImageInDB.id = imageId
                                                            self.logger.log(.info, "Image.id is updated with generated UUID \(imageId), subPath=\(subPath), repositoryId=\(self._repositoryId)")
                                                        }else{
                                                            self.logger.log(.error, "Cannot update Image.id with generated UUID, subPath=\(subPath), repositoryId=\(self._repositoryId)")
                                                        }
                                                    }
                                                    
                                                    // maintenance image record with incorrect repositoryId and/or incorrect containerId
                                                    if let imageId = existingImageInDB.id, imageId != "" {
                                                        
                                                        if existingImageInDB.repositoryId != self._repositoryId || existingImageInDB.containerId != currentContainer.id {
                                                            self.logger.log(.info, "To update Image id=\(imageId) to container id=\(currentContainer.id) and repository id=\(self._repositoryId), subPath=\(subPath)")
                                                            let executeState = ImageRecordDao.default.updateImageWithContainerId(id: imageId, repositoryId: self._repositoryId, containerId: currentContainer.id)
                                                            if executeState != .OK {
                                                                self.logger.log(.error, "Failed to update Image with repositoryId=\(self._repositoryId), containerId=\(currentContainer.id), imageId=\(imageId), subPath=\(subPath): ExecuteState=\(executeState)")
                                                            }else{
                                                                self.logger.log(.info, "Updated Image id=\(imageId) to container id=\(currentContainer.id) and repository id=\(self._repositoryId), subPath=\(subPath)")
                                                            }
                                                        }
                                                    }
                                                    
                                                    importedImageId = existingImageInDB.id ?? ""
                                                    currentImage = existingImageInDB
                                                    
                                                }else{
                                                    
                                                    self.logger.log(.info, "Not exist Image with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                    
                                                    self.logger.log(.info, "To create Image to container id=\(currentContainer.id) and repository id=\(self._repositoryId), subPath=\(subPath)")
                                                    
                                                    // FIXME: repositoryVolume and repositoryPath should be delete
                                                    if let createdImage = ImageRecordDao.default.createImage(repositoryId: self._repositoryId,
                                                                                                             containerId: currentContainer.id,
                                                                                                             repositoryVolume: imageRepository.repositoryVolume,
                                                                                                             repositoryPath: imageRepository.repositoryPath,
                                                                                                             subPath: subPath) {
                                                        self.logger.log(.info, "Created Image id=\(createdImage.id ?? ""), repositoryId=\(imageRepository.id), containerId=\(currentContainer.id), subPath=\(subPath), path=\(createdImage.path)")
                                                        
                                                        importedImageId = createdImage.id ?? ""
                                                        currentImage = createdImage
                                                    }else{
                                                        self.logger.log(.error, "Cannot create Image with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                    }
                                                }
                                                
                                                // link imageId to ImageDeviceFile, Image.subPath == ImageDeviceFile.localFilePath
                                                // update Image.originalMD5, deviceId, deviceFileId, Image.originalMD5 == ImageDeviceFile.fileMD5
                                                if let imageDeviceFile = DeviceDao.default.getDeviceFile(repositoryId: self._repositoryId, localFilePath: subPath.removeFirstStash()) {
                                                    if imageDeviceFile.importedImageId == "" && importedImageId != "" {
                                                        
                                                        self.logger.log(.trace, "Update ImageDeviceFile importedImageId:\(importedImageId), repositoryId:\(self._repositoryId), subPath:\(subPath.removeFirstStash())")
                                                        let _ = DeviceDao.default.updateDeviceFileWithImageId(importedImageId: importedImageId,
                                                                                                              repositoryId: self._repositoryId,
                                                                                                              subPath: subPath.removeFirstStash())
                                                        
                                                        self.logger.log(.trace, "Update Image originalMD5:\(imageDeviceFile.fileMD5), deviceId:\(imageDeviceFile.deviceId), deviceFileId:\(imageDeviceFile.fileId), repositoryId:\(self._repositoryId), subPath:\(subPath.removeFirstStash())")
                                                        if imageDeviceFile.fileMD5 ?? "" != "" && imageDeviceFile.deviceId ?? "" != "" && imageDeviceFile.fileId ?? "" != "" {
                                                            if let importedImage = currentImage {
                                                                if importedImage.originalMD5 ?? "" == "" || importedImage.deviceId == "" || importedImage.deviceFileId == "" {
                                                                    
                                                                    let _ = ImageRecordDao.default.updateImageMd5AndDeviceFileId(id: importedImageId,
                                                                                                                                 md5: imageDeviceFile.fileMD5 ?? "",
                                                                                                                                 deviceId: imageDeviceFile.deviceId ?? "",
                                                                                                                                 deviceFileId: imageDeviceFile.fileId ?? "")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                            }else{
                                                // should not happen
                                                self.logger.log(.error, "No container id able to link to this file with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                            }
                                        } // if it's folder or file
                                    } // if it's folder or file
                                }catch {
                                    self.logger.log(.error, "Unexpected error occured when handling subPath: \(subPath) in repository id \(self._repositoryId)", error)
                                }
                            } // end of if let urlPath
                        } // end of for-loop
                        
                        
                        DispatchQueue.main.async {
                            self.working = false
                            self.toggleButtons(true)
                            if(self.forceStop) {
                                self.lblMessage.stringValue = "Re-Scan folders is stopped by user."
                            }else{
                                self.lblMessage.stringValue = "Re-Scan folders completed."
                            }
                            self.forceStop = false
                        }
                    } // end of if let directoryEnumerator
                    else{
                        DispatchQueue.main.async {
                            self.forceStop = false
                            self.working = false
                            self.toggleButtons(true)
                            self.lblMessage.stringValue = "Re-Scan folders encounter problem. Volume may be lost, or folder may be moved."
                        }
                    }
                } // end of DispatchQueue.global.async
            }, stop: {task in
                
            })
        }else{
            self.logger.log(.error, "DB record not found for ImageRepository with id: \(self._repositoryId)")
            self.forceStop = false
            self.working = false
            self.toggleButtons(true)
        }
    }
}
