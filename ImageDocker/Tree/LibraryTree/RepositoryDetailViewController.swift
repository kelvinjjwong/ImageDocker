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
    @IBOutlet weak var lblRepoFree: NSTextField!
    @IBOutlet weak var lblBackupFree: NSTextField!
    @IBOutlet weak var lblCropFree: NSTextField!
    @IBOutlet weak var lblTotalSize: NSTextField!
    
    
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
        self.lblRepoFree.stringValue = "0M / 0T"
        self.lblBackupFree.stringValue = "0M / 0T"
        self.lblCropFree.stringValue = "0M / 0T"
        self.lblTotalSize.stringValue = "0 GB"
        DispatchQueue.global().async {
            if let repository = ModelStore.default.getRepository(repositoryPath: path) {
                var totalSize = 0.0
                
                var repoDiskFree = ""
                var repoDiskTotal = ""
                if repository.repositoryPath != "" && FileManager.default.fileExists(atPath: repository.repositoryPath) {
                    self.repoSpace = LocalDirectory.bridge.occupiedDiskSpace(path: repository.repositoryPath)
                    (repoDiskTotal, repoDiskFree) = LocalDirectory.bridge.freeSpace(path: repository.repositoryPath)
                    if repoDiskTotal != "" && repoDiskFree != "" {
                        DispatchQueue.main.async {
                            self.lblRepoFree.stringValue = "\(repoDiskFree) / \(repoDiskTotal)"
                        }
                    }
                }else{
                    self.repoSpace = [:]
                }
                if let repoTotal = self.repoSpace["."] {
                    DispatchQueue.main.async {
                        self.lblEditableStorageSpace.stringValue = repoTotal
                    }
                    var amount = Double(repoTotal.substring(from: 0, to: -1)) ?? 0
                    if repoTotal.hasSuffix("T") {
                        amount = amount * 1000 * 1000
                    }
                    if repoTotal.hasSuffix("G") {
                        amount = amount * 1000
                    }
                    if repoTotal.hasSuffix("B") || repoTotal.hasSuffix("K") {
                        amount = 0
                    }
                    totalSize += amount
                }
                
                var backupDiskFree = ""
                var backupDiskTotal = ""
                if repository.storagePath != "" && FileManager.default.fileExists(atPath: repository.storagePath) {
                    self.backupSpace = LocalDirectory.bridge.occupiedDiskSpace(path: repository.storagePath)
                    (backupDiskTotal, backupDiskFree) = LocalDirectory.bridge.freeSpace(path: repository.storagePath)
                    if backupDiskTotal != "" && backupDiskFree != "" {
                        DispatchQueue.main.async {
                            self.lblBackupFree.stringValue = "\(backupDiskFree) / \(backupDiskTotal)"
                        }
                    }
                }else{
                    self.backupSpace = [:]
                }
                if let backupTotal = self.backupSpace["."] {
                    DispatchQueue.main.async {
                        self.lblBackupSpace.stringValue = backupTotal
                    }
                    var amount = Double(backupTotal.substring(from: 0, to: -1)) ?? 0
                    if backupTotal.hasSuffix("T") {
                        amount = amount * 1000 * 1000
                    }
                    if backupTotal.hasSuffix("G") {
                        amount = amount * 1000
                    }
                    if backupTotal.hasSuffix("B") || backupTotal.hasSuffix("K") {
                        amount = 0
                    }
                    totalSize += amount
                }
                
                var cropDiskFree = ""
                var cropDiskTotal = ""
                if repository.cropPath != "" && FileManager.default.fileExists(atPath: repository.cropPath) {
                    self.faceSpace = LocalDirectory.bridge.occupiedDiskSpace(path: repository.cropPath)
                    (cropDiskTotal, cropDiskFree) = LocalDirectory.bridge.freeSpace(path: repository.cropPath)
                    if cropDiskTotal != "" && cropDiskFree != "" {
                        DispatchQueue.main.async {
                            self.lblCropFree.stringValue = "\(cropDiskFree) / \(cropDiskTotal)"
                        }
                    }
                }else{
                    self.faceSpace = [:]
                }
                if let faceTotal = self.faceSpace["."] {
                    DispatchQueue.main.async {
                        self.lblCropSpace.stringValue = faceTotal
                    }
                    var amount = Double(faceTotal.substring(from: 0, to: -1)) ?? 0
                    if faceTotal.hasSuffix("T") {
                        amount = amount * 1000 * 1000
                    }
                    if faceTotal.hasSuffix("G") {
                        amount = amount * 1000
                    }
                    if faceTotal.hasSuffix("B") || faceTotal.hasSuffix("K") {
                        amount = 0
                    }
                    totalSize += amount
                }
                let totalSizeGB:Double = totalSize / 1000
                DispatchQueue.main.async {
                    self.lblTotalSize.stringValue = "\(totalSizeGB) G"
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
            self.txtDetail.string = "Editable storage:\n\(output)"
            self.txtDetail.isHidden = false
        }else{
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    @IBAction func onBackupDetailClicked(_ sender: NSButton) {
        if let output = self.backupSpace["console_output"] {
            self.txtDetail.string = "Backup storage:\n\(output)"
            self.txtDetail.isHidden = false
        }else{
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    @IBAction func onCropDetailClicked(_ sender: NSButton) {
        if let output = self.faceSpace["console_output"] {
            self.txtDetail.string = "Face storage:\n\(output)"
            self.txtDetail.isHidden = false
        }else{
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    
}
