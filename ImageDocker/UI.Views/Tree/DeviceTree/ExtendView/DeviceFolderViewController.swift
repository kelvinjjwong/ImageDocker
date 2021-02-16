//
//  DeviceFolderViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/9/9.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class DeviceFolderViewController: NSViewController, DirectoryViewGotoDelegate {
    
    // MARK: - PROPERTIES
    
    private let defaultBasePath = "/sdcard/Pictures/"
    private let spaceAlternative = "."
    
    private var isComputer = false
    
    private var images:[ImageFile]
    private var currentPath:URL
    
    // MARK: - CONTROLS
    
    @IBOutlet weak var txtDirectory: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var tblShortcut: NSTableView!
    @IBOutlet weak var tblFolders: NSTableView!
    @IBOutlet weak var tblFiles: NSTableView!
    @IBOutlet weak var btnParent: NSButton!
    @IBOutlet weak var btnHome: NSButton!
    @IBOutlet weak var btnGoto: NSButton!
    @IBOutlet weak var comboDeviceList: NSComboBox!
    @IBOutlet weak var chkCreateFolder: NSButton!
    @IBOutlet weak var txtFolderName: NSTextField!
    @IBOutlet weak var lblFreeSpace: NSTextField!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var lblProgressMessage: NSTextField!
    
    
    // MARK: - TABLE DELEGATES
    
    private let tblShortcutDelegate = DirectoryShortcutTableDelegate()
    private let tblFoldersDelegate = DirectoryFolderTableDelegate()
    private let tblFilesDelegate = DirectoryFilesTableDelegate()
    
    private var deviceListController:DeviceListComboController!
    
    private var directoryViewDelegate:DirectoryViewDelegate
    
    // MARK: - VIEW INIT
    
    /// Entrance method
    /// - 1st time:   init -> viewDidLoad -> setupDeviceList -> refreshDeviceList -> viewInit
    /// - 2nd time or more: reinit -> refreshDeviceList -> viewInit
    
    init(images: [ImageFile]){
        self.images = images
        self.currentPath = URL(fileURLWithPath: "/")
        self.directoryViewDelegate = LocalDirectoryViewDelegate()
        super.init(nibName: "DeviceFolderViewController", bundle: nil)
        self.tblShortcutDelegate.gotoDelegate = self
        self.tblFoldersDelegate.gotoDelegate = self
        // do not set value for components here, do it in viewDidLoad()
    }
    
    /// Entrance method
    /// - Note: Executes on pop up every time
    /// - 1st time:   init -> viewDidLoad -> setupDeviceList -> refreshDeviceList -> viewInit
    /// - 2nd time or more: reinit -> refreshDeviceList -> viewInit
    func reinit(_ images:[ImageFile]){
        self.images = images
        self.lblFreeSpace.stringValue = "0M"
        self.getImagesInfo()
        self.refreshDeviceList()
    }
    
    
    required init?(coder: NSCoder) {
        self.images = []
        self.directoryViewDelegate = LocalDirectoryViewDelegate()
        self.currentPath = URL(fileURLWithPath: "/")
        super.init(coder: coder)
    }
    
    private func getImagesInfo() {
        
        DispatchQueue.global().async {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "yyyy年MM月"
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy年"
            
            //self.txtFolderName.stringValue = ""
            if self.images.count > 0 {
                var firstEvent = ""
                var firstPlace = ""
                var firstDate = ""
                var firstYear = ""
                var firstMonth = ""
                var places:Set<String> = []
                var events:Set<String> = []
                var dates:Set<String> = []
                var months:Set<String> = []
                var years:Set<String> = []
                
                var totalSize = 0
                for img in self.images {
                    if let dt = img.photoTakenDate() {
                        let dateString = dateFormatter.string(from: dt)
                        let monthString = monthFormatter.string(from: dt)
                        let yearString = yearFormatter.string(from: dt)
                        dates.insert(dateString)
                        months.insert(monthString)
                        years.insert(yearString)
                        if firstDate == "" {
                            firstDate = dateString
                        }
                        if firstMonth == "" {
                            firstMonth = monthString
                        }
                        if firstYear == "" {
                            firstYear = yearString
                        }
                    }
                    if img.event != "" {
                        events.insert(img.event)
                        if firstEvent == "" {
                            firstEvent = img.event
                        }
                    }
                    if img.place != "" {
                        places.insert(img.place)
                        if firstPlace == "" {
                            firstPlace = img.place
                        }
                    }
                    
                    do {
                        let attr = try FileManager.default.attributesOfItem(atPath: img.url.path)
                        let fileSize = attr[FileAttributeKey.size] as! UInt64
                        totalSize += Int(fileSize)
                    } catch {
                        print("Error: \(error)")
                    }
                }
//                print("total size: \(totalSize)")
                let totalSizeInMB = totalSize / 1000 / 1000
                var event = ""
                var place = ""
                var date = ""
                if events.count == 1 {
                    event = firstEvent
                }
                if places.count == 1 {
                    place = firstPlace
                }
                if date == "" && dates.count == 1 {
                    date = firstDate
                }
                if date == "" && months.count == 1 {
                    date = firstMonth
                }
                if date == "" && years.count == 1 {
                    date = firstYear
                }
                
                // TODO: add people / family's nickname to folder name
                let result = "\(event) \(date) \(place)".trimmingCharacters(in: .whitespacesAndNewlines)
                DispatchQueue.main.async {
                    self.txtFolderName.stringValue = result
                    self.lblProgressMessage.stringValue = "\(self.images.count) IMAGES TO BE COPIED, TOTAL \(totalSizeInMB) MB"
                }
                
                
            }
        }
        
        
    }
    
    // Executes only once
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblShortcut.delegate = tblShortcutDelegate
        tblShortcut.dataSource = tblShortcutDelegate
        
        tblFolders.delegate = tblFoldersDelegate
        tblFolders.dataSource = tblFoldersDelegate
        
        tblFiles.delegate = tblFilesDelegate
        tblFiles.dataSource = tblFilesDelegate
        
        self.lblFreeSpace.stringValue = "0M"
        
        self.setupDeviceList()
        self.getImagesInfo()
    }
    
    /// - If device dropdown list loaded with devices, pick the selected one (usually the first one)
    /// and load default starting path from configuration, try to locate the path in the selected
    /// device and refresh the folder list and filename list.
    /// - If no device connected, load from computer desktop
    /// - Note: Executes on pop up every time
    private func viewInitWithSelectedDevice(){
        var k = -1
        if self.deviceListController.deviceItems.count > 0 {
            let i = self.comboDeviceList.indexOfSelectedItem
            if i >= 0 && i < self.deviceListController.deviceItems.count {
                k = i
            }
        }
        if k > 0 { // if k > 0 when my computer is the first option [0]
            let device = self.deviceListController.deviceItems[k]
            
            self.isComputer = false
            self.directoryViewDelegate = AndroidDirectoryViewDelegate(deviceId: device.deviceId)
            
            let shortcuts = self.directoryViewDelegate.shortcuts()
            
            viewInit(path: shortcuts[0].path, shortcuts: shortcuts)
        }else{
            // load folders and files from computer desktop
            // basePath is ~/desktop
            // shortcuts includes desktop, documents, pictures
            // add a flag to indicate operating on my computer or a device
            
            self.isComputer = true
            self.directoryViewDelegate = LocalDirectoryViewDelegate()
            
            let shortcuts = self.directoryViewDelegate.shortcuts()
            
            viewInit(path: shortcuts[0].path, shortcuts: shortcuts)
        }
    }
    
    /// Replace shortcuts list with given list, reload folder list and filename list from the given path.
    /// - Note: Executes on pop up every time
    private func viewInit(path:String, shortcuts:[DirectoryViewShortcut]){
        
        tblShortcutDelegate.shortcuts = shortcuts
        tblShortcut.reloadData()
        
        if shortcuts.count > 0 {
            tblShortcut.isEnabled = true
        }else{
            tblShortcut.isEnabled = false
        }
        
        goto(path: path)
    }
    
    @IBAction func onRefreshDevicesClicked(_ sender: Any) {
        self.refreshDeviceList()
    }
    
    // MARK: - GOTO ACTION
    
    @IBAction func onBrowseClicked(_ sender: NSButton) {
        self.goto(path: txtDirectory.stringValue)
    }
    
    @IBAction func onParentClicked(_ sender: NSButton) {
        self.gotoParent()
    }
    
    @IBAction func onHomeClicked(_ sender: NSButton) {
        self.gotoHome()
    }
    
    /// a router to decide load real data into lists or clean up lists
    internal func goto(path:String){
        if path != "" {
            currentPath = URL(fileURLWithPath: path)
            goto(url: currentPath)
        }else {
            self.txtDirectory.stringValue = ""
            self.tblFoldersDelegate.folders = []
            self.tblFilesDelegate.files = []
            self.tblFolders.reloadData()
            self.tblFiles.reloadData()
            self.btnOK.isEnabled = false
            self.tblFolders.isEnabled = false
            self.tblFiles.isEnabled = false
        }
    }
    
    /// load folders and files into lists from the given url(path).
    private func goto(url:URL){
        
        let path = url.path
        
        self.txtDirectory.stringValue = path
        
        let folders = self.directoryViewDelegate.listSubFolders(in: path)
        
        self.tblFoldersDelegate.folders = folders
        
        let files = self.directoryViewDelegate.listFiles(in: path, ext: nil)
        self.tblFilesDelegate.files = files
        
        self.tblFolders.reloadData()
        self.tblFiles.reloadData()
        
        if folders.count > 0 {
            self.tblFolders.isEnabled = true
        }else{
            self.tblFolders.isEnabled = false
        }
        
        if files.count > 0 {
            self.tblFiles.isEnabled = true
        }else{
            self.tblFiles.isEnabled = false
        }
        
        if self.isComputer {
            DispatchQueue.global().async {
                let (_, freeSize, _) = LocalDirectory.bridge.freeSpace(path: path)
                DispatchQueue.main.async {
                    self.lblFreeSpace.stringValue = freeSize
                }
            }
        }else{
            let index = self.comboDeviceList.indexOfSelectedItem
            let device = self.deviceListController.deviceItems[index]
            DispatchQueue.global().async {
                let dev = Android.bridge.memory(device: device)
                DispatchQueue.main.async {
                    self.lblFreeSpace.stringValue = dev.availSize
                }
            }
        }
        
        
    }
    
    func currentUrl() -> URL {
        return self.currentPath
    }
    
    private func refreshFolderView() {
        self.goto(url: self.currentPath)
    }
    
    private func gotoParent() {
//        print("current: \(currentPath.path)")
        let parent = currentPath.deletingLastPathComponent()
        self.currentPath = parent
//        print("parent: \(currentPath.path)")
        goto(url: parent)
    }
    
    private func gotoHome() {
        self.currentPath = URL(fileURLWithPath: self.directoryViewDelegate.home())
        goto(path: self.directoryViewDelegate.home())
    }
    
    private var accumulator:Accumulator? = nil
    
    // MARK: - EXPORT ACTION
    
    /// export selected images to given folder in computer or device
    @IBAction func onOKClicked(_ sender: NSButton) {
        guard txtDirectory.stringValue != "" else {return}
        let i = self.comboDeviceList.indexOfSelectedItem
        if i >= 0 && i < self.deviceListController.deviceItems.count {
            let device = self.deviceListController.deviceItems[i]
            
//            print("EXPORT TO DEVICE: \(device.deviceId) - \(device.name)")
            
            self.btnOK.isEnabled = false
            self.btnHome.isEnabled = false
            self.btnParent.isEnabled = false
            self.btnGoto.isEnabled = false
            self.comboDeviceList.isEnabled = false
            
            var copiedCount = 0
            //var existsCount = 0
            
            self.accumulator = Accumulator(target: self.images.count, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage,
                                           onCompleted: {data in
                                            
                                            self.btnOK.isEnabled = true
                                            self.btnHome.isEnabled = true
                                            self.btnParent.isEnabled = true
                                            self.btnGoto.isEnabled = true
                                            self.comboDeviceList.isEnabled = true
                                            self.txtFolderName.isEnabled = true
                                            self.txtDirectory.isEnabled = true
                    
                                            self.lblProgressMessage.stringValue = "\(self.images.count) IMAGES TO BE COPIED, \(copiedCount) COPIED"
                                            
            })
            
            
            var destinationPath:URL = URL(fileURLWithPath: self.txtDirectory.stringValue)
            let folderName = self.txtFolderName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: "-")
            if folderName != "" {
                destinationPath.appendPathComponent(folderName)
            }
            // if disable before getting value, changes to value will be abandon
            self.txtFolderName.isEnabled = false
            self.txtDirectory.isEnabled = false
            
            DispatchQueue.global().async {
                
                let androidFileManager = AndroidFileManager(deviceId: device.deviceId)
                //let sourceFileSystemHandler = ComputerFileManager()
                //let filenameDateFormatter = DateFormatter()
                //filenameDateFormatter.dateFormat = "yyyy年MM月dd日HH点mm分ss秒"
                
                // create directory
                if self.isComputer {
                    do {
                        try FileManager.default.createDirectory(atPath: destinationPath.path, withIntermediateDirectories: true, attributes: nil)
                    }catch{
                        print(error)
                        DispatchQueue.main.async {
                            self.lblProgressMessage.stringValue = "UNABLE TO CREATE FOLDER, PLEASE CHANGE ANOTHER PLACE"
                        }
                        return
                    }
                }else{
                    if !androidFileManager.createDirectory(atPath: destinationPath.path) {
                        
                        DispatchQueue.main.async {
                            self.lblProgressMessage.stringValue = "UNABLE TO CREATE FOLDER, PLEASE CHANGE ANOTHER PLACE"
                        }
                        return
                    }
                }
                
                // copy files
                for image in self.images {
                    if let data = image.imageData {
                        
                        if self.isComputer {
//                            print("EXPORTING FROM \(image.url.path) TO \(destinationPath.path)")
                            let fileUrl = destinationPath.appendingPathComponent(data.filename)
                            do {
                                try FileManager.default.copyItem(at: image.url, to: fileUrl)
                                copiedCount += 1
                            }catch{
                                print(error)
                            }
                        }else{
//                            print("EXPORTING FROM \(image.url.path) TO \(device.deviceId):\(destinationPath.path)")
                            let _ = Android.bridge.push(device: device.deviceId, from: image.url.path, to: destinationPath.path)
                            if Android.bridge.existsFile(device: device.deviceId, path: destinationPath.path) {
                                copiedCount += 1
                            }
                        }
                        
                    }
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("")
                    }
                }
                
                DispatchQueue.main.async {
                    self.refreshFolderView()
                }
                
            }
        }
    }
    
    // MARK: - DEVICE FILESYS HANDLER
    
    /// - deprecated
    private func getOrCreateFolderOnDevice(basePath: URL, photo: Image, fm: FileSystemHandler) -> String {
        var album = ""
        var event = photo.event ?? "家人照片"
        if event == "" {
            event = "家人照片"
        }
        if let year = photo.photoTakenYear {
            album = "\(event) \(year)年"
        }else{
            album = event
        }
        album = album.replacingOccurrences(of: " ", with: spaceAlternative)
        let url = basePath.appendingPathComponent(album)
        if fm.createDirectory(atPath: url.path) {
            return url.path
        }else{
            return basePath.path
        }
    }
    
    // MARK: - DEVICE DROPDOWN LIST
    
    /// Initialize device dropdown list controller, then call refreshDeviceList() method
    /// - Note: Executes only once
    private func setupDeviceList() {
        if self.deviceListController == nil {
            self.deviceListController = DeviceListComboController()
            self.deviceListController.onSelectionChanged = {
                self.viewInitWithSelectedDevice()
            }
            self.deviceListController.combobox = self.comboDeviceList
            self.comboDeviceList.dataSource = self.deviceListController
            self.comboDeviceList.delegate = self.deviceListController
        }
        self.refreshDeviceList()
    }
    
    /// Refresh device dropdown list, then call viewInit() method
    /// - Note: Executes on pop up every time
    func refreshDeviceList() {
        self.lblProgressMessage.stringValue = ""
        self.deviceListController.loadDevices()
        self.comboDeviceList.reloadData()
        
        self.comboDeviceList.selectItem(at: 0)
        self.lblProgressMessage.stringValue = "\(self.images.count) IMAGES TO BE COPIED"
        self.viewInitWithSelectedDevice()
    }
    
}

class DeviceListComboController : NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var deviceItems:[PhoneDevice] = []
    var combobox:NSComboBox?
    var working:Bool = false
    var onSelectionChanged: (() -> Void)? = nil
    
    func loadDevices() {
        self.deviceItems.removeAll()
        
        var computer = PhoneDevice(type: .Unknown, deviceId: "Computer", manufacture: "Computer", model: "Computer")
        computer.name = "My Computer"
        self.deviceItems.append(computer)
        
        let devices:[String] = Android.bridge.devices()
//        print("android device count: \(devices.count)")
        if devices.count > 0 {
            for deviceId in devices {
                if let device:PhoneDevice = Android.bridge.device(id: deviceId) {
                    let imageDevice = DeviceDao.default.getOrCreateDevice(device: device)
                    
                    var dev:PhoneDevice = Android.bridge.memory(device: device)
                    if imageDevice.name != "" && imageDevice.name != imageDevice.deviceId {
                        dev.name = imageDevice.name ?? ""
                    }else{
                        dev.name = ""
                    }
                    if dev.name == "" {
                        dev.name = "\(imageDevice.manufacture ?? dev.manufacture) \(imageDevice.model ?? dev.model)"
                    }
                    self.deviceItems.append(dev)
//                    print("COMBO added \(dev.name)")
                }
            }
        }
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let index = self.combobox?.indexOfSelectedItem {
//            print("selection changed, selected index=\(index)")
            if self.onSelectionChanged != nil {
                self.onSelectionChanged!()
            }
        }
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return(deviceItems.count)
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return(deviceItems[index].name as AnyObject)
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        var i = 0
        for item in deviceItems {
            let str = item.name
            if str == string{
                return i
            }
            i += 1
        }
        return -1
    }
    
    
}


