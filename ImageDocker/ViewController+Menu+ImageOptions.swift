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
        self.btnImageOptions.menu?.addItem(withTitle: "Extract EXIF from image", action: #selector(previewMenuExtractExif(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Extract date time from filename", action: #selector(previewMenuExtractDatetime(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        self.btnImageOptions.menu?.addItem(withTitle: "Large View", action: #selector(previewMenuLargeView(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        self.btnImageOptions.menu?.addItem(withTitle: "Preview editable version", action: #selector(previewMenuPreviewEditableVersion(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Preview backup version", action: #selector(previewMenuPreviewBackupVersion(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        self.btnImageOptions.menu?.addItem(withTitle: "Find editable version from Finder", action: #selector(previewMenuFindEditableInFinder(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Find backup version from Finder", action: #selector(previewMenuFindBackupInFinder(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        self.btnImageOptions.menu?.addItem(withTitle: "Replace image with backup version", action: #selector(previewMenuReplaceWithBackupVersion(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        self.btnImageOptions.menu?.addItem(withTitle: "Pick date time from Filename", action: #selector(previewMenuPickFilenameDate(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Pick date time from FileCreateDate", action: #selector(previewMenuPickFileCreateDate(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Pick date time from FileModifyDate", action: #selector(previewMenuPickFileModifyDate(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Pick date time from Software Modified Date", action: #selector(previewMenuPickSoftwareModifyDate(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        self.btnImageOptions.menu?.addItem(withTitle: "Turn 90° clockwise", action: #selector(previewMenuTurnRight(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Turn -90° counter-clockwise", action: #selector(previewMenuTurnLeft(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Upside down", action: #selector(previewMenuTurnUpsideDown(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        self.btnImageOptions.menu?.addItem(withTitle: "Find faces", action: #selector(previewMenuFindFace(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(withTitle: "Recognize faces", action: #selector(previewMenuRecognizeFace(_:)), keyEquivalent: "")
        self.btnImageOptions.menu?.addItem(NSMenuItem.separator())
        self.btnImageOptions.menu?.addItem(withTitle: "Write notes", action: #selector(previewMenuWriteNote(_:)), keyEquivalent: "")
    }
    
    @objc func previewMenuReplaceWithBackupVersion(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuPickFilenameDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuPickFileCreateDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuPickFileModifyDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuPickSoftwareModifyDate(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuTurnRight(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuTurnLeft(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuTurnUpsideDown(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuFindFace(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuRecognizeFace(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuWriteNote(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
    }
    
    @objc func previewMenuAction(_ menuItem:NSMenuItem) {
        print("clicked prewview menu")
    }
    
    @objc func previewMenuExtractExif(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        self.loadImageExif()
    }
    
    @objc func previewMenuExtractDatetime(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        let dateString = Naming.DateTime.recognize(url: url)
        print("recognized date: \(dateString)")
        if dateString != "" {
            if self.img.imageData != nil {
                self.img.imageData?.dateTimeFromFilename = dateString
                if let dt = self.img.earliestDate() {
                    print("earliest date is \(dt) UTC")
                    self.img.storePhotoTakenDate(dateTime: dt)
                }
                self.img.save()
                self.loadImageExif()
            }
        }
    }
    
    @objc func previewMenuFindEditableInFinder(_ menuItem:NSMenuItem){
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @objc func previewMenuFindBackupInFinder(_ menuItem:NSMenuItem){
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @objc func previewMenuLargeView(_ menuItem:NSMenuItem){
        self.btnImageOptions.selectItem(at: 0)
        self.onCollectionViewItemQuickLook(self.img)
    }
    
    @objc func previewMenuPreviewEditableVersion(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        self.previewImage(url: url, isPhoto: self.img.isPhoto)
        DispatchQueue.main.async {
            self.lblImageDescription.stringValue = "EDITABLE VERSION"
        }
    }
    
    @objc func previewMenuPreviewBackupVersion(_ menuItem:NSMenuItem) {
        self.btnImageOptions.selectItem(at: 0)
        if let url = self.img.backupUrl {
            self.previewImage(url: url, isPhoto: self.img.isPhoto)
            DispatchQueue.main.async {
                self.lblImageDescription.stringValue = "BACKUP VERSION"
            }
        }
    }
    
    @objc func previewMenuRestoreBackupImage() {
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
                            print("Restoring backup image from [\(backupUrl.path)] to [url.path]")
                            try FileManager.default.createDirectory(atPath: tmpFolder, withIntermediateDirectories: true, attributes: nil)
                            try FileManager.default.moveItem(atPath: url.path, toPath: tmpPath)
                            try FileManager.default.copyItem(atPath: backupUrl.path, toPath: url.path)
                            
                            DispatchQueue.main.async {
                                self.lblImageDescription.stringValue = "RESTORED FROM BACKUP VERSION"
                            }
                        }catch{
                            print("Unable to restore backup image from [\(backupUrl.path)] to [url.path]")
                            print(error)
                            DispatchQueue.main.async {
                                self.lblImageDescription.stringValue = "RESTORE BACKUP VERSION FAILED"
                            }
                            print("Restoring original editable version from \(tmpPath)")
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
                        DispatchQueue.main.async {
                            self.lblImageDescription.stringValue = "BACKUP VERSION DOES NOT EXIST"
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.lblImageDescription.stringValue = "EDITABLE VERSION DOES NOT EXIST"
                    }
                }
            }
        }
    }
    
    fileprivate func findFaces() {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        DispatchQueue.global().async {
            FaceTask.default.findFaces(path: url.path)
        }
    }
    
    func recognizeFaces() {
        self.btnImageOptions.selectItem(at: 0)
        let url = self.img.url
        DispatchQueue.global().async {
            FaceTask.default.recognizeFaces(path: url.path)
        }
    }
}
