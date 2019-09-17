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
    fileprivate static let homebrewKey = "HomebrewKey"
    fileprivate static let pythonKey = "PythonKey"
    fileprivate static let faceRecognitionModelKey = "FaceRecognitionModelKey"
    fileprivate static let alternativeFaceModelPathKey = "AlternativeFaceModelPathKey"
    fileprivate static let ifuseKey = "ifuseKey"
    fileprivate static let ideviceidKey = "ideviceidKey"
    fileprivate static let ideviceinfoKey = "ideviceinfoKey"
    fileprivate static let memoryPeakKey = "memoryPeakKey"
    fileprivate static let amountForPaginationKey = "amountForPaginationKey"
    
    
    fileprivate static let storageLocationKey = "storageLocationKey"
    fileprivate static let networkDatabaseLocationKey = "networkDatabaseLocationKey"
    fileprivate static let networkStoragePrefixKey = "networkStoragePrefixKey"
    
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
    @IBOutlet weak var chkMajorFaceRecognitionModel: NSButton!
    @IBOutlet weak var chkAlternativeFaceRecognitionModel: NSButton!
    @IBOutlet weak var lblMajorFaceModelPath: NSTextField!
    @IBOutlet weak var txtAlternativeFaceModelPath: NSTextField!
    @IBOutlet weak var btnCheckFaceComponents: NSButton!
    @IBOutlet weak var txtIfusePath: NSTextField!
    @IBOutlet weak var txtIdeviceIdPath: NSTextField!
    @IBOutlet weak var txtIdeviceInfoPath: NSTextField!
    @IBOutlet weak var lblDatabaseBackupPath: NSTextField!
    @IBOutlet var lblComponentsInstruction: NSTextView!
    @IBOutlet weak var lblIOSMountPointMessage: NSTextField!
    @IBOutlet weak var lblIfuseMessage: NSTextField!
    @IBOutlet weak var lblIdeviceIdMessage: NSTextField!
    @IBOutlet weak var lblIdeviceInfoMessage: NSTextField!
    @IBOutlet weak var memorySlider: NSSlider!
    @IBOutlet weak var lblMinMemory: NSTextField!
    @IBOutlet weak var lblMidMemory: NSTextField!
    @IBOutlet weak var lblMaxMemory: NSTextField!
    @IBOutlet weak var lblSelectedMemory: NSTextField!
    @IBOutlet weak var lblMin2Memory: NSTextField!
    @IBOutlet weak var lblMid2Memory: NSTextField!
    @IBOutlet weak var lstAmountForPagination: NSPopUpButton!
    
    @IBOutlet weak var txtNetworkDatabaseLocation: NSTextField!
    @IBOutlet weak var lblNetworkDBBackupLocation: NSTextField!
    @IBOutlet weak var txtNetworkStoragePrefix: NSTextField!
    @IBOutlet weak var btnBrowseNetworkDatabaseLocation: NSButton!
    @IBOutlet weak var btnGotoNetworkDatabaseLocation: NSButton!
    @IBOutlet weak var btnGotoNetworkDBBackupLocation: NSButton!
    @IBOutlet weak var btnVerifyNetworkRepo: NSButton!
    @IBOutlet weak var lblNetworkVerifyMessage: NSTextField!
    @IBOutlet weak var chkLocalLocation: NSButton!
    @IBOutlet weak var chkNetworkLocation: NSButton!
    
    
    
    
    fileprivate var selectedFaceModel = "major"
    
    
    // MARK: ACTION BUTTONS
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        self.savePreferences()
        self.dismiss(sender)
    }
    
    // MARK: -
    // MARK: ACTION BUTTONS FOR DATA LOCATION
    
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
    
    @IBAction func onBrowseNetworkDatabaseLocationClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    self.txtNetworkDatabaseLocation.stringValue = path
                }
            }
        }
    }
    
    @IBAction func onGotoNetworkDatabaseLocationClicked(_ sender: NSButton) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: self.txtNetworkDatabaseLocation.stringValue)])
    }
    
    @IBAction func onGotoNetworkDBBackupLocationClicked(_ sender: NSButton) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: self.lblNetworkDBBackupLocation.stringValue)])
    }
    
    private var selectedStorageLocation = "local"
    
    @IBAction func onCheckLocalLocationClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkLocalLocation.state = .off
            self.selectedStorageLocation = "network"
        }else{
            self.chkLocalLocation.state = .on
            self.selectedStorageLocation = "local"
        }
    }
    
    @IBAction func onCheckNetworkLocationClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkNetworkLocation.state = .off
            self.selectedStorageLocation = "local"
        }else{
            self.chkNetworkLocation.state = .on
            self.selectedStorageLocation = "network"
        }
    }
    
    // MARK: -
    
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
        let path = ExecutionEnvironment.default.locate("brew")
        if path != "" {
            self.txtHomebrewPath.stringValue = path
            self.lblHomebrewMessage.stringValue = ""
        }else{
            self.txtHomebrewPath.stringValue = ""
            self.lblHomebrewMessage.stringValue = "ERROR: Missing Homebrew"
        }
    }
    
    @IBAction func onLocatePythonClicked(_ sender: NSButton) {
        let path = ExecutionEnvironment.default.locate("python3")
        if path != "" {
            self.txtPythonPath.stringValue = path
            self.lblPythonMessage.stringValue = ""
        }else{
            self.txtPythonPath.stringValue = ""
            self.lblPythonMessage.stringValue = "ERROR: Missing Python 3"
        }
    }
    
    @IBAction func onCheckComponentsClicked(_ sender: NSButton) {
        let _ = self.checkComponentStatus()
    }
    
    fileprivate func checkComponentStatus() -> Bool {
        let py3 = self.txtPythonPath.stringValue
        let brew = self.txtHomebrewPath.stringValue
        if py3 == "" || brew == "" {
            return false
        }
        if !FileManager.default.fileExists(atPath: py3) || !FileManager.default.fileExists(atPath: brew) {
            return false
        }
        self.btnCheckFaceComponents.isEnabled = false
        DispatchQueue.global().async {
            let pip = ExecutionEnvironment.default.locate("pip3")
            let pips = ExecutionEnvironment.default.pipList(pip)
            let brews = ExecutionEnvironment.default.brewList(brew)
            let casks = ExecutionEnvironment.default.brewCaskList(brew)
            
            var result = ""
            for component in ExecutionEnvironment.componentsForDlibFaceRecognition {
                if pips.contains(component) || brews.contains(component) || casks.contains(component) {
                    result += "INSTALLED: \(component)\n"
                }else{
                    result += "NOT FOUND: \(component)\n"
                }
            }
            DispatchQueue.main.async {
                self.lblComponentsStatus.stringValue = result
                self.btnCheckFaceComponents.isEnabled = true
            }
        }
        return true
    }
    
    @IBAction func onMajorFaceModelClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkAlternativeFaceRecognitionModel.state = .off
            self.selectedFaceModel = "major"
        }else{
            self.chkAlternativeFaceRecognitionModel.state = .on
            self.selectedFaceModel = "alternative"
        }
    }
    
    @IBAction func onAlternativeFaceModelClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkMajorFaceRecognitionModel.state = .off
            self.selectedFaceModel = "alternative"
        }else{
            self.chkMajorFaceRecognitionModel.state = .on
            self.selectedFaceModel = "major"
        }
    }
    
    @IBAction func onBrowseAlternativeFaceModelClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = false
        openPanel.canChooseFiles        = true
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = false
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    if path != "" {
                        self.txtAlternativeFaceModelPath.stringValue = path
                    }
                }
            }
        }
    }
    
    @IBAction func onBaiduLinkClicked(_ sender: Any) {
        if let url = URL(string: "http://lbsyun.baidu.com"),
            NSWorkspace.shared.open(url) {
            print("triggered link \(url)")
        }
    }
    
    @IBAction func onGoogleLinkClicked(_ sender: Any) {
        if let url = URL(string: "https://developers.google.com/maps/documentation/maps-static/intro"),
            NSWorkspace.shared.open(url) {
            print("triggered link \(url)")
        }
    }
    
    @IBAction func onLocateIfuseClicked(_ sender: NSButton) {
        let path = ExecutionEnvironment.default.locate("ifuse")
        if path != "" {
            self.txtIfusePath.stringValue = path
            self.lblIfuseMessage.stringValue = ""
        }else{
            self.txtIfusePath.stringValue = ""
            self.lblIfuseMessage.stringValue = "ERROR: Missing ifuse"
        }
    }
    
    @IBAction func onLocateIdeviceIdClicked(_ sender: NSButton) {
        let path = ExecutionEnvironment.default.locate("idevice_id")
        if path != "" {
            self.txtIdeviceIdPath.stringValue = path
            self.lblIdeviceIdMessage.stringValue = ""
        }else{
            self.txtIdeviceIdPath.stringValue = ""
            self.lblIdeviceIdMessage.stringValue = "ERROR: Missing imobiledevice"
        }
    }
    
    @IBAction func onLocateIdeviceInfoClicked(_ sender: NSButton) {
        let path = ExecutionEnvironment.default.locate("ideviceinfo")
        if path != "" {
            self.txtIdeviceInfoPath.stringValue = path
            self.lblIdeviceInfoMessage.stringValue = ""
        }else{
            self.txtIdeviceInfoPath.stringValue = ""
            self.lblIdeviceInfoMessage.stringValue = "ERROR: Missing imobiledevice"
        }
    }
    
    @IBAction func onFindDatabaseBackupClicked(_ sender: NSButton) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: self.lblDatabaseBackupPath.stringValue)])
    }
    
    // MARK: PAGINATION
    
    class func amountForPagination() -> Int {
        let defaults = UserDefaults.standard
        let value = defaults.integer(forKey: amountForPaginationKey)
        return value
    }
    
    // MARK: MEMORY USAGE
    
    class func peakMemory() -> Int {
        
        let totalRam = ProcessInfo.processInfo.physicalMemory / 1024 / 1024 / 1024
        let max = Int(totalRam)
        let mid = Int(totalRam / 2)
        let defaults = UserDefaults.standard
        let value = defaults.integer(forKey: memoryPeakKey)
        if value > max {
            return mid
        }
        return value
    }
    
    // MARK: FACE RECOGNITION
    
    
    class func homebrewPath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: homebrewKey) else {return ""}
        return txt
    }
    
    class func pythonPath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: pythonKey) else {return ""}
        return txt
    }
    
    class func faceRecognitionModel() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: faceRecognitionModelKey) else {return "major"}
        return txt
    }
    
    class func alternativeFaceModel() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: alternativeFaceModelPathKey) else {return ""}
        return txt
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
    
    class func networkDatabaseLocation() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: networkDatabaseLocationKey) else {return ""}
        return txt
    }
    
    class func networkStoragePrefix() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: networkStoragePrefixKey) else {return ""}
        return txt
    }
    
    class func storageLocationSelection() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: storageLocationKey) else {return ""}
        return txt
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
    
    class func ideviceidPath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: ideviceidKey) else {return ""}
        return txt
    }
    
    class func ideviceinfoPath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: ideviceinfoKey) else {return ""}
        return txt
    }
    
    class func ifusePath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: ifuseKey) else {return ""}
        return txt
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
        defaults.set(txtNetworkDatabaseLocation.stringValue,
                     forKey: PreferencesController.networkDatabaseLocationKey)
        defaults.set(txtNetworkStoragePrefix.stringValue,
                     forKey: PreferencesController.networkStoragePrefixKey)
        defaults.set(self.selectedStorageLocation,
                     forKey: PreferencesController.storageLocationKey)
        defaults.set(txtIOSMountPoint.stringValue,
                     forKey: PreferencesController.iosMountPointKey)
        defaults.set(txtIfusePath.stringValue,
                     forKey: PreferencesController.ifuseKey)
        defaults.set(txtIdeviceIdPath.stringValue,
                     forKey: PreferencesController.ideviceidKey)
        defaults.set(txtIdeviceInfoPath.stringValue,
                     forKey: PreferencesController.ideviceinfoKey)
        defaults.set(txtHomebrewPath.stringValue,
                     forKey: PreferencesController.homebrewKey)
        defaults.set(txtPythonPath.stringValue,
                     forKey: PreferencesController.pythonKey)
        defaults.set(txtAlternativeFaceModelPath.stringValue,
                     forKey: PreferencesController.alternativeFaceModelPathKey)
        defaults.set(self.selectedFaceModel,
                     forKey: PreferencesController.faceRecognitionModelKey)
        defaults.set(Int(self.memorySlider.intValue),
                     forKey: PreferencesController.memoryPeakKey)
        
        var paginationAmount = 0
        if self.lstAmountForPagination.stringValue != "Unlimited" {
            paginationAmount = Int(self.lstAmountForPagination.titleOfSelectedItem ?? "0") ?? 0
        }
        print("SET AMOUNT FOR PAGINATION AS \(paginationAmount)")
        defaults.set(paginationAmount,
                     forKey: PreferencesController.amountForPaginationKey)

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
        txtNetworkDatabaseLocation.stringValue = PreferencesController.networkDatabaseLocation()
        txtNetworkStoragePrefix.stringValue = PreferencesController.networkStoragePrefix()
        self.selectedStorageLocation = PreferencesController.storageLocationSelection()
        if self.selectedStorageLocation == "local" {
            self.chkLocalLocation.state = .on
            self.chkNetworkLocation.state = .off
        }else{
            self.chkLocalLocation.state = .off
            self.chkNetworkLocation.state = .on
        }
        
        txtIOSMountPoint.stringValue = PreferencesController.iosDeviceMountPoint()
        txtIfusePath.stringValue = PreferencesController.ifusePath()
        txtIdeviceIdPath.stringValue = PreferencesController.ideviceidPath()
        txtIdeviceInfoPath.stringValue = PreferencesController.ideviceinfoPath()
        txtExportToAndroidPath.stringValue = PreferencesController.exportToAndroidDirectory()
        txtHomebrewPath.stringValue = PreferencesController.homebrewPath()
        txtPythonPath.stringValue = PreferencesController.pythonPath()
        lblMajorFaceModelPath.stringValue = FaceRecognition.defaultModelPath
        txtAlternativeFaceModelPath.stringValue = PreferencesController.alternativeFaceModel()
        self.selectedFaceModel = PreferencesController.faceRecognitionModel()
        if self.selectedFaceModel == "major" {
            self.chkMajorFaceRecognitionModel.state = .on
            self.chkAlternativeFaceRecognitionModel.state = .off
        }else{
            self.chkMajorFaceRecognitionModel.state = .off
            self.chkAlternativeFaceRecognitionModel.state = .on
        }
        
        self.btnCheckFaceComponents.isEnabled = false
        var result = ""
        self.lblComponentsInstruction.string = ExecutionEnvironment.instructionForDlibFaceRecognition
        var testing = true
        if PreferencesController.pythonPath() != "" && PreferencesController.homebrewPath() != "" {
            testing = self.checkComponentStatus()
        }
        if testing {
            for component in ExecutionEnvironment.componentsForDlibFaceRecognition {
                result += "CHECKING: \(component)\n"
            }
        }else{
            self.btnCheckFaceComponents.isEnabled = true
            for component in ExecutionEnvironment.componentsForDlibFaceRecognition {
                result += "REQUIRED: \(component)\n"
            }
        }
        self.lblComponentsStatus.stringValue = result
        self.lblDatabaseBackupPath.stringValue = URL(fileURLWithPath: PreferencesController.databasePath()).appendingPathComponent("DataBackup").path
        self.setupMemorySlider()
        if PreferencesController.networkDatabaseLocation() != "" {
            self.lblNetworkDBBackupLocation.stringValue = URL(fileURLWithPath: PreferencesController.networkDatabaseLocation()).appendingPathComponent("DataBackup").path
        }
        let paginationAmount = PreferencesController.amountForPagination()
        print("GOT AMOUNT FOR PAGINATION \(paginationAmount)")
        if paginationAmount == 0 {
            self.lstAmountForPagination.selectItem(withTitle: "Unlimited")
        }else{
            self.lstAmountForPagination.selectItem(withTitle: "\(paginationAmount)")
        }
    }
    
    fileprivate func setupMemorySlider() {
        let totalRam = ProcessInfo.processInfo.physicalMemory / 1024 / 1024 / 1024
        self.memorySlider.maxValue = Double(totalRam)
        self.memorySlider.minValue = 0
        self.memorySlider.numberOfTickMarks = Int(totalRam) + 1
        self.memorySlider.allowsTickMarkValuesOnly = true
        self.memorySlider.tickMarkPosition = .below
        self.memorySlider.altIncrementValue = 1
        self.lblMinMemory.stringValue = "0 (Unlimited)"
        self.lblMaxMemory.stringValue = "\(totalRam) GB"
        self.lblMidMemory.stringValue = "\(totalRam / 2) GB"
        self.lblMin2Memory.stringValue = "\(totalRam / 2 - totalRam / 4) GB"
        self.lblMid2Memory.stringValue = "\(totalRam / 2 + totalRam / 4) GB"
        self.memorySlider.intValue = Int32(PreferencesController.peakMemory())
        let value = self.memorySlider.intValue
        if value > 0 {
            self.lblSelectedMemory.stringValue = "Selected \(value) GB as Peak"
        }else{
            self.lblSelectedMemory.stringValue = "Selected Unlimited"
        }
        
    }
    
    @IBAction func onMemorySliderClicked(_ sender: NSSlider) {
        let value = self.memorySlider.intValue
        if value > 0 {
            self.lblSelectedMemory.stringValue = "Selected \(value) GB as Peak"
        }else{
            self.lblSelectedMemory.stringValue = "Selected Unlimited"
        }
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
