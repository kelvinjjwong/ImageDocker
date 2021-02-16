//
//  ViewController+Menu+ImageOptions.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/1.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func setupPreviewMenu() {
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: "Large View", action: #selector(previewMenuLargeView(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: "Preview editable version", action: #selector(previewMenuPreviewEditableVersion(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Preview backup version", action: #selector(previewMenuPreviewBackupVersion(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: "Find editable version from Finder", action: #selector(previewMenuFindEditableInFinder(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Find backup version from Finder", action: #selector(previewMenuFindBackupInFinder(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: "Pick date time from DateTimeOriginal", action: #selector(previewMenuPickDateTimeOriginal(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Pick date time from Filename", action: #selector(previewMenuPickFilenameDate(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Pick date time from FileCreateDate", action: #selector(previewMenuPickFileCreateDate(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Pick date time from FileModifyDate", action: #selector(previewMenuPickFileModifyDate(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Pick date time from Software Modified Date", action: #selector(previewMenuPickSoftwareModifyDate(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: "Turn 90° clockwise", action: #selector(previewMenuTurnRight(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Turn -90° counter-clockwise", action: #selector(previewMenuTurnLeft(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Upside down", action: #selector(previewMenuTurnUpsideDown(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Save image direction", action: #selector(previewMenuMarkRotateDirection(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: "Extract EXIF from image", action: #selector(previewMenuExtractExif(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Extract date time from filename", action: #selector(previewMenuExtractDatetime(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: "Find faces", action: #selector(previewMenuFindFace(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Recognize faces", action: #selector(previewMenuRecognizeFace(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: "Write notes", action: #selector(previewMenuWriteNote(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: "Replace image with backup version", action: #selector(previewMenuRestoreBackupImage(_:)), keyEquivalent: "")
    }
    
    @objc func previewMenuWriteNote(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        print("preview menu - to do function")
    }
    
    @objc func previewMenuMarkRotateDirection(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        print("preview menu - to do function")
    }
    
    @objc func previewMenuTurnRight(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let img = self.getImageFromPreview() {
            self.previewImage(image: img.rotate(degrees: -90))
        }
    }
    
    @objc func previewMenuTurnLeft(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let img = self.getImageFromPreview() {
            self.previewImage(image: img.rotate(degrees: 90))
        }
    }
    
    @objc func previewMenuTurnUpsideDown(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let img = self.getImageFromPreview() {
            self.previewImage(image: img.rotate(degrees: 180))
        }
    }
    
    fileprivate func copyDateToBatchEditor(value:String, name:String) {
//        if self.selectionViewController.imagesLoader.getItems().count == 0 {
//            Alert.noImageSelected()
//            return
//        }
        
        let components = value.components(separatedBy: " ")
        if components.count >= 2{
            let datetime:String = components[0] + " " + components[1]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
            if let _ = dateFormatter.date(from: datetime) {
                let newValue = components[0].replacingOccurrences(of: ":", with: "-") + " " + components[1]
                self.openDatePicker(self.btnDatePicker, with: newValue)
                self.popNotification(message: "Copied \(newValue) to date picker in batch editor.")
            }
        }
    }
    
    @objc func previewMenuPickFilenameDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "From Filename") {
            self.copyDateToBatchEditor(value: value, name: "Date in Filename")
        }else{
            self.popNotification(message: "Selected image does not have date time in filename, may need re-scan its EXIF.")
        }
    }
    
    @objc func previewMenuPickDateTimeOriginal(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "DateTimeOriginal") {
            self.copyDateToBatchEditor(value: value, name: "DateTimeOriginal")
        }else{
            self.popNotification(message: "Selected image does not have DateTimeOriginal, may need re-scan its EXIF.")
        }
    }
    
    @objc func previewMenuPickFileCreateDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "FileCreateDate") {
            self.copyDateToBatchEditor(value: value, name: "FileCreateDate")
        }else{
            self.popNotification(message: "Selected image does not have FileCreateDate, may need re-scan its EXIF.")
        }
    }
    
    @objc func previewMenuPickFileModifyDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "FileModifyDate") {
            self.copyDateToBatchEditor(value: value, name: "FileModifyDate")
        }else{
            self.popNotification(message: "Selected image does not have FileModifyDate, may need re-scan its EXIF.")
        }
    }
    
    @objc func previewMenuPickSoftwareModifyDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "Software Modified") {
            self.copyDateToBatchEditor(value: value, name: "SoftwareModifyDate")
        }else{
            self.popNotification(message: "Selected image does not have SoftwareModifyDate, may need re-scan its EXIF.")
        }
    }
    
    @objc func previewMenuFindFace(_ menuItem:NSMenuItem) {
        self.findFacesFromSelectedImage()
    }
    
    @objc func previewMenuRecognizeFace(_ menuItem:NSMenuItem) {
        self.recognizeFacesFromSelectedImage()
    }
    
    @objc func previewMenuExtractExif(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        self.loadImageExif()
        self.popNotification(message: "Done extract EXIF for selected image.")
//        print("preview menu - done")
    }
    
    @objc func previewMenuExtractDatetime(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        let dateString = Naming.DateTime.recognize(url: url)
//        print("recognized date: \(dateString)")
        if dateString != "" {
            if self.img.imageData != nil {
                self.img.imageData?.dateTimeFromFilename = dateString
                if let dt = self.img.earliestDate() {
//                    print("earliest date is \(dt) UTC")
                    self.img.storePhotoTakenDate(dateTime: dt)
                }
                let _ = self.img.save()
                self.loadImageExif()
                
                self.popNotification(message: "Done extract date time from filename for selected image.")
            }
        }else{

            self.popNotification(message: "Failed to extract date time from filename for selected image.")
        }
//        print("preview menu - done")
    }
    
    @objc func previewMenuFindEditableInFinder(_ menuItem:NSMenuItem){
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        NSWorkspace.shared.activateFileViewerSelecting([url])
//        print("preview menu - done")
    }
    
    @objc func previewMenuFindBackupInFinder(_ menuItem:NSMenuItem){
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        NSWorkspace.shared.activateFileViewerSelecting([url])
//        print("preview menu - done")
    }
    
    @objc func previewMenuLargeView(_ menuItem:NSMenuItem){
        self.btnImageOptions.selectItem(at: 0)
        self.onCollectionViewItemQuickLook(self.img)
//        print("preview menu - done")
    }
    
    @objc func previewMenuPreviewEditableVersion(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        self.previewImage(url: url, isPhoto: self.img.isPhoto)
        DispatchQueue.main.async {
            self.lblImageDescription.stringValue = "EDITABLE VERSION"
        }
//        print("preview menu - done")
    }
    
    @objc func previewMenuPreviewBackupVersion(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let url = self.img.backupUrl {
            self.previewImage(url: url, isPhoto: self.img.isPhoto)
            DispatchQueue.main.async {
                self.lblImageDescription.stringValue = "BACKUP VERSION"
            }
        }
//        print("preview menu - done")
    }
    
    @objc func previewMenuRestoreBackupImage(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        DispatchQueue.global().async {
            if let imageFile = self.img {
                let url = imageFile.url
                if FileManager.default.fileExists(atPath: url.path) {
                    if let backupUrl = imageFile.backupUrl, FileManager.default.fileExists(atPath: backupUrl.path) {
                        
                        let uuid = UUID().uuidString
                        let filename = imageFile.fileName
                        let tmpFolder = "/tmp/\(uuid)"
                        let tmpPath = "\(tmpFolder)/\(filename)"
                        do {
//                            print("Restoring backup image from [\(backupUrl.path)] to [url.path]")
                            try FileManager.default.createDirectory(atPath: tmpFolder, withIntermediateDirectories: true, attributes: nil)
                            try FileManager.default.moveItem(atPath: url.path, toPath: tmpPath)
                            try FileManager.default.copyItem(atPath: backupUrl.path, toPath: url.path)

                            self.popNotification(message: "Done replaced image with backup version for selected image.")
                        }catch{
                            print("Unable to restore backup image from [\(backupUrl.path)] to [url.path]")
                            print(error)

                            self.popNotification(message: "Failed to replace image with backup version for selected image.")
                            
//                            print("Restoring original editable version from \(tmpPath)")
                            do {
                                try FileManager.default.removeItem(atPath: url.path)
                                try FileManager.default.moveItem(atPath: tmpPath, toPath: url.path)
                            }catch{
                                print("Unable to restore original editable version from [\(tmpPath)] to [\(url.path)]")
                                print(error)
                            }
                        }
                        do {
                            try FileManager.default.removeItem(atPath: tmpPath)
                            try FileManager.default.removeItem(atPath: tmpFolder)
                        }catch{
                            print(error)
                        }
                    }else{
                        self.popNotification(message: "Error: Selected image's backup version does not exist.")
                    }
                }else{
                    self.popNotification(message: "Error: Selected image's editable version does not exist.")
                }
            }
            
        }
    }
    
    fileprivate func findFacesFromSelectedImage() {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        DispatchQueue.global().async {
            let _ = FaceTask.default.findFaces(path: url.path)
            self.popNotification(message: "Done find faces from selected image.")
        }
    }
    
    func recognizeFacesFromSelectedImage() {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        DispatchQueue.global().async {
            let _ = FaceTask.default.recognizeFaces(path: url.path)
            self.popNotification(message: "Done recognize faces from selected image.")
        }
    }
}
