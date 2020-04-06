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
    
    fileprivate func getExportedFilenames() -> Set<String> {
        let allExportedImagesStored = ImageSearchDao.default.getAllExportedImages(includeHidden: false)
        var allExportedFilenames:Set<String> = []
        for image in allExportedImagesStored {
            let path = "\(image.exportToPath ?? "")/\(image.exportAsFilename ?? "")"
            let fileUrl = URL(fileURLWithPath: path) // maybe contains symbol links
            let resolvedPath = fileUrl.resolvingSymlinksInPath().path
            if !FileManager.default.fileExists(atPath: fileUrl.path) {
                // no longer exists exported file, clean exported fields in database
                ImageExportDao.default.cleanImageExportPath(path: image.path)
            }else{
                allExportedFilenames.insert(resolvedPath) // transform to non symbol link physical path
            }
        }
        return allExportedFilenames
    }
    
    fileprivate func checkIfExportedFilesExist() {
        self.printMessage("Loading exported files for validation ...")
        print("\(Date()) EXPORT: DB LOADING getAllExportedImages")
        let allExportedImagesStored = ImageSearchDao.default.getAllExportedImages(includeHidden: false)
        print("\(Date()) EXPORT: DB LOADING getAllExportedImages : DONE")
        let total = allExportedImagesStored.count
        var k:Int = 0
        
        print("\(Date()) EXPORT: CHECKING IF MARKED EXPORTED ARE REALLY EXPORTED")
        for photo in allExportedImagesStored {
            
            // if suppressed from outside, stop immediately
            guard self.nonStop() else {return}
            
            k += 1
            self.printMessage("Validating exported files ... ( \(k) / \(total) )")
            
            if photo.exportToPath != nil && photo.exportAsFilename != nil {
                let fullpath:String = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
                if !FileManager.default.fileExists(atPath: fullpath){
                    ImageExportDao.default.cleanImageExportPath(path: photo.path)
                }else{
                    if photo.exportedMD5 == nil {
                        self.printMessage("Updating MD5 of exported file ... ( \(k) / \(total) )")
                        let md5 = ComputerFileManager.default.md5(pathOfFile: photo.path)
                        ImageExportDao.default.storeImageExportedMD5(path: photo.path, md5: md5)
                        
                    }
                }
            }
        }
        
        print("\(Date()) EXPORT: CHECKING IF MARKED EXPORTED ARE REALLY EXPORTED: DONE")
    }
    
    private func prepareExportDestination(path: String) -> Bool {
        if PreferencesController.exportDirectory() == "" {
            return false
        }
        let fm:FileManager = FileManager.default
        if !fm.fileExists(atPath: path) {
            do {
                try fm.createDirectory(atPath: PreferencesController.exportDirectory(), withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Cannot location or create destination directory for exporting photos: \(PreferencesController.exportDirectory())")
                print(error)
                return false
            }
        }
        return true
    }
    
    private func patchImageDescription(image photo:Image) -> (Bool, String) {
        let originalImageDescription = Naming.Export.getOriginalDescription(image: photo)
        let generatedImageDescription = Naming.Export.getNewDescription(image: photo)
        if originalImageDescription != generatedImageDescription {
            print("\(Date()) Change ImageDescription for \(photo.path)")
            ExifTool.helper.patchImageDescription(description: generatedImageDescription, url: URL(fileURLWithPath: photo.path))
            if generatedImageDescription != photo.longDescription {
                ImageRecordDao.default.storeImageDescription(path: photo.path, shortDescription: nil, longDescription: generatedImageDescription)
            }
            return (true, generatedImageDescription)
            print("\(Date()) Change ImageDescription for \(photo.path) : DONE")
        }
        return (false, generatedImageDescription)
    }
    
    private func exists(image photo:Image, targetPath path:String, targetFilename filename:String,
                        imageDescription:String,
                        fileState:(isSamePath: Bool, existAtPath: FileExistState, filename:String, md5:String)) -> Bool {
        
        if fileState.existAtPath == .existAtPathWithSameMD5 {
            if fileState.isSamePath {
                if photo.exportTime == nil {
                    ImageExportDao.default.storeImageExportedTime(path: path, date: Date())
                }
            }else{
                ImageExportDao.default.storeImageExportSuccess(path: photo.path, date: Date(),
                                                           exportToPath: path,
                                                           exportedFilename: filename,
                                                           exportedMD5: fileState.md5,
                                                           exportedLongDescription: imageDescription)
            }
            if photo.exportedMD5 == nil {
                ImageExportDao.default.storeImageExportedMD5(path: photo.path, md5: fileState.md5)
            }
            return true
        }
        return false
    }
    
    private func exportFile(image photo:Image, path:String, filename:String, imageDescription:String, md5:String) -> Bool {
        print("\(Date()) Copy file \(photo.path)")
        var copied = false
        var errorMessage = ""
        autoreleasepool { () -> Void in
            do {
                try FileManager.default.copyItem(atPath: photo.path, toPath: "\(path)/\(filename)")
                copied = true
            }catch {
                print("Cannot copy from: \(photo.path) to: \(path)/\(filename) ")
                print(error)
                copied = false
                errorMessage = error.localizedDescription
            }
        }
        if !copied {
            ImageExportDao.default.storeImageExportFail(path: photo.path, date: Date(), message: "ERROR: \(errorMessage)")
            
            return false
        }else{
            print("\(Date()) Copy file \(photo.path) : DONE")
            
            ImageExportDao.default.storeImageExportSuccess(path: photo.path, date: Date(),
                                                       exportToPath: path,
                                                       exportedFilename: filename,
                                                       exportedMD5: md5,
                                                       exportedLongDescription: imageDescription)
            return true
        }
    }
    
    
    func export(profile:ExportProfile, after date:Date, housekeep:Bool) -> (Bool, String) {
        guard self.nonStop() && !TaskManager.exporting else {return (false, "PREVENTED")}
        
        guard self.prepareExportDestination(path: profile.directory) else {
            return (false, "INACCESSIBLE DIRECTORY")
        }
        
        
        //print("exporting")
        TaskManager.exporting = true
        print("  ")
        print("!! ExportManager start working at \(Date())")
        
        
        //var filepaths:[String] = []
        
        // check exported
        self.printMessage("Validating ...")
        
        self.checkIfExportedFilesExist()
        
        // check updates and which not exported
        self.printMessage("Searching for updates ...")
        
        print("\(Date()) EXPORT: CHECKING UPDATES AND WHICH NOT EXPORTED")
        
        let total = ImageCountDao.default.countAllPhotoFilesForExporting(after: date)
        
        var batchTotal = 1
        let batchLimit = 500
        
        var i:Int = 0
        while(batchTotal > 0) {
            
            // check updates and which not exported
            self.printMessage("EXPORT Searching for updates ...")
            
            print("\(Date()) EXPORT: CHECKING UPDATES AND WHICH NOT EXPORTED")
        
            let photos:[Image] = ImageSearchDao.default.getAllPhotoFilesForExporting(after: date, limit: batchLimit)
            
            batchTotal = photos.count
            
            if batchTotal == 0 {
                break
            }
            
            for photo in photos {
                guard self.nonStop() else {return (false, "FORCED STOP")}
                
                i += 1
                self.printMessage("EXPORT Processing ... ( \(i) / \(total) )")
                
                print("EXPORT Processing \(i) : \(photo.path)")
                
                // invalid date
                if photo.photoTakenYear == 0 {
                    continue
                }
                
                let pathUrl = URL(fileURLWithPath: photo.path)
                let pathExt = pathUrl.pathExtension.lowercased()
                
                // invalid file-ext
                if !Naming.FileType.allowed.contains(pathExt){
                    ImageExportDao.default.storeImageExportFail(path: photo.path, date: Date(), message: "FILE EXT DISALLOWED")
                    continue
                }
                
                // invalid source file
                if !FileManager.default.fileExists(atPath: photo.path) {
                    ImageExportDao.default.storeImageExportFail(path: photo.path, date: Date(), message: "SOURCE FILE NOT FOUND")
                    continue
                }
                
                var fileChanged = false
                var generatedImageDescription = ""
                (fileChanged, generatedImageDescription) = self.patchImageDescription(image: photo)
                
                // generate path and filename
                let path = Naming.Export.buildFolder(photo: photo)
                let fileState = Naming.Export.buildFilename(photo: photo,
                                                    toPath: path,
                                                    forceGenerateMD5: fileChanged)
                
                let filename = fileState.filename
                
                // check if exist and duplicate
                
                if self.exists(image: photo, targetPath: path, targetFilename: filename, imageDescription: generatedImageDescription, fileState: fileState) {
                    continue
                }
                
                // not exist at path
                self.printMessage("EXPORT Copying ... ( \(i) / \(total) )")
                
                let _ = self.exportFile(image: photo, path: path, filename: filename, imageDescription: generatedImageDescription, md5: fileState.md5)
            }
        } // end of while loop
        self.printMessage("")
        
        print("\(Date()) EXPORT: CHECKING UPDATES AND WHICH NOT EXPORTED: DONE")
        
        if housekeep {
            self.housekeep()
        }
        
        TaskManager.exporting = false
        
        return (true, "COMPLETED")
    }
    
    fileprivate func housekeep() {
        print("\(Date()) EXPORT: HOUSE KEEP")
        
        self.printMessage("Checking invalid exported files ...")
        
        let allExportedFilenames:Set<String> = self.getExportedFilenames()
        
        let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: PreferencesController.exportDirectory()),
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
                        if !allExportedFilenames.contains(file.path) {
                            print("found useless file \(file.path), mark to delete")
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
    
}

