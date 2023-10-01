//
//  ExportManager.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/18.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class ExportManager {
    
    let logger = LoggerFactory.get(category: "ExportManager")
    
    static let `default` = ExportManager()
    
    //var working:Bool = false
    var suppressed:Bool = false
    var tasks:[String:Bool] = [:]
    var messageBox:NSTextField? = nil
    
    // MARK: - PROCESS HANDLING
    
    func withMessageBox(_ box:NSTextField) -> ExportManager {
        self.messageBox = box
        return self
    }
    
    @objc func enable() {
        self.suppressed = false
        self.printMessage("")
    }
    
    @objc func disable() {
        self.suppressed = true
        self.stopAllTasks()
    }
    
    @objc func stopTask(profileId:String) {
        self.tasks[profileId] = false
        self.printMessage("Task \(profileId) stopped.")
    }
    
    private func stopAllTasks() {
        for (key, _) in self.tasks {
            self.stopTask(profileId: key)
        }
        self.printMessage("All tasks stopped.")
    }
    
    private func startTask(profileId:String) {
        self.tasks[profileId] = true
    }
    
    /**
     If suppressed from outside, stop immediately
     */
    fileprivate func nonStop(profileId:String) -> Bool {
        
        if Setting.database.isSQLite() && self.suppressed {
            self.logger.log("ExportManager is suppressed.")
            TaskManager.exporting = false
            self.stopAllTasks()
            return false
        }else{
            if let state = self.tasks[profileId] {
                if state == false {
                    return false
                }
            }
        }
        return true
    }
    
    fileprivate func printMessage(_ text:String) {
        if self.messageBox != nil {
            DispatchQueue.main.async {
                self.messageBox?.stringValue = text
            }
        }
    }
    
    
    
    // MARK: - EXIF PATCH
    private func patchImageDescription(targetFullFilePath:String, image:Image) {
        let generatedImageDescription = Naming.Export.getNewDescription(image: image)
        ExifTool.helper.patchImageDescription(description: generatedImageDescription, url: URL(fileURLWithPath: targetFullFilePath))

        self.logger.log("Change ImageDescription for image.id: \(image.id) : DONE")
    }
    
    private func patchImageDateTime(image:Image, profile:ExportProfile, targetFilePath:String) {
        // TODO: patch EXIF DATETIME
    }
    
    private func patchImageGeolocation(image:Image, profile:ExportProfile, targetFilePath:String) {
        // TODO: patch EXIF GEOLOCATION
    }
    
    private func generateImageMD5(path:String) -> String {
        let md5 = ComputerFileManager.default.md5(pathOfFile: path)
        return md5
    }
    
    // MARK: - EXPORT PROFILE NOW
    
    private func createDirectory(profile:ExportProfile) -> (Bool, String) {
        let directory = "\(profile.targetVolume)\(profile.directory)"
        var isDir:ObjCBool = false
        if FileManager.default.fileExists(atPath: directory, isDirectory: &isDir) {
            if isDir.boolValue == false {
                return (false, "INACCESSIBLE DIRECTORY \(directory)")
            }
        }else{
            do {
                try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
            }catch{
                return (false, "UNABLE TO CREATE DIRECTORY \(directory)")
            }
            if FileManager.default.fileExists(atPath: directory, isDirectory: &isDir) {
                if isDir.boolValue == false {
                    return (false, "UNABLE TO CREATE DIRECTORY \(directory)")
                }
            }else{
                return (false, "UNABLE TO CREATE DIRECTORY \(directory)")
            }
        }
        return (true, "")
    }
    
    func export(profile:ExportProfile, rehearsal:Bool = false, limit:Int? = nil) -> (Bool, String) {
        guard self.nonStop(profileId: profile.id) && !TaskManager.exporting else {return (false, "PREVENTED")}
        
        let (dirReady, msg) = self.createDirectory(profile: profile)
        if !dirReady {
            return (dirReady, msg)
        }
        
        let triggerTime = Date()
        
        
        //self.logger.log("exporting")
        TaskManager.exporting = true
        self.logger.log("  ")
        self.logger.log("!! ExportManager start working at \(Date())")
        
        self.startTask(profileId: profile.id)
        
        self.logger.log("EXPORT: CHECKING UPDATES AND WHICH NOT EXPORTED")
        
        let totalImagesInDb = ExportDao.default.countImagesForExport(profile: profile)
        
        var total:Int = totalImagesInDb
        let pageSizeMax = 100
        var pageSize:Int = totalImagesInDb
        var pageCount:Int = 1
        
        var lastPageImages = 0
        if let limit = limit {
            total = min(totalImagesInDb, limit)
            pageSize = min(pageSizeMax, limit)
            pageCount = total / pageSize
            if (pageCount * pageSize) < total {
                lastPageImages = total - (pageCount * pageSize)
                pageCount += 1
            }
        }
        
        var i:Int = 0
        var failed:Int = 0
        for pageNumber in 1...pageCount {
            
            guard self.nonStop(profileId: profile.id) else {return (false, "FORCED STOP")}
            
            self.printMessage("Searching images in page \(pageNumber) / \(pageCount)...")
            
            let images = ExportDao.default.getImagesForExport(profile: profile, pageSize: pageSize, pageNumber: pageNumber)
            
            if images.count > 0 {
                var imagesToExport = pageSize
                if pageNumber == pageCount && lastPageImages > 0 {
                    // last page
                    imagesToExport = lastPageImages
                }
                
                for n in 1...imagesToExport {

                    guard self.nonStop(profileId: profile.id) else {return (false, "FORCED STOP")}
                    
                    i += 1
                    
                    self.printMessage("Exporting image ( \(i) / \(total) ) ...")
                    
                    let image = images[n-1]
                    
                    let exportOK = self.exportFile(profile: profile, image: image, triggerTime: triggerTime, rehearsal: rehearsal)
                    
                    if !exportOK {
                        failed += 1
                    }
                    
                }
            }
            
        } // end of while loop
        self.printMessage("Export DONE: \(profile.name)")
        
        TaskManager.exporting = false
        
        return (true, "COMPLETED with \(failed) error.")
    }
    
    // MARK: - EXPORT SINGLE FILE
    
    private func exportFile(profile:ExportProfile, image:Image, triggerTime:Date, rehearsal:Bool = false) -> Bool {
        // invalid date
        if image.photoTakenYear == 0 {
            return false
        }
        
        var imagePath = ""
        if let repository = RepositoryDao.default.getRepository(id: image.repositoryId) {
            imagePath = "\(repository.repositoryVolume)\(repository.repositoryPath)\(image.subPath.withFirstStash())"
        }
        
        let pathUrl = URL(fileURLWithPath: imagePath)
        let fileExt = pathUrl.pathExtension.lowercased()
        
        // invalid file-ext
        if !Naming.FileType.allowed.contains(fileExt){
            return false
        }
        
        // invalid source file
        if imagePath == "" || !FileManager.default.fileExists(atPath: imagePath) {
            self.logger.log("[\(imagePath)] Source image not found in file system")
            return false
        }
        
        // generate target path and filename
        
        let (basePath, subfolder) = Naming.Export.buildExportSubFolder(image: image, profile: profile, triggerTime: triggerTime)
        let targetFilename = Naming.Export.buildExportFilename(image: image, profile: profile, subfolder: subfolder)
        
        let fullTargetPath = URL(fileURLWithPath: basePath).appendingPathComponent(subfolder)
        let fullTargetFilePath = fullTargetPath.appendingPathComponent(targetFilename)
        
        self.logger.log("[\(imagePath)] Will copy file to [\(fullTargetFilePath)]")
        
        if rehearsal {
            self.logger.log("[\(imagePath)] Rehearsal not really copy file.")
            return true
        }
        
        // copy file
        
        var copied = false
        var errorMessage = ""
        autoreleasepool { () -> Void in
            if let imageId = image.id {
                let (exportedSubfolder, exportedFilename) = ExportDao.default.getExportedFilename(imageId: imageId, profileId: profile.id)
                if let exportedSubfolder = exportedSubfolder, let exportedFilename = exportedFilename {
                    
                    let exportedPath = URL(fileURLWithPath: profile.directory).appendingPathComponent(exportedSubfolder).appendingPathComponent(exportedFilename)
                    if FileManager.default.fileExists(atPath: exportedPath.path) {
                        do {
                            try FileManager.default.removeItem(atPath: exportedPath.path)
                        }catch{
                            self.logger.log(.warning, "[\(imagePath)] WARN: Unable to delete previous exported file: \(exportedPath.path)")
                            self.logger.log(.error, error)
                        }
                    }
                }
            }
            if FileManager.default.fileExists(atPath: "\(fullTargetFilePath.path)") {
                self.logger.log("[\(imagePath)] Destination file exists, try delete: \(fullTargetFilePath.path)")
                do {
                    try FileManager.default.removeItem(atPath: "\(fullTargetFilePath.path)")
                }catch{
                    self.logger.log(.warning, "[\(imagePath)] WARN: Unable to delete previous exported file: \(fullTargetFilePath.path)")
                    self.logger.log(.error, error)
                }
            }
            do {
                self.logger.log("[\(imagePath)] Copying file to [\(fullTargetFilePath.path)]")
                try FileManager.default.copyItem(atPath: imagePath, toPath: "\(fullTargetFilePath.path)")
                copied = true
                self.logger.log("[\(imagePath)] Copied file to [\(fullTargetFilePath.path)]")
            }catch {
                self.logger.log(.error, "[\(imagePath)] Unable to copy file to: [\(fullTargetFilePath.path)] ")
                self.logger.log(.error, error)
                copied = false
                errorMessage = error.localizedDescription
            }
        }
        
        if copied {
            // patch EXIF
            if profile.patchDateTime {
                self.patchImageDateTime(image: image, profile: profile, targetFilePath: fullTargetFilePath.path)
            }
            
            if profile.patchGeolocation {
                self.patchImageGeolocation(image: image, profile: profile, targetFilePath: fullTargetFilePath.path)
            }
            
            if profile.patchImageDescription {
                self.patchImageDescription(targetFullFilePath: fullTargetFilePath.path, image: image)
            }
            
            // generate MD5
            let md5 = self.generateImageMD5(path: fullTargetFilePath.path)
            
            self.logger.log("[\(imagePath)] Copy file to [\(fullTargetFilePath.path)] DONE.")
            
            let _ = ExportDao.default.storeImageExportSuccess(imageId: image.id ?? imagePath, profileId: profile.id, repositoryPath: image.repositoryPath, subfolder: subfolder, filename: targetFilename, exportedMD5: md5)
            // TODO handle db interrupt error
            return true
        }else{
            let _ = ExportDao.default.storeImageExportFail(imageId: image.id ?? imagePath, profileId: profile.id, repositoryPath: image.repositoryPath, subfolder: subfolder, filename: targetFilename, failMessage: errorMessage)
            // TODO handle db interrupt error
            
            return false
        }
    }
    
    // MARK: - HOUSE KEEP
    func housekeepFilesNotInExportLog(profile:ExportProfile) {
        self.logger.log("EXPORT: HOUSE KEEP")
        
        self.printMessage("Checking invalid exported files ...")
        
        let exportedFileInfos = ExportDao.default.getExportedImages(profileId: profile.id)
        
        var fileRecords:Set<String> = []
        for info in exportedFileInfos {
            let path = URL(fileURLWithPath: profile.directory).appendingPathComponent(info.1).appendingPathComponent(info.2)
            fileRecords.insert(path.path)
        }
        
        let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: profile.directory),
                                                        includingPropertiesForKeys: [.isDirectoryKey, .isReadableKey, .isWritableKey ],
                                                        options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                            self.logger.log(.error, "directoryEnumerator error at \(url): ", error)
                                                            return true
        })!
        
        var allExportedDirectories:Set<String> = []
        var uselessFiles:Set<String> = []
        for case let file as URL in enumerator {
            guard self.nonStop(profileId: profile.id) else {return}
            do {
                
                // if suppressed from outside, stop immediately
                
                let url = try file.resourceValues(forKeys: [.isDirectoryKey, .isReadableKey, .isWritableKey])
                if url.isWritable! {
                    if !url.isDirectory! {
                        if !fileRecords.contains(file.path) {
                            self.logger.log("found file not in record: \(file.path) , mark to delete")
                            uselessFiles.insert(file.path)
                        }
                    }else {
                        allExportedDirectories.insert("\(file.path)/")
                    }
                }
            }catch{
                self.logger.log(.error, "Error reading url properties for \(file.path)")
                self.logger.log(.error, error)
            }
        }
        
        self.logger.log("Useless exported file count: \(uselessFiles.count)")
        
        self.printMessage("Found invalid exported files: \(uselessFiles.count)")
        
        // delete useless exported files
        if uselessFiles.count > 0 {
            let total = uselessFiles.count
            var i = 0
            for uselessFile in uselessFiles {
                
                // if suppressed from outside, stop immediately
                guard self.nonStop(profileId: profile.id) else {return}
                
                i += 1
                self.printMessage("Deleting invalid exported file ... ( \(i) / \(total) )")
                
                self.logger.log("deleting invalid exported file \(uselessFile)")
                
                do {
                    try FileManager.default.removeItem(atPath: uselessFile)
                }catch {
                    self.logger.log(.error, "Cannot delete invalid exported file \(uselessFile)")
                    self.logger.log(.error, error)
                }
            }
        }
        
        self.printMessage("Checking empty exported folders ...")
        
        for folder in allExportedDirectories {
            guard self.nonStop(profileId: profile.id) else {return}
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: folder)
                if contents.count == 0 {
                    try FileManager.default.removeItem(atPath: folder)
                }
            }catch{
                self.logger.log(.error, "  Cannot delete empty exported folder \(folder)")
                self.logger.log(.error, error)
            }
        }
        
        self.printMessage("")
        
        self.logger.log("EXPORT: HOUSE KEEP: DONE")
    }
    
    
    // check if exported file record should not be exported to file system
    func housekeepNewHiddenImages(profile:ExportProfile) {
        let exportedImages = ExportDao.default.getExportedImages(profileId: profile.id)
        for (imageId, subfolder, filename) in exportedImages {
            var shouldDelete = false
            var shouldDeleteFile = false
            
            // check hidden
            if let image = ImageRecordDao.default.getImage(id: imageId) {
                if image.hidden || image.hiddenByContainer || image.hiddenByRepository {
                    shouldDelete = true
                    shouldDeleteFile = true
                }
            }

            let path = URL(fileURLWithPath: profile.directory).appendingPathComponent(subfolder).appendingPathComponent(filename)
            // check not exist in file system
            if !shouldDelete {
                if !FileManager.default.fileExists(atPath: path.path) {
                    shouldDelete = true
                    shouldDeleteFile = false
                }
            }
            
            // TODO check not in criteria, should delete file and record
            
            // delete ExportLog record
            if shouldDelete {
                let _ = ExportDao.default.deleteExportLog(imageId: imageId, profileId: profile.id)
            }
            
            if shouldDeleteFile {
                do {
                    try FileManager.default.removeItem(atPath: path.path)
                }catch {
                    self.logger.log(.error, "Unable to delete invalid exported file \(path.path)")
                    self.logger.log(.error, error)
                }
            }
        }
    }
    
}

