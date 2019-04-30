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
        var data = self.devicePath!
        data.toSubFolder = self.txtSubFolder.stringValue.trimmingCharacters(in: .whitespaces)
        
        // TODO: UPDATE RELATED physical directory of IMAGE DEVICE FILES
        // TODO: UPDATE RELATED importToPath of IMAGE DEVICE FILES
        // TODO: UPDATE RELATED path AND subpath of IMAGEs where IMAGE.path = (IMAGE DEVICE FILE.importToPath + importAsFilename)
        ModelStore.default.saveDevicePath(file: data)
        self.lblMessage.stringValue = "Updated local folder."
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
            }
        }
    }
    
}
