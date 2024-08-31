//
//  RepositoryDetailViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/25.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory
import SharedDeviceLib

class RepositoryDetailViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "TreeExpand", subCategory: "RepositoryDetailViewController", includeTypes: [])
    
    @IBOutlet weak var btnConfig: NSButton!
    @IBOutlet weak var btnReScanFolders: NSButton!
    
    
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
    @IBOutlet weak var btnDropIn: NSButton!  /// - Tag: RepositoryDetailViewController.btnDropIn
    @IBOutlet weak var btnImport: NSButton! /// - Tag: RepositoryDetailViewController.btnImport
    @IBOutlet weak var btnExif: NSButton! /// - Tag: RepositoryDetailViewController.btnExif
    @IBOutlet weak var btnLocation: NSButton! /// - Tag: RepositoryDetailViewController.btnLocation
    @IBOutlet weak var btnFaces: NSButton! /// - Tag: RepositoryDetailViewController.btnFaces
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var indProgress: NSProgressIndicator!
    @IBOutlet weak var btnStop: NSButton! /// - Tag: RepositoryDetailViewController.btnStop
    @IBOutlet weak var lblShouldImport: NSTextField!
    @IBOutlet weak var indShouldImport: NSLevelIndicator!
    @IBOutlet weak var lblPath: NSTextField!
    
    @IBOutlet weak var lblNewPath: NSTextField!
    @IBOutlet weak var lblNewContainerName: NSTextField!
    
    @IBOutlet weak var btnGotoPath: NSButton!  /// - Tag: RepositoryDetailViewController.btnGotoPath
    
    
    @IBOutlet weak var boxImageRecords: NSBox!
    @IBOutlet weak var lblCaptionCopiedFromDevice: NSTextField!
    @IBOutlet weak var lblCaptionImagesShouldImport: NSTextField!
    @IBOutlet weak var lblCaptionImportedEditable: NSTextField!
    @IBOutlet weak var lblCaptionExtractedExif: NSTextField!
    @IBOutlet weak var lblCaptionRecognizedLocation: NSTextField!
    @IBOutlet weak var lblCaptionRecognizedFaces: NSTextField!
    
    @IBOutlet weak var boxDiskSpaceStat: NSBox!
    @IBOutlet weak var lblCaptionEditableStorage: NSTextField!
    @IBOutlet weak var lblCaptionBackupStorage: NSTextField!
    @IBOutlet weak var lblCaptionFacesStorage: NSTextField!
    @IBOutlet weak var lblCaptionTotalSize: NSTextField!
    @IBOutlet weak var lblCaptionFreeOnEditableStorage: NSTextField!
    @IBOutlet weak var lblCaptionFreeOnBackupStorage: NSTextField!
    @IBOutlet weak var lblCaptionFreeOnFacesStorage: NSTextField!
    @IBOutlet weak var btnDetailOfEditableStorage: NSButton!  /// - Tag: RepositoryDetailViewController.btnDetailOfEditableStorage
    @IBOutlet weak var btnDetailOfBackupStorage: NSButton!  /// - Tag: RepositoryDetailViewController.btnDetailOfBackupStorage
    @IBOutlet weak var btnDetailOfFacesStorage: NSButton!  /// - Tag: RepositoryDetailViewController.btnDetailOfFacesStorage
    
    @IBOutlet weak var lblCaptionFolder: NSTextField!
    
    private var accumulator:Accumulator? = nil
    private var working = false
    private var forceStop = false
    
    // MARK: INIT VIEW
    
    init() {
        super.init(nibName: "RepositoryDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnConfig.title = Words.library_tree_configure.word()
        
        self.boxImageRecords.title = Words.library_tree_stat_image_records.word()
        self.boxDiskSpaceStat.title = Words.library_tree_disk_space_statistics.word()
        self.lblCaptionCopiedFromDevice.stringValue = Words.library_tree_copied_from_device.word()
        self.lblCaptionImagesShouldImport.stringValue = Words.library_tree_images_should_import.word()
        self.lblCaptionImportedEditable.stringValue = Words.library_tree_imported_as_editable.word()
        self.lblCaptionExtractedExif.stringValue = Words.library_tree_extracted_exif.word()
        self.lblCaptionRecognizedLocation.stringValue = Words.library_tree_recognized_location.word()
        self.lblCaptionRecognizedFaces.stringValue = Words.library_tree_recognized_faces.word()
        self.btnDropIn.title = Words.library_tree_drop_in.word()
        self.btnImport.title = Words.library_tree_import.word()
        self.btnReScanFolders.title = Words.library_tree_rescan.word()
        self.btnExif.title = Words.library_tree_extract.word()
        self.btnLocation.title = Words.library_tree_recognize.word()
        self.btnFaces.title = Words.library_tree_recognize.word()
        self.btnStop.title = Words.library_tree_stop.word()
        self.lblCaptionFolder.stringValue = Words.library_tree_folder.word()
        self.lblCaptionEditableStorage.stringValue = Words.library_tree_editable_storage.word()
        self.lblCaptionBackupStorage.stringValue = Words.library_tree_backup_storage.word()
        self.lblCaptionFacesStorage.stringValue = Words.library_tree_faces_storage.word()
        self.lblCaptionTotalSize.stringValue = Words.library_tree_total_size.word()
        self.lblCaptionFreeOnEditableStorage.stringValue = Words.library_tree_free_on_disk.word()
        self.lblCaptionFreeOnBackupStorage.stringValue = Words.library_tree_free_on_disk.word()
        self.lblCaptionFreeOnFacesStorage.stringValue = Words.library_tree_free_on_disk.word()
        self.btnDetailOfEditableStorage.title = Words.library_tree_detail.word()
        self.btnDetailOfBackupStorage.title = Words.library_tree_detail.word()
        self.btnDetailOfFacesStorage.title = Words.library_tree_detail.word()
        self.btnGotoPath.title = Words.library_tree_reveal_in_finder.word()
        
        
        self.txtDetail.isEditable = false
        self.txtDetail.isHidden = true
    }
    
    var repoSpace:[String:String] = [:]
    var backupSpace:[String:String] = [:]
    var faceSpace:[String:String] = [:]
    
    fileprivate var onConfigure: (() -> Void)!
    fileprivate var onManageSubContainers: (() -> Void)!
    fileprivate var onShowDeviceDialog: ((PhoneDevice) -> Void)!
    
    fileprivate var repository:ImageRepository?
    fileprivate var _repositoryId:Int = 0
    fileprivate var _repositoryPath:String = ""
    fileprivate var _repositoryName = ""
    
    private var phoneDevice:PhoneDevice? = nil
    
    func toggleNewPath(_ state:Bool){
        self.lblNewPath.stringValue = ""
        self.lblNewContainerName.stringValue = ""
        self.lblNewPath.isHidden = !state
        self.lblNewContainerName.isHidden = !state
    }
    
    /// - Tag: RepositoryDetailViewController.initView(id)
    func initView(repository: ImageRepository,
                  onShowDeviceDialog: @escaping ((PhoneDevice) -> Void),
                  onConfigure: @escaping (() -> Void),
                  onManageSubContainers: @escaping (() -> Void)
    ) {
        self.phoneDevice = nil
        self.repository = repository
        
        self._repositoryId = repository.id
        self._repositoryPath = repository.repositoryPath // without repositoryVolume
        self._repositoryName = ""
        self.onConfigure = onConfigure
        self.onShowDeviceDialog = onShowDeviceDialog
        self.onManageSubContainers = onManageSubContainers
        
        self.scrollDetail.hasVerticalScroller = false
        self.txtDetail.string = Words.library_tree_calculating.word()
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
        
        self.lblPath.stringValue = Naming.Image.generateFullAbsoluteRepositoryPath(repositoryVolume: repository.repositoryVolume, repositoryPath: repository.repositoryPath)
        
        self.toggleNewPath(false)
        
        
        DispatchQueue.global().async {
            if let repository = RepositoryDao.default.getRepository(id: self._repositoryId) {
                
                self._repositoryName = repository.name
                
                var isAndroid = false
                if repository.deviceId != "" {
                    if let device = DeviceDao.default.getDevice(deviceId: repository.deviceId) {
                        isAndroid = ( (device.type ?? "") == "Android")
                        
                        self.phoneDevice = PhoneDevice(type: isAndroid ? .Android : .iPhone,
                                                      deviceId: repository.deviceId,
                                                      manufacture: device.manufacture ?? "", 
                                                      model: device.model ?? "")
                        self.phoneDevice?.name = device.name ?? ""
                        
                        var connectedDeviceIds:[String] = []
                        if isAndroid {
                            connectedDeviceIds = DeviceBridge.Android().devices()
                        }else{
                            var connectIOS = true
                            if Setting.localEnvironment.iosDeviceMountPoint() == "" {
                                connectIOS = false
                                MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: Words.device_tree_setup_mountpoint_for_ios.word())
                            }
                            if !DeviceBridge.IPHONE().validCommands() {
                                connectIOS = false
                                MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: Words.device_tree_ifuse_not_installed.word())
                            }
                            if connectIOS {
                                connectedDeviceIds = DeviceBridge.IPHONE().devices()
                            }
                        }
                        if !connectedDeviceIds.contains(repository.deviceId) {
                            
                            DispatchQueue.main.async {
                                MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: "Device is not connected")
                                if isAndroid {
                                    MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: Words.device_tree_need_debug_mode.word())
                                }else{
                                    MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: Words.device_tree_no_ios_connected.word())
                                }
                            }
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            MessageEventCenter.default.showMessage(type: "Repository", name: repository.name, message: "Cannot find device id for this repository")
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
                DispatchQueue.main.async {
                    self.txtDetail.string = "\(Words.library_tree_cannot_find_selected_repository_in_db.word()): \(Naming.Image.generateFullAbsoluteRepositoryPath(repositoryVolume: repository.repositoryVolume, repositoryPath: repository.repositoryPath))"
                }
            }
        }
    }
    
    @IBAction func onConfigureClicked(_ sender: NSButton) {
        self.onConfigure()
    }
    
    
    /// - Tag: RepositoryDetailViewController.onEditableDetailClicked()
    @IBAction func onEditableDetailClicked(_ sender: NSButton) {
        if let output = self.repoSpace["console_output"] {
            self.scrollDetail.hasVerticalScroller = true
            self.txtDetail.string = "\(Words.library_tree_editable_storage.word())\n\(output)"
            self.txtDetail.isHidden = false
        }else{
            self.scrollDetail.hasVerticalScroller = false
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    /// - Tag: RepositoryDetailViewController.onBackupDetailClicked()
    @IBAction func onBackupDetailClicked(_ sender: NSButton) {
        if let output = self.backupSpace["console_output"] {
            self.scrollDetail.hasVerticalScroller = true
            self.txtDetail.string = "\(Words.library_tree_backup_storage.word())\n\(output)"
            self.txtDetail.isHidden = false
        }else{
            self.scrollDetail.hasVerticalScroller = false
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    /// - Tag: RepositoryDetailViewController.onCropDetailClicked()
    @IBAction func onCropDetailClicked(_ sender: NSButton) {
        if let output = self.faceSpace["console_output"] {
            self.scrollDetail.hasVerticalScroller = true
            self.txtDetail.string = "\(Words.library_tree_faces_storage.word())\n\(output)"
            self.txtDetail.isHidden = false
        }else{
            self.scrollDetail.hasVerticalScroller = false
            self.txtDetail.string = ""
            self.txtDetail.isHidden = true
        }
    }
    
    /// - Tag: RepositoryDetailViewController.onDropInClicked()
    @IBAction func onDropInClicked(_ sender: NSButton) {
        if let repository = RepositoryDao.default.getRepository(id: self._repositoryId),
            let device = DeviceDao.default.getDevice(deviceId: repository.deviceId),
            let deviceType = device.type {
            
            let phoneDevice = self.phoneDevice
                            ?? PhoneDevice(type: .Unknown, deviceId: "", manufacture: "", model: "") // not bind phone yet or local disk folder
            
            self.onShowDeviceDialog(phoneDevice)
            
        }
    }
    
    fileprivate func toggleButtons(_ state:Bool) {
        DispatchQueue.main.async {
            self.btnReScanFolders.isEnabled = state
            
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
    
    /// - parameter sender: [button](x-source-tag://RepositoryDetailViewController.btnImport)
    /// - Tag: RepositoryDetailViewController.onImportClicked()
    @IBAction func onImportClicked(_ sender: NSButton) {
        self.scanImageRepository()
    }
    
    @IBAction func onExifClicked(_ sender: NSButton) {
        if let repository = RepositoryDao.default.getRepository(repositoryPath: self._repositoryPath) {
            self.toggleButtons(false)
            let indicator = Accumulator(target: 2,
                                        indicator: self.indProgress,
                                        suspended: true,
                                        lblMessage: self.lblMessage,
                                        presetAddingMessage: Words.searchingImagesForEXIF.word(),
                                        onCompleted: { data in
                                            self.logger.log("====== COMPLETED SCAN single REPO for EXIF \(repository.name)")
                                            self.toggleButtons(true)
            },
                                        onDataChanged: {
                                            self.logger.log("====== DATE CHANGED when SCAN single REPO for EXIF \(repository.name)")
            })
            
            ImageFolderTreeScanner.default.scanPhotosToLoadExif_asTask(repository: repository, indicator: indicator, onCompleted: {
                self.logger.log(">>>> onCompleted")
                self.toggleButtons(true)
            })
        }
    }
    
    @IBAction func onLocationClicked(_ sender: NSButton) {
        if let repository = RepositoryDao.default.getRepository(repositoryPath: self._repositoryPath) {
            self.toggleButtons(false)
            let indicator = Accumulator(target: 2,
                                        indicator: self.indProgress,
                                        suspended: true,
                                        lblMessage: self.lblMessage,
                                        presetAddingMessage: Words.searchingImagesForLocation.word(),
                                        onCompleted: { data in
                                            self.logger.log("====== COMPLETED SCAN single REPO for location \(repository.name)")
                                            self.toggleButtons(true)
            },
                                        onDataChanged: {
                                            self.logger.log("====== DATE CHANGED when SCAN single REPO for location \(repository.name)")
            })
            
            ImageFolderTreeScanner.default.scanPhotosToLoadLocation_asTask(repository: repository, indicator: indicator, onCompleted: {
                self.logger.log(">>>> onCompleted")
                self.toggleButtons(true)
            })
        }
    }
    
    @IBAction func onFacesClicked(_ sender: NSButton) {
        self.logger.log(.todo, "TODO function")
    }
    
    @IBAction func onStopClicked(_ sender: NSButton) {
        self.forceStop = true
    }
    
    @IBAction func onGotoPathClicked(_ sender: NSButton) {
        let url = URL(fileURLWithPath: self.lblPath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// - Tag: RepositoryDetailViewController.onReScanFoldersClicked()
    @IBAction func onReScanFoldersClicked(_ sender: NSButton) {
        self.scanImageRepository()
    }
    
    // currently using
    private func scanImageRepository() {
        self.logger.log("scanImageRepository")
        if(self.working) {
            self.logger.log(.error, "Another long task is working.")
            NotificationMessageManager.default.createNotificationMessage(type: "Import for editing", name: self._repositoryName, message: "Another long task is working.")
            return
        }
        self.forceStop = false
        self.working = true
        self.toggleButtons(false)
        self.lblMessage.stringValue = "Re-Scanning folders ..."
        
        logger.log(.debug, "repo path: \(self._repositoryPath)")
//        let (volume, path) = _repositoryPath.getVolumeFromThisPath()
        
        
        if let imageRepository = RepositoryDao.default.getRepository(id: self._repositoryId) {
            let volume = imageRepository.repositoryVolume
            let path = imageRepository.repositoryPath
            logger.log(.debug, "DB record found for ImageRepository: id=\(imageRepository.id), name=\(imageRepository.name), volume=\(volume), path=\(path)")
            
            let _ = TaskletManager.default.createAndStartTask(type: "Re-Scan repository", name: "\(imageRepository.name)"
                                                              , exec: { task in
                
                
                TaskletManager.default.updateProgress(id: task.id, message: "Re-Scanning folders ...", increase: false)
                
                DispatchQueue.global().async {
                    
                    // MARK: ImageRepository linked with an ImageContainer
                    
                    if let repositoryLinkedContainer = RepositoryDao.default.findContainer(repositoryId: imageRepository.id, subPath: "") {
                        self.logger.log("ImageRepository linked with an ImageContainer, repositoryId:\(imageRepository.id), containerId:\(repositoryLinkedContainer.id)")
                    }else{
                        self.logger.log(.error, "Unable to find ImageRepository's linked ImageContainer record in database, repositoryId:\(imageRepository.id)")
                        if let createdLinkedContainer = RepositoryDao.default.createEmptyImageContainerLinkToRepository(repositoryId: imageRepository.id) {
                            self.logger.log(.info, "Created an empty ImageContainer linking to ImageRepository, repositoryId:\(imageRepository.id), containerId:\(createdLinkedContainer.id)")
                        }else{
                            self.logger.log(.error, "Unable to create an empty ImageContainer linking to ImageRepository, repositoryId:\(imageRepository.id)")
                            DispatchQueue.main.async {
                                self.working = false
                                self.toggleButtons(true)
                                self.lblMessage.stringValue = "Database error: Unable to create an empty ImageContainer linking to this repository."
                            }
                            return
                        }
                    }
                    
                    if TaskletManager.default.isTaskStopped(id: task.id) == true {
                        DispatchQueue.main.async {
                            self.working = false
                            self.toggleButtons(true)
                            self.lblMessage.stringValue = "User stopped task: re-scan folders."
                        }
                        return
                    }
                    
                    // MARK: - loop folder directory
                    
                    let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
                    let resourceValueKeys = [URLResourceKey.isRegularFileKey, URLResourceKey.typeIdentifierKey, URLResourceKey.isDirectoryKey]
                    if let directoryEnumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: "\(volume)\(path)"),
                                                                                includingPropertiesForKeys: resourceValueKeys,
                                                                                options: options,
                                                                                errorHandler: { url, error in
                        self.logger.log(.error, "`directoryEnumerator` error: \(error).")
                        self.forceStop = false
                        self.working = false
                        self.toggleButtons(true)
                        return true
                    }) {
                        var urls:[NSURL] = []
                        let startTime_loopUrls = Date()
                        for case let url as NSURL in directoryEnumerator {
                            urls.append(url)
                        }
                        let total = urls.count
                        TaskletManager.default.setTotal(id: task.id, total: total)
                        self.logger.timecost("[ReScanFolders][loopUrls]", fromDate: startTime_loopUrls)
                        self.logger.log(.debug, "total urls: \(total)")
                        
                        DispatchQueue.main.async {
                            self.accumulator = Accumulator(target: total, indicator: self.indProgress, suspended: false, lblMessage: self.lblMessage)
                        }
                        
                        var z = 0
                        var currentContainer:ImageContainer? = nil
                        for case let url in urls {
                            if let urlPath = url.path {
                                z += 1
                                
                                guard (!self.forceStop) && (TaskletManager.default.isTaskStopped(id: task.id) == false) else {
                                    self.logger.log(.info, "[onReScanFoldersClicked] for-loop terminated as user clicked stop button.")
                                    DispatchQueue.main.async {
                                        self.accumulator?.forceComplete()
                                    }
                                    break
                                }
                                
                                // MARK: define subPath
                                
                                let (_, subPath) = urlPath.getVolumeFromThisPath(repositoryPath: imageRepository.repositoryPath)
                                self.logger.log(.debug, "Found subPath: \(subPath)")
                                
                                DispatchQueue.main.async {
                                    let _ = self.accumulator?.add("Found: \(subPath)")
                                }
                                TaskletManager.default.updateProgress(id: task.id, message: "Found: \(subPath) (\(z)/\(task.total))", increase: true)
                                
                                do {
                                    let resourceValues = try url.resourceValues(forKeys: resourceValueKeys)
                                    if let isDirectory = resourceValues[URLResourceKey.isDirectoryKey] as? NSNumber {
                                        if isDirectory.boolValue {
                                            self.logger.log("Importing subPath [\(subPath)] into repository id [\(self._repositoryId)], it is a folder")
                                            
                                            // find parent container of current container
                                            let folderName = subPath.lastPartOfUrl()
                                            
                                            let parentSubPath = subPath.parentPath()
                                            self.logger.log("Folder subPath [\(subPath)]'s parentSubPath is [\(parentSubPath)] in repository id \(self._repositoryId)")
                                            
                                            // MARK: define parentId
                                            
                                            var parentId = 0
                                            if let parentContainer = RepositoryDao.default.findContainer(repositoryId: self._repositoryId, subPath: parentSubPath) {
                                                parentId = parentContainer.id
                                            }
                                            
                                            // ensure parentId != 0
                                            if parentId == 0 {
                                                self.logger.log(.error, "Cannot find matching parent ImageContainer with parentSubPath [\(parentSubPath)] in repository id [\(self._repositoryId)], ignore import this folder [\(subPath)]")
                                                break
                                            }
                                            
                                            // if image container record exist in database
                                            self.logger.log(.info, "Check if exist ImageContainer with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                            if let existingContainerInDB = RepositoryDao.default.findContainer(repositoryId: self._repositoryId, subPath: subPath) {
                                                
                                                self.logger.log(.info, "Exist ImageContainer with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                
                                                // update repositoryId if repositoryId=0
                                                if existingContainerInDB.repositoryId == 0 {
                                                    let executeState_updateRepoId = RepositoryDao.default.updateImageContainerWithRepositoryId(containerId: existingContainerInDB.id, repositoryId: imageRepository.id)
                                                    if executeState_updateRepoId == .OK {
                                                        self.logger.log("Updated ImageContainer.repositoryId, containerId=\(existingContainerInDB.id), repositoryId=\(imageRepository.id)")
                                                    }else{
                                                        self.logger.log(.error, "Unable to update ImageContainer.repositoryId, containerId=\(existingContainerInDB.id), repositoryId=\(imageRepository.id)")
                                                    }
                                                    existingContainerInDB.repositoryId = imageRepository.id
                                                }
                                                
                                                // update parentId if parentId not matched
                                                if existingContainerInDB.parentId != parentId {
                                                    let executeState_updateParentId = RepositoryDao.default.updateImageContainerWithParentId(containerId: existingContainerInDB.id, parentId: parentId)
                                                    if executeState_updateParentId == .OK {
                                                        self.logger.log("Updated ImageContainer.parentId, containerId=\(existingContainerInDB.id), parentId=\(parentId)")
                                                    }else{
                                                        self.logger.log(.error, "Unable to update ImageContainer.parentId, containerId=\(existingContainerInDB.id), parentId=\(parentId)")
                                                    }
                                                    existingContainerInDB.parentId = parentId
                                                }
                                                
                                                currentContainer = existingContainerInDB
                                                self.logger.log(.debug, "Found ImageContainer id [\(existingContainerInDB.id)] for subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                            }
                                            else{ // if image container record does not exist in database
                                                
                                                self.logger.log(.info, "Not exist ImageContainer with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                
                                                // MARK: create ImageContainer
                                                
                                                // FIXME: repositoryPath should be delete
                                                if let createdContainer = RepositoryDao.default.createContainer(name: folderName,
                                                                                                                repositoryId: self._repositoryId,
                                                                                                                parentId: parentId,
                                                                                                                subPath: subPath,
                                                                                                                repositoryPath: "\(self._repositoryPath)") {
                                                    self.logger.log(.info, "Created ImageContainer id=\(createdContainer.id), parentId=\(createdContainer.parentId), repositoryId=\(self._repositoryId), subPath=\(subPath), path=\(createdContainer.path)")
                                                    currentContainer = createdContainer
                                                }else{
                                                    self.logger.log(.error, "Cannot create ImageContainer DB record, subPath=\(subPath)")
                                                }
                                            }
                                        }else{
                                            self.logger.log("Importing subPath [\(subPath)] into repository id [\(self._repositoryId)], it is a file")
                                            if let currentContainer = currentContainer {
                                                
                                                var currentImage:Image? = nil
                                                
                                                var importedImageId = ""
                                                
                                                // check if Image exist
                                                self.logger.log(.info, "Check if exist Image with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                if let existingImageInDB = ImageRecordDao.default.findImage(repositoryId: self._repositoryId, subPath: subPath) {
                                                    
                                                    self.logger.log(.info, "Exist Image with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                    
                                                    // maintenance if imageId is null or imageId == ""
                                                    if let imageId = existingImageInDB.id, imageId != "" {
                                                        
                                                    }else{
                                                        self.logger.log(.warning, "Image.id is nil, try to generate UUID, subPath=\(subPath), repositoryId=\(self._repositoryId)")
                                                        let (executeState_generateId, imageId) = ImageRecordDao.default.generateImageIdByRepositoryIdAndSubPath(repositoryId: self._repositoryId, subPath: subPath)
                                                        
                                                        if executeState_generateId == .OK {
                                                            existingImageInDB.id = imageId
                                                            self.logger.log(.info, "Image.id is updated with generated UUID \(imageId), subPath=\(subPath), repositoryId=\(self._repositoryId)")
                                                        }else{
                                                            self.logger.log(.error, "Cannot update Image.id with generated UUID, subPath=\(subPath), repositoryId=\(self._repositoryId)")
                                                        }
                                                    }
                                                    
                                                    // maintenance image record with incorrect repositoryId and/or incorrect containerId
                                                    if let imageId = existingImageInDB.id, imageId != "" {
                                                        
                                                        if existingImageInDB.repositoryId != self._repositoryId || existingImageInDB.containerId != currentContainer.id {
                                                            self.logger.log(.info, "To update Image id=\(imageId) to container id=\(currentContainer.id) and repository id=\(self._repositoryId), subPath=\(subPath)")
                                                            let executeState = ImageRecordDao.default.updateImageWithContainerId(id: imageId, repositoryId: self._repositoryId, containerId: currentContainer.id)
                                                            if executeState != .OK {
                                                                self.logger.log(.error, "Failed to update Image with repositoryId=\(self._repositoryId), containerId=\(currentContainer.id), imageId=\(imageId), subPath=\(subPath): ExecuteState=\(executeState)")
                                                            }else{
                                                                self.logger.log(.info, "Updated Image id=\(imageId) to container id=\(currentContainer.id) and repository id=\(self._repositoryId), subPath=\(subPath)")
                                                            }
                                                        }
                                                    }
                                                    
                                                    importedImageId = existingImageInDB.id ?? ""
                                                    currentImage = existingImageInDB
                                                    
                                                }else{
                                                    
                                                    self.logger.log(.info, "Not exist Image with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                    
                                                    self.logger.log(.info, "To create Image to container id=\(currentContainer.id) and repository id=\(self._repositoryId), subPath=\(subPath)")
                                                    
                                                    // FIXME: repositoryVolume and repositoryPath should be delete
                                                    if let createdImage = ImageRecordDao.default.createImage(repositoryId: self._repositoryId,
                                                                                                             containerId: currentContainer.id,
                                                                                                             repositoryVolume: imageRepository.repositoryVolume,
                                                                                                             repositoryPath: imageRepository.repositoryPath,
                                                                                                             subPath: subPath) {
                                                        self.logger.log(.info, "Created Image id=\(createdImage.id ?? ""), repositoryId=\(imageRepository.id), containerId=\(currentContainer.id), subPath=\(subPath), path=\(createdImage.path)")
                                                        
                                                        importedImageId = createdImage.id ?? ""
                                                        currentImage = createdImage
                                                    }else{
                                                        self.logger.log(.error, "Cannot create Image with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                                    }
                                                }
                                                
                                                // link imageId to ImageDeviceFile, Image.subPath == ImageDeviceFile.localFilePath
                                                // update Image.originalMD5, deviceId, deviceFileId, Image.originalMD5 == ImageDeviceFile.fileMD5
                                                if let imageDeviceFile = DeviceDao.default.getDeviceFile(repositoryId: self._repositoryId, localFilePath: subPath.removeFirstStash()) {
                                                    if imageDeviceFile.importedImageId == "" && importedImageId != "" {
                                                        
                                                        self.logger.log("Update ImageDeviceFile importedImageId:\(importedImageId), repositoryId:\(self._repositoryId), subPath:\(subPath.removeFirstStash())")
                                                        let _ = DeviceDao.default.updateDeviceFileWithImageId(importedImageId: importedImageId,
                                                                                                              repositoryId: self._repositoryId,
                                                                                                              subPath: subPath.removeFirstStash())
                                                        
                                                        self.logger.log("Update Image originalMD5:\(imageDeviceFile.fileMD5), deviceId:\(imageDeviceFile.deviceId), deviceFileId:\(imageDeviceFile.fileId), repositoryId:\(self._repositoryId), subPath:\(subPath.removeFirstStash())")
                                                        if imageDeviceFile.fileMD5 ?? "" != "" && imageDeviceFile.deviceId ?? "" != "" && imageDeviceFile.fileId ?? "" != "" {
                                                            if let importedImage = currentImage {
                                                                if importedImage.originalMD5 ?? "" == "" || importedImage.deviceId == "" || importedImage.deviceFileId == "" {
                                                                    
                                                                    let _ = ImageRecordDao.default.updateImageMd5AndDeviceFileId(id: importedImageId,
                                                                                                                                 md5: imageDeviceFile.fileMD5 ?? "",
                                                                                                                                 deviceId: imageDeviceFile.deviceId ?? "",
                                                                                                                                 deviceFileId: imageDeviceFile.fileId ?? "")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                            }else{
                                                // should not happen
                                                self.logger.log(.error, "No container id able to link to this file with subPath [\(subPath)] in repository id [\(self._repositoryId)]")
                                            }
                                        } // if it's folder or file
                                    } // if it's folder or file
                                }catch {
                                    self.logger.log(.error, "Unexpected error occured when handling subPath: \(subPath) in repository id \(self._repositoryId)", error)
                                }
                            } // end of if let urlPath
                        } // end of for-loop
                        
                        
                        DispatchQueue.main.async {
                            self.working = false
                            self.toggleButtons(true)
                            if(self.forceStop) {
                                self.lblMessage.stringValue = "Re-Scan folders is stopped by user."
                            }else{
                                self.lblMessage.stringValue = "Re-Scan folders completed."
                            }
                            self.forceStop = false
                        }
                    } // end of if let directoryEnumerator
                    else{
                        DispatchQueue.main.async {
                            self.forceStop = false
                            self.working = false
                            self.toggleButtons(true)
                            self.lblMessage.stringValue = "Re-Scan folders encounter problem. Volume may be lost, or folder may be moved."
                        }
                    }
                } // end of DispatchQueue.global.async
            }, stop: {task in
                
            })
        }else{
            self.logger.log(.error, "DB record not found for ImageRepository with id: \(self._repositoryId)")
            self.forceStop = false
            self.working = false
            self.toggleButtons(true)
        }
    }
    
    private func scanImageRepository_Exif() {
        
    }
    
}
