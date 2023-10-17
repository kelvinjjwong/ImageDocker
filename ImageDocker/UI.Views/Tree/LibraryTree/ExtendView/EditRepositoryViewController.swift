//
//  EditRepositoryViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/30.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class EditRepositoryViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "REPO", subCategory: "CONFIG")
    
    private var originalRepositoryId:Int = 0
    private var originalContainer:ImageContainer? = nil
    
    // MARK: - FIELDS
    
    @IBOutlet weak var lblOwner: NSTextField!
    @IBOutlet weak var ddlOwner: NSPopUpButton!
    
    
    @IBOutlet weak var lblSubFolderLabel: NSTextField!
    @IBOutlet weak var lblSubFolderLevel: NSTextField!
    @IBOutlet weak var lblDevice: NSTextField!
    @IBOutlet weak var lblCropsImagesPath: NSTextField!
    @IBOutlet weak var lblFacesImagesPath: NSTextField!
    @IBOutlet weak var lblRawImagesPath: NSTextField!
    @IBOutlet weak var lblEditableImagesPath: NSTextField!
    @IBOutlet weak var lblHomePath: NSTextField!
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtHomePath: NSTextField!
    @IBOutlet weak var txtStoragePath: NSTextField!
    @IBOutlet weak var txtRepository: NSTextField!
    @IBOutlet weak var txtFacePath: NSTextField!
    @IBOutlet weak var txtCropPath: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var btnBrowseHomePath: NSButton!
    @IBOutlet weak var btnBrowseStoragePath: NSButton!
    @IBOutlet weak var btnBrowseRepositoryPath: NSButton!
    @IBOutlet weak var btnBrowseFacePath: NSButton!
    @IBOutlet weak var btnBrowseCropPath: NSButton!
    @IBOutlet weak var btnFindHomePath: NSButton!
    @IBOutlet weak var btnFindStoragePath: NSButton!
    @IBOutlet weak var btnFindRepositoryPath: NSButton!
    @IBOutlet weak var btnFindFacePath: NSButton!
    @IBOutlet weak var btnFindCropPath: NSButton!
    @IBOutlet weak var lblNameRemark: NSTextField!
    @IBOutlet weak var lblHomePathRemark: NSTextField!
    @IBOutlet weak var lblStoragePathRemark: NSTextField!
    @IBOutlet weak var lblRepositoryPathRemark: NSTextField!
    @IBOutlet weak var lblFacePathRemark: NSTextField!
    @IBOutlet weak var lblCropPathRemark: NSTextField!
    @IBOutlet weak var btnFollowHomePath: NSButton!
    @IBOutlet weak var btnCopyToRaw: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var btnRestoreOriginal: NSButton!
    @IBOutlet weak var btnUpdateStorageImages: NSButton!
    @IBOutlet weak var btnUpdateRepositoryImages: NSButton!
    @IBOutlet weak var btnUpdateFaceImages: NSButton!
    @IBOutlet weak var btnUpdateCropImages: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var lblDeviceId: NSTextField!
    @IBOutlet weak var lblDeviceName: NSTextField!
    @IBOutlet weak var btnLoadDevices: NSButton!
    @IBOutlet weak var btnCompareDevicePath: NSButton!
    @IBOutlet weak var btnCleanDevice: NSButton!
    @IBOutlet weak var btnShowHide: NSButton!
    @IBOutlet weak var btnNormalize: NSButton!
    @IBOutlet weak var btnStat: NSButton!
    @IBOutlet weak var btnFaceBackToOrigin: NSButton!
    @IBOutlet weak var btnFaceFollowHome: NSButton!
    @IBOutlet weak var btnPathsFollowDevice: NSButton!
//    @IBOutlet weak var btnFindFaces: NSButton!
    @IBOutlet weak var boxRepository: NSBox!
    @IBOutlet weak var boxFaces: NSBox!
    @IBOutlet weak var boxDevice: NSBox!
    @IBOutlet weak var btnUpdateEmptyEvent: NSButton!
    @IBOutlet weak var chkFolderAsEvent: NSButton!
    @IBOutlet weak var lstEventFolderLevel: NSPopUpButton!
    @IBOutlet weak var btnPreviewEventFolders: NSButton!
    @IBOutlet weak var btnUpdateAllEvents: NSButton!
    @IBOutlet weak var chkFolderAsBrief: NSButton!
    @IBOutlet weak var lstBriefFolderLevel: NSPopUpButton!
    @IBOutlet weak var btnPreviewBriefFolders: NSButton!
    @IBOutlet weak var btnUpdateEmptyBrief: NSButton!
    @IBOutlet weak var btnUpdateAllBrief: NSButton!
    
    // MARK: - DROP DOWN LISTS
    @IBOutlet weak var lstVolumesOfEditableImages: NSComboBox!
    @IBOutlet weak var lstVolumesOfRawImages: NSComboBox!
    @IBOutlet weak var lstVolumesOfFaces: NSComboBox!
    @IBOutlet weak var lstVolumesOfCrops: NSComboBox!
    @IBOutlet weak var lstVolumesOfHome: NSComboBox!
    
    var ownerListController : TextListViewPopupController!
    var volumesOfEditableImagesListController : TextListViewPopupController!
    var volumesOfRawImagesListController : TextListViewPopupController!
    var volumesOfFacesListController : TextListViewPopupController!
    var volumesOfCropsListController : TextListViewPopupController!
    var volumesOfHomeListController : TextListViewPopupController!
    
    
    private var window:NSWindow? = nil
    
    var eventFoldersPreviewPopover : TwoColumnTablePopover!
    var briefFoldersPreviewPopover : TwoColumnTablePopover!
    
    private var accumulator:Accumulator? = nil
    
    private var working = false
    
    // MARK: - FUTURE ACTIONS
    
    fileprivate var onCompleted: (() -> Void)?
    
    // MARK: - INIT
    
    init(){
        super.init(nibName: "EditRepositoryViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventFoldersPreviewPopover = TwoColumnTablePopover(width: 600, height: 500) { id, name, action in
            // do nothing
        }
        self.briefFoldersPreviewPopover = TwoColumnTablePopover(width: 600, height: 500) { id, name, action in
            // do nothing
        }
        
        self.ownerListController = TextListViewPopupController(self.ddlOwner)
        self.volumesOfEditableImagesListController = TextListViewPopupController(self.lstVolumesOfEditableImages)
        self.volumesOfRawImagesListController = TextListViewPopupController(self.lstVolumesOfRawImages)
        self.volumesOfFacesListController = TextListViewPopupController(self.lstVolumesOfFaces)
        self.volumesOfCropsListController = TextListViewPopupController(self.lstVolumesOfCrops)
        self.volumesOfHomeListController = TextListViewPopupController(self.lstVolumesOfHome)
        
        self.refreshCoreMembers(selectedValue: "")
        self.refreshMountedVolumes(append: Setting.localEnvironment.localDiskMountPoints())
        
        self.setupUIDisplay()
    }
    
    var owners:[String:String] = [:]
    
    func refreshCoreMembers(selectedValue:String) {
        self.owners.removeAll()
        var items:[String] = []
        var ids:[String] = []
        
        ids.append("shared")
        items.append(Words.owner_public_shared.word())
        self.owners[Words.owner_public_shared.word()] = "shared"
        
        let coreMembers = FaceDao.default.getCoreMembers()
        for m in coreMembers {
            ids.append(m.id)
            items.append(m.shortName ?? m.name)
            self.owners[m.shortName ?? m.name] = m.id
        }
        self.ownerListController.load(items)
        
        if ids.contains(selectedValue) {
            if let option = owners.first(where: { key, value in
                return value == selectedValue
            }) {
                self.ownerListController.select(option.key)
            }
        }else{
            self.ownerListController.select(Words.owner_public_shared.word())
        }
    }
    
    // MARK: - refresh volumes drop down
    
    func refreshMountedVolumes(dropdown list:TextListViewPopupController, append items:[String] = []) {
        var mountedVolumes = LocalDirectory.bridge.listMountedVolumes()
        
        for item in items {
            if !mountedVolumes.contains(item) {
                mountedVolumes.append(item)
            }
        }
        list.load(mountedVolumes)
    }
    
    func refreshMountedVolumes(append items:[String] = []) {
        
        var mountedVolumes = LocalDirectory.bridge.listMountedVolumes()
        
        for item in items {
            if !mountedVolumes.contains(item) {
                mountedVolumes.append(item)
            }
        }
        mountedVolumes.sort()
        
        self.volumesOfEditableImagesListController.load(mountedVolumes)
        self.volumesOfRawImagesListController.load(mountedVolumes)
        self.volumesOfFacesListController.load(mountedVolumes)
        self.volumesOfCropsListController.load(mountedVolumes)
        self.volumesOfHomeListController.load(mountedVolumes)
    }
    
    // MARK: - setup UI / toggle buttons
    
    func setupUIDisplay() {
//        self.btnFindFaces.title = Words.findFaces.word()
        self.lblName.stringValue = Words.repository_name.word()
        self.lblHomePath.stringValue = Words.repository_home_path.word()
        self.lblEditableImagesPath.stringValue = Words.repository_editable_images_path.word()
        self.lblRawImagesPath.stringValue = Words.repository_raw_images_path.word()
        self.lblFacesImagesPath.stringValue = Words.repository_faces_images_path.word()
        self.lblCropsImagesPath.stringValue = Words.repository_crops_images_path.word()
        self.boxRepository.title = Words.repository_box_store_images.word()
        self.boxFaces.title = Words.repository_box_store_faces.word()
        self.boxDevice.title = Words.repository_box_link_to_device.word()
        
        self.btnOK.title = Words.saveRepository.word()
        self.btnStat.title = Words.stat.word()
        self.btnRemove.title = Words.deleteAllImages.word()
        self.btnShowHide.title = Words.disableRepository.word()
        self.btnCopyToRaw.title = Words.copyEditableImagesToRaw.word()
        self.btnNormalize.title = Words.normalizeDuplicatedHiddens.word()
        self.btnCleanDevice.title = Words.clean.word()
        self.btnLoadDevices.title = Words.link.word()
        self.btnFindCropPath.title = Words.viewInFinder.word()
        self.btnFindFacePath.title = Words.viewInFinder.word()
        self.btnFindHomePath.title = Words.viewInFinder.word()
        self.btnBrowseCropPath.title = Words.browsePath.word()
        self.btnBrowseFacePath.title = Words.browsePath.word()
        self.btnBrowseHomePath.title = Words.browsePath.word()
        self.btnFaceFollowHome.title = Words.followHome.word()
        self.btnFollowHomePath.title = Words.followHome.word()
        self.btnFindStoragePath.title = Words.viewInFinder.word()
        self.btnRestoreOriginal.title = Words.backToOrigin.word()
        self.btnFaceBackToOrigin.title = Words.backToOrigin.word()
        self.btnUpdateCropImages.title = Words.update.word()
        self.btnUpdateFaceImages.title = Words.update.word()
        self.btnBrowseStoragePath.title = Words.browsePath.word()
        self.btnCompareDevicePath.title = Words.checkPaths.word()
        self.btnPathsFollowDevice.title = Words.pathFollowDevicePath.word()
        self.btnFindRepositoryPath.title = Words.viewInFinder.word()
        self.btnUpdateStorageImages.title = Words.update.word()
        self.btnBrowseRepositoryPath.title = Words.browsePath.word()
        self.btnUpdateRepositoryImages.title = Words.update.word()
        self.btnUpdateEmptyEvent.title = Words.updateEmptyEvents.word()
        self.btnUpdateAllEvents.title = Words.updateAllEvents.word()
        self.btnUpdateEmptyBrief.title = Words.updateEmptyBriefs.word()
        self.btnUpdateAllBrief.title = Words.updateAllBriefs.word()
        self.btnPreviewEventFolders.title = Words.preview.word()
        self.btnPreviewBriefFolders.title = Words.preview.word()
        self.chkFolderAsBrief.title = Words.useFolderAsBrief.word()
        self.chkFolderAsEvent.title = Words.useFolderAsEvent.word()
    }
    
    fileprivate func toggleButtons(_ show:Bool){
        DispatchQueue.main.async {
//            self.btnFindFaces.isEnabled = show
            self.btnOK.isEnabled = show
            self.btnStat.isEnabled = show
            self.btnRemove.isEnabled = show
            self.btnShowHide.isEnabled = show
            self.btnCopyToRaw.isEnabled = show
            self.btnNormalize.isEnabled = show
            self.btnCleanDevice.isEnabled = show
            self.btnLoadDevices.isEnabled = show
            self.btnFindCropPath.isEnabled = show
            self.btnFindFacePath.isEnabled = show
            self.btnFindHomePath.isEnabled = show
            self.btnBrowseCropPath.isEnabled = show
            self.btnBrowseFacePath.isEnabled = show
            self.btnBrowseHomePath.isEnabled = show
            self.btnFaceFollowHome.isEnabled = show
            self.btnFollowHomePath.isEnabled = show
            self.btnFindStoragePath.isEnabled = show
            self.btnRestoreOriginal.isEnabled = show
            self.btnFaceBackToOrigin.isEnabled = show
            self.btnUpdateCropImages.isEnabled = show
            self.btnUpdateFaceImages.isEnabled = show
            self.btnBrowseStoragePath.isEnabled = show
            self.btnCompareDevicePath.isEnabled = show
            self.btnPathsFollowDevice.isEnabled = show
            self.btnFindRepositoryPath.isEnabled = show
            self.btnUpdateStorageImages.isEnabled = show
            self.btnBrowseRepositoryPath.isEnabled = show
            self.btnUpdateRepositoryImages.isEnabled = show
            self.txtName.isEnabled = show
            self.txtCropPath.isEnabled = show
            self.txtFacePath.isEnabled = show
            self.txtHomePath.isEnabled = show
            self.txtRepository.isEnabled = show
            self.txtStoragePath.isEnabled = show
            self.btnUpdateEmptyEvent.isEnabled = show
            self.btnUpdateAllEvents.isEnabled = show
            self.btnUpdateEmptyBrief.isEnabled = show
            self.btnUpdateAllBrief.isEnabled = show
        }
        
    }
    
    // MARK: - clean fields
    
    fileprivate func emptyGeneralTextFields() {
            self.txtName.stringValue = ""
            self.lblNameRemark.stringValue = ""
            self.txtHomePath.stringValue = ""
            self.lblHomePathRemark.stringValue = ""
            
            self.lblDeviceId.stringValue = ""
            self.lblDeviceName.stringValue = ""
        
        self.ddlOwner.selectItem(withTitle: Words.owner_public_shared.word())
    }
    
    fileprivate func emptyStorageTextFields() {
            self.txtStoragePath.stringValue = ""
            self.lblStoragePathRemark.stringValue = ""
            self.txtRepository.stringValue = ""
            self.lblRepositoryPathRemark.stringValue = ""
            self.btnRestoreOriginal.isHidden = true
            self.btnCopyToRaw.isHidden = true
            self.btnUpdateStorageImages.isHidden = true
            self.btnUpdateRepositoryImages.isHidden = true
        
        self.lstVolumesOfEditableImages.selectItem(withObjectValue: "")
        self.lstVolumesOfRawImages.selectItem(withObjectValue: "")
    }
    
    fileprivate func emptyFaceTextFields() {
            self.txtFacePath.stringValue = ""
            self.lblFacePathRemark.stringValue = ""
            self.txtCropPath.stringValue = ""
            self.lblCropPathRemark.stringValue = ""
            self.btnUpdateFaceImages.isHidden = true
            self.btnUpdateCropImages.isHidden = true
        
        self.lstVolumesOfFaces.selectItem(withObjectValue: "")
        self.lstVolumesOfCrops.selectItem(withObjectValue: "")
    }
    
    fileprivate func freshNew() {
        
        self.emptyGeneralTextFields()
        self.emptyStorageTextFields()
        self.emptyFaceTextFields()
        self.originalRepositoryId = 0
        self.originalContainer = nil
        self.btnOK.title = Words.save.word()
        self.lblMessage.stringValue = ""
        if let window = self.window {
            window.title = Words.addRepository.word()
        }
        self.btnBrowseHomePath.title = Words.assign.word()
        self.btnBrowseStoragePath.title = Words.assign.word()
        self.btnBrowseRepositoryPath.title = Words.assign.word()
        self.btnBrowseFacePath.title = Words.assign.word()
        self.btnBrowseCropPath.title = Words.assign.word()
        self.btnFaceBackToOrigin.isHidden = true
        self.btnNormalize.isHidden = true
//        self.btnFindFaces.isHidden = true
        self.btnShowHide.isHidden = true
        self.btnStat.isHidden = true
        self.btnRestoreOriginal.isHidden = true
        self.btnCopyToRaw.isHidden = true
        self.btnUpdateStorageImages.isHidden = true
        self.btnUpdateRepositoryImages.isHidden = true
        self.btnUpdateFaceImages.isHidden = true
        self.btnUpdateCropImages.isHidden = true
        self.btnRemove.isHidden = true
        self.btnUpdateEmptyEvent.isHidden = true
        
        self.lblDeviceId.stringValue = ""
        self.lblDeviceName.stringValue = ""
        
        self.lstEventFolderLevel.selectItem(at: 0)
        self.lstBriefFolderLevel.selectItem(at: 0)
    }
    
    // - MARK: get / set volume and path
    
    func setVolumeAndPath(path: String, volumeDropdown list: NSComboBox, volumeController: TextListViewPopupController, pathField text: NSTextField) {
        let (volume, path) = path.getVolumeFromThisPath()
        
        self.refreshMountedVolumes(dropdown: volumeController, append: [volume])
        list.selectItem(withObjectValue: volume)
        text.stringValue = path
    }
    
    func getVolumePath(dropdown list:NSComboBox, text:NSTextField) -> String {
        return "\(list.objectValueOfSelectedItem ?? "")\(text.stringValue)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // - MARK: init view
    
    func initNew(window:NSWindow, onOK: (() -> Void)? = nil) {
        self.onCompleted = onOK
        self.window = window
        
        freshNew()
    }
    
    func initEdit(id:Int, path:String, window:NSWindow, onOK: (() -> Void)? = nil) {
        self.onCompleted = onOK
        self.window = window
        self.emptyGeneralTextFields()
        self.emptyStorageTextFields()
        self.emptyFaceTextFields()
        self.lblMessage.stringValue = ""
        let (repositoryVolume, repositoryPath) = path.removeLastStash().getVolumeFromThisPath()
        if let repository = RepositoryDao.default.getRepository(id: id) {
            
//            let container = RepositoryDao.default.getContainer(path: path.removeLastStash()) // fix: change to get by id
            let container = RepositoryDao.default.getRepositoryLinkingContainer(repositoryId: repository.id)
            self.originalRepositoryId = repository.id
            self.originalContainer = container
            self.txtName.stringValue = repository.name
            self.txtHomePath.stringValue = "\(repository.homePath)"
            self.txtRepository.stringValue = "\(repository.repositoryPath)"
            self.txtStoragePath.stringValue = "\(repository.storagePath)"
            self.txtFacePath.stringValue = "\(repository.facePath)"
            self.txtCropPath.stringValue = "\(repository.cropPath)"
            
            self.refreshCoreMembers(selectedValue: repository.owner)
            
            let userDefinedMountPoints = Setting.localEnvironment.localDiskMountPoints()
            
            self.refreshMountedVolumes(append: [
                repository.homeVolume,
                repository.repositoryVolume,
                repository.storageVolume,
                repository.faceVolume,
                repository.cropVolume
            ].appending(userDefinedMountPoints))
            
            self.lstVolumesOfEditableImages.selectItem(withObjectValue: repository.repositoryVolume)
            self.lstVolumesOfRawImages.selectItem(withObjectValue: repository.storageVolume)
            self.lstVolumesOfFaces.selectItem(withObjectValue: repository.faceVolume)
            self.lstVolumesOfCrops.selectItem(withObjectValue: repository.cropVolume)
            self.lstVolumesOfHome.selectItem(withObjectValue: repository.homeVolume)
            
            self.btnFaceBackToOrigin.isHidden = false
            self.btnNormalize.isHidden = false
//            self.btnFindFaces.isHidden = false
            self.btnShowHide.isHidden = false
            self.btnStat.isHidden = false
            self.btnRestoreOriginal.isHidden = false
            self.btnCopyToRaw.isHidden = false
            self.btnUpdateStorageImages.isHidden = false
            self.btnUpdateRepositoryImages.isHidden = false
            self.btnUpdateFaceImages.isHidden = false
            self.btnUpdateCropImages.isHidden = false
            self.btnRemove.isHidden = false
            self.btnUpdateEmptyEvent.isHidden = false
            self.btnOK.title = Words.updateRepositoryName.word()
            window.title = Words.editRepository.word()
            
            self.btnBrowseRepositoryPath.title = Words.moveTo.word()
            
            if repository.homePath == "" {
                self.btnBrowseHomePath.title = Words.assign.word()
            }else{
                self.btnBrowseHomePath.title = Words.moveTo.word()
            }
            if repository.storagePath == "" {
                self.btnBrowseStoragePath.title = Words.assign.word()
            }else{
                self.btnBrowseStoragePath.title = Words.moveTo.word()
            }
            if repository.facePath == "" {
                self.btnBrowseFacePath.title = Words.assign.word()
            }else{
                self.btnBrowseFacePath.title = Words.moveTo.word()
            }
            if repository.cropPath == "" {
                self.btnBrowseCropPath.title = Words.assign.word()
            }else{
                self.btnBrowseCropPath.title = Words.moveTo.word()
            }
            
            self.stat()
            
            if let container = container, container.hiddenByRepository {
                self.btnShowHide.title = Words.enableRepository.word()
            }else{
                self.btnShowHide.title = Words.disableRepository.word()
            }
            
            if repository.deviceId != "" {
                self.displayDeviceInfo(deviceId: repository.deviceId)
            }
            
            self.lstEventFolderLevel.selectItem(at: repository.eventFolderLevel - 1)
            self.chkFolderAsEvent.state = repository.folderAsEvent ? .on : .off
            self.chkFolderAsBrief.state = repository.folderAsBrief ? .on : .off
            
            self.setBriefFolderLevelSelection(repository.briefFolderLevel)
            
        }else{
            self.originalRepositoryId = 0
            self.originalContainer = nil
            self.lblMessage.stringValue = "\(Words.cannotFindRepositoryPath.word()) [id:\(id)][path:\(path)]"
        }
    }
    
    // MARK: - STATISTIC
    
    /// - Tag: EditRepositoryViewController.stat()
    fileprivate func stat() {
        if let container = self.originalContainer {
            let path = container.path
            self.toggleButtons(false)
            DispatchQueue.global().async {
                let imagesTotal = ImageCountDao.default.countImages(repositoryRoot: path)
                let imagesWithoutRepoPath = ImageCountDao.default.countImageWithoutRepositoryPath(repositoryRoot: path)
                let imagesWithoutSubPath = ImageCountDao.default.countImageWithoutSubPath(repositoryRoot: path)
                let imagesWithoutId = ImageCountDao.default.countImageWithoutId(repositoryRoot: path)
                let imagesUnmatchedRepoPath = ImageCountDao.default.countImageUnmatchedRepositoryRoot(repositoryRoot: path)
                let containersWithoutRepoPath = ImageCountDao.default.countContainersWithoutRepositoryPath(repositoryRoot: path)
                let containersWithoutSubPath = ImageCountDao.default.countContainersWithoutSubPath(repositoryRoot: path)
                let imageWithoutFace = ImageCountDao.default.countImageWithoutFace(repositoryRoot: path)
                let imageNotYetFacialDetection = ImageCountDao.default.countImageNotYetFacialDetection(repositoryRoot: path)
                
                let msg = "\(Words.hidden.word()):\(container.hiddenByRepository), \(Words.total.word()):\(imagesTotal), \(Words.imageMissingRepositoryPath.word()):\(imagesWithoutRepoPath), \(Words.imageMissingSubPath.word()):\(imagesWithoutSubPath), \(Words.imageMissingId.word()):\(imagesWithoutId), \(Words.imageNotMatchingRepository.word()):\(imagesUnmatchedRepoPath), \(Words.containerNoRepo.word()):\(containersWithoutRepoPath), \(Words.containerNoSub.word()):\(containersWithoutSubPath), \(Words.imageWithoutFace.word()):\(imageWithoutFace), \(Words.imageNotYetScanFace.word()):\(imageNotYetFacialDetection)"
                
                self.logger.log(msg)
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = msg
                    self.toggleButtons(true)
                }
            }
        }
    }
    
    @IBAction func onStatClicked(_ sender: NSButton) {
        self.stat()
    }
    
    
    // MARK: - HELPER
    
    fileprivate func checkDirectory(path:String, messageBox:NSTextField) -> Bool {
        var pass = true
        let trimPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimPath.isDirectoryExists() || trimPath.isVolumeExists() {
            if trimPath.isFileExists() {
                if !trimPath.isDirectoryExists() {
                    pass = false
                    messageBox.stringValue = "Path is occupied by a file. You need a folder."
                }
            }else{
                let (created, error) = trimPath.mkdirs(logger: self.logger)
                if !created {
                    pass = false
                    messageBox.stringValue = "Unable to create directory at \(path) - \(error)"
                }
            }
            return pass
        }else{
            messageBox.stringValue = "Volume is not mounted, please mount it first."
            return false
        }
    }
    
    // MARK: - ACTION - SAVE NEW
    
    /// - Tag: EditRepositoryViewController.saveNewRepository()
    fileprivate func saveNewRepository() {
        let ownerName = self.ddlOwner.titleOfSelectedItem ?? Words.owner_public_shared.word()
        let ownerId = self.owners[ownerName] ?? ownerName
        
        let name = self.txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let homePath = self.getVolumePath(dropdown: self.lstVolumesOfHome, text: self.txtHomePath)
        let storagePath = self.getVolumePath(dropdown: self.lstVolumesOfRawImages, text: self.txtStoragePath)
        let facePath = self.getVolumePath(dropdown: self.lstVolumesOfFaces, text: self.txtFacePath)
        let cropPath = self.getVolumePath(dropdown: self.lstVolumesOfCrops, text: self.txtCropPath)
        let repositoryPath = self.getVolumePath(dropdown: self.lstVolumesOfEditableImages, text: self.txtRepository)
        let deviceId = self.lblDeviceId.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if name == "" {
            self.lblNameRemark.stringValue = "Please give me a name."
        }
        if homePath == "" || self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
        }
        if storagePath == "" || self.txtStoragePath.stringValue == "" {
            self.lblStoragePathRemark.stringValue = "Please assign path for storing RAW copies."
        }
        if repositoryPath == "" || self.txtRepository.stringValue == "" {
            self.lblRepositoryPathRemark.stringValue = "Please assign path for storing modifies."
        }
        if facePath == "" || self.txtFacePath.stringValue == "" {
            self.lblFacePathRemark.stringValue = "Please assign path for storing recognized pictures."
        }
        if cropPath == "" || self.txtCropPath.stringValue == "" {
            self.lblCropPathRemark.stringValue = "Please assign path for storing faces within pictures."
        }
        guard name != ""
            && homePath != ""
            && storagePath != ""
            && repositoryPath != ""
            && facePath != ""
            && cropPath != ""
            else {return}
        var pass = true
        pass = pass && self.checkDirectory(path: homePath, messageBox: self.lblHomePathRemark)
        pass = pass && self.checkDirectory(path: storagePath, messageBox: self.lblStoragePathRemark)
        pass = pass && self.checkDirectory(path: repositoryPath, messageBox: self.lblRepositoryPathRemark)
        pass = pass && self.checkDirectory(path: facePath, messageBox: self.lblFacePathRemark)
        pass = pass && self.checkDirectory(path: cropPath, messageBox: self.lblCropPathRemark)
        
        guard pass else {return}
        
        
        
        let imagefolder = RepositoryDao.default.createRepository(name: name,
                                                                 owner: ownerId,
                                                path: repositoryPath,
                                                homePath: homePath,
                                                storagePath: storagePath,
                                                facePath: facePath,
                                                cropPath: cropPath)
        
        if let repository = imagefolder.containerFolder {
            let repo = repository
            repo.folderAsEvent = (self.chkFolderAsEvent.state == .on)
            repo.eventFolderLevel = (self.lstEventFolderLevel.indexOfSelectedItem + 1)
            repo.folderAsBrief = (self.chkFolderAsBrief.state == .on)
            repo.briefFolderLevel = self.getBriefFolderLevelFromSelection()
            repo.deviceId = deviceId
            let _ = RepositoryDao.default.saveImageContainer(container: repo)
        }
    }
    
    // MARK: - ACTION - SAVE EXISTS
    
    /// - Tag: EditRepositoryViewController.onOKClicked()
    @IBAction func onOKClicked(_ sender: Any) {
        
        if let container = self.originalContainer { // edit
            let ownerName = self.ddlOwner.titleOfSelectedItem ?? Words.owner_public_shared.word()
            let ownerId = self.owners[ownerName] ?? ownerName
            
            let name = self.txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let homePath = self.getVolumePath(dropdown: self.lstVolumesOfHome, text: self.txtHomePath)
            if name == "" {
                self.lblNameRemark.stringValue = "Please give me a name."
                return
            }
            if homePath == "" || self.txtHomePath.stringValue == "" {
                self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
                return
            }
            var pass = true
            pass = pass && self.checkDirectory(path: homePath, messageBox: self.lblHomePathRemark)
            guard pass else {return}
            
            let origin = container
            origin.name = name
            origin.homePath = homePath
            origin.folderAsEvent = self.chkFolderAsEvent.state == .on
            origin.eventFolderLevel = (self.lstEventFolderLevel.indexOfSelectedItem + 1)
            origin.folderAsBrief = (self.chkFolderAsBrief.state == .on)
            origin.briefFolderLevel = self.getBriefFolderLevelFromSelection()
            
            let storagePath = self.getVolumePath(dropdown: self.lstVolumesOfRawImages, text: self.txtStoragePath)
            let facePath = self.getVolumePath(dropdown: self.lstVolumesOfFaces, text: self.txtFacePath)
            let cropPath = self.getVolumePath(dropdown: self.lstVolumesOfCrops, text: self.txtCropPath)
            let repositoryPath = self.getVolumePath(dropdown: self.lstVolumesOfEditableImages, text: self.txtRepository)
            
            let (homeVolume, _homePath) = homePath.getVolumeFromThisPath()
            let (repositoryVolume, _repositoryPath) = repositoryPath.getVolumeFromThisPath()
            let (storageVolume, _storagePath) = storagePath.getVolumeFromThisPath()
            let (faceVolume, _facePath) = facePath.getVolumeFromThisPath()
            let (cropVolume, _cropPath) = cropPath.getVolumeFromThisPath()
            
            RepositoryDao.default.updateRepository(id: self.originalRepositoryId, name: name,
                                                   owner: ownerId,
                                                   homeVolume: homeVolume, homePath: _homePath,
                                                   repositoryVolume: repositoryVolume, repositoryPath: _repositoryPath,
                                                   storageVolume: storageVolume, storagePath: _storagePath,
                                                   faceVolume: faceVolume, facePath: _facePath,
                                                   cropVolume: cropVolume, cropPath: _cropPath)
            
            let _ = RepositoryDao.default.saveImageContainer(container: origin)
            self.lblMessage.stringValue = "Info updated."
            
        }else{ // new
            self.saveNewRepository()
            self.lblMessage.stringValue = "Repository created."
        }
        if self.onCompleted != nil {
            self.onCompleted!()
        }
    }
    
    // MARK: - ACTION - RESTORE/ORIGIN
    
    /// - Tag: EditRepositoryViewController.onRestoreOriginalClicked()
    @IBAction func onRestoreOriginalClicked(_ sender: NSButton) {
        if let container = self.originalContainer {
            self.emptyStorageTextFields()
            self.txtName.stringValue = container.name
            self.setVolumeAndPath(path: container.homePath,
                                  volumeDropdown: self.lstVolumesOfHome,
                                  volumeController: self.volumesOfHomeListController,
                                  pathField: self.txtHomePath)
            self.setVolumeAndPath(path: container.path,
                                  volumeDropdown: self.lstVolumesOfEditableImages,
                                  volumeController: self.volumesOfEditableImagesListController,
                                  pathField: self.txtRepository)
            self.setVolumeAndPath(path: container.storagePath,
                                  volumeDropdown: self.lstVolumesOfRawImages,
                                  volumeController: self.volumesOfRawImagesListController,
                                  pathField: self.txtStoragePath)
            self.btnRestoreOriginal.isHidden = false
            self.btnCopyToRaw.isHidden = false
        }
    }
    
    /// - Tag: EditRepositoryViewController.onRestoreOriginalFacePathClicked()
    @IBAction func onRestoreOriginalFacePathClicked(_ sender: NSButton) {
        
        if let container = self.originalContainer {
            self.emptyFaceTextFields()
            
            self.setVolumeAndPath(path: container.facePath,
                                  volumeDropdown: self.lstVolumesOfFaces,
                                  volumeController: self.volumesOfFacesListController,
                                  pathField: self.self.txtFacePath)
            self.setVolumeAndPath(path: container.cropPath,
                                  volumeDropdown: self.lstVolumesOfCrops,
                                  volumeController: self.volumesOfCropsListController,
                                  pathField: self.txtCropPath)
        }
    }
    
    // MARK: - ACTION - FOLLOW HOME
    
    /// - Tag: EditRepositoryViewController.onFollowHomePathClicked()
    @IBAction func onFollowHomePathClicked(_ sender: NSButton) {
        
        
        let homePath = self.getVolumePath(dropdown: self.lstVolumesOfHome, text: self.txtHomePath)
        
        if homePath == "" || self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
            return
        }
        
        if !self.checkDirectory(path: homePath, messageBox: self.lblHomePathRemark) {
            return
        }
        
        let home = URL(fileURLWithPath: homePath)
        let storage = home.appendingPathComponent("import")
        let repository = home.appendingPathComponent("repository")
        
        if self.txtRepository.stringValue != "" && self.txtRepository.stringValue != repository.path {
            self.lblRepositoryPathRemark.stringValue = "previous: \(self.txtRepository.stringValue)"
        }
        if self.txtStoragePath.stringValue != "" && self.txtStoragePath.stringValue != storage.path  {
            self.lblStoragePathRemark.stringValue = "previous: \(self.txtStoragePath.stringValue)"
        }
        
        if let container = self.originalContainer {
            if container.storagePath != "" {
                self.lblStoragePathRemark.stringValue = "original: \(container.storagePath)"
            }
            if container.path != "" {
                self.lblRepositoryPathRemark.stringValue = "original: \(container.path)"
            }
        }
        
        self.setVolumeAndPath(path: repository.path,
                              volumeDropdown: self.lstVolumesOfEditableImages,
                              volumeController: self.volumesOfEditableImagesListController,
                              pathField: self.txtRepository)
        
        self.setVolumeAndPath(path: storage.path,
                              volumeDropdown: self.lstVolumesOfRawImages,
                              volumeController: self.volumesOfRawImagesListController,
                              pathField: self.txtStoragePath)
    }
    
    /// - Tag: EditRepositoryViewController.onFacePathFollowHomeClicked()
    @IBAction func onFacePathFollowHomeClicked(_ sender: NSButton) {
        
        let homePath = self.getVolumePath(dropdown: self.lstVolumesOfHome, text: self.txtHomePath)
        
        if homePath == "" || self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
            return
        }
        
        if !self.checkDirectory(path: homePath, messageBox: self.lblHomePathRemark) {
            return
        }
        let home = URL(fileURLWithPath: homePath)
        let face = home.appendingPathComponent("faces")
        let crop = home.appendingPathComponent("crop")
        
        if self.txtFacePath.stringValue != "" && self.txtFacePath.stringValue != face.path {
            self.lblFacePathRemark.stringValue = "previous: \(self.txtFacePath.stringValue)"
        }
        if self.txtCropPath.stringValue != "" && self.txtCropPath.stringValue != crop.path {
            self.lblCropPathRemark.stringValue = "previous: \(self.txtCropPath.stringValue)"
        }
        
        if let container = self.originalContainer {
            if container.facePath != "" {
                self.lblFacePathRemark.stringValue = "original: \(container.facePath)"
            }
            if container.cropPath != "" {
                self.lblCropPathRemark.stringValue = "original: \(container.cropPath)"
            }
        }
        
        self.setVolumeAndPath(path: face.path,
                              volumeDropdown: self.lstVolumesOfFaces,
                              volumeController: self.volumesOfFacesListController,
                              pathField: self.txtFacePath)
        
        self.setVolumeAndPath(path: crop.path,
                              volumeDropdown: self.lstVolumesOfCrops,
                              volumeController: self.volumesOfCropsListController,
                              pathField: self.txtCropPath)
    }
    
    /// - Tag: EditRepositoryViewController.onFollowDevicePathsClicked()
    @IBAction func onFollowDevicePathsClicked(_ sender: NSButton) {
        let deviceId = self.lblDeviceId.stringValue
        if deviceId != "" {
            if let device = DeviceDao.default.getDevice(deviceId: deviceId) {
                
                self.setVolumeAndPath(path: device.homePath ?? "",
                                      volumeDropdown: self.lstVolumesOfHome,
                                      volumeController: self.volumesOfHomeListController,
                                      pathField: self.txtHomePath)
                self.setVolumeAndPath(path: device.repositoryPath ?? "",
                                      volumeDropdown: self.lstVolumesOfEditableImages,
                                      volumeController: self.volumesOfEditableImagesListController,
                                      pathField: self.txtRepository)
                self.setVolumeAndPath(path: device.storagePath ?? "",
                                      volumeDropdown: self.lstVolumesOfRawImages,
                                      volumeController: self.volumesOfRawImagesListController,
                                      pathField: self.txtStoragePath)
            }
        }
    }
    
    // MARK: - ACTION - EDITABLE->RAW
    
    /// - Tag: EditRepositoryViewController.onCopyToRawClicked()
    @IBAction func onCopyToRawClicked(_ sender: NSButton) {
        if let container = self.originalContainer {
            if container.repositoryPath == "" {
                self.lblMessage.stringValue = "ERROR: Path for storing editable images cannot be empty. Please assign it and save first."
                return
            }
            if container.storagePath == "" {
                self.lblMessage.stringValue = "ERROR: Path for storing raw images cannot be empty. Please assign it and save first."
                return
            }
            if container.repositoryId == 0 {
                self.logger.log(.error, "[onCopyToRawClicked] container.repository == 0, container.id:\(container.id)")
                self.lblMessage.stringValue = "ERROR: Repository is not linked to this container."
                return
            }
            var repositoryVolume = ""
            var rawVolume = ""
            if let repository = RepositoryDao.default.getRepository(id: container.repositoryId) {
                repositoryVolume = repository.repositoryVolume
                rawVolume = repository.storageVolume
            }
            if repositoryVolume == "" || !repositoryVolume.isVolumeExists() {
                self.logger.log(.error, "[onCopyToRawClicked] Volume disk of editable images is empty or not mounted, volume:\(repositoryVolume), container.id:\(container.id), repositoryId:\(container.repositoryId)")
                self.lblMessage.stringValue = "ERROR: Volume disk of editable images is empty or not mounted."
                return
            }
            if rawVolume == "" || !rawVolume.isVolumeExists() {
                self.logger.log(.error, "[onCopyToRawClicked] Volume disk of raw images is empty or not mounted, volume:\(rawVolume), container.id:\(container.id), repositoryId:\(container.repositoryId)")
                self.lblMessage.stringValue = "ERROR: Volume disk of raw images is empty or not mounted."
                return
            }
            let (_, _repositoryPath) = container.repositoryPath.getVolumeFromThisPath()
            let (_, _rawPath) = container.storagePath.getVolumeFromThisPath()
            let repositoryPath = "\(repositoryVolume)\(_repositoryPath)"
            let rawPath = "\(rawVolume)\(_rawPath)"
            if !repositoryPath.isDirectoryExists() {
                self.lblMessage.stringValue = "ERROR: Path for storing editable images doesn't exist. Please re-assign it and save first."
                return
            }
            if !rawPath.isDirectoryExists() {
                self.lblMessage.stringValue = "ERROR: Path for storing raw images doesn't exist. Please re-assign it and save first."
                return
            }
            
            guard !self.working else {return}
            
            self.working = true
            
            var count = 0
            var copiedCount = 0
            var abnormalCount = 0
            var errorCount = 0
            self.toggleButtons(false)
            DispatchQueue.main.async {
                self.accumulator = Accumulator(target: 100, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage,
                                               onCompleted: { data in
                                                self.lblMessage.stringValue = "Total \(count) images, copied \(copiedCount) images, \(errorCount) images occured error, \(abnormalCount) images ignored (no-sub-path) "
                                                self.working = false
                                                self.toggleButtons(true)
                                               },
                                               startupMessage: "Loading images from database ..."
                                              )
            }
            
            DispatchQueue.global().async {
                let images = ImageSearchDao.default.getImages(repositoryId: container.repositoryId)
                
                if images.count == 0 {
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = "No image could be copied. Please update image-records in the repository if they really exist."
                        self.working = false
                        self.toggleButtons(true)
                    }
                    return
                }
                count = images.count
                DispatchQueue.main.async {
                    self.accumulator?.setTarget(count)
                }
                
                for image in images {
                    if image.subPath != "" {
                        let sourcePath = "\(repositoryPath.withLastStash())\(image.subPath)"
                        let targetPath = "\(rawPath.withLastStash())\(image.subPath)"
                        if FileManager.default.fileExists(atPath: sourcePath) && !FileManager.default.fileExists(atPath: targetPath) {
                            let containerUrl = URL(fileURLWithPath: targetPath).deletingLastPathComponent()
                            
                            do {
                                try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                            }catch{
                                self.logger.log(error)
                            }
                            do { // copy file
                                try FileManager.default.copyItem(atPath: sourcePath, toPath: targetPath)
                                copiedCount += 1
                            }catch{
                                self.logger.log(error)
                                errorCount += 1
                            }
                        }
                    }else{
                        abnormalCount += 1
                    }
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("Processing images ...")
                    }
                }
            }
        }else{
            self.lblMessage.stringValue = "New repository has to be saved first."
            return
        }
    }
    
    // MARK: - ACTION - OPEN/BROWSE
    
    /// - Tag: EditRepositoryViewController.onBrowseHomePath()
    @IBAction func onBrowseHomePath(_ sender: NSButton) {
        if let win = self.window {
        
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true

            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    self.lblHomePathRemark.stringValue = "previous: \(self.txtHomePath.stringValue)"
                    
                    self.setVolumeAndPath(path: url.path,
                                          volumeDropdown: self.lstVolumesOfHome,
                                          volumeController: self.volumesOfHomeListController,
                                          pathField: self.txtHomePath)
                }
            }
        }
    }
    
    /// - Tag: EditRepositoryViewController.onBrowseStoragePathClicked()
    @IBAction func onBrowseStoragePathClicked(_ sender: NSButton) {
        if let win = self.window {
            
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true
            
            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    self.lblStoragePathRemark.stringValue = "previous: \(self.txtStoragePath.stringValue)"
                    
                    self.setVolumeAndPath(path: url.path,
                                          volumeDropdown: self.lstVolumesOfRawImages,
                                          volumeController: self.volumesOfRawImagesListController,
                                          pathField: self.txtStoragePath)
                }
            }
        }
    }
    
    /// - Tag: EditRepositoryViewController.onBrowseRepositoryPathClicked()
    @IBAction func onBrowseRepositoryPathClicked(_ sender: NSButton) {
        if let win = self.window {
            
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true
            
            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    self.lblRepositoryPathRemark.stringValue = "previous: \(self.txtRepository.stringValue)"
                    
                    self.setVolumeAndPath(path: url.path,
                                          volumeDropdown: self.lstVolumesOfEditableImages,
                                          volumeController: self.volumesOfEditableImagesListController,
                                          pathField: self.txtRepository)
                }
            }
        }
    }
    
    /// - Tag: EditRepositoryViewController.onBrowseFacePathClicked()
    @IBAction func onBrowseFacePathClicked(_ sender: NSButton) {
        if let win = self.window {
            
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true
            
            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    self.lblFacePathRemark.stringValue = "previous: \(self.txtFacePath.stringValue)"
                    
                    self.setVolumeAndPath(path: url.path,
                                          volumeDropdown: self.lstVolumesOfFaces,
                                          volumeController: self.volumesOfFacesListController,
                                          pathField: self.txtFacePath)
                }
            }
        }
    }
    
    /// - Tag: EditRepositoryViewController.onBrowseCropPath()
    @IBAction func onBrowseCropPath(_ sender: NSButton) {
        if let win = self.window {
            
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true
            
            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    self.lblCropPathRemark.stringValue = "previous: \(self.txtCropPath.stringValue)"
                    
                    self.setVolumeAndPath(path: url.path,
                                          volumeDropdown: self.lstVolumesOfCrops,
                                          volumeController: self.volumesOfCropsListController,
                                          pathField: self.txtCropPath)
                }
            }
        }
    }
    
    // MARK: - ACTION - VIEW IN FINDER
    
    /// - Tag: EditRepositoryViewController.onFindHomePath()
    @IBAction func onFindHomePath(_ sender: NSButton) {
        let homePath = self.getVolumePath(dropdown: self.lstVolumesOfHome, text: self.txtHomePath)
        
        if homePath == "" || self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
            return
        }
        
        if !self.checkDirectory(path: homePath, messageBox: self.lblHomePathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: homePath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// - Tag: EditRepositoryViewController.onFindStoragePathClicked()
    @IBAction func onFindStoragePathClicked(_ sender: NSButton) {
        let storagePath = self.getVolumePath(dropdown: self.lstVolumesOfRawImages, text: self.txtStoragePath)
        
        if storagePath == "" || self.txtStoragePath.stringValue == "" {
            self.lblStoragePathRemark.stringValue = "Please assign path for storing RAW copies."
            return
        }
        
        if !self.checkDirectory(path: storagePath, messageBox: self.lblStoragePathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: storagePath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// - Tag: EditRepositoryViewController.onFindRepositoryPathClicked()
    @IBAction func onFindRepositoryPathClicked(_ sender: NSButton) {
        let repositoryPath = self.getVolumePath(dropdown: self.lstVolumesOfEditableImages, text: self.txtRepository)
        
        if repositoryPath == "" || self.txtRepository.stringValue == "" {
            self.lblRepositoryPathRemark.stringValue = "Please assign path for storing modifies."
            return
        }
        
        if !self.checkDirectory(path: repositoryPath, messageBox: self.lblRepositoryPathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: repositoryPath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// - Tag: EditRepositoryViewController.onFindFaceRepositoryPathClicked()
    @IBAction func onFindFaceRepositoryPathClicked(_ sender: NSButton) {
        
        let facesPath = self.getVolumePath(dropdown: self.lstVolumesOfFaces, text: self.txtFacePath)
        
        if facesPath == "" || self.txtFacePath.stringValue == "" {
            self.lblFacePathRemark.stringValue = "Please assign path for storing recognized pictures."
            return
        }
        
        if !self.checkDirectory(path: facesPath, messageBox: self.lblFacePathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: facesPath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// - Tag: EditRepositoryViewController.onFindCropPath()
    @IBAction func onFindCropPath(_ sender: NSButton) {
        
        let cropsPath = self.getVolumePath(dropdown: self.lstVolumesOfCrops, text: self.txtCropPath)
        
        if cropsPath == "" || self.txtCropPath.stringValue == "" {
            self.lblCropPathRemark.stringValue = "Please assign path for storing faces within pictures."
            return
        }
        
        if !self.checkDirectory(path: cropsPath, messageBox: self.lblCropPathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: cropsPath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    // MARK: - ACTION - CHANGE RAW PATH
    
    /// - Tag: EditRepositoryViewController.onUpdateStorageImagesClicked()
    @IBAction func onUpdateStorageImagesClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            
            var originalRawVolume = ""
            if let repository = RepositoryDao.default.getRepository(id: repoContainer.repositoryId) {
                originalRawVolume = repository.storageVolume
            }
            if originalRawVolume == "" || !originalRawVolume.isVolumeExists() {
                self.lblStoragePathRemark.stringValue = "Original volume disk of raw version is empty or not mounted: \(originalRawVolume)"
                return
            }
            
            let (_, _originalRawPath) = repoContainer.storagePath.getVolumeFromThisPath()
            
            let originalRawPath = "\(originalRawVolume)\(_originalRawPath)".withLastStash()
            
            if !originalRawPath.isDirectoryExists() {
                self.lblStoragePathRemark.stringValue = "Original path of raw version does not exist: \(originalRawPath)"
                return
            }
            
            let newRawPath = self.getVolumePath(dropdown: self.lstVolumesOfRawImages, text: self.txtStoragePath).withLastStash()
            
            let (newRawVolume, _) = newRawPath.getVolumeFromThisPath()
            
            if !newRawVolume.isVolumeExists() {
                self.lblStoragePathRemark.stringValue = "New volume disk of raw version is empty or not mounted: \(newRawVolume)"
                return
            }
            
            if newRawPath == "" || !newRawPath.isDirectoryExists() {
                self.lblStoragePathRemark.stringValue = "New path of raw version does not exist: \(newRawPath)"
                return
            }
            if newRawPath == originalRawPath {
                self.lblStoragePathRemark.stringValue = "Path of raw version has no change."
                return
            }
            
            self.working = true
            
            self.lblMessage.stringValue = "Checking for update ..."
            
            
            self.toggleButtons(false)
            self.lblMessage.stringValue = ""
            
            DispatchQueue.global().async {
            
                if originalRawPath != "/" && originalRawPath != "" { // clone from original RAW path
                    let oldBaseUrl = URL(fileURLWithPath: originalRawPath)
                    let newBaseUrl = URL(fileURLWithPath: newRawPath)
                    let oldFullUrl = oldBaseUrl.resolvingSymlinksInPath()
                    let newFullUrl = newBaseUrl.resolvingSymlinksInPath()
                    if newFullUrl.path != oldFullUrl.path { // physically inequal, need copy files
                        let oldFiles = oldBaseUrl.walkthruDirectory()  // FIXME: load from database instead?
                        
                        let total = oldFiles.allObjects.count
                        
                        DispatchQueue.main.async {
                            self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                        }
                        
                        for case let oldUrl as URL in oldFiles {
                            let newFilePath = oldUrl.path.replacingFirstOccurrence(of: oldBaseUrl.path.withLastStash(), with: newBaseUrl.path.withLastStash())
                            let newUrl = URL(fileURLWithPath: newFilePath)
                            let containerUrl = newUrl.deletingLastPathComponent()
                            if !FileManager.default.fileExists(atPath: newFilePath) { // no folder, create folder
                                do {
                                    try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                                }catch{
                                    self.logger.log(error)
                                }
                                do { // copy file
                                    try FileManager.default.copyItem(at: oldUrl, to: newUrl)
                                }catch{
                                    self.logger.log(error)
                                }
                            }
                            
                            
                            DispatchQueue.main.async {
                                let _ = self.accumulator?.add("Updating RAW images ...")
                            }
                        }
                    }
                }
                
                // save repo's path
                let repo = repoContainer
                repo.storagePath = newRawPath
                let _ = RepositoryDao.default.saveImageContainer(container: repo)
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    self.toggleButtons(true)
                    self.lblMessage.stringValue = "RAW storage updated."
                    
                    self.working = false
                }
                
            }
            
        }
    }
    
    // MARK: - ACTION - CHANGE REPO PATH
    
    /// - Tag: EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    @IBAction func onUpdateRepositoryImagesClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            
            
            var originalRepoVolume = ""
            if let repository = RepositoryDao.default.getRepository(id: repoContainer.repositoryId) {
                originalRepoVolume = repository.repositoryVolume
            }
            if originalRepoVolume == "" || !originalRepoVolume.isVolumeExists() {
                self.lblRepositoryPathRemark.stringValue = "Original volume disk of editable version is empty or not mounted: \(originalRepoVolume)"
                return
            }
            
            let (_, _originalRepoPath) = repoContainer.repositoryPath.getVolumeFromThisPath()
            
            let originalRepoPath = "\(originalRepoVolume)\(_originalRepoPath)".withLastStash()
            
            if !originalRepoPath.isDirectoryExists() {
                self.lblRepositoryPathRemark.stringValue = "Original path of editable version does not exist: \(originalRepoPath)"
                return
            }
            
            let newRepoPath = self.getVolumePath(dropdown: self.lstVolumesOfEditableImages, text: self.txtRepository).withLastStash()
            
            let (newRepoVolume, _) = newRepoPath.getVolumeFromThisPath()
            
            if !newRepoVolume.isVolumeExists() {
                self.lblStoragePathRemark.stringValue = "New volume disk of editable version is empty or not mounted: \(newRepoVolume)"
                return
            }
            
            if newRepoPath == "" || !newRepoPath.isDirectoryExists() {
                self.lblRepositoryPathRemark.stringValue = "New path of editable version does not exist: \(newRepoPath)"
                return
            }
            if newRepoPath == originalRepoPath {
                self.lblRepositoryPathRemark.stringValue = "Path of editable version has no change."
                return
            }
            
            self.working = true
            
            
            self.toggleButtons(false)
            self.lblMessage.stringValue = "Loading editable image files ..."
            
            DispatchQueue.global().async {
            
                // save images' path, save images' repository path to new repository path (base path)
                let images = ImageSearchDao.default.getImages(repositoryId: repoContainer.repositoryId)
                
                if images.count > 0 {
                    
                    let total = images.count
                    
                    DispatchQueue.main.async {
                        self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                    }
                    
                    for image in images {
                        
                        DispatchQueue.main.async {
                            let _ = self.accumulator?.add("Updating editable image files ...")
                        }
                        
                        // fix unmatched repository path: fix physically inequal
                        let newPath = image.path.replacingFirstOccurrence(of: originalRepoPath, with: newRepoPath)
                        let containerUrl = URL(fileURLWithPath: newPath).deletingLastPathComponent()
                        
                        let newUrl = URL(fileURLWithPath: newPath).resolvingSymlinksInPath()
                        let oldUrl = URL(fileURLWithPath: image.path).resolvingSymlinksInPath()
                        
                        if newUrl.path != oldUrl.path { // physically inequal
                            if !FileManager.default.fileExists(atPath: newUrl.path) { // no folder in new place, create folder
                                do {
                                    try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                                }catch{
                                    self.logger.log(error)
                                }
                                do { // no file in new place, copy file
                                    try FileManager.default.copyItem(at: oldUrl, to: newUrl)
                                }catch{
                                    self.logger.log(error)
                                }
                            }
                        }
                        
                        // fix empty repository path
                        let containerPath = containerUrl.path
                        
                        // fix empty sub path
                        let subPath = image.path.replacingFirstOccurrence(of: originalRepoPath, with: "")
                        
                        // fix unmatched repository path: fix logically inequal
                        // change image path to new place
                        let oldPath = image.path
                        
                        // fix empty id
                        if let imageId = image.id {
                            let _ = ImageRecordDao.default.updateImagePaths(id: imageId, newPath: newPath, repositoryPath: newRepoPath, subPath: subPath, containerPath: containerPath)
                        }else {
                            // old logic, can be demised in future
                            let id = image.id ?? UUID().uuidString
                            
                            let _ = ImageRecordDao.default.updateImagePaths(oldPath: oldPath, newPath: newPath, repositoryPath: newRepoPath, subPath: subPath, containerPath: containerPath, id: id)
                        }
                    }
                }
                
                // save sub-containers' path
                
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "Loading sub-folders ..."
                }
                
                let subContainers = RepositoryDao.default.getContainers(repositoryId: repoContainer.repositoryId)
                
                let total = subContainers.count
                
                DispatchQueue.main.async {
                    self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                }
                
                for subContainer in subContainers {
                    
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("Updating sub-containers ...")
                    }
                    
                    let sub = subContainer
                    let oldPath = sub.path
                    if sub.subPath == "" {
                        sub.subPath = sub.path.replacingFirstOccurrence(of: originalRepoPath, with: "")
                    }
                    if sub.parentPath == "" {
                        sub.parentPath = URL(fileURLWithPath: sub.path).deletingLastPathComponent().path.replacingFirstOccurrence(of: originalRepoPath, with: "")
                    }
                    sub.repositoryPath = newRepoPath
                    sub.parentFolder = sub.parentFolder.replacingFirstOccurrence(of: repoContainer.path, with: newRepoPath.removeLastStash()) // without stash
                    sub.path = sub.path.replacingFirstOccurrence(of: originalRepoPath, with: newRepoPath)
                    
                    let _ = RepositoryDao.default.updateImageContainerPaths(containerId: subContainer.id, newPath: sub.path, repositoryPath: sub.repositoryPath, parentFolder: sub.parentFolder, subPath: sub.subPath)
                }
                
                // save repo's path
                let repo = repoContainer
                let oldPath = repo.path
                let newPath = newRepoPath.removeLastStash()
                repo.repositoryPath = newRepoPath
                
                let _ = RepositoryDao.default.updateImageContainerRepositoryPaths(containerId: repoContainer.id, newPath: newPath, repositoryPath: newRepoPath)
                
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    self.initEdit(id: repo.repositoryId, path: newPath, window: self.window!) // reload repository data to form
                    
                    self.toggleButtons(true)
                    //self.lblMessage.stringValue = "Repository updated."
                    
                    self.stat()
                    
                    self.working = false
                }
                
            }
            
        }
    }
    
    // MARK: - ACTION - CHANGE FACE PATH
    
    /// - Tag: EditRepositoryViewController.onUpdateFaceImagesClicked()
    @IBAction func onUpdateFaceImagesClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            
            
            var originalFaceVolume = ""
            if let repository = RepositoryDao.default.getRepository(id: repoContainer.repositoryId) {
                originalFaceVolume = repository.faceVolume
            }
            if originalFaceVolume == "" || !originalFaceVolume.isVolumeExists() {
                self.lblFacePathRemark.stringValue = "Original volume disk of faces is empty or not mounted: \(originalFaceVolume)"
                return
            }
            
            let (_, _originalFacePath) = repoContainer.facePath.getVolumeFromThisPath()
            
            let originalFacePath = "\(originalFaceVolume)\(_originalFacePath)".withLastStash()
            
            if !originalFacePath.isDirectoryExists() {
                self.lblFacePathRemark.stringValue = "Original path of faces does not exist: \(originalFacePath)"
                return
            }
            
            let newFacePath = self.getVolumePath(dropdown: self.lstVolumesOfFaces, text: self.txtFacePath).withLastStash()
            
            let (newFaceVolume, _) = newFacePath.getVolumeFromThisPath()
            
            if !newFaceVolume.isVolumeExists() {
                self.lblFacePathRemark.stringValue = "New volume disk of faces is empty or not mounted: \(newFaceVolume)"
                return
            }
            
            if newFacePath == "" || !newFacePath.isDirectoryExists() {
                self.lblFacePathRemark.stringValue = "New path of faces does not exist: \(newFacePath)"
                return
            }
            if newFacePath == originalFacePath {
                self.lblFacePathRemark.stringValue = "Path of faces has no change."
                return
            }
            
            self.working = true
            
            
            self.toggleButtons(false)
            self.lblMessage.stringValue = ""
            
            DispatchQueue.global().async {
            
                if originalFacePath != "/" { // clone from original FACE path
                    let oldBaseUrl = URL(fileURLWithPath: originalFacePath)
                    let newBaseUrl = URL(fileURLWithPath: newFacePath)
                    let oldFullUrl = oldBaseUrl.resolvingSymlinksInPath()
                    let newFullUrl = newBaseUrl.resolvingSymlinksInPath()
                    
                    // copy physical files
                    if newFullUrl.path != oldFullUrl.path { // physically inequal, need copy files
                        let oldFiles = oldBaseUrl.walkthruDirectory()
                        
                        let total = oldFiles.allObjects.count
                        
                        DispatchQueue.main.async {
                            self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                        }
                        
                        for case let oldUrl as URL in oldFiles {
                            
                            DispatchQueue.main.async {
                                let _ = self.accumulator?.add("Copying face file ...")
                            }
                            
                            let newFilePath = oldUrl.path.replacingFirstOccurrence(of: oldBaseUrl.path.withLastStash(), with: newBaseUrl.path.withLastStash())
                            let newUrl = URL(fileURLWithPath: newFilePath)
                            let containerUrl = newUrl.deletingLastPathComponent()
                            if !FileManager.default.fileExists(atPath: newFilePath) { // no folder, create folder
                                do {
                                    try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                                }catch{
                                    self.logger.log(error)
                                }
                                do { // copy file
                                    try FileManager.default.copyItem(at: oldUrl, to: newUrl)
                                }catch{
                                    self.logger.log(error)
                                }
                            }
                        }
                    }
                }
                
                // Paths of face-images are not necessary to update as the table does not store full paths for faces.
                
                
                // save repo's path
                let repo = repoContainer
                repo.facePath = newFacePath
                let _ = RepositoryDao.default.saveImageContainer(container: repo)
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    
                    self.toggleButtons(true)
                    self.lblMessage.stringValue = "Face files updated."
                    
                    self.working = false
                }
                
            }
            
        }
    }
    
    /// - Tag: EditRepositoryViewController.onUpdateCropImagesClicked()
    @IBAction func onUpdateCropImagesClicked(_ sender: NSButton) {
        // FIXME: DEMISE
       
    }
    
    // MARK: - ACTION - FIX HIDDEN
    
    /// - Tag: EditRepositoryViewController.onNormalizeHiddenClicked()
    @IBAction func onNormalizeHiddenClicked(_ sender: NSButton) {
        let repo = self.getVolumePath(dropdown: self.lstVolumesOfEditableImages, text: self.txtRepository)
        let raw = self.getVolumePath(dropdown: self.lstVolumesOfRawImages, text: self.txtStoragePath)
        guard !self.working && repo != "/" && raw != "/" else {return}
        self.working = true
        
        
        self.toggleButtons(false)
        
        var updateCount = 0
        var count = 0
        
        
        DispatchQueue.main.async {
            self.accumulator = Accumulator(target: 100, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage,
                                           onCompleted: { data in
                                                DispatchQueue.main.async {
                                                    let msg = "Normalized \(count) duplicated image-sets. Updated \(updateCount) images."
                                                    self.logger.log(msg)
                                                    self.lblMessage.stringValue = msg
                                                    self.working = false
                                                    
                                                    self.toggleButtons(true)
                                                }
                                           },
                                           startupMessage: "Loading duplicates from database ..."
                                          )
        }
        DispatchQueue.global().async {
            self.logger.log("loading duplicates from database")
            
            let duplicates = ImageDuplicationDao.default.getDuplicatedImages(repositoryId: self.originalRepositoryId)
            self.logger.log("loaded duplicates \(duplicates.count)")
            
            count = duplicates.count
            self.accumulator?.setTarget(count)
            
            for key in duplicates.keys {
                
                let images = duplicates[key]!
                if images.count >= 2{
                    var rawImgHidden = true
                    var rawImgCount = 0
                    var repoImgCount = 0
                    var showedRepoImgCount = 0
                    for image in images {
                        if image.path.starts(with: raw) {
                            rawImgCount += 1 // if no raw image, no need proceed, nothing to hide
                            rawImgHidden = rawImgHidden && image.hidden // if all raw images are hidden, no need proceed
                        }else if image.path.starts(with: repo) {
                            repoImgCount += 1 // if no repo image, no need proceed, nothing to show
                            if !image.hidden {
                                showedRepoImgCount += 1 // if already showed at least one repo image, no need proceed
                            }
                        }
                    }
                    var needHideRawImage = false
                    var needShowRepoImage = false
                    if repoImgCount > 0 && rawImgCount > 0 {
                        // maybe need flip
                        if !rawImgHidden {
                            // if one or more raw images showed, need hide raw images
                            needHideRawImage = true
                            
                            if showedRepoImgCount == 0 {
                                // if no repo image showed, need show 1st repo image
                                needShowRepoImage = true
                            }
                        }
                    }
                    if needHideRawImage || needShowRepoImage {
                        var doneShowRepoImage = false
                        for image in images {
                            if needHideRawImage && image.path.starts(with: raw) && !image.hidden {
                                // hide raw image if not hidden
                                let img = image
                                img.hidden = true
                                let _ = ImageRecordDao.default.saveImage(image: img)
                                updateCount += 1
                            }
                            if !doneShowRepoImage && needShowRepoImage && image.path.starts(with: repo) {
                                // show the 1st repo image
                                let img = image
                                img.hidden = false
                                let _ = ImageRecordDao.default.saveImage(image: img)
                                updateCount += 1
                                // only do once
                                doneShowRepoImage = true
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    let _ = self.accumulator?.add("Normalizing duplicated image-sets ...")
                }
            }// end of for-loop
            
            
        }// end of background thread
        
    }
    
    // MARK: - ACTION - DELETE RECORDS
    
    /// - Tag: EditRepositoryViewController.onRemoveClicked()
    @IBAction func onRemoveClicked(_ sender: NSButton) {
        if let container = self.originalContainer {
            if Alert.dialogOKCancel(question: "Remove all records and image-records of this repository from database ?", text: container.path) {
                
                self.toggleButtons(false)
                DispatchQueue.global().async {
                    let _ = RepositoryDao.default.deleteRepository(id: container.repositoryId)
                    
                    DispatchQueue.main.async {
                        
                        self.freshNew()
                        
                        self.toggleButtons(true)
                        self.lblMessage.stringValue = "All records and image-records of this repository have been removed from database."
                        
                    }
                }
            }
        }
    }
    
    // MARK: - ACTION - DEVICE INFO
    
    /// - Tag: EditRepositoryViewController.onLoadDevicesClicked()
    @IBAction func onLoadDevicesClicked(_ sender: NSButton) {
        self.createDevicesPopover()
        self.devicesViewController.initView()
        
        let cellRect = sender.bounds
        self.devicesPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    // MARK: - ACTION - COMPARE PATH
    
    /// - Tag: EditRepositoryViewController.onCompareDevicePathClicked()
    @IBAction func onCompareDevicePathClicked(_ sender: NSButton) {
        
        let deviceId = self.lblDeviceId.stringValue
        if deviceId != "" {
            if let device = DeviceDao.default.getDevice(deviceId: deviceId) {
                let deviceHomePath = device.homePath ?? ""
                let deviceRepoPath = device.repositoryPath ?? ""
                let deviceRawPath = device.storagePath ?? ""
                let repoHomePath = self.getVolumePath(dropdown: self.lstVolumesOfHome, text: self.txtHomePath)
                let repoRepoPath = self.getVolumePath(dropdown: self.lstVolumesOfEditableImages, text: self.txtRepository)
                let repoRawPath = self.getVolumePath(dropdown: self.lstVolumesOfRawImages, text: self.txtStoragePath)
                if deviceHomePath != repoHomePath {
                    self.lblHomePathRemark.stringValue = "Different with device setting: [\(deviceHomePath)]"
                }
                if deviceRepoPath != repoRepoPath {
                    self.lblRepositoryPathRemark.stringValue = "Different with device setting: [\(deviceRepoPath)]"
                }
                if deviceRawPath != repoRawPath {
                    self.lblStoragePathRemark.stringValue = "Different with device setting: [\(deviceRawPath)]"
                }
            }
            
        }
    }
    
    /// - Tag: EditRepositoryViewController.onCleanDeviceClicked()
    @IBAction func onCleanDeviceClicked(_ sender: NSButton) {
        self.lblDeviceId.stringValue = ""
        self.lblDeviceName.stringValue = ""
        self.linkDeviceToRepository(deviceId: "", deviceName: "")
    }
    
    /// - Tag: EditRepositoryViewController.linkDeviceToRepository()
    fileprivate func linkDeviceToRepository(deviceId: String, deviceName:String){
        if let container = self.originalContainer { // FIXME: demise?
            let repo = container
            repo.deviceId = deviceId
            let state = RepositoryDao.default.saveImageContainer(container: repo)
            if state != .OK {
                self.lblMessage.stringValue = "\(state) - Unable to link repository with device in database."
            }else{
                self.lblMessage.stringValue = "\(state) - Updated link between repository and device [\(deviceId) - \(deviceName)]."
            }
        }
        if originalRepositoryId > 0 {
            RepositoryDao.default.linkRepositoryToDevice(id: originalRepositoryId, deviceId: deviceId)
        }else{
            self.logger.log(.error, "[linkDeviceToRepository] repository id is nil, unable to link repository with device \(deviceId) [\(deviceName)]")
            self.lblMessage.stringValue = "ImageRepositoryId is nil - Unable to link repository with device in database."
        }
    }
    
    // MARK: - ACTION - SHOW/HIDE
    
    /// - Tag: EditRepositoryViewController.onShowHideClicked()
    @IBAction func onShowHideClicked(_ sender: NSButton) {
        if let container = self.originalContainer {
            if container.hiddenByRepository {
                DispatchQueue.global().async {
                    let _ = RepositoryDao.default.showRepository(id: container.repositoryId)
                    self.originalContainer?.hiddenByRepository = false
                    let _ = RepositoryDao.default.saveImageContainer(container: self.originalContainer!)
                    
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = Words.showImagesOfRepository.word()
                        self.btnShowHide.title = Words.enableRepository.word()
                    }
                    
                    self.stat()
                }
            }else{
                DispatchQueue.global().async {
                    let _ = RepositoryDao.default.hideRepository(id: container.repositoryId)
                    self.originalContainer?.hiddenByRepository = true
                    let _ = RepositoryDao.default.saveImageContainer(container: self.originalContainer!)
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = Words.hideImagesOfRepository.word()
                        self.btnShowHide.title = Words.disableRepository.word()
                    }
                    
                    self.stat()
                }
            }
        }
    }
    
    fileprivate var stopByExceedLimit = false
    fileprivate var continousWorking = false
    fileprivate var continousWorkingAttempt = 0
    fileprivate var continousWorkingRemain = 0
    
    // MARK: - ACTION - FIX BRIEF
    
    /// - Tag: EditRepositoryViewController.onUpdateEmptyBriefClicked()
    @IBAction func onUpdateEmptyBriefClicked(_ sender: NSButton) {
        self.lblMessage.stringValue = "Updating images..."
        self.btnUpdateEmptyBrief.isEnabled = false
        self.btnUpdateAllBrief.isEnabled = false
        self.btnUpdateEmptyEvent.isEnabled = false
        self.btnUpdateAllEvents.isEnabled = false
        DispatchQueue.global().async {
            if let container = self.originalContainer {
                let images = ImageSearchDao.default.getImages(repositoryId: container.repositoryId)
                let level = self.getBriefFolderLevelFromSelection()
                let total = images.count
                var i = 0
                for image in images {
                    if image.shortDescription != nil && image.shortDescription != "" {
                        continue
                    }
                    let img = image
                    i += 1
                    img.shortDescription = Naming.Image.getBriefFromFolderName(image: image, folderLevel: level)
                    let _ = ImageRecordDao.default.saveImage(image: img)
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = "Updating images... (\(i)/\(total))"
                    }
                }
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "Updated (\(i)/\(total)) images."
                    self.btnUpdateEmptyBrief.isEnabled = true
                    self.btnUpdateAllBrief.isEnabled = true
                    self.btnUpdateEmptyEvent.isEnabled = true
                    self.btnUpdateAllEvents.isEnabled = true
                }
            }
        }
    }
    
    /// - Tag: EditRepositoryViewController.onUpdateAllBriefClicked()
    @IBAction func onUpdateAllBriefClicked(_ sender: NSButton) {
        self.lblMessage.stringValue = "Updating images..."
        self.btnUpdateEmptyBrief.isEnabled = false
        self.btnUpdateAllBrief.isEnabled = false
        self.btnUpdateEmptyEvent.isEnabled = false
        self.btnUpdateAllEvents.isEnabled = false
        DispatchQueue.global().async {
            if let container = self.originalContainer {
                let images = ImageSearchDao.default.getImages(repositoryId: container.repositoryId)
                let level = self.getBriefFolderLevelFromSelection()
                let total = images.count
                var i = 0
                for image in images {
                    let img = image
                    i += 1
                    img.shortDescription = Naming.Image.getBriefFromFolderName(image: image, folderLevel: level)
                    let _ = ImageRecordDao.default.saveImage(image: img)
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = "Updating images... (\(i)/\(total))"
                    }
                }
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "Updated (\(i)/\(total)) images."
                    self.btnUpdateEmptyBrief.isEnabled = true
                    self.btnUpdateAllBrief.isEnabled = true
                    self.btnUpdateEmptyEvent.isEnabled = true
                    self.btnUpdateAllEvents.isEnabled = true
                }
            }
        }
    }
    
    /// - Tag: EditRepositoryViewController.getBriefFolderLevelFromSelection()
    private func getBriefFolderLevelFromSelection() -> Int {
        var lv = -1
        let selectedLevel = self.lstBriefFolderLevel.indexOfSelectedItem
        if selectedLevel == 0 {
            lv = -1
        }else if selectedLevel == 1 {
            lv = -2
        }else if selectedLevel == 2 {
            lv = 1
        }else if selectedLevel == 3 {
            lv = 2
        }else{
            lv = -1
        }
        return lv
    }
    
    /// - Tag: EditRepositoryViewController.setBriefFolderLevelSelection()
    private func setBriefFolderLevelSelection(_ value:Int) {
        if value == -1 {
            self.lstBriefFolderLevel.selectItem(at: 0)
        }else if value == -2 {
            self.lstBriefFolderLevel.selectItem(at: 1)
        }else if value == 1 {
            self.lstBriefFolderLevel.selectItem(at: 2)
        }else if value == 2 {
            self.lstBriefFolderLevel.selectItem(at: 3)
        }else{
            
            self.lstBriefFolderLevel.selectItem(at: 0)
        }
    }
    
    /// - Tag: EditRepositoryViewController.onPreviewBriefFolders()
    @IBAction func onPreviewBriefFolders(_ sender: NSButton) {
        let amount = 100
        let lv = self.getBriefFolderLevelFromSelection()
        var array:[String] = []
        if let container = self.originalContainer {
            var folders:Set<String> = []
            let paths = RepositoryDao.default.getAllContainerPathsOfImages(repositoryId: container.repositoryId)
            for path in paths {
                if path == container.repositoryPath {continue}
                let p = path.replacingFirstOccurrence(of: container.repositoryPath.withLastStash(), with: "")
                if p == "" {continue}
                let parts = p.components(separatedBy: "/")
                
                var level = lv - 1
                if lv < 0 {
                    level = parts.count - 1 + lv
                }
                if level < 0 {level = 0}
                if level < parts.count {
                    var join = ""
                    for i in 0...level {
                        join += parts[i]
                        join += "/"
                    }
                    folders.insert(join)
                }
            }
            array = folders.sorted()
        }else{
            var folders:Set<String> = []
            let path = self.getVolumePath(dropdown: self.lstVolumesOfEditableImages, text: self.txtRepository)
            if path != "" {
                let paths = LocalDirectory.bridge.folders(in: path, unlimitedDepth: true)
                for p in paths {
                    let parts = p.components(separatedBy: "/")
                    
                    var level = lv - 1
                    if lv < 0 {
                        level = parts.count - 1 + lv
                    }
                    if level < 0 {level = 0}
                    if level < parts.count {
                        var join = ""
                        for i in 0...level {
                            join += parts[i]
                            join += "/"
                        }
                        folders.insert(join)
                    }
                }
            }
            array = folders.sorted()
        }
        var names:[String] = []
        if array.count > amount {
            for i in 0...(amount-1) {
                let v = array[i]
                names.append(v)
            }
        }else{
            names = array
        }
        if names.count > 0 {
            var mapping:[(String, String)] = []
            for name in names {
                let n = Naming.Image.getBriefFromFolderName(subPath: name, folderLevel: lv)
                mapping.append((n, name))
            }
            self.briefFoldersPreviewPopover.load(mapping)
            self.briefFoldersPreviewPopover.show(sender)
        }
    }
    
    
    // MARK: - ACTION - FIX EVENT
    
    /// - Tag: EditRepositoryViewController.onUpdateEmptyEventClicked()
    @IBAction func onUpdateEmptyEventClicked(_ sender: NSButton) {
        self.lblMessage.stringValue = "Updating images..."
        self.btnUpdateEmptyBrief.isEnabled = false
        self.btnUpdateAllBrief.isEnabled = false
        self.btnUpdateEmptyEvent.isEnabled = false
        self.btnUpdateAllEvents.isEnabled = false
        DispatchQueue.global().async {
            if let container = self.originalContainer {
                let images = ImageSearchDao.default.getImages(repositoryId: container.repositoryId)
                let level = self.lstEventFolderLevel.indexOfSelectedItem + 1
                let total = images.count
                var i = 0
                for image in images {
                    if image.event != nil && image.event != "" {
                        continue
                    }
                    let img = image
                    i += 1
                    img.event = Naming.Image.getEventFromFolderName(image: image, folderLevel: level)
                    let _ = ImageRecordDao.default.saveImage(image: img)
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = "Updating images... (\(i)/\(total))"
                    }
                }
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "Updated (\(i)/\(total)) images."
                    self.btnUpdateEmptyBrief.isEnabled = true
                    self.btnUpdateAllBrief.isEnabled = true
                    self.btnUpdateEmptyEvent.isEnabled = true
                    self.btnUpdateAllEvents.isEnabled = true
                }
            }
        }
    }
    
    /// - Tag: EditRepositoryViewController.onUpdateAllEventsClicked()
    @IBAction func onUpdateAllEventsClicked(_ sender: NSButton) {
        self.lblMessage.stringValue = "Updating images..."
        self.btnUpdateEmptyBrief.isEnabled = false
        self.btnUpdateAllBrief.isEnabled = false
        self.btnUpdateEmptyEvent.isEnabled = false
        self.btnUpdateAllEvents.isEnabled = false
        DispatchQueue.global().async {
            if let container = self.originalContainer {
                let images = ImageSearchDao.default.getImages(repositoryId: container.repositoryId)
                let level = self.lstEventFolderLevel.indexOfSelectedItem + 1
                let total = images.count
                var i = 0
                for image in images {
                    let img = image
                    i += 1
                    img.event = Naming.Image.getEventFromFolderName(image: image, folderLevel: level)
                    let _ = ImageRecordDao.default.saveImage(image: img)
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = "Updating images... (\(i)/\(total))"
                    }
                }
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "Updated (\(i)/\(total)) images."
                    self.btnUpdateEmptyBrief.isEnabled = true
                    self.btnUpdateAllBrief.isEnabled = true
                    self.btnUpdateEmptyEvent.isEnabled = true
                    self.btnUpdateAllEvents.isEnabled = true
                }
            }
        }
    }
    
    /// - Tag: EditRepositoryViewController.onPreviewEventFolders()
    @IBAction func onPreviewEventFolders(_ sender: NSButton) {
        let amount = 50
        let level = self.lstEventFolderLevel.indexOfSelectedItem
        var array:[String] = []
        if let container = self.originalContainer {
            var folders:Set<String> = []
            let paths = RepositoryDao.default.getAllContainerPathsOfImages(repositoryId: container.repositoryId)
            for path in paths {
                if path == container.repositoryPath {continue}
                let p = path.replacingFirstOccurrence(of: container.repositoryPath.withLastStash(), with: "")
                if p == "" {continue}
                let parts = p.components(separatedBy: "/")
                
                if level < parts.count {
                    var join = ""
                    for i in 0...level {
                        join += parts[i]
                        join += "/"
                    }
                    folders.insert(join)
                }
            }
            array = folders.sorted()
        }else{
            var folders:Set<String> = []
            let path = self.getVolumePath(dropdown: self.lstVolumesOfEditableImages, text: self.txtRepository)
            if path != "" {
                let paths = LocalDirectory.bridge.folders(in: path, unlimitedDepth: true)
                for p in paths {
                    let parts = p.components(separatedBy: "/")
                    
                    if level < parts.count {
                        var join = ""
                        for i in 0...level {
                            join += parts[i]
                            join += "/"
                        }
                        folders.insert(join)
                    }
                }
            }
            array = folders.sorted()
        }
        var names:[String] = []
        if array.count > amount {
            for i in 0...(amount-1) {
                let v = array[i]
                names.append(v)
            }
        }else{
            names = array
        }
        if names.count > 0 {
            var mapping:[(String, String)] = []
            for name in names {
                let n = Naming.Image.getEventFromFolderName(subPath: name, folderLevel: level + 1)
                mapping.append((n, name))
            }
            self.eventFoldersPreviewPopover.load(mapping)
            self.eventFoldersPreviewPopover.show(sender)
        }
        
    }
    
    
    
    // MARK: - DEVICE LIST Popover
    
    var devicesPopover:NSPopover?
    var devicesViewController:DeviceListViewController!
    
    fileprivate func createDevicesPopover(){
        var myPopover = self.devicesPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 600, height: 400))
            self.devicesViewController = DeviceListViewController()
            self.devicesViewController.view.frame = frame
            self.devicesViewController.selectionDelegate = self
            
            myPopover!.contentViewController = self.devicesViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.devicesPopover = myPopover
    }
    
    // MARK: - FIND FACES
    
    /// - Tag: EditRepositoryViewController.onFindFacesClicked()
    @IBAction func onFindFacesClicked(_ sender: NSButton) {
//        guard !self.working else {
//            self.logger.log("other task is running. abort this task.")
//            return
//        }
//        if let repository = self.originalContainer {
//
//            if repository.cropPath == "" {
//                self.logger.log("ERROR: Crop path is empty, please assign it first: \(repository.path)")
//                self.lblMessage.stringValue = "ERROR: Crop path is empty, please assign it first"
//                return
//            }
//
//            // ensure base crop path exists
//            var isDir:ObjCBool = false
//            if FileManager.default.fileExists(atPath: repository.cropPath, isDirectory: &isDir) {
//                if !isDir.boolValue {
//                    self.logger.log("ERROR: Crop path of repository is not a directory: \(repository.cropPath)")
//                    self.lblMessage.stringValue = "ERROR: Crop path of repository is not a directory"
//                    return
//                }
//            }
//
//
//            let limitRam = PreferencesController.peakMemory() * 1024
//            self.stopByExceedLimit = false
//
//            self.accumulator = Accumulator(target: 100, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage,
//                                           onCompleted: { data in
//                                                DispatchQueue.main.async {
//                                                    let count = data["count"] ?? 0
//                                                    let total = data["total"] ?? 0
//                                                    let detectedCount = data["detectedCount"] ?? 0
//                                                    self.continousWorkingRemain = total - count
//                                                    var msg = "Total \(total) images. Processed \(count) images. Found \(detectedCount) images with face(s)."
//                                                    if self.stopByExceedLimit {
//                                                        msg += " Stopped since total size exceeds memory limitation \(limitRam) MB"
//                                                        if self.continousWorkingRemain > 0 {
//                                                            msg += ", cleaning memory..."
//                                                        }
//                                                    }
//                                                    self.logger.log(msg)
//                                                    self.working = false
//                                                    self.logger.log(">>> REMAIN \(self.continousWorkingRemain)")
//                                                    if self.continousWorkingRemain <= 0 {
//                                                        self.toggleButtons(true)
//                                                        self.logger.log(">>> DONE")
//                                                        msg = "Total \(total) images. Processed \(count) images. Found \(detectedCount) images with face(s)."
//                                                        self.continousWorking = false
//                                                    }
//
//                                                    self.lblMessage.stringValue = msg
//                                                }
//                                            },
//                                            startupMessage: "Loading images from database ..."
//                                            )
//
//            DispatchQueue.global().async {
//                self.continousWorkingRemain = 1
//                self.continousWorking = true
//                self.continousWorkingAttempt = 0
//
//                let images = ImageSearchDao.default.getImagesWithoutFace(repositoryRoot: repository.path.withStash())
//
//                self.accumulator?.cleanData()
//
//                while(self.continousWorkingRemain > 0){
//                    if !self.working {
//                        self.logger.log(">>> RE-TRIGGER")
//                        self.continousWorkingAttempt += 1
//                        self.logger.log(">>> TRIGGER SCANNER ATTEMPT=\(self.continousWorkingAttempt), REMAIN=\(self.continousWorkingRemain)")
//                        self.scanFaces(from: images, in: repository)
//                    }
//                    self.logger.log(">>> SLEEP, REMAIN \(self.continousWorkingRemain)")
//                    sleep(10)
//                }
//            }
//        }
    }
}

extension EditRepositoryViewController : DeviceListDelegate {
    
    /// - Tag: EditRepositoryViewController.displayDeviceInfo()
    fileprivate func displayDeviceInfo(deviceId: String, updateDB:Bool = false) {
        
        if let device = DeviceDao.default.getDevice(deviceId: deviceId) {
            //self.logger.log("in device id = \(deviceId)")
            //self.logger.log("queried device id = \(device.deviceId)")
            self.lblDeviceId.stringValue = device.deviceId ?? ""
            var name = device.name ?? ""
            if name == "" {
                var model = device.marketName ?? ""
                if model == "" {
                    model = device.model ?? ""
                }
                name = "\(device.manufacture ?? "") \(model)"
            }
            self.lblDeviceName.stringValue = name
            
            self.logger.log("update db? \(updateDB)")
            if updateDB {
                self.logger.log("linking repo with device \(device.deviceId ?? "")")
                self.linkDeviceToRepository(deviceId: device.deviceId ?? "", deviceName: name)
            }
        }else{
            self.lblDeviceId.stringValue = ""
            self.lblDeviceName.stringValue = ""
        }
    }
    
    func selectDevice(deviceId: String) {
        self.displayDeviceInfo(deviceId: deviceId, updateDB: true)
    }
}

extension EditRepositoryViewController : NSPopoverDelegate {
    
}
