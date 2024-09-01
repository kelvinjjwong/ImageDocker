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
    
    let logger = LoggerFactory.get(category: "Setting", subCategory: "LocalEnvironment")
    
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
    @IBOutlet weak var lblExifLatestVersion: NSTextField!
    @IBOutlet weak var btnExifCheckVersion: NSButton!
    
    
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
    
    @IBAction func onExifCheckVersionClicked(_ sender: NSButton) {
        DispatchQueue.global().async {
            let version = ExifTool.getLatestVersionUrl()
            DispatchQueue.main.async {
                self.lblExifLatestVersion.stringValue = version
            }
        }
    }
    
    
    @IBAction func onDownloadExifToolClicked(_ sender: NSButton) {
        let url = self.lblExifLatestVersion.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if url == "" || !url.hasPrefix("https://exiftool.org/") {
            self.logger.log("EXIFTOOL latest version url is invalid: \(url)")
            return
        }
        let filename = url.lastPartOfUrl()
        self.lblExifToolMessage.stringValue = "Downloading \(filename)"
        
        DispatchQueue.global().async {
            let destinationPath = URL(fileURLWithPath: Setting.tools.toolsPath()).appending(component: "exiftool").path
            
            do {
                try FileManager.default.createDirectory(atPath: destinationPath, withIntermediateDirectories: true)
            }catch{
                self.logger.log(.error, "Unable to create folder for exiftool at \(destinationPath)", error)
                return
            }
            
            self.downloadFileCompletionHandler(urlstring: url, destinationPath: destinationPath, deleteIfExist: true) {(destinationUrl, error) in
                if let dest = destinationUrl {
                    self.logger.log("Downloaded exiftool to: \(dest)")
                    if dest.path != "" && dest.path.isFileExists() {
                        let _ = ExifTool.untarExiftoolPackage(filePath: dest.path)
                        DispatchQueue.main.async {
                            self.lblExifToolMessage.stringValue = "Downloaded \(filename)"
                            self.txtExifToolPath.stringValue = "\(destinationPath.removeLastStash())/current/exiftool"
                        }
                    }
                } else {
                    self.logger.log(.error, error)
                }
              
            }
        }
        
        
    }
    
    
    func checkExifToolPath() {
        let _path = self.txtExifToolPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if _path != "" && _path.isFileExists() {
            DispatchQueue.global().async {
                let version = ExifTool.getVersion(path: _path)
                DispatchQueue.main.async {
                    self.lblExifToolMessage.stringValue = "\(Words.preference_tab_found_path.fill(arguments: "exiftool", _path)) , Ver.\(version)"
                }
            }
        }else{
            self.lblExifToolMessage.stringValue = Words.preference_tab_missing_error.fill(arguments: "exiftool")
        }
    }
    
    func saveExifSection(_ defaults:UserDefaults) {
        self.logger.log("Saving EXIFTOOL path: \(self.txtExifToolPath.stringValue)")
        Setting.localEnvironment.saveExifToolPath(self.txtExifToolPath.stringValue)
    }
    
    
    // MARK: - SAVE ALL TABS
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        
        self.saveMobileSection(defaults)
        self.saveExifSection(defaults)
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
        
        self.txtExifToolPath.stringValue = Setting.localEnvironment.exiftoolPath()
        self.txtExifToolPath.isEnabled = false
        
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
    
    private func downloadFileCompletionHandler(urlstring: String, destinationPath: String, deleteIfExist:Bool, completion: @escaping (URL?, Error?) -> Void) {

        let url = URL(string: urlstring)!
        let destinationUrl = URL(fileURLWithPath: destinationPath).appendingPathComponent(url.lastPathComponent)
        self.logger.log(destinationUrl)

        if FileManager().fileExists(atPath: destinationUrl.path) {
            self.logger.log(.warning, "File already exists [\(destinationUrl.path)]")
            
            if deleteIfExist {
                do {
                    try FileManager().removeItem(at: destinationUrl)
                }catch{
                    self.logger.log(.error, "Unable to delete when file exist: \(destinationUrl.path)", error)
                    completion(destinationUrl, error)
                    return
                }
            }else{
                completion(destinationUrl, nil)
                return
            }
        }

        let request = URLRequest(url: url)


        let task = URLSession.shared.downloadTask(with: request) { tempFileUrl, response, error in
//            print(tempFileUrl, response, error)
            if error != nil {
                completion(nil, error)
                return
            }

            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let tempFileUrl = tempFileUrl {
                        self.logger.log("download finished")
                        try! FileManager.default.moveItem(at: tempFileUrl, to: destinationUrl)
                        completion(destinationUrl, error)
                    } else {
                        completion(nil, error)
                    }

                }
            }

        }
        task.resume()
    }
    
}
