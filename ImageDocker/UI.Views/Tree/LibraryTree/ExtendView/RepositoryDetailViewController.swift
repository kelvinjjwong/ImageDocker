//
//  RepositoryDetailViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/25.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class RepositoryDetailViewController: NSViewController {
    
    let logger = ConsoleLogger(category: "TreeExpand", subCategory: "RepositoryDetailViewController", includeTypes: [.debug, .performance])
    
    @IBOutlet weak var btnConfig: NSButton!
    @IBOutlet weak var btnManageSubContainers: NSButton!
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
    @IBOutlet weak var lblPath: NSTextField!
    
    @IBOutlet weak var lblNewPath: NSTextField!
    @IBOutlet weak var lblNewContainerName: NSTextField!
    
    @IBOutlet weak var btnFindParent: NSButton!
    @IBOutlet weak var btnPickParent: NSButton!
    @IBOutlet weak var btnPickGoUp: NSButton!
    @IBOutlet weak var btnPickGoDown: NSButton!
    @IBOutlet weak var btnGotoPath: NSButton!
    
    @IBOutlet weak var btnRefreshData: NSButton!
    
    
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
    @IBOutlet weak var btnDetailOfEditableStorage: NSButton!
    @IBOutlet weak var btnDetailOfBackupStorage: NSButton!
    @IBOutlet weak var btnDetailOfFacesStorage: NSButton!
    
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
        self.btnManageSubContainers.title = Words.library_tree_manage_sub_containers.word()
        
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
        self.btnFindParent.title = Words.library_tree_find_another_parent_folder.word()
        self.btnGotoPath.title = Words.library_tree_reveal_in_finder.word()
        self.btnPickGoUp.title = Words.library_tree_go_up.word()
        self.btnPickGoDown.title = Words.library_tree_restore.word()
        self.btnPickParent.title = Words.library_tree_save_as_parent_folder.word()
        self.btnRefreshData.title = Words.library_tree_refresh_relationship_data.word()
        
        
        self.txtDetail.isEditable = false
        self.txtDetail.isHidden = true
    }
    
    var repoSpace:[String:String] = [:]
    var backupSpace:[String:String] = [:]
    var faceSpace:[String:String] = [:]
    
    fileprivate var onConfigure: (() -> Void)!
    fileprivate var onManageSubContainers: (() -> Void)!
    fileprivate var onShowDeviceDialog: ((PhoneDevice) -> Void)!
    
    fileprivate var _repositoryId:Int = 0
    fileprivate var _repositoryPath:String = ""
    
    func toggleNewPath(_ state:Bool){
        self.lblNewPath.stringValue = ""
        self.lblNewContainerName.stringValue = ""
        self.lblNewPath.isHidden = !state
        self.lblNewContainerName.isHidden = !state
        self.btnPickParent.isHidden = true
        self.btnPickGoUp.isHidden = !state
        self.btnPickGoDown.isHidden = !state
        self.btnRefreshData.isHidden = !state
    }
    
    func initView(id:Int,
                  path:String,
                  onShowDeviceDialog: @escaping ((PhoneDevice) -> Void),
                  onConfigure: @escaping (() -> Void),
                  onManageSubContainers: @escaping (() -> Void)
    ) {
        self._repositoryId = id
        self._repositoryPath = path
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
        
        self.lblPath.stringValue = path
        
        self.toggleNewPath(false)
        
        
        DispatchQueue.global().async {
            if let repository = RepositoryDao.default.getRepository(repositoryPath: path) {
                
                var isAndroid = false
                if repository.deviceId != "" {
                    let device = DeviceDao.default.getDevice(deviceId: repository.deviceId)
                    isAndroid = ( (device?.type ?? "") == "Android")
                }
                
                let countCopiedFromDevice = ImageCountDao.default.countCopiedFromDevice(deviceId: repository.deviceId)
                let countShouldImport = isAndroid ? ( ImageCountDao.default.countImagesShouldImport(rawStoragePath: repository.storagePath.withLastStash(), deviceId: repository.deviceId) ) : countCopiedFromDevice
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
                
                if let _ = TaskletManager.default.searchRunningTask(name: repository.name) {
                    self.toggleButtons(false)
                }else{
                    self.toggleButtons(true)
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
                    self.txtDetail.string = "\(Words.library_tree_cannot_find_selected_repository_in_db.word()): \(path)"
                }
            }
        }
    }
    
    @IBAction func onConfigureClicked(_ sender: NSButton) {
        self.onConfigure()
    }
    
    @IBAction func onManageSubContainersClicked(_ sender: NSButton) {
        self.onManageSubContainers()
    }
    
    
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
    
    @IBAction func onImportClicked(_ sender: NSButton) {
        if let repository = RepositoryDao.default.getRepository(repositoryPath: self._repositoryPath) {
            self.toggleButtons(false)
            let indicator = Accumulator(target: 1000,
                                        indicator: self.indProgress,
                                        suspended: true,
                                        lblMessage: self.lblMessage,
                                        presetAddingMessage: Words.importingImages.word(),
                                        onCompleted: { data in
                                            self.logger.log("====== COMPLETED SCAN single REPO \(repository.name)")
                                            self.toggleButtons(true)
            },
                                        onDataChanged: {
                                            self.logger.log("====== DATE CHANGED when SCAN single REPO \(repository.name)")
            })
            
            ImageFolderTreeScanner.default.scanSingleRepository_asTask(repository: repository, indicator: indicator, onCompleted: {
                self.logger.log(">>>> onCompleted")
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
    
    @IBAction func onFindParentClicked(_ sender: NSButton) {
        if(self.lblNewPath.isHidden){
            self.toggleNewPath(true)
        }
        
        let url = URL(fileURLWithPath: self.lblPath.stringValue)
        let newUrl = url.deletingLastPathComponent()
        self.lblNewPath.stringValue = newUrl.path
        self.findNewContainer(path: newUrl.path)
    }
    
    private func findNewContainer(path:String){
        if let newContainer = RepositoryDao.default.getContainer(path: path) {
            self.lblNewContainerName.stringValue = newContainer.name
            self.btnPickParent.isHidden = false
        }else{
            self.lblNewContainerName.stringValue = Words.library_tree_cannot_find_matched_container.word()
            self.btnPickParent.isHidden = true
        }
    }
    
    @IBAction func onPickParentClicked(_ sender: NSButton) {
        
        let buttonTitle = self.btnPickParent.title
        self.btnPickParent.title = Words.library_tree_saving_parent_folder.word()
        self.btnPickParent.isEnabled = false
        self.btnRefreshData.isEnabled = false
        
        let newPath = self.lblNewPath.stringValue
        let path = self.lblPath.stringValue
        
        DispatchQueue.global().async {
            if let parentContainer = RepositoryDao.default.getContainer(path: newPath){
                
                if let container = RepositoryDao.default.getContainer(path: path) {
                    
                    container.parentFolder = parentContainer.path
                    container.parentPath = URL(fileURLWithPath: container.path.replacingFirstOccurrence(of: parentContainer.path, with: "")).deletingLastPathComponent().path.removeLastStash()
                        
                    let state = RepositoryDao.default.saveImageContainer(container: container)
                    if state == .OK {
                        let _ = RepositoryDao.default.updateParentContainerSubContainers(thisPath: container.path)
                        
                        DispatchQueue.main.async {
                            self.lblNewContainerName.stringValue = Words.library_tree_saved_parent_folder.word()
                            
                            self.btnPickParent.title = buttonTitle
                            self.btnPickParent.isEnabled = true
                            self.btnRefreshData.isEnabled = true
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.lblNewContainerName.stringValue = Words.library_tree_cannot_save_parent_folder.word()
                            
                            self.btnPickParent.title = buttonTitle
                            self.btnPickParent.isEnabled = true
                            self.btnRefreshData.isEnabled = true
                        }
                    }
                    
                }else{
                    DispatchQueue.main.async {
                        self.lblNewContainerName.stringValue = Words.library_tree_cannot_find_selected_folder_in_db.word()
                        
                        self.btnPickParent.title = buttonTitle
                        self.btnPickParent.isEnabled = true
                        self.btnRefreshData.isEnabled = true
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.lblNewContainerName.stringValue = Words.library_tree_cannot_find_selected_parent_folder_in_db.word()
                    
                    self.btnPickParent.title = buttonTitle
                    self.btnPickParent.isEnabled = true
                    self.btnRefreshData.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func onPickGoUpClicked(_ sender: NSButton) {
        let url = URL(fileURLWithPath: self.lblNewPath.stringValue)
        let newUrl = url.deletingLastPathComponent()
        if newUrl.path != "/" {
            self.lblNewPath.stringValue = newUrl.path
            self.findNewContainer(path: newUrl.path)
        }else{
            self.lblNewContainerName.stringValue = Words.library_tree_should_not_use_root_folder.word()
        }
    }
    
    @IBAction func onPickGoDownClicked(_ sender: NSButton) {
        let url = URL(fileURLWithPath: self.lblPath.stringValue)
        let newUrl = url.deletingLastPathComponent()
        self.lblNewPath.stringValue = newUrl.path
        self.findNewContainer(path: newUrl.path)
    }
    
    @IBAction func onGotoPathClicked(_ sender: NSButton) {
        let url = URL(fileURLWithPath: self.lblPath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onRefreshDataClicked(_ sender: NSButton) {
        let buttonTitle = self.btnRefreshData.title
        self.btnRefreshData.title = Words.library_tree_updating.word()
        self.btnPickParent.isEnabled = false
        self.btnRefreshData.isEnabled = false
        
        let path = self.lblPath.stringValue
        
        DispatchQueue.global().async {
            if let _ = RepositoryDao.default.getContainer(path: path) {
                let _ = RepositoryDao.default.updateParentContainerSubContainers(thisPath: path)
                let _ = RepositoryDao.default.updateImageContainerSubContainers(path: path)
            }
            
            DispatchQueue.main.async {
                self.btnRefreshData.title = buttonTitle
                self.btnPickParent.isEnabled = true
                self.btnRefreshData.isEnabled = true
                
            }
        }
    }
    
    @IBAction func onReScanFoldersClicked(_ sender: NSButton) {
        
        if(self.working) {
            self.logger.log(.error, "Another long task is working.")
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
            
            DispatchQueue.global().async {
                
                if let repositoryLinkedContainer = RepositoryDao.default.findContainer(repositoryId: imageRepository.id, subPath: "") {
                    self.logger.log("ImageRepository linked with an ImageContainer, repositoryId:\(imageRepository.id), containerId:\(repositoryLinkedContainer.id)")
                }else{
                    self.logger.log(.warning, "Unable to find ImageRepository's linked ImageContainer record in database, repositoryId:\(imageRepository.id)")
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
                    self.logger.timecost("[ReScanFolders][loopUrls]", fromDate: startTime_loopUrls)
                    self.logger.log(.debug, "total urls: \(total)")
                    
                    DispatchQueue.main.async {
                        self.accumulator = Accumulator(target: total, indicator: self.indProgress, suspended: false, lblMessage: self.lblMessage)
                    }
                    
                    var currentContainer:ImageContainer? = nil
                    for case let url in urls {
                        if let urlPath = url.path {
                            
                            guard !self.forceStop else {
                                self.logger.log(.info, "[onReScanFoldersClicked] for-loop terminated as user clicked stop button.")
                                DispatchQueue.main.async {
                                    self.accumulator?.forceComplete()
                                }
                                break
                            }
                            
                            let (_, subPath) = urlPath.getVolumeFromThisPath(repositoryPath: imageRepository.repositoryPath)
                            self.logger.log(.debug, "Found subPath: \(subPath)")
                            
                            DispatchQueue.main.async {
                                let _ = self.accumulator?.add("Found: \(subPath)")
                            }
                            
                            do {
                                let resourceValues = try url.resourceValues(forKeys: resourceValueKeys)
                                if let isDirectory = resourceValues[URLResourceKey.isDirectoryKey] as? NSNumber {
                                    if isDirectory.boolValue {
                                        self.logger.log(.debug, "it is a folder")
                                            
                                        // find parent container of current container
                                        let name = subPath.lastPartOfUrl()
                                        let volume_repositoryPath = "\(imageRepository.repositoryVolume)\(imageRepository.repositoryPath)"
                                        
                                        let parentPath = subPath.parentPath()
                                        
                                        var parentId = 0
                                        if let parentContainer = RepositoryDao.default.findContainer(repositoryVolume: imageRepository.repositoryVolume, repositoryPath: imageRepository.repositoryPath, subPath: parentPath) {
                                            parentId = parentContainer.id
                                        }
                                        
                                        // if image container record exist in database
                                        if let existingContainerInDB = RepositoryDao.default.findContainer(repositoryVolume: imageRepository.repositoryVolume, repositoryPath: imageRepository.repositoryPath, subPath: subPath) {
                                            
                                            // update repositoryId from zero
                                            if existingContainerInDB.repositoryId == 0 {
                                                let executeState_updateRepoId = RepositoryDao.default.updateImageContainerWithRepositoryId(containerId: existingContainerInDB.id, repositoryId: imageRepository.id)
                                                if executeState_updateRepoId == .OK {
                                                    self.logger.log("Updated ImageContainer.repositoryId, containerId=\(existingContainerInDB.id), repositoryId=\(imageRepository.id)")
                                                }else{
                                                    self.logger.log(.error, "Unable to update ImageContainer.repositoryId, containerId=\(existingContainerInDB.id), repositoryId=\(imageRepository.id)")
                                                }
                                                existingContainerInDB.repositoryId = imageRepository.id
                                            }
                                            
                                            // update parentId if need adjust
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
                                            self.logger.log(.debug, "Found ImageContainer DB record for this subPath")
                                        }
                                        else{ // if image container record does not exist in database
                                            
                                            if let createdContainer = RepositoryDao.default.createContainer(name: name, repositoryId: imageRepository.id, parentId: parentId, subPath: subPath, repositoryPath: volume_repositoryPath) {
                                                self.logger.log(.info, "Created ImageContainer DB record, id=\(createdContainer.id), parentId=\(createdContainer.parentId) path=\(createdContainer.path)")
                                                currentContainer = createdContainer
                                            }else{
                                                self.logger.log(.error, "Cannot create ImageContainer DB record, subPath=\(subPath)")
                                            }
                                        }
                                    }else{
                                        self.logger.log(.debug, "it is a file")
                                        if let currentContainer = currentContainer {
                                            if let existingImageInDB = ImageRecordDao.default.findImage(repositoryVolume: imageRepository.repositoryVolume, repositoryPath: imageRepository.repositoryPath, subPath: subPath) {
                                                
                                                // maintenance image record with empty id
                                                if let imageId = existingImageInDB.id, imageId != "" {
                                                    
                                                }else{
                                                    self.logger.log(.warning, "Image.id is nil, try to generate UUID")
                                                    let (executeState_generateId, imageId) = ImageRecordDao.default.generateImageIdByPath(repositoryVolume: imageRepository.repositoryVolume, repositoryPath: imageRepository.repositoryPath, subPath: subPath)
                                                    
                                                    if executeState_generateId == .OK {
                                                        existingImageInDB.id = imageId
                                                        self.logger.log(.info, "Image.id is updated with generated UUID \(imageId)")
                                                    }else{
                                                        self.logger.log(.error, "Cannot update Image.id with generated UUID, subPath=\(subPath)")
                                                    }
                                                }
                                                
                                                // maintenance image record with incorrect repositoryId and/or incorrect containerId
                                                if let imageId = existingImageInDB.id, imageId != "" {
                                                    
                                                    if existingImageInDB.repositoryId != imageRepository.id || existingImageInDB.containerId != currentContainer.id {
                                                        let executeState = ImageRecordDao.default.updateImageWithContainerId(id: imageId, repositoryId: imageRepository.id, containerId: currentContainer.id)
                                                        if executeState != .OK {
                                                            self.logger.log(.error, "Failed to update Image with repositoryId=\(imageRepository.id), containerId=\(currentContainer.id), imageId=\(imageId): ExecuteState=\(executeState)")
                                                        }
                                                    }
                                                }
                                                
                                            }else{
                                                
                                                if let createdImage = ImageRecordDao.default.createImage(repositoryId: imageRepository.id, containerId: currentContainer.id, repositoryVolume: imageRepository.repositoryVolume, repositoryPath: imageRepository.repositoryPath, subPath: subPath) {
                                                    self.logger.log(.info, "Created Image DB record, id=\(createdImage.id ?? ""), repositoryId=\(imageRepository.id), containerId=\(currentContainer.id), path=\(createdImage.path)")
                                                }else{
                                                    self.logger.log(.error, "Cannot create Image DB record, subPath=\(subPath)")
                                                }
                                            }
                                        }else{
                                            // would not happen
                                            self.logger.log(.error, "No container able to link to this file")
                                        }
                                    }
                                }
                            }catch {
                                self.logger.log(.error, "Unexpected error occured when handling subPath: \(subPath)", error)
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
        }else{
            logger.log(.error, "DB record not found for ImageRepository with id: \(self._repositoryId)")
            self.forceStop = false
            self.working = false
            self.toggleButtons(true)
        }
    }
    
    
    
}
