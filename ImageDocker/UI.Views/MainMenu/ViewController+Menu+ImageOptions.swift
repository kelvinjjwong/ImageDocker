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
        
        self.btnImageOptions.menu?.item(at: 0)?.title = Words.imageOption.word()
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.largeView.word(), action: #selector(previewMenuLargeView(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.previewEditableVersion.word(), action: #selector(previewMenuPreviewEditableVersion(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.previewBackupVersion.word(), action: #selector(previewMenuPreviewBackupVersion(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.findEditableVersionFromFinder.word(), action: #selector(previewMenuFindEditableInFinder(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.findBackupVersionFromFinder.word(), action: #selector(previewMenuFindBackupInFinder(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.pickDateTimeFromDateTimeOriginal.word(), action: #selector(previewMenuPickDateTimeOriginal(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.pickDateTimeFromFilename.word(), action: #selector(previewMenuPickFilenameDate(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.pickDateTimeFromFileCreateDate.word(), action: #selector(previewMenuPickFileCreateDate(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.pickDateTimeFromFileModifyDate.word(), action: #selector(previewMenuPickFileModifyDate(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.pickDateTimeFromSoftwareModifiedDate.word(), action: #selector(previewMenuPickSoftwareModifyDate(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.turn90clockwise.word(), action: #selector(previewMenuTurnRight(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.turn90counterClockwise.word(), action: #selector(previewMenuTurnLeft(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.turnUpsideDown.word(), action: #selector(previewMenuTurnUpsideDown(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.saveImageDirection.word(), action: #selector(previewMenuMarkRotateDirection(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.extractExif.word(), action: #selector(previewMenuExtractExif(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.extractDateTimeFromFilename.word(), action: #selector(previewMenuExtractDatetime(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.findFaces.word(), action: #selector(previewMenuFindFace(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.recognizeFaces.word(), action: #selector(previewMenuRecognizeFace(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.writeNotes.word(), action: #selector(previewMenuWriteNote(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.replaceImageWithBackupVersion.word(), action: #selector(previewMenuRestoreBackupImage(_:)), keyEquivalent: "")
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
                self.selectionViewController.openDatePicker(with: newValue)
                self.popNotification(message: Words.copiedDateToBatchDatePicker.word("%s", "\(newValue)"))
            }
        }
    }
    
    @objc func previewMenuPickFilenameDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "From Filename") {
            self.copyDateToBatchEditor(value: value, name: "Date in Filename")
        }else{
            self.popNotification(message: Words.error_imageMissingDateTimeInFilename.word())
        }
    }
    
    @objc func previewMenuPickDateTimeOriginal(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "DateTimeOriginal") {
            self.copyDateToBatchEditor(value: value, name: "DateTimeOriginal")
        }else{
            self.popNotification(message: Words.error_imageMissingDateTimeOriginal.word())
        }
    }
    
    @objc func previewMenuPickFileCreateDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "FileCreateDate") {
            self.copyDateToBatchEditor(value: value, name: "FileCreateDate")
        }else{
            self.popNotification(message: Words.error_imageMissingFileCreateDate.word())
        }
    }
    
    @objc func previewMenuPickFileModifyDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "FileModifyDate") {
            self.copyDateToBatchEditor(value: value, name: "FileModifyDate")
        }else{
            self.popNotification(message: Words.error_imageMissingFileModifyDate.word())
        }
    }
    
    @objc func previewMenuPickSoftwareModifyDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "Software Modified") {
            self.copyDateToBatchEditor(value: value, name: "SoftwareModifyDate")
        }else{
            self.popNotification(message: Words.error_imageMissingSoftwareModifyDate.word())
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
        self.popNotification(message: Words.info_doneExtractExif.word())
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
                
                self.popNotification(message: Words.info_doneExtractDateTimeFromFilename.word())
            }
        }else{

            self.popNotification(message: Words.error_extractDateTimeFromFilename.word())
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
            self.lblImageDescription.stringValue = Words.editableVersion.word()
        }
//        print("preview menu - done")
    }
    
    @objc func previewMenuPreviewBackupVersion(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let url = self.img.backupUrl {
            self.previewImage(url: url, isPhoto: self.img.isPhoto)
            DispatchQueue.main.async {
                self.lblImageDescription.stringValue = Words.backupVersion.word()
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

                            self.popNotification(message: Words.info_doneReplacedImageToBackupVersion.word())
                        }catch{
                            print("Unable to restore backup image from [\(backupUrl.path)] to [url.path]")
                            print(error)

                            self.popNotification(message: Words.error_replaceImageToBackupVersion.word())
                            
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
                        self.popNotification(message: Words.error_imageMissingBackupVersion.word())
                    }
                }else{
                    self.popNotification(message: Words.error_imageMissingEditableVersion.word())
                }
            }
            
        }
    }
    
    fileprivate func findFacesFromSelectedImage() {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        DispatchQueue.global().async {
            let _ = FaceTask.default.findFaces(path: url.path)
            self.popNotification(message: Words.info_doneFindingFaces.word())
        }
    }
    
    func recognizeFacesFromSelectedImage() {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        DispatchQueue.global().async {
            let _ = FaceTask.default.recognizeFaces(path: url.path)
            self.popNotification(message: Words.info_doneRecognizeFaces.word())
        }
    }
}
