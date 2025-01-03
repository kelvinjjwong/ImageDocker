//
//  DeviceCopyViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory
import SharedDeviceLib
import IPhoneDeviceReader
import AndroidDeviceReader

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
    var data:ImageDevicePath? = nil
    
    static func new(_ pair:(String, String)) -> DeviceCopyDestination {
        return DeviceCopyDestination(sourcePath: pair.0, toSubFolder: pair.1, type:.onDevice, exclude: false, manyChildren: false, data: nil)
    }
    
    static func local(_ pair:(String, String)) -> DeviceCopyDestination {
        return DeviceCopyDestination(sourcePath: pair.0, toSubFolder: pair.1, type:.localDirectory, exclude: false, manyChildren: false, data: nil)
    }
    
    static func from(_ devicePath: ImageDevicePath) -> DeviceCopyDestination {
        return DeviceCopyDestination(sourcePath: devicePath.path,
                                     toSubFolder: devicePath.toSubFolder,
                                     type:.onDevice,
                                     exclude: devicePath.exclude,
                                     manyChildren: devicePath.manyChildren,
                                     data: devicePath
                                    )
    }
    
    static func from(_ devicePaths: [ImageDevicePath]) -> [DeviceCopyDestination] {
        var result:[DeviceCopyDestination] = []
        for devicePath in devicePaths {
            result.append(DeviceCopyDestination.from(devicePath))
        }
        return result
    }
    
    static func from(deviceId: String, deviceType: MobileType = .Android) -> [DeviceCopyDestination] {
        let devicePaths = DeviceDao.default.getDevicePaths(deviceId: deviceId, deviceType: deviceType)
        return DeviceCopyDestination.from(devicePaths)
    }
}

class DeviceCopyViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "DEVICE", subCategory: "COPY")
    
    let dateFormatter = DateFormatter()
    
    //let mountpoint = PreferencesController.iosDeviceMountPoint()
    
    // MARK: ENVIRONMENT
    var device:PhoneDevice = PhoneDevice(type: .Android, deviceId: "", manufacture: "", model: "")
    
    var deviceFiles_fulllist:[String : [PhoneFile]] = [:]
    var deviceFiles_filtered:[String : [PhoneFile]] = [:]
    
    var paths:[DeviceCopyDestination] = []
    
    var selectedPath:DeviceCopyDestination? = nil
    
    var connected = false
    
    // MARK: CONTROLS
    
    @IBOutlet weak var lblRepositoryName: NSTextField!
    @IBOutlet weak var lblStoragePath: NSTextField!
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
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var btnDeepLoad: NSButton!
    @IBOutlet weak var btnStop: NSButton!
    @IBOutlet weak var btnGotoStorage: NSButton!
    @IBOutlet weak var lblModel: NSTextField!
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblStorage: NSTextField!
    @IBOutlet weak var lblModelName: NSTextField!
    
    @IBOutlet weak var btnBulkUpdate: NSButton!
    
    
    
    // MARK: POPOVER
    var addLocalDirectoryPopover:NSPopover?
    var addLocalDirectoryViewController:AddLocalDirectoryViewController!
    var addOnDeviceDirectoryPopover:NSPopover?
    
    var devicePathPopover:NSPopover?
    var devicePathViewController:DevicePathDetailViewController!
    
    // MARK: TABLE DELEGATES
    
    let sourcePathTableDelegate:DeviceSourcePathTableDelegate = DeviceSourcePathTableDelegate()
    let fileTableDelegate:DeviceFileTableDelegate = DeviceFileTableDelegate()
    
    
    
    // MARK: - INIT
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnCopy.title = Words.device_copy_files.word()
        self.btnLoad.title = Words.device_load_file_list.word()
        self.btnDeepLoad.title = Words.device_deep_load.word()
        self.btnDeleteRecords.title = Words.device_delete_records.word()
        self.btnUpdateRepository.title = Words.device_copy_to_repository.word()
        self.btnDeleteRecords.title = Words.device_delete_records.word()
        self.btnSave.title = Words.device_save.word()
        self.btnStop.title = Words.device_stop.word()
        self.btnMount.title = Words.device_mount.word()
        self.btnLoadFromLocal.title = Words.device_local.word()
        self.cbShowCopied.title = Words.device_show_copied.word()
        self.lblModelName.stringValue = Words.device_model.word()
        self.lblName.stringValue = Words.device_name.word()
        self.lblStorage.stringValue = Words.device_raw_folder.word()
        
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
        
        self.tblSourcePath.action = #selector(onSourcePathTableClicked)
        
        btnStop.isHidden = true
    }
    
    @objc func onSourcePathTableClicked() {
//        self.logger.log(.trace, "row \(tblSourcePath.clickedRow), col \(tblSourcePath.clickedColumn) clicked")
        if sourcePathTableDelegate.paths.count > 0 && tblSourcePath.clickedRow < paths.count && tblSourcePath.clickedRow >= 0 && tblSourcePath.clickedColumn >= 0 {
            let devicePath = paths[tblSourcePath.clickedRow]
            if let data = devicePath.data {
                self.createDevicePathDetailPopover()
                self.devicePathPopover?.close()
                self.devicePathViewController.initView(data, repository: self.repository!) 
                let rect = self.tblSourcePath.rect(ofRow: tblSourcePath.clickedRow)
                let cellRect = NSMakeRect(5, 255-rect.origin.y, 100, 100)
                self.devicePathPopover?.show(relativeTo: cellRect, of: self.view, preferredEdge: .minX)
                
            }else{
//                self.logger.log(.trace, "CLICKED, NO DATA")
            }
        }
    }
    var deviceConnectivityTimer:Timer?
    var repository:ImageRepository?
    
    func viewInit(device:PhoneDevice, repository: ImageRepository){
        self.repository = repository
        if device.deviceId != self.device.deviceId {
//            self.logger.log(.trace, "DEVICE INIT")
//            self.logger.log(.trace, "DIFFERENT DEVICE \(device.deviceId) != \(self.device.deviceId)")
            self.device = device
            
            self.btnUpdateRepository.isEnabled = true
            
            self.btnCopy.isEnabled = false
            self.btnLoad.isEnabled = false
            self.btnDeepLoad.isEnabled = false
            
            self.btnDeleteRecords.isHidden = true
            self.btnBulkUpdate.isHidden = true
            
            self.connected = DeviceBridge.isConnected(deviceId: device.deviceId)
            
            self.deviceConnectivityTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block:{_ in
                DispatchQueue.global().async {
                    if DeviceBridge.isConnected(deviceId: device.deviceId) {
                        DispatchQueue.main.async {
                            self.btnCopy.isEnabled = true
                            self.btnLoad.isEnabled = true
                            self.btnDeepLoad.isEnabled = true
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.btnCopy.isEnabled = false
                            self.btnLoad.isEnabled = false
                            self.btnDeepLoad.isEnabled = false
                        }
                    }
                }})
            
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
            
            let marketName = Naming.Camera.getMarketName(maker: device.manufacture, model: device.model)
            var marketDisplayName = ""
            if marketName != "" {
                marketDisplayName = " (\(marketName))"
            }
            
            let imageDevice = DeviceDao.default.getOrCreateDevice(device: device)
            
            self.lblModel.stringValue = "\(imageDevice.manufacture ?? "") \(imageDevice.model ?? "")\(marketDisplayName)"
            
            if let repository = self.repository {
                self.lblRepositoryName.stringValue = repository.name
                self.lblStoragePath.stringValue = "\(repository.storageVolume)\(repository.storagePath)"
            }else{
                self.lblRepositoryName.stringValue = imageDevice.name ?? imageDevice.marketName ?? imageDevice.deviceId ?? ""
                self.lblStoragePath.stringValue = ""
            }
            
            self.addOnDeviceDirectoryPopover = nil
            
            if device.type == .Android {
                self.paths = DeviceCopyDestination.from(deviceId: device.deviceId)
                self.emptyFileLists(paths: paths)
                self.sourcePathTableDelegate.paths = paths
                self.tblSourcePath.reloadData()
                
                
            }else if device.type == .iPhone {
                if IPHONE.bridge.mounted(path: Setting.localEnvironment.iosDeviceMountPoint()) {
                    self.btnMount.title = Words.device_unmount.word()
                    self.paths = DeviceCopyDestination.from(deviceId: device.deviceId, deviceType: .iPhone)
                    self.emptyFileLists(paths: paths)
                    self.sourcePathTableDelegate.paths = paths
                    self.tblSourcePath.reloadData()
                }else{
                    self.btnMount.title = Words.device_mount.word()
                    self.emptyFileLists(paths: paths)
                    self.paths = []
                    self.sourcePathTableDelegate.paths = paths
                    self.tblSourcePath.reloadData()
                }
            }
            self.fileTableDelegate.files = []
            self.tblFiles.reloadData()
        }else{
            logger.log("SAME DEVICE \(device.deviceId) == \(self.device.deviceId)")
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
    
    // MARK: - GET FILE LIST
    
    func getFileFullList(from path:DeviceCopyDestination, reloadFileList:Bool = false) -> [PhoneFile]{
        self.logger.log(.trace, "getFileFullList from \(path.sourcePath)")
//        self.logger.log(.trace, "GET FULL LIST FROM \(path)")
        if self.deviceFiles_fulllist[path.sourcePath] == nil {
//            self.logger.log(.trace, "nil, return empty")
            self.deviceFiles_fulllist[path.sourcePath] = []
            return []
        }else{
            if self.deviceFiles_fulllist[path.sourcePath]!.count == 0 {
//                self.logger.log(.trace, "not nil but zero count, load from path")
                let excludePaths:[String] = self.getExcludedPaths()
                self.loadFromPath(path: path, reloadFileList:reloadFileList, excludePaths: excludePaths)
            }
        }
        // not nil and has count
        return self.deviceFiles_fulllist[path.sourcePath]!
    }
    
    func getFileFilteredList(from path:DeviceCopyDestination, reloadFileList:Bool = false) -> [PhoneFile]{
        self.logger.log(.trace, "getFileFilteredList from \(path.sourcePath)")
        if self.deviceFiles_fulllist[path.sourcePath] == nil {
            return []
        }
        if self.deviceFiles_fulllist[path.sourcePath] != nil && self.deviceFiles_fulllist[path.sourcePath]!.count == 0 {
            let excludePaths:[String] = self.getExcludedPaths()
            self.loadFromPath(path: path, reloadFileList:reloadFileList, excludePaths: excludePaths)
        }
        return self.deviceFiles_filtered[path.sourcePath]!
    }
    
    // MARK: - LOAD FROM PATH
    
    fileprivate func loadFromLocalPath(path:String, pretendPath:String, reloadFileList:Bool = false, checksumMode:ChecksumMode = .Rough) {
//        self.logger.log(.trace, "LOAD FROM LOCAL \(path) - \(pretendPath)")
        
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
                let importedFile:ImageDeviceFile? = DeviceDao.default.getImportedFile(deviceId: self.device.deviceId, file: f)
                if let deviceFile = importedFile {
//                    self.logger.log(.trace, "IMPORTED \(f.filename)")
                    f.storedMD5 = deviceFile.fileMD5 ?? ""
                    f.storedSize = deviceFile.fileSize ?? ""
                    f.storedDateTime = deviceFile.fileDateTime ?? ""
                    f.importDate = deviceFile.importDate ?? ""
                    f.importToPath = deviceFile.localFilePath ?? "" // FIXME:
                    f.importAsFilename = deviceFile.importAsFilename ?? ""
                    
                    f.deviceFile = deviceFile
                }else{
//                    self.logger.log(.trace, "NOT IMPORTED \(f.filename)")
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
    
    fileprivate func loadFromOnDevicePath(path:String, devicePath:ImageDevicePath?, reloadFileList:Bool = false, checksumMode:ChecksumMode = .Rough, excludePaths:[String]){
        
        DispatchQueue.main.async {
            self.deviceFiles_filtered[path] = []
            self.deviceFiles_fulllist[path] = []
        }
        var files:[PhoneFile] = []
        if self.device.type == .Android {
            if DeviceBridge.Android().exists(device: self.device.deviceId, path: path) {
                files = DeviceBridge.Android().files(device: self.device.deviceId, in: path)
            }else{
//                self.logger.log(.trace, "NOT EXISTS PATH ON DEVICE \(path)")
            }
        }else{
            files = IPHONE.bridge.files(mountPoint: Setting.localEnvironment.iosDeviceMountPoint(), in: path)
        }
        guard files.count > 0 else {
//            self.logger.log(.trace, "NO FILE FOUND in \(path)")
//            DispatchQueue.main.async {
//                self.lblProgressMessage.stringValue = "No file found in \(path)"
//            }
            return
        }
        let total = files.count
        DispatchQueue.main.async {
            self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
        }
        for file in files {
            
            guard !self.forceStop else {
                break
            }
            var shouldExclude = false
            for excludePath in excludePaths {
                if file.path.starts(with: excludePath.withLastStash()) {
                    shouldExclude = true
                }
            }
            if shouldExclude {
                continue
            }
            let deviceFile = DeviceDao.default.getOrCreateDeviceFile(deviceId: self.device.deviceId, file: file)
            var f = file
            if deviceFile.importAsFilename != "" {
                f.storedMD5 = deviceFile.fileMD5 ?? ""
                f.storedSize = deviceFile.fileSize ?? ""
                f.storedDateTime = deviceFile.fileDateTime ?? ""
            }
            
            f.importDate = deviceFile.importDate ?? ""
            f.importToPath = deviceFile.localFilePath ?? "" // FIXME:
            f.importAsFilename = deviceFile.importAsFilename ?? "" // trigger compare
            
            f.deviceFile = deviceFile
            
            f.checksumMode = checksumMode
            
            if checksumMode == .Rough {
                if (f.stored && !f.matchedWithoutMD5){
//                    self.logger.log(.trace, "Getting MD5 of \(f.path)")
                    f.fileMD5 = DeviceBridge.Android().md5(device: self.device.deviceId, fileWithPath: f.path)
                }
            }else if checksumMode == .Deep {
                if (f.stored && !f.matched){
//                    self.logger.log(.trace, "Getting MD5 of \(f.path)")
                    f.fileMD5 = DeviceBridge.Android().md5(device: self.device.deviceId, fileWithPath: f.path)
                }
            }
            
            if deviceFile.devicePathId == "" {
                // new record, need save
                deviceFile.fileMD5 = f.fileMD5
                if let devicePath = devicePath {
                    deviceFile.devicePathId = devicePath.id
                }
                DeviceDao.default.saveDeviceFile(file: deviceFile)
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
        }// end of file loop
        self.forceStop = false
        // Enable "Copy Files" button if any path includes new file(s)
        DispatchQueue.main.async {
            if self.deviceFiles_filtered[path]!.count > 0 {
                self.btnCopy.isEnabled = true
            }
            if reloadFileList {
//                self.logger.log(.trace, "RELOAD")
                self.tblFiles.reloadData()
            }
        }
    }
    
    func loadFromPath(path: DeviceCopyDestination, reloadFileList:Bool = false, checksumMode:ChecksumMode = .Rough, excludePaths:[String]) {
        
        if path.type == .onDevice {
            loadFromOnDevicePath(path: path.sourcePath, devicePath: path.data, reloadFileList: reloadFileList, checksumMode: checksumMode, excludePaths: excludePaths)
        }else if path.type == .localDirectory {
            loadFromLocalPath(path: path.sourcePath, pretendPath: path.toSubFolder, reloadFileList:reloadFileList)
        }
    }
    
    func refreshFileList(){
        if !self.connected {
            return
        }
        if let selectedPath = self.selectedPath {
            let state = self.cbShowCopied.state == .on
            
            self.lblMessage.stringValue = "Loading from: \(selectedPath.sourcePath)"
        
            DispatchQueue.global().async {
                self.fileTableDelegate.files = state ? self.getFileFullList(from: selectedPath, reloadFileList: true) : self.getFileFilteredList(from: selectedPath, reloadFileList: true)
                
                DispatchQueue.main.async {
                    self.tblFiles.reloadData()
                    self.toggleSpecialButtons()
                }
            }
        }
    }
    
    // MARK: - ACTION BUTTON - OPEN PANEL
    
    @IBAction func onGotoRawClicked(_ sender: NSButton) {
        guard self.lblStoragePath.stringValue != "" else {return}
        
        let url = URL(fileURLWithPath: self.lblStoragePath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onMountClicked(_ sender: NSButton) {
//        self.logger.log(self.device)
        if self.device.type == .iPhone {
//            self.logger.log(self.btnMount.title)
            let mountpoint = Setting.localEnvironment.iosDeviceMountPoint()
            if self.btnMount.title == Words.device_mount.word() {
//                self.logger.log(.trace, "INVOKE MOUNT")
                IPHONE.bridge.unmount(path: mountpoint)
                if IPHONE.bridge.mount(path: mountpoint) {
//                    self.logger.log(.trace, "JUST MOUNTED")
                    self.btnMount.title = Words.device_unmount.word()
                    
                    self.paths = [
                        DeviceCopyDestination.new(("/DCIM/", "Camera"))
                    ]
                    self.emptyFileLists(paths: paths)
                    self.sourcePathTableDelegate.paths = paths
                    self.tblSourcePath.reloadData()
                    
                }else{
//                    self.logger.log(.trace, "UNABLE TO MOUNT IPHONE")
                }
            }else {
//                self.logger.log(.trace, "INVOKE UNMOUNT")
                // Unmount
                IPHONE.bridge.unmount(path: mountpoint)
                self.btnMount.title = Words.device_mount.word()
                
                self.emptyFileLists(paths: paths)
                self.paths = []
                self.sourcePathTableDelegate.paths = paths
                self.tblSourcePath.reloadData()
            }
        }else{
//            self.logger.log(.trace, "NOT IPHONE")
            self.btnMount.isHidden = true
            self.btnMount.isEnabled = false
        }
    }
    
    
    
    // MARK: - TOGGLE BUTTONS
    
    fileprivate func toggleControls(state:Bool) {
        DispatchQueue.main.async {
            self.btnMount.isEnabled = state
            self.btnCopy.isEnabled = state
            self.btnLoad.isEnabled = state
            self.btnDeepLoad.isEnabled = state
            self.btnSave.isEnabled = state
            self.btnAddSourcePath.isEnabled = state
            self.btnRemoveSourcePath.isEnabled = state
            self.btnLoadFromLocal.isEnabled = state
            self.btnDeleteRecords.isEnabled = state
            self.btnUpdateRepository.isEnabled = state
            self.cbShowCopied.isEnabled = state
            self.tblSourcePath.isEnabled = state
            self.btnStop.isHidden = state
        }
    }
    
    fileprivate func disableButtons(){
        self.toggleControls(state: false)
    }
    
    fileprivate func enableButtons() {
        self.toggleControls(state: true)
    }
    
    // MARK: - VALID PATHS
    
    fileprivate func validPaths() -> Bool {
        
        self.lblMessage.stringValue = ""
        let storagePath = lblStoragePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if storagePath == "" {
            self.lblMessage.stringValue = "ERROR: Path for Raw Copy should not be empty!"
            return false
        }
        
        if !storagePath.isDirectoryExists() {
            self.lblMessage.stringValue = "ERROR: Path for Raw Copy is not a directory!"
            return false
        }
        return true
    }
    
    
    // MARK: - ACTION BUTTON - SAVE
    
    @IBAction func onSaveClicked(_ sender: NSButton) {
        guard !self.working else {return}
        
        self.working = true
        self.disableButtons()
        
        let marketName = Naming.Camera.getMarketName(maker: device.manufacture, model: device.model)
        
        self.accumulator = Accumulator(target: 1, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
        
        DispatchQueue.global().async {
        
            var imageDevice = DeviceDao.default.getOrCreateDevice(device: self.device)
            
//            if let oldStoragePath = imageDevice.storagePath, oldStoragePath != storagePath {
//                let deviceFiles = DeviceDao.default.getDeviceFiles(deviceId: self.device.deviceId)
//                if deviceFiles.count > 0 {
//                    
//                    self.accumulator?.reset()
//                    self.accumulator?.setTarget(deviceFiles.count)
// 
//                    for deviceFile in deviceFiles {
//                        
//                        // IF storage path changed, MOVE files from old path to new path
//                        if let oldImportToPath = deviceFile.importToPath, let filename = deviceFile.filename, let localFilePath = deviceFile.localFilePath, localFilePath != "" {
//                            
//                            DispatchQueue.main.async {
//                                self.lblMessage.stringValue = "Updating new RAW storage: \(localFilePath)"
//                            }
//                            
//                            let oldFilePath = URL(fileURLWithPath: oldImportToPath).appendingPathComponent(filename)
//                            let newFilePath = URL(fileURLWithPath: storagePath).appendingPathComponent(localFilePath)
//                            let newFolderPath = newFilePath.deletingLastPathComponent()
//                            if !newFilePath.path.isFileExists() {
//                                
//                                DispatchQueue.main.async {
//                                    self.lblMessage.stringValue = "Copying to new RAW storage: \(localFilePath)"
//                                }
//                                
//                                do {
//                                    try FileManager.default.createDirectory(at: newFolderPath, withIntermediateDirectories: true, attributes: nil)
//                                }catch{
//                                    self.logger.log(.trace, "Error occured when trying to create folder \(newFolderPath.path)", error)
//                                }
//                                do {
//                                    try FileManager.default.copyItem(atPath: oldFilePath.path, toPath: newFilePath.path)
//                                }catch{
//                                    self.logger.log(.trace, "Error occured when trying to copy [\(oldFilePath.path)] to [\(newFilePath.path)]", error)
//                                }
//                            }
//                            var file = deviceFile
//                            file.importToPath = newFolderPath.path
////                            self.logger.log(.trace, "Update [\(localFilePath)] with new importToPath: \(newFolderPath.path)")
//                            let _ = DeviceDao.default.saveDeviceFile(file: file)
//                        }
//                        
//                        DispatchQueue.main.async {
//                            let _ = self.accumulator?.add("")
//                        }
//                    }
//                }
//            }
//        
//            if let oldRepositoryPath = imageDevice.repositoryPath, oldRepositoryPath != repositoryPath {
//                let deviceFiles = DeviceDao.default.getDeviceFiles(deviceId: self.device.deviceId)
//                if deviceFiles.count > 0 {
//                    
//                    self.accumulator?.reset()
//                    self.accumulator?.setTarget(deviceFiles.count)
//                    
//                    for deviceFile in deviceFiles {
//                        
//                        // IF repository path changed, MOVE files from old path to new path
//                        
//                        if let localFilePath = deviceFile.localFilePath, localFilePath != "" {
//                            
//                            DispatchQueue.main.async {
//                                self.lblMessage.stringValue = "Updating new repository: \(localFilePath)"
//                            }
//                            
//                            let oldFilePath = URL(fileURLWithPath: oldRepositoryPath).appendingPathComponent(localFilePath)
//                            let newFilePath = URL(fileURLWithPath: repositoryPath).appendingPathComponent(localFilePath)
//                            let newFolderPath = newFilePath.deletingLastPathComponent()
//                            if !newFilePath.path.isFileExists() {
//                                
//                                DispatchQueue.main.async {
//                                    self.lblMessage.stringValue = "Copying to new repository: \(localFilePath)"
//                                }
//                                
//                                do {
//                                    try FileManager.default.createDirectory(at: newFolderPath, withIntermediateDirectories: true, attributes: nil)
//                                }catch{
//                                    self.logger.log(.trace, "Error occured when trying to create folder \(newFolderPath.path)", error)
//                                }
//                                do {
//                                    try FileManager.default.copyItem(atPath: oldFilePath.path, toPath: newFilePath.path)
//                                }catch{
//                                    self.logger.log(.trace, "Error occured when trying to copy [\(oldFilePath.path)] to [\(newFilePath.path)]", error)
//                                }
//                            }
//                        }
//                        
//                        DispatchQueue.main.async {
//                            let _ = self.accumulator?.add("")
//                        }
//                    }
//                }
//            }
            
            imageDevice.name = self.lblRepositoryName.stringValue
            imageDevice.marketName = marketName
            let _ = DeviceDao.default.saveDevice(device: imageDevice)
            
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
        if Alert.dialogOKCancel(question: "DELETE DEVICE FILE RECORDS", text: "Do you confirm to delete all device file imported recoreds?") {
            self.logger.log(.trace, "proceed delete")
            self.lblMessage.stringValue = "Deleting records ..."
            let _ = DeviceDao.default.deleteDeviceFiles(deviceId: self.device.deviceId)
            self.lblMessage.stringValue = "Deleted records."
        }
        
    }
    
    // MARK: - ACTION BUTTON - LOAD FILE LIST
    
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
        self.forceStop = false
        if paths.count > 0 {
            self.disableButtons()
            
            let excludePaths:[String] = self.getExcludedPaths()
            
            DispatchQueue.main.async {
                self.lblMessage.stringValue = "Loading file list ..."
            }
            
            DispatchQueue.global().async {
                for path in self.paths {
                    
                    guard !self.forceStop else {
                        break
                    }
                    if !path.exclude {
                        DispatchQueue.main.async {
                            self.lblMessage.stringValue = "Loading from: \(path.sourcePath)"
                        }
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
        let msg = "TOTAL: \(sumOfFulllist), NEW: \(sumOfFiltered)\(timeRange)"
        self.lblMessage.stringValue = msg
//        self.logger.log(msg)
        
        if sumOfFiltered == 0 {
            self.btnCopy.isEnabled = false
        }
        
    }
    
    @IBAction func onLoadClicked(_ sender: NSButton) {
        self.reloadFileList()
    }
    
    @IBAction func onDeepLoadClicked(_ sender: NSButton) {
        self.reloadFileList(checksumMode: .Deep)
    }
    
    
    // MARK: - COUNT FILE LIST
    
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
    
    // MARK: - ACTION BUTTON - STOP COPY
    
    @IBAction func onStopClicked(_ sender: NSButton) {
        self.forceStop = true
    }
    
    
    // MARK: - ACTION BUTTON - COPY FILES
    
    fileprivate var forceStop = false
    fileprivate var working = false
    fileprivate var accumulator:Accumulator?
    
    // COPY button
    @IBAction func onCopyClicked(_ sender: NSButton) {
        guard !working && self.validPaths() else {return}
        
        if self.repository == nil {
            return
        }
        let repository = self.repository!
        
        var total = 0
        for path in self.paths {
            if path.exclude {
                continue
            }
//            self.logger.log(.trace, "TO BE COPIED: \(path.sourcePath) - \(self.deviceFiles_filtered[path.sourcePath]!.count)")
            total += self.deviceFiles_filtered[path.sourcePath]!.count
        }
//        self.logger.log(.trace, "TO BE COPIED: \(total)")
        guard total > 0 else {return}
        self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
        
        // major folder is store path
        let destination = "\(repository.storageVolume)\(repository.storagePath)"
        
        self.forceStop = false
        self.working = true
        self.disableButtons()
        
        let computerFileHandler = ComputerFileManager()
        
        DispatchQueue.global().async {
            let now = Date()
            let date = self.dateFormatter.string(from: now)
            for path in self.paths {
                
                guard !self.forceStop else {
                    break
                }
                
                if path.exclude {
                    continue
                }
                
                // subFolder
                var subFolder = path.toSubFolder
                if path.type == .localDirectory {
                    // PRETEND AS ON DEVICE PATH
                    if let onDevicePath = self.paths.first(where: {$0.sourcePath == path.toSubFolder && $0.type == .onDevice}) {
                        subFolder = onDevicePath.toSubFolder
                    }
                }
                
                // storePath + subFolder
                var destinationPath = URL(fileURLWithPath: destination).appendingPathComponent(subFolder).path
                if !destinationPath.isFileExists() {
                    let (created, error) = destinationPath.mkdirs(logger: self.logger)
                    if !created {
                        destinationPath = destination
                    }
                }
                
                // loop files
                for file in self.deviceFiles_filtered[path.sourcePath]! {
                    
                    guard !self.forceStop else {
                        break
                    }
                    
                    var destinationPathForFile = destinationPath
                    var localFilePath = "\(subFolder.withLastStash())\(file.filename)"
                    if file.folder != "" {
                        
                        // subFolder + deviceFolder + filename
                        localFilePath = "\(subFolder.withLastStash())\(file.folder.withLastStash())\(file.filename)"
                        
                        // storePath + subFolder + deviceFolder
                        destinationPathForFile = URL(fileURLWithPath: destinationPath).appendingPathComponent(file.folder).path
                        
                        if !destinationPathForFile.isFileExists() {
                            let (created, error) = destinationPathForFile.mkdirs(logger: self.logger)
                            if !created {
                                destinationPathForFile = destinationPath
                            }
                        }
                    }
                    
                    // notify UI
                    DispatchQueue.main.async {
                        if file.folder != "" {
                            self.lblMessage.stringValue = "Copying from device: \(subFolder)/\(file.folder)/\(file.filename)"
                        }else{
                            self.lblMessage.stringValue = "Copying from device: \(subFolder)/\(file.filename)"
                        }
                    }
                    
                    // link to database object
                    var deviceFile = file.deviceFile as! ImageDeviceFile
                    
                    // copy/pull file from device to disk physically
                    if path.type == .onDevice {
                        if self.device.type == .Android {
                            let (result, error) = DeviceBridge.Android().pull(device: self.device.deviceId, from: file.path, to: destinationPathForFile)
                            if result && error == nil {
//                                self.logger.log(.trace, "Copied \(file.path)")
                                deviceFile.localFilePath = localFilePath
//                                    deviceFile.importToPath = destinationPathForFile
                                deviceFile.importAsFilename = file.filename
                                deviceFile.importDate = date
                                deviceFile.repositoryId = self.repository!.id
                                let _ = DeviceDao.default.saveDeviceFile(file: deviceFile)
//                                    self.logger.log(.trace, "Updated \(file.path)")
                            }else{
//                                self.logger.log(.trace, "Failed to copy \(file.path)")
                                if let err = error {
                                    if err.localizedDescription.range(of: "device '\(self.device.deviceId)' not found") != nil {
                                        self.forceStop = true
                                        DispatchQueue.main.async {
                                            self.lblMessage.stringValue = "Device disconnected accidentially."
                                        }
                                    }
                                }
                            }
                        }else if self.device.type == .iPhone {
                            if IPHONE.bridge.pull(mountPoint: Setting.localEnvironment.iosDeviceMountPoint(), sourcePath:path.sourcePath, from: file.path, to: destinationPathForFile) {
//                                self.logger.log(.trace, "Copied \(file.path)")
                                deviceFile.localFilePath = localFilePath
//                                    deviceFile.importToPath = destinationPathForFile
                                deviceFile.importAsFilename = file.filename
                                deviceFile.importDate = date
                                deviceFile.repositoryId = self.repository!.id
                                let _ = DeviceDao.default.saveDeviceFile(file: deviceFile)
//                                    self.logger.log(.trace, "Updated \(file.path)")
                            }else{
//                                self.logger.log(.trace, "Failed to copy \(file.path)")
                            }
                        }
                    } else if path.type == .localDirectory {
//                        self.logger.log(.trace, "COPYING LOCAL \(file.onDevicePath)")
                        
                        var needSaveFile:Bool = false
                        let destinationFile = URL(fileURLWithPath: destinationPathForFile).appendingPathComponent(file.filename).path
                        if destinationFile.isFileExists() {
                            // exist file, avoid copy
                            needSaveFile = true
                        }else{ // not exist, copy file
                            let (copied, error) = file.onDevicePath.copyFile(to: destinationFile, logger: self.logger)
                            if copied {
                                needSaveFile = true
                            }else{
                                self.logger.log(.error, "unable to copy file from \(file.onDevicePath) to \(destinationFile) - \(error)")
                            }
                        }
                        if needSaveFile {
                            deviceFile.localFilePath = localFilePath
//                            deviceFile.importToPath = destinationPathForFile
                            deviceFile.importAsFilename = file.filename
                            deviceFile.importDate = date
                            deviceFile.repositoryId = self.repository!.id
                            let _ = DeviceDao.default.saveDeviceFile(file: deviceFile)
//                            self.logger.log(.trace, "Updated \(file.path)")
                        }
                    }
                    
                    // store file path to database
                    self.updateDeviceFileIntoRepository(fileRecord: deviceFile,
                                                        repository: repository,
                                                        fileHandler: computerFileHandler)
                    
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("")
                    }
                } // end of file-loop
            } // end of path-loop
            
            guard !self.forceStop else {
                self.forceStop = false
                self.working = false
                DispatchQueue.main.async {
                    self.enableButtons()
                    self.lblMessage.stringValue = ""
                }
                return
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
        } // end of global async
    }
    
    // MARK: - ACTION BUTTON - UPDATE REPOSITORY
    
    // copy files from raw folder to repository folder if it wasn't copied
    // generate md5 and update field 'md5' if it's null or empty in db
    fileprivate func updateDeviceFileIntoRepository(fileRecord deviceFile:ImageDeviceFile,repository:ImageRepository, fileHandler:ComputerFileManager){
        self.logger.log(.trace, "updateDeviceFileIntoRepository() -> \(deviceFile.localFilePath)")
        
        let storageUrlWithSlash = "\(repository.storageVolume)\(repository.storagePath)".withLastStash()
        let repositoryPath = "\(repository.repositoryVolume)\(repository.repositoryPath)".withLastStash()
        
        var file = deviceFile
        if let path = file.path, let filename = file.filename, let localFilePath = file.localFilePath {
            
            var needSave = false
            
//            var importToPath = importToPath_origin
            
            // fix old version records incorrectly excluded 'subpath' from 'importToPath'
            // e.g,                   when: path=/DCIM/100APPLE/IMG_0106.JPG
            //                        then:
            //          old version importToPath=/Volumes/Mac Drive/MacStorage/photo.apple.iphone6/Camera
            //      current version importToPath=/Volumes/Mac Drive/MacStorage/photo.apple.iphone6/Camera/100APPLE
            // so that 'localFilePath' should be=Camera/100APPLE/IMG_0106.JPG
//            if path.starts(with: "/DCIM/") && path.contains("APPLE/") {
//                let appleFolder = path.replacingFirstOccurrence(of: "/DCIM/", with: "").replacingFirstOccurrence(of: "/\(filename)", with: "")
//                importToPath = "\(storageUrlWithSlash)Camera/\(appleFolder)"
//                if importToPath != importToPath_origin {
//                    file.importToPath = importToPath
//                    needSave = true
//                }
//            }
            
            // update field 'localFilePath' if it's null or empty in db
//            let localFilePath = "\(subpath)/\(filename)"
//            if localFilePath != "/" && ( file.localFilePath == nil || file.localFilePath == "" ) {
//                file.localFilePath = localFilePath
//                needSave = true
//            }
            
            DispatchQueue.main.async {
                self.lblMessage.stringValue = "Copying into editable folder: \(localFilePath)"
            }
            
            let importedFileUrl = URL(fileURLWithPath: storageUrlWithSlash).appendingPathComponent(localFilePath)
            let repositoryFileUrl = URL(fileURLWithPath: repositoryPath).appendingPathComponent(localFilePath)
            //self.logger.log(repositoryFileUrl.path)
            
            let repositoryFolderUrl = repositoryFileUrl.deletingLastPathComponent()
            do {
                self.logger.log(.trace, "Create editable directoy [\(repositoryFolderUrl)]")
                try FileManager.default.createDirectory(at: repositoryFolderUrl, withIntermediateDirectories: true, attributes: nil)
            }catch{
                logger.log("Error occured when trying to create folder \(repositoryFolderUrl.path)", error)
            }
            // copy files from raw folder to repository folder if it wasn't copied
            if !repositoryFileUrl.path.isFileExists() {
                self.logger.log(.trace, "Copying file from [\(importedFileUrl.path)] to [\(repositoryFileUrl.path)]")
                let (copied, error) = importedFileUrl.path.copyFile(to: repositoryFileUrl.path, logger: self.logger)
                if !copied {
                    logger.log("Error occured when trying to copy file from \(importedFileUrl.path) to \(repositoryFileUrl.path) - \(error)")
                }
            }
            
            // generate md5 and update field 'md5' if it's null or empty in db
            if file.fileMD5 == nil || file.fileMD5 == "" {
                let md5 = fileHandler.md5(pathOfFile: importedFileUrl.path)
                self.logger.log(.trace, "Generated MD5 for [\(importedFileUrl.path)] as [\(md5)]")
                if md5 != "" {
                    file.fileMD5 = md5
                    needSave = true
                }
            }
            if needSave {
                let _ = DeviceDao.default.saveDeviceFile(file: file)
            }
        }
    }
    
    @IBAction func onUpdateRepositoryClicked(_ sender: Any) {
        guard !working && self.validPaths() else {return}
        
        if self.repository == nil {
            return
        }
        let repository = self.repository!
        
        self.forceStop = false
        self.working = true
        
        self.disableButtons()
        
        let deviceFiles = DeviceDao.default.getDeviceFiles(deviceId: self.device.deviceId)
//        self.logger.log(.trace, "device file count: \(deviceFiles.count)")
        if deviceFiles.count > 0 {
            self.accumulator = Accumulator(target: deviceFiles.count, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
            
            let computerFileHandler = ComputerFileManager()
            
            DispatchQueue.global().async {
                for deviceFile in deviceFiles {
                    
                    guard !self.forceStop else {
                        break
                    }
                    
                    self.updateDeviceFileIntoRepository(fileRecord: deviceFile,
                                                        repository: repository,
                                                        fileHandler: computerFileHandler)
                    
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("")
                    }
                }
                self.logger.log(.trace, "Completed copy into editable folder")
                DispatchQueue.main.async {
                    self.lblMessage.stringValue = "Completed copy into editable folder"
                }
                self.forceStop = false
                self.working = false
                self.enableButtons()
            }
        }else{
            self.logger.log(.trace, "No file record could be copied into editable folder.")
            self.lblMessage.stringValue = "No file record could be copied into editable folder."
            self.forceStop = false
            self.working = false
            self.enableButtons()
        }
    }
    
    // MARK: - ACTION BUTTON - CHECKBOX - SHOW COPIED
    
    @IBAction func onCheckboxShowCopiedClicked(_ sender: NSButton) {
        self.refreshFileList()
    }
    
    // MARK: - ACTION BUTTONS - ADD LOCAL DIRECTORY AS SOURCE PATH
    
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
            let _ = DeviceDao.default.deleteDevicePath(deviceId: self.device.deviceId, path: path.sourcePath)
            selectedPath = nil
            tblSourcePath.reloadData()
        }
    }
    
    // for debug only
    @IBAction func onBulkUpdateClicked(_ sender: NSButton) {
    }
    
    // MARK: - POPOVER - DEVICE PATH DETAIL
    fileprivate func createDevicePathDetailPopover(){
        var myPopover = self.devicePathPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 500, height: 300))
            
            self.devicePathViewController = DevicePathDetailViewController()
            self.devicePathViewController.view.frame = frame
            
            myPopover!.contentViewController = self.devicePathViewController
            //myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            //myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.devicePathPopover = myPopover
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
//                self.logger.log(.trace, "\(directory) \(toSubFolder) \(isExclude)")
                var dest = DeviceCopyDestination.new((directory, toSubFolder))
                // on device directory need to be saved into db
                if !self.sourcePathTableDelegate.paths.contains(where: {$0.sourcePath == dest.sourcePath && $0.type == .onDevice }) {
                    // SAVE DEVICE PATH TO DB
                    if isExclude {
                        let devicePath = ImageDevicePath.exclude(deviceId: self.device.deviceId, path: directory)
                        let _ = DeviceDao.default.saveDevicePath(file: devicePath)
                        dest = DeviceCopyDestination.from(devicePath)
                    }else{
                        let devicePath = ImageDevicePath.include(deviceId: self.device.deviceId, path: directory, toSubFolder: toSubFolder, manyChildren: hasManyChildren)
                        let _ = DeviceDao.default.saveDevicePath(file: devicePath)
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
//                self.logger.log(.trace, "\(directory) \(toSubFolder) \(isExclude)")
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

// MARK: - SOURCE PATH TABLE

protocol DeviceSourcePathSelectionDelegate {
    func selectDeviceSourcePath(path:DeviceCopyDestination)
}

// MARK: SOURCE PATH - CLICK ACTION
extension DeviceCopyViewController : DeviceSourcePathSelectionDelegate {
    
    func selectDeviceSourcePath(path: DeviceCopyDestination) {
        selectedPath = path
//        self.logger.log(.trace, "SELECTED \(path.sourcePath) - \(path.toSubFolder) - \(path.type)")
        self.refreshFileList()
        
    }
}

class DeviceSourcePathTableDelegate : NSObject {
    var paths:[DeviceCopyDestination] = []
    var clickAction: ( (_ devicePath:DeviceCopyDestination, _ rowIndex:Int) -> Void )? = nil
    
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
            case NSUserInterfaceItemIdentifier("sourcePath"):
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
            colView.textField?.lineBreakMode = .byWordWrapping
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
        if lastSelectedRow != nil && paths.count > 0 && lastSelectedRow! < paths.count {
            
            
            if clickAction != nil {
//                self.logger.log(.trace, "TRIGGER CLICK ACTION")
                let devicePath = paths[lastSelectedRow!]
                clickAction!(devicePath, lastSelectedRow!)
            }
        }
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
            colView.textField?.lineBreakMode = .byWordWrapping
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
