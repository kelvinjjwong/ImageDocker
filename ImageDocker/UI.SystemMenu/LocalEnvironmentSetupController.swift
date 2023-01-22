//
//  LocalEnvironmentSetupController.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/1/4.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa

final class LocalEnvironmentSetupController: NSViewController {
    
    let logger = ConsoleLogger(category: "LocalEnvironmentSetupController")
    
    @IBOutlet weak var tabs: NSTabView!
    
    @IBOutlet weak var btnApply: NSButton!
    
    // MARK: MOBILE DEVICE
    
    @IBOutlet weak var boxAndroid: NSBox!
    @IBOutlet weak var boxIOS: NSBox!
    
    @IBOutlet weak var txtAdbPath: NSTextField!
    @IBOutlet weak var lblAdbMessage: NSTextField!
    @IBOutlet weak var btnBrowseAdbPath: NSButton!
    
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
    
    // MARK: - SAVE BUTTON
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        self.savePreferences()
        self.dismiss(sender)
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
    }
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        
        self.saveMobileSection(defaults)
    }
    
    // MARK: - HEALTH CHECK
    
    class func healthCheck() {
    }
    
    // MARK: - INIT SECTIONS
    
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
        
    }
    
    func initFaceRecognitionSection() {
        
    }
    
    // MARK: VIEW INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Words.mainmenu_local_environment.word()
        // Do any additional setup after loading the view.
        self.setupTabs()
        self.initMobileSection()
        self.initExifToolSection()
        self.initFaceRecognitionSection()
    }
    
    func setupTabs() {
        self.view.window?.title = Words.mainmenu_local_environment.word()
        self.btnApply.title = Words.apply.word()
        self.tabs.tabViewItem(at: 0).label = Words.preference_tab_mobile_device_connection.word()
        self.tabs.tabViewItem(at: 1).label = Words.preference_tab_exiftool.word()
        self.tabs.tabViewItem(at: 2).label = Words.preference_tab_face_recognition.word()
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}