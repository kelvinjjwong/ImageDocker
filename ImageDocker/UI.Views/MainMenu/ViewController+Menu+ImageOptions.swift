//
//  ViewController+Menu+ImageOptions.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/1.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func setupPreviewMenu(isVideo:Bool = false) {
        self.btnImageOptions.menu?.items.removeAll()
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.imageOption.word(), action: nil, keyEquivalent: "")
        
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
//        self.btnImageOptions.menu?.addItem(withTitle: Words.saveImageDirection.word(), action: #selector(previewMenuMarkRotateDirection(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.extractExif.word(), action: #selector(previewMenuExtractExif(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: Words.extractDateTimeFromFilename.word(), action: #selector(previewMenuExtractDatetime(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
//        self.btnImageOptions.menu?.addItem(withTitle: Words.findFaces.word(), action: #selector(previewMenuFindFace(_:)), keyEquivalent: "")
//        self.btnImageOptions.menu?.addItem(withTitle: Words.recognizeFaces.word(), action: #selector(previewMenuRecognizeFace(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.writeNotes.word(), action: #selector(previewMenuWriteNote(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.replaceImageWithBackupVersion.word(), action: #selector(previewMenuRestoreBackupImage(_:)), keyEquivalent: "")
        
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        
        self.btnImageOptions.menu?.addItem(withTitle: Words.rescanImageExif.word(), action: #selector(rescanImageExif(_:)), keyEquivalent: "")
    }
    
    @objc func rescanImageExif(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        
        if let imageFile = self.img {
            let url = imageFile.url
            logger.log("preview menu - rescan image exif - \(url)")
            if let image = imageFile.imageData {
                let i = ImageFile(image: image, forceReloadExif: true)
                
                // FIXME: function for rescan exif
                print(i.location.latitude)
                print(i.location.longitude)
                print(i.location.latitudeBD)
                print(i.location.longitudeBD)
            }
        }
        
    }
    
    @objc func previewMenuWriteNote(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        // FIXME: write note
        logger.log("preview menu - to do function")
    }
    
    @objc func previewMenuTurnRight(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        self.imagePreviewController.rotateImage(rotateDegree: -90)
    }
    
    @objc func previewMenuTurnLeft(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        self.imagePreviewController.rotateImage(rotateDegree: +90)
    }
    
    @objc func previewMenuTurnUpsideDown(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        self.imagePreviewController.rotateImage(rotateDegree: +180)
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
                MessageEventCenter.default.showMessage(type: "BATCH_EDITOR", name: "DATE_COPIER", message: Words.copiedDateToBatchDatePicker.word("%s", "\(newValue)"))
            }
        }
    }
    
    @objc func previewMenuPickFilenameDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "From Filename") {
            self.copyDateToBatchEditor(value: value, name: "Date in Filename")
        }else{
            MessageEventCenter.default.showMessage(type: "IMAGE", name: "DATE_PICKER", message: Words.error_imageMissingDateTimeInFilename.word())
        }
    }
    
    @objc func previewMenuPickDateTimeOriginal(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "DateTimeOriginal") {
            self.copyDateToBatchEditor(value: value, name: "DateTimeOriginal")
        }else{
            MessageEventCenter.default.showMessage(type: "IMAGE", name: "DATE_PICKER", message: Words.error_imageMissingDateTimeOriginal.word())
        }
    }
    
    @objc func previewMenuPickFileCreateDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "FileCreateDate") {
            self.copyDateToBatchEditor(value: value, name: "FileCreateDate")
        }else{
            MessageEventCenter.default.showMessage(type: "IMAGE", name: "DATE_PICKER", message: Words.error_imageMissingFileCreateDate.word())
        }
    }
    
    @objc func previewMenuPickFileModifyDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "FileModifyDate") {
            self.copyDateToBatchEditor(value: value, name: "FileModifyDate")
        }else{
            MessageEventCenter.default.showMessage(type: "IMAGE", name: "DATE_PICKER", message: Words.error_imageMissingFileModifyDate.word())
        }
    }
    
    @objc func previewMenuPickSoftwareModifyDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let value = self.img.metaInfoHolder.getMeta(category: "DateTime", subCategory: "", title: "Software Modified") {
            self.copyDateToBatchEditor(value: value, name: "SoftwareModifyDate")
        }else{
            MessageEventCenter.default.showMessage(type: "IMAGE", name: "DATE_PICKER", message: Words.error_imageMissingSoftwareModifyDate.word())
        }
    }
    
//    @objc func previewMenuFindFace(_ menuItem:NSMenuItem) {
//        self.findFacesFromSelectedImage()
//    }
//    
//    @objc func previewMenuRecognizeFace(_ menuItem:NSMenuItem) {
//        self.recognizeFacesFromSelectedImage()
//    }
    
    @objc func previewMenuExtractExif(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        self.loadImageExif()
        MessageEventCenter.default.showMessage(type: "IMAGE", name: "EXIF_EXTRACTOR", message: Words.info_doneExtractExif.word())
//        self.logger.log("preview menu - done")
    }
    
    @objc func previewMenuExtractDatetime(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        let dateString = Naming.DateTime.recognize(url: url)
//        self.logger.log("recognized date: \(dateString)")
        if dateString != "" {
            if self.img.imageData != nil {
                self.img.imageData?.dateTimeFromFilename = dateString
                if let dt = self.img.earliestDate() {
//                    self.logger.log("earliest date is \(dt) UTC")
                    self.img.storePhotoTakenDate(dateTime: dt)
                }
                self.logger.log(.trace, "[previewMenuExtractDatetime] save image record - \(self.img.imageData?.path ?? "")")
                let _ = self.img.save()
                self.loadImageExif()
                
                MessageEventCenter.default.showMessage(type: "BATCH_EDITOR", name: "DATE_EXTRACTOR", message: Words.info_doneExtractDateTimeFromFilename.word())
            }
        }else{

            MessageEventCenter.default.showMessage(type: "BATCH_EDITOR", name: "DATE_EXTRACTOR", message: Words.error_extractDateTimeFromFilename.word())
        }
//        self.logger.log("preview menu - done")
    }
    
    @objc func previewMenuFindEditableInFinder(_ menuItem:NSMenuItem){
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        NSWorkspace.shared.activateFileViewerSelecting([url])
//        self.logger.log("preview menu - done")
    }
    
    @objc func previewMenuFindBackupInFinder(_ menuItem:NSMenuItem){
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        NSWorkspace.shared.activateFileViewerSelecting([url])
//        self.logger.log("preview menu - done")
    }
    
    @objc func previewMenuLargeView(_ menuItem:NSMenuItem){
        self.btnImageOptions.selectItem(at: 0)
        self.onCollectionViewItemQuickLook(self.img)
//        self.logger.log("preview menu - done")
    }
    
    @objc func previewMenuPreviewEditableVersion(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        self.previewImage(image: self.img, isRawVersion: false)
        DispatchQueue.main.async {
            self.lblImageDescription.stringValue = Words.editableVersion.word()
        }
//        self.logger.log("preview menu - done")
    }
    
    @objc func previewMenuPreviewBackupVersion(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let url = self.img.backupUrl {
            self.previewImage(image: self.img, isRawVersion: true)
            DispatchQueue.main.async {
                self.lblImageDescription.stringValue = Words.backupVersion.word()
            }
        }
//        self.logger.log("preview menu - done")
    }
    
    @objc func previewMenuRestoreBackupImage(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        DispatchQueue.global().async {
            if let imageFile = self.img {
                let url = imageFile.url
                if url.path.isFileExists() {
                    if let backupUrl = imageFile.backupUrl, backupUrl.path.isFileExists() {
                        
                        let uuid = UUID().uuidString
                        let filename = imageFile.fileName
                        let tmpFolder = "/tmp/\(uuid)"
                        let tmpPath = "\(tmpFolder)/\(filename)"
                        do {
//                            self.logger.log("Restoring backup image from [\(backupUrl.path)] to [url.path]")
                            try FileManager.default.createDirectory(atPath: tmpFolder, withIntermediateDirectories: true, attributes: nil)
                            try FileManager.default.moveItem(atPath: url.path, toPath: tmpPath)
                            try FileManager.default.copyItem(atPath: backupUrl.path, toPath: url.path)

                            MessageEventCenter.default.showMessage(type: "IMAGE", name: "RESTORE_BACKUP", message: Words.info_doneReplacedImageToBackupVersion.word())
                        }catch{
                            self.logger.log("Unable to restore backup image from [\(backupUrl.path)] to [url.path]")
                            self.logger.log(error)

                            MessageEventCenter.default.showMessage(type: "IMAGE", name: "RESTORE_BACKUP", message: Words.error_replaceImageToBackupVersion.word())
                            
//                            self.logger.log("Restoring original editable version from \(tmpPath)")
                            do {
                                try FileManager.default.removeItem(atPath: url.path)
                                try FileManager.default.moveItem(atPath: tmpPath, toPath: url.path)
                            }catch{
                                MessageEventCenter.default.showMessage(type: "IMAGE", name: "RESTORE_BACKUP", message: "Unable to restore original editable version from [\(tmpPath)] to [\(url.path)]")
                                self.logger.log(error)
                            }
                        }
                        do {
                            try FileManager.default.removeItem(atPath: tmpPath)
                            try FileManager.default.removeItem(atPath: tmpFolder)
                        }catch{
                            self.logger.log(error)
                        }
                    }else{
                        MessageEventCenter.default.showMessage(type: "IMAGE", name: "RESTORE_BACKUP", message: Words.error_imageMissingBackupVersion.word())
                    }
                }else{
                    MessageEventCenter.default.showMessage(type: "IMAGE", name: "RESTORE_BACKUP", message: Words.error_imageMissingEditableVersion.word())
                }
            }
            
        }
    }
    
//    fileprivate func findFacesFromSelectedImage() {
//        self.btnImageOptions.selectItem(at: 0)
//        let url = self.img.url
//        DispatchQueue.global().async {
//            let _ = FaceTask.default.findFaces(path: url.path)
//            MessageEventCenter.default.showMessage(type: "IMAGE", name:"FACE_SCANNER", message: Words.info_doneFindingFaces.word())
//        }
//    }
//
//    func recognizeFacesFromSelectedImage() {
//        self.btnImageOptions.selectItem(at: 0)
//        let url = self.img.url
//        DispatchQueue.global().async {
//            let _ = FaceTask.default.recognizeFaces(path: url.path)
//            MessageEventCenter.default.showMessage(type: "IMAGE", name:"FACE_SCANNER", message: Words.info_doneRecognizeFaces.word())
//        }
//    }
}
