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
    
    // MARK: ENVIRONMENT
    var device:PhoneDevice = PhoneDevice(type: .Android, deviceId: "", manufacture: "", model: "")
    
    var deviceFiles_fulllist:[String : [PhoneFile]] = [:]
    var deviceFiles_filtered:[String : [PhoneFile]] = [:]
    
    var paths:[DeviceCopyDestination] = []
    
    var selectedPath:String = ""
    
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
        tblSourcePath.isEnabled = false
        
        sourcePathTableDelegate.sourcePathSelectionDelegate = self
        self.tblSourcePath.delegate = sourcePathTableDelegate
        self.tblSourcePath.dataSource = sourcePathTableDelegate
        self.tblFiles.delegate = fileTableDelegate
        self.tblFiles.dataSource = fileTableDelegate
    }
    
    func viewInit(device:PhoneDevice){
        if device.manufacture != self.device.manufacture && device.deviceId != self.device.deviceId && device.model != self.device.model {
            
            self.device = device
            
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
    
    func getFileFullList(from path:String) -> [PhoneFile]{
        if self.deviceFiles_fulllist[path]!.count == 0 {
            self.loadFromPath(path: path)
        }
        return self.deviceFiles_fulllist[path]!
    }
    
    func getFileFilteredList(from path:String) -> [PhoneFile]{
        if self.deviceFiles_fulllist[path]!.count == 0 {
            self.loadFromPath(path: path)
        }
        return self.deviceFiles_filtered[path]!
    }
    
    func loadFromPath(path:String) {
        DispatchQueue.main.async {
            self.deviceFiles_filtered[path] = []
            self.deviceFiles_fulllist[path] = []
        }
        let files = Android.bridge.files(device: self.device.deviceId, in: path)
        let total = files.count
        DispatchQueue.main.async {
            self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
        }
        for file in files {
            let deviceFile = ModelStore.default.getOrCreateDeviceFile(deviceId: self.device.deviceId, file: file)
            var f = file
            f.storedMD5 = deviceFile.fileMD5 ?? ""
            f.storedSize = deviceFile.fileSize ?? ""
            f.storedDateTime = deviceFile.fileDateTime ?? ""
            f.importDate = deviceFile.importDate ?? ""
            f.importToPath = deviceFile.importToPath ?? ""
            f.importAsFilename = deviceFile.importAsFilename ?? ""
            
            f.deviceFile = deviceFile
            
            if (f.stored && !f.matched){
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
        }
    }
    
    func refreshFileList(){
        self.fileTableDelegate.files = cbShowCopied.state == .on ? self.getFileFullList(from: selectedPath) : self.getFileFilteredList(from: selectedPath)
        self.tblFiles.reloadData()
    }
    
    // MARK: ACTIONS
    
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
    
    @IBAction func onSaveClicked(_ sender: NSButton) {
        let name = txtName.stringValue
        let storagePath = txtStorePath.stringValue
        guard storagePath != "" else {return}
        var imageDevice = ModelStore.default.getOrCreateDevice(device: device)
        imageDevice.name = name
        imageDevice.storagePath = storagePath
        ModelStore.default.saveDevice(device: imageDevice)
    }
    
    @IBAction func onLoadClicked(_ sender: NSButton) {
        if paths.count > 0 {
            btnAddSourcePath.isEnabled = false
            btnRemoveSourcePath.isEnabled = false
            tblSourcePath.isEnabled = false
            cbShowCopied.isEnabled = false
            btnLoad.isEnabled = false
            DispatchQueue.global().async {
                for path in self.paths {
                    self.loadFromPath(path: path.sourcePath)
                }
                DispatchQueue.main.async {
                    self.selectDeviceSourcePath(path: self.paths[0].sourcePath)
                    self.btnAddSourcePath.isEnabled = true
                    self.btnRemoveSourcePath.isEnabled = true
                    self.tblSourcePath.isEnabled = true
                    self.cbShowCopied.isEnabled = true
                    self.btnLoad.isEnabled = true
                    self.tblSourcePath.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func onLoadFromLocalClicked(_ sender: NSButton) {
    }
    
    
    fileprivate var accumulator:Accumulator?
    
    @IBAction func onCopyClicked(_ sender: NSButton) {
        var total = 0
        for path in self.paths {
            total += self.deviceFiles_filtered[path.sourcePath]!.count
        }
        guard total > 0 else {return}
        self.accumulator = Accumulator(target: total, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage)
        
        let destination = self.txtStorePath.stringValue
        btnCopy.isEnabled = false
        btnLoad.isEnabled = false
        btnBrowseStorePath.isEnabled = false
        cbShowCopied.isEnabled = false
        btnAddSourcePath.isEnabled = false
        btnRemoveSourcePath.isEnabled = false
        
        DispatchQueue.global().async {
            let now = Date()
            let date = self.dateFormatter.string(from: now)
            for path in self.paths {
                var destinationPath = URL(fileURLWithPath: destination).appendingPathComponent(path.toSubFolder).path
                if !FileManager.default.fileExists(atPath: destinationPath) {
                    do {
                        try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
                    }catch{
                        print(error)
                        destinationPath = destination
                    }
                }
                for file in self.deviceFiles_filtered[path.sourcePath]! {
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
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("")
                    }
                }
            }
            DispatchQueue.main.async {
                self.refreshFileList()
                self.btnCopy.isEnabled = true
                self.btnLoad.isEnabled = true
                self.btnBrowseStorePath.isEnabled = true
                self.cbShowCopied.isEnabled = true
                self.btnAddSourcePath.isEnabled = true
                self.btnRemoveSourcePath.isEnabled = true
            }
        }
    }
    
    @IBAction func onCheckboxShowCopiedClicked(_ sender: NSButton) {
        self.refreshFileList()
    }
    
    @IBAction func onAddSourcePathClicked(_ sender: NSButton) {
    }
    
    @IBAction func onRemoveSourcePathClicked(_ sender: NSButton) {
    }
    
}

protocol DeviceSourcePathSelectionDelegate {
    func selectDeviceSourcePath(path:String)
}

// MARK: CLICK ACTION
extension DeviceCopyViewController : DeviceSourcePathSelectionDelegate {
    
    func selectDeviceSourcePath(path: String) {
        selectedPath = path
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
                    self.sourcePathSelectionDelegate?.selectDeviceSourcePath(path: paths[lastSelectedRow!].sourcePath)
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
