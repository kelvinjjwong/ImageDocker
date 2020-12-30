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
    @IBOutlet weak var scrollDetail: NSScrollView!
    
    @IBOutlet weak var lblRepoFree: NSTextField!
    @IBOutlet weak var lblBackupFree: NSTextField!
    @IBOutlet weak var lblCropFree: NSTextField!
    @IBOutlet weak var lblTotalSize: NSTextField!
    
    @IBOutlet weak var lblCopiedFromDevice: NSTextField!
    @IBOutlet weak var lblImported: NSTextField!
    @IBOutlet weak var lblExif: NSTextField!
    @IBOutlet weak var lblLocation: NSTextField!
    @IBOutlet weak var lblFaces: NSTextField!
    @IBOutlet weak var indCopiedFromDevice: NSLevelIndicator!
    @IBOutlet weak var indImported: NSLevelIndicator!
    @IBOutlet weak var indExif: NSLevelIndicator!
    @IBOutlet weak var indLocation: NSLevelIndicator!
    @IBOutlet weak var indFaces: NSLevelIndicator!
    @IBOutlet weak var btnDropIn: NSButton!
    @IBOutlet weak var btnImport: NSButton!
    @IBOutlet weak var btnExif: NSButton!
    @IBOutlet weak var btnLocation: NSButton!
    @IBOutlet weak var btnFaces: NSButton!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var indProgress: NSProgressIndicator!
    @IBOutlet weak var btnStop: NSButton!
    @IBOutlet weak var lblShouldImport: NSTextField!
    @IBOutlet weak var indShouldImport: NSLevelIndicator!
    
    
    // MARK: INIT VIEW
    
    init() {
        super.init(nibName: "RepositoryDetailViewController", bundle: nil)
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
    fileprivate var onShowDeviceDialog: ((PhoneDevice) -> Void)!
    
    fileprivate var _repositoryPath:String = ""
    
    func initView(path:String, onShowDeviceDialog: @escaping ((PhoneDevice) -> Void), onConfigure: @escaping (() -> Void)) {
        self._repositoryPath = path
        self.onConfigure = onConfigure
        self.onShowDeviceDialog = onShowDeviceDialog
        
        self.scrollDetail.hasVerticalScroller = false
        self.txtDetail.string = "Calculating ..."
        self.txtDetail.isHidden = true
        self.lblEditableStorageSpace.stringValue = "0M"
        self.lblBackupSpace.stringValue = "0M"
        self.lblCropSpace.stringValue = "0M"
        self.lblRepoFree.stringValue = "0M / 0T"
        self.lblBackupFree.stringValue = "0M / 0T"
        self.lblCropFree.stringValue = "0M / 0T"
        self.lblTotalSize.stringValue = "0 GB"

        self.lblCopiedFromDevice.stringValue = "0"
        self.lblShouldImport.stringValue = "0"
        self.lblImported.stringValue = "0"
        self.lblExif.stringValue = "0"
        self.lblLocation.stringValue = "0"
        self.lblFaces.stringValue = "0"

        self.indCopiedFromDevice.maxValue = 100.0
        self.indCopiedFromDevice.minValue = 0.0
        self.indCopiedFromDevice.doubleValue = 0.0
        
        self.indShouldImport.maxValue = 100.0
        self.indShouldImport.minValue = 0.0
        self.indShouldImport.doubleValue = 0.0
        
        self.indImported.maxValue = 100.0
        self.indImported.minValue = 0.0
        self.indImported.doubleValue = 0.0
        
        self.indExif.maxValue = 100.0
        self.indExif.minValue = 0.0
        self.indExif.doubleValue = 0.0
        
        self.indLocation.maxValue = 100.0
        self.indLocation.minValue = 0.0
        self.indLocation.doubleValue = 0.0
        
        self.indFaces.maxValue = 100.0
        self.indFaces.minValue = 0.0
        self.indFaces.doubleValue = 0.0
        
        self.lblMessage.isHidden = true
        self.indProgress.isHidden = true
        self.btnStop.isHidden = true
        
        
        DispatchQueue.global().async {
            if let repository = RepositoryDao.default.getRepository(repositoryPath: path) {
                
                var isAndroid = false
                if repository.deviceId != "" {
                    let device = DeviceDao.default.getDevice(deviceId: repository.deviceId)
                    isAndroid = ( (device?.type ?? "") == "Android")
                }
                
                let countCopiedFromDevice = ImageCountDao.default.countCopiedFromDevice(deviceId: repository.deviceId)
                let countShouldImport = isAndroid ? ( ImageCountDao.default.countImagesShouldImport(rawStoragePath: repository.storagePath.withStash(), deviceId: repository.deviceId) ) : countCopiedFromDevice
                let countImported = ImageCountDao.default.countImportedAsEditable(repositoryPath: repository.repositoryPath)
                let countExtractedExif = ImageCountDao.default.countExtractedExif(repositoryPath: repository.repositoryPath)
                let countRecognizedLocation = ImageCountDao.default.countRecognizedLocation(repositoryPath: repository.repositoryPath)
                let countRecognizedFaces = ImageCountDao.default.countRecognizedFaces(repositoryPath: repository.repositoryPath)
                
                DispatchQueue.main.async {
                    self.lblCopiedFromDevice.stringValue = "\(countCopiedFromDevice)"
                    self.lblShouldImport.stringValue = "\(countShouldImport)"
                    self.lblImported.stringValue = "\(countImported)"
                    self.lblExif.stringValue = "\(countExtractedExif)"
                    self.lblLocation.stringValue = "\(countRecognizedLocation)"
                    self.lblFaces.stringValue = "\(countRecognizedFaces)"
                    
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
            }
        }
        DispatchQueue.global().async {
            if let repository = RepositoryDao.default.getRepository(repositoryPath: path) {
                
                let (repoSize, _, _, repoDetail) = LocalDirectory.bridge.getDiskSpace(path: repository.repositoryPath, lblDiskFree: self.lblRepoFree, lblDiskOccupied: self.lblEditableStorageSpace)
                self.repoSpace = repoDetail
                
                let (backupSize, _, _, backupDetail) = LocalDirectory.bridge.getDiskSpace(path: repository.storagePath, lblDiskFree: self.lblBackupFree, lblDiskOccupied: self.lblBackupSpace)
                self.backupSpace = backupDetail
                
                let (faceSize, _, _, faceDetail) = LocalDirectory.bridge.getDiskSpace(path: repository.cropPath, lblDiskFree: self.lblCropFree, lblDiskOccupied: self.lblCropSpace)
                self.faceSpace = faceDetail
                
                let totalSizeGB:Double = repoSize + backupSize + faceSize
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
            self.scrollDetail.hasVerticalScroller = true
            self.txtDetail.string = "Editable storage:\n\(output)"
            self.txtDetail.isHidden = false
        }else{
            self.scrollDetail.hasVerticalScroller = false
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    @IBAction func onBackupDetailClicked(_ sender: NSButton) {
        if let output = self.backupSpace["console_output"] {
            self.scrollDetail.hasVerticalScroller = true
            self.txtDetail.string = "Backup storage:\n\(output)"
            self.txtDetail.isHidden = false
        }else{
            self.scrollDetail.hasVerticalScroller = false
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    @IBAction func onCropDetailClicked(_ sender: NSButton) {
        if let output = self.faceSpace["console_output"] {
            self.scrollDetail.hasVerticalScroller = true
            self.txtDetail.string = "Face storage:\n\(output)"
            self.txtDetail.isHidden = false
        }else{
            self.scrollDetail.hasVerticalScroller = false
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    @IBAction func onDropInClicked(_ sender: NSButton) {
        if let repository = RepositoryDao.default.getRepository(repositoryPath: self._repositoryPath),
            let device = DeviceDao.default.getDevice(deviceId: repository.deviceId),
            let deviceType = device.type {
            
            var dev:PhoneDevice
            if deviceType == "iPhone" {
                dev = PhoneDevice(type: .iPhone, deviceId: device.deviceId ?? "", manufacture: device.manufacture ?? "", model: device.model ?? "")
                dev.name = device.name ?? ""
                
            }else if deviceType == "Android" {
                dev = PhoneDevice(type: .Android, deviceId: device.deviceId ?? "", manufacture: device.manufacture ?? "", model: device.model ?? "")
                dev.name = device.name ?? ""
            }else{
                return
            }
            
            self.onShowDeviceDialog(dev)
            
        }
    }
    
    fileprivate func toggleButtons(_ state:Bool) {
        DispatchQueue.main.async {
            self.lblMessage.isHidden = state
            self.indProgress.isHidden = state
            self.btnStop.isHidden = state
            
            self.btnDropIn.isEnabled = state
            self.btnImport.isEnabled = state
            self.btnExif.isEnabled = state
            self.btnLocation.isEnabled = state
            self.btnFaces.isEnabled = state
            
            self.btnConfig.isEnabled = state
        }
    }
    
    @IBAction func onImportClicked(_ sender: NSButton) {
        if let repository = RepositoryDao.default.getRepository(repositoryPath: self._repositoryPath) {
            self.toggleButtons(false)
            let indicator = Accumulator(target: 1000,
                                        indicator: self.indProgress,
                                        suspended: true,
                                        lblMessage: self.lblMessage,
                                        presetAddingMessage: "Importing images ...",
                                        onCompleted: { data in
                                            print("====== COMPLETED SCAN single REPO \(repository.name)")
                                            self.toggleButtons(true)
            },
                                        onDataChanged: {
                                            print("====== DATE CHANGED when SCAN single REPO \(repository.name)")
            })
            
            ImageFolderTreeScanner.default.scanSingleRepository_asTask(repository: repository, indicator: indicator, onCompleted: {
                print(">>>> onCompleted")
                self.toggleButtons(true)
            })
        }
    }
    
    @IBAction func onExifClicked(_ sender: NSButton) {
        if let repository = RepositoryDao.default.getRepository(repositoryPath: self._repositoryPath) {
            self.toggleButtons(false)
            let indicator = Accumulator(target: 2,
                                        indicator: self.indProgress,
                                        suspended: true,
                                        lblMessage: self.lblMessage,
                                        presetAddingMessage: "Searching images for EXIF ...",
                                        onCompleted: { data in
                                            print("====== COMPLETED SCAN single REPO for EXIF \(repository.name)")
                                            self.toggleButtons(true)
            },
                                        onDataChanged: {
                                            print("====== DATE CHANGED when SCAN single REPO for EXIF \(repository.name)")
            })
            
            ImageFolderTreeScanner.default.scanPhotosToLoadExif_asTask(repository: repository, indicator: indicator, onCompleted: {
                print(">>>> onCompleted")
                self.toggleButtons(true)
            })
        }
    }
    
    @IBAction func onLocationClicked(_ sender: NSButton) {
    }
    
    @IBAction func onFacesClicked(_ sender: NSButton) {
    }
    
    @IBAction func onStopClicked(_ sender: NSButton) {
    }
    
}
