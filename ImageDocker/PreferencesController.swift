//
//  PreferencesController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/23.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

final class PreferencesController: NSViewController {
    
    // MARK: - KEYS
    
    // MARK: GEOLOCATION API
    fileprivate static let baiduAKKey = "BaiduAKKey"
    fileprivate static let baiduSKKey = "BaiduSKKey"
    fileprivate static let googleAKKey = "GoogleAPIKey"
    
    // MARK: DATABASE
    fileprivate static let databasePathKey = "DatabasePathKey"
    fileprivate static let databaseLocationKey = "DatabaseLocationKey"
    fileprivate static let remoteDBServerKey = "RemoteDBServer"
    fileprivate static let remoteDBPortKey = "RemoteDBPort"
    fileprivate static let remoteDBUsernameKey = "RemoteDBUsername"
    fileprivate static let remoteDBPasswordKey = "RemoteDBPassword"
    fileprivate static let remoteDBSchemaKey = "RemoteDBSchema"
    fileprivate static let remoteDBDatabaseKey = "RemoteDBDatabase"
    fileprivate static let remoteDBNoPasswordKey = "RemoteDBNoPassword"
    
    // MARK: MOBILE DEVICE
    fileprivate static let exportToAndroidPathKey = "ExportToAndroidPath"
    fileprivate static let iosMountPointKey = "IOSMountPointKey"
    fileprivate static let ifuseKey = "ifuseKey"
    fileprivate static let ideviceidKey = "ideviceidKey"
    fileprivate static let ideviceinfoKey = "ideviceinfoKey"
    
    // MARK: FACE RECOGNITION
    fileprivate static let homebrewKey = "HomebrewKey"
    fileprivate static let pythonKey = "PythonKey"
    fileprivate static let faceRecognitionModelKey = "FaceRecognitionModelKey"
    fileprivate static let alternativeFaceModelPathKey = "AlternativeFaceModelPathKey"
    
    // MARK: PERFORMANCE
    fileprivate static let memoryPeakKey = "memoryPeakKey"
    fileprivate static let amountForPaginationKey = "amountForPaginationKey"
    
    // MARK: - UI FIELDS
    @IBOutlet weak var tabs: NSTabView!
    
    // MARK: GEOLOCATION API
    @IBOutlet weak var txtBaiduAK: NSTextField!
    @IBOutlet weak var txtBaiduSK: NSTextField!
    @IBOutlet weak var txtGoogleAPIKey: NSTextField!
    
    // MARK: DATABASE
    @IBOutlet weak var chkLocalLocation: NSButton!
    @IBOutlet weak var chkNetworkLocation: NSButton!
    
    @IBOutlet weak var txtDatabasePath: NSTextField!
    @IBOutlet weak var lblDatabaseBackupPath: NSTextField!
    @IBOutlet weak var lblLocalSchemaVersion: NSTextField!
    
    
    @IBOutlet weak var txtRemoteDBServer: NSTextField!
    @IBOutlet weak var txtRemoteDBPort: NSTextField!
    @IBOutlet weak var txtRemoteDBUser: NSTextField!
    @IBOutlet weak var txtRemoteDBPassword: NSSecureTextField!
    @IBOutlet weak var txtRemoteDBSchema: NSTextField!
    @IBOutlet weak var txtRemoteDBDatabase: NSTextField!
    @IBOutlet weak var chkRemoteDBNoPassword: NSButton!
    @IBOutlet weak var btnRemoteDBTest: NSButton!
    @IBOutlet weak var lblNetworkVerifyMessage: NSTextField!
    @IBOutlet weak var lblRemoteSchemaVersion: NSTextField!
    
    
    @IBOutlet weak var btnCloneLocalToRemote: NSButton!
    @IBOutlet weak var btnCloneRemoteToLocal: NSButton!
    @IBOutlet weak var btnBackupLocal: NSButton!
    @IBOutlet weak var btnBackupRemote: NSButton!
    @IBOutlet weak var lblDataCloneMessage: NSTextField!
    @IBOutlet weak var chkDeleteAllBeforeClone: NSButton!
    
    
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
    
    // MARK: FACE RECOGNITION
    @IBOutlet weak var txtPythonPath: NSTextField!
    @IBOutlet weak var lblHomebrewMessage: NSTextField!
    @IBOutlet weak var lblPythonMessage: NSTextField!
    @IBOutlet weak var lblComponentsStatus: NSTextField!
    @IBOutlet weak var chkMajorFaceRecognitionModel: NSButton!
    @IBOutlet weak var chkAlternativeFaceRecognitionModel: NSButton!
    @IBOutlet weak var lblMajorFaceModelPath: NSTextField!
    @IBOutlet weak var txtAlternativeFaceModelPath: NSTextField!
    @IBOutlet weak var btnCheckFaceComponents: NSButton!
    @IBOutlet var lblComponentsInstruction: NSTextView!
    
    // MARK: PERFORMANCE
    @IBOutlet weak var memorySlider: NSSlider!
    @IBOutlet weak var lblMinMemory: NSTextField!
    @IBOutlet weak var lblMidMemory: NSTextField!
    @IBOutlet weak var lblMaxMemory: NSTextField!
    @IBOutlet weak var lblSelectedMemory: NSTextField!
    @IBOutlet weak var lblMin2Memory: NSTextField!
    @IBOutlet weak var lblMid2Memory: NSTextField!
    @IBOutlet weak var lstAmountForPagination: NSPopUpButton!
    
    
    fileprivate var selectedFaceModel = "major"
    
    
    // MARK: - SAVE BUTTON
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        self.savePreferences()
        self.dismiss(sender)
    }
    
    // MARK: - ACTION FOR PERFORMANCE SECTION
    
    @IBAction func onMemorySliderClicked(_ sender: NSSlider) {
        let value = self.memorySlider.intValue
        if value > 0 {
            self.lblSelectedMemory.stringValue = "Selected \(value) GB as Peak"
        }else{
            self.lblSelectedMemory.stringValue = "Selected Unlimited"
        }
    }
    
    // MARK: - ACTION FOR DATABASE SECTION
    
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
    
    @IBAction func onFindDatabaseBackupClicked(_ sender: NSButton) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: self.lblDatabaseBackupPath.stringValue)])
    }
    
    private var selectedDatabaseLocation = "local"
    
    @IBAction func onCheckLocalLocationClicked(_ sender: NSButton) {
        if selectedDatabaseLocation == "local" {
            self.chkLocalLocation.state = .off
            self.chkNetworkLocation.state = .on
            self.selectedDatabaseLocation = "network"
        }else{
            self.chkNetworkLocation.state = .off
            self.chkLocalLocation.state = .on
            self.selectedDatabaseLocation = "local"
        }
    }
    
    @IBAction func onCheckNetworkLocationClicked(_ sender: NSButton) {
        if selectedDatabaseLocation == "network" {
            self.chkLocalLocation.state = .on
            self.chkNetworkLocation.state = .off
            self.selectedDatabaseLocation = "local"
        }else{
            self.chkLocalLocation.state = .off
            self.chkNetworkLocation.state = .on
            self.selectedDatabaseLocation = "network"
        }
    }
    
    @IBAction func onCheckRemoteNopasswordClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.txtRemoteDBPassword.isEditable = false
        }else{
            self.txtRemoteDBPassword.isEditable = true
        }
    }
    
    
    @IBAction func onRemoteDBTestClicked(_ sender: NSButton) {
        self.lblDataCloneMessage.stringValue = "TODO function."
    }
    
    private func toggleDatabaseClonerButtons(state: Bool) {
        self.btnBackupLocal.isEnabled = state
        self.btnBackupRemote.isEnabled = state
        self.btnCloneLocalToRemote.isEnabled = state
        self.btnCloneRemoteToLocal.isEnabled = state
        self.chkDeleteAllBeforeClone.isEnabled = state
    }
    
    @IBAction func onCloneLocalToRemoteClicked(_ sender: NSButton) {
        let dropBeforeCreate = self.chkDeleteAllBeforeClone.state == .on
        self.toggleDatabaseClonerButtons(state: false)
        DispatchQueue.global().async {
            
            DispatchQueue.main.async {
                self.lblDataCloneMessage.stringValue = "Updating schema ..."
            }
            PostgresConnection.default.versionCheck(dropBeforeCreate: dropBeforeCreate)

            
            final class Version : PostgresCustomRecord {
                var ver:Int = 0
                public init() {}
            }
            
            if let version = Version.fetchOne(PostgresConnection.database(), sql: "select substring(ver, '\\d+')::int versions from version_migrations order by versions desc") {
                DispatchQueue.main.async {
                    self.lblRemoteSchemaVersion.stringValue = "v\(version.ver)"
                    self.lblDataCloneMessage.stringValue = "Remote DB schema version is v\(version.ver) now."
                }
                var containers:[ImageContainer] = []
                var images:[Image] = []
                var places:[ImagePlace] = []
                var events:[ImageEvent] = []
                var devices:[ImageDevice] = []
                var deviceFiles:[ImageDeviceFile] = []
                var devicePaths:[ImageDevicePath] = []
                var people:[People] = []
                var relationships:[PeopleRelationship] = []
                var imagePeople:[ImagePeople] = []
                var imageFaces:[ImageFace] = []
                var exportProfiles:[ExportProfile] = []
                var families:[Family] = []
                var familyMembers:[FamilyMember] = []
                var familyJoints:[FamilyJoint] = []
                do {
                    let db = try SQLiteConnectionGRDB.default.sharedDBPool()
                    try db.read { localdb in
                        DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Loading repositories data from local database..." }
                        containers = try ImageContainer.fetchAll(localdb)
                        
                        DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Loading images data from local database..." }
                        images = try Image.fetchAll(localdb)
                        
                        DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Loading places data from local database..." }
                        places = try ImagePlace.fetchAll(localdb)
                        
                        DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Loading events data from local database..." }
                        events = try ImageEvent.fetchAll(localdb)
                        
                        DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Loading devices data from local database..." }
                        devices = try ImageDevice.fetchAll(localdb)
                        deviceFiles = try ImageDeviceFile.fetchAll(localdb)
                        devicePaths = try ImageDevicePath.fetchAll(localdb)
                        
                        DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Loading face data from local database..." }
                        people = try People.fetchAll(localdb)
                        relationships = try PeopleRelationship.fetchAll(localdb)
                        imagePeople = try ImagePeople.fetchAll(localdb)
                        imageFaces = try ImageFace.fetchAll(localdb)
                        families = try Family.fetchAll(localdb)
                        familyMembers = try FamilyMember.fetchAll(localdb)
                        familyJoints = try FamilyJoint.fetchAll(localdb)
                        
                        DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Loading profile data from local database..." }
                        exportProfiles = try ExportProfile.fetchAll(localdb)
                    }

                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Loaded all data from local database..." }
                }catch{
                    print(error)

                    DispatchQueue.main.async { self.toggleDatabaseClonerButtons(state: true) }
                    return
                }
                
                let remotedb = PostgresConnection.database()
                var count = 0
                var i = 0
                count = containers.count
                DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning repositories data to remote database..." }
                for record in containers {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning repositories data to remote database... \(i) / \(count)" }
                }
                
                count = images.count
                i = 0
                DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning images data to remote database..." }
                for record in images {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning images data to remote database... \(i) / \(count)" }
                }
                
                count = places.count
                i = 0
                DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning places data to remote database..." }
                for record in places {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning places data to remote database... \(i) / \(count)" }
                }
                count = events.count
                i = 0
                DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning events data to remote database..." }
                for record in events {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning events data to remote database... \(i) / \(count)" }
                }
                count = devices.count + deviceFiles.count + devicePaths.count
                i = 0
                DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning devices data to remote database..." }
                for record in devices {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning devices data to remote database... \(i) / \(count)" }
                }
                for record in deviceFiles {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning devices data to remote database... \(i) / \(count)" }
                }
                for record in devicePaths {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning devices data to remote database... \(i) / \(count)" }
                }
                count = people.count + relationships.count + imagePeople.count + imageFaces.count + families.count + familyMembers.count + familyJoints.count
                i = 0
                DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning faces data to remote database..." }
                for record in people {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning faces data to remote database... \(i) / \(count)" }
                }
                for record in relationships {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning faces data to remote database... \(i) / \(count)" }
                }
                for record in imagePeople {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning faces data to remote database... \(i) / \(count)" }
                }
                for record in imageFaces {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning faces data to remote database... \(i) / \(count)" }
                }
                for record in families {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning faces data to remote database... \(i) / \(count)" }
                }
                for record in familyMembers {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning faces data to remote database... \(i) / \(count)" }
                }
                for record in familyJoints {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning faces data to remote database... \(i) / \(count)" }
                }
                count = exportProfiles.count
                i = 0
                DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning export profiles data to remote database..." }
                for record in exportProfiles {
                    record.save(remotedb)
                    i += 1
                    DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloning export profiles data to remote database... \(i) / \(count)" }
                }
                DispatchQueue.main.async { self.lblDataCloneMessage.stringValue = "Cloned all data to remote database." }
                
                DispatchQueue.main.async { self.toggleDatabaseClonerButtons(state: true) }
                return
            }else{
                DispatchQueue.main.async {
                    self.lblRemoteSchemaVersion.stringValue = "No schema"
                    self.lblDataCloneMessage.stringValue = "Something wrong happened. Please check console output."
                }
                DispatchQueue.main.async { self.toggleDatabaseClonerButtons(state: true) }
                return
            }
        }
        
    }
    
    @IBAction func onCloneRemoteToLocalClicked(_ sender: NSButton) {
        self.lblDataCloneMessage.stringValue = "TODO function."
    }
    
    @IBAction func onBackupLocalClicked(_ sender: NSButton) {
        self.lblDataCloneMessage.stringValue = "TODO function."
    }
    
    @IBAction func onBackupRemoteClicked(_ sender: NSButton) {
        self.lblDataCloneMessage.stringValue = "TODO function."
    }
    
    @IBAction func onLocalSchemaVersionClicked(_ sender: NSButton) {
        self.lblDataCloneMessage.stringValue = "TODO function."
    }
    
    @IBAction func onRemoteSchemaVersionClicked(_ sender: NSButton) {
        DispatchQueue.global().async {
            final class Version : PostgresCustomRecord {
                var ver:Int = 0
                public init() {}
            }
            
            if let version = Version.fetchOne(PostgresConnection.database(), sql: "select substring(ver, '\\d+')::int versions from version_migrations order by versions desc") {
                DispatchQueue.main.async {
                    self.lblRemoteSchemaVersion.stringValue = "v\(version.ver)"
                }
            }else{
                DispatchQueue.main.async {
                    self.lblRemoteSchemaVersion.stringValue = "No schema"
                }
            }
        }
    }
    
    
    // MARK: - ACTION FOR FACE RECOGNITION SECTION
    
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
    
    // MARK: - ACTION FOR GEOLOCATION API SECTION
    
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
    
    // MARK: - READ SETTINGS
    
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
    
    class func databaseLocation() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: databaseLocationKey) else {return "local"}
        return txt
    }
    
    
    
    class func remoteDBServer() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: remoteDBServerKey) else {return "127.0.0.1"}
        return txt
    }
    
    
    class func remoteDBPort() -> Int {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: remoteDBPortKey) else {return 5432}
        if let value = Int(txt) {
            return value
        }else{
            return 5432
        }
    }
    
    
    class func remoteDBUsername() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: remoteDBUsernameKey) else {return ""}
        return txt
    }
    
    
    class func remoteDBPassword() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: remoteDBPasswordKey) else {return ""}
        return txt
    }
    
    
    class func remoteDBSchema() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: remoteDBSchemaKey) else {return "public"}
        return txt
    }
    
    
    class func remoteDBDatabase() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: remoteDBDatabaseKey) else {return ""}
        return txt
    }
    
    
    class func remoteDBNoPassword() -> Bool {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: remoteDBNoPasswordKey) else {return true}
        if txt == "true"  {
            return true
        }else{
            return false
        }
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
    
    func saveGeolocationAPISection(_ defaults:UserDefaults) {
        
        defaults.set(txtGoogleAPIKey.stringValue,
                     forKey: PreferencesController.googleAKKey)
        defaults.set(txtBaiduAK.stringValue,
                     forKey: PreferencesController.baiduAKKey)
        defaults.set(txtBaiduSK.stringValue,
                     forKey: PreferencesController.baiduSKKey)
    }
    
    func saveFaceRecognitionSection(_ defaults:UserDefaults) {
        defaults.set(txtHomebrewPath.stringValue,
                     forKey: PreferencesController.homebrewKey)
        defaults.set(txtPythonPath.stringValue,
                     forKey: PreferencesController.pythonKey)
        defaults.set(txtAlternativeFaceModelPath.stringValue,
                     forKey: PreferencesController.alternativeFaceModelPathKey)
        defaults.set(self.selectedFaceModel,
                     forKey: PreferencesController.faceRecognitionModelKey)
    }
    
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
    
    func saveDatabaseSection(_ defaults:UserDefaults) {
        
        defaults.set(self.selectedDatabaseLocation,
                     forKey: PreferencesController.databaseLocationKey)
        
        defaults.set(txtDatabasePath.stringValue,
                     forKey: PreferencesController.databasePathKey)
        
        defaults.set(txtRemoteDBServer.stringValue,
                     forKey: PreferencesController.remoteDBServerKey)
        
        if let _ = Int(txtRemoteDBPort.stringValue) {
            defaults.set(txtRemoteDBPort.stringValue,
                         forKey: PreferencesController.remoteDBPortKey)
        }else{
            defaults.set("5432",
                         forKey: PreferencesController.remoteDBPortKey)
        }
        
        defaults.set(txtRemoteDBUser.stringValue,
                     forKey: PreferencesController.remoteDBUsernameKey)
        
        defaults.set(txtRemoteDBPassword.stringValue,
                     forKey: PreferencesController.remoteDBPasswordKey)
        
        defaults.set(txtRemoteDBSchema.stringValue,
                     forKey: PreferencesController.remoteDBSchemaKey)
        
        defaults.set(txtRemoteDBDatabase.stringValue,
                     forKey: PreferencesController.remoteDBDatabaseKey)
        
        defaults.set(chkRemoteDBNoPassword.state == .on ? "true" : "false",
                     forKey: PreferencesController.remoteDBNoPasswordKey)
    }
    
    func savePerformanceSection(_ defaults:UserDefaults) {
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
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        
        self.savePerformanceSection(defaults)
        self.saveDatabaseSection(defaults)
        self.saveMobileSection(defaults)
        self.saveFaceRecognitionSection(defaults)
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
    
    // MARK: - INIT SECTIONS
    
    func initDatabaseSection() {
        
        self.selectedDatabaseLocation = PreferencesController.databaseLocation()
        if self.selectedDatabaseLocation == "local" {
            self.chkLocalLocation.state = .on
            self.chkNetworkLocation.state = .off
        }else{
            self.chkLocalLocation.state = .off
            self.chkNetworkLocation.state = .on
        }
        
        txtDatabasePath.stringValue = PreferencesController.databasePath()
        self.lblDatabaseBackupPath.stringValue = URL(fileURLWithPath: PreferencesController.databasePath()).appendingPathComponent("DataBackup").path
        
        txtRemoteDBServer.stringValue = PreferencesController.remoteDBServer()
        txtRemoteDBPort.stringValue = "\(PreferencesController.remoteDBPort())"
        txtRemoteDBUser.stringValue = PreferencesController.remoteDBUsername()
        txtRemoteDBPassword.stringValue = PreferencesController.remoteDBPassword()
        txtRemoteDBSchema.stringValue = PreferencesController.remoteDBSchema()
        txtRemoteDBDatabase.stringValue = PreferencesController.remoteDBDatabase()
        
        let remoteDBNoPassword = PreferencesController.remoteDBNoPassword()
        if remoteDBNoPassword {
            self.chkRemoteDBNoPassword.state = .on
            self.txtRemoteDBPassword.isEditable = false
        }else{
            self.chkRemoteDBNoPassword.state = .off
            self.txtRemoteDBPassword.isEditable = true
        }
    }
    
    func initMobileSection() {
        
        txtIOSMountPoint.stringValue = PreferencesController.iosDeviceMountPoint()
        txtIfusePath.stringValue = PreferencesController.ifusePath()
        txtIdeviceIdPath.stringValue = PreferencesController.ideviceidPath()
        txtIdeviceInfoPath.stringValue = PreferencesController.ideviceinfoPath()
        txtExportToAndroidPath.stringValue = PreferencesController.exportToAndroidDirectory()
    }
    
    func initFaceRecognitionSection() {
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
    }
    
    func initGeolocationAPISection() {
        
        txtBaiduAK.stringValue = PreferencesController.baiduAK()
        txtBaiduSK.stringValue = PreferencesController.baiduSK()
        txtGoogleAPIKey.stringValue = PreferencesController.googleAPIKey()
    }
    
    func initPerformanceSection() {
        self.setupMemorySlider()
        let paginationAmount = PreferencesController.amountForPagination()
        print("GOT AMOUNT FOR PAGINATION \(paginationAmount)")
        if paginationAmount == 0 {
            self.lstAmountForPagination.selectItem(withTitle: "Unlimited")
        }else{
            self.lstAmountForPagination.selectItem(withTitle: "\(paginationAmount)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Setting"
        // Do any additional setup after loading the view.
        self.initPerformanceSection()
        self.initDatabaseSection()
        self.initMobileSection()
        self.initFaceRecognitionSection()
        self.initGeolocationAPISection()
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
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
