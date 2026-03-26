//
//  RepositoryDetailViewController+Status.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2026/3/26.
//  Copyright © 2026 nonamecat. All rights reserved.
//

import Cocoa

extension RepositoryDetailViewController {
    
    public func loadImportStatus(repositoryId: Int) {
        DispatchQueue.global().async {
            if let repository = RepositoryDao.default.getRepository(id: repositoryId) {
                
                self._repositoryName = repository.name
                
                var lastDateCopiedFromDevice = ImageCountDao.default.lastDateCopiedFromDevice(deviceId: repository.deviceId)
                
                //var isAndroid = false
                if let device = self.loadDeviceInfo(repository: repository) {
                    
                    if lastDateCopiedFromDevice == nil {
                        if device.type == Naming.Device.iPhone {
                            let storagePath = Naming.Image.generateFullAbsoluteRepositoryPath(repositoryVolume: repository.storageVolume, repositoryPath: repository.storagePath)
                            let path = URL(fileURLWithPath: storagePath).appending(path: "Camera")
                            if let latestSubFolder = LocalDirectory.bridge.getLatestSubFolder(path: path.path()) {
                                let folderPath = path.appending(path: latestSubFolder)
                                if let latestFile = LocalDirectory.bridge.getLatestFile(path: folderPath.path()) {
        
                                    lastDateCopiedFromDevice = latestFile.0
                                    
                                }
                            }
                        }
                    }
                }
                
                let countCopiedFromDevice = ImageCountDao.default.countCopiedFromDevice(deviceId: repository.deviceId)
                let countShouldImport = ImageCountDao.default.countImagesShouldImport(deviceId: repository.deviceId)
//                let countImported = ImageCountDao.default.countImportedAsEditable(repositoryPath: "\(repository.repositoryVolume)\(repository.repositoryPath)")
                let countImported = ImageCountDao.default.countImportedAsEditable(deviceId: repository.deviceId)
                let countExtractedExif = ImageCountDao.default.countExtractedExif(repositoryId: repository.id)
                let countRecognizedLocation = ImageCountDao.default.countRecognizedLocation(repositoryId: repository.id)
                let countRecognizedFaces = ImageCountDao.default.countRecognizedFaces(repositoryId: repository.id)
                
                DispatchQueue.main.async {
                    self.lblCopiedFromDevice.stringValue = "\(countCopiedFromDevice)"
                    self.lblShouldImport.stringValue = "\(countShouldImport)"
                    self.lblImported.stringValue = "\(countImported)"
                    self.lblExif.stringValue = "\(countExtractedExif)"
                    self.lblLocation.stringValue = "\(countRecognizedLocation)"
                    self.lblFaces.stringValue = "\(countRecognizedFaces)"
                    
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    
                    if let lastDateCopiedFromDevice = lastDateCopiedFromDevice {
                        self.lblLastDateCopiedFromDevice.stringValue = "\(dateFormatter.string(from: lastDateCopiedFromDevice))"
                    }else{
                        self.lblLastDateCopiedFromDevice.stringValue = ""
                    }
                    
                    var rateCopied = 0.0
                    var rateShouldImport = 0.0
                    var rateImported = 0.0
                    var rateExif = 0.0
                    var rateLocation = 0.0
                    var rateFaces = 0.0
                    
                    let denominator = Double((countCopiedFromDevice == 0) ? countImported : countCopiedFromDevice)
                    if denominator > 0 {
                        rateCopied = (countCopiedFromDevice == 0) ? 0.0 : 1.0
                        rateShouldImport = (countCopiedFromDevice == 0) ? 0.0 : (Double(countShouldImport) / Double(countCopiedFromDevice) )
                        rateImported = (countCopiedFromDevice == 0) ? 1.0 : (Double(countImported) / denominator)
                        rateExif = Double(countExtractedExif) / denominator
                        rateLocation = Double(countRecognizedLocation) / denominator
                        rateFaces = Double(countRecognizedFaces) / denominator
                    }
                    
                    self.indCopiedFromDevice.doubleValue = rateCopied * 100
                    self.indShouldImport.doubleValue = rateShouldImport * 100
                    self.indImported.doubleValue = rateImported * 100
                    self.indExif.doubleValue = rateExif * 100
                    self.indLocation.doubleValue = rateLocation * 100
                    self.indFaces.doubleValue = rateFaces * 100
                }
                
                if let _ = TaskletManager.default.searchRunningTask(name: repository.name) {
                    self.toggleButtons(false)
                }else{
                    self.toggleButtons(true)
                }
            }
        }
    }
}
