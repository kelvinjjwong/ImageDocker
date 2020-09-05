//
//  ExportManager.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/18.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class ExportManager {
    
    static let `default` = ExportManager()
    
    //var working:Bool = false
    var suppressed:Bool = false
    var messageBox:NSTextField? = nil
    
    // MARK: - PROCESS HANDLING
    
    func withMessageBox(_ box:NSTextField) -> ExportManager {
        self.messageBox = box
        return self
    }
    
    @objc func enable() {
        self.suppressed = false
        
        if self.messageBox != nil {
            DispatchQueue.main.async {
                self.messageBox?.stringValue = ""
            }
        }
    }
    
    @objc func disable() {
        self.suppressed = true
        if self.messageBox != nil {
            DispatchQueue.main.async {
                self.messageBox?.stringValue = ""
            }
        }
    }
    
    /**
     If suppressed from outside, stop immediately
     */
    fileprivate func nonStop() -> Bool {
        if self.suppressed {
            print("ExportManager is suppressed.")
            TaskManager.exporting = false
            DispatchQueue.main.async {
                self.messageBox?.stringValue = ""
            }
            return false
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

        print("\(Date()) Change ImageDescription for \(image.path) : DONE")
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
    
    func export(profile:ExportProfile, rehearsal:Bool = false, limit:Int? = nil) -> (Bool, String) {
        guard self.nonStop() && !TaskManager.exporting else {return (false, "PREVENTED")}
        
        var isDir:ObjCBool = false
        if FileManager.default.fileExists(atPath: profile.directory, isDirectory: &isDir) {
            if isDir.boolValue == false {
                return (false, "INACCESSIBLE DIRECTORY")
            }
        }else{
            return (false, "INACCESSIBLE DIRECTORY")
        }
        
        let triggerTime = Date()
        
        
        //print("exporting")
        TaskManager.exporting = true
        print("  ")
        print("!! ExportManager start working at \(Date())")
        
        
        //var filepaths:[String] = []
        
        // check exported
        self.printMessage("Validating ...")
        
        // check updates and which not exported
        self.printMessage("Searching for updates ...")
        
        print("\(Date()) EXPORT: CHECKING UPDATES AND WHICH NOT EXPORTED")
        
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
        for pageNumber in 1...pageCount {
            
            guard self.nonStop() else {return (false, "FORCED STOP")}
            
            self.printMessage("Searching images in page \(pageNumber) / \(pageCount)...")
            
            let images = ExportDao.default.getImagesForExport(profile: profile, pageSize: pageSize, pageNumber: pageNumber)
            
            if images.count > 0 {
                var imagesToExport = pageSize
                if pageNumber == pageCount {
                    // last page
                    imagesToExport = lastPageImages
                }
                
                for n in 1...imagesToExport {

                    guard self.nonStop() else {return (false, "FORCED STOP")}
                    
                    i += 1
                    
                    self.printMessage("Exporting image ( \(i) / \(total) ) ...")
                    
                    let image = images[n]
                    
                    let _ = self.exportFile(profile: profile, image: image, triggerTime: triggerTime, rehearsal: rehearsal)
                    
                }
            }
            
        } // end of while loop
        self.printMessage("Export DONE: \(profile.name)")
        
        TaskManager.exporting = false
        
        return (true, "COMPLETED")
    }
    
    // MARK: - EXPORT SINGLE FILE
    
    private func exportFile(profile:ExportProfile, image:Image, triggerTime:Date, rehearsal:Bool = false) -> Bool {
        // invalid date
        if image.photoTakenYear == 0 {
            return false
        }
        
        let pathUrl = URL(fileURLWithPath: image.path)
        let fileExt = pathUrl.pathExtension.lowercased()
        
        // invalid file-ext
        if !Naming.FileType.allowed.contains(fileExt){
            return false
        }
        
        // invalid source file
        if !FileManager.default.fileExists(atPath: image.path) {
            print("Source image not found in file system: \(image.path)")
            return false
        }
        
        // generate target path and filename
        
        let (basePath, subfolder) = Naming.Export.buildExportSubFolder(image: image, profile: profile, triggerTime: triggerTime)
        let targetFilename = Naming.Export.buildExportFilename(image: image, profile: profile, subfolder: subfolder)
        
        let fullTargetPath = URL(fileURLWithPath: basePath).appendingPathComponent(subfolder)
        let fullTargetFilePath = fullTargetPath.appendingPathComponent(targetFilename)
        
        print("\(Date()) Copy file [\(image.path)] to [\(fullTargetFilePath)]")
        
        if rehearsal {
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
                            print("WARN: Unable to delete previous exported file: \(exportedPath.path)")
                            print(error)
                        }
                    }
                }
            }
            do {
                try FileManager.default.copyItem(atPath: image.path, toPath: "\(fullTargetFilePath)")
                copied = true
            }catch {
                print("Unable to copy from: [\(image.path)] to: [\(fullTargetFilePath)] ")
                print(error)
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
            
            print("\(Date()) Copy file [\(image.path)] to [\(fullTargetFilePath)] DONE.")
            
            let _ = ExportDao.default.storeImageExportSuccess(imageId: image.id ?? image.path, profileId: profile.id, repositoryPath: image.repositoryPath, subfolder: subfolder, filename: targetFilename, exportedMD5: md5)
            // TODO handle db interrupt error
            return true
        }else{
            let _ = ExportDao.default.storeImageExportFail(imageId: image.id ?? image.path, profileId: profile.id, repositoryPath: image.repositoryPath, subfolder: subfolder, filename: targetFilename, failMessage: errorMessage)
            // TODO handle db interrupt error
            
            return false
        }
    }
    
    // MARK: - HOUSE KEEP
    func housekeepFilesNotInExportLog(profile:ExportProfile) {
        print("\(Date()) EXPORT: HOUSE KEEP")
        
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
                                                            print("directoryEnumerator error at \(url): ", error)
                                                            return true
        })!
        
        var allExportedDirectories:Set<String> = []
        var uselessFiles:Set<String> = []
        for case let file as URL in enumerator {
            guard self.nonStop() else {return}
            do {
                
                // if suppressed from outside, stop immediately
                
                let url = try file.resourceValues(forKeys: [.isDirectoryKey, .isReadableKey, .isWritableKey])
                if url.isWritable! {
                    if !url.isDirectory! {
                        if !fileRecords.contains(file.path) {
                            print("found file not in record: \(file.path) , mark to delete")
                            uselessFiles.insert(file.path)
                        }
                    }else {
                        allExportedDirectories.insert("\(file.path)/")
                    }
                }
            }catch{
                print("Error reading url properties for \(file.path)")
                print(error)
            }
        }
        
        print("Useless exported file count: \(uselessFiles.count)")
        
        self.printMessage("Found invalid exported files: \(uselessFiles.count)")
        
        // delete useless exported files
        if uselessFiles.count > 0 {
            let total = uselessFiles.count
            var i = 0
            for uselessFile in uselessFiles {
                
                // if suppressed from outside, stop immediately
                guard self.nonStop() else {return}
                
                i += 1
                self.printMessage("Deleting invalid exported file ... ( \(i) / \(total) )")
                
                print("deleting invalid exported file \(uselessFile)")
                
                do {
                    try FileManager.default.removeItem(atPath: uselessFile)
                }catch {
                    print("Cannot delete invalid exported file \(uselessFile)")
                    print(error)
                }
            }
        }
        
        self.printMessage("Checking empty exported folders ...")
        
        for folder in allExportedDirectories {
            guard self.nonStop() else {return}
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: folder)
                if contents.count == 0 {
                    try FileManager.default.removeItem(atPath: folder)
                }
            }catch{
                print("  Cannot delete empty exported folder \(folder)")
                print(error)
            }
        }
        
        self.printMessage("")
        
        print("\(Date()) EXPORT: HOUSE KEEP: DONE")
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
                    print("Unable to delete invalid exported file \(path.path)")
                    print(error)
                }
            }
        }
    }
    
}

