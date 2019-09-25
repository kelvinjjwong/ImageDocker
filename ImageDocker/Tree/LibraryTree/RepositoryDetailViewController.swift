//
//  RepositoryDetailViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/25.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class RepositoryDetailViewController: NSViewController {
    
    @IBOutlet weak var btnConfig: NSButton!
    @IBOutlet weak var lblEditableStorageSpace: NSTextField!
    @IBOutlet weak var lblBackupSpace: NSTextField!
    @IBOutlet weak var lblCropSpace: NSTextField!
    @IBOutlet var txtDetail: NSTextView!
    
    
    // MARK: INIT VIEW
    
    init() {
        super.init(nibName: NSNib.Name(rawValue: "RepositoryDetailViewController"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtDetail.isEditable = false
        self.txtDetail.isHidden = true
    }
    
    var repoSpace:[String:String] = [:]
    var backupSpace:[String:String] = [:]
    var faceSpace:[String:String] = [:]
    
    fileprivate var onConfigure: (() -> Void)!
    
    
    func initView(path:String, onConfigure: @escaping (() -> Void)) {
        self.txtDetail.string = "Calculating ..."
        self.onConfigure = onConfigure
        self.txtDetail.isHidden = true
        self.lblEditableStorageSpace.stringValue = "0M"
        self.lblBackupSpace.stringValue = "0M"
        self.lblCropSpace.stringValue = "0M"
        DispatchQueue.global().async {
            if let repository = ModelStore.default.getRepository(repositoryPath: path) {
                if repository.repositoryPath != "" && FileManager.default.fileExists(atPath: repository.repositoryPath) {
                    self.repoSpace = LocalDirectory.bridge.occupiedDiskSpace(path: repository.repositoryPath)
                }else{
                    self.repoSpace = [:]
                }
                
                if repository.storagePath != "" && FileManager.default.fileExists(atPath: repository.storagePath) {
                    self.backupSpace = LocalDirectory.bridge.occupiedDiskSpace(path: repository.storagePath)
                }else{
                    self.backupSpace = [:]
                }
                
                if repository.cropPath != "" && FileManager.default.fileExists(atPath: repository.cropPath) {
                    self.faceSpace = LocalDirectory.bridge.occupiedDiskSpace(path: repository.cropPath)
                }else{
                    self.faceSpace = [:]
                }
                if let repoTotal = self.repoSpace["."] {
                    DispatchQueue.main.async {
                        self.lblEditableStorageSpace.stringValue = repoTotal
                    }
                }
                if let backupTotal = self.backupSpace["."] {
                    DispatchQueue.main.async {
                        self.lblBackupSpace.stringValue = backupTotal
                    }
                }
                if let faceTotal = self.faceSpace["."] {
                    DispatchQueue.main.async {
                        self.lblCropSpace.stringValue = faceTotal
                    }
                }
                DispatchQueue.main.async {
                    self.txtDetail.string = ""
                }
            }else{
                DispatchQueue.main.async {
                    self.txtDetail.string = "Cannot find repository from DB: \(path)"
                }
            }
        }
    }
    
    @IBAction func onConfigureClicked(_ sender: NSButton) {
        self.onConfigure()
    }
    
    @IBAction func onEditableDetailClicked(_ sender: NSButton) {
        if let output = self.repoSpace["console_output"] {
            self.txtDetail.string = output
            self.txtDetail.isHidden = false
        }else{
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    @IBAction func onBackupDetailClicked(_ sender: NSButton) {
        if let output = self.backupSpace["console_output"] {
            self.txtDetail.string = output
            self.txtDetail.isHidden = false
        }else{
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    @IBAction func onCropDetailClicked(_ sender: NSButton) {
        if let output = self.faceSpace["console_output"] {
            self.txtDetail.string = output
            self.txtDetail.isHidden = false
        }else{
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    
}
