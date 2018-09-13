//
//  ExportManager.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/18.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class ExportManager {
    
    static var working:Bool = false
    static var suppressed:Bool = false
    static var messageBox:NSTextField? = nil
    
    @objc static func enable() {
        suppressed = false
        
        if messageBox != nil {
            DispatchQueue.main.async {
                messageBox?.stringValue = ""
            }
        }
    }
    
    @objc static func disable() {
        suppressed = true
        if messageBox != nil {
            DispatchQueue.main.async {
                messageBox?.stringValue = ""
            }
        }
    }
    
    static func export(after date:Date) {
        if suppressed {
            print("ExportManager is suppressed.")
            return
        }
        if working {
            print("ExportManager: Another instance is working, I'll take a rest.")
            return
        }
        if PreferencesController.exportDirectory() == "" {
            DispatchQueue.main.async {
                Alert.invalidExportPath()
            }
            return
        }
        //print("exporting")
        working = true
        print("  ")
        print("!! ExportManager start working at \(Date())")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日HH点mm分ss"
        
        let sourceFileSystemHandler = ComputerFileManager()
        let targetFileSystemHandler = ComputerFileManager()
        
        //var filepaths:[String] = []
        
        let fm:FileManager = FileManager.default
        if !fm.fileExists(atPath: PreferencesController.exportDirectory()) {
            do {
                try fm.createDirectory(atPath: PreferencesController.exportDirectory(), withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Cannot location or create destination directory for exporting photos: \(PreferencesController.exportDirectory())")
                print(error)
                return
            }
        }
        
        // check exported
        
        if messageBox != nil {
            DispatchQueue.main.async {
                messageBox?.stringValue = "EXPORT Validating ..."
            }
        }
        
        let allMarkedExported = ModelStore.default.getAllPhotoFilesMarkedExported()
        let totalMarked = allMarkedExported.count
        var k:Int = 0
        
        
        print("\(Date()) EXPORT: CHECKING IF MARKED EXPORTED ARE REALLY EXPORTED")
        for photo in allMarkedExported {
            
            // if suppressed from outside, stop immediately
            if suppressed {
                ExportManager.working = false
                DispatchQueue.main.async {
                    messageBox?.stringValue = ""
                }
                return
            }
            
            k += 1
            if messageBox != nil {
                DispatchQueue.main.async {
                    messageBox?.stringValue = "EXPORT Validating ... ( \(k) / \(totalMarked) )"
                }
            }
            
            if photo.exportToPath != nil && photo.exportAsFilename != nil {
                let fullpath:String = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
                if !fm.fileExists(atPath: fullpath){
                    ModelStore.default.cleanImageExportTime(path: photo.path)
                    //photo.exportTime = nil
                    //recovered = true
                }
            }
        }
        
        print("\(Date()) EXPORT: CHECKING IF MARKED EXPORTED ARE REALLY EXPORTED: DONE")
        
        // check updates and which not exported
        if messageBox != nil {
            DispatchQueue.main.async {
                messageBox?.stringValue = "EXPORT Searching for updates ..."
            }
        }
        
        print("\(Date()) EXPORT: CHECKING UPDATES AND WHICH NOT EXPORTED")
        
        let allowedExt:Set<String> = ["jpg", "jpeg", "mp4", "mov", "mpg", "mpeg"]
        
        let total = ModelStore.default.countAllPhotoFilesForExporting(after: date)
        
        var batchTotal = 1
        let batchLimit = 500
        
        var i:Int = 0
        while(batchTotal > 0) {
            
            // check updates and which not exported
            if messageBox != nil {
                DispatchQueue.main.async {
                    messageBox?.stringValue = "EXPORT Searching for updates ..."
                }
            }
            
            print("\(Date()) EXPORT: CHECKING UPDATES AND WHICH NOT EXPORTED")
        
            let photos:[Image] = ModelStore.default.getAllPhotoFilesForExporting(after: date, limit: batchLimit)
            
            batchTotal = photos.count
            
            if batchTotal == 0 {
                break
            }
            
            for photo in photos {
                
                // if suppressed from outside, stop immediately
                if suppressed {
                    
                    ExportManager.working = false
                    DispatchQueue.main.async {
                        messageBox?.stringValue = ""
                    }
                    return
                }
                
                
                
                i += 1
                if messageBox != nil {
                    DispatchQueue.main.async {
                        messageBox?.stringValue = "EXPORT Processing ... ( \(i) / \(total) )"
                    }
                }
                
                print("EXPORT Processing \(i) : \(photo.path)")
                
                // invalid date
                if photo.photoTakenYear == 0 {
                    continue
                }
                
                let pathUrl = URL(fileURLWithPath: photo.path)
                let pathExt = pathUrl.pathExtension.lowercased()
                
                // invalid file-ext
                if !allowedExt.contains(pathExt){
                    ModelStore.default.storeImageExportFail(path: photo.path, date: Date(), message: "FILE EXT DISALLOWED")
                    continue
                }
                
                // invalid source file
                if !FileManager.default.fileExists(atPath: photo.path) {
                    ModelStore.default.storeImageExportFail(path: photo.path, date: Date(), message: "SOURCE FILE NOT FOUND")
                    continue
                }
                
                // patch image description into original image file, md5 will change
                let originalImageDescription = photo.exportedLongDescription ?? ExifTool.helper.getImageDescription(url: pathUrl)
                let generatedImageDescription = photo.longDescription ?? ExportManager.getImageDescription(photo: photo)
                if originalImageDescription != generatedImageDescription {
                    print("\(Date()) Change ImageDescription for \(photo.path)")
                    ExifTool.helper.patchImageDescription(description: generatedImageDescription, url: pathUrl)
                    print("\(Date()) Change ImageDescription for \(photo.path) : DONE")
                }
                
                // generate path and filename
                let path = getOrCreateFolder(photo: photo, fm: targetFileSystemHandler)
                let fileState = getOrCreateFilename(photo: photo,
                                                    toPath: path,
                                                    dateFormat: dateFormatter,
                                                    targetFileManager: targetFileSystemHandler,
                                                    sourceFileManager: sourceFileSystemHandler )
                
                let filename = fileState.filename
                
                // check if exist and duplicate
                if fileState.existAtPath == .existAtPathWithSameMD5 {
                    if fileState.isSamePath {
                        if photo.exportTime == nil {
                            ModelStore.default.storeImageExportedTime(path: photo.path, date: Date())
                        }
                    }else{
                        ModelStore.default.storeImageExportSuccess(path: photo.path, date: Date(),
                                                                  exportToPath: path,
                                                                  exportedFilename: filename,
                                                                  exportedMD5: fileState.md5,
                                                                  exportedLongDescription: generatedImageDescription)
                    }
                    if photo.exportedMD5 == nil {
                        ModelStore.default.storeImageExportedMD5(path: photo.path, md5: fileState.md5)
                    }
                    continue
                }
                
                // not exist at path
                
                if messageBox != nil {
                    DispatchQueue.main.async {
                        messageBox?.stringValue = "EXPORT Copying ... ( \(i) / \(total) )"
                    }
                }
                print("\(Date()) Copy file \(photo.path)")
                do {
                    try fm.copyItem(atPath: photo.path, toPath: "\(path)/\(filename)")
                }catch {
                    print("Cannot copy from: \(photo.path) to: \(path)/\(filename) ")
                    print(error)
                    
                    ModelStore.default.storeImageExportFail(path: photo.path, date: Date(), message: "ERROR: \(error.localizedDescription)")
                    
                    continue
                }
                print("\(Date()) Copy file \(photo.path) : DONE")
                
                ModelStore.default.storeImageExportSuccess(path: photo.path, date: Date(),
                                                          exportToPath: path,
                                                          exportedFilename: filename,
                                                          exportedMD5: fileState.md5,
                                                          exportedLongDescription: generatedImageDescription)
            }
        } // end of while loop
        
        if messageBox != nil {
            DispatchQueue.main.async {
                messageBox?.stringValue = ""
            }
        }
        
        print("\(Date()) EXPORT: CHECKING UPDATES AND WHICH NOT EXPORTED: DONE")
        
        
        // if suppressed from outside, stop immediately
        if suppressed {
            ExportManager.working = false
            DispatchQueue.main.async {
                messageBox?.stringValue = ""
            }
            return
        }
        
        // house keep
        
        print("\(Date()) EXPORT: HOUSE KEEP")
        let allExportedFilenames:Set<String> = ModelStore.default.getAllExportedPhotoFilenames(includeHidden: false)
        
        let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: PreferencesController.exportDirectory()),
                                                        includingPropertiesForKeys: [.isDirectoryKey, .isReadableKey, .isWritableKey ],
                                                        options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                            print("directoryEnumerator error at \(url): ", error)
                                                            return true
        })!
        
        var allExportedDirectories:Set<String> = []
        var uselessFiles:Set<String> = []
        for case let file as URL in enumerator {
            do {
                
                // if suppressed from outside, stop immediately
                if suppressed {
                    ExportManager.working = false
                    DispatchQueue.main.async {
                        messageBox?.stringValue = ""
                    }
                    return
                }
                
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
        
        // delete useless files
        if uselessFiles.count > 0 {
            let total = uselessFiles.count
            var i = 0
            for uselessFile in uselessFiles {
                
                // if suppressed from outside, stop immediately
                if suppressed {
                    ExportManager.working = false
                    DispatchQueue.main.async {
                        messageBox?.stringValue = ""
                    }
                    return
                }
                i += 1
                
                if messageBox != nil {
                    DispatchQueue.main.async {
                        messageBox?.stringValue = "Useless file ... ( \(i) / \(total) )"
                    }
                }
                
                print("deleting useless file \(uselessFile)")
                
                do {
                    try fm.removeItem(atPath: uselessFile)
                }catch {
                    print("Cannot delete useless file \(uselessFile)")
                    print(error)
                }
            }
        }
        // recognize empty folders
        for exportedFilePath in allExportedFilenames {
            for folder in allExportedDirectories {
                
                // if suppressed from outside, stop immediately
                if suppressed {
                    ExportManager.working = false
                    DispatchQueue.main.async {
                        messageBox?.stringValue = ""
                    }
                    return
                }
                
                if exportedFilePath.starts(with: folder) {
                    allExportedDirectories.remove(folder)
                    continue
                }
            }
        }
        // delete empty folders
        if allExportedDirectories.count > 0 {
            print("  ")
            let total = allExportedDirectories.count
            var i = 0
            for emptyFolder in allExportedDirectories {
                
                // if suppressed from outside, stop immediately
                if suppressed {
                    ExportManager.working = false
                    DispatchQueue.main.async {
                        messageBox?.stringValue = ""
                    }
                    return
                }
                
                i += 1
                
                if messageBox != nil {
                    DispatchQueue.main.async {
                        messageBox?.stringValue = "Empty folder ... ( \(i) / \(total) )"
                    }
                }
                
                print("deleting empty folder \(emptyFolder)")
                do {
                    try fm.removeItem(atPath: emptyFolder)
                }catch{
                    print("  Cannot delete empty folder \(emptyFolder)")
                    print(error)
                }
            }
            print("  ")
        }
        
        if messageBox != nil {
            DispatchQueue.main.async {
                messageBox?.stringValue = ""
            }
        }
        
        print("\(Date()) EXPORT: HOUSE KEEP: DONE")
        
        ExportManager.working = false
        
    }
    
    static func getOrCreateFolder(photo:Image, fm: FileSystemHandler) -> String{
        var pathComponents:[String] = []
        pathComponents.append(PreferencesController.exportDirectory())
        pathComponents.append("\(photo.photoTakenYear ?? 0)年")
        //let year:String = "\(photo.photoTakenYear)"
        let month:String = photo.photoTakenMonth! < 10 ? "0\(photo.photoTakenMonth ?? 0)" : "\(photo.photoTakenMonth ?? 0)"
        //let day:String = photo.photoTakenDay < 10 ? "0\(photo.photoTakenDay)" : "\(photo.photoTakenDay)"
        let event:String = photo.event == nil || photo.event == "" ? "" : " \(photo.event ?? "")"
        pathComponents.append("\(month)月\(event)")
        let path:String = pathComponents.joined(separator: "/")
        
        if fm.createDirectory(atPath: path) {
            return path
        }else{
            return ""
        }
    }
    
    static func getImageDescription(photo:Image) -> String {
        var eventAndPlace = ""
        
        if photo.event != nil && photo.event != "" {
            eventAndPlace = "\(photo.event!)"
        }
        if photo.place != nil && photo.place != "" {
            eventAndPlace = "\(eventAndPlace) 在 \(photo.place!)"
        }
        return eventAndPlace
    }
    
    static func getOrCreateFilename(photo:Image, toPath path:String, dateFormat dateFormatter:DateFormatter,
                                    targetFileManager fm:FileSystemHandler,
                                    sourceFileManager:FileSystemHandler,
                                    ignoreDiffPathChecking:Bool = false) -> (isSamePath: Bool, existAtPath: FileExistState, filename:String, md5:String) {
        
        var filenameComponents:[String] = []
        
        // Date
        var photoDateFormatted = ""
        if photo.photoTakenDate != nil {
            photoDateFormatted = dateFormatter.string(from: photo.photoTakenDate!)
            filenameComponents.append(photoDateFormatted)
        }
        
        // Event & Place
        let eventAndPlace = getImageDescription(photo: photo)
        if eventAndPlace != "" {
            filenameComponents.append(eventAndPlace)
        }
        
        // Image Source
        if (photo.filename.starts(with: "mmexport")) {
            filenameComponents.append(" (来自微信)")
        }
        
        if (photo.filename.starts(with: "QQ空间视频_")) {
            filenameComponents.append(" (来自QQ)")
        }
        
        if (photo.filename.starts(with: "Screenshot_")) {
            filenameComponents.append(" (手机截屏)")
        }
        
        // Combine
        let fileExt:String = (photo.filename.split(separator: Character(".")).last?.lowercased())!
        filenameComponents.append(".")
        filenameComponents.append(fileExt)
        
        // export as this name
        var filename:String = filenameComponents.joined()
        
        // START: check duplicates, adjust filename if duplicates at target path
        
        // export to this path
        var targetPath:String = "\(path)/\(filename)"
        
        var previousTargetPath = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
        if previousTargetPath == "/" {
            previousTargetPath = ""
        }
        
        let isSamePath:Bool = ignoreDiffPathChecking ? true : ( previousTargetPath == targetPath )
        
        // detect duplicates
        let md5OfSourceFile = photo.exportedMD5 ?? sourceFileManager.md5(pathOfFile: photo.path)
        
        var state = fm.fileExists(atPath: targetPath, md5: md5OfSourceFile)
        
        if state == .notExistAtPath {
            return (isSamePath: isSamePath, existAtPath: .notExistAtPath, filename: filename, md5: md5OfSourceFile)
        }
        
        if state == .existAtPathWithSameMD5 {
            return (isSamePath: isSamePath, existAtPath: .existAtPathWithSameMD5, filename: filename, md5: md5OfSourceFile)
        }
        
        // if another photo occupied the filename at targetPath, with different md5, change filename
        if state == .existAtPathWithDifferentMD5 {
            
            // add camera model to suffix
            filenameComponents.removeLast()
            filenameComponents.removeLast()
            if photo.cameraMaker != nil && photo.cameraMaker != "" {
                filenameComponents.append(" (\(photo.cameraMaker!)")
                
                if photo.cameraModel != nil && photo.cameraModel != "" {
                    filenameComponents.append(" \(photo.cameraModel!)")
                }
                filenameComponents.append(")")
            }
            filenameComponents.append(".")
            filenameComponents.append(fileExt)
            filename = filenameComponents.joined()
            targetPath = "\(path)/\(filename)"
            
            // add number to suffix
            for i in 1...9999 {
                let suffix = i < 10 ? "0\(i)" : "\(i)"
                
                state = fm.fileExists(atPath: targetPath, md5: md5OfSourceFile)
                if state == .existAtPathWithDifferentMD5 {
                    filenameComponents.removeLast() // fileExt
                    filenameComponents.removeLast() // .
                    if i > 1 {
                        filenameComponents.removeLast() // suffix
                    }
                    filenameComponents.append(" \(suffix)")
                    filenameComponents.append(".")
                    filenameComponents.append(fileExt)
                    filename = filenameComponents.joined()
                    targetPath = "\(path)/\(filename)"
                }else{
                    print("break for-loop")
                    break
                }
            } // state will become .notExistAtPath or .existAtPathWithSameMD5
        }
        // only returns: .notExistAtPath or .existAtPathWithSameMD5
        return (isSamePath: isSamePath, existAtPath: state, filename: filename, md5:md5OfSourceFile)
    }
}

