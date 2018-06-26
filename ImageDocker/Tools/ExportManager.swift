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
    
    static func md5(pathOfFile:String) -> String {
        let pipe = Pipe()
        let cmd = Process()
        cmd.standardOutput = pipe
        cmd.standardError = pipe
        cmd.launchPath = "/sbin/md5"
        cmd.arguments = []
        cmd.arguments?.append(pathOfFile)
        cmd.launch()
        cmd.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        if string != "" && string.starts(with: "MD5 (") {
            let comp:[String] = string.components(separatedBy: " = ")
            if comp.count == 2 {
                return comp[1].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }
        }
        return ""
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
        //print("exporting")
        working = true
        print("  ")
        print("!! ExportManager start working at \(Date())")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日HH点mm分ss"
        
        //var filepaths:[String] = []
        
        if PreferencesController.exportDirectory() != "" {
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
            let allMarkedExported = ModelStore.getAllPhotoFilesMarkedExported()
            let totalMarked = allMarkedExported.count
            var k:Int = 0
            var recovered:Bool = false
            
            print("\(Date()) EXPORT: CHECKING IF MARKED EXPORTED ARE REALLY EXPORTED")
            for photo in allMarkedExported {
                
                // if suppressed from outside, stop immediately
                if suppressed {
                    
                    if recovered {
                        ModelStore.save()
                    }
                    
                    ExportManager.working = false
                    DispatchQueue.main.async {
                        messageBox?.stringValue = ""
                    }
                    return
                }
                
                k += 1
                if messageBox != nil {
                    DispatchQueue.main.async {
                        messageBox?.stringValue = "EXPORT Checking ... ( \(k) / \(totalMarked) )"
                    }
                }
                
                if photo.exportToPath != nil && photo.exportAsFilename != nil {
                    let fullpath:String = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
                    if !fm.fileExists(atPath: fullpath){
                        photo.exportTime = nil
                        recovered = true
                    }
                }
            }
            if recovered {
                ModelStore.save()
            }
            
            print("\(Date()) EXPORT: CHECKING IF MARKED EXPORTED ARE REALLY EXPORTED: DONE")
            
            // check updates and which not exported
            
            print("\(Date()) EXPORT: CHECKING UPDATES AND WHICH NOT EXPORTED")
            var dataChanged:Bool = false
            let photos:[PhotoFile] = ModelStore.getAllPhotoFilesForExporting(after: date)
            
            let total = photos.count
            var i:Int = 0
            for photo in photos {
                
                // if suppressed from outside, stop immediately
                if suppressed {
                    
                    if dataChanged {
                        DispatchQueue.main.async {
                            ModelStore.save()
                            //print("export done")
                        }
                    }
                    
                    ExportManager.working = false
                    DispatchQueue.main.async {
                        messageBox?.stringValue = ""
                    }
                    return
                }
                
                i += 1
                if messageBox != nil {
                    DispatchQueue.main.async {
                        messageBox?.stringValue = "EXPORT Checking ... ( \(i) / \(total) )"
                    }
                }
                
                if photo.photoTakenYear == 0 {
                    continue
                }
                var pathComponents:[String] = []
                pathComponents.append(PreferencesController.exportDirectory())
                pathComponents.append("\(photo.photoTakenYear)年")
                //let year:String = "\(photo.photoTakenYear)"
                let month:String = photo.photoTakenMonth < 10 ? "0\(photo.photoTakenMonth)" : "\(photo.photoTakenMonth)"
                //let day:String = photo.photoTakenDay < 10 ? "0\(photo.photoTakenDay)" : "\(photo.photoTakenDay)"
                let event:String = photo.event == nil || photo.event == "" ? "" : " \(photo.event ?? "")"
                pathComponents.append("\(month)月\(event)")
                let path:String = pathComponents.joined(separator: "/")
                
                do {
                    try fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                }catch{
                    print("Cannot create directory: \(path)")
                    print(error)
                    continue
                }
                
                var filenameComponents:[String] = []
                if photo.photoTakenDate != nil {
                    filenameComponents.append(dateFormatter.string(from: photo.photoTakenDate!))
                    if photo.event != nil && photo.event != "" {
                        filenameComponents.append(" ")
                        filenameComponents.append(photo.event!)
                    }
                    if photo.place != nil && photo.place != "" {
                        filenameComponents.append(" 在")
                        filenameComponents.append(photo.place!)
                    }
                }
                
                if (photo.filename?.starts(with: "mmexport"))! {
                    filenameComponents.append(" (来自微信)")
                }
                
                if (photo.filename?.starts(with: "QQ空间视频_"))! {
                    filenameComponents.append(" (来自QQ)")
                }
                
                if (photo.filename?.starts(with: "Screenshot_"))! {
                    filenameComponents.append(" (手机截屏)")
                }
                
                let fileExt:String = (photo.filename!.split(separator: Character(".")).last?.lowercased())!
                filenameComponents.append(".")
                filenameComponents.append(fileExt)
                
                // export as this name
                var filename:String = filenameComponents.joined()
                
                // export to this path
                var fullpath:String = "\(path)/\(filename)"
                
                var originalExportPath = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
                if originalExportPath == "/" {
                    originalExportPath = ""
                }
                
                // detect duplicates
                if originalExportPath == fullpath { // export to the same path as previous
                    if fm.fileExists(atPath: fullpath) {
                        let md5Exists = md5(pathOfFile: fullpath)
                        let md5PhotoFile = md5(pathOfFile: photo.path!)
                        if md5Exists == md5PhotoFile {
                            // same file, abort
                            //filepaths.append(originalExportPath)
                            
                            if photo.exportTime == nil {
                                photo.exportTime = Date()
                                dataChanged = true
                            }
                            continue
                        }else{
                            // different file, delete the one in export path
                            print("!! exists destination \(fullpath) , different md5, delete")
                            do {
                                try fm.removeItem(atPath: originalExportPath)
                            }catch {
                                print("Cannot delete original copy: \(originalExportPath)")
                                print(error)
                            }
                        }
                    }
                }else if originalExportPath != "" && originalExportPath != fullpath { // export to a different path from previous
                    if fm.fileExists(atPath: originalExportPath) { // delete the one in previous path
                        do {
                            try fm.removeItem(atPath: originalExportPath)
                        }catch {
                            print("Cannot delete original copy: \(originalExportPath)")
                            print(error)
                        }
                    }
                }
                
                // other photo occupied the filename, same md5, abort
                if fm.fileExists(atPath: fullpath) {
                    let md5Exists = md5(pathOfFile: fullpath)
                    let md5PhotoFile = md5(pathOfFile: photo.path!)
                    if md5Exists == md5PhotoFile {
                        
                        if photo.exportTime == nil {
                            photo.exportTime = Date()
                            dataChanged = true
                        }
                        continue
                    }
                }
                // other photo occupied the filename, different md5, change filename
                if fm.fileExists(atPath: fullpath) {
                    print("!! exists destination \(fullpath) , add camera as suffix")
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
                    fullpath = "\(path)/\(filename)"
                }
                // other photo occupied the filename, different md5, change filename
                for i in 1...99 {
                    let suffix = i < 10 ? "0\(i)" : "\(i)"
                    
                    if fm.fileExists(atPath: fullpath) {
                        print("!! exists destination \(fullpath) , add \(suffix) as suffix")
                        filenameComponents.removeLast()
                        filenameComponents.removeLast()
                        filenameComponents.append(" \(suffix)")
                        filenameComponents.append(".")
                        filenameComponents.append(fileExt)
                        filename = filenameComponents.joined()
                        fullpath = "\(path)/\(filename)"
                    }else{
                        break
                    }
                }
                
                
                if messageBox != nil {
                    DispatchQueue.main.async {
                        messageBox?.stringValue = "EXPORT Copying ... ( \(i) / \(total) )"
                    }
                }
                do {
                    try fm.copyItem(atPath: photo.path!, toPath: "\(path)/\(filename)")
                }catch {
                    print("Cannot copy from: \(photo.path!) to: \(path)/\(filename) ")
                    print(error)
                    continue
                }
                
                if photo.exportToPath == nil || path != photo.exportToPath {
                    photo.exportToPath = path
                    photo.exportTime = Date()
                    dataChanged = true
                }
                if photo.exportAsFilename == nil || filename != photo.exportAsFilename {
                    photo.exportAsFilename = filename
                    photo.exportTime = Date()
                    dataChanged = true
                }
                
                if photo.exportTime == nil {
                    photo.exportTime = Date()
                    dataChanged = true
                }
                
                //filepaths.append(fullpath)
            }
            
            if dataChanged {
                DispatchQueue.main.async {
                    ModelStore.save()
                    //print("export done")
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
            var filepaths:[String] = []
            let allphotos = ModelStore.getAllPhotoFiles()
            for photo in allphotos {
                if photo.exportToPath != nil && photo.exportAsFilename != nil {
                    let path = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
                    filepaths.append(path)
                }
            }
            
            let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: PreferencesController.exportDirectory()),
                                                            includingPropertiesForKeys: [.isDirectoryKey, .isReadableKey ],
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                print("directoryEnumerator error at \(url): ", error)
                                                                return true
            })!
            
            var emptyFolders:[String] = []
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
                    
                    let url = try file.resourceValues(forKeys: [.isDirectoryKey, .isReadableKey])
                    if !url.isDirectory! {
                    
                        if filepaths.index(where: { $0 == file.path }) == nil {
                            print("found useless file \(file.path), delete")
                            do {
                                try fm.removeItem(atPath: file.path)
                            }catch {
                                print("Cannot delete useless file \(file.path)")
                                print(error)
                            }
                        }
                    }else {
                        emptyFolders.append("\(file.path)/")
                    }
                }catch{
                    print("Error reading url properties for \(file.path)")
                    print(error)
                }
            }
            for filepath in filepaths {
                for folder in emptyFolders {
                    if filepath.starts(with: folder) {
                        let i = emptyFolders.index(of: folder)!
                        emptyFolders.remove(at: i)
                        continue
                    }
                }
            }
            if emptyFolders.count > 0 {
                print("  ")
                for emptyFolder in emptyFolders {
                    
                    // if suppressed from outside, stop immediately
                    if suppressed {
                        ExportManager.working = false
                        DispatchQueue.main.async {
                            messageBox?.stringValue = ""
                        }
                        return
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
            
            print("\(Date()) EXPORT: HOUSE KEEP: DONE")
            
            ExportManager.working = false
        }
    }
}
