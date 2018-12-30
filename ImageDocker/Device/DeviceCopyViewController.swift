//
//  DeviceCopyViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

enum DeviceCopyDestinationType:Int {
    case onDevice
    case localDirectory
}

struct DeviceCopyDestination {
    var sourcePath:String
    var toSubFolder:String
    var type:DeviceCopyDestinationType
    
    static func new(_ pair:(String, String)) -> DeviceCopyDestination {
        return DeviceCopyDestination(sourcePath: pair.0, toSubFolder: pair.1, type:.onDevice)
    }
    
    static func local(_ pair:(String, String)) -> DeviceCopyDestination {
        return DeviceCopyDestination(sourcePath: pair.0, toSubFolder: pair.1, type:.localDirectory)
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
        txtStorePath.isEditable = false
        tblSourcePath.isEnabled = true
        
        sourcePathTableDelegate.sourcePathSelectionDelegate = self
        self.tblSourcePath.delegate = sourcePathTableDelegate
        self.tblSourcePath.dataSource = sourcePathTableDelegate
        self.tblFiles.delegate = fileTableDelegate
        self.tblFiles.dataSource = fileTableDelegate
    }
    
    func viewInit(device:PhoneDevice){
        if device.manufacture != self.device.manufacture && device.deviceId != self.device.deviceId && device.model != self.device.model {
            print("DEVICE INIT")
            self.device = device
            
            if device.type == .iPhone {
                self.btnMount.isHidden = false
                self.btnMount.isEnabled = true
            }else{
                self.btnMount.isHidden = true
                self.btnMount.isEnabled = false
            }
            
            let imageDevice = ModelStore.default.getOrCreateDevice(device: device)
            
            self.lblModel.stringValue = "\(imageDevice.manufacture ?? "") \(imageDevice.model ?? "")"
            if imageDevice.name != nil && imageDevice.name != "" {
                self.txtName.stringValue = imageDevice.name ?? ""
            }else{
                self.txtName.stringValue = imageDevice.deviceId ?? ""
            }
            
            if imageDevice.storagePath != nil && imageDevice.storagePath != "" {
                txtStorePath.stringValue = imageDevice.storagePath ?? ""
                btnSave.isEnabled = true
            }
            
            self.addOnDeviceDirectoryPopover = nil
            
            if device.type == .Android {
                self.paths = [
                    DeviceCopyDestination.new(("/sdcard/DCIM/Camera/", "Camera")),
                    DeviceCopyDestination.new(("/sdcard/tencent/MicroMsg/Weixin/", "WeChat")),
                    DeviceCopyDestination.new(("/sdcard/tencent/QQ_Images/", "QQ")),
                    DeviceCopyDestination.new(("/sdcard/tencent/QQ_Video/", "QQ")),
                    DeviceCopyDestination.new(("/sdcard/Snapseed/", "Snapseed")),
                    DeviceCopyDestination.new(("/sdcard/Pictures/Instagram/", "Instagram"))
                    ]
                self.emptyFileLists(paths: paths)
                self.sourcePathTableDelegate.paths = paths
                self.tblSourcePath.reloadData()
                
                
            }else if device.type == .iPhone {
                if IPHONE.bridge.mounted(path: PreferencesController.iosDeviceMountPoint()) {
                    self.btnMount.title = "Unmount"
                    self.paths = [
                        DeviceCopyDestination.new(("/DCIM/", "Camera"))
                    ]
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
            self.loadFromPath(path: path, reloadFileList:reloadFileList)
        }
        return self.deviceFiles_fulllist[path.sourcePath]!
    }
    
    func getFileFilteredList(from path:DeviceCopyDestination, reloadFileList:Bool = false) -> [PhoneFile]{
        if self.deviceFiles_fulllist[path.sourcePath] == nil {
            return []
        }
        if self.deviceFiles_fulllist[path.sourcePath] != nil && self.deviceFiles_fulllist[path.sourcePath]!.count == 0 {
            self.loadFromPath(path: path, reloadFileList:reloadFileList)
        }
        return self.deviceFiles_filtered[path.sourcePath]!
    }
    
    // MARK: LOAD FROM PATH
    
    fileprivate func loadFromLocalPath(path:String, pretendPath:String, reloadFileList:Bool = false) {
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
                    if !(f.stored && f.matched) {
                        self.deviceFiles_filtered[path]!.append(f)
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
    
    fileprivate func loadFromOnDevicePath(path:String, reloadFileList:Bool = false){
        
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
            
            if (f.stored && !f.matched){
                print("Getting MD5 of \(f.path)")
                f.fileMD5 = Android.bridge.md5(device: self.device.deviceId, fileWithPath: f.path)
            }
            
            DispatchQueue.main.async {
                self.deviceFiles_fulllist[path]!.append(f)
                if !(f.stored && f.matched) {
                    self.deviceFiles_filtered[path]!.append(f)
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
    
    func loadFromPath(path: DeviceCopyDestination, reloadFileList:Bool = false) {
        if path.type == .onDevice {
            loadFromOnDevicePath(path: path.sourcePath, reloadFileList: reloadFileList)
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
    
    // MARK: TOOL BUTTON - OPEN PANEL
    
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
    
    
    // MARK: TOOL BUTTON - OK
    
    @IBAction func onSaveClicked(_ sender: NSButton) {
        let name = txtName.stringValue
        let storagePath = txtStorePath.stringValue
        guard storagePath != "" else {return}
        var imageDevice = ModelStore.default.getOrCreateDevice(device: device)
        imageDevice.name = name
        imageDevice.storagePath = storagePath
        ModelStore.default.saveDevice(device: imageDevice)
    }
    
    // MARK: ACTION BUTTON - DELETE RECORDS
    
    @IBAction func onDeleteRecordsClicked(_ sender: NSButton) {
        ModelStore.default.deleteDeviceFiles(deviceId: self.device.deviceId)
    }
    
    // MARK: ACTION BUTTON - LOAD FILE LIST
    
    fileprivate func reloadFileList() {
        if paths.count > 0 {
            btnAddSourcePath.isEnabled = false
            btnRemoveSourcePath.isEnabled = false
            btnLoadFromLocal.isEnabled = false
            tblSourcePath.isEnabled = false
            cbShowCopied.isEnabled = false
            btnLoad.isEnabled = false
            btnDeleteRecords.isEnabled = false
            if self.device.type == .iPhone {
                self.btnMount.isEnabled = false
            }
            DispatchQueue.global().async {
                for path in self.paths {
                    self.loadFromPath(path: path)
                }
                DispatchQueue.main.async {
                    self.btnAddSourcePath.isEnabled = true
                    self.btnRemoveSourcePath.isEnabled = true
                    self.btnLoadFromLocal.isEnabled = true
                    self.tblSourcePath.isEnabled = true
                    self.cbShowCopied.isEnabled = true
                    self.btnLoad.isEnabled = true
                    self.btnDeleteRecords.isEnabled = true
                    if self.device.type == .iPhone {
                        self.btnMount.isEnabled = true
                    }
                    if self.selectedPath == nil {
                        self.selectDeviceSourcePath(path: self.paths[0])
                    }else{
                        self.selectDeviceSourcePath(path: self.selectedPath!)
                    }
                }
            }
        }
    }
    
    @IBAction func onLoadClicked(_ sender: NSButton) {
        self.reloadFileList()
    }
    
    // MARK: ACTION BUTTON - COPY FILES
    
    fileprivate var accumulator:Accumulator?
    
    @IBAction func onCopyClicked(_ sender: NSButton) {
        var total = 0
        for path in self.paths {
            print("TO BE COPIED: \(path.sourcePath) - \(self.deviceFiles_filtered[path.sourcePath]!.count)")
            total += self.deviceFiles_filtered[path.sourcePath]!.count
        }
        print("TO BE COPIED: \(total)")
        guard total > 0 else {return}
        self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
        
        let destination = self.txtStorePath.stringValue
        btnCopy.isEnabled = false
        btnLoad.isEnabled = false
        btnBrowseStorePath.isEnabled = false
        btnDeleteRecords.isEnabled = false
        cbShowCopied.isEnabled = false
        btnAddSourcePath.isEnabled = false
        btnRemoveSourcePath.isEnabled = false
        btnLoadFromLocal.isEnabled = false
        
        if self.device.type == .iPhone {
            self.btnMount.isEnabled = false
        }
        
        DispatchQueue.global().async {
            let now = Date()
            let date = self.dateFormatter.string(from: now)
            for path in self.paths {
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
                    if path.type == .onDevice {
                        if self.device.type == .Android {
                            if Android.bridge.pull(device: self.device.deviceId, from: file.path, to: destinationPath) {
                                print("Copied \(file.path)")
                                if file.deviceFile != nil {
                                    var deviceFile = file.deviceFile!
                                    deviceFile.importToPath = destinationPath
                                    deviceFile.importAsFilename = file.filename
                                    deviceFile.importDate = date
                                    ModelStore.default.saveDeviceFile(file: deviceFile)
                                    print("Updated \(file.path)")
                                }
                            }else{
                                print("Failed to copy \(file.path)")
                            }
                        }else if self.device.type == .iPhone {
                            if IPHONE.bridge.pull(mountPoint: PreferencesController.iosDeviceMountPoint(), sourcePath:path.sourcePath, from: file.path, to: destinationPath) {
                                print("Copied \(file.path)")
                                if file.deviceFile != nil {
                                    var deviceFile = file.deviceFile!
                                    deviceFile.importToPath = destinationPath
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
                        let destinationFile = URL(fileURLWithPath: destinationPath).appendingPathComponent(file.filename).path
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
                            var deviceFile:ImageDeviceFile = file.deviceFile!
                            deviceFile.importToPath = destinationPath
                            deviceFile.importAsFilename = file.filename
                            deviceFile.importDate = date
                            ModelStore.default.saveDeviceFile(file: deviceFile)
                            print("Updated \(file.path)")
                        }
                    }
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
    
    @IBAction func onCheckboxShowCopiedClicked(_ sender: NSButton) {
        self.refreshFileList()
    }
    
    // MARK: TOOL BUTTONS - SOURCE PATH
    
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
            paths.remove(at: sourcePathTableDelegate.lastSelectedRow!)
            sourcePathTableDelegate.paths.remove(at: sourcePathTableDelegate.lastSelectedRow!)
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
                                                                                   onApply: { (directory, toSubFolder) in
                print("\(directory) \(toSubFolder)")
                let dest = DeviceCopyDestination.new((directory, toSubFolder))
                if !self.sourcePathTableDelegate.paths.contains(where: {$0.sourcePath == dest.sourcePath && $0.type == .onDevice }) {
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
                                                                                   onApply: { (directory, toSubFolder) in
                print("\(directory) \(toSubFolder)")
                let dest = DeviceCopyDestination.local((directory, toSubFolder))
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
                value = info.stored && info.matched ? "Copied" : "NEW"
                
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
