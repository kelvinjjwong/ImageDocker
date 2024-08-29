//
//  DevicePathDetailViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/4/5.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class DevicePathDetailViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "DevicePathDetailViewController")
    
    // MARK: CONTROLS
    @IBOutlet weak var lblPath: NSTextField!
    @IBOutlet weak var chkExclude: NSButton!
    @IBOutlet weak var lblSubFolder: NSTextField!
    @IBOutlet weak var txtSubFolder: NSTextField!
    @IBOutlet weak var chkManyChildren: NSButton!
    @IBOutlet weak var btnUpdate: NSButton!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var chkExcludeImported: NSButton!
    
    @IBOutlet weak var btnGoto: NSButton!
    
    // MARK: ACTIONS
    
    @IBAction func onGotoClicked(_ sender: NSButton) {
        let repository = self.repository!
        let url = URL(fileURLWithPath: "\(repository.storageVolume)\(repository.storagePath)").appendingPathComponent(self.devicePath.toSubFolder)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    
    @IBAction func onManyChildrenClicked(_ sender: NSButton) {
        let data = self.devicePath!
        let repository = self.repository!
        let state = self.chkManyChildren.state == .on
        data.manyChildren = state
        let _ = DeviceDao.default.saveDevicePath(file: data)
        
        let containerPath = URL(fileURLWithPath: "\(repository.storageVolume)\(repository.storagePath)").appendingPathComponent(self.devicePath.toSubFolder).path
//        self.logger.log("CONTAINER TO BE UPDATED: \(containerPath)")
        let _ = RepositoryDao.default.updateImageContainerToggleManyChildren(path: containerPath, state: state)
//        self.logger.log("Updated expandable state to \(state ? "ON" : "OFF").")
        
        self.lblMessage.stringValue = "Updated expandable state to \(state ? "ON" : "OFF")."
    }
    
    @IBAction func onExcludeImportedClicked(_ sender: NSButton) {
    }
    
    
    
    @IBAction func onUpdateClicked(_ sender: NSButton) {
        guard self.txtSubFolder.stringValue != "" else {
            self.lblMessage.stringValue = "ERROR: Local folder cannot be empty."
            return
        }
        self.btnUpdate.isEnabled = false
        
        let repository = self.repository!
        
        let data = self.devicePath!
        let oldLocalFolder = data.toSubFolder
        data.toSubFolder = self.txtSubFolder.stringValue.trimmingCharacters(in: .whitespaces)
        data.excludeImported = (self.chkExcludeImported.state == .on)
        data.manyChildren = (self.chkManyChildren.state == .on)
        
//        self.logger.log("deviceId=\(data.deviceId), old localFolder=\(oldLocalFolder), new localFolder=\(data.toSubFolder), repository=\(self.repositoryPath)")
        
        DispatchQueue.global().async {
            
            if data.toSubFolder == oldLocalFolder {
                // subfolder unchanged
                let _ = DeviceDao.default.saveDevicePath(file: data)
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "Saved toggles."
                }
            }
            
            // apply changes to database when device path is decided to be excluded
            
//            if data.excludeImported && self.repositoryPath.trimmingCharacters(in: .whitespaces) != "" {
//                DispatchQueue.main.async {
//                    self.lblMessage.stringValue = "Deleting related containers and images..."
//                }
//                //let localPath = URL(fileURLWithPath: self.repositoryPath).appendingPathComponent(oldLocalFolder).path
//                //self.logger.log("deleting container which local path=\(localPath)")
//                //let state1 = ModelStore.default.deleteContainer(path: localPath)
//                let state = ModelStore.default.saveDevicePath(file: data)
//                if state != .OK {
//                    DispatchQueue.main.async {
//                        self.lblMessage.stringValue = "\(state) - Unable to update setting."
//                    }
//                }else{
//                    // physically delete path in disk
////                    do {
////                        try
////                            FileManager.default.removeItem(atPath: localPath)
////                            DispatchQueue.main.async {
////                                self.lblMessage.stringValue = "Deleted related containers and imported images."
////                            }
////                    }catch{
////                        DispatchQueue.main.async {
////                            self.lblMessage.stringValue = "Unable to delete path in disk."
////                        }
////                        self.logger.log("Unable to delete path in disk: \(localPath)")
////                        self.logger.log(error)
////                    }
//                }
//            }
            
            // apply changes to database when device path's local folder to be renamed
            
            if !data.exclude && !data.excludeImported && oldLocalFolder != data.toSubFolder {
//                self.logger.log("changed local folder from [\(oldLocalFolder)] to [\(data.toSubFolder)]")
                
                let oldLocalPath = URL(fileURLWithPath: "\(repository.storageVolume)\(repository.storagePath)").appendingPathComponent(oldLocalFolder).path
                let newLocalPath = URL(fileURLWithPath: "\(repository.storageVolume)\(repository.storagePath)").appendingPathComponent(data.toSubFolder).path
                
                if !newLocalPath.isDirectoryExists() {
                    let (created, error) = newLocalPath.mkdirs(logger: self.logger)
                    if !created {
                        self.logger.log("Unable to create directory for new local folder [\(data.toSubFolder)] at: \(newLocalPath)")
                    }
                }
                if !newLocalPath.isDirectoryExists() {
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = "Failed to change local folder: unable to access."
                    }
                }else{
//                    self.logger.log("TODO: UPDATE RELATED physical directory of IMAGE DEVICE FILES")
                    
                    //UPDATE RELATED physical directory of IMAGE DEVICE FILES
                    let (created, error) = oldLocalPath.moveFile(to: newLocalPath, logger: self.logger)
                    if !created {
                        self.logger.log("Unable to change local folder: failed to move/rename folder - \(error)")
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Failed to change local folder: unable to rename folder - \(error)"
                        }
                    }else{
//                        self.logger.log("TODO: UPDATE RELATED importToPath of IMAGE DEVICE FILES")
                        
                        // UPDATE RELATED importToPath of IMAGE DEVICE FILES
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updating imported files..."
                        }
                        let importedRecords = DeviceDao.default.getDeviceFiles(deviceId: data.deviceId, importToPath: oldLocalPath)
                        if importedRecords.count > 0 {
                            DispatchQueue.main.async {
                                self.lblMessage.stringValue = "Updating imported files records...\(importedRecords.count)"
                            }
                            for record in importedRecords {
                                var rec = record
                                rec.importToPath = newLocalPath
                                let _ = DeviceDao.default.saveDeviceFile(file: rec)
                            }
                        }
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updated imported files."
                        }
                        
//                        self.logger.log("TODO: UPDATE CONTAINERS and SUB-CONTAINERS")
                        // UPDATE container and sub-containers
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updating related containers..."
                        }
                        if let container = RepositoryDao.default.getContainer(path: oldLocalPath) {
                            let cont = container
                            cont.path = newLocalPath
                            cont.name = data.toSubFolder
                            cont.subPath = data.toSubFolder
                            
                            let subContainers = RepositoryDao.default.getContainers(rootPath: oldLocalPath)
                            if subContainers.count > 0 {
                                DispatchQueue.main.async {
                                    self.lblMessage.stringValue = "Updating related containers...\(subContainers.count+1)"
                                }
                                for subContainer in subContainers {
                                    let sub = subContainer
                                    sub.path = sub.path.replacingFirstOccurrence(of: oldLocalPath.withLastStash(), with: newLocalPath.withLastStash())
                                    sub.parentFolder = newLocalPath
                                    sub.subPath = sub.subPath.replacingFirstOccurrence(of: oldLocalFolder.withLastStash(), with: data.toSubFolder.withLastStash())
                                    let _ = RepositoryDao.default.saveImageContainer(container: sub)
                                }
                            }
                            let _ = RepositoryDao.default.saveImageContainer(container: cont)
                        }
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updated related containers."
                        }
                        
//                        self.logger.log("TODO: UPDATE RELATED path AND subpath of IMAGEs where IMAGE.path = (IMAGE DEVICE FILE.importToPath + importAsFilename)")
                        
                        // UPDATE RELATED path AND subpath of IMAGEs where IMAGE.path = (IMAGE DEVICE FILE.importToPath + importAsFilename)
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updating imported images in repository..."
                        }
                        
                        let images = ImageSearchDao.default.getPhotoFiles(rootPath: oldLocalPath)
                        if images.count > 0 {
                            DispatchQueue.main.async {
                                self.lblMessage.stringValue = "Updating imported images in repository...\(images.count)"
                            }
                            for image in images {
                                let img = image
                                img.path = img.path.replacingFirstOccurrence(of: oldLocalPath.withLastStash(), with: newLocalPath.withLastStash())
                                if img.containerPath == oldLocalPath {
                                    // from the directory
                                    img.containerPath = newLocalPath
                                }else{
                                    // from sub-directories
                                    img.containerPath = img.containerPath?.replacingFirstOccurrence(of: oldLocalPath.withLastStash(), with: newLocalPath.withLastStash())
                                }
                                img.subPath = img.subPath.replacingFirstOccurrence(of: oldLocalFolder.withLastStash(), with: data.toSubFolder.withLastStash())
                                
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updated imported images in repository."
                        }
                        
                        
                        let _ = DeviceDao.default.saveDevicePath(file: data)
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updated local folder."
                        }
                    } // end of if renamedLocalFolder
                } // end of if existNewPath
                
                
            } // end of !data.exclude && !data.excludeImported && oldLocalFolder != data.toSubFolder
            
            DispatchQueue.main.async {
                self.btnUpdate.isEnabled = true
            }
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(nibName: "DevicePathDetailViewController", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate var devicePath:ImageDevicePath!
    fileprivate var repository:ImageRepository?
    
    func initView(_ devicePath:ImageDevicePath, repository:ImageRepository) {
        self.repository = repository
        if let devPath = DeviceDao.default.getDevicePath(deviceId: devicePath.deviceId, path: devicePath.path) {
            self.lblMessage.stringValue = ""
            self.lblMessage.isHidden = false
            self.progressIndicator.isHidden = true
            self.devicePath = devPath
            self.lblPath.stringValue = devPath.path
            if devPath.exclude {
                self.chkExclude.isHidden = false
                self.chkExclude.state = .on
                self.chkExclude.isEnabled = false
                self.lblSubFolder.isHidden = true
                self.txtSubFolder.isHidden = true
                self.txtSubFolder.stringValue = ""
                self.chkManyChildren.isHidden = true
                self.chkManyChildren.state = .off
                self.btnUpdate.isHidden = true
                self.btnGoto.isHidden = true
                self.chkExcludeImported.isHidden = true
                self.chkExcludeImported.state = .off
            }else{
                self.chkExclude.isHidden = true
                self.chkExclude.state = .off
                self.chkExclude.isEnabled = false
                self.lblSubFolder.isHidden = false
                self.txtSubFolder.isHidden = false
                self.txtSubFolder.stringValue = devPath.toSubFolder
                self.chkManyChildren.isHidden = false
                self.chkManyChildren.state = devPath.manyChildren ? .on : .off
                self.btnUpdate.isHidden = false
                self.btnGoto.isHidden = false
                self.chkExcludeImported.isHidden = false
                self.chkExcludeImported.state = devPath.excludeImported ? .on : .off
            }
            
            
        }
    }
    
}
