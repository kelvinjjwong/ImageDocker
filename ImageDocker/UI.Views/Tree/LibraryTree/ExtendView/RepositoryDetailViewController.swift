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
    
    let logger = LoggerFactory.get(category: "TreeExpand", subCategory: "RepositoryDetailViewController")
    
    @IBOutlet weak var btnConfig: NSButton!
    @IBOutlet weak var btnReScanFolders: NSButton!
    
    @IBOutlet weak var lblRepositoryName: NSTextField!
    
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
    
    @IBOutlet weak var lblLastDateCopiedFromDevice: NSTextField!
    @IBOutlet weak var lblLastDateImageShouldImport: NSTextField!
    @IBOutlet weak var lblLastDateImportedEditable: NSTextField!
    @IBOutlet weak var lblLastDateExtractedEXIF: NSTextField!
    @IBOutlet weak var lblLastDateRecognizedLocation: NSTextField!
    
    
    @IBOutlet weak var lblCaptionFolder: NSTextField!
    
    
    @IBOutlet weak var tblDeviceInfo: NSTableView!
    
    var deviceInfoTableController : DictionaryTableViewController!
    
    var accumulator:Accumulator? = nil
    var working = false
    var forceStop = false
    
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
//        self.btnGotoPath.title = Words.library_tree_reveal_in_finder.word()
        
        
        self.txtDetail.isEditable = false
        self.txtDetail.isHidden = true
        
        self.deviceInfoTableController = DictionaryTableViewController(self.tblDeviceInfo)
        self.deviceInfoTableController.editableColumns = ["value"]
        
        self.deviceInfoTableController.onValueChanged = { id, column, originValue, newValue in
            if let repository = self.repository, repository.deviceId != "" {
                let _ = DeviceDao.default.updateMetaInfo(deviceId: repository.deviceId, metaId: id, value: newValue)
            }
        }
    }
    
    var repoSpace:[String:String] = [:]
    var backupSpace:[String:String] = [:]
    var faceSpace:[String:String] = [:]
    
    fileprivate var onConfigure: (() -> Void)!
    fileprivate var onManageSubContainers: (() -> Void)!
    var onShowDeviceDialog: ((PhoneDevice) -> Void)!
    
    var repository:ImageRepository?
    var _repositoryId:Int = 0
    var _repositoryPath:String = ""
    var _repositoryName = ""
    
    var phoneDevice:PhoneDevice? = nil
    
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
        self._repositoryName = repository.name
        
        if let owner_p = FaceDao.default.getPerson(id: repository.owner) {
            self.lblRepositoryName.stringValue = "\(owner_p.name) / \(repository.name)"
        }else{
            self.lblRepositoryName.stringValue = "\(repository.name)"
        }
        
        if repository.deviceId != "" {
            if let device = DeviceDao.default.getDevice(deviceId: repository.deviceId) {
                self.lblRepositoryName.stringValue = "\(self.lblRepositoryName.stringValue) - \(device.manufacture ?? "") \(device.model ?? "") \(device.marketName ?? "")"
            }
        }
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
        
        self.lblLastDateExtractedEXIF.stringValue = ""
        self.lblLastDateImportedEditable.stringValue = ""
        self.lblLastDateRecognizedLocation.stringValue = ""
        self.lblLastDateCopiedFromDevice.stringValue = ""
        self.lblLastDateImageShouldImport.stringValue = ""

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
        
        self.loadImportStatus(repositoryId: self._repositoryId)
        
        self.loadDiskSize()
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
        self.copyFromDevice()
    }
    
    func toggleButtons(_ state:Bool) {
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
        if let repository = RepositoryDao.default.getRepository(id: self._repositoryId) {
            self.toggleButtons(false)
            let indicator = Accumulator(target: 2,
                                        indicator: self.indProgress,
                                        suspended: true,
                                        lblMessage: self.lblMessage,
                                        presetAddingMessage: Words.searchingImagesForEXIF.word(), // progress indicate 1 (RepositoryDetailViewController - Accumulator(target: 2)
                                        onCompleted: { data in
                                            self.logger.log(.trace, "====== COMPLETED SCAN single REPO for EXIF \(repository.name)")
                                            self.toggleButtons(true)
            },
                                        onDataChanged: {
                                            self.logger.log(.trace, "====== DATE CHANGED when SCAN single REPO for EXIF \(repository.name)")
            })
            
            ImageFolderTreeScanner.default.scanPhotosToLoadExif_asTask(repository: repository, indicator: indicator, onCompleted: {
                self.logger.log(.trace, ">>>> onCompleted")
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
                                            self.logger.log(.trace, "====== COMPLETED SCAN single REPO for location \(repository.name)")
                                            self.toggleButtons(true)
            },
                                        onDataChanged: {
                                            self.logger.log(.trace, "====== DATE CHANGED when SCAN single REPO for location \(repository.name)")
            })
            
            ImageFolderTreeScanner.default.scanPhotosToLoadLocation_asTask(repository: repository, indicator: indicator, onCompleted: {
                self.logger.log(.trace, ">>>> onCompleted")
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
    
    
    
    private func scanImageRepository_Exif() {
        
    }
    
}
