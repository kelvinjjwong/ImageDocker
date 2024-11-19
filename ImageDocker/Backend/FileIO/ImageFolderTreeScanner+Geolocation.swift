//
//  ImageFolderTreeScanner+Geolocation.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/14.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Foundation

extension ImageFolderTreeScanner {
    
    func scanPhotosToLoadLocation(repository:ImageContainer, taskId:String = "", indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil)  {
        if indicator != nil {
            DispatchQueue.main.async {
                let _ = indicator?.add(Words.location_scan_loading_images.word())
            }
        }
        TaskletManager.default.updateProgress(id: taskId, message: Words.location_scan_loading_images.word(), increase: false)
        let images = ImageSearchDao.default.getPhotoFilesWithoutLocation(repositoryPath: repository.repositoryPath)
        self.logger.log(.trace, "PHOTOS WITHOUT LOCATION: \(images.count) - \(repository.name)")
        self.scanPhotosToLoadExif(images: images, taskId: taskId, indicator: indicator, onCompleted: onCompleted)
    }
    
    func scanPhotosToLoadLocation_asTask(repository:ImageContainer, indicator:Accumulator? = nil, onCompleted: (() -> Void)? = nil) {
        let _ = TaskletManager.default.createAndStartTask(type: "LOCATION", name: repository.name
        , exec: { task in
            DispatchQueue.global().async {
                self.scanPhotosToLoadLocation(repository: repository, taskId: task.id, indicator: indicator, onCompleted: onCompleted)
            }
        }, stop: {task in
            
        })
    }
}
