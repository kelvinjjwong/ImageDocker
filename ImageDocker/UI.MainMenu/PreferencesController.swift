//
//  PreferencesController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/23.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

final class PreferencesController: NSViewController {
    
    let logger = ConsoleLogger(category: "PreferencesController")
    
    // Postgres DB date timezone offset (hours)
    static let postgresTimestampTimezoneOffset = "+8"
    
    // MARK: - KEYS
    fileprivate static let volumesKey = "VolumesKey"
    
    fileprivate static let languageKey = "LanguageKey"
    
    // MARK: GEOLOCATION API
    fileprivate static let baiduAKKey = "BaiduAKKey"
    fileprivate static let baiduSKKey = "BaiduSKKey"
    fileprivate static let googleAKKey = "GoogleAPIKey"
    
    // MARK: MOBILE DEVICE
    fileprivate static let exportToAndroidPathKey = "ExportToAndroidPath"
    fileprivate static let iosMountPointKey = "IOSMountPointKey"
    fileprivate static let ifuseKey = "ifuseKey"
    fileprivate static let ideviceidKey = "ideviceidKey"
    fileprivate static let ideviceinfoKey = "ideviceinfoKey"
    
    // MARK: FACE RECOGNITION
//    fileprivate static let homebrewKey = "HomebrewKey"
//    fileprivate static let pythonKey = "PythonKey"
//    fileprivate static let faceRecognitionModelKey = "FaceRecognitionModelKey"
//    fileprivate static let alternativeFaceModelPathKey = "AlternativeFaceModelPathKey"
    
    // MARK: PERFORMANCE
    fileprivate static let memoryPeakKey = "memoryPeakKey"
    fileprivate static let amountForPaginationKey = "amountForPaginationKey"
    
    // MARK: - UI FIELDS
    @IBOutlet weak var tabs: NSTabView!
    
    @IBOutlet weak var btnApply: NSButton!
    
    
    // MARK: GENERAL
    @IBOutlet weak var lblLanguage: NSTextField!
    @IBOutlet weak var popupLanguage: NSPopUpButton!
    
    
    // MARK: GEOLOCATION API
    @IBOutlet weak var txtBaiduAK: NSTextField!
    @IBOutlet weak var txtBaiduSK: NSTextField!
    @IBOutlet weak var txtGoogleAPIKey: NSTextField!
    
    @IBOutlet weak var boxBaiduMap: NSBox!
    @IBOutlet weak var boxGoogleMap: NSBox!
    @IBOutlet weak var lblBaiduMapPrompt: NSTextField!
    @IBOutlet weak var lblGoogleMapPrompt: NSTextField!
    
    // MARK: MOBILE DEVICE
    @IBOutlet weak var txtIOSMountPoint: NSTextField!
    @IBOutlet weak var txtExportToAndroidPath: NSTextField!
    @IBOutlet weak var txtHomebrewPath: NSTextField!
    @IBOutlet weak var txtIfusePath: NSTextField!
    @IBOutlet weak var txtIdeviceIdPath: NSTextField!
    @IBOutlet weak var txtIdeviceInfoPath: NSTextField!
    @IBOutlet weak var lblIOSMountPointMessage: NSTextField!
    @IBOutlet weak var lblIfuseMessage: NSTextField!
    @IBOutlet weak var lblIdeviceIdMessage: NSTextField!
    @IBOutlet weak var lblIdeviceInfoMessage: NSTextField!
    
    @IBOutlet weak var boxAndroid: NSBox!
    @IBOutlet weak var boxIOS: NSBox!
    @IBOutlet weak var lblAndroidPathForUpload: NSTextField!
    @IBOutlet weak var lblAndroidPromptForUpload: NSTextField!
    @IBOutlet weak var lblIOSMountPoint: NSTextField!
    @IBOutlet weak var lblIOSInstallGuideline: NSTextField!
    @IBOutlet weak var btnBrowseIOSMountPoint: NSButton!
    @IBOutlet weak var btnLocateIfusePath: NSButton!
    @IBOutlet weak var btnLocateIdeviceIdPath: NSButton!
    @IBOutlet weak var btnLocateIdeviceInfoPath: NSButton!
    
    
    // MARK: FACE RECOGNITION
//    @IBOutlet weak var txtPythonPath: NSTextField!
//    @IBOutlet weak var lblHomebrewMessage: NSTextField!
//    @IBOutlet weak var lblPythonMessage: NSTextField!
//    @IBOutlet weak var lblComponentsStatus: NSTextField!
//    @IBOutlet weak var chkMajorFaceRecognitionModel: NSButton!
//    @IBOutlet weak var chkAlternativeFaceRecognitionModel: NSButton!
//    @IBOutlet weak var lblMajorFaceModelPath: NSTextField!
//    @IBOutlet weak var txtAlternativeFaceModelPath: NSTextField!
//    @IBOutlet weak var btnCheckFaceComponents: NSButton!
//    @IBOutlet var lblComponentsInstruction: NSTextView!
    
    // MARK: PERFORMANCE
    @IBOutlet weak var memorySlider: NSSlider!
    @IBOutlet weak var lblMinMemory: NSTextField!
    @IBOutlet weak var lblMidMemory: NSTextField!
    @IBOutlet weak var lblMaxMemory: NSTextField!
    @IBOutlet weak var lblSelectedMemory: NSTextField!
    @IBOutlet weak var lblMin2Memory: NSTextField!
    @IBOutlet weak var lblMid2Memory: NSTextField!
    @IBOutlet weak var lstAmountForPagination: NSPopUpButton!
    
    @IBOutlet weak var boxMemoryLimit: NSBox!
    @IBOutlet weak var boxPagination: NSBox!
    @IBOutlet weak var lblMemoryLimit: NSTextField!
    @IBOutlet weak var lblPaginationPromptLeft: NSTextField!
    @IBOutlet weak var lblPaginationPromptRight: NSTextField!
    
    
    
    // MARK: - SAVE BUTTON
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        self.savePreferences()
        self.dismiss(sender)
    }
    
    // MARK: - ACTION FOR PERFORMANCE SECTION
    
    @IBAction func onMemorySliderClicked(_ sender: NSSlider) {
        let value = self.memorySlider.intValue
        if value > 0 {
            self.lblSelectedMemory.stringValue = Words.preference_tab_performance_selected_memory.fill(arguments: "\(value)")
        }else{
            self.lblSelectedMemory.stringValue = Words.preference_tab_performance_selected_memory_unlimited.word()
        }
    }
    
    // MARK: - ACTION FOR FACE RECOGNITION SECTION
    
//    @IBAction func onLocateHomebrewClicked(_ sender: NSButton) {
//        let path = ExecutionEnvironment.default.locate("brew")
//        if path != "" {
//            self.txtHomebrewPath.stringValue = path
//            self.lblHomebrewMessage.stringValue = ""
//        }else{
//            self.txtHomebrewPath.stringValue = ""
//            self.lblHomebrewMessage.stringValue = "ERROR: Missing Homebrew"
//        }
//    }
//    
//    @IBAction func onLocatePythonClicked(_ sender: NSButton) {
//        let path = ExecutionEnvironment.default.locate("python3")
//        if path != "" {
//            self.txtPythonPath.stringValue = path
//            self.lblPythonMessage.stringValue = ""
//        }else{
//            self.txtPythonPath.stringValue = ""
//            self.lblPythonMessage.stringValue = "ERROR: Missing Python 3"
//        }
//    }
//    
//    @IBAction func onCheckComponentsClicked(_ sender: NSButton) {
//        let _ = self.checkComponentStatus()
//    }
//    
//    fileprivate func checkComponentStatus() -> Bool {
//        let py3 = self.txtPythonPath.stringValue
//        let brew = self.txtHomebrewPath.stringValue
//        if py3 == "" || brew == "" {
//            return false
//        }
//        if !FileManager.default.fileExists(atPath: py3) || !FileManager.default.fileExists(atPath: brew) {
//            return false
//        }
//        self.btnCheckFaceComponents.isEnabled = false
//        DispatchQueue.global().async {
//            let pip = ExecutionEnvironment.default.locate("pip3")
//            let pips = ExecutionEnvironment.default.pipList(pip)
//            let brews = ExecutionEnvironment.default.brewList(brew)
//            let casks = ExecutionEnvironment.default.brewCaskList(brew)
//            
//            var result = ""
//            for component in ExecutionEnvironment.componentsForDlibFaceRecognition {
//                if pips.contains(component) || brews.contains(component) || casks.contains(component) {
//                    result += "INSTALLED: \(component)\n"
//                }else{
//                    result += "NOT FOUND: \(component)\n"
//                }
//            }
//            DispatchQueue.main.async {
//                self.lblComponentsStatus.stringValue = result
//                self.btnCheckFaceComponents.isEnabled = true
//            }
//        }
//        return true
//    }
    
    // MARK: TOGGLE GROUP - FACE MODEL
    
//    private var toggleGroup_FaceModel:ToggleGroup!
//
//    @IBAction func onMajorFaceModelClicked(_ sender: NSButton) {
//        self.toggleGroup_FaceModel.selected = "major"
//    }
//
//    @IBAction func onAlternativeFaceModelClicked(_ sender: NSButton) {
//        self.toggleGroup_FaceModel.selected = "alternative"
//    }
//
//    @IBAction func onBrowseAlternativeFaceModelClicked(_ sender: NSButton) {
//        let openPanel = NSOpenPanel()
//        openPanel.canChooseDirectories  = false
//        openPanel.canChooseFiles        = true
//        openPanel.showsHiddenFiles      = false
//        openPanel.canCreateDirectories  = false
//
//        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
//            guard response == NSApplication.ModalResponse.OK else {return}
//            if let path = openPanel.url?.path {
//                DispatchQueue.main.async {
//                    if path != "" {
//                        self.txtAlternativeFaceModelPath.stringValue = path
//                    }
//                }
//            }
//        }
//    }
    
    // MARK: - ACTION FOR GEOLOCATION API SECTION
    
    @IBAction func onBaiduLinkClicked(_ sender: Any) {
        if let url = URL(string: "http://lbsyun.baidu.com"),
            NSWorkspace.shared.open(url) {
            self.logger.log("triggered link \(url)")
        }
    }
    
    @IBAction func onGoogleLinkClicked(_ sender: Any) {
        if let url = URL(string: "https://developers.google.com/maps/documentation/maps-static/intro"),
            NSWorkspace.shared.open(url) {
            self.logger.log("triggered link \(url)")
        }
    }
    
    // MARK: - ACTION FOR MOBILE DEVICE SECTION
    
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
            self.lblIfuseMessage.stringValue = ""
        }else{
            self.txtIfusePath.stringValue = ""
            self.lblIfuseMessage.stringValue = Words.preference_tab_missing_error.fill(arguments: "ifuse")
        }
    }
    
    @IBAction func onLocateIdeviceIdClicked(_ sender: NSButton) {
        let path = ExecutionEnvironment.default.locate("idevice_id")
        if path != "" {
            self.txtIdeviceIdPath.stringValue = path
            self.lblIdeviceIdMessage.stringValue = ""
        }else{
            self.txtIdeviceIdPath.stringValue = ""
            self.lblIdeviceIdMessage.stringValue = Words.preference_tab_missing_error.fill(arguments: "imobiledevice")
        }
    }
    
    @IBAction func onLocateIdeviceInfoClicked(_ sender: NSButton) {
        let path = ExecutionEnvironment.default.locate("ideviceinfo")
        if path != "" {
            self.txtIdeviceInfoPath.stringValue = path
            self.lblIdeviceInfoMessage.stringValue = ""
        }else{
            self.txtIdeviceInfoPath.stringValue = ""
            self.lblIdeviceInfoMessage.stringValue = Words.preference_tab_missing_error.fill(arguments: "imobiledevice")
        }
    }
    
    // MARK: - READ SETTINGS
    
    // MARK: GENERAL
    
    class func language() -> String {
        let defaults = UserDefaults.standard
        let value = defaults.string(forKey: languageKey) ?? "eng"
        return value
    }
    
    // MARK: PERFORMANCE
    
    class func amountForPagination() -> Int {
        let defaults = UserDefaults.standard
        let value = defaults.integer(forKey: amountForPaginationKey)
        return value
    }
    
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
    
    
//    class func homebrewPath() -> String {
//        let defaults = UserDefaults.standard
//        guard let txt = defaults.string(forKey: homebrewKey) else {return ""}
//        return txt
//    }
//
//    class func pythonPath() -> String {
//        let defaults = UserDefaults.standard
//        guard let txt = defaults.string(forKey: pythonKey) else {return ""}
//        return txt
//    }
//
//    class func faceRecognitionModel() -> String {
//        let defaults = UserDefaults.standard
//        guard let txt = defaults.string(forKey: faceRecognitionModelKey) else {return "major"}
//        return txt
//    }
//
//    class func alternativeFaceModel() -> String {
//        let defaults = UserDefaults.standard
//        guard let txt = defaults.string(forKey: alternativeFaceModelPathKey) else {return ""}
//        return txt
//    }
    
    // MARK: GEOLOCATION API
    
    
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
    
    class func googleAPIKey() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: googleAKKey) else {return ""}
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
    
    // MARK: ANDROID
    
    class func exportToAndroidDirectory() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: exportToAndroidPathKey) else {return ""}
        return txt
    }
    
    // MARK: - SAVE SETTINGS
    
    func saveGeneralSection(_ defaults:UserDefaults) {
        let oldValue = PreferencesController.language()
        
        let lang = self.popupLanguage.titleOfSelectedItem ?? "English"
        var value = "eng"
        if lang == "English" {
            value = "eng"
        }else if lang == "Chinese Simplified" {
            value = "chs"
        }
        defaults.set(value,
                     forKey: PreferencesController.languageKey)
        
        if oldValue != value {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ChangeEvent.language), object: nil)
        }
    }
    
    func saveGeolocationAPISection(_ defaults:UserDefaults) {
        
        defaults.set(txtGoogleAPIKey.stringValue,
                     forKey: PreferencesController.googleAKKey)
        defaults.set(txtBaiduAK.stringValue,
                     forKey: PreferencesController.baiduAKKey)
        defaults.set(txtBaiduSK.stringValue,
                     forKey: PreferencesController.baiduSKKey)
    }
    
//    func saveFaceRecognitionSection(_ defaults:UserDefaults) {
//        defaults.set(txtHomebrewPath.stringValue,
//                     forKey: PreferencesController.homebrewKey)
//        defaults.set(txtPythonPath.stringValue,
//                     forKey: PreferencesController.pythonKey)
//        defaults.set(txtAlternativeFaceModelPath.stringValue,
//                     forKey: PreferencesController.alternativeFaceModelPathKey)
//        defaults.set(self.toggleGroup_FaceModel.selected,
//                     forKey: PreferencesController.faceRecognitionModelKey)
//    }
    
    func saveMobileSection(_ defaults:UserDefaults) {
        
        defaults.set(txtIOSMountPoint.stringValue,
                     forKey: PreferencesController.iosMountPointKey)
        defaults.set(txtIfusePath.stringValue,
                     forKey: PreferencesController.ifuseKey)
        defaults.set(txtIdeviceIdPath.stringValue,
                     forKey: PreferencesController.ideviceidKey)
        defaults.set(txtIdeviceInfoPath.stringValue,
                     forKey: PreferencesController.ideviceinfoKey)
        defaults.set(txtExportToAndroidPath.stringValue,
                     forKey: PreferencesController.exportToAndroidPathKey)
    }
    
    func savePerformanceSection(_ defaults:UserDefaults) {
        defaults.set(Int(self.memorySlider.intValue),
                     forKey: PreferencesController.memoryPeakKey)
        
        var paginationAmount = 0
        if self.lstAmountForPagination.stringValue != "Unlimited" {
            paginationAmount = Int(self.lstAmountForPagination.titleOfSelectedItem ?? "0") ?? 0
        }
        self.logger.log("SET AMOUNT FOR PAGINATION AS \(paginationAmount)")
        defaults.set(paginationAmount,
                     forKey: PreferencesController.amountForPaginationKey)
    }
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        
        self.saveGeneralSection(defaults)
        self.savePerformanceSection(defaults)
        self.saveMobileSection(defaults)
//        self.saveFaceRecognitionSection(defaults)
        self.saveGeolocationAPISection(defaults)
    }
    
    // MARK: - HEALTH CHECK
    
    class func healthCheck() {
        
        if baiduAK() == "" || baiduSK() == "" {
            // TODO: notify user when geolocation API missing
            //Alert.invalidBaiduMapAK()
            return
        }
    }
    
    class func saveRepositoryVolumes(_ volumes:[String]) {
        let defaults = UserDefaults.standard
        defaults.set(volumes,
                     forKey: PreferencesController.volumesKey)
    }
    
    class func getSavedRepositoryVolumes() -> [String] {
        let defaults = UserDefaults.standard
        guard let volumes = defaults.stringArray(forKey: volumesKey) else {return []}
        return volumes
        
    }
    
    // MARK: - INIT SECTIONS
    
    func initMobileSection() {
        self.boxAndroid.title = Words.preference_tab_mobile_box_android.word()
        self.boxIOS.title = Words.preference_tab_mobile_box_ios.word()
        self.lblAndroidPathForUpload.stringValue = Words.preference_tab_mobile_box_android_path.word()
        self.lblAndroidPromptForUpload.stringValue = Words.preference_tab_mobile_box_android_prompt.word()
        self.lblIOSMountPoint.stringValue = Words.preference_tab_mobile_box_ios_mount_point.word()
        self.btnBrowseIOSMountPoint.title = Words.preference_tab_mobile_box_ios_browse.word()
        self.btnLocateIfusePath.title = Words.preference_tab_mobile_box_ios_locate.word()
        self.btnLocateIdeviceIdPath.title = Words.preference_tab_mobile_box_ios_locate.word()
        self.btnLocateIdeviceInfoPath.title = Words.preference_tab_mobile_box_ios_locate.word()
        
        
        txtIOSMountPoint.stringValue = PreferencesController.iosDeviceMountPoint()
        txtIfusePath.stringValue = PreferencesController.ifusePath()
        txtIdeviceIdPath.stringValue = PreferencesController.ideviceidPath()
        txtIdeviceInfoPath.stringValue = PreferencesController.ideviceinfoPath()
        txtExportToAndroidPath.stringValue = PreferencesController.exportToAndroidDirectory()
    }
    
//    func initFaceRecognitionSection() {
//        txtHomebrewPath.stringValue = PreferencesController.homebrewPath()
//        txtPythonPath.stringValue = PreferencesController.pythonPath()
//        lblMajorFaceModelPath.stringValue = FaceRecognition.defaultModelPath
//        txtAlternativeFaceModelPath.stringValue = PreferencesController.alternativeFaceModel()
//
//
//        self.toggleGroup_FaceModel = ToggleGroup([
//            "major"       : self.chkMajorFaceRecognitionModel,
//            "alternative" : self.chkAlternativeFaceRecognitionModel
//        ])
//        self.toggleGroup_FaceModel.selected = PreferencesController.faceRecognitionModel()
//
//        self.btnCheckFaceComponents.isEnabled = false
//        var result = ""
//        self.lblComponentsInstruction.string = ExecutionEnvironment.instructionForDlibFaceRecognition
//        var testing = true
//        if PreferencesController.pythonPath() != "" && PreferencesController.homebrewPath() != "" {
//            testing = self.checkComponentStatus()
//        }
//        if testing {
//            for component in ExecutionEnvironment.componentsForDlibFaceRecognition {
//                result += "CHECKING: \(component)\n"
//            }
//        }else{
//            self.btnCheckFaceComponents.isEnabled = true
//            for component in ExecutionEnvironment.componentsForDlibFaceRecognition {
//                result += "REQUIRED: \(component)\n"
//            }
//        }
//        self.lblComponentsStatus.stringValue = result
//    }
    
    func initGeolocationAPISection() {
        self.boxBaiduMap.title = Words.preference_tab_geo_location_api_box_baidu.word()
        self.boxGoogleMap.title = Words.preference_tab_geo_location_api_box_google.word()
        self.lblBaiduMapPrompt.stringValue = Words.preference_tab_geo_location_api_prompt.word()
        self.lblGoogleMapPrompt.stringValue = Words.preference_tab_geo_location_api_prompt.word()
        
        txtBaiduAK.stringValue = PreferencesController.baiduAK()
        txtBaiduSK.stringValue = PreferencesController.baiduSK()
        txtGoogleAPIKey.stringValue = PreferencesController.googleAPIKey()
    }
    
    func initGeneral() {
        self.lblLanguage.stringValue = Words.preference_tab_general_ui_language.word()
        let language = PreferencesController.language()
        if language == "eng" {
            self.popupLanguage.selectItem(withTitle: "English")
        }else if language == "chs" {
            self.popupLanguage.selectItem(withTitle: "Chinese Simplified")
        }else{
            self.popupLanguage.selectItem(withTitle: "English")
        }
    }
    
    func initPerformanceSection() {
        self.boxMemoryLimit.title = Words.preference_tab_performance_box_memory_limit.word()
        self.lblMemoryLimit.stringValue = Words.preference_tab_performance_box_memory_limit_prompt.word()
        self.boxPagination.title = Words.preference_tab_performance_box_pagination.word()
        self.lblMinMemory.stringValue = Words.preference_tab_performance_slide_unlimited.word()
        self.boxPagination.title = Words.preference_tab_performance_box_pagination.word()
        self.lblPaginationPromptLeft.stringValue = Words.preference_tab_performance_box_pagination_prompt_left.word()
        self.lblPaginationPromptRight.stringValue = Words.preference_tab_performance_box_pagination_prompt_right.word()
        self.setupMemorySlider()
        let paginationAmount = PreferencesController.amountForPagination()
//        self.logger.log("GOT AMOUNT FOR PAGINATION \(paginationAmount)")
        if paginationAmount == 0 {
            self.lstAmountForPagination.selectItem(withTitle: Words.preference_tab_performance_pagination_unlimited.word())
        }else{
            self.lstAmountForPagination.selectItem(withTitle: "\(paginationAmount)")
        }
    }
    
    // MARK: VIEW INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Words.preference_dialog_title.word()
        // Do any additional setup after loading the view.
        self.setupTabs()
        self.initGeneral()
        self.initPerformanceSection()
        self.initMobileSection()
//        self.initFaceRecognitionSection()
        self.initGeolocationAPISection()
        
    }
    
    func setupTabs() {
        self.view.window?.title = Words.mainmenu_preferences.word()
        self.btnApply.title = Words.apply.word()
        self.tabs.tabViewItem(at: 0).label = Words.preference_tab_general.word()
        self.tabs.tabViewItem(at: 1).label = Words.preference_tab_performance.word()
        self.tabs.tabViewItem(at: 2).label = Words.preference_tab_mobile.word()
        self.tabs.tabViewItem(at: 3).label = Words.preference_tab_face_recognition.word()
        self.tabs.tabViewItem(at: 4).label = Words.preference_tab_geo_location_api.word()
    }
    
    fileprivate func setupMemorySlider() {
        let totalRam = ProcessInfo.processInfo.physicalMemory / 1024 / 1024 / 1024
        self.memorySlider.maxValue = Double(totalRam)
        self.memorySlider.minValue = 0
        self.memorySlider.numberOfTickMarks = Int(totalRam) + 1
        self.memorySlider.allowsTickMarkValuesOnly = true
        self.memorySlider.tickMarkPosition = .below
        self.memorySlider.altIncrementValue = 1
        self.lblMinMemory.stringValue = Words.preference_tab_performance_slide_unlimited.word()
        self.lblMaxMemory.stringValue = "\(totalRam) GB"
        self.lblMidMemory.stringValue = "\(totalRam / 2) GB"
        self.lblMin2Memory.stringValue = "\(totalRam / 2 - totalRam / 4) GB"
        self.lblMid2Memory.stringValue = "\(totalRam / 2 + totalRam / 4) GB"
        self.memorySlider.intValue = Int32(PreferencesController.peakMemory())
        let value = self.memorySlider.intValue
        if value > 0 {
            self.lblSelectedMemory.stringValue = Words.preference_tab_performance_selected_memory.fill(arguments: "\(value)")
        }else{
            self.lblSelectedMemory.stringValue = Words.preference_tab_performance_selected_memory_unlimited.word()
        }
        
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    var backupArchives:[(String, String, String, String)] = []
    
    var shouldLoadPostgresBackupArchives = true
}

