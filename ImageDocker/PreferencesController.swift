//
//  PreferencesController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/23.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

final class PreferencesController: NSViewController {
    
    fileprivate static let baiduAKKey = "BaiduAKKey"
    fileprivate static let baiduSKKey = "BaiduSKKey"
    fileprivate static let googleAKKey = "GoogleAPIKey"
    fileprivate static let exportPathKey = "ExportPath"
    fileprivate static let exportToAndroidPathKey = "ExportToAndroidPath"
    fileprivate static let databasePathKey = "DatabasePathKey"
    fileprivate static let iosMountPointKey = "IOSMountPointKey"
    
    // MARK: Properties
    @IBOutlet weak var txtBaiduAK: NSTextField!
    @IBOutlet weak var txtBaiduSK: NSTextField!
    @IBOutlet weak var txtExportPath: NSTextField!
    @IBOutlet weak var txtGoogleAPIKey: NSTextField!
    @IBOutlet weak var tabs: NSTabView!
    @IBOutlet weak var txtDatabasePath: NSTextField!
    @IBOutlet weak var txtIOSMountPoint: NSTextField!
    @IBOutlet weak var txtExportToAndroidPath: NSTextField!
    @IBOutlet weak var txtHomebrewPath: NSTextField!
    @IBOutlet weak var txtPythonPath: NSTextField!
    @IBOutlet weak var lblHomebrewMessage: NSTextField!
    @IBOutlet weak var lblPythonMessage: NSTextField!
    @IBOutlet weak var lblComponentsStatus: NSTextField!
    @IBOutlet weak var lblComponentsInstruction: NSTextField!
    
    
    
    // MARK: ACTION BUTTONS
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        self.savePreferences()
        self.dismiss(sender)
    }
    
    @IBAction func onButtonBrowseClicked(_ sender: Any) {
        //let window = NSApplication.shared.windows.first!
        
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    self.txtExportPath.stringValue = path
                }
            }
        }
    }
    
    @IBAction func onBrowseDatabasePathClicked(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    self.txtDatabasePath.stringValue = path
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
    
    @IBAction func onLocateHomebrewClicked(_ sender: NSButton) {
    }
    
    @IBAction func onInstallHomebrewClicked(_ sender: NSButton) {
    }
    
    @IBAction func onLocatePythonClicked(_ sender: NSButton) {
    }
    
    @IBAction func onInstallPythonClicked(_ sender: NSButton) {
    }
    
    @IBAction func onCheckComponentsClicked(_ sender: NSButton) {
    }
    
    
    
    // MARK: BAIDU
    
    
    class func baiduAK() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: baiduAKKey) else {return ""}
        return txt
    }
    
    class func baiduSK() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: baiduSKKey) else {return ""}
        return txt
    }
    
    // MARK: GOOGLE
    
    class func googleAPIKey() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: googleAKKey) else {return ""}
        return txt
    }
    
    // MARK: EXPORT
    
    class func exportToAndroidDirectory() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: exportToAndroidPathKey) else {return ""}
        return txt
    }
    
    class func exportDirectory() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: exportPathKey) else {return ""}
        var isDir : ObjCBool = false
        if FileManager.default.fileExists(atPath: txt, isDirectory: &isDir) {
            if isDir.boolValue {
                return txt
            }else{
                return ""
            }
        }else{
            return ""
        }
    }
    
    // MARK: DATABASE
    
    class func databasePath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: databasePathKey) else {
            return AppDelegate.current.applicationDocumentsDirectory.path
        }
        var isDir : ObjCBool = false
        if FileManager.default.fileExists(atPath: txt, isDirectory: &isDir) {
            if isDir.boolValue {
                return txt
            }else{
                return AppDelegate.current.applicationDocumentsDirectory.path
            }
        }else{
            return AppDelegate.current.applicationDocumentsDirectory.path
        }
    }
    
    class func databasePath(filename: String) -> String {
        let url = URL(fileURLWithPath: databasePath()).appendingPathComponent(filename)
        return url.path
    }
    
    // MARK: IPHONE
    
    class func iosDeviceMountPoint() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: iosMountPointKey) else {
            var isDir : ObjCBool = false
            if FileManager.default.fileExists(atPath: "/MacStorage/mount/iPhone/", isDirectory: &isDir) {
                if isDir.boolValue {
                    return "/MacStorage/mount/iPhone/"
                }else{
                    return ""
                }
            }else{
                return ""
            }
        }
        var isDir : ObjCBool = false
        if FileManager.default.fileExists(atPath: txt, isDirectory: &isDir) {
            if isDir.boolValue {
                return txt
            }else{
                return ""
            }
        }else{
            return ""
        }
    }
    
    // MARK: SAVE SETTINGS
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        defaults.set(txtBaiduAK.stringValue,
                     forKey: PreferencesController.baiduAKKey)
        defaults.set(txtBaiduSK.stringValue,
                     forKey: PreferencesController.baiduSKKey)
        defaults.set(txtExportPath.stringValue,
                     forKey: PreferencesController.exportPathKey)
        defaults.set(txtExportToAndroidPath.stringValue,
                     forKey: PreferencesController.exportToAndroidPathKey)
        defaults.set(txtGoogleAPIKey.stringValue,
                     forKey: PreferencesController.googleAKKey)
        defaults.set(txtDatabasePath.stringValue,
                     forKey: PreferencesController.databasePathKey)
        defaults.set(txtIOSMountPoint.stringValue,
                     forKey: PreferencesController.iosMountPointKey)

    }
    
    // MARK: HEALTH CHECK
    
    class func healthCheck() {
        
        if baiduAK() == "" || baiduSK() == "" {
            Alert.invalidBaiduMapAK()
            return
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Setting"
        // Do any additional setup after loading the view.
        txtBaiduAK.stringValue = PreferencesController.baiduAK()
        txtBaiduSK.stringValue = PreferencesController.baiduSK()
        txtGoogleAPIKey.stringValue = PreferencesController.googleAPIKey()
        txtExportPath.stringValue = PreferencesController.exportDirectory()
        txtDatabasePath.stringValue = PreferencesController.databasePath()
        txtIOSMountPoint.stringValue = PreferencesController.iosDeviceMountPoint()
        txtExportToAndroidPath.stringValue = PreferencesController.exportToAndroidDirectory()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
