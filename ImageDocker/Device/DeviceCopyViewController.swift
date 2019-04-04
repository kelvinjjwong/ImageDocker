//
//  DeviceCopyViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

enum ChecksumMode : Int {
    case Rough
    case Deep
}

enum DeviceCopyDestinationType:Int {
    case onDevice
    case localDirectory
}

struct DeviceCopyDestination {
    var sourcePath:String
    var toSubFolder:String
    var type:DeviceCopyDestinationType
    var exclude:Bool
    var manyChildren:Bool
    
    static func new(_ pair:(String, String)) -> DeviceCopyDestination {
        return DeviceCopyDestination(sourcePath: pair.0, toSubFolder: pair.1, type:.onDevice, exclude: false, manyChildren: false)
    }
    
    static func local(_ pair:(String, String)) -> DeviceCopyDestination {
        return DeviceCopyDestination(sourcePath: pair.0, toSubFolder: pair.1, type:.localDirectory, exclude: false, manyChildren: false)
    }
    
    static func from(_ devicePath: ImageDevicePath) -> DeviceCopyDestination {
        return DeviceCopyDestination(sourcePath: devicePath.path,
                                     toSubFolder: devicePath.toSubFolder,
                                     type:.onDevice,
                                     exclude: devicePath.exclude,
                                     manyChildren: devicePath.manyChildren)
    }
    
    static func from(_ devicePaths: [ImageDevicePath]) -> [DeviceCopyDestination] {
        var result:[DeviceCopyDestination] = []
        for devicePath in devicePaths {
            result.append(DeviceCopyDestination.from(devicePath))
        }
        return result
    }
    
    static func from(deviceId: String, deviceType: MobileType = .Android) -> [DeviceCopyDestination] {
        let devicePaths = ModelStore.default.getDevicePaths(deviceId: deviceId, deviceType: deviceType)
        return DeviceCopyDestination.from(devicePaths)
    }
}

class DeviceCopyViewController: NSViewController {
    
    let dateFormatter = DateFormatter()
    
    //let mountpoint = PreferencesController.iosDeviceMountPoint()
    
    // MARK: ENVIRONMENT
    var device:PhoneDevice = PhoneDevice(type: .Android, deviceId: "", manufacture: "", model: "")
    
    var deviceFiles_fulllist:[String : [PhoneFile]] = [:]
    var deviceFiles_filtered:[String : [PhoneFile]] = [:]
    
    var paths:[DeviceCopyDestination] = []
    
    var selectedPath:DeviceCopyDestination? = nil
    
    // MARK: CONTROLS
    
    @IBOutlet weak var lblModel: NSTextField!
    @IBOutlet weak var txtStorePath: NSTextField!
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var btnBrowseStorePath: NSButton!
    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var btnCopy: NSButton!
    @IBOutlet weak var cbShowCopied: NSButton!
    @IBOutlet weak var btnAddSourcePath: NSButton!
    @IBOutlet weak var btnRemoveSourcePath: NSButton!
    @IBOutlet weak var tblSourcePath: NSTableView!
    @IBOutlet weak var tblFiles: NSTableView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var lblProgressMessage: NSTextField!
    @IBOutlet weak var btnLoad: NSButton!
    @IBOutlet weak var btnLoadFromLocal: NSButton!
    @IBOutlet weak var btnMount: NSButton!
    @IBOutlet weak var btnDeleteRecords: NSButton!
    @IBOutlet weak var btnUpdateRepository: NSButton!
    @IBOutlet weak var txtRepositoryPath: NSTextField!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var btnBrowseRepository: NSButton!
    @IBOutlet weak var btnDeepLoad: NSButton!
    @IBOutlet weak var txtHomePath: NSTextField!
    
    
    
    // MARK: POPOVER
    var addLocalDirectoryPopover:NSPopover?
    var addLocalDirectoryViewController:AddLocalDirectoryViewController!
    var addOnDeviceDirectoryPopover:NSPopover?
    
    // MARK: TABLE DELEGATES
    
    let sourcePathTableDelegate:DeviceSourcePathTableDelegate = DeviceSourcePathTableDelegate()
    let fileTableDelegate:DeviceFileTableDelegate = DeviceFileTableDelegate()
    
    // MARK: INIT

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        btnSave.isEnabled = false
        btnCopy.isEnabled = false
        //txtStorePath.isEditable = false
        tblSourcePath.isEnabled = true
        
        sourcePathTableDelegate.sourcePathSelectionDelegate = self
        self.tblSourcePath.delegate = sourcePathTableDelegate
        self.tblSourcePath.dataSource = sourcePathTableDelegate
        self.tblFiles.delegate = fileTableDelegate
        self.tblFiles.dataSource = fileTableDelegate
    }
    
    func viewInit(device:PhoneDevice){
        if device.deviceId != self.device.deviceId {
            print("DEVICE INIT")
            print("DIFFERENT DEVICE \(device.deviceId) != \(self.device.deviceId)")
            self.device = device
            
            self.btnCopy.isEnabled = false
            self.btnUpdateRepository.isEnabled = false
            
            if device.type == .iPhone {
                self.btnMount.isHidden = false
                self.btnMount.isEnabled = true
            }else{
                self.btnMount.isHidden = true
                self.btnMount.isEnabled = false
            }
            
            self.lblMessage.stringValue = ""
            
            if let accumulate = self.accumulator {
                accumulate.reset()
            }
            
            let marketName = CameraModelRecognizer.getMarketName(maker: device.manufacture, model: device.model)
            var marketDisplayName = ""
            if marketName != "" {
                marketDisplayName = " (\(marketName))"
            }
            
            let imageDevice = ModelStore.default.getOrCreateDevice(device: device)
            
            self.lblModel.stringValue = "\(imageDevice.manufacture ?? "") \(imageDevice.model ?? "")\(marketDisplayName)"
            if imageDevice.name != nil && imageDevice.name != "" {
                self.txtName.stringValue = imageDevice.name ?? ""
            }else{
                self.txtName.stringValue = imageDevice.deviceId ?? ""
            }
            
            if imageDevice.storagePath != nil && imageDevice.storagePath != "" {
                txtStorePath.stringValue = imageDevice.storagePath ?? ""
                btnSave.isEnabled = true
            }else{
                txtStorePath.stringValue = ""
            }
            
            if imageDevice.repositoryPath != nil && imageDevice.repositoryPath != "" {
                txtRepositoryPath.stringValue = imageDevice.repositoryPath ?? ""
                btnSave.isEnabled = true
            }else{
                txtRepositoryPath.stringValue = ""
            }
            
            if imageDevice.homePath != nil && imageDevice.homePath != "" {
                txtHomePath.stringValue = imageDevice.homePath ?? ""
            }else{
                txtHomePath.stringValue = ""
            }
            
            self.addOnDeviceDirectoryPopover = nil
            
            if device.type == .Android {
                self.paths = DeviceCopyDestination.from(deviceId: device.deviceId)
                self.emptyFileLists(paths: paths)
                self.sourcePathTableDelegate.paths = paths
                self.tblSourcePath.reloadData()
                
                
            }else if device.type == .iPhone {
                if IPHONE.bridge.mounted(path: PreferencesController.iosDeviceMountPoint()) {
                    self.btnMount.title = "Unmount"
                    self.paths = DeviceCopyDestination.from(deviceId: device.deviceId, deviceType: .iPhone)
                    self.emptyFileLists(paths: paths)
                    self.sourcePathTableDelegate.paths = paths
                    self.tblSourcePath.reloadData()
                }else{
                    self.btnMount.title = "Mount"
                    self.emptyFileLists(paths: paths)
                    self.paths = []
                    self.sourcePathTableDelegate.paths = paths
                    self.tblSourcePath.reloadData()
                }
            }
            self.fileTableDelegate.files = []
            self.tblFiles.reloadData()
        }else{
            print("SAME DEVICE \(device.deviceId) == \(self.device.deviceId)")
        }
    }
    
    override func dismiss(_ sender: Any?) {
        if let wc = self.view.window?.windowController {
            wc.dismissController (sender)
        }
    }
    
    func emptyFileLists(paths: [DeviceCopyDestination]){
        for path in paths {
            self.deviceFiles_filtered[path.sourcePath] = []
            self.deviceFiles_fulllist[path.sourcePath] = []
        }
    }
    
    // MARK: GET FILE LIST
    
    func getFileFullList(from path:DeviceCopyDestination, reloadFileList:Bool = false) -> [PhoneFile]{
        print("GET FULL LIST FROM \(path)")
        if self.deviceFiles_fulllist[path.sourcePath] == nil {
            print("nil, return empty")
            return []
        }
        if self.deviceFiles_fulllist[path.sourcePath] != nil && self.deviceFiles_fulllist[path.sourcePath]!.count == 0 {
            print("not nil but zero count, load from path")
            let excludePaths:[String] = self.getExcludedPaths()
            self.loadFromPath(path: path, reloadFileList:reloadFileList, excludePaths: excludePaths)
        }
        return self.deviceFiles_fulllist[path.sourcePath]!
    }
    
    func getFileFilteredList(from path:DeviceCopyDestination, reloadFileList:Bool = false) -> [PhoneFile]{
        if self.deviceFiles_fulllist[path.sourcePath] == nil {
            return []
        }
        if self.deviceFiles_fulllist[path.sourcePath] != nil && self.deviceFiles_fulllist[path.sourcePath]!.count == 0 {
            let excludePaths:[String] = self.getExcludedPaths()
            self.loadFromPath(path: path, reloadFileList:reloadFileList, excludePaths: excludePaths)
        }
        return self.deviceFiles_filtered[path.sourcePath]!
    }
    
    // MARK: LOAD FROM PATH
    
    fileprivate func loadFromLocalPath(path:String, pretendPath:String, reloadFileList:Bool = false, checksumMode:ChecksumMode = .Rough) {
        print("LOAD FROM LOCAL \(path) - \(pretendPath)")
        
        DispatchQueue.main.async {
            self.deviceFiles_filtered[path] = []
            self.deviceFiles_fulllist[path] = []
        }
        let files = LocalDirectory.bridge.files(in: path)
        if files.count > 0 {
            let total = files.count
            DispatchQueue.main.async {
                self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
            }
            for file in files {
                var f = file
                // SAVE BEFORE PRETEND
                f.onDevicePath = file.path
                // PRETEND
                let filepath:URL = URL(fileURLWithPath: file.onDevicePath).appendingPathComponent(file.folder)
                let url:URL = URL(fileURLWithPath: pretendPath).appendingPathComponent(file.folder).appendingPathComponent(file.filename)
                f.path = url.path
                let importedFile:ImageDeviceFile? = ModelStore.default.getImportedFile(deviceId: self.device.deviceId, file: f)
                if let deviceFile = importedFile {
                    print("IMPORTED \(f.filename)")
                    f.storedMD5 = deviceFile.fileMD5 ?? ""
                    f.storedSize = deviceFile.fileSize ?? ""
                    f.storedDateTime = deviceFile.fileDateTime ?? ""
                    f.importDate = deviceFile.importDate ?? ""
                    f.importToPath = deviceFile.importToPath ?? ""
                    f.importAsFilename = deviceFile.importAsFilename ?? ""
                    
                    f.deviceFile = deviceFile
                }else{
                    print("NOT IMPORTED \(f.filename)")
                    let key = "\(self.device.deviceId):\(f.path)"
                    let datetime = LocalDirectory.bridge.datetime(of: f.filename, in: filepath.path)
                    let deviceFile = ImageDeviceFile.new(fileId: key,
                                                         deviceId: self.device.deviceId,
                                                         path: filepath.path,
                                                         filename: f.filename,
                                                         fileDateTime: datetime,
                                                         fileSize: f.fileSize)
                    f.deviceFile = deviceFile
                }
                DispatchQueue.main.async {
                    self.deviceFiles_fulllist[path]!.append(f)
                    if checksumMode == .Rough {
                        if !(f.stored && f.matchedWithoutMD5) {
                            self.deviceFiles_filtered[path]!.append(f)
                        }
                    }else{
                        if !(f.stored && f.matched) {
                            self.deviceFiles_filtered[path]!.append(f)
                        }
                    }
                    let _ = self.accumulator?.add("")
                }
            }
            // Enable "Copy Files" button if any path includes new file(s)
            DispatchQueue.main.async {
                if self.deviceFiles_filtered[path]!.count > 0 {
                    self.btnCopy.isEnabled = true
                }
                if reloadFileList {
                    self.tblFiles.reloadData()
                }
            }
        }
    }
    
    fileprivate func loadFromOnDevicePath(path:String, reloadFileList:Bool = false, checksumMode:ChecksumMode = .Rough, excludePaths:[String]){
        
        DispatchQueue.main.async {
            self.deviceFiles_filtered[path] = []
            self.deviceFiles_fulllist[path] = []
        }
        var files:[PhoneFile] = []
        if self.device.type == .Android {
            if Android.bridge.exists(device: self.device.deviceId, path: path) {
                files = Android.bridge.files(device: self.device.deviceId, in: path)
            }else{
                print("NOT EXISTS PATH ON DEVICE \(path)")
            }
        }else{
            files = IPHONE.bridge.files(mountPoint: PreferencesController.iosDeviceMountPoint(), in: path)
        }
        let total = files.count
        DispatchQueue.main.async {
            self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
        }
        for file in files {
            var shouldExclude = false
            for excludePath in excludePaths {
                if file.path.starts(with: excludePath.withStash()) {
                    shouldExclude = true
                }
            }
            if shouldExclude {
                continue
            }
            let deviceFile = ModelStore.default.getOrCreateDeviceFile(deviceId: self.device.deviceId, file: file)
            var f = file
            if deviceFile.importAsFilename != "" {
                f.storedMD5 = deviceFile.fileMD5 ?? ""
                f.storedSize = deviceFile.fileSize ?? ""
                f.storedDateTime = deviceFile.fileDateTime ?? ""
            }
            
            f.importDate = deviceFile.importDate ?? ""
            f.importToPath = deviceFile.importToPath ?? ""
            f.importAsFilename = deviceFile.importAsFilename ?? "" // trigger compare
            
            f.deviceFile = deviceFile
            
            f.checksumMode = checksumMode
            
            if checksumMode == .Rough {
                if (f.stored && !f.matchedWithoutMD5){
                    print("Getting MD5 of \(f.path)")
                    f.fileMD5 = Android.bridge.md5(device: self.device.deviceId, fileWithPath: f.path)
                }
            }else if checksumMode == .Deep {
                if (f.stored && !f.matched){
                    print("Getting MD5 of \(f.path)")
                    f.fileMD5 = Android.bridge.md5(device: self.device.deviceId, fileWithPath: f.path)
                }
            }
            
            DispatchQueue.main.async {
                self.deviceFiles_fulllist[path]!.append(f)
                if checksumMode == .Rough {
                    if !(f.stored && f.matchedWithoutMD5) {
                        self.deviceFiles_filtered[path]!.append(f)
                    }
                }else{
                    if !(f.stored && f.matched) {
                        self.deviceFiles_filtered[path]!.append(f)
                    }
                }
                let _ = self.accumulator?.add("")
            }
        }
        // Enable "Copy Files" button if any path includes new file(s)
        DispatchQueue.main.async {
            if self.deviceFiles_filtered[path]!.count > 0 {
                self.btnCopy.isEnabled = true
            }
            if reloadFileList {
                print("RELOAD")
                self.tblFiles.reloadData()
            }
        }
    }
    
    func loadFromPath(path: DeviceCopyDestination, reloadFileList:Bool = false, checksumMode:ChecksumMode = .Rough, excludePaths:[String]) {
        if path.type == .onDevice {
            loadFromOnDevicePath(path: path.sourcePath, reloadFileList: reloadFileList, checksumMode: checksumMode, excludePaths: excludePaths)
        }else if path.type == .localDirectory {
            loadFromLocalPath(path: path.sourcePath, pretendPath: path.toSubFolder, reloadFileList:reloadFileList)
        }
    }
    
    func refreshFileList(){
        if selectedPath != nil {
            self.fileTableDelegate.files = cbShowCopied.state == .on ? self.getFileFullList(from: selectedPath!, reloadFileList: true) : self.getFileFilteredList(from: selectedPath!, reloadFileList: true)
            
            self.tblFiles.reloadData()
        }
    }
    
    // MARK: ACTION BUTTON - OPEN PANEL
    
    @IBAction func onBrowseStorePathClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    if path != "" {
                        self.txtStorePath.stringValue = path
                        self.btnSave.isEnabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func onBrowseRepositoryPathClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    if path != "" {
                        self.txtRepositoryPath.stringValue = path
                        self.btnSave.isEnabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func onBrowseHomePathClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    if path != "" {
                        self.txtHomePath.stringValue = path
                    }
                }
            }
        }
    }
    
    @IBAction func onGotoHomeClicked(_ sender: NSButton) {
        guard self.txtHomePath.stringValue != "" else {return}
        
        let url = URL(fileURLWithPath: self.txtHomePath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onGotoRepositoryClicked(_ sender: NSButton) {
        guard self.txtRepositoryPath.stringValue != "" else {return}
        
        let url = URL(fileURLWithPath: self.txtRepositoryPath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onGotoRawClicked(_ sender: NSButton) {
        guard self.txtStorePath.stringValue != "" else {return}
        
        let url = URL(fileURLWithPath: self.txtStorePath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onMountClicked(_ sender: NSButton) {
        print(self.device)
        if self.device.type == .iPhone {
            print(self.btnMount.title)
            let mountpoint = PreferencesController.iosDeviceMountPoint()
            if self.btnMount.title == "Mount" {
                print("INVOKE MOUNT")
                IPHONE.bridge.unmount(path: mountpoint)
                if IPHONE.bridge.mount(path: mountpoint) {
                    print("JUST MOUNTED")
                    self.btnMount.title = "Unmount"
                    
                    self.paths = [
                        DeviceCopyDestination.new(("/DCIM/", "Camera"))
                    ]
                    self.emptyFileLists(paths: paths)
                    self.sourcePathTableDelegate.paths = paths
                    self.tblSourcePath.reloadData()
                    
                }else{
                    print("UNABLE TO MOUNT IPHONE")
                }
            }else {
                print("INVOKE UNMOUNT")
                // Unmount
                IPHONE.bridge.unmount(path: mountpoint)
                self.btnMount.title = "Mount"
                
                self.emptyFileLists(paths: paths)
                self.paths = []
                self.sourcePathTableDelegate.paths = paths
                self.tblSourcePath.reloadData()
            }
        }else{
            print("NOT IPHONE")
            self.btnMount.isHidden = true
            self.btnMount.isEnabled = false
        }
    }
    
    
    
    // MARK: TOGGLE BUTTONS
    
    fileprivate func toggleControls(state:Bool) {
        self.btnMount.isEnabled = state
        self.btnCopy.isEnabled = state
        self.btnLoad.isEnabled = state
        self.btnDeepLoad.isEnabled = state
        self.btnSave.isEnabled = state
        self.btnBrowseStorePath.isEnabled = state
        self.btnBrowseRepository.isEnabled = state
        self.btnAddSourcePath.isEnabled = state
        self.btnRemoveSourcePath.isEnabled = state
        self.btnLoadFromLocal.isEnabled = state
        self.btnDeleteRecords.isEnabled = state
        self.btnUpdateRepository.isEnabled = state
        self.cbShowCopied.isEnabled = state
        self.tblSourcePath.isEnabled = state
    }
    
    fileprivate func disableButtons(){
        self.toggleControls(state: false)
    }
    
    fileprivate func enableButtons() {
        self.toggleControls(state: true)
    }
    
    // MARK: VALID PATHS
    
    fileprivate func validPaths() -> Bool {
        
        self.lblMessage.stringValue = ""
        let storagePath = txtStorePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let repositoryPath = txtRepositoryPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if storagePath == "" {
            self.lblMessage.stringValue = "ERROR: Path for Raw Copy should not be empty!"
            return false
        }
        if repositoryPath == "" {
            self.lblMessage.stringValue = "ERROR: Path for Repository should not be empty!"
            return false
        }
        
        if repositoryPath == storagePath {
            self.lblMessage.stringValue = "ERROR: Both paths should not be same!"
            return false
        }
        
        var isDir:ObjCBool = false
        if FileManager.default.fileExists(atPath: storagePath, isDirectory: &isDir) {
            if isDir.boolValue == false {
                self.lblMessage.stringValue = "ERROR: Path for Raw Copy is not a directory!"
                return false
            }
        }else{
            self.lblMessage.stringValue = "ERROR: Path for Raw Copy does not exist!"
            return false
        }
        if FileManager.default.fileExists(atPath: repositoryPath, isDirectory: &isDir) {
            if isDir.boolValue == false {
                self.lblMessage.stringValue = "ERROR: Path for Repository is not a directory!"
                return false
            }
        }else{
            self.lblMessage.stringValue = "ERROR: Path for Repository does not exist!"
            return false
        }
        return true
    }
    
    
    // MARK: ACTION BUTTON - SAVE
    
    @IBAction func onSaveClicked(_ sender: NSButton) {
        guard !self.working else {return}
        let name = txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let homePath = txtHomePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let storagePath = txtStorePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let repositoryPath = txtRepositoryPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !self.validPaths() {
            return
        }
        
        self.working = true
        self.disableButtons()
        
        // TODO: IF storage path / repository path changed, MOVE files from old path to new path
        
        let marketName = CameraModelRecognizer.getMarketName(maker: device.manufacture, model: device.model)
        
        self.accumulator = Accumulator(target: 1, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
        
        DispatchQueue.global().async {
        
            var imageDevice = ModelStore.default.getOrCreateDevice(device: self.device)
            
            if let oldStoragePath = imageDevice.storagePath, oldStoragePath != storagePath {
                let deviceFiles = ModelStore.default.getDeviceFiles(deviceId: self.device.deviceId)
                if deviceFiles.count > 0 {
                    
                    self.accumulator?.reset()
                    self.accumulator?.setTarget(deviceFiles.count)
 
                    for deviceFile in deviceFiles {
                        if let oldImportToPath = deviceFile.importToPath, let filename = deviceFile.filename, let localFilePath = deviceFile.localFilePath, localFilePath != "" {
                            
                            DispatchQueue.main.async {
                                self.lblMessage.stringValue = "Updating new RAW storage: \(localFilePath)"
                            }
                            
                            let oldFilePath = URL(fileURLWithPath: oldImportToPath).appendingPathComponent(filename)
                            let newFilePath = URL(fileURLWithPath: storagePath).appendingPathComponent(localFilePath)
                            let newFolderPath = newFilePath.deletingLastPathComponent()
                            if !FileManager.default.fileExists(atPath: newFilePath.path) {
                                
                                DispatchQueue.main.async {
                                    self.lblMessage.stringValue = "Copying to new RAW storage: \(localFilePath)"
                                }
                                
                                do {
                                    try FileManager.default.createDirectory(at: newFolderPath, withIntermediateDirectories: true, attributes: nil)
                                }catch{
                                    print("Error occured when trying to create folder \(newFolderPath.path)")
                                    print(error)
                                }
                                do {
                                    try FileManager.default.copyItem(atPath: oldFilePath.path, toPath: newFilePath.path)
                                }catch{
                                    print("Error occured when trying to copy [\(oldFilePath.path)] to [\(newFilePath.path)]")
                                    print(error)
                                }
                            }
                            var file = deviceFile
                            file.importToPath = newFolderPath.path
                            print("Update [\(localFilePath)] with new importToPath: \(newFolderPath.path)")
                            ModelStore.default.saveDeviceFile(file: file)
                        }
                        
                        DispatchQueue.main.async {
                            let _ = self.accumulator?.add("")
                        }
                    }
                }
            }
        
            if let oldRepositoryPath = imageDevice.repositoryPath, oldRepositoryPath != repositoryPath {
                let deviceFiles = ModelStore.default.getDeviceFiles(deviceId: self.device.deviceId)
                if deviceFiles.count > 0 {
                    
                    self.accumulator?.reset()
                    self.accumulator?.setTarget(deviceFiles.count)
                    
                    for deviceFile in deviceFiles {
                        if let localFilePath = deviceFile.localFilePath, localFilePath != "" {
                            
                            DispatchQueue.main.async {
                                self.lblMessage.stringValue = "Updating new repository: \(localFilePath)"
                            }
                            
                            let oldFilePath = URL(fileURLWithPath: oldRepositoryPath).appendingPathComponent(localFilePath)
                            let newFilePath = URL(fileURLWithPath: repositoryPath).appendingPathComponent(localFilePath)
                            let newFolderPath = newFilePath.deletingLastPathComponent()
                            if !FileManager.default.fileExists(atPath: newFilePath.path) {
                                
                                DispatchQueue.main.async {
                                    self.lblMessage.stringValue = "Copying to new repository: \(localFilePath)"
                                }
                                
                                do {
                                    try FileManager.default.createDirectory(at: newFolderPath, withIntermediateDirectories: true, attributes: nil)
                                }catch{
                                    print("Error occured when trying to create folder \(newFolderPath.path)")
                                    print(error)
                                }
                                do {
                                    try FileManager.default.copyItem(atPath: oldFilePath.path, toPath: newFilePath.path)
                                }catch{
                                    print("Error occured when trying to copy [\(oldFilePath.path)] to [\(newFilePath.path)]")
                                    print(error)
                                }
                            }
                        }
                        
                        DispatchQueue.main.async {
                            let _ = self.accumulator?.add("")
                        }
                    }
                }
            }
            
            imageDevice.name = name
            imageDevice.homePath = homePath
            imageDevice.storagePath = storagePath
            imageDevice.repositoryPath = repositoryPath
            imageDevice.marketName = marketName
            ModelStore.default.saveDevice(device: imageDevice)
            
            DispatchQueue.main.async {
                self.enableButtons()
                self.toggleSpecialButtons()
                self.working = false
                self.lblMessage.stringValue = "Device info saved."
            }
        }
    }
    
    // MARK: ACTION BUTTON - DELETE RECORDS
    
    @IBAction func onDeleteRecordsClicked(_ sender: NSButton) {
        self.lblMessage.stringValue = "Deleting records ..."
        ModelStore.default.deleteDeviceFiles(deviceId: self.device.deviceId)
        self.lblMessage.stringValue = "Deleted records."
    }
    
    // MARK: ACTION BUTTON - LOAD FILE LIST
    
    fileprivate func getExcludedPaths() -> [String] {
        var excludePaths:[String] = []
        for path in paths {
            if path.exclude {
                excludePaths.append(path.sourcePath)
            }
        }
        return excludePaths
    }
    
    fileprivate func reloadFileList(checksumMode:ChecksumMode = .Rough) {
        self.working = true
        if paths.count > 0 {
            self.disableButtons()
            
            let excludePaths:[String] = self.getExcludedPaths()
            
            DispatchQueue.main.async {
                self.lblMessage.stringValue = "Loading file list ..."
            }
            
            DispatchQueue.global().async {
                for path in self.paths {
                    if !path.exclude {
                        self.loadFromPath(path: path, checksumMode: checksumMode, excludePaths: excludePaths)
                    }
                }
                DispatchQueue.main.async {
                    
                    self.enableButtons()
                    
                    if self.selectedPath == nil {
                        self.selectDeviceSourcePath(path: self.paths[0])
                    }else{
                        self.selectDeviceSourcePath(path: self.selectedPath!)
                    }
                    self.working = false
                    
                    self.toggleSpecialButtons()
                }
            }
        }else{
            self.working = false
        }
    }
    
    fileprivate func toggleSpecialButtons() {
        let sumOfFulllist = self.countFullList()
        let sumOfFiltered = self.countFilteredList()
        var timeRange = ""
        if sumOfFiltered > 0 {
            let maxDate = self.getFilteredMaxDate()
            let minDate = self.getFilteredMinimalDate()
            timeRange = " (\(minDate) - \(maxDate))"
        }
        self.lblMessage.stringValue = "TOTAL: \(sumOfFulllist), NEW: \(sumOfFiltered)\(timeRange)"
        
        if sumOfFiltered == 0 {
            self.btnCopy.isEnabled = false
        }
        
        if self.hasEmptyMD5() {
            self.btnUpdateRepository.isEnabled = true
        }else{
            self.btnUpdateRepository.isEnabled = false
        }
    }
    
    @IBAction func onLoadClicked(_ sender: NSButton) {
        self.reloadFileList()
    }
    
    @IBAction func onDeepLoadClicked(_ sender: NSButton) {
        self.reloadFileList(checksumMode: .Deep)
    }
    
    
    // MARK: COUNT FILE LIST
    
    fileprivate func countFilteredList() -> Int {
        var total = 0
        for path in self.paths {
            total += self.deviceFiles_filtered[path.sourcePath]!.count
        }
        return total
    }
    
    fileprivate func countFullList() -> Int {
        var total = 0
        for path in self.paths {
            total += self.deviceFiles_fulllist[path.sourcePath]!.count
        }
        return total
    }
    
    fileprivate func hasEmptyMD5() -> Bool {
        for path in self.paths {
            if let files = self.deviceFiles_fulllist[path.sourcePath] {
                for file in files {
                    if file.importToPath != "" && file.storedMD5 == "" {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    fileprivate func getFilteredMaxDate() -> String {
        var max = "0000-00-00 00:00:00"
        for path in self.paths {
            if let files = self.deviceFiles_filtered[path.sourcePath] {
                for file in files {
                    if file.fileDateTime > max {
                        max = file.fileDateTime
                    }
                }
            }
        }
        return max
    }
    
    fileprivate func getFilteredMinimalDate() -> String {
        var min = "9999-00-00 00:00:00"
        for path in self.paths {
            if let files = self.deviceFiles_filtered[path.sourcePath] {
                for file in files {
                    if file.fileDateTime < min {
                        min = file.fileDateTime
                    }
                }
            }
        }
        return min
    }
    
    // MARK: ACTION BUTTON - COPY FILES
    
    fileprivate var working = false
    fileprivate var accumulator:Accumulator?
    
    @IBAction func onCopyClicked(_ sender: NSButton) {
        guard !working && self.validPaths() else {return}
        var total = 0
        for path in self.paths {
            if path.exclude {
                continue
            }
            print("TO BE COPIED: \(path.sourcePath) - \(self.deviceFiles_filtered[path.sourcePath]!.count)")
            total += self.deviceFiles_filtered[path.sourcePath]!.count
        }
        print("TO BE COPIED: \(total)")
        guard total > 0 else {return}
        self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
        
        let destination = self.txtStorePath.stringValue
        
        self.working = true
        self.disableButtons()
        
        let storagePath = txtStorePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let repositoryPath = txtRepositoryPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let storageUrl = URL(fileURLWithPath: storagePath)
        let storageUrlWithSlash = "\(storageUrl.path)/"
        
        let computerFileHandler = ComputerFileManager()
        
        DispatchQueue.global().async {
            let now = Date()
            let date = self.dateFormatter.string(from: now)
            for path in self.paths {
                if path.exclude {
                    continue
                }
                var subFolder = path.toSubFolder
                if path.type == .localDirectory {
                    // PRETEND AS ON DEVICE PATH
                    if let onDevicePath = self.paths.first(where: {$0.sourcePath == path.toSubFolder && $0.type == .onDevice}) {
                        subFolder = onDevicePath.toSubFolder
                    }
                }
                var destinationPath = URL(fileURLWithPath: destination).appendingPathComponent(subFolder).path
                if !FileManager.default.fileExists(atPath: destinationPath) {
                    do {
                        try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
                    }catch{
                        print(error)
                        destinationPath = destination
                    }
                }
                for file in self.deviceFiles_filtered[path.sourcePath]! {
                    
                    var destinationPathForFile = destinationPath
                    if file.folder != "" {
                        destinationPathForFile = URL(fileURLWithPath: destinationPath).appendingPathComponent(file.folder).path
                        
                        if !FileManager.default.fileExists(atPath: destinationPathForFile) {
                            do {
                                try FileManager.default.createDirectory(atPath: destinationPathForFile, withIntermediateDirectories: true, attributes: nil)
                            }catch{
                                print(error)
                                destinationPathForFile = destinationPath
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if file.folder != "" {
                            self.lblMessage.stringValue = "Copying from device: \(subFolder)/\(file.folder)/\(file.filename)"
                        }else{
                            self.lblMessage.stringValue = "Copying from device: \(subFolder)/\(file.filename)"
                        }
                    }
                    var deviceFile = file.deviceFile!
                    if path.type == .onDevice {
                        if self.device.type == .Android {
                            if Android.bridge.pull(device: self.device.deviceId, from: file.path, to: destinationPathForFile) {
                                print("Copied \(file.path)")
                                if file.deviceFile != nil {
                                    deviceFile.importToPath = destinationPathForFile
                                    deviceFile.importAsFilename = file.filename
                                    deviceFile.importDate = date
                                    ModelStore.default.saveDeviceFile(file: deviceFile)
                                    print("Updated \(file.path)")
                                }
                            }else{
                                print("Failed to copy \(file.path)")
                            }
                        }else if self.device.type == .iPhone {
                            if IPHONE.bridge.pull(mountPoint: PreferencesController.iosDeviceMountPoint(), sourcePath:path.sourcePath, from: file.path, to: destinationPathForFile) {
                                print("Copied \(file.path)")
                                if file.deviceFile != nil {
                                    deviceFile.importToPath = destinationPathForFile
                                    deviceFile.importAsFilename = file.filename
                                    deviceFile.importDate = date
                                    ModelStore.default.saveDeviceFile(file: deviceFile)
                                    print("Updated \(file.path)")
                                }
                            }else{
                                print("Failed to copy \(file.path)")
                            }
                        }
                    } else if path.type == .localDirectory {
                        print("COPYING LOCAL \(file.onDevicePath)")
                        
                        var needSaveFile:Bool = false
                        let destinationFile = URL(fileURLWithPath: destinationPathForFile).appendingPathComponent(file.filename).path
                        if FileManager.default.fileExists(atPath: destinationFile) {
                            // exist file, avoid copy
                            needSaveFile = true
                        }else{ // not exist, copy file
                            do{
                                try FileManager.default.copyItem(atPath: file.onDevicePath, toPath: destinationFile)
                                
                                needSaveFile = true
                            }catch{
                                print(error)
                            }
                        }
                        if needSaveFile {
                            deviceFile.importToPath = destinationPathForFile
                            deviceFile.importAsFilename = file.filename
                            deviceFile.importDate = date
                            ModelStore.default.saveDeviceFile(file: deviceFile)
                            print("Updated \(file.path)")
                        }
                    }
                    
                    self.updateDeviceFileIntoRepository(fileRecord: deviceFile, storageUrlWithSlash: storageUrlWithSlash, repositoryPath: repositoryPath, fileHandler: computerFileHandler)
                    
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("")
                    }
                }
            }
            DispatchQueue.main.async {
                //self.refreshFileList()
//                self.btnCopy.isEnabled = true
//                self.btnLoad.isEnabled = true
//                self.btnBrowseStorePath.isEnabled = true
//                self.cbShowCopied.isEnabled = true
//                self.btnAddSourcePath.isEnabled = true
//                self.btnRemoveSourcePath.isEnabled = true
                self.reloadFileList()
            }
        }
    }
    
    // MARK: ACTION BUTTON - UPDATE REPOSITORY
    
    fileprivate func updateDeviceFileIntoRepository(fileRecord deviceFile:ImageDeviceFile, storageUrlWithSlash:String, repositoryPath:String, fileHandler:ComputerFileManager){
        var file = deviceFile
        if let filename = file.filename, let importToPath = file.importToPath, importToPath.starts(with: storageUrlWithSlash) {
            
            var needSave = false
            let subpath = importToPath.replacingOccurrences(of: storageUrlWithSlash, with: "")
            let localFilePath = "\(subpath)/\(filename)"
            if localFilePath != "/" && ( file.localFilePath == nil || file.localFilePath == "" ) {
                file.localFilePath = localFilePath
                needSave = true
            }else{
                return
            }
            
            DispatchQueue.main.async {
                self.lblMessage.stringValue = "Updating repository: \(localFilePath)"
            }
            
            let importedFileUrl = URL(fileURLWithPath: importToPath).appendingPathComponent(filename)
            let repositoryFileUrl = URL(fileURLWithPath: repositoryPath).appendingPathComponent(localFilePath)
            //print(repositoryFileUrl.path)
            
            let repositoryFolderUrl = repositoryFileUrl.deletingLastPathComponent()
            do {
                try FileManager.default.createDirectory(at: repositoryFolderUrl, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Error occured when trying to create folder \(repositoryFolderUrl.path)")
                print(error)
            }
            if !FileManager.default.fileExists(atPath: repositoryFileUrl.path) {
                do {
                    try FileManager.default.copyItem(atPath: importedFileUrl.path, toPath: repositoryFileUrl.path)
                }catch{
                    print("Error occured when trying to copy file from \(importedFileUrl.path) to \(repositoryFileUrl.path)")
                    print(error)
                }
            }
            if file.fileMD5 == nil || file.fileMD5 == "" {
                let md5 = fileHandler.md5(pathOfFile: importedFileUrl.path)
                if md5 != "" {
                    file.fileMD5 = md5
                    needSave = true
                }
            }
            if needSave {
                ModelStore.default.saveDeviceFile(file: file)
            }
        }
    }
    
    @IBAction func onUpdateRepositoryClicked(_ sender: Any) {
        guard !working && self.validPaths() else {return}
        
        self.working = true
        
        self.disableButtons()
        
        let deviceFiles = ModelStore.default.getDeviceFiles(deviceId: self.device.deviceId)
        if deviceFiles.count > 0 {
            self.accumulator = Accumulator(target: deviceFiles.count, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
            
            let storagePath = txtStorePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let repositoryPath = txtRepositoryPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let storageUrl = URL(fileURLWithPath: storagePath)
            let storageUrlWithSlash = "\(storageUrl.path)/"
            
            let computerFileHandler = ComputerFileManager()
            
            DispatchQueue.global().async {
                for deviceFile in deviceFiles {
                    
                    self.updateDeviceFileIntoRepository(fileRecord: deviceFile, storageUrlWithSlash: storageUrlWithSlash, repositoryPath: repositoryPath, fileHandler: computerFileHandler)
                    
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("")
                    }
                }
                self.working = false
                self.enableButtons()
            }
        }else{
            self.lblMessage.stringValue = "No file record."
            self.working = false
            self.enableButtons()
        }
    }
    
    // MARK: ACTION BUTTON - CHECKBOX - SHOW COPIED
    
    @IBAction func onCheckboxShowCopiedClicked(_ sender: NSButton) {
        self.refreshFileList()
    }
    
    // MARK: ACTION BUTTONS - ADD LOCAL DIRECTORY AS SOURCE PATH
    
    @IBAction func onLoadFromLocalClicked(_ sender: NSButton) {
        self.createLocalDirectoryPopover()
        
        let cellRect = sender.bounds
        self.addLocalDirectoryPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    // MARK: ACTION BUTTON - ADD / REMOVE SOURCE PATH
    
    @IBAction func onAddSourcePathClicked(_ sender: NSButton) {
        self.createOnDeviceDirectoryPopover()
        
        let cellRect = sender.bounds
        self.addOnDeviceDirectoryPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    @IBAction func onRemoveSourcePathClicked(_ sender: NSButton) {
        if sourcePathTableDelegate.lastSelectedRow != nil && sourcePathTableDelegate.lastSelectedRow! < sourcePathTableDelegate.paths.count {
            let pathIndex = sourcePathTableDelegate.lastSelectedRow!
            let path = paths[pathIndex]
            paths.remove(at: pathIndex)
            sourcePathTableDelegate.paths.remove(at: pathIndex)
            sourcePathTableDelegate.lastSelectedRow = nil
            if selectedPath != nil {
                if self.deviceFiles_fulllist[selectedPath!.sourcePath] != nil {
                    self.deviceFiles_fulllist[selectedPath!.sourcePath]?.removeAll()
                    self.deviceFiles_fulllist[selectedPath!.sourcePath] = nil
                }
                if self.deviceFiles_filtered[selectedPath!.sourcePath] != nil {
                    self.deviceFiles_filtered[selectedPath!.sourcePath]?.removeAll()
                    self.deviceFiles_filtered[selectedPath!.sourcePath] = nil
                }
            }
            ModelStore.default.deleteDevicePath(deviceId: self.device.deviceId, path: path.sourcePath)
            selectedPath = nil
            tblSourcePath.reloadData()
        }
    }
    
    // MARK: POPOVER - ON DEVICE DIRECTORY
    
    fileprivate func createOnDeviceDirectoryPopover(){
        var myPopover = self.addOnDeviceDirectoryPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 750, height: 390))
            
            let directoryViewDelegate = AndroidDirectoryViewDelegate(deviceId: self.device.deviceId)
            self.addLocalDirectoryViewController = AddLocalDirectoryViewController(directoryViewDelegate: directoryViewDelegate,
                                                                                   deviceType: self.device.type,
                                                                                   destinationType: .onDevice,
                                                                                   onApply: { (directory, toSubFolder, isExclude, hasManyChildren) in
                print("\(directory) \(toSubFolder) \(isExclude)")
                var dest = DeviceCopyDestination.new((directory, toSubFolder))
                // on device directory need to be saved into db
                if !self.sourcePathTableDelegate.paths.contains(where: {$0.sourcePath == dest.sourcePath && $0.type == .onDevice }) {
                    // TODO: SAVE DEVICE PATH TO DB
                    if isExclude {
                        let devicePath = ImageDevicePath.exclude(deviceId: self.device.deviceId, path: directory)
                        ModelStore.default.saveDevicePath(file: devicePath)
                        dest = DeviceCopyDestination.from(devicePath)
                    }else{
                        let devicePath = ImageDevicePath.include(deviceId: self.device.deviceId, path: directory, toSubFolder: toSubFolder, manyChildren: hasManyChildren)
                        ModelStore.default.saveDevicePath(file: devicePath)
                        dest = DeviceCopyDestination.from(devicePath)
                    }
                    self.paths.append(dest)
                    self.sourcePathTableDelegate.paths.append(dest)
                    
                    self.deviceFiles_filtered[dest.sourcePath] = []
                    self.deviceFiles_fulllist[dest.sourcePath] = []
                    
                    self.tblSourcePath.reloadData()
                }
                self.addOnDeviceDirectoryPopover?.close()
            })
            //self.addLocalDirectoryViewController.viewInit()
            self.addLocalDirectoryViewController.view.frame = frame
            
            myPopover!.contentViewController = self.addLocalDirectoryViewController
            //myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            //myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.addOnDeviceDirectoryPopover = myPopover
    }
    
    // MARK: POPOVER - LOCAL DIRECTORY
    
    fileprivate func createLocalDirectoryPopover(){
        var myPopover = self.addLocalDirectoryPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 750, height: 390))
            
            let directoryViewDelegate = LocalDirectoryViewDelegate()
            self.addLocalDirectoryViewController = AddLocalDirectoryViewController(directoryViewDelegate: directoryViewDelegate,
                                                                                   deviceType: self.device.type,
                                                                                   destinationType: .localDirectory,
                                                                                   onApply: { (directory, toSubFolder, isExclude, hasManyChildren) in
                print("\(directory) \(toSubFolder) \(isExclude)")
                let dest = DeviceCopyDestination.local((directory, toSubFolder))
                // local directory no need to be saved into db
                if !self.sourcePathTableDelegate.paths.contains(where: {$0.sourcePath == dest.sourcePath && $0.type == .localDirectory }) {
                    
                    self.paths.append(dest)
                    self.sourcePathTableDelegate.paths.append(dest)
                    
                    self.deviceFiles_filtered[dest.sourcePath] = []
                    self.deviceFiles_fulllist[dest.sourcePath] = []
                    
                    self.tblSourcePath.reloadData()
                }
                
                self.addLocalDirectoryPopover?.close()
            })
            //self.addLocalDirectoryViewController.viewInit()
            self.addLocalDirectoryViewController.view.frame = frame
            
            myPopover!.contentViewController = self.addLocalDirectoryViewController
            //myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            //myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.addLocalDirectoryPopover = myPopover
    }
    
}

// MARK: SOURCE PATH TABLE

protocol DeviceSourcePathSelectionDelegate {
    func selectDeviceSourcePath(path:DeviceCopyDestination)
}

// MARK: SOURCE PATH - CLICK ACTION
extension DeviceCopyViewController : DeviceSourcePathSelectionDelegate {
    
    func selectDeviceSourcePath(path: DeviceCopyDestination) {
        selectedPath = path
        print("SELECTED \(path.sourcePath) - \(path.toSubFolder) - \(path.type)")
        self.refreshFileList()
    }
}

class DeviceSourcePathTableDelegate : NSObject {
    var paths:[DeviceCopyDestination] = []
    
    var sourcePathSelectionDelegate : DeviceSourcePathSelectionDelegate?
    var lastSelectedRow:Int?{
        didSet {
            if lastSelectedRow != nil && paths.count > 0 && lastSelectedRow! < paths.count {
                
                if self.sourcePathSelectionDelegate != nil {
                    let dest = paths[lastSelectedRow!]
                    if dest.type == .localDirectory {
                        self.sourcePathSelectionDelegate?.selectDeviceSourcePath(path: paths[lastSelectedRow!])
                    }else if dest.type == .onDevice {
                        self.sourcePathSelectionDelegate?.selectDeviceSourcePath(path: paths[lastSelectedRow!])
                    }
                }
            }
        }
    }
    
}

extension DeviceSourcePathTableDelegate : NSTableViewDelegate {
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.paths.count - 1) {
            return nil
        }
        let info:DeviceCopyDestination = self.paths[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("path"):
                value = info.sourcePath
            case NSUserInterfaceItemIdentifier("destination"):
                value = info.toSubFolder
            case NSUserInterfaceItemIdentifier("exclude"):
                if info.exclude {
                    value = "X"
                }else{
                    value = ""
                }
            case NSUserInterfaceItemIdentifier("manyChildren"):
                if info.manyChildren {
                    value = "MC"
                }else{
                    value = ""
                }
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = NSParagraphStyle.LineBreakMode.byWordWrapping
            if row == tableView.selectedRow {
                lastSelectedRow = row
            } else {
                lastSelectedRow = nil
            }
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
//        rowView.backgroundColor = row % 2 == 1
//            ? NSColor.white
//            : NSColor.lightGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
}

extension DeviceSourcePathTableDelegate : NSTableViewDataSource {
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.paths.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}

// MARK: FILE LIST TABLE

class DeviceFileTableDelegate : NSObject {
    var files:[PhoneFile] = []
    var lastSelectedRow:Int?
}

extension DeviceFileTableDelegate : NSTableViewDelegate {
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.files.count - 1) {
            return nil
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSize = 3
        
        let info:PhoneFile = self.files[row]
        var value = ""
        var column = ""
        var numberCell = false
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("filename"):
                value = info.filename
            case NSUserInterfaceItemIdentifier("subFolder"):
                value = info.folder
            case NSUserInterfaceItemIdentifier("fileMD5"):
                value = info.fileMD5
            case NSUserInterfaceItemIdentifier("fileSize"):
                value = info.fileSize != "" ? numberFormatter.string(from: info.fileSize.numberValue ?? -1 ) ?? info.fileSize : ""
                numberCell = true
            case NSUserInterfaceItemIdentifier("fileDateTime"):
                value = info.fileDateTime
            case NSUserInterfaceItemIdentifier("previousMD5"):
                value = info.storedMD5
            case NSUserInterfaceItemIdentifier("previousSize"):
                value = info.storedSize != "" ? numberFormatter.string(from: info.storedSize.numberValue ?? -1 ) ?? info.storedSize : ""
                numberCell = true
            case NSUserInterfaceItemIdentifier("previousDateTime"):
                value = info.storedDateTime
            case NSUserInterfaceItemIdentifier("copyState"):
                column = "copyState"
                if info.checksumMode == .Rough {
                    value = info.stored && info.matchedWithoutMD5 ? "Copied" : "NEW"
                }else{
                    value = info.stored && info.matched ? "Copied" : "NEW"
                }
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = NSParagraphStyle.LineBreakMode.byWordWrapping
            if numberCell {
                colView.textField?.alignment = .right
            }
            if row == tableView.selectedRow {
                lastSelectedRow = row
            } else {
                lastSelectedRow = nil
            }
            if column == "copyState" {
                if value == "Copied" {
                    colView.textField?.textColor = NSColor.lightGray
                }else{
                    colView.textField?.textColor = NSColor.green
                }
            }
            
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
//        rowView.backgroundColor = row % 2 == 1
//            ? NSColor.white
//            : NSColor.lightGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
}

extension DeviceFileTableDelegate : NSTableViewDataSource {
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.files.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}
