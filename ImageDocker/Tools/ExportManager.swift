//
//  ExportManager.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/6/18.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

class ExportManager {
    
    static var working:Bool = false
    
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
                return comp[1]
            }
        }
        return ""
    }
    
    static func export() {
        if working {
            print("ExportManager: Another instance is working, I'll take a rest.")
            return
        }
        //print("exporting")
        working = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日HH点mm分ss"
        
        var filepaths:[String] = []
        
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
            let photos:[PhotoFile] = ModelStore.getAllPhotoFiles()
            for photo in photos {
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
                
                var filename:String = filenameComponents.joined()
                var fullpath:String = "\(path)/\(filename)"
                
                var originalExportPath = "\(photo.exportToPath ?? "")/\(photo.exportAsFilename ?? "")"
                if originalExportPath == "/" {
                    originalExportPath = ""
                }
                
                // detect duplicates
                if originalExportPath == fullpath {
                    if fm.fileExists(atPath: fullpath) {
                        print("!! exists destination \(fullpath)")
                        let md5Exists = md5(pathOfFile: fullpath)
                        let md5PhotoFile = md5(pathOfFile: photo.path!)
                        if md5Exists == md5PhotoFile {
                            filepaths.append(originalExportPath)
                            print(">> same md5 (\(md5Exists)), ignore")
                            continue
                        }else{
                            print(">> different md5, delete")
                            do {
                                try fm.removeItem(atPath: originalExportPath)
                            }catch {
                                print("Cannot delete original copy: \(originalExportPath)")
                                print(error)
                            }
                        }
                    }
                }else if originalExportPath != "" && originalExportPath != fullpath {
                    if fm.fileExists(atPath: originalExportPath) {
                        do {
                            try fm.removeItem(atPath: originalExportPath)
                        }catch {
                            print("Cannot delete original copy: \(originalExportPath)")
                            print(error)
                        }
                    }
                }
                
                
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
                
                if fm.fileExists(atPath: fullpath) {
                    print("!! exists destination \(fullpath) , add 01 as suffix")
                    filenameComponents.removeLast()
                    filenameComponents.removeLast()
                    filenameComponents.append(" 01")
                    filenameComponents.append(".")
                    filenameComponents.append(fileExt)
                    filename = filenameComponents.joined()
                    fullpath = "\(path)/\(filename)"
                }
                
                if fm.fileExists(atPath: fullpath) {
                    print("!! exists destination \(fullpath) , add 02 as suffix")
                    filenameComponents.removeLast()
                    filenameComponents.removeLast()
                    filenameComponents.removeLast()
                    filenameComponents.append(" 02")
                    filenameComponents.append(".")
                    filenameComponents.append(fileExt)
                    filename = filenameComponents.joined()
                    fullpath = "\(path)/\(filename)"
                }
                
                if fm.fileExists(atPath: fullpath) {
                    print("!! exists destination \(fullpath) , add 03 as suffix")
                    filenameComponents.removeLast()
                    filenameComponents.removeLast()
                    filenameComponents.removeLast()
                    filenameComponents.append(" 03")
                    filenameComponents.append(".")
                    filenameComponents.append(fileExt)
                    filename = filenameComponents.joined()
                    fullpath = "\(path)/\(filename)"
                }
                
                if fm.fileExists(atPath: fullpath) {
                    print("!! exists destination \(fullpath) , add 04 as suffix")
                    filenameComponents.removeLast()
                    filenameComponents.removeLast()
                    filenameComponents.removeLast()
                    filenameComponents.append(" 04")
                    filenameComponents.append(".")
                    filenameComponents.append(fileExt)
                    filename = filenameComponents.joined()
                    fullpath = "\(path)/\(filename)"
                }
                
                if fm.fileExists(atPath: fullpath) {
                    print("!! exists destination \(fullpath) , add 05 as suffix")
                    filenameComponents.removeLast()
                    filenameComponents.removeLast()
                    filenameComponents.removeLast()
                    filenameComponents.append(" 05")
                    filenameComponents.append(".")
                    filenameComponents.append(fileExt)
                    filename = filenameComponents.joined()
                    fullpath = "\(path)/\(filename)"
                }
                
                do {
                    try fm.copyItem(atPath: photo.path!, toPath: "\(path)/\(filename)")
                }catch {
                    print("Cannot copy from: \(photo.path!) to: \(path)/\(filename) ")
                    print(error)
                    continue
                }
                
                photo.exportToPath = path
                photo.exportAsFilename = filename
                
                filepaths.append(fullpath)
            }
            
            DispatchQueue.main.async {
                ModelStore.save()
                //print("export done")
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
                    let url = try file.resourceValues(forKeys: [.isDirectoryKey, .isReadableKey])
                    if !url.isDirectory! {
                    
                        if filepaths.index(where: { $0 == file.path }) == nil {
                            print("detecetd useless file \(file.path), delete")
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
                    do {
                        try fm.removeItem(atPath: emptyFolder)
                    }catch{
                        print("  Cannot delete empty folder \(emptyFolder)")
                        print(error)
                    }
                }
                print("  ")
            }
            
            ExportManager.working = false
        }
    }
}
