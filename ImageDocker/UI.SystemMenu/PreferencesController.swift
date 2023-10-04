//
//  PreferencesController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/23.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

final class PreferencesController: NSViewController {
    
    let logger = LoggerFactory.get(category: "PreferencesController")
    
    // Postgres DB date timezone offset (hours)
    static let postgresTimestampTimezoneOffset = "+8"
    
    // MARK: - KEYS
    fileprivate static let volumesKey = "VolumesKey"
    
    // MARK: FACE RECOGNITION
//    fileprivate static let homebrewKey = "HomebrewKey"
//    fileprivate static let pythonKey = "PythonKey"
//    fileprivate static let faceRecognitionModelKey = "FaceRecognitionModelKey"
//    fileprivate static let alternativeFaceModelPathKey = "AlternativeFaceModelPathKey"
    
    // MARK: - UI FIELDS
    @IBOutlet weak var tabs: NSTabView!
    
    @IBOutlet weak var btnApply: NSButton!
    
    
    // MARK: GENERAL
    @IBOutlet weak var lblLanguage: NSTextField!
    @IBOutlet weak var popupLanguage: NSPopUpButton!
    
    @IBOutlet weak var boxLogging: NSBox!
    @IBOutlet weak var lblLogPath: NSTextField!
    @IBOutlet weak var txtLogPath: NSTextField!
    @IBOutlet weak var btnBrowseLogPath: NSButton!
    @IBOutlet weak var btnOpenLogPath: NSButton!
    
    
    // MARK: MOBILE DEVICE
    @IBOutlet weak var txtExportToAndroidPath: NSTextField!
    
    @IBOutlet weak var boxAndroid: NSBox!
    @IBOutlet weak var lblAndroidPathForUpload: NSTextField!
    @IBOutlet weak var lblAndroidPromptForUpload: NSTextField!
    
    
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
    
    // MARK: - ACTION FOR GENERAL SECTION
    
    @IBAction func onBrowseLogPath(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories  = true
        openPanel.canChooseFiles        = false
        openPanel.showsHiddenFiles      = false
        openPanel.canCreateDirectories  = true
        
        openPanel.beginSheetModal(for: self.view.window!) { (response) -> Void in
            guard response == NSApplication.ModalResponse.OK else {return}
            if let path = openPanel.url?.path {
                DispatchQueue.main.async {
                    self.txtLogPath.stringValue = path
                }
            }
        }
    }
    
    @IBAction func onOpenLogPathClicked(_ sender: NSButton) {
        let path = self.txtLogPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if path != "" && path.isDirectoryExists() {
            let url = URL(fileURLWithPath: path.withLastStash())
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
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
    
    // MARK: - SAVE SETTINGS
    
    func saveGeneralSection(_ defaults:UserDefaults) {
        let oldValue = Setting.UI.language()
        
        let lang = self.popupLanguage.titleOfSelectedItem ?? "English"
        var value = "eng"
        if lang == "English" {
            value = "eng"
        }else if lang == "Chinese Simplified" {
            value = "chs"
        }
        Setting.UI.saveLanguage(value)
        
        if oldValue != value {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: ChangeEvent.language), object: nil)
        }
        
        let logPath = self.txtLogPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if logPath != "" && logPath.isDirectoryExists() {
            Setting.logging.saveLogPath(logPath)
        }
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
        Setting.mobileDeviceTransfer.saveExportToAndroidDirectory(txtExportToAndroidPath.stringValue)
    }
    
    func savePerformanceSection(_ defaults:UserDefaults) {
        Setting.performance.savePeakMemory(Int(self.memorySlider.intValue))
        Setting.performance.saveAmountForPagination(self.lstAmountForPagination.titleOfSelectedItem ?? Words.preference_tab_performance_pagination_unlimited.word())
    }
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        
        self.saveGeneralSection(defaults)
        self.savePerformanceSection(defaults)
        self.saveMobileSection(defaults)
    }
    
    // MARK: - HEALTH CHECK
    
    class func healthCheck() {
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
        self.lblAndroidPathForUpload.stringValue = Words.preference_tab_mobile_box_android_path.word()
        self.lblAndroidPromptForUpload.stringValue = Words.preference_tab_mobile_box_android_prompt.word()
        
        txtExportToAndroidPath.stringValue = Setting.mobileDeviceTransfer.exportToAndroidDirectory()
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
    
    func initGeneral() {
        self.lblLanguage.stringValue = Words.preference_tab_general_ui_language.word()
        let language = Setting.UI.language()
        if language == "eng" {
            self.popupLanguage.selectItem(withTitle: "English")
        }else if language == "chs" {
            self.popupLanguage.selectItem(withTitle: "Chinese Simplified")
        }else{
            self.popupLanguage.selectItem(withTitle: "English")
        }
        
        self.boxLogging.title = Words.preference_tab_general_box_logging.word()
        self.lblLogPath.stringValue = Words.preference_tab_general_log_path.word()
        self.btnBrowseLogPath.title = Words.preference_tab_general_log_path_browse.word()
        self.btnOpenLogPath.title = Words.preference_tab_general_log_path_reveal_in_finder.word()
        
        self.txtLogPath.stringValue = Setting.logging.logPath()
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
        let paginationAmount = Setting.performance.amountForPagination()
//        self.logger.log("GOT AMOUNT FOR PAGINATION \(paginationAmount)")
        self.lstAmountForPagination.item(at: 0)?.title = Words.preference_tab_performance_pagination_unlimited.word()
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
        
    }
    
    func setupTabs() {
        self.view.window?.title = Words.mainmenu_preferences.word()
        self.btnApply.title = Words.apply.word()
        self.tabs.tabViewItem(at: 0).label = Words.preference_tab_general.word()
        self.tabs.tabViewItem(at: 1).label = Words.preference_tab_performance.word()
        self.tabs.tabViewItem(at: 2).label = Words.preference_tab_mobile.word()
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
        self.memorySlider.intValue = Int32(Setting.performance.peakMemory())
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
}

