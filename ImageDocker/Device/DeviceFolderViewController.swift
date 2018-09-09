//
//  DeviceFolderViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/9/9.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class DeviceFolderViewController: NSViewController, DirectoryViewGotoDelegate {
    
    // MARK: PROPERTIES
    
    var images:[ImageFile]
    var currentPath:URL
    
    // MARK: CONTROLS
    
    @IBOutlet weak var txtDirectory: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var tblShortcut: NSTableView!
    @IBOutlet weak var tblFolders: NSTableView!
    @IBOutlet weak var tblFiles: NSTableView!
    @IBOutlet weak var btnParent: NSButton!
    @IBOutlet weak var btnHome: NSButton!
    @IBOutlet weak var btnGoto: NSButton!
    @IBOutlet weak var comboDeviceList: NSComboBox!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var lblProgressMessage: NSTextField!
    
    // MARK: TABLE DELEGATES
    
    let tblShortcutDelegate = DirectoryShortcutTableDelegate()
    let tblFoldersDelegate = DirectoryFolderTableDelegate()
    let tblFilesDelegate = DirectoryFilesTableDelegate()
    
    var deviceListController:DeviceListComboController!
    
    var directoryViewDelegate:DirectoryViewDelegate
    
    // MARK: INIT
    
    
    init(images: [ImageFile]){
        self.images = images
        self.currentPath = URL(fileURLWithPath: "/")
        self.directoryViewDelegate = LocalDirectoryViewDelegate()
        super.init(nibName: NSNib.Name(rawValue: "DeviceFolderViewController"), bundle: nil)
        self.tblShortcutDelegate.gotoDelegate = self
        self.tblFoldersDelegate.gotoDelegate = self
    }
    
    
    required init?(coder: NSCoder) {
        self.images = []
        self.directoryViewDelegate = LocalDirectoryViewDelegate()
        self.currentPath = URL(fileURLWithPath: "/")
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblShortcut.delegate = tblShortcutDelegate
        tblShortcut.dataSource = tblShortcutDelegate
        
        tblFolders.delegate = tblFoldersDelegate
        tblFolders.dataSource = tblFoldersDelegate
        
        tblFiles.delegate = tblFilesDelegate
        tblFiles.dataSource = tblFilesDelegate
        
        self.setupDeviceList()
    }
    
    func viewInit(){
        let i = self.comboDeviceList.indexOfSelectedItem
        if i >= 0 && i < self.deviceListController.deviceItems.count {
            let device = self.deviceListController.deviceItems[i]
            
            self.directoryViewDelegate = AndroidDirectoryViewDelegate(deviceId: device.deviceId)
            viewInit(path: directoryViewDelegate.home(), shortcuts: directoryViewDelegate.shortcuts())
        }else{
            viewInit(path: "", shortcuts: [])
        }
    }
    
    func viewInit(path:String, shortcuts:[DirectoryViewShortcut]){
        
        tblShortcutDelegate.shortcuts = shortcuts
        tblShortcut.reloadData()
        
        if shortcuts.count > 0 {
            tblShortcut.isEnabled = true
        }else{
            tblShortcut.isEnabled = false
        }
        
        goto(path: path)
    }
    
    func setupDeviceList() {
        if self.deviceListController == nil {
            self.deviceListController = DeviceListComboController()
            self.deviceListController.combobox = self.comboDeviceList
            self.comboDeviceList.dataSource = self.deviceListController
            self.comboDeviceList.delegate = self.deviceListController
        }
        self.refreshDeviceList()
        self.viewInit()
    }
    
    func refreshDeviceList() {
        self.lblProgressMessage.stringValue = ""
        self.deviceListController.loadAndroidDevices()
        self.comboDeviceList.reloadData()
        if self.deviceListController.deviceItems.count > 0 {
            // enable tables and buttons
            self.tblShortcut.isEnabled = true
            self.tblFolders.isEnabled = true
            self.tblFiles.isEnabled = true
            self.btnGoto.isEnabled = true
            self.btnParent.isEnabled = true
            self.btnHome.isEnabled = true
            self.txtDirectory.isEnabled = true
            self.btnOK.isEnabled = true
            
            self.comboDeviceList.selectItem(at: 0)
            
        }else{
            self.lblProgressMessage.stringValue = "NO DEVICES FOUND, PLEASE REFRESH TO RETRY"
            // disable tables and buttons
            self.tblShortcut.isEnabled = false
            self.tblFolders.isEnabled = false
            self.tblFiles.isEnabled = false
            self.btnGoto.isEnabled = false
            self.btnParent.isEnabled = false
            self.btnHome.isEnabled = false
            self.txtDirectory.isEnabled = false
            self.btnOK.isEnabled = false
        }
    }
    
    // MARK: ACTION
    
    @IBAction func onRefreshDevicesClicked(_ sender: Any) {
        self.refreshDeviceList()
    }
    
    
    @IBAction func onBrowseClicked(_ sender: NSButton) {
        self.goto(path: txtDirectory.stringValue)
    }
    
    @IBAction func onParentClicked(_ sender: NSButton) {
        self.gotoParent()
    }
    
    @IBAction func onHomeClicked(_ sender: NSButton) {
        self.gotoHome()
    }
    
    func goto(path:String){
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
    
    func goto(url:URL){
        
        let path = url.path
        
        self.txtDirectory.stringValue = path
        
        let folders = self.directoryViewDelegate.listSubFolders(in: path)
        self.tblFoldersDelegate.folders = folders
        
        let files = self.directoryViewDelegate.listFiles(in: path)
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
        
        
    }
    
    func currentUrl() -> URL {
        return self.currentPath
    }
    
    func gotoParent() {
        print("current: \(currentPath.path)")
        let parent = currentPath.deletingLastPathComponent()
        self.currentPath = parent
        print("parent: \(currentPath.path)")
        goto(url: parent)
    }
    
    func gotoHome() {
        self.currentPath = URL(fileURLWithPath: self.directoryViewDelegate.home())
        goto(path: self.directoryViewDelegate.home())
    }
    
    var accumulator:Accumulator? = nil
    
    @IBAction func onOKClicked(_ sender: NSButton) {
        guard txtDirectory.stringValue != "" else {return}
        let i = self.comboDeviceList.indexOfSelectedItem
        if i >= 0 && i < self.deviceListController.deviceItems.count {
            let device = self.deviceListController.deviceItems[i]
            
            print("PUSH TO DEVICE: \(device.deviceId) - \(device.name)")
            
            self.btnOK.isEnabled = false
            self.btnHome.isEnabled = false
            self.btnParent.isEnabled = false
            self.btnGoto.isEnabled = false
            self.comboDeviceList.isEnabled = false
            
            self.accumulator = Accumulator(target: self.images.count, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblProgressMessage, onCompleted: {data in
                    self.btnOK.isEnabled = true
                    self.btnHome.isEnabled = true
                    self.btnParent.isEnabled = true
                    self.btnGoto.isEnabled = true
                    self.comboDeviceList.isEnabled = true
                })
            
            DispatchQueue.global().async {
                for image in self.images {
                    let destinationPath:URL = URL(fileURLWithPath: self.txtDirectory.stringValue)
                        .appendingPathComponent(image.event)
                    let _ = Android.bridge.push(device: device.deviceId, from: image.url.path, to: destinationPath.path)
                    
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("")
                    }
                }
                
            }
        }
    }
    
}

class DeviceListComboController : NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var deviceItems:[PhoneDevice] = []
    var combobox:NSComboBox?
    var working:Bool = false
    
    func loadAndroidDevices() {
        self.deviceItems.removeAll()
        let devices:[String] = Android.bridge.devices()
        print("android device count: \(devices.count)")
        if devices.count > 0 {
            for deviceId in devices {
                if let device:PhoneDevice = Android.bridge.device(id: deviceId) {
                    let imageDevice = ModelStore.default.getOrCreateDevice(device: device)
                    
                    var dev:PhoneDevice = Android.bridge.memory(device: device)
                    if imageDevice.name != "" {
                        dev.name = imageDevice.name ?? ""
                    }
                    if dev.name == "" {
                        dev.name = "\(imageDevice.manufacture ?? dev.manufacture) \(imageDevice.model ?? dev.model)"
                    }
                    self.deviceItems.append(dev)
                    print("COMBO added \(dev.name)")
                }
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


