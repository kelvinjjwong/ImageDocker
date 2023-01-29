//
//  EditRepositoryViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/30.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class EditRepositoryViewController: NSViewController {
    
    let logger = ConsoleLogger(category: "REPO", subCategory: "CONFIG")
    
    private var originalContainer:ImageContainer? = nil
    
    // MARK: - FIELDS
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
        
        self.setupUIDisplay()
    }
    
    func setupUIDisplay() {
//        self.btnFindFaces.title = Words.findFaces.word()
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
    
    fileprivate func emptyGeneralTextFields() {
            self.txtName.stringValue = ""
            self.lblNameRemark.stringValue = ""
            self.txtHomePath.stringValue = ""
            self.lblHomePathRemark.stringValue = ""
            
            self.lblDeviceId.stringValue = ""
            self.lblDeviceName.stringValue = ""
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
    }
    
    fileprivate func emptyFaceTextFields() {
            self.txtFacePath.stringValue = ""
            self.lblFacePathRemark.stringValue = ""
            self.txtCropPath.stringValue = ""
            self.lblCropPathRemark.stringValue = ""
            self.btnUpdateFaceImages.isHidden = true
            self.btnUpdateCropImages.isHidden = true
    }
    
    fileprivate func freshNew() {
        
        self.emptyGeneralTextFields()
        self.emptyStorageTextFields()
        self.emptyFaceTextFields()
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
    
    func initNew(window:NSWindow, onOK: (() -> Void)? = nil) {
        self.onCompleted = onOK
        self.window = window
        freshNew()
    }
    
    func initEdit(path:String, window:NSWindow, onOK: (() -> Void)? = nil) {
        self.onCompleted = onOK
        self.window = window
        self.emptyGeneralTextFields()
        self.emptyStorageTextFields()
        self.emptyFaceTextFields()
        self.lblMessage.stringValue = ""
        if let container = RepositoryDao.default.getContainer(path: path) {
            self.originalContainer = container
            self.txtName.stringValue = container.name
            self.txtHomePath.stringValue = container.homePath
            self.txtStoragePath.stringValue = container.storagePath
            self.txtRepository.stringValue = container.path
            self.txtFacePath.stringValue = container.facePath
            self.txtCropPath.stringValue = container.cropPath
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
            
            if container.homePath == "" {
                self.btnBrowseHomePath.title = Words.assign.word()
            }else{
                self.btnBrowseHomePath.title = Words.moveTo.word()
            }
            if container.storagePath == "" {
                self.btnBrowseStoragePath.title = Words.assign.word()
            }else{
                self.btnBrowseStoragePath.title = Words.moveTo.word()
            }
            if container.facePath == "" {
                self.btnBrowseFacePath.title = Words.assign.word()
            }else{
                self.btnBrowseFacePath.title = Words.moveTo.word()
            }
            if container.cropPath == "" {
                self.btnBrowseCropPath.title = Words.assign.word()
            }else{
                self.btnBrowseCropPath.title = Words.moveTo.word()
            }
            
            self.stat()
            
            if container.hiddenByRepository {
                self.btnShowHide.title = Words.enableRepository.word()
            }else{
                self.btnShowHide.title = Words.disableRepository.word()
            }
            
            if container.deviceId != "" {
                self.displayDeviceInfo(deviceId: container.deviceId)
            }
            
            self.lstEventFolderLevel.selectItem(at: container.eventFolderLevel - 1)
            self.chkFolderAsEvent.state = container.folderAsEvent ? .on : .off
            self.chkFolderAsBrief.state = container.folderAsBrief ? .on : .off
            
            self.setBriefFolderLevelSelection(container.briefFolderLevel)
            
        }else{
            self.originalContainer = nil
            self.lblMessage.stringValue = "\(Words.cannotFindRepositoryPath.word()) [\(path)]"
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
        var isDir:ObjCBool = false
        var pass = true
        let trimPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if FileManager.default.fileExists(atPath: trimPath, isDirectory: &isDir) { // exist as a file
            if isDir.boolValue == false {
                pass = false
                messageBox.stringValue = "Path is occupied by a file. You need a folder."
            }
        }else{ // not exist
            do {
                try FileManager.default.createDirectory(atPath: trimPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                pass = false
                messageBox.stringValue = "Unable to create directory at \(path)"
                self.logger.log(error)
            }
        }
        return pass
    }
    
    // MARK: - ACTION BUTTON - SAVE / OK
    
    /// - Tag: EditRepositoryViewController.saveNewRepository()
    fileprivate func saveNewRepository() {
        let name = self.txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let homePath = self.txtHomePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let storagePath = self.txtStoragePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let facePath = self.txtFacePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let cropPath = self.txtCropPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let repositoryPath = self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let deviceId = self.lblDeviceId.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if name == "" {
            self.lblNameRemark.stringValue = "Please give me a name."
        }
        if self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
        }
        if self.txtStoragePath.stringValue == "" {
            self.lblStoragePathRemark.stringValue = "Please assign path for storing RAW copies."
        }
        if self.txtRepository.stringValue == "" {
            self.lblRepositoryPathRemark.stringValue = "Please assign path for storing modifies."
        }
        if self.txtFacePath.stringValue == "" {
            self.lblFacePathRemark.stringValue = "Please assign path for storing recognized pictures."
        }
        if self.txtCropPath.stringValue == "" {
            self.lblCropPathRemark.stringValue = "Please assign path for storing faces within pictures."
        }
        guard self.txtName.stringValue != ""
            && self.txtHomePath.stringValue != ""
            && self.txtStoragePath.stringValue != ""
            && self.txtRepository.stringValue != ""
            && self.txtFacePath.stringValue != ""
            && self.txtCropPath.stringValue != ""
            else {return}
        var pass = true
        pass = pass && self.checkDirectory(path: self.txtHomePath.stringValue, messageBox: self.lblHomePathRemark)
        pass = pass && self.checkDirectory(path: self.txtStoragePath.stringValue, messageBox: self.lblStoragePathRemark)
        pass = pass && self.checkDirectory(path: self.txtRepository.stringValue, messageBox: self.lblRepositoryPathRemark)
        pass = pass && self.checkDirectory(path: self.txtFacePath.stringValue, messageBox: self.lblFacePathRemark)
        pass = pass && self.checkDirectory(path: self.txtCropPath.stringValue, messageBox: self.lblCropPathRemark)
        
        guard pass else {return}
        
        
        
        let imagefolder = RepositoryDao.default.createRepository(name: name,
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
    
    /// - Tag: EditRepositoryViewController.onOKClicked()
    @IBAction func onOKClicked(_ sender: Any) {
        
        if let container = self.originalContainer { // edit
            let name = self.txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let homePath = self.txtHomePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if name == "" {
                self.lblNameRemark.stringValue = "Please give me a name."
                return
            }
            if self.txtHomePath.stringValue == "" {
                self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
                return
            }
            var pass = true
            pass = pass && self.checkDirectory(path: self.txtHomePath.stringValue, messageBox: self.lblHomePathRemark)
            guard pass else {return}
            
            let origin = container
            origin.name = name
            origin.homePath = homePath
            origin.folderAsEvent = self.chkFolderAsEvent.state == .on
            origin.eventFolderLevel = (self.lstEventFolderLevel.indexOfSelectedItem + 1)
            origin.folderAsBrief = (self.chkFolderAsBrief.state == .on)
            origin.briefFolderLevel = self.getBriefFolderLevelFromSelection()
            let _ = RepositoryDao.default.saveImageContainer(container: origin)
            self.lblMessage.stringValue = "General info updated."
            
        }else{ // new
            self.saveNewRepository()
            self.lblMessage.stringValue = "Repository created."
        }
        if self.onCompleted != nil {
            self.onCompleted!()
        }
    }
    
    // MARK: - ACTION BUTTON - RESTORE TO ORIGIN
    
    /// - Tag: EditRepositoryViewController.onRestoreOriginalClicked()
    @IBAction func onRestoreOriginalClicked(_ sender: NSButton) {
        if let container = self.originalContainer {
            self.emptyStorageTextFields()
            self.txtName.stringValue = container.name
            self.txtHomePath.stringValue = container.homePath
            self.txtStoragePath.stringValue = container.storagePath
            self.txtRepository.stringValue = container.path
            self.btnRestoreOriginal.isHidden = false
            self.btnCopyToRaw.isHidden = false
        }
    }
    
    /// - Tag: EditRepositoryViewController.onRestoreOriginalFacePathClicked()
    @IBAction func onRestoreOriginalFacePathClicked(_ sender: NSButton) {
        
        if let container = self.originalContainer {
            self.emptyFaceTextFields()
            self.txtFacePath.stringValue = container.facePath
            self.txtCropPath.stringValue = container.cropPath
        }
    }
    
    // MARK: - ACTION BUTTON - FOLLOW HOME PATH
    
    /// - Tag: EditRepositoryViewController.onFollowHomePathClicked()
    @IBAction func onFollowHomePathClicked(_ sender: NSButton) {
        
        if self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
            return
        }
        
        if !self.checkDirectory(path: self.txtHomePath.stringValue, messageBox: self.lblHomePathRemark) {
            return
        }
        
        let home = URL(fileURLWithPath: self.txtHomePath.stringValue)
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
        
        self.txtRepository.stringValue = repository.path
        self.txtStoragePath.stringValue = storage.path
    }
    
    /// - Tag: EditRepositoryViewController.onFacePathFollowHomeClicked()
    @IBAction func onFacePathFollowHomeClicked(_ sender: NSButton) {
        
        if self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
            return
        }
        
        if !self.checkDirectory(path: self.txtHomePath.stringValue, messageBox: self.lblHomePathRemark) {
            return
        }
        let home = URL(fileURLWithPath: self.txtHomePath.stringValue)
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
        self.txtFacePath.stringValue = face.path
        self.txtCropPath.stringValue = crop.path
    }
    
    // MARK: - ACTION BUTTON - COPY IMAGES FROM EDITABLE TO RAW STORAGE
    
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
            var isDir:ObjCBool = false
            if !FileManager.default.fileExists(atPath: container.repositoryPath, isDirectory: &isDir) {
                self.lblMessage.stringValue = "ERROR: Path for storing editable images doesn't exist. Please re-assign it and save first."
                return
            }else if isDir.boolValue == false {
                self.lblMessage.stringValue = "ERROR: Path for storing editable images must be a directory. Please re-assign it and save first."
                return
            }
            if !FileManager.default.fileExists(atPath: container.storagePath, isDirectory: &isDir) {
                self.lblMessage.stringValue = "ERROR: Path for storing raw images doesn't exist. Please re-assign it and save first."
                return
            }else if isDir.boolValue == false {
                self.lblMessage.stringValue = "ERROR: Path for storing raw images must be a directory. Please re-assign it and save first."
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
                let images = ImageSearchDao.default.getImages(repositoryPath: container.repositoryPath)
                
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
                        let sourcePath = image.path
                        let targetPath = "\(container.storagePath.withLastStash())\(image.subPath)"
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
    
    // MARK: - ACTION BUTTON - OPEN DIALOG
    
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
                    self.txtHomePath.stringValue = url.path
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
                    self.txtStoragePath.stringValue = url.path
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
                    self.txtRepository.stringValue = url.path
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
                    self.txtFacePath.stringValue = url.path
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
                    self.txtCropPath.stringValue = url.path
                }
            }
        }
    }
    
    // MARK: - ACTION BUTTON - VIEW IN FINDER
    
    /// - Tag: EditRepositoryViewController.onFindHomePath()
    @IBAction func onFindHomePath(_ sender: NSButton) {
        if self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
            return
        }
        
        if !self.checkDirectory(path: self.txtHomePath.stringValue, messageBox: self.lblHomePathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: self.txtHomePath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// - Tag: EditRepositoryViewController.onFindStoragePathClicked()
    @IBAction func onFindStoragePathClicked(_ sender: NSButton) {
        if self.txtStoragePath.stringValue == "" {
            self.lblStoragePathRemark.stringValue = "Please assign path for storing RAW copies."
            return
        }
        
        if !self.checkDirectory(path: self.txtStoragePath.stringValue, messageBox: self.lblStoragePathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: self.txtStoragePath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// - Tag: EditRepositoryViewController.onFindRepositoryPathClicked()
    @IBAction func onFindRepositoryPathClicked(_ sender: NSButton) {
        if self.txtRepository.stringValue == "" {
            self.lblRepositoryPathRemark.stringValue = "Please assign path for storing modifies."
            return
        }
        
        if !self.checkDirectory(path: self.txtRepository.stringValue, messageBox: self.lblRepositoryPathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: self.txtRepository.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// - Tag: EditRepositoryViewController.onFindFaceRepositoryPathClicked()
    @IBAction func onFindFaceRepositoryPathClicked(_ sender: NSButton) {
        if self.txtFacePath.stringValue == "" {
            self.lblFacePathRemark.stringValue = "Please assign path for storing recognized pictures."
            return
        }
        
        if !self.checkDirectory(path: self.txtFacePath.stringValue, messageBox: self.lblFacePathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: self.txtFacePath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    /// - Tag: EditRepositoryViewController.onFindCropPath()
    @IBAction func onFindCropPath(_ sender: NSButton) {
        if self.txtCropPath.stringValue == "" {
            self.lblCropPathRemark.stringValue = "Please assign path for storing faces within pictures."
            return
        }
        
        if !self.checkDirectory(path: self.txtCropPath.stringValue, messageBox: self.lblCropPathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: self.txtCropPath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    // MARK: - ACTION BUTTON - UPDATE IMAGES
    
    /// - Tag: EditRepositoryViewController.onUpdateStorageImagesClicked()
    @IBAction func onUpdateStorageImagesClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            let originalRawPath = repoContainer.storagePath.withLastStash()
            let newRawPath = self.txtStoragePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withLastStash()
            
            if newRawPath == "/" {
                self.lblStoragePathRemark.stringValue = "Path for RAW copy is empty."
                return
            }
            if newRawPath == originalRawPath {
                self.lblStoragePathRemark.stringValue = "Path for RAW copy has no change."
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
                        let oldFiles = oldBaseUrl.walkthruDirectory()
                        
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
                
                // TODO: should be demised in future to improve performance
                let _ = ImageRecordDao.default.updateImageRawBase(pathStartsWith: originalRawPath, rawPath: newRawPath)
                
                let _ = ImageRecordDao.default.updateImageRawBase(oldRawPath: originalRawPath, newRawPath: newRawPath)
                
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
    
    /// - Tag: EditRepositoryViewController.onUpdateRepositoryImagesClicked()
    @IBAction func onUpdateRepositoryImagesClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            
            let originalRepoPath = repoContainer.path.withLastStash()
            let newRepoPathNoStash = self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let newRepoPath = self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withLastStash()
            
            if newRepoPath == "/" || newRepoPath == "" {
                return
            }
            
            var go = false
            
            self.lblMessage.stringValue = "Checking for update ..."
            
            if newRepoPath == originalRepoPath {
                let imagesWithoutRepoPath = ImageCountDao.default.countImageWithoutRepositoryPath(repositoryRoot: originalRepoPath)
                let imagesWithoutSubPath = ImageCountDao.default.countImageWithoutSubPath(repositoryRoot: originalRepoPath)
                let imagesWithoutId = ImageCountDao.default.countImageWithoutId(repositoryRoot: originalRepoPath)
                let imagesUnmatchedRepoPath = ImageCountDao.default.countImageUnmatchedRepositoryRoot(repositoryRoot: originalRepoPath)
                
                let containersWithoutRepoPath = ImageCountDao.default.countContainersWithoutRepositoryPath(repositoryRoot: originalRepoPath)
                let containersWithoutSubPath = ImageCountDao.default.countContainersWithoutSubPath(repositoryRoot: originalRepoPath)
                
                logger.log("No-repo:\(imagesWithoutRepoPath) No-sub:\(imagesWithoutSubPath) No-id:\(imagesWithoutId) Unmatch-repo:\(imagesUnmatchedRepoPath) container-no-repo:\(containersWithoutRepoPath) container-no-sub:\(containersWithoutSubPath)")
                logger.log("continue if one of above larger than zero")
                
                if imagesWithoutRepoPath > 0 || imagesWithoutSubPath > 0 || imagesWithoutId > 0 || imagesUnmatchedRepoPath > 0 || containersWithoutRepoPath > 0 ||  containersWithoutSubPath > 0 {
                    go = true
                }
                if imagesWithoutRepoPath == 0 && imagesWithoutSubPath == 0 && imagesWithoutId == 0 && imagesUnmatchedRepoPath == 0 && containersWithoutRepoPath == 0 &&  containersWithoutSubPath == 0 {
                    go = true
                }
            }else{
                // change place
                logger.log("repo changed place")
                go = true
            }
            guard go else {
                self.lblMessage.stringValue = ""
                logger.log("abort")
                return
            }
            
            self.working = true
            
            
            self.toggleButtons(false)
            self.lblMessage.stringValue = "Loading editable image files ..."
            
            DispatchQueue.global().async {
            
                // save images' path, save images' repository path to new repository path (base path)
                let images = ImageSearchDao.default.getPhotoFiles(rootPath: originalRepoPath)
                
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
                        let id = image.id ?? UUID().uuidString
                        
                        let _ = ImageRecordDao.default.updateImagePaths(oldPath: oldPath, newPath: newPath, repositoryPath: newRepoPath, subPath: subPath, containerPath: containerPath, id: id)
                    }
                }
                
                // save sub-containers' path
                
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "Loading sub-folders ..."
                }
                
                let subContainers = RepositoryDao.default.getContainers(rootPath: originalRepoPath)
                
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
                    sub.parentFolder = sub.parentFolder.replacingFirstOccurrence(of: repoContainer.path, with: newRepoPathNoStash) // without stash
                    sub.path = sub.path.replacingFirstOccurrence(of: originalRepoPath, with: newRepoPath)
                    let _ = RepositoryDao.default.updateImageContainerPaths(oldPath: oldPath, newPath: sub.path, repositoryPath: sub.repositoryPath, parentFolder: sub.parentFolder, subPath: sub.subPath)
                }
                
                // save repo's path
                let repo = repoContainer
                let oldPath = repo.path
                let newPath = newRepoPathNoStash
                repo.repositoryPath = newRepoPath
                let _ = RepositoryDao.default.updateImageContainerRepositoryPaths(oldPath: oldPath, newPath: newPath, repositoryPath: newRepoPath)
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    self.initEdit(path: newPath, window: self.window!) // reload repository data to form
                    
                    self.toggleButtons(true)
                    //self.lblMessage.stringValue = "Repository updated."
                    
                    self.stat()
                    
                    self.working = false
                }
                
            }
            
        }
    }
    
    /// - Tag: EditRepositoryViewController.onUpdateFaceImagesClicked()
    @IBAction func onUpdateFaceImagesClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            let originalFacePath = repoContainer.facePath.withLastStash()
            let newFacePath = self.txtFacePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withLastStash()
            
            if newFacePath == "/" || newFacePath == originalFacePath {
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
        // TODO: DEMISE
       
    }
    
    
    /// - Tag: EditRepositoryViewController.onNormalizeHiddenClicked()
    @IBAction func onNormalizeHiddenClicked(_ sender: NSButton) {
        let repo = self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withLastStash()
        let raw = self.txtStoragePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withLastStash()
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
            
            let duplicates = ImageDuplicationDao.default.getDuplicatedImages(repositoryRoot: repo, theOtherRepositoryRoot: raw)
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
    
    // MARK: - ACTION BUTTON - DELETE RECORDS
    
    /// - Tag: EditRepositoryViewController.onRemoveClicked()
    @IBAction func onRemoveClicked(_ sender: NSButton) {
        if let container = self.originalContainer {
            if Alert.dialogOKCancel(question: "Remove all records and image-records of this repository from database ?", text: container.path) {
                
                self.toggleButtons(false)
                DispatchQueue.global().async {
                    let _ = RepositoryDao.default.deleteRepository(repositoryRoot: container.path)
                    
                    DispatchQueue.main.async {
                        
                        self.freshNew()
                        
                        self.toggleButtons(true)
                        self.lblMessage.stringValue = "All records and image-records of this repository have been removed from database."
                        
                    }
                }
            }
        }
    }
    
    // MARK: - ACTION BUTTON - DEVICE INFO AREA
    
    /// - Tag: EditRepositoryViewController.onLoadDevicesClicked()
    @IBAction func onLoadDevicesClicked(_ sender: NSButton) {
        self.createDevicesPopover()
        self.devicesViewController.initView()
        
        let cellRect = sender.bounds
        self.devicesPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    /// - Tag: EditRepositoryViewController.onCompareDevicePathClicked()
    @IBAction func onCompareDevicePathClicked(_ sender: NSButton) {
        let deviceId = self.lblDeviceId.stringValue
        if deviceId != "" {
            if let device = DeviceDao.default.getDevice(deviceId: deviceId) {
                let homePath = device.homePath ?? ""
                let repoPath = device.repositoryPath ?? ""
                let rawPath = device.storagePath ?? ""
                if self.txtHomePath.stringValue != homePath {
                    self.lblHomePathRemark.stringValue = "Different w/ device: [\(homePath)]"
                }
                if self.txtRepository.stringValue != repoPath {
                    self.lblRepositoryPathRemark.stringValue = "Different w/ device: [\(repoPath)]"
                }
                if self.txtStoragePath.stringValue != rawPath {
                    self.lblStoragePathRemark.stringValue = "Different w/ device: [\(rawPath)]"
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
        if let container = self.originalContainer {
            let repo = container
            repo.deviceId = deviceId
            let state = RepositoryDao.default.saveImageContainer(container: repo)
            if state != .OK {
                self.lblMessage.stringValue = "\(state) - Unable to link repository with device in database."
            }else{
                self.lblMessage.stringValue = "\(state) - Updated link between repository and device [\(deviceId) - \(deviceName)]."
            }
        }
    }
    
    // MARK: - ACTION BUTTON - SHOW HIDE IMAGES
    
    /// - Tag: EditRepositoryViewController.onShowHideClicked()
    @IBAction func onShowHideClicked(_ sender: NSButton) {
        if let container = self.originalContainer {
            if container.hiddenByRepository {
                DispatchQueue.global().async {
                    let _ = RepositoryDao.default.showRepository(repositoryRoot: container.path.withLastStash())
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
                    let _ = RepositoryDao.default.hideRepository(repositoryRoot: container.path.withLastStash())
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
    
    /// - Tag: EditRepositoryViewController.onFollowDevicePathsClicked()
    @IBAction func onFollowDevicePathsClicked(_ sender: NSButton) {
        let deviceId = self.lblDeviceId.stringValue
        if deviceId != "" {
            if let device = DeviceDao.default.getDevice(deviceId: deviceId) {
                self.txtHomePath.stringValue = device.homePath ?? ""
                self.txtRepository.stringValue = device.repositoryPath ?? ""
                self.txtStoragePath.stringValue = device.storagePath ?? ""
            }
        }
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
    
    fileprivate var stopByExceedLimit = false
    fileprivate var continousWorking = false
    fileprivate var continousWorkingAttempt = 0
    fileprivate var continousWorkingRemain = 0
    
    /// - Tag: EditRepositoryViewController.onUpdateEmptyBriefClicked()
    @IBAction func onUpdateEmptyBriefClicked(_ sender: NSButton) {
        self.lblMessage.stringValue = "Updating images..."
        self.btnUpdateEmptyBrief.isEnabled = false
        self.btnUpdateAllBrief.isEnabled = false
        self.btnUpdateEmptyEvent.isEnabled = false
        self.btnUpdateAllEvents.isEnabled = false
        DispatchQueue.global().async {
            if let container = self.originalContainer {
                let images = ImageSearchDao.default.getImages(repositoryPath: container.repositoryPath)
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
                let images = ImageSearchDao.default.getImages(repositoryPath: container.repositoryPath)
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
            let paths = RepositoryDao.default.getAllContainerPathsOfImages(rootPath: container.repositoryPath)
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
            let path = self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    
    // MARK: - UPDATE EVENT
    
    /// - Tag: EditRepositoryViewController.onUpdateEmptyEventClicked()
    @IBAction func onUpdateEmptyEventClicked(_ sender: NSButton) {
        self.lblMessage.stringValue = "Updating images..."
        self.btnUpdateEmptyBrief.isEnabled = false
        self.btnUpdateAllBrief.isEnabled = false
        self.btnUpdateEmptyEvent.isEnabled = false
        self.btnUpdateAllEvents.isEnabled = false
        DispatchQueue.global().async {
            if let container = self.originalContainer {
                let images = ImageSearchDao.default.getImages(repositoryPath: container.repositoryPath)
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
                let images = ImageSearchDao.default.getImages(repositoryPath: container.repositoryPath)
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
            let paths = RepositoryDao.default.getAllContainerPathsOfImages(rootPath: container.repositoryPath)
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
            let path = self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    
    
    // MARK: - DEVICES LIST Popover
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
