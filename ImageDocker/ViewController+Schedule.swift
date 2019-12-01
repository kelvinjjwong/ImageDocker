//
//  ViewController+Schedule.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func startSchedules() {
//        self.scanLocationChangeTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block:{_ in
//            guard TaskManager.allowRefreshTrees() else {return}
//            print("\(Date()) SCANING LOCATION CHANGE")
//            if self.lastCheckLocationChange != nil {
//                let photoFiles:[Image] = ModelStore.default.getPhotoFiles(after: self.lastCheckLocationChange!)
//                if photoFiles.count > 0 {
//                    self.saveTreeItemsExpandState()
//                    self.refreshLocationTree()
//                    self.restoreTreeItemsExpandState()
//                    self.restoreTreeSelection()
//                    self.lastCheckLocationChange = Date()
//                }
//            }
//        })
        
//        self.scanPhotoTakenDateChangeTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block:{_ in
//            guard TaskManager.allowRefreshTrees() else {return}
//            print("\(Date()) SCANING DATE CHANGE")
//            if self.lastCheckPhotoTakenDateChange != nil {
//                let photoFiles:[Image] = ModelStore.default.getPhotoFiles(after: self.lastCheckPhotoTakenDateChange!)
//                if photoFiles.count > 0 {
//                    self.saveTreeItemsExpandState()
//                    self.refreshMomentTree()
//                    self.restoreTreeItemsExpandState()
//                    self.restoreTreeSelection()
//                    self.lastCheckPhotoTakenDateChange = Date()
//                }
//            }
//        })
        
//        self.scanEventChangeTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block:{_ in
//            guard TaskManager.allowRefreshTrees() else {return}
//            print("\(Date()) SCANING EVENT CHANGE")
//            if self.lastCheckEventChange != nil {
//                let photoFiles:[Image] = ModelStore.default.getPhotoFiles(after: self.lastCheckEventChange!)
//                if photoFiles.count > 0 {
//                    self.saveTreeItemsExpandState()
//                    self.refreshEventTree()
//                    self.restoreTreeItemsExpandState()
//                    self.restoreTreeSelection()
//                    self.lastCheckEventChange = Date()
//                }
//            }
//        })
        
        self.exportPhotosTimers = Timer.scheduledTimer(withTimeInterval: 600, repeats: true, block:{_ in
            print("\(Date()) TRYING TO EXPORT \(self.suppressedExport)")
            guard TaskManager.allowExport() else {return}
            print("\(Date()) EXPORT FUNCTION WAITING FOR UPDATE")
//            DispatchQueue.global().async {
////                ExportManager.default.export(after: self.lastExportPhotos!)
////                self.lastExportPhotos = Date()
//            }
        })
        
        //        self.scanRepositoriesTimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true, block:{_ in
        //            print("\(Date()) TRY TO SCAN REPOS")
        //            guard !self.suppressedScan && !ExportManager.default.working && !self.scaningRepositories && !self.creatingRepository else {return}
        //            print("\(Date()) SCANING REPOS")
        //            self.startScanRepositories()
        //        })
        
        self.scanPhotosToLoadExifTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block:{_ in
            print("\(Date()) TRY TO SCAN PHOTO TO LOAD EXIF")
            guard !self.suppressedScan && TaskManager.allowReadImagesExif() else { return }
            print("\(Date()) SCANING PHOTOS TO LOAD EXIF")
            self.startScanRepositoriesToLoadExif()
        })
    }
}
