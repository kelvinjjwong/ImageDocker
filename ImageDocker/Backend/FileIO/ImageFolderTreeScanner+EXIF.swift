//
//  ImageFolderTreeScanner+EXIF.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/14.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation

extension ImageFolderTreeScanner {
    
    // 3  (from RepositoryDetailView dialog)
    func scanPhotosToLoadExif(images:[Image], taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil) {
//        if suppressedScan {
//            if indicator != nil {
//                indicator?.forceComplete()
//            }
//            return
//        }
        
        self.logger.log("checking stop flag for task id \(taskId)")
        
        if TaskletManager.default.isTaskStopped(id: taskId) == true { return }
        
        self.logger.log("continue load exif")
        
        if indicator != nil {
            DispatchQueue.main.async {
                let _ = indicator?.add(Words.progress_meta_scan_loading_rules.word())
            }
        }
        
        TaskletManager.default.updateProgress(id: taskId, message: Words.progress_meta_scan_loading_rules.word(), increase: false)
        
        let excludedContainerPaths = DeviceDao.default.getExcludedImportedContainerPaths(withStash: true)
        
        self.logger.log("loaded excluded container paths")
        
        let photoCount = images.count
        
        if photoCount > 0 {
            self.logger.log("UPDATING EXIF: \(images.count)")
            if indicator != nil {
                indicator?.setTarget(photoCount)
            }

            TaskletManager.default.setTotal(id: taskId, total: photoCount)
            
            self.logger.log("set total \(photoCount)")
            
            var i = 0
            
            for photo in images {
                
                i += 1
                
//                if suppressedScan {
//                    if indicator != nil {
//                        indicator?.forceComplete()
//                    }
//                    return
//                }
                
                if TaskletManager.default.isTaskStopped(id: taskId) == true { return }
                
                var exclude = false
                for excludedPath in excludedContainerPaths {
                    if photo.path.hasPrefix(excludedPath) {
                        self.logger.log("Exclude image (exclude device path): \(photo.path)")
                        exclude = true
                        break
                    }
                }
                if !exclude {
                    let _ = ImageFile(image: photo, indicator: indicator, forceReloadExif: true) // FIXME: try to simplify
                }else{
                    if indicator != nil {
                        DispatchQueue.main.async {
                            let _ = indicator?.add(Words.progress_meta_scan_loading_images.word())
                        }
                    }
                }
                
                TaskletManager.default.updateProgress(id: taskId, message: Words.progress_meta_scan_images.fill(arguments: "\(i)", "\(photoCount)", photo.subPath), increase: true)
                self.logger.log("finished exif \(photo.subPath)")
            } // end of images-loop
            //ModelStore.save()
            self.logger.log("UPDATING EXIF: SAVE DONE")
        }else {
            if indicator != nil {
                indicator?.forceComplete()
            }
            TaskletManager.default.updateProgress(id: taskId, message: Words.extract_meta_no_need.word(), increase: false)
        }
        
        TaskletManager.default.forceComplete(id: taskId)
        
        if onCompleted != nil {
            onCompleted!()
        }
    }
    
    // 2  (from RepositoryDetailView dialog)
    func scanPhotosToLoadExif(repository:ImageRepository, taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil)  {
        if indicator != nil {
            DispatchQueue.main.async {
                let _ = indicator?.add(Words.exif_scan_loading_images.word())
            }
        }
        TaskletManager.default.updateProgress(id: taskId, message: Words.exif_scan_loading_images.word(), increase: false)
        let images = ImageSearchDao.default.getImagesWithoutExif(repositoryId: repository.id)
        self.logger.log("PHOTOS WITHOUT EXIF: \(images.count) - repository id:\(repository.id)")
        self.scanPhotosToLoadExif(images: images, taskId: taskId, indicator: indicator, onCompleted: onCompleted)
    }
    
    func scanPhotosToLoadExif(taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil)  {
        if indicator != nil {
            DispatchQueue.main.async {
                let _ = indicator?.add(Words.exif_scan_loading_images.word())
            }
        }
        TaskletManager.default.updateProgress(id: taskId, message: Words.exif_scan_loading_images.word(), increase: false)
        let images = ImageSearchDao.default.getPhotoFilesWithoutExif()
        self.logger.log("PHOTOS WITHOUT EXIF: \(images.count)")
        self.scanPhotosToLoadExif(images: images, taskId: taskId, indicator: indicator, onCompleted: onCompleted)
    }
    
    // 1  (from RepositoryDetailView dialog)
    func scanPhotosToLoadExif_asTask(repository:ImageRepository, indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil) {
        let _ = TaskletManager.default.createAndStartTask(type: "EXIF", name: repository.name
        , exec: { task in
            DispatchQueue.global().async {
                self.scanPhotosToLoadExif(repository: repository, taskId: task.id, indicator: indicator, onCompleted: onCompleted)
            }
        }, stop: {task in
            
        })
    }
}
