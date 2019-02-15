//
//  EditRepositoryViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/30.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class EditRepositoryViewController: NSViewController {
    
    private var originalContainer:ImageContainer? = nil
    
    // MARK: FIELDS
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
    
    
    private var accumulator:Accumulator? = nil
    
    private var working = false
    
    // MARK: INIT
    
    init(){
        super.init(nibName: NSNib.Name(rawValue: "EditRepositoryViewController"), bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private var window:NSWindow? = nil
    
    // MARK: ACTIONS
    
    fileprivate var onCompleted: (() -> Void)?
    
    // MARK: INIT
    
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
        self.btnOK.title = "Save"
        self.lblMessage.stringValue = ""
        if let window = self.window {
            window.title = "Add Repository"
        }
        self.btnBrowseHomePath.title = "Assign"
        self.btnBrowseStoragePath.title = "Assign"
        self.btnBrowseRepositoryPath.title = "Assign"
        self.btnBrowseFacePath.title = "Assign"
        self.btnBrowseCropPath.title = "Assign"
        self.btnRestoreOriginal.isHidden = true
        self.btnCopyToRaw.isHidden = true
        self.btnUpdateStorageImages.isHidden = true
        self.btnUpdateRepositoryImages.isHidden = true
        self.btnUpdateFaceImages.isHidden = true
        self.btnUpdateCropImages.isHidden = true
        self.btnRemove.isHidden = true
        
        self.lblDeviceId.stringValue = ""
        self.lblDeviceName.stringValue = ""
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
        if let container = ModelStore.default.getContainer(path: path) {
            self.originalContainer = container
            self.txtName.stringValue = container.name
            self.txtHomePath.stringValue = container.homePath
            self.txtStoragePath.stringValue = container.storagePath
            self.txtRepository.stringValue = container.path
            self.txtFacePath.stringValue = container.facePath
            self.txtCropPath.stringValue = container.cropPath
            self.btnRestoreOriginal.isHidden = false
            self.btnCopyToRaw.isHidden = false
            self.btnUpdateStorageImages.isHidden = false
            self.btnUpdateRepositoryImages.isHidden = false
            self.btnUpdateFaceImages.isHidden = false
            self.btnUpdateCropImages.isHidden = false
            self.btnRemove.isHidden = false
            self.btnOK.title = "Update Name & Home"
            window.title = "Edit Repository"
            
            self.btnBrowseRepositoryPath.title = "Move..."
            
            if container.homePath == "" {
                self.btnBrowseHomePath.title = "Assign"
            }else{
                self.btnBrowseHomePath.title = "Move..."
            }
            if container.storagePath == "" {
                self.btnBrowseStoragePath.title = "Assign"
            }else{
                self.btnBrowseStoragePath.title = "Move..."
            }
            if container.facePath == "" {
                self.btnBrowseFacePath.title = "Assign"
            }else{
                self.btnBrowseFacePath.title = "Move..."
            }
            if container.cropPath == "" {
                self.btnBrowseCropPath.title = "Assign"
            }else{
                self.btnBrowseCropPath.title = "Move..."
            }
            
            self.stat()
            
            if container.hiddenByRepository {
                self.btnShowHide.title = "Enable Repository"
            }else{
                self.btnShowHide.title = "Disable Repository"
            }
            
            if container.deviceId != "" {
                self.displayDeviceInfo(deviceId: container.deviceId)
            }
            
        }else{
            self.originalContainer = nil
            self.lblMessage.stringValue = "ERROR: Cannot find repository with path [\(path)]"
        }
    }
    
    // MARK: STATISTIC
    
    fileprivate func stat() {
        if let container = self.originalContainer {
            let path = container.path
            
            DispatchQueue.global().async {
                let imagesTotal = ModelStore.default.countImages(repositoryRoot: path)
                let imagesWithoutRepoPath = ModelStore.default.countImageWithoutRepositoryPath(repositoryRoot: path)
                let imagesWithoutSubPath = ModelStore.default.countImageWithoutSubPath(repositoryRoot: path)
                let imagesWithoutId = ModelStore.default.countImageWithoutId(repositoryRoot: path)
                let imagesUnmatchedRepoPath = ModelStore.default.countImageUnmatchedRepositoryRoot(repositoryRoot: path)
                let containersWithoutRepoPath = ModelStore.default.countContainersWithoutRepositoryPath(repositoryRoot: path)
                let containersWithoutSubPath = ModelStore.default.countContainersWithoutSubPath(repositoryRoot: path)
                
                let msg = "Hidden:\(container.hiddenByRepository), Total:\(imagesTotal), No-repo:\(imagesWithoutRepoPath), No-sub:\(imagesWithoutSubPath), No-id:\(imagesWithoutId), Unmatch-repo:\(imagesUnmatchedRepoPath), container-no-repo:\(containersWithoutRepoPath), container-no-sub:\(containersWithoutSubPath)"
                
                print(msg)
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = msg
                }
            }
        }
    }
    
    @IBAction func onStatClicked(_ sender: NSButton) {
        self.stat()
    }
    
    
    // MARK: HELPER
    
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
                print(error)
            }
        }
        return pass
    }
    
    // MARK: ACTION BUTTON - SAVE / OK
    
    fileprivate func saveNewRepository() {
        let name = self.txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let homePath = self.txtHomePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let storagePath = self.txtStoragePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let facePath = self.txtFacePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let cropPath = self.txtCropPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let repositoryPath = self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
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
        
        ImageFolderTreeScanner.createRepository(name: name,
                                                path: repositoryPath,
                                                homePath: homePath,
                                                storagePath: storagePath,
                                                facePath: facePath,
                                                cropPath: cropPath)
    }
    
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
            
            var origin = container
            origin.name = name
            origin.homePath = homePath
            ModelStore.default.saveImageContainer(container: origin)
            self.lblMessage.stringValue = "General info updated."
            
        }else{ // new
            self.saveNewRepository()
            self.lblMessage.stringValue = "Repository created."
        }
        if self.onCompleted != nil {
            self.onCompleted!()
        }
    }
    
    // MARK: ACTION BUTTON - RESTORE TO ORIGIN
    
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
    
    @IBAction func onRestoreOriginalFacePathClicked(_ sender: NSButton) {
        
        if let container = self.originalContainer {
            self.emptyFaceTextFields()
            self.txtFacePath.stringValue = container.facePath
            self.txtCropPath.stringValue = container.cropPath
        }
    }
    
    // MARK: ACTION BUTTON - FOLLOW HOME PATH
    
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
    
    // MARK: ACTION BUTTON - COPY IMAGES FROM EDITABLE TO RAW STORAGE
    
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
            // TODO: disable buttons
            
            var count = 0
            var copiedCount = 0
            var abnormalCount = 0
            var errorCount = 0
            DispatchQueue.main.async {
                self.accumulator = Accumulator(target: 100, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage,
                                               onCompleted: { data in
                                                self.lblMessage.stringValue = "Total \(count) images, copied \(copiedCount) images, \(errorCount) images occured error, \(abnormalCount) images ignored (no-sub-path) "
                                                self.working = false
                                                // TODO: enable buttons
                                               },
                                               startupMessage: "Loading images from database ..."
                                              )
            }
            
            DispatchQueue.global().async {
                let images = ModelStore.default.getImages(repositoryPath: container.repositoryPath)
                
                if images.count == 0 {
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = "No image could be copied. Please update image-records in the repository if they really exist."
                        self.working = false
                        // TODO: enable buttons
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
                        let targetPath = "\(container.storagePath.withStash())\(image.subPath)"
                        if FileManager.default.fileExists(atPath: sourcePath) && !FileManager.default.fileExists(atPath: targetPath) {
                            let containerUrl = URL(fileURLWithPath: targetPath).deletingLastPathComponent()
                            
                            do {
                                try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                            }catch{
                                print(error)
                            }
                            do { // copy file
                                try FileManager.default.copyItem(atPath: sourcePath, toPath: targetPath)
                                copiedCount += 1
                            }catch{
                                print(error)
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
    
    // MARK: ACTION BUTTON - OPEN DIALOG
    
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
    
    // MARK: ACTION BUTTON - VIEW IN FINDER
    
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
    
    // MARK: ACTION BUTTON - UPDATE IMAGES
    
    @IBAction func onUpdateStorageImagesClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            let originalRawPath = repoContainer.storagePath.withStash()
            let newRawPath = self.txtStoragePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withStash()
            
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
            
            self.btnUpdateStorageImages.isEnabled = false
            self.btnUpdateRepositoryImages.isEnabled = false
            self.btnUpdateFaceImages.isEnabled = false
            self.btnUpdateCropImages.isEnabled = false
            self.btnCopyToRaw.isEnabled = false
            self.lblMessage.stringValue = ""
            
            DispatchQueue.global().async {
            
                if originalRawPath != "/" && originalRawPath != "" { // clone from original RAW path
                    let oldBaseUrl = URL(fileURLWithPath: originalRawPath)
                    let newBaseUrl = URL(fileURLWithPath: newRawPath)
                    let oldFullUrl = oldBaseUrl.resolvingSymlinksInPath()
                    let newFullUrl = newBaseUrl.resolvingSymlinksInPath()
                    if newFullUrl.path != oldFullUrl.path { // physically inequal, need copy files
                        let oldFiles = ImageFolderTreeScanner.default.walkthruDirectory(at: oldBaseUrl)
                        
                        let total = oldFiles.allObjects.count
                        
                        DispatchQueue.main.async {
                            self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                        }
                        
                        for case let oldUrl as URL in oldFiles {
                            let newFilePath = oldUrl.path.replacingFirstOccurrence(of: oldBaseUrl.path.withStash(), with: newBaseUrl.path.withStash())
                            let newUrl = URL(fileURLWithPath: newFilePath)
                            let containerUrl = newUrl.deletingLastPathComponent()
                            if !FileManager.default.fileExists(atPath: newFilePath) { // no folder, create folder
                                do {
                                    try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                                }catch{
                                    print(error)
                                }
                                do { // copy file
                                    try FileManager.default.copyItem(at: oldUrl, to: newUrl)
                                }catch{
                                    print(error)
                                }
                            }
                            
                            
                            DispatchQueue.main.async {
                                let _ = self.accumulator?.add("Updating RAW images ...")
                            }
                        }
                    }
                }
                
                // TODO: should be demised in future to improve performance
                ModelStore.default.updateImageRawBase(pathStartsWith: originalRawPath, rawPath: newRawPath)
                
                ModelStore.default.updateImageRawBase(oldRawPath: originalRawPath, newRawPath: newRawPath)
                
                // save repo's path
                var repo = repoContainer
                repo.storagePath = newRawPath
                ModelStore.default.saveImageContainer(container: repo)
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    self.btnUpdateStorageImages.isEnabled = true
                    self.btnUpdateRepositoryImages.isEnabled = true
                    self.btnUpdateFaceImages.isEnabled = true
                    self.btnUpdateCropImages.isEnabled = true
                    self.btnCopyToRaw.isEnabled = true
                    self.lblMessage.stringValue = "RAW storage updated."
                    
                    self.working = false
                }
                
            }
            
        }
    }
    
    @IBAction func onUpdateRepositoryImagesClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            
            let originalRepoPath = repoContainer.path.withStash()
            let newRepoPath = self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withStash()
            
            if newRepoPath == "/" || newRepoPath == "" {
                return
            }
            
            var go = false
            
            self.lblMessage.stringValue = "Checking for update ..."
            
            if newRepoPath == originalRepoPath {
                let imagesWithoutRepoPath = ModelStore.default.countImageWithoutRepositoryPath(repositoryRoot: originalRepoPath)
                let imagesWithoutSubPath = ModelStore.default.countImageWithoutSubPath(repositoryRoot: originalRepoPath)
                let imagesWithoutId = ModelStore.default.countImageWithoutId(repositoryRoot: originalRepoPath)
                let imagesUnmatchedRepoPath = ModelStore.default.countImageUnmatchedRepositoryRoot(repositoryRoot: originalRepoPath)
                
                let containersWithoutRepoPath = ModelStore.default.countContainersWithoutRepositoryPath(repositoryRoot: originalRepoPath)
                let containersWithoutSubPath = ModelStore.default.countContainersWithoutSubPath(repositoryRoot: originalRepoPath)
                
                if imagesWithoutRepoPath > 0 || imagesWithoutSubPath > 0 || imagesWithoutId > 0 || imagesUnmatchedRepoPath > 0 || containersWithoutRepoPath > 0 ||  containersWithoutSubPath > 0 {
                    go = true
                }
            }
            guard go else {
                self.lblMessage.stringValue = ""
                return
            }
            
            self.working = true
            
            self.btnUpdateStorageImages.isEnabled = false
            self.btnUpdateRepositoryImages.isEnabled = false
            self.btnUpdateFaceImages.isEnabled = false
            self.btnUpdateCropImages.isEnabled = false
            self.btnCopyToRaw.isEnabled = false
            self.lblMessage.stringValue = ""
            
            DispatchQueue.global().async {
            
                // save images' path, save images' repository path to new repository path (base path)
                let images = ModelStore.default.getPhotoFiles(rootPath: originalRepoPath)
                
                if images.count > 0 {
                    
                    let total = images.count
                    
                    DispatchQueue.main.async {
                        self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                    }
                    
                    for image in images {
                        
                        DispatchQueue.main.async {
                            let _ = self.accumulator?.add("Updating editable image files ...")
                        }
                        
                        var img = image
                        
                        // fix unmatched repository path: fix physically inequal
                        let newPath = image.path.replacingFirstOccurrence(of: originalRepoPath, with: newRepoPath)
                        let containerUrl = URL(fileURLWithPath: newPath).deletingLastPathComponent()
                        
                        let newUrl = URL(fileURLWithPath: newPath).resolvingSymlinksInPath()
                        let oldUrl = URL(fileURLWithPath: image.path).resolvingSymlinksInPath()
                        
                        if newUrl.path != oldUrl.path { // physically inequal
                            if !FileManager.default.fileExists(atPath: newUrl.path) { // no folder, create folder
                                do {
                                    try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                                }catch{
                                    print(error)
                                }
                                do { // copy file
                                    try FileManager.default.copyItem(at: oldUrl, to: newUrl)
                                }catch{
                                    print(error)
                                }
                            }
                        }
                        
                        // fix empty repository path
                        img.repositoryPath = newRepoPath
                        img.containerPath = containerUrl.path
                        
                        // fix empty sub path
                        img.subPath = img.path.replacingFirstOccurrence(of: originalRepoPath, with: "")
                        
                        // fix unmatched repository path: fix logically inequal
                        img.path = newPath
                        
                        // fix empty id
                        if img.id == nil {
                            img.id = UUID().uuidString
                        }
                        ModelStore.default.saveImage(image: img)
                    }
                }
                
                // save sub-containers' path
                
                let subContainers = ModelStore.default.getContainers(rootPath: originalRepoPath)
                
                let total = subContainers.count
                
                DispatchQueue.main.async {
                    self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                }
                
                for subContainer in subContainers {
                    
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("Updating sub-containers ...")
                    }
                    
                    var sub = subContainer
                    if sub.subPath == "" {
                        sub.subPath = sub.path.replacingFirstOccurrence(of: originalRepoPath, with: "")
                    }
                    if sub.parentPath == "" {
                        sub.parentPath = URL(fileURLWithPath: sub.path).deletingLastPathComponent().path.replacingFirstOccurrence(of: originalRepoPath, with: "")
                    }
                    sub.repositoryPath = newRepoPath
                    sub.parentFolder = sub.parentFolder.replacingFirstOccurrence(of: originalRepoPath, with: newRepoPath)
                    sub.path = sub.path.replacingFirstOccurrence(of: originalRepoPath, with: newRepoPath)
                    ModelStore.default.saveImageContainer(container: sub)
                }
                
                // save repo's path
                var repo = repoContainer
                repo.repositoryPath = newRepoPath
                ModelStore.default.saveImageContainer(container: repo)
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    self.btnUpdateStorageImages.isEnabled = true
                    self.btnUpdateRepositoryImages.isEnabled = true
                    self.btnUpdateFaceImages.isEnabled = true
                    self.btnUpdateCropImages.isEnabled = true
                    self.btnCopyToRaw.isEnabled = true
                    //self.lblMessage.stringValue = "Repository updated."
                    
                    self.stat()
                    
                    self.working = false
                }
                
            }
            
        }
    }
    
    @IBAction func onUpdateFaceImagesClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            let originalFacePath = repoContainer.facePath.withStash()
            let newFacePath = self.txtFacePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withStash()
            
            if newFacePath == "/" || newFacePath == originalFacePath {
                return
            }
            
            self.working = true
            
            self.btnUpdateStorageImages.isEnabled = false
            self.btnUpdateRepositoryImages.isEnabled = false
            self.btnUpdateFaceImages.isEnabled = false
            self.btnUpdateCropImages.isEnabled = false
            self.btnCopyToRaw.isEnabled = false
            self.lblMessage.stringValue = ""
            
            DispatchQueue.global().async {
            
                if originalFacePath != "/" { // clone from original FACE path
                    let oldBaseUrl = URL(fileURLWithPath: originalFacePath)
                    let newBaseUrl = URL(fileURLWithPath: newFacePath)
                    let oldFullUrl = oldBaseUrl.resolvingSymlinksInPath()
                    let newFullUrl = newBaseUrl.resolvingSymlinksInPath()
                    
                    // copy physical files
                    if newFullUrl.path != oldFullUrl.path { // physically inequal, need copy files
                        let oldFiles = ImageFolderTreeScanner.default.walkthruDirectory(at: oldBaseUrl)
                        
                        let total = oldFiles.allObjects.count
                        
                        DispatchQueue.main.async {
                            self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                        }
                        
                        for case let oldUrl as URL in oldFiles {
                            
                            DispatchQueue.main.async {
                                let _ = self.accumulator?.add("Copying face file ...")
                            }
                            
                            let newFilePath = oldUrl.path.replacingFirstOccurrence(of: oldBaseUrl.path.withStash(), with: newBaseUrl.path.withStash())
                            let newUrl = URL(fileURLWithPath: newFilePath)
                            let containerUrl = newUrl.deletingLastPathComponent()
                            if !FileManager.default.fileExists(atPath: newFilePath) { // no folder, create folder
                                do {
                                    try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                                }catch{
                                    print(error)
                                }
                                do { // copy file
                                    try FileManager.default.copyItem(at: oldUrl, to: newUrl)
                                }catch{
                                    print(error)
                                }
                            }
                        }
                    }
                }
                
                // TODO: update face-image records
                
                
                // save repo's path
                var repo = repoContainer
                repo.facePath = newFacePath
                ModelStore.default.saveImageContainer(container: repo)
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    self.btnUpdateStorageImages.isEnabled = true
                    self.btnUpdateRepositoryImages.isEnabled = true
                    self.btnUpdateFaceImages.isEnabled = true
                    self.btnUpdateCropImages.isEnabled = true
                    self.btnCopyToRaw.isEnabled = true
                    self.lblMessage.stringValue = "Face files updated."
                    
                    self.working = false
                }
                
            }
            
        }
    }
    
    @IBAction func onUpdateCropImagesClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            let originalCropPath = repoContainer.cropPath.withStash()
            let newCropPath = self.txtCropPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withStash()
            
            if newCropPath == "/" || newCropPath == originalCropPath {
                return
            }
            
            self.working = true
            
            self.btnUpdateStorageImages.isEnabled = false
            self.btnUpdateRepositoryImages.isEnabled = false
            self.btnUpdateFaceImages.isEnabled = false
            self.btnUpdateCropImages.isEnabled = false
            self.btnCopyToRaw.isEnabled = false
            self.lblMessage.stringValue = ""
            
            DispatchQueue.global().async {
            
                if originalCropPath != "/" { // clone from original CROP path
                    let oldBaseUrl = URL(fileURLWithPath: originalCropPath)
                    let newBaseUrl = URL(fileURLWithPath: newCropPath)
                    let oldFullUrl = oldBaseUrl.resolvingSymlinksInPath()
                    let newFullUrl = newBaseUrl.resolvingSymlinksInPath()
                    
                    // copy physical files
                    if newFullUrl.path != oldFullUrl.path { // physically inequal, need copy files
                        let oldFiles = ImageFolderTreeScanner.default.walkthruDirectory(at: oldBaseUrl)
                        
                        let total = oldFiles.allObjects.count
                        
                        DispatchQueue.main.async {
                            self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                        }
                        
                        for case let oldUrl as URL in oldFiles {
                            DispatchQueue.main.async {
                                let _ = self.accumulator?.add("Copying crop file ...")
                            }
                            
                            let newFilePath = oldUrl.path.replacingFirstOccurrence(of: oldBaseUrl.path.withStash(), with: newBaseUrl.path.withStash())
                            let newUrl = URL(fileURLWithPath: newFilePath)
                            let containerUrl = newUrl.deletingLastPathComponent()
                            if !FileManager.default.fileExists(atPath: newFilePath) { // no folder, create folder
                                do {
                                    try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                                }catch{
                                    print(error)
                                }
                                do { // copy file
                                    try FileManager.default.copyItem(at: oldUrl, to: newUrl)
                                }catch{
                                    print(error)
                                }
                            }
                            
                            
                        }
                    }
                }
                
                // TODO: update crop-image records
                
                
                // save repo's path
                var repo = repoContainer
                repo.cropPath = newCropPath
                ModelStore.default.saveImageContainer(container: repo)
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    self.btnUpdateStorageImages.isEnabled = true
                    self.btnUpdateRepositoryImages.isEnabled = true
                    self.btnUpdateFaceImages.isEnabled = true
                    self.btnUpdateCropImages.isEnabled = true
                    self.btnCopyToRaw.isEnabled = true
                    self.lblMessage.stringValue = "Crop files updated."
                    
                    self.working = false
                }
            }
            
        }
       
    }
    
    
    
//    @IBAction func onUpdateContainersClicked(_ sender: NSButton) {
//        guard !self.working else {return}
//        if let repoContainer = self.originalContainer {
//            
//            self.working = true
//            
//            self.btnUpdateContainers.isEnabled = false
//            self.btnUpdateStorageImages.isEnabled = false
//            self.btnUpdateRepositoryImages.isEnabled = false
//            self.btnUpdateFaceImages.isEnabled = false
//            self.btnUpdateCropImages.isEnabled = false
//            self.btnCopyToRaw.isEnabled = false
//            self.lblMessage.stringValue = ""
//            
//            DispatchQueue.global().async {
//                var repo = repoContainer
//                let repoPath = repo.path.withStash()
//                var repoChanged = false
//                if repo.repositoryPath == "" {
//                    repo.repositoryPath = repoPath
//                    repoChanged = true
//                }
//                
//                let path = repo.path.withStash()
//                
//                if repoChanged {
//                    ModelStore.default.saveImageContainer(container: repo)
//                }
//                
//                let subContainers = ModelStore.default.getContainers(rootPath: path)
//                
//                let total = subContainers.count
//                
//                DispatchQueue.main.async {
//                    self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
//                }
//                
//                for subContainer in subContainers {
//                    var sub = subContainer
//                    var subChanged = false
//                    if sub.repositoryPath == "" {
//                        sub.repositoryPath = repoPath
//                        subChanged = true
//                    }
//                    if sub.parentPath == "" {
//                        sub.parentPath = URL(fileURLWithPath: sub.path).deletingLastPathComponent().path.replacingFirstOccurrence(of: repoPath, with: "")
//                        subChanged = true
//                    }
//                    if sub.subPath == "" {
//                        sub.subPath = sub.path.replacingFirstOccurrence(of: path, with: "")
//                        subChanged = true
//                    }
//                    if subChanged {
//                        ModelStore.default.saveImageContainer(container: sub)
//                    }
//                    
//                    
//                    DispatchQueue.main.async {
//                        let _ = self.accumulator?.add("Updating sub-containers ...")
//                    }
//                }
//                
//                DispatchQueue.main.async {
//                    self.btnUpdateContainers.isEnabled = true
//                    self.btnUpdateStorageImages.isEnabled = true
//                    self.btnUpdateRepositoryImages.isEnabled = true
//                    self.btnUpdateFaceImages.isEnabled = true
//                    self.btnUpdateCropImages.isEnabled = true
//                    self.btnCopyToRaw.isEnabled = true
//                    self.lblMessage.stringValue = "Sub-containers updated."
//                    
//                    self.working = false
//                }
//            }
//        }
//    }
    
//    @IBAction func onUpdateHomePathClicked(_ sender: NSButton) {
//        if let container = self.originalContainer { // edit
//            let homePath = self.txtHomePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
//            if homePath == "" {
//                self.lblHomePathRemark.stringValue = "Please assign home path."
//                return
//            }
//            
//            var origin = container
//            origin.homePath = homePath
//            ModelStore.default.saveImageContainer(container: origin)
//            self.lblMessage.stringValue = "Home path updated."
//            
//        }
//    }
    
    @IBAction func onNormalizeHiddenClicked(_ sender: NSButton) {
        let repo = self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withStash()
        let raw = self.txtStoragePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).withStash()
        guard !self.working && repo != "/" && raw != "/" else {return}
        self.working = true
        
        // TODO: disable buttons
        
        var updateCount = 0
        var count = 0
        
        
        DispatchQueue.main.async {
            self.accumulator = Accumulator(target: 100, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage,
                                           onCompleted: { data in
                                                DispatchQueue.main.async {
                                                    let msg = "Normalized \(count) duplicated image-sets. Updated \(updateCount) images."
                                                    print(msg)
                                                    self.lblMessage.stringValue = msg
                                                    self.working = false
                                                    // TODO: enable buttons
                                                }
                                           },
                                           startupMessage: "Loading duplicates from database ..."
                                          )
        }
        DispatchQueue.global().async {
            print("loading duplicates from database")
            
            let duplicates = ModelStore.default.getDuplicatedImages(repositoryRoot: repo, theOtherRepositoryRoot: raw)
            print("loaded duplicates \(duplicates.count)")
            
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
                                var img = image
                                img.hidden = true
                                ModelStore.default.saveImage(image: img)
                                updateCount += 1
                            }
                            if !doneShowRepoImage && needShowRepoImage && image.path.starts(with: repo) {
                                // show the 1st repo image
                                var img = image
                                img.hidden = false
                                ModelStore.default.saveImage(image: img)
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
    
    // MARK: ACTION BUTTON - DELETE RECORDS
    
    @IBAction func onRemoveClicked(_ sender: NSButton) {
        if let container = self.originalContainer {
            if Alert.dialogOKCancel(question: "Remove all records and image-records of this repository from database ?", text: container.path) {
                // TODO: disable buttons
                DispatchQueue.global().async {
                    ModelStore.default.deleteRepository(repositoryRoot: container.path)
                    
                    self.freshNew()
                    self.lblMessage.stringValue = "All records and image-records of this repository have been removed from database."
                    // TODO: use delegate from main window to close this window and refresh library tree in main window
                }
            }
        }
    }
    
    // MARK: ACTION BUTTON - DEVICE INFO AREA
    
    @IBAction func onLoadDevicesClicked(_ sender: NSButton) {
        self.createDevicesPopover()
        self.devicesViewController.initView()
        
        let cellRect = sender.bounds
        self.devicesPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    @IBAction func onCompareDevicePathClicked(_ sender: NSButton) {
        let deviceId = self.lblDeviceId.stringValue
        if deviceId != "" {
            if let device = ModelStore.default.getDevice(deviceId: deviceId) {
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
    
    @IBAction func onCleanDeviceClicked(_ sender: NSButton) {
        self.lblDeviceId.stringValue = ""
        self.lblDeviceName.stringValue = ""
        self.linkDeviceToRepository(deviceId: "")
    }
    
    fileprivate func linkDeviceToRepository(deviceId: String){
        if let container = self.originalContainer {
            var repo = container
            repo.deviceId = deviceId
            ModelStore.default.saveImageContainer(container: repo)
        }
    }
    
    @IBAction func onShowHideClicked(_ sender: NSButton) {
        if let container = self.originalContainer {
            if container.hiddenByRepository {
                DispatchQueue.global().async {
                    ModelStore.default.showRepository(repositoryRoot: container.path.withStash())
                    self.originalContainer?.hiddenByRepository = false
                    ModelStore.default.saveImageContainer(container: self.originalContainer!)
                    
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = "Updated images as enabled"
                        self.btnShowHide.title = "Disable Repository"
                    }
                    
                    self.stat()
                }
            }else{
                DispatchQueue.global().async {
                    ModelStore.default.hideRepository(repositoryRoot: container.path.withStash())
                    self.originalContainer?.hiddenByRepository = true
                    ModelStore.default.saveImageContainer(container: self.originalContainer!)
                    DispatchQueue.main.async {
                        self.lblMessage.stringValue = "Updated images as disabled"
                        self.btnShowHide.title = "Enable Repository"
                    }
                    
                    self.stat()
                }
            }
        }
    }
    
    @IBAction func onFollowDevicePathsClicked(_ sender: NSButton) {
        let deviceId = self.lblDeviceId.stringValue
        if deviceId != "" {
            if let device = ModelStore.default.getDevice(deviceId: deviceId) {
                self.txtHomePath.stringValue = device.homePath ?? ""
                self.txtRepository.stringValue = device.repositoryPath ?? ""
                self.txtStoragePath.stringValue = device.storagePath ?? ""
            }
        }
    }
    
    
    // MARK: DEVICES LIST Popover
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
    
    fileprivate func displayDeviceInfo(deviceId: String, updateDB:Bool = false) {
        
        if let device = ModelStore.default.getDevice(deviceId: deviceId) {
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
            
            if updateDB {
                self.linkDeviceToRepository(deviceId: device.deviceId ?? "")
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
