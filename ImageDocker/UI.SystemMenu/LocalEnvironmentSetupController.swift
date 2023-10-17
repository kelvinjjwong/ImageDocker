//
//  LocalEnvironmentSetupController.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/4.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

final class LocalEnvironmentSetupController: NSViewController {
    
    let logger = LoggerFactory.get(category: "LocalEnvironmentSetupController")
    
    @IBOutlet weak var tabs: NSTabView!
    
    @IBOutlet weak var btnApply: NSButton!
    
    // MARK: LOCAL DISK
    
    @IBOutlet weak var lblLocalMountPointPrompt: NSTextField!
    @IBOutlet weak var txtPathForLocalMountPoint: NSTextField!
    @IBOutlet weak var btnAddLocalMountPoint: NSButton!
    @IBOutlet weak var tblLocalMountPoints: NSTableView!
    @IBOutlet weak var lblLocalMountPoint: NSTextField!
    
    var localMountPointsTableController : DictionaryTableViewController!
    
    
    // MARK: MOBILE DEVICE
    
    @IBOutlet weak var boxAndroid: NSBox!
    @IBOutlet weak var boxIOS: NSBox!
    
    @IBOutlet weak var txtAdbPath: NSTextField!
    @IBOutlet weak var lblAdbMessage: NSTextField!
    @IBOutlet weak var btnBrowseAdbPath: NSButton!
    @IBOutlet weak var lblAdbInstruction: NSTextField!
    
    @IBOutlet weak var txtIOSMountPoint: NSTextField!
    @IBOutlet weak var txtIfusePath: NSTextField!
    @IBOutlet weak var txtIdeviceIdPath: NSTextField!
    @IBOutlet weak var txtIdeviceInfoPath: NSTextField!
    @IBOutlet weak var lblIOSMountPointMessage: NSTextField!
    @IBOutlet weak var lblIfuseMessage: NSTextField!
    @IBOutlet weak var lblIdeviceIdMessage: NSTextField!
    @IBOutlet weak var lblIdeviceInfoMessage: NSTextField!
    
    @IBOutlet weak var lblIOSMountPoint: NSTextField!
    @IBOutlet weak var btnBrowseIOSMountPoint: NSButton!
    @IBOutlet weak var btnLocateIfusePath: NSButton!
    @IBOutlet weak var btnLocateIdeviceIdPath: NSButton!
    @IBOutlet weak var btnLocateIdeviceInfoPath: NSButton!
    @IBOutlet weak var lblMacFuseInstruction: NSTextField!
    
    // MARK: EXIFTOOL
    @IBOutlet weak var boxExifTool: NSBox!
    @IBOutlet weak var lblExifToolPath: NSTextField!
    @IBOutlet weak var txtExifToolPath: NSTextField!
    @IBOutlet weak var btnBrowseExifToolPath: NSButton!
    @IBOutlet weak var lblExifToolMessage: NSTextField!
    @IBOutlet weak var lblExifToolInstruction: NSTextField!
    
    
    // MARK: - SAVE BUTTON
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        self.savePreferences()
        self.dismiss(sender)
    }
    
    // MARK: - ACTION FOR LOCAL DISK SECTION
    
    @IBAction func onAddLocalMountPointClicked(_ sender: NSButton) {
        let newPath = self.txtPathForLocalMountPoint.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if newPath != "" {
            var records = Setting.localEnvironment.localDiskMountPoints()
            if !records.contains(newPath) {
                records.append(newPath)
            }
            Setting.localEnvironment.saveLocalDiskMountPoints(records)
            
            // reload table view
            self.localMountPointsTableController.load(self.loadLocalMountPoints(), afterLoaded: {
            })
        }
    }
    
    
    // MARK: - ACTION FOR MOBILE DEVICE SECTION
    
    @IBAction func onLocateAdbClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    self.txtAdbPath.stringValue = path
                }
            }
        }
    }
    
    @IBAction func onBrowseIOSMountPointClicked(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    self.txtIOSMountPoint.stringValue = path
                }
            }
        }
    }
    
    @IBAction func onLocateIfuseClicked(_ sender: NSButton) {
        let path = ExecutionEnvironment.default.locate("ifuse")
        if path != "" {
            self.txtIfusePath.stringValue = path
            self.lblIfuseMessage.stringValue = Words.preference_tab_found_path.fill(arguments: "ifuse", path)
        }else{
            self.txtIfusePath.stringValue = ""
            self.lblIfuseMessage.stringValue = Words.preference_tab_missing_error.fill(arguments: "ifuse")
        }
    }
    
    @IBAction func onLocateIdeviceIdClicked(_ sender: NSButton) {
        let path = ExecutionEnvironment.default.locate("idevice_id")
        if path != "" {
            self.txtIdeviceIdPath.stringValue = path
            self.lblIdeviceIdMessage.stringValue = Words.preference_tab_found_path.fill(arguments: "idevice_id", path)
        }else{
            self.txtIdeviceIdPath.stringValue = ""
            self.lblIdeviceIdMessage.stringValue = Words.preference_tab_missing_error.fill(arguments: "idevice_id")
        }
    }
    
    @IBAction func onLocateIdeviceInfoClicked(_ sender: NSButton) {
        let path = ExecutionEnvironment.default.locate("ideviceinfo")
        if path != "" {
            self.txtIdeviceInfoPath.stringValue = path
            self.lblIdeviceInfoMessage.stringValue = Words.preference_tab_found_path.fill(arguments: "ideviceinfo", path)
        }else{
            self.txtIdeviceInfoPath.stringValue = ""
            self.lblIdeviceInfoMessage.stringValue = Words.preference_tab_missing_error.fill(arguments: "ideviceinfo")
        }
    }
    
    func saveMobileSection(_ defaults:UserDefaults) {
        Setting.localEnvironment.saveAdbPath(txtAdbPath.stringValue)
        Setting.localEnvironment.saveIOSMountPoint(txtIOSMountPoint.stringValue)
        Setting.localEnvironment.saveIfusePath(txtIfusePath.stringValue)
        Setting.localEnvironment.saveIdeviceIdPath(txtIdeviceIdPath.stringValue)
        Setting.localEnvironment.saveIdeviceInfoPath(txtIdeviceInfoPath.stringValue)
        Setting.localEnvironment.saveExifToolPath(txtExifToolPath.stringValue)
    }
    
    // MARK: - ACTION FOR EXIFTOOL SECTION
    @IBAction func onBrowseExifToolClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    self.txtExifToolPath.stringValue = path
                }
            }
        }
    }
    
    func checkExifToolPath() {
        let _path = self.txtExifToolPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if _path != "" && _path.isFileExists() {
            self.lblExifToolMessage.stringValue = Words.preference_tab_found_path.fill(arguments: "exiftool", _path)
        }else{
            let path = ExecutionEnvironment.default.locate("exiftool")
            if path != "" {
                self.txtExifToolPath.stringValue = path
                self.lblExifToolMessage.stringValue = Words.preference_tab_found_path.fill(arguments: "exiftool", path)
                Setting.localEnvironment.saveExifToolPath(path)
            }else{
                self.txtExifToolPath.stringValue = ""
                self.lblExifToolMessage.stringValue = Words.preference_tab_missing_error.fill(arguments: "exiftool")
            }
        }
    }
    
    
    // MARK: - SAVE ALL TABS
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        
        self.saveMobileSection(defaults)
    }
    
    // MARK: - HEALTH CHECK
    
    class func healthCheck() {
    }
    
    // MARK: - INIT SECTIONS
    
    func initLocalDiskSection() {
        self.localMountPointsTableController = DictionaryTableViewController(self.tblLocalMountPoints)
        self.localMountPointsTableController.actionIcon = Icons.remove
        self.localMountPointsTableController.onAction = { id in
            
            var records = Setting.localEnvironment.localDiskMountPoints()
            if let idx = records.firstIndex(of: id) {
                records.remove(at: idx)
            }
            Setting.localEnvironment.saveLocalDiskMountPoints(records)
            
            // reload table view
            self.localMountPointsTableController.load(self.loadLocalMountPoints(), afterLoaded: {
            })
        }
        
        self.txtPathForLocalMountPoint.stringValue = ""
        self.localMountPointsTableController.load(self.loadLocalMountPoints(), afterLoaded: {
        })
    }
    
    func loadLocalMountPoints() -> [[String:String]] {
        var records:[[String:String]] = []
        let localMountPoints = Setting.localEnvironment.localDiskMountPoints()
        for p in localMountPoints {
            var record:[String:String] = [:]
            record["id"] = p
            record["value"] = p
            record["check"] = "false"
            
            let dest = LocalDirectory.bridge.getSymbolicLinkDestination(path: p)
            record["destination"] = dest
            records.append(record)
        }
        return records
    }
    
    func initMobileSection() {
        self.boxAndroid.title = Words.preference_tab_mobile_box_android.word()
        self.boxIOS.title = Words.preference_tab_mobile_box_ios.word()
        
        self.lblIOSMountPoint.stringValue = Words.preference_tab_mobile_box_ios_mount_point.word()
        self.btnBrowseAdbPath.title = Words.preference_tab_mobile_box_ios_browse.word()
        self.btnBrowseIOSMountPoint.title = Words.preference_tab_mobile_box_ios_browse.word()
        self.btnLocateIfusePath.title = Words.preference_tab_mobile_box_ios_locate.word()
        self.btnLocateIdeviceIdPath.title = Words.preference_tab_mobile_box_ios_locate.word()
        self.btnLocateIdeviceInfoPath.title = Words.preference_tab_mobile_box_ios_locate.word()
        
        txtAdbPath.stringValue = Setting.localEnvironment.adbPath()
        
        txtIOSMountPoint.stringValue = Setting.localEnvironment.iosDeviceMountPoint()
        txtIfusePath.stringValue = Setting.localEnvironment.ifusePath()
        txtIdeviceIdPath.stringValue = Setting.localEnvironment.ideviceidPath()
        txtIdeviceInfoPath.stringValue = Setting.localEnvironment.ideviceinfoPath()
    }
    
    func initExifToolSection() {
        self.boxExifTool.title = Words.preference_tab_exiftool_box_location.word()
        
        self.lblExifToolPath.stringValue = Words.preference_tab_exiftool_box_exiftool_path.word()
        self.btnBrowseExifToolPath.title = Words.preference_tab_mobile_box_ios_browse.word()
        self.lblExifToolInstruction.stringValue = Words.preference_tab_exiftool_box_exiftool_instruction.word()
        
        txtExifToolPath.stringValue = Setting.localEnvironment.exiftoolPath()
        
        self.checkExifToolPath()
        
    }
    
    func initFaceRecognitionSection() {
        
    }
    
    // MARK: VIEW INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Words.mainmenu_local_environment.word()
        // Do any additional setup after loading the view.
        self.setupTabs()
        self.initLocalDiskSection()
        self.initMobileSection()
        self.initExifToolSection()
        self.initFaceRecognitionSection()
    }
    
    func setupTabs() {
        self.view.window?.title = Words.mainmenu_local_environment.word()
        self.btnApply.title = Words.apply.word()
        self.tabs.tabViewItem(at: 0).label = Words.preference_tab_local_disk.word()
        self.tabs.tabViewItem(at: 1).label = Words.preference_tab_mobile_device_connection.word()
        self.tabs.tabViewItem(at: 2).label = Words.preference_tab_exiftool.word()
        self.tabs.tabViewItem(at: 3).label = Words.preference_tab_face_recognition.word()
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}
