//
//  RepositoryDetailViewController+Size.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/26.
//  Copyright © 2026 nonamecat. All rights reserved.
//

import Cocoa

extension RepositoryDetailViewController {
    
    public func loadDiskSize() {
        DispatchQueue.global().async {
            if let repository = RepositoryDao.default.getRepository(id: self._repositoryId) {
                
                let (repoSize, _, _, repoDetail) = LocalDirectory.bridge.getDiskSpace(path: "\(repository.repositoryVolume)\(repository.repositoryPath)", lblDiskFree: self.lblRepoFree, lblDiskOccupied: self.lblEditableStorageSpace)
                self.repoSpace = repoDetail
                
                let (backupSize, _, _, backupDetail) = LocalDirectory.bridge.getDiskSpace(path: "\(repository.storageVolume)\(repository.storagePath)", lblDiskFree: self.lblBackupFree, lblDiskOccupied: self.lblBackupSpace)
                self.backupSpace = backupDetail
                
                let (faceSize, _, _, faceDetail) = LocalDirectory.bridge.getDiskSpace(path: "\(repository.cropVolume)\(repository.cropPath)", lblDiskFree: self.lblCropFree, lblDiskOccupied: self.lblCropSpace)
                self.faceSpace = faceDetail
                
                let totalSizeGB:Double = repoSize + backupSize + faceSize
                DispatchQueue.main.async {
                    self.lblTotalSize.stringValue = "\(totalSizeGB) G"
                }
                
                DispatchQueue.main.async {
                    self.txtDetail.string = ""
                }
            }else{
                if let repository = self.repository {
                    DispatchQueue.main.async {
                        self.txtDetail.string = "\(Words.library_tree_cannot_find_selected_repository_in_db.word()): \(Naming.Image.generateFullAbsoluteRepositoryPath(repositoryVolume: repository.repositoryVolume, repositoryPath: repository.repositoryPath))"
                    }
                }
            }
        }
    }
    
}
