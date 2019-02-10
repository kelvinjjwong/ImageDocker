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
    @IBOutlet weak var btnUpdateContainers: NSButton!
    @IBOutlet weak var btnUpdateHomePath: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var lblDeviceId: NSTextField!
    @IBOutlet weak var lblDeviceName: NSTextField!
    @IBOutlet weak var btnLoadDevices: NSButton!
    @IBOutlet weak var btnCompareDevicePath: NSButton!
    @IBOutlet weak var btnCleanDevice: NSButton!
    
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
    
    fileprivate func emptyTextFields() {
        self.txtName.stringValue = ""
        self.lblNameRemark.stringValue = ""
        self.txtHomePath.stringValue = ""
        self.lblHomePathRemark.stringValue = ""
        self.txtStoragePath.stringValue = ""
        self.lblStoragePathRemark.stringValue = ""
        self.txtRepository.stringValue = ""
        self.lblRepositoryPathRemark.stringValue = ""
        self.txtFacePath.stringValue = ""
        self.lblFacePathRemark.stringValue = ""
        self.txtCropPath.stringValue = ""
        self.lblCropPathRemark.stringValue = ""
        self.btnRestoreOriginal.isHidden = true
        self.btnCopyToRaw.isHidden = true
        self.btnUpdateContainers.isHidden = true
        self.btnUpdateStorageImages.isHidden = true
        self.btnUpdateRepositoryImages.isHidden = true
        self.btnUpdateFaceImages.isHidden = true
        self.btnUpdateCropImages.isHidden = true
    }
    
    func initNew(window:NSWindow, onOK: (() -> Void)? = nil) {
        self.onCompleted = onOK
        self.window = window
        self.emptyTextFields()
        self.originalContainer = nil
        self.btnOK.title = "Save"
        self.lblMessage.stringValue = ""
        window.title = "Add Repository"
        self.btnBrowseHomePath.title = "Assign"
        self.btnBrowseStoragePath.title = "Assign"
        self.btnBrowseRepositoryPath.title = "Assign"
        self.btnBrowseFacePath.title = "Assign"
        self.btnBrowseCropPath.title = "Assign"
        self.btnRestoreOriginal.isHidden = true
        self.btnCopyToRaw.isHidden = true
        self.btnUpdateContainers.isHidden = true
        self.btnUpdateStorageImages.isHidden = true
        self.btnUpdateRepositoryImages.isHidden = true
        self.btnUpdateFaceImages.isHidden = true
        self.btnUpdateCropImages.isHidden = true
        self.btnUpdateHomePath.isHidden = true
        self.btnRemove.isHidden = true
    }
    
    func initEdit(path:String, window:NSWindow, onOK: (() -> Void)? = nil) {
        self.onCompleted = onOK
        self.window = window
        self.emptyTextFields()
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
            self.btnUpdateContainers.isHidden = false
            self.btnUpdateStorageImages.isHidden = false
            self.btnUpdateRepositoryImages.isHidden = false
            self.btnUpdateFaceImages.isHidden = false
            self.btnUpdateCropImages.isHidden = false
            self.btnUpdateHomePath.isHidden = false
            self.btnRemove.isHidden = false
            self.btnOK.title = "Save Name"
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
        }else{
            self.originalContainer = nil
            self.lblMessage.stringValue = "ERROR: Cannot find repository with path [\(path)]"
        }
    }
    
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
            if name == "" {
                self.lblNameRemark.stringValue = "Please give me a name."
                return
            }
            
            var origin = container
            origin.name = name
            ModelStore.default.saveImageContainer(container: origin)
            self.lblMessage.stringValue = "Name updated."
            
        }else{ // new
            self.saveNewRepository()
            self.lblMessage.stringValue = "Repository created."
        }
        if self.onCompleted != nil {
            self.onCompleted!()
        }
    }
    
    @IBAction func onRestoreOriginalClicked(_ sender: NSButton) {
        if let container = self.originalContainer {
            self.emptyTextFields()
            self.txtName.stringValue = container.name
            self.txtHomePath.stringValue = container.homePath
            self.txtStoragePath.stringValue = container.storagePath
            self.txtRepository.stringValue = container.path
            self.txtFacePath.stringValue = container.facePath
            self.txtCropPath.stringValue = container.cropPath
            self.btnRestoreOriginal.isHidden = false
            self.btnCopyToRaw.isHidden = false
        }
    }
    
    @IBAction func onRestoreOriginalFacePathClicked(_ sender: NSButton) {
    }
    
    
    
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
        let face = home.appendingPathComponent("faces")
        let crop = home.appendingPathComponent("crop")
        
        if self.txtRepository.stringValue != "" && self.txtRepository.stringValue != repository.path {
            self.lblRepositoryPathRemark.stringValue = "previous: \(self.txtRepository.stringValue)"
        }
        if self.txtStoragePath.stringValue != "" && self.txtStoragePath.stringValue != storage.path  {
            self.lblStoragePathRemark.stringValue = "previous: \(self.txtStoragePath.stringValue)"
        }
        if self.txtFacePath.stringValue != "" && self.txtFacePath.stringValue != face.path {
            self.lblFacePathRemark.stringValue = "previous: \(self.txtFacePath.stringValue)"
        }
        if self.txtCropPath.stringValue != "" && self.txtCropPath.stringValue != crop.path {
            self.lblCropPathRemark.stringValue = "previous: \(self.txtCropPath.stringValue)"
        }
        
        if let container = self.originalContainer {
            if container.storagePath != "" {
                self.lblStoragePathRemark.stringValue = "original: \(container.storagePath)"
            }
            if container.path != "" {
                self.lblRepositoryPathRemark.stringValue = "original: \(container.path)"
            }
            if container.facePath != "" {
                self.lblFacePathRemark.stringValue = "original: \(container.facePath)"
            }
            if container.cropPath != "" {
                self.lblCropPathRemark.stringValue = "original: \(container.cropPath)"
            }
        }
        
        self.txtRepository.stringValue = repository.path
        self.txtStoragePath.stringValue = storage.path
        self.txtFacePath.stringValue = face.path
        self.txtCropPath.stringValue = crop.path
    }
    
    @IBAction func onFacePathFollowHomeClicked(_ sender: NSButton) {
    }
    
    
    
    @IBAction func onCopyToRawClicked(_ sender: NSButton) {
        // TODO: Copy images from repository to RAW storage
        print("TODO: Copy images from repository to RAW storage")
        
        self.lblMessage.stringValue = "TODO function"
    }
    
    
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
            
            self.btnUpdateContainers.isEnabled = false
            self.btnUpdateStorageImages.isEnabled = false
            self.btnUpdateRepositoryImages.isEnabled = false
            self.btnUpdateFaceImages.isEnabled = false
            self.btnUpdateCropImages.isEnabled = false
            self.btnCopyToRaw.isEnabled = false
            self.lblMessage.stringValue = ""
            
            DispatchQueue.global().async {
            
                if originalRawPath != "/" { // clone from original RAW path
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
                                let _ = self.accumulator?.add("Copying RAW file ...")
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
                    self.btnUpdateContainers.isEnabled = true
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
            
            if newRepoPath == "/" || newRepoPath == originalRepoPath {
                return
            }
            
            self.working = true
            
            self.btnUpdateContainers.isEnabled = false
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
                        var img = image
                        
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
                        img.repositoryPath = newRepoPath
                        img.containerPath = containerUrl.path
                        img.subPath = img.path.replacingFirstOccurrence(of: originalRepoPath, with: "")
                        img.path = newPath
                        if img.id == nil {
                            img.id = UUID().uuidString
                        }
                        ModelStore.default.saveImage(image: img)
                        
                        DispatchQueue.main.async {
                            let _ = self.accumulator?.add("Copying repository file ...")
                        }
                    }
                }
                
                // save sub-containers' path
                
                let subContainers = ModelStore.default.getContainers(rootPath: originalRepoPath)
                
                let total = subContainers.count
                
                DispatchQueue.main.async {
                    self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                }
                
                for subContainer in subContainers {
                    var sub = subContainer
                    if sub.subPath == "" {
                        sub.subPath = sub.path.replacingFirstOccurrence(of: originalRepoPath, with: "")
                    }
                    if sub.parentPath == "" {
                        sub.parentPath = URL(fileURLWithPath: sub.path).deletingLastPathComponent().path.replacingFirstOccurrence(of: originalRepoPath, with: "")
                    }
                    sub.repositoryPath = newRepoPath
                    sub.parentFolder = "\(newRepoPath)\(sub.parentPath)"
                    sub.path = sub.path.replacingFirstOccurrence(of: originalRepoPath, with: newRepoPath)
                    ModelStore.default.saveImageContainer(container: sub)
                    
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("Updating sub-container ...")
                    }
                }
                
                // save repo's path
                var repo = repoContainer
                repo.repositoryPath = newRepoPath
                ModelStore.default.saveImageContainer(container: repo)
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    self.btnUpdateContainers.isEnabled = true
                    self.btnUpdateStorageImages.isEnabled = true
                    self.btnUpdateRepositoryImages.isEnabled = true
                    self.btnUpdateFaceImages.isEnabled = true
                    self.btnUpdateCropImages.isEnabled = true
                    self.btnCopyToRaw.isEnabled = true
                    self.lblMessage.stringValue = "Repository updated."
                    
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
            
            self.btnUpdateContainers.isEnabled = false
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
                                let _ = self.accumulator?.add("Copying face file ...")
                            }
                        }
                    }
                }
                
                // save repo's path
                var repo = repoContainer
                repo.facePath = newFacePath
                ModelStore.default.saveImageContainer(container: repo)
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    self.btnUpdateContainers.isEnabled = true
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
            
            self.btnUpdateContainers.isEnabled = false
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
                                let _ = self.accumulator?.add("Copying crop file ...")
                            }
                        }
                    }
                }
                
                // save repo's path
                var repo = repoContainer
                repo.cropPath = newCropPath
                ModelStore.default.saveImageContainer(container: repo)
                self.originalContainer = repo
                
                DispatchQueue.main.async {
                    self.btnUpdateContainers.isEnabled = true
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
    
    @IBAction func onUpdateContainersClicked(_ sender: NSButton) {
        guard !self.working else {return}
        if let repoContainer = self.originalContainer {
            
            self.working = true
            
            self.btnUpdateContainers.isEnabled = false
            self.btnUpdateStorageImages.isEnabled = false
            self.btnUpdateRepositoryImages.isEnabled = false
            self.btnUpdateFaceImages.isEnabled = false
            self.btnUpdateCropImages.isEnabled = false
            self.btnCopyToRaw.isEnabled = false
            self.lblMessage.stringValue = ""
            
            DispatchQueue.global().async {
                var repo = repoContainer
                let repoPath = repo.path.withStash()
                var repoChanged = false
                if repo.repositoryPath == "" {
                    repo.repositoryPath = repoPath
                    repoChanged = true
                }
                
                let path = repo.path.withStash()
                
                if repoChanged {
                    ModelStore.default.saveImageContainer(container: repo)
                }
                
                let subContainers = ModelStore.default.getContainers(rootPath: path)
                
                let total = subContainers.count
                
                DispatchQueue.main.async {
                    self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
                }
                
                for subContainer in subContainers {
                    var sub = subContainer
                    var subChanged = false
                    if sub.repositoryPath == "" {
                        sub.repositoryPath = repoPath
                        subChanged = true
                    }
                    if sub.parentPath == "" {
                        sub.parentPath = URL(fileURLWithPath: sub.path).deletingLastPathComponent().path.replacingFirstOccurrence(of: repoPath, with: "")
                        subChanged = true
                    }
                    if sub.subPath == "" {
                        sub.subPath = sub.path.replacingFirstOccurrence(of: path, with: "")
                        subChanged = true
                    }
                    if subChanged {
                        ModelStore.default.saveImageContainer(container: sub)
                    }
                    
                    
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("Updating sub-containers ...")
                    }
                }
                
                DispatchQueue.main.async {
                    self.btnUpdateContainers.isEnabled = true
                    self.btnUpdateStorageImages.isEnabled = true
                    self.btnUpdateRepositoryImages.isEnabled = true
                    self.btnUpdateFaceImages.isEnabled = true
                    self.btnUpdateCropImages.isEnabled = true
                    self.btnCopyToRaw.isEnabled = true
                    self.lblMessage.stringValue = "Sub-containers updated."
                    
                    self.working = false
                }
            }
        }
    }
    
    @IBAction func onUpdateHomePathClicked(_ sender: NSButton) {
        if let container = self.originalContainer { // edit
            let homePath = self.txtHomePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if homePath == "" {
                self.lblHomePathRemark.stringValue = "Please assign home path."
                return
            }
            
            var origin = container
            origin.homePath = homePath
            ModelStore.default.saveImageContainer(container: origin)
            self.lblMessage.stringValue = "Home path updated."
            
        }
    }
    
    @IBAction func onRemoveClicked(_ sender: NSButton) {
    }
    
    @IBAction func onLoadDevicesClicked(_ sender: NSButton) {
    }
    
    @IBAction func onCompareDevicePathClicked(_ sender: NSButton) {
    }
    
    @IBAction func onCleanDeviceClicked(_ sender: NSButton) {
    }
    
}
