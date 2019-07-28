//
//  DevicePathDetailViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/4/5.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class DevicePathDetailViewController: NSViewController {
    
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
        let url = URL(fileURLWithPath: self.repositoryPath).appendingPathComponent(self.devicePath.toSubFolder)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    
    @IBAction func onManyChildrenClicked(_ sender: NSButton) {
        var data = self.devicePath!
        let state = self.chkManyChildren.state == .on
        data.manyChildren = state
        ModelStore.default.saveDevicePath(file: data)
        
        let containerPath = URL(fileURLWithPath: self.repositoryPath).appendingPathComponent(self.devicePath.toSubFolder).path
        print("CONTAINER TO BE UPDATED: \(containerPath)")
        ModelStore.default.updateImageContainerToggleManyChildren(path: containerPath, state: state)
        print("Updated expandable state to \(state ? "ON" : "OFF").")
        
        self.lblMessage.stringValue = "Updated expandable state to \(state ? "ON" : "OFF")."
    }
    
    
    @IBAction func onUpdateClicked(_ sender: NSButton) {
        guard self.txtSubFolder.stringValue != "" else {
            self.lblMessage.stringValue = "ERROR: Local folder cannot be empty."
            return
        }
        self.btnUpdate.isEnabled = false
        
        
        
        DispatchQueue.global().async {
            var data = self.devicePath!
            let oldLocalFolder = data.toSubFolder
            data.toSubFolder = self.txtSubFolder.stringValue.trimmingCharacters(in: .whitespaces)
            data.excludeImported = (self.chkExcludeImported.state == .on)
            
            print("deviceId=\(data.deviceId), old localFolder=\(oldLocalFolder), new localFolder=\(data.toSubFolder), repository=\(self.repositoryPath)")
            
            // apply changes to database when device path is decided to be excluded
            
            if data.excludeImported && self.repositoryPath.trimmingCharacters(in: .whitespaces) != "" {
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "Deleting related containers and images..."
                }
                let localPath = URL(fileURLWithPath: self.repositoryPath).appendingPathComponent(oldLocalFolder).path
                print("deleting container which local path=\(localPath)")
                ModelStore.default.deleteContainer(path: localPath)
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "Deleted related containers and images."
                }
            }
            
            // apply changes to database when device path's local folder to be renamed
            
            if !data.exclude && !data.excludeImported && oldLocalFolder != data.toSubFolder {
                print("changed local folder from [\(oldLocalFolder)] to [\(data.toSubFolder)]")
                
                let oldLocalPath = URL(fileURLWithPath: self.repositoryPath).appendingPathComponent(oldLocalFolder).path
                let newLocalPath = URL(fileURLWithPath: self.repositoryPath).appendingPathComponent(data.toSubFolder).path
                
                var isDir:ObjCBool = false
                var existNewPath = false
                if FileManager.default.fileExists(atPath: newLocalPath, isDirectory: &isDir) {
                    if isDir.boolValue {
                        existNewPath = true
                    }
                }
                if !existNewPath {
                    do {
                        try FileManager.default.createDirectory(atPath: newLocalPath, withIntermediateDirectories: true, attributes: nil)
                        existNewPath = true
                    }catch{
                        existNewPath = false
                        print("Unable to create directory for new local folder [\(data.toSubFolder)] at: \(newLocalPath)")
                        print(error)
                    }
                }
                if !existNewPath {
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = "Failed to change local folder: unable to access."
                    }
                }else{
                    print("TODO: UPDATE RELATED physical directory of IMAGE DEVICE FILES")
                    
                    //UPDATE RELATED physical directory of IMAGE DEVICE FILES
                    var renamedLocalFolder = false
                    do {
                        try FileManager.default.moveItem(atPath: oldLocalPath, toPath: newLocalPath)
                        renamedLocalFolder = true
                    }catch{
                        renamedLocalFolder = false
                        print("Unable to change local folder: failed to move/rename folder")
                        print(error)
                    }
                    if !renamedLocalFolder {
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Failed to change local folder: unable to rename folder."
                        }
                    }else{
                        print("TODO: UPDATE RELATED importToPath of IMAGE DEVICE FILES")
                        
                        // UPDATE RELATED importToPath of IMAGE DEVICE FILES
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updating imported files..."
                        }
                        let importedRecords = ModelStore.default.getDeviceFiles(deviceId: data.deviceId, importToPath: oldLocalPath)
                        if importedRecords.count > 0 {
                            DispatchQueue.main.async {
                                self.lblMessage.stringValue = "Updating imported files records...\(importedRecords.count)"
                            }
                            for record in importedRecords {
                                var rec = record
                                rec.importToPath = newLocalPath
                                ModelStore.default.saveDeviceFile(file: rec)
                            }
                        }
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updated imported files."
                        }
                        
                        print("TODO: UPDATE CONTAINERS and SUB-CONTAINERS")
                        // UPDATE container and sub-containers
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updating related containers..."
                        }
                        if let container = ModelStore.default.getContainer(path: oldLocalPath) {
                            var cont = container
                            cont.path = newLocalPath
                            cont.name = data.toSubFolder
                            cont.subPath = data.toSubFolder
                            
                            let subContainers = ModelStore.default.getContainers(rootPath: oldLocalPath)
                            if subContainers.count > 0 {
                                DispatchQueue.main.async {
                                    self.lblMessage.stringValue = "Updating related containers...\(subContainers.count+1)"
                                }
                                for subContainer in subContainers {
                                    var sub = subContainer
                                    sub.path = sub.path.replacingFirstOccurrence(of: oldLocalPath.withStash(), with: newLocalPath.withStash())
                                    sub.parentFolder = newLocalPath
                                    sub.subPath = sub.subPath.replacingFirstOccurrence(of: oldLocalFolder.withStash(), with: data.toSubFolder.withStash())
                                    ModelStore.default.saveImageContainer(container: sub)
                                }
                            }
                            ModelStore.default.saveImageContainer(container: cont)
                        }
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updated related containers."
                        }
                        
                        print("TODO: UPDATE RELATED path AND subpath of IMAGEs where IMAGE.path = (IMAGE DEVICE FILE.importToPath + importAsFilename)")
                        
                        // UPDATE RELATED path AND subpath of IMAGEs where IMAGE.path = (IMAGE DEVICE FILE.importToPath + importAsFilename)
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updating imported images in repository..."
                        }
                        
                        let images = ModelStore.default.getPhotoFiles(rootPath: oldLocalPath)
                        if images.count > 0 {
                            DispatchQueue.main.async {
                                self.lblMessage.stringValue = "Updating imported images in repository...\(images.count)"
                            }
                            for image in images {
                                var img = image
                                img.path = img.path.replacingFirstOccurrence(of: oldLocalPath.withStash(), with: newLocalPath.withStash())
                                if img.containerPath == oldLocalPath {
                                    // from the directory
                                    img.containerPath = newLocalPath
                                }else{
                                    // from sub-directories
                                    img.containerPath = img.containerPath?.replacingFirstOccurrence(of: oldLocalPath.withStash(), with: newLocalPath.withStash())
                                }
                                img.subPath = img.subPath.replacingFirstOccurrence(of: oldLocalFolder.withStash(), with: data.toSubFolder.withStash())
                                
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updated imported images in repository."
                        }
                        
                        
                        ModelStore.default.saveDevicePath(file: data)
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Updated local folder."
                        }
                    }
                }
                
                
            }
            
            DispatchQueue.main.async {
                self.btnUpdate.isEnabled = true
            }
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(nibName: NSNib.Name(rawValue: "DevicePathDetailViewController"), bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate var devicePath:ImageDevicePath!
    fileprivate var repositoryPath = ""
    
    func initView(_ devicePath:ImageDevicePath, _ repositoryPath:String) {
        self.repositoryPath = repositoryPath
        if let devPath = ModelStore.default.getDevicePath(deviceId: devicePath.deviceId, path: devicePath.path) {
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
                if repositoryPath.trimmingCharacters(in: .whitespaces) != "" {
                    self.btnGoto.isHidden = false
                }else{
                    self.btnGoto.isHidden = true
                }
                self.chkExcludeImported.isHidden = false
                self.chkExcludeImported.state = devPath.excludeImported ? .on : .off
            }
        }
    }
    
}
