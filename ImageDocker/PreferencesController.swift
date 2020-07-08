//
//  PreferencesController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/23.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

final class PreferencesController: NSViewController {
    
    // Postgres DB date timezone offset (hours)
    static let postgresTimestampTimezoneOffset = "+8"
    
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
    fileprivate static let localDBServerKey = "LocalDBServer"
    fileprivate static let localDBPortKey = "LocalDBPort"
    fileprivate static let localDBUsernameKey = "LocalDBUsername"
    fileprivate static let localDBPasswordKey = "LocalDBPassword"
    fileprivate static let localDBSchemaKey = "LocalDBSchema"
    fileprivate static let localDBDatabaseKey = "LocalDBDatabase"
    fileprivate static let localDBNoPasswordKey = "LocalDBNoPassword"
    
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
    
    @IBOutlet weak var btnApply: NSButton!
    
    
    // MARK: GEOLOCATION API
    @IBOutlet weak var txtBaiduAK: NSTextField!
    @IBOutlet weak var txtBaiduSK: NSTextField!
    @IBOutlet weak var txtGoogleAPIKey: NSTextField!
    
    // MARK: DATABASE
    @IBOutlet weak var chkLocalLocation: NSButton!
    @IBOutlet weak var chkLocalDBServer: NSButton!
    @IBOutlet weak var chkNetworkLocation: NSButton!
    
    @IBOutlet weak var txtLocalDBFilePath: NSTextField!
    @IBOutlet weak var btnLocalDBFileTest: NSButton!
    @IBOutlet weak var btnLocalDBFileBackup: NSButton!
    @IBOutlet weak var lblLocalDBFileMessage: NSTextField!
    @IBOutlet weak var lblLocalDBFileSchemaVersion: NSTextField!
    
    
    @IBOutlet weak var txtLocalDBServer: NSTextField!
    @IBOutlet weak var txtLocalDBPort: NSTextField!
    @IBOutlet weak var txtLocalDBUser: NSTextField!
    @IBOutlet weak var txtLocalDBPassword: NSSecureTextField!
    @IBOutlet weak var txtLocalDBSchema: NSTextField!
    @IBOutlet weak var txtLocalDBDatabase: NSTextField!
    @IBOutlet weak var txtLocalDBBinPath: NSTextField!
    @IBOutlet weak var chkLocalDBBinInsideApp: NSButton!
    @IBOutlet weak var btnLocalDBServerTest: NSButton!
    @IBOutlet weak var lblLocalDBServerSchemaVersion: NSTextField!
    @IBOutlet weak var chkLocalDBNoPassword: NSButton!
    @IBOutlet weak var btnLocalDBServerBackup: NSButton!
    @IBOutlet weak var lblLocalDBServerMessage: NSTextField!
    
    
    @IBOutlet weak var txtRemoteDBServer: NSTextField!
    @IBOutlet weak var txtRemoteDBPort: NSTextField!
    @IBOutlet weak var txtRemoteDBUser: NSTextField!
    @IBOutlet weak var txtRemoteDBPassword: NSSecureTextField!
    @IBOutlet weak var txtRemoteDBSchema: NSTextField!
    @IBOutlet weak var txtRemoteDBDatabase: NSTextField!
    @IBOutlet weak var chkRemoteDBNoPassword: NSButton!
    @IBOutlet weak var btnRemoteDBTest: NSButton!
    @IBOutlet weak var lblRemoteSchemaVersion: NSTextField!
    
    // MARK: BACKUP
    @IBOutlet weak var lblDatabaseBackupPath: NSTextField!
    @IBOutlet weak var lblDBBackupUsedSpace: NSTextField!
    
    @IBOutlet weak var chkDeleteAllBeforeClone: NSButton!
    @IBOutlet weak var chkFromLocalDBFile: NSButton!
    @IBOutlet weak var chkFromLocalDBServer: NSButton!
    @IBOutlet weak var chkFromRemoteDBServer: NSButton!
    @IBOutlet weak var chkToLocalDBFile: NSButton!
    @IBOutlet weak var chkToLocalDBServer: NSButton!
    @IBOutlet weak var chkToRemoteDBServer: NSButton!
    @IBOutlet weak var btnCloneLocalToRemote: NSButton!
    @IBOutlet weak var lblDataCloneMessage: NSTextField!
    
    @IBOutlet weak var tblDatabaseArchives: NSTableView!
    @IBOutlet weak var chkRestoreToLocalDBFile: NSButton!
    @IBOutlet weak var chkRestoreToLocalDBServer: NSButton!
    @IBOutlet weak var txtRestoreToDatabaseName: NSTextField!
    @IBOutlet weak var lblRestoreToDatabaseName: NSTextField!
    @IBOutlet weak var btnCreateDatabase: NSButton!
    @IBOutlet weak var lblSelectedDBArchive: NSTextField!
    @IBOutlet weak var lblRestoreDatabaseMessage: NSTextField!
    @IBOutlet weak var btnReloadDBArchives: NSButton!
    @IBOutlet weak var btnRestoreDBArchive: NSButton!
    @IBOutlet weak var btnDeleteDBArchives: NSButton!
    
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
                    self.txtLocalDBFilePath.stringValue = path
                }
            }
        }
    }
    
    @IBAction func onFindDatabaseBackupClicked(_ sender: NSButton) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: self.lblDatabaseBackupPath.stringValue)])
    }
    
    @IBAction func onCheckLocalLocationClicked(_ sender: NSButton) {
        if sender.state == .on {
            selectedDatabaseLocation = "local"
            self.toggleDBLocations()
        }else{
            if self.chkLocalLocation.state == .off && self.chkNetworkLocation.state == .off && self.chkLocalDBServer.state == .off {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onCheckLocalDBServerClicked(_ sender: NSButton) {
        if sender.state == .on {
            selectedDatabaseLocation = "localServer"
            self.toggleDBLocations()
        }else{
            if self.chkLocalLocation.state == .off && self.chkNetworkLocation.state == .off && self.chkLocalDBServer.state == .off {
                sender.state = .on
            }
        }
    }
    
    
    @IBAction func onCheckNetworkLocationClicked(_ sender: NSButton) {
        if sender.state == .on {
            selectedDatabaseLocation = "network"
            self.toggleDBLocations()
        }else{
            if self.chkLocalLocation.state == .off && self.chkNetworkLocation.state == .off && self.chkLocalDBServer.state == .off {
                sender.state = .on
            }
        }
    }
    
    private func toggleLocalNoPassword() {
        if self.chkLocalDBNoPassword.state == .on {
            self.txtLocalDBPassword.isEditable = false
        }else{
            self.txtLocalDBPassword.isEditable = true
        }
    }
    
    @IBAction func onCheckLocalNoPasswordClicked(_ sender: NSButton) {
        self.toggleLocalNoPassword()
    }
    
    private func toggleRemoteNoPassword() {
        if self.chkRemoteDBNoPassword.state == .on {
            self.txtRemoteDBPassword.isEditable = false
        }else{
            self.txtRemoteDBPassword.isEditable = true
        }
    }
    
    
    @IBAction func onCheckRemoteNopasswordClicked(_ sender: NSButton) {
        self.toggleRemoteNoPassword()
    }
    
    private func toggleLocalDBBinPathInsideApp() {
        if self.chkLocalDBBinInsideApp.state == .on {
            self.txtLocalDBBinPath.stringValue = "/Applications/Postgres.app/Contents/Versions/latest/bin"
            self.txtLocalDBBinPath.isEditable = false
        }else{
            self.txtLocalDBBinPath.isEditable = true
        }
    }
    
    @IBAction func onCheckLocalDBBinInsideApp(_ sender: NSButton) {
        self.toggleLocalDBBinPathInsideApp()
    }
    
    @IBAction func onLocalDBServerTestClicked(_ sender: NSButton) {
        self.lblLocalDBServerSchemaVersion.stringValue = "TODO."
    }
    
    
    @IBAction func onRemoteDBTestClicked(_ sender: NSButton) {
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
    
    private func toggleDatabaseClonerButtons(state: Bool) {
        self.btnLocalDBFileBackup.isEnabled = state
        self.btnLocalDBServerBackup.isEnabled = state
        self.btnCloneLocalToRemote.isEnabled = state
    }
    
    @IBAction func onCalcBackupUsedSpace(_ sender: NSButton) {
        let path = lblDatabaseBackupPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if path != "" {
            DispatchQueue.global().async {
                let (sizeGB, spaceFree, _, _) = LocalDirectory.bridge.getDiskSpace(path: path)
                DispatchQueue.main.async {
                    self.lblDBBackupUsedSpace.stringValue = "Used: \(sizeGB) , Free: \(spaceFree)"
                }
            }
        }
    }
    
    
    @IBAction func onCloneLocalToRemoteClicked(_ sender: NSButton) {
        let dropBeforeCreate = self.chkDeleteAllBeforeClone.state == .on
        self.toggleDatabaseClonerButtons(state: false)
        
        DispatchQueue.global().async {
            
            DispatchQueue.main.async {
                self.lblDataCloneMessage.stringValue = "Re-initializing schema ..."
            }
            PostgresConnection.default.versionCheck(dropBeforeCreate: dropBeforeCreate, location: .remoteDBServer)

            
            final class Version : PostgresCustomRecord {
                var ver:Int = 0
                public init() {}
            }
            
            if let version = Version.fetchOne(PostgresConnection.database(.remoteDBServer), sql: "select substring(ver, '\\d+')::int versions from version_migrations order by versions desc") {
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
                
                let remotedb = PostgresConnection.database(.remoteDBServer)
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
    
    @IBAction func onBackupLocalClicked(_ sender: NSButton) {
        self.lblLocalDBFileMessage.stringValue = "TODO function."
    }
    
    @IBAction func onBackupRemoteClicked(_ sender: NSButton) {
        self.lblLocalDBServerMessage.stringValue = "TODO function."
    }
    
    @IBAction func onLocalSchemaVersionClicked(_ sender: NSButton) {
        self.lblLocalDBFileSchemaVersion.stringValue = "TODO."
    }
    
    @IBAction func onReloadDBArchivesClicked(_ sender: NSButton) {
    }
    
    @IBAction func onRestoreDBArchiveClicked(_ sender: NSButton) {
    }
    
    @IBAction func onDeleteDBArchivesClicked(_ sender: NSButton) {
    }
    
    @IBAction func onCreateDatabaseClicked(_ sender: NSButton) {
    }
    
    @IBAction func onCheckToLocalDBFileClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.selectedRestoreToDBLocation = "localDBFile"
            self.toggleRestoreToDBLocations()
        }else{
            if self.chkRestoreToLocalDBFile.state == .off && self.chkRestoreToLocalDBServer.state == .off {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onCheckToLocalDBServerClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.selectedRestoreToDBLocation = "localDBServer"
            self.toggleRestoreToDBLocations()
        }else{
            if self.chkRestoreToLocalDBFile.state == .off && self.chkRestoreToLocalDBServer.state == .off {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onCheckFromLocalDBFile(_ sender: NSButton) {
        if sender.state == .on {
            self.selectedCloneFromDBLocation = "localDBFile"
            self.toggleCloneFromDBLocations()
        }else{
            if self.chkFromLocalDBFile.state == .off && self.chkFromLocalDBServer.state == .off && self.chkFromRemoteDBServer.state == .off {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onCheckFromLocalDBServer(_ sender: NSButton) {
        if sender.state == .on {
            self.selectedCloneFromDBLocation = "localDBServer"
            self.toggleCloneFromDBLocations()
        }else{
            if self.chkFromLocalDBFile.state == .off && self.chkFromLocalDBServer.state == .off && self.chkFromRemoteDBServer.state == .off {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onCheckFromRemoteDBServer(_ sender: NSButton) {
        if sender.state == .on {
            self.selectedCloneFromDBLocation = "remoteDBServer"
            self.toggleCloneFromDBLocations()
        }else{
            if self.chkFromLocalDBFile.state == .off && self.chkFromLocalDBServer.state == .off && self.chkFromRemoteDBServer.state == .off {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onCheckToLocalDBFile(_ sender: NSButton) {
        if sender.state == .on {
            self.selectedCloneToDBLocation = "localDBFile"
            self.toggleCloneToDBLocations()
        }else{
            if self.chkToLocalDBFile.state == .off && self.chkToLocalDBServer.state == .off && self.chkToRemoteDBServer.state == .off {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onCheckToLocalDBServer(_ sender: NSButton) {
        if sender.state == .on {
            self.selectedCloneToDBLocation = "localDBServer"
            self.toggleCloneToDBLocations()
        }else{
            if self.chkToLocalDBFile.state == .off && self.chkToLocalDBServer.state == .off && self.chkToRemoteDBServer.state == .off {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onCheckToRemoteDBServer(_ sender: NSButton) {
        if sender.state == .on {
            self.selectedCloneToDBLocation = "RemoteDBServer"
            self.toggleCloneToDBLocations()
        }else{
            if self.chkToLocalDBFile.state == .off && self.chkToLocalDBServer.state == .off && self.chkToRemoteDBServer.state == .off {
                sender.state = .on
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
    
    class func localDBServer() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: localDBServerKey) else {return "127.0.0.1"}
        return txt
    }
    
    
    class func localDBPort() -> Int {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: localDBPortKey) else {return 5432}
        if let value = Int(txt) {
            return value
        }else{
            return 5432
        }
    }
    
    
    class func localDBUsername() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: localDBUsernameKey) else {return ""}
        return txt
    }
    
    
    class func localDBPassword() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: localDBPasswordKey) else {return ""}
        return txt
    }
    
    
    class func localDBSchema() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: localDBSchemaKey) else {return "public"}
        return txt
    }
    
    
    class func localDBDatabase() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: localDBDatabaseKey) else {return ""}
        return txt
    }
    
    
    class func localDBNoPassword() -> Bool {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: localDBNoPasswordKey) else {return true}
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
        
        defaults.set(txtLocalDBFilePath.stringValue,
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
        
        
        
        defaults.set(txtLocalDBServer.stringValue,
                     forKey: PreferencesController.localDBServerKey)
        
        if let _ = Int(txtLocalDBPort.stringValue) {
            defaults.set(txtLocalDBPort.stringValue,
                         forKey: PreferencesController.localDBPortKey)
        }else{
            defaults.set("5432",
                         forKey: PreferencesController.localDBPortKey)
        }
        
        defaults.set(txtLocalDBUser.stringValue,
                     forKey: PreferencesController.localDBUsernameKey)
        
        defaults.set(txtLocalDBPassword.stringValue,
                     forKey: PreferencesController.localDBPasswordKey)
        
        defaults.set(txtLocalDBSchema.stringValue,
                     forKey: PreferencesController.localDBSchemaKey)
        
        defaults.set(txtLocalDBDatabase.stringValue,
                     forKey: PreferencesController.localDBDatabaseKey)
        
        defaults.set(chkLocalDBNoPassword.state == .on ? "true" : "false",
                     forKey: PreferencesController.localDBNoPasswordKey)
    }
    
    func saveBackupSection(_ defaults:UserDefaults) {
        
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
        self.saveBackupSection(defaults)
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

    private var selectedDatabaseLocation = "local"
    
    private func toggleDBLocations() {
        if self.selectedDatabaseLocation == "local" {
            self.chkLocalLocation.state = .on
            self.chkLocalDBServer.state = .off
            self.chkNetworkLocation.state = .off
        }else if self.selectedDatabaseLocation == "network"{
            self.chkLocalLocation.state = .off
            self.chkLocalDBServer.state = .off
            self.chkNetworkLocation.state = .on
        }else {
            self.chkLocalLocation.state = .off
            self.chkLocalDBServer.state = .on
            self.chkNetworkLocation.state = .off
        }
    }
    
    private var selectedRestoreToDBLocation = ""
    
    private func toggleRestoreToDBLocations() {
        if self.selectedRestoreToDBLocation == "localDBFile" {
            self.chkRestoreToLocalDBFile.state = .on
            self.chkRestoreToLocalDBServer.state = .off
        }else{
            self.chkRestoreToLocalDBFile.state = .off
            self.chkRestoreToLocalDBServer.state = .on
        }
    }
    
    private var selectedCloneFromDBLocation = ""
    
    private func toggleCloneFromDBLocations() {
        if self.selectedCloneFromDBLocation == "localDBFile" {
            self.chkFromLocalDBFile.state = .on
            self.chkFromLocalDBServer.state = .off
            self.chkFromRemoteDBServer.state = .off
        }else if self.selectedCloneFromDBLocation == "localDBServer" {
            self.chkFromLocalDBFile.state = .off
            self.chkFromLocalDBServer.state = .on
            self.chkFromRemoteDBServer.state = .off
        }else{
            self.chkFromLocalDBFile.state = .off
            self.chkFromLocalDBServer.state = .off
            self.chkFromRemoteDBServer.state = .on
        }
    }
    
    private var selectedCloneToDBLocation = ""
    
    private func toggleCloneToDBLocations() {
        if self.selectedCloneToDBLocation == "localDBFile" {
            self.chkToLocalDBFile.state = .on
            self.chkToLocalDBServer.state = .off
            self.chkToRemoteDBServer.state = .off
        }else if self.selectedCloneToDBLocation == "localDBServer" {
            self.chkToLocalDBFile.state = .off
            self.chkToLocalDBServer.state = .on
            self.chkToRemoteDBServer.state = .off
        }else{
            self.chkToLocalDBFile.state = .off
            self.chkToLocalDBServer.state = .off
            self.chkToRemoteDBServer.state = .on
        }
    }
    
    func initDatabaseSection() {
        
        self.selectedDatabaseLocation = PreferencesController.databaseLocation()
        self.toggleDBLocations()
        
        self.selectedCloneFromDBLocation = "remoteDBServer"
        self.selectedCloneToDBLocation = "localDBServer"
        self.toggleCloneFromDBLocations()
        self.toggleCloneToDBLocations()
        
        self.selectedRestoreToDBLocation = "localDBServer"
        self.toggleRestoreToDBLocations()
        
        
        txtLocalDBFilePath.stringValue = PreferencesController.databasePath()
        
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
        
        txtLocalDBServer.stringValue = PreferencesController.localDBServer()
        txtLocalDBPort.stringValue = "\(PreferencesController.localDBPort())"
        txtLocalDBUser.stringValue = PreferencesController.localDBUsername()
        txtLocalDBPassword.stringValue = PreferencesController.localDBPassword()
        txtLocalDBSchema.stringValue = PreferencesController.localDBSchema()
        txtLocalDBDatabase.stringValue = PreferencesController.localDBDatabase()
        
        let localDBNoPassword = PreferencesController.localDBNoPassword()
        if localDBNoPassword {
            self.chkLocalDBNoPassword.state = .on
            self.txtLocalDBPassword.isEditable = false
        }else{
            self.chkLocalDBNoPassword.state = .off
            self.txtLocalDBPassword.isEditable = true
        }
    }
    
    func initBackupSection() {
        self.lblDatabaseBackupPath.stringValue = URL(fileURLWithPath: PreferencesController.databasePath()).appendingPathComponent("DataBackup").path
        
        self.chkDeleteAllBeforeClone.state = .on
        self.chkDeleteAllBeforeClone.isEnabled = false
        
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
        self.initBackupSection()
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
