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
    
    
    @IBOutlet weak var txtLocalDBServer: NSTextField!
    @IBOutlet weak var txtLocalDBPort: NSTextField!
    @IBOutlet weak var txtLocalDBUser: NSTextField!
    @IBOutlet weak var txtLocalDBPassword: NSSecureTextField!
    @IBOutlet weak var txtLocalDBSchema: NSTextField!
    @IBOutlet weak var txtLocalDBDatabase: NSTextField!
    @IBOutlet weak var txtLocalDBBinPath: NSTextField!
    @IBOutlet weak var btnLocalDBServerTest: NSButton!
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
    @IBOutlet weak var btnRemoteDBServerBackup: NSButton!
    @IBOutlet weak var lblRemoteDBServerMessage: NSTextField!
    
    
    // MARK: BACKUP
    @IBOutlet weak var lblDatabaseBackupPath: NSTextField!
    @IBOutlet weak var lblDBBackupUsedSpace: NSTextField!
    @IBOutlet weak var btnBackupNow: NSButton!
    
    @IBOutlet weak var chkDeleteAllBeforeClone: NSButton!
    @IBOutlet weak var chkFromLocalDBFile: NSButton!
    @IBOutlet weak var chkFromLocalDBServer: NSButton!
    @IBOutlet weak var chkFromRemoteDBServer: NSButton!
    @IBOutlet weak var chkFromBackupArchive: NSButton!
    
    @IBOutlet weak var chkToLocalDBFile: NSButton!
    @IBOutlet weak var chkToLocalDBServer: NSButton!
    @IBOutlet weak var chkToRemoteDBServer: NSButton!
    @IBOutlet weak var btnCloneLocalToRemote: NSButton!
    @IBOutlet weak var lblDataCloneMessage: NSTextField!
    
    
    @IBOutlet weak var scrDatabaseArchives: NSScrollView!
    @IBOutlet weak var tblDatabaseArchives: NSTableView!
    @IBOutlet weak var txtRestoreToDatabaseName: NSTextField!
    @IBOutlet weak var lblRestoreToDatabaseName: NSTextField!
    @IBOutlet weak var btnCheckDatabaseName: NSButton!
    @IBOutlet weak var lblCheckDatabaseName: NSTextField!
    
    
    @IBOutlet weak var btnCreateDatabase: NSButton!
    @IBOutlet weak var btnReloadDBArchives: NSButton!
    @IBOutlet weak var btnDeleteDBArchives: NSButton!
    
    @IBOutlet weak var chkPostgresInApp: NSButton!
    @IBOutlet weak var chkPostgresByBrew: NSButton!
    
    
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
    
    // MARK: TOGGLE GROUP - DB LOCATION

    private var toggleGroup_DBLocation:ToggleGroup!
    
    @IBAction func onCheckLocalLocationClicked(_ sender: NSButton) {
        self.toggleGroup_DBLocation.selected = "local"
    }
    
    @IBAction func onCheckLocalDBServerClicked(_ sender: NSButton) {
        self.toggleGroup_DBLocation.selected = "localServer"
    }
    
    
    @IBAction func onCheckNetworkLocationClicked(_ sender: NSButton) {
        self.toggleGroup_DBLocation.selected = "network"
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
    
    // MARK: LOCAL DB FILE
    
    @IBAction func onBackupLocalClicked(_ sender: NSButton) {
        self.btnLocalDBFileBackup.isEnabled = false
        self.lblLocalDBFileMessage.stringValue = "Creating backup ..."
        DispatchQueue.global().async {
            let (backupFolder, status, error) = ExecutionEnvironment.default.createDatabaseBackup(.localFile, suffix: "-on-runtime")
            DispatchQueue.main.async {
                self.btnLocalDBFileBackup.isEnabled = true
                if status == false {
                    self.lblLocalDBFileMessage.stringValue = "Backup failed: \(error.debugDescription)"
                }else{
                    self.lblLocalDBFileMessage.stringValue = "Created \(backupFolder)"
                }
            }
        }
    }
    
    @IBAction func onLocalSchemaVersionClicked(_ sender: NSButton) {
        self.lblLocalDBFileMessage.stringValue = "TODO."
    }
    
    // MARK: LOCAL DB SERVER
    
    @IBAction func onBackupLocalServerClicked(_ sender: NSButton) {
        self.btnLocalDBServerBackup.isEnabled = false
        self.lblLocalDBServerMessage.stringValue = "Creating backup ..."
        DispatchQueue.global().async {
            let (backupFolder, status, error) = ExecutionEnvironment.default.createDatabaseBackup(.localDBServer, suffix: "-on-runtime")
            DispatchQueue.main.async {
                self.btnLocalDBServerBackup.isEnabled = true
                if status == false {
                    self.lblLocalDBServerMessage.stringValue = "Backup failed: \(error.debugDescription)"
                }else{
                    self.lblLocalDBServerMessage.stringValue = "Created \(backupFolder)"
                }
            }
        }
    }
    
    @IBAction func onLocalDBServerTestClicked(_ sender: NSButton) {
        self.lblLocalDBServerMessage.stringValue = "TODO."
        
        DispatchQueue.global().async {
            final class Version : PostgresCustomRecord {
                var ver:Int = 0
                public init() {}
            }
            
            if let version = Version.fetchOne(PostgresConnection.database(.localDBServer), sql: "select substring(ver, '\\d+')::int versions from version_migrations order by versions desc") {
                DispatchQueue.main.async {
                    self.lblLocalDBServerMessage.stringValue = "v\(version.ver)"
                }
            }else{
                DispatchQueue.main.async {
                    self.lblLocalDBServerMessage.stringValue = "No schema"
                }
            }
        }
    }
    
    // MARK: REMOTE DB SERVER
    
    @IBAction func onBackupRemoteServerClicked(_ sender: NSButton) {
        self.btnRemoteDBServerBackup.isEnabled = false
        self.lblRemoteDBServerMessage.stringValue = "Creating backup ..."
        DispatchQueue.global().async {
            let (backupFolder, status, error) = ExecutionEnvironment.default.createDatabaseBackup(.remoteDBServer, suffix: "-on-runtime")
            DispatchQueue.main.async {
                self.btnRemoteDBServerBackup.isEnabled = true
                if status == false {
                    self.lblRemoteDBServerMessage.stringValue = "Backup failed: \(error.debugDescription)"
                }else{
                    self.lblRemoteDBServerMessage.stringValue = "Created \(backupFolder)"
                }
            }
        }
    }
    
    @IBAction func onRemoteDBServerTestClicked(_ sender: NSButton) {
        self.lblRemoteDBServerMessage.stringValue = "TODO version test"
    }
    
    
    // MARK: - ACTION FOR BACKUP SECTION
    
    private func toggleDatabaseClonerButtons(state: Bool) {
        self.btnLocalDBFileBackup.isEnabled = state
        self.btnLocalDBServerBackup.isEnabled = state
        self.btnCloneLocalToRemote.isEnabled = state
        self.tblDatabaseArchives.isEnabled = state
        self.btnDeleteDBArchives.isEnabled = state
        self.btnReloadDBArchives.isEnabled = state
        self.btnCreateDatabase.isEnabled = state
        self.btnCheckDatabaseName.isEnabled = state
        self.txtRestoreToDatabaseName.isEnabled = state
        if state == true {
            self.toggleGroup_CloneFromDBLocation.enable()
            self.toggleGroup_CloneToDBLocation.enable()
            if self.toggleGroup_CloneFromDBLocation.selected == "localDBFile" {
                self.toggleGroup_CloneToDBLocation.disable(key: "localDBFile", onComplete: { nextKey in
                    if nextKey == "localDBServer" || nextKey == "remoteDBServer" {
                        self.loadBackupArchives(postgres: true)
                    }
                })
            }
        }else{
            self.toggleGroup_CloneFromDBLocation.disable()
            self.toggleGroup_CloneToDBLocation.disable()
        }
    }
    
    func calculateBackupUsedSpace(path:String) {
        let (sizeGB, spaceFree, _, _) = LocalDirectory.bridge.getDiskSpace(path: path)
        DispatchQueue.main.async {
            self.lblDBBackupUsedSpace.stringValue = "Used: \(Double(sizeGB).rounded(toPlaces: 2)) GB , Free: \(spaceFree)"
        }
    }
    
    @IBAction func onCalcBackupUsedSpace(_ sender: NSButton) {
        let path = lblDatabaseBackupPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if path != "" {
            DispatchQueue.global().async {
                self.calculateBackupUsedSpace(path: path)
            }
        }
    }
    
    @IBAction func onBackupNowClicked(_ sender: NSButton) {
        // TODO: SAVE ALL FIELDS BEFORE START BACKUP
        self.btnBackupNow.isEnabled = false
        self.lblDBBackupUsedSpace.stringValue = "Creating backup ..."
        DispatchQueue.global().async {
            let (backupFolder, status, error) = ExecutionEnvironment.default.createDatabaseBackup(suffix: "-on-runtime")
            DispatchQueue.main.async {
                self.btnBackupNow.isEnabled = true
                if status == false {
                    self.lblDBBackupUsedSpace.stringValue = "Backup failed: \(error.debugDescription)"
                }else{
                    self.lblDBBackupUsedSpace.stringValue = "Created \(backupFolder)"
                }
            }
        }
    }
    
    
    
    @IBAction func onCloneLocalToRemoteClicked(_ sender: NSButton) {
        // TODO: SAVE ALL FIELDS BEFORE START CLONE
        let dropBeforeCreate = self.chkDeleteAllBeforeClone.state == .on
        
        self.scrDatabaseArchives.layer?.borderColor = NSColor.clear.cgColor
        self.scrDatabaseArchives.layer?.borderWidth = 0.0
        
        self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.clear.cgColor
        self.txtRestoreToDatabaseName.layer?.borderWidth = 0.0
        
        self.lblDataCloneMessage.stringValue = ""
        
         // TODO: avoid select both from-sqlite and to-sqlite
        if self.toggleGroup_CloneFromDBLocation.selected == "backupArchive" {
            guard self.tblDatabaseArchives.numberOfSelectedRows == 1 else {
                self.scrDatabaseArchives.layer?.borderColor = NSColor.red.cgColor
                self.scrDatabaseArchives.layer?.borderWidth = 1.0
                self.lblDataCloneMessage.stringValue = "One row should be selected in archive table"
                return
            }
            guard let cmd = PreferencesController.getPostgresCommandPath() else {
                self.lblDataCloneMessage.stringValue = "Unable to locate psql command in macOS, restore aborted."
                return
            }
            let database = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let checkDatabase = self.lblCheckDatabaseName.stringValue
            guard database != "" else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblCheckDatabaseName.stringValue = "Error: empty."
                return
            }
            guard (checkDatabase == "Not exists." || checkDatabase == "Created.") else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblDataCloneMessage.stringValue = "Please check if target database exists first"
                return
            }
            let row = self.tblDatabaseArchives.selectedRow
            let timestamp = self.backupArchives[row].0
            let folder = self.backupArchives[row].3
            print("restore from \(folder)")
            
            var host = ""
            var port = 5432
            var user = ""
            var message = ""
            if self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
                host = PreferencesController.localDBServer()
                port = PreferencesController.localDBPort()
                user = PreferencesController.localDBUsername()
                message = "Restoring archive [\(timestamp)] to local postgres database [\(database)] ..."
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = PreferencesController.remoteDBServer()
                port = PreferencesController.remoteDBPort()
                user = PreferencesController.remoteDBUsername()
                message = "Restoring archive [\(timestamp)] to remote postgres database [\(database)] ..."
            }else{
                self.lblDataCloneMessage.stringValue = "TODO: from backup archive to sqlite"
                return
            }
            self.toggleDatabaseClonerButtons(state: false)
            self.lblDataCloneMessage.stringValue = message
            DispatchQueue.global().async {
                let (_, _) = PostgresConnection.default.restoreDatabase(commandPath: cmd, database: database, host: host, port: port, user: user, backupFolder: folder)
                DispatchQueue.main.async {
                    self.toggleDatabaseClonerButtons(state: true)
                    self.lblDataCloneMessage.stringValue = "Restore archive [\(timestamp)] to [\(database)] completed."
                }
            }
            
        }
        else if  self.toggleGroup_CloneFromDBLocation.selected == "localDBFile" {
            var host = ""
            var port = 5432
            var user = ""
            var database = ""
            var message = ""
            var schema = ""
            var psw = ""
            var nopsw = false
            if       self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
                host = PreferencesController.localDBServer()
                port = PreferencesController.localDBPort()
                user = PreferencesController.localDBUsername()
                database = PreferencesController.localDBDatabase()
                psw = PreferencesController.localDBPassword()
                nopsw = PreferencesController.localDBNoPassword()
                schema = PreferencesController.localDBSchema()
                message = "Clone from SQLite to local postgres database ..."
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = PreferencesController.remoteDBServer()
                port = PreferencesController.remoteDBPort()
                user = PreferencesController.remoteDBUsername()
                database = PreferencesController.remoteDBDatabase()
                psw = PreferencesController.remoteDBPassword()
                nopsw = PreferencesController.remoteDBNoPassword()
                schema = PreferencesController.remoteDBSchema()
                message = "Clone from SQLite to remote postgres database ..."
            }else{
                // more options?
                return
            }
            if self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) != "" && self.lblCheckDatabaseName.stringValue == "Created" {
                database = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            self.toggleDatabaseClonerButtons(state: false)
            self.lblDataCloneMessage.stringValue = message
            DispatchQueue.global().async {
                ImageDBCloner.default.fromLocalSQLiteToPostgreSQL(dropBeforeCreate: dropBeforeCreate,
                    postgresDB: { () -> PostgresDB in
                        return PostgresConnection.database(host: host, port: port, user: user, database: database, schema: schema, password: psw, nopsw: nopsw)
                }, message: { msg in
                    DispatchQueue.main.async {
                        self.lblDataCloneMessage.stringValue = msg
                    }
                }, onComplete: {
                    DispatchQueue.main.async {
                        self.toggleDatabaseClonerButtons(state: true)
                        self.lblDataCloneMessage.stringValue = "Database clone completed."
                    }
                })
            }
        }else if self.toggleGroup_CloneFromDBLocation.selected == "localDBServer" {
            
            guard let cmd = PreferencesController.getPostgresCommandPath() else {
                self.lblDataCloneMessage.stringValue = "Unable to locate psql command in macOS, restore aborted."
                return
            }
            let database = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let checkDatabase = self.lblCheckDatabaseName.stringValue
            guard database != "" else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblCheckDatabaseName.stringValue = "Error: empty."
                return
            }
            guard (checkDatabase == "Not exists." || checkDatabase == "Created.") else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblDataCloneMessage.stringValue = "Please check if target database exists first"
                return
            }
            var host = ""
            var port = 5432
            var user = ""
            var message = ""
            if       self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
                host = PreferencesController.localDBServer()
                port = PreferencesController.localDBPort()
                user = PreferencesController.localDBUsername()
                message = "Clone from local postgres to local postgres database ..."
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = PreferencesController.remoteDBServer()
                port = PreferencesController.remoteDBPort()
                user = PreferencesController.remoteDBUsername()
                message = "Clone from local postgres to remote postgres database ..."
            }else{
                self.lblDataCloneMessage.stringValue = "TODO from local postgres to sqlite"
                return
            }
            self.toggleDatabaseClonerButtons(state: false)
            self.lblDataCloneMessage.stringValue = message
            DispatchQueue.global().async {
                let (_, _) = PostgresConnection.default.cloneDatabase(commandPath: cmd,
                                                                      srcDatabase: PreferencesController.localDBDatabase(),
                                                                      srcHost: PreferencesController.localDBServer(),
                                                                      srcPort: PreferencesController.localDBPort(),
                                                                      srcUser: PreferencesController.localDBUsername(),
                                                                      destDatabase: database,
                                                                      destHost: host,
                                                                      destPort: port,
                                                                      destUser: user)
                DispatchQueue.main.async {
                    self.toggleDatabaseClonerButtons(state: true)
                    self.lblDataCloneMessage.stringValue = "Clone from local postgres to [\(database)] completed."
                }
            }
        }else if self.toggleGroup_CloneFromDBLocation.selected == "remoteDBServer" {
            
            guard let cmd = PreferencesController.getPostgresCommandPath() else {
                self.lblDataCloneMessage.stringValue = "Unable to locate psql command in macOS, restore aborted."
                return
            }
            let database = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let checkDatabase = self.lblCheckDatabaseName.stringValue
            guard database != "" else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblCheckDatabaseName.stringValue = "Error: empty."
                return
            }
            guard (checkDatabase == "Not exists." || checkDatabase == "Created.") else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblDataCloneMessage.stringValue = "Please check if target database exists first"
                return
            }
            var host = ""
            var port = 5432
            var user = ""
            var message = ""
            if       self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
                host = PreferencesController.localDBServer()
                port = PreferencesController.localDBPort()
                user = PreferencesController.localDBUsername()
                message = "Clone from remote postgres to local postgres database ..."
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = PreferencesController.remoteDBServer()
                port = PreferencesController.remoteDBPort()
                user = PreferencesController.remoteDBUsername()
                message = "Clone from remote postgres to remote postgres database ..."
            }else{
                self.lblDataCloneMessage.stringValue = "TODO from remote postgres to sqlite"
                return
            }
            self.toggleDatabaseClonerButtons(state: false)
            self.lblDataCloneMessage.stringValue = message
            DispatchQueue.global().async {
                let (_, _) = PostgresConnection.default.cloneDatabase(commandPath: cmd,
                                                                      srcDatabase: PreferencesController.remoteDBDatabase(),
                                                                      srcHost: PreferencesController.remoteDBServer(),
                                                                      srcPort: PreferencesController.remoteDBPort(),
                                                                      srcUser: PreferencesController.remoteDBUsername(),
                                                                      destDatabase: database,
                                                                      destHost: host,
                                                                      destPort: port,
                                                                      destUser: user)
                DispatchQueue.main.async {
                    self.toggleDatabaseClonerButtons(state: true)
                    self.lblDataCloneMessage.stringValue = "Clone from remote postgres to [\(database)] completed."
                }
            }
        }else{
            // more options?
        }
        
    }
    
    @IBAction func onReloadDBArchivesClicked(_ sender: NSButton) {
        if self.toggleGroup_CloneToDBLocation.selected == "localDBFile" {
            self.loadBackupArchives(postgres: false)
        }else{
            self.loadBackupArchives(postgres: true)
        }
    }
    
    @IBAction func onDeleteDBArchivesClicked(_ sender: NSButton) {
        var selected:[String] = []
        if self.tblDatabaseArchives.numberOfSelectedRows > 0 {
            for i in 0..<self.backupArchives.count {
                if self.tblDatabaseArchives.isRowSelected(i) {
                    let (_, _, _, folder) = self.backupArchives[i]
                    selected.append(folder)
                }
            }
        }
        let backupPath = URL(fileURLWithPath: PreferencesController.databasePath()).appendingPathComponent("DataBackup")
        DispatchQueue.global().async {
            for folder in selected {
                let url = backupPath.appendingPathComponent(folder)
                
                print("delete backup folder \(folder)")
                do{
                    try FileManager.default.removeItem(at: url)
                }catch{
                    print("Unable to delete backup archive: \(url.path)")
                    print(error)
                }
            }
            self.loadBackupArchives()
            self.calculateBackupUsedSpace(path: backupPath.path)
        }
    }
    
    @IBAction func onCheckBackupToDatabaseName(_ sender: NSButton) {
        guard let cmd = PreferencesController.getPostgresCommandPath() else {
            print("\(Date()) Unable to locate psql command in macOS, check db exist aborted.")
            return
        }
        var host = ""
        var port = 5432
        var user = ""
        if self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
            host = PreferencesController.localDBServer()
            port = PreferencesController.localDBPort()
            user = PreferencesController.localDBUsername()
        }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
            host = PreferencesController.remoteDBServer()
            port = PreferencesController.remoteDBPort()
            user = PreferencesController.remoteDBUsername()
        }else{
            print("Selected to-database is not postgres. check db exist aborted.")
            return
        }
        let targetDatabase = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard targetDatabase != "" else {
            self.lblCheckDatabaseName.stringValue = "Error: empty."
            self.btnCreateDatabase.isHidden = true
            return
        }
        DispatchQueue.global().async {
            let databases = PostgresConnection.default.getExistDatabases(commandPath: cmd, host: host, port: port)
            var exists = false
            for database in databases {
                if database == targetDatabase {
                    exists = true
                    break
                }
            }
            if exists {
                DispatchQueue.main.async {
                    self.lblCheckDatabaseName.stringValue = "Exists."
                    self.btnCreateDatabase.isHidden = true
                }
            }else{
                DispatchQueue.main.async {
                    self.lblCheckDatabaseName.stringValue = "Not exists."
                    self.btnCreateDatabase.isHidden = false
                }
            }
        }
    }
    
    
    @IBAction func onCreateDatabaseClicked(_ sender: NSButton) {
        let databaseName = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard databaseName != "" else {
            print("Error: database name is empty")
            return
        }
        guard let cmd = PreferencesController.getPostgresCommandPath() else {
            print("\(Date()) Unable to locate pg_dump command in macOS, createdb aborted.")
            return
        }
        var host = ""
        var port = 5432
        var user = ""
        if self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
            host = PreferencesController.localDBServer()
            port = PreferencesController.localDBPort()
            user = PreferencesController.localDBUsername()
        }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
            host = PreferencesController.remoteDBServer()
            port = PreferencesController.remoteDBPort()
            user = PreferencesController.remoteDBUsername()
        }else{
            print("Selected to-database is not postgres. createdb aborted.")
            return
        }
        
        self.btnCreateDatabase.isEnabled = false
        
        // TODO: SAVE ALL FIELDS BEFORE START CREATEDB
        DispatchQueue.global().async {
            
            let (status, _, pgError, err) = PostgresConnection.default.createDatabase(commandPath: cmd, database: databaseName, host: host, port: port, user: user)
            
            if status == true {
                print("created database \(databaseName) on \(user)@\(host):\(port)")
                DispatchQueue.main.async {
                    self.btnCreateDatabase.isEnabled = true
                    self.lblCheckDatabaseName.stringValue = "Created."
                }
            }else{
                print("Unable to create database \(databaseName) on \(user)@\(host):\(port)")
                print(pgError)
                if let error = err {
                    print(error)
                }
                DispatchQueue.main.async {
                    self.btnCreateDatabase.isEnabled = true
                    self.lblCheckDatabaseName.stringValue = "Failed createdb."
                }
            }
        }
    }
    
    // MARK: TOGGLE GROUP - CLONE FROM DB
    
    var toggleGroup_CloneFromDBLocation:ToggleGroup!
    
    @IBAction func onCheckFromLocalDBFile(_ sender: NSButton) {
        self.toggleGroup_CloneFromDBLocation.selected = "localDBFile"
        self.tblDatabaseArchives.allowsMultipleSelection = true
        self.toggleGroup_CloneToDBLocation.disable(key: "localDBFile", onComplete: { nextKey in
            if nextKey == "localDBServer" || nextKey == "remoteDBServer" {
                self.loadBackupArchives(postgres: true)
            }
        })
    }
    
    @IBAction func onCheckFromLocalDBServer(_ sender: NSButton) {
        self.toggleGroup_CloneFromDBLocation.selected = "localDBServer"
        self.tblDatabaseArchives.allowsMultipleSelection = true
        self.toggleGroup_CloneToDBLocation.enable()
    }
    
    @IBAction func onCheckFromRemoteDBServer(_ sender: NSButton) {
        self.toggleGroup_CloneFromDBLocation.selected = "remoteDBServer"
        self.tblDatabaseArchives.allowsMultipleSelection = true
        self.toggleGroup_CloneToDBLocation.enable()
    }
    
    @IBAction func onCheckFromBackupArchive(_ sender: NSButton) {
        self.toggleGroup_CloneFromDBLocation.selected = "backupArchive"
        self.tblDatabaseArchives.allowsMultipleSelection = false
        self.toggleGroup_CloneToDBLocation.enable()
        self.loadBackupArchives()
    }
    
    
    // MARK: TOGGLE GROUP - CLONE TO DB
    
    var toggleGroup_CloneToDBLocation:ToggleGroup!
    
    @IBAction func onCheckToLocalDBFile(_ sender: NSButton) {
        self.toggleGroup_CloneToDBLocation.selected = "localDBFile"
        self.toggleCreatePostgresDatabase(state: false)
        self.loadBackupArchives(postgres: false)
    }
    
    @IBAction func onCheckToLocalDBServer(_ sender: NSButton) {
        self.toggleGroup_CloneToDBLocation.selected = "localDBServer"
        self.toggleCreatePostgresDatabase(state: true)
        self.loadBackupArchives(postgres: true)
    }
    
    @IBAction func onCheckToRemoteDBServer(_ sender: NSButton) {
        self.toggleGroup_CloneToDBLocation.selected = "remoteDBServer"
        self.toggleCreatePostgresDatabase(state: true)
        self.loadBackupArchives(postgres: true)
    }
    
    private func toggleCreatePostgresDatabase(state: Bool) {
        self.lblRestoreToDatabaseName.isHidden = !state
        self.txtRestoreToDatabaseName.isHidden = !state
        self.lblCheckDatabaseName.isHidden = !state
        self.btnCheckDatabaseName.isHidden = !state
        self.btnCreateDatabase.isHidden = true
        self.lblCheckDatabaseName.stringValue = ""
    }
    
    // MARK: TOGGLE GROUP - Postgres Command Path
    
    var toggleGroup_InstalledPostgres:ToggleGroup!
    
    @IBAction func onCheckInstallPostgresByBrew(_ sender: NSButton) {
        let path = "/usr/local/bin"
        if let postgresCommandPath = ExecutionEnvironment.default.findPostgresCommand(from: [path]) {
            self.toggleGroup_InstalledPostgres.selected = postgresCommandPath
            self.txtLocalDBBinPath.stringValue = postgresCommandPath
        }else{
            self.lblDataCloneMessage.stringValue = "ERROR: Unable to find PostgreSQL from Homebrew \(path)"
            sender.state = .off
        }
       
    }
    
    @IBAction func onCheckInstallPostgresInApp(_ sender: NSButton) {
        let path = "/Applications/Postgres.app/Contents/Versions/latest/bin"
        if let postgresCommandPath = ExecutionEnvironment.default.findPostgresCommand(from: [path]) {
            self.toggleGroup_InstalledPostgres.selected = postgresCommandPath
            self.txtLocalDBBinPath.stringValue = postgresCommandPath
        }else{
            self.lblDataCloneMessage.stringValue = "ERROR: Unable to find PostgreSQL from PostgresApp \(path)"
            sender.state = .off
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
    
    // MARK: TOGGLE GROUP - FACE MODEL
    
    private var toggleGroup_FaceModel:ToggleGroup!
    
    @IBAction func onMajorFaceModelClicked(_ sender: NSButton) {
        self.toggleGroup_FaceModel.selected = "major"
    }
    
    @IBAction func onAlternativeFaceModelClicked(_ sender: NSButton) {
        self.toggleGroup_FaceModel.selected = "alternative"
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
    
    static let predefinedLocalDBFilePath = AppDelegate.current.applicationDocumentsDirectory.path
    
    class func databasePath() -> String {
        let defaults = UserDefaults.standard
        guard let txt = defaults.string(forKey: databasePathKey) else {
            return predefinedLocalDBFilePath
        }
        var isDir : ObjCBool = false
        if FileManager.default.fileExists(atPath: txt, isDirectory: &isDir) {
            if isDir.boolValue {
                return txt
            }else{
                return predefinedLocalDBFilePath
            }
        }else{
            return predefinedLocalDBFilePath
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
        defaults.set(self.toggleGroup_FaceModel.selected,
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
        
        defaults.set(self.toggleGroup_DBLocation.selected,
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
    
    
    func initDatabaseSection() {
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
    
    class func getPostgresCommandPath() -> String? {
        let keys:[String] = [
            "/Applications/Postgres.app/Contents/Versions/latest/bin",
            "/usr/local/bin"
        ]
        if let postgresCommandPath = ExecutionEnvironment.default.findPostgresCommand(from: keys) {
            return postgresCommandPath
        }else{
            return nil
        }
    }
    
    func initBackupSection() {
        
        self.tblDatabaseArchives.backgroundColor = NSColor.black
        self.tblDatabaseArchives.delegate = self
        self.tblDatabaseArchives.dataSource = self
        self.tblDatabaseArchives.allowsMultipleSelection = true
        
        self.btnCreateDatabase.isHidden = true
        
        self.lblDatabaseBackupPath.stringValue = URL(fileURLWithPath: PreferencesController.databasePath()).appendingPathComponent("DataBackup").path
        
        self.chkDeleteAllBeforeClone.state = .on
        self.chkDeleteAllBeforeClone.isEnabled = false
        
        self.txtLocalDBBinPath.isEditable = false
        
        self.toggleGroup_InstalledPostgres = ToggleGroup([
            "/Applications/Postgres.app/Contents/Versions/latest/bin" : self.chkPostgresInApp,
            "/usr/local/bin"                                          : self.chkPostgresByBrew
        ], keysOrderred: [
            "/Applications/Postgres.app/Contents/Versions/latest/bin",
            "/usr/local/bin"
            ])
        
        self.toggleGroup_DBLocation = ToggleGroup([
            "local"       : self.chkLocalLocation,
            "localServer" : self.chkLocalDBServer,
            "network"     : self.chkNetworkLocation
        ], keysOrderred: ["local", "localServer", "network"])
        
        self.toggleGroup_CloneFromDBLocation = ToggleGroup([
            "localDBFile"   :self.chkFromLocalDBFile,
            "localDBServer" :self.chkFromLocalDBServer,
            "remoteDBServer":self.chkFromRemoteDBServer,
            "backupArchive" :self.chkFromBackupArchive
            ], keysOrderred: ["localDBFile", "localDBServer", "remoteDBServer", "backupArchive"])
        
        self.toggleGroup_CloneToDBLocation = ToggleGroup([
            "localDBFile"   :self.chkToLocalDBFile,
            "localDBServer" :self.chkToLocalDBServer,
            "remoteDBServer":self.chkToRemoteDBServer
            ], keysOrderred: ["localDBFile", "localDBServer", "remoteDBServer"],
               onSelect: { option in
                if option == "localDBServer" {
                    self.txtRestoreToDatabaseName.stringValue = PreferencesController.localDBDatabase()
                }else if option == "remoteDBServer" {
                    self.txtRestoreToDatabaseName.stringValue = PreferencesController.remoteDBDatabase()
                }
        })
        
        self.toggleGroup_DBLocation.selected = PreferencesController.databaseLocation()
        self.toggleGroup_CloneFromDBLocation.selected = "localDBFile"
        self.toggleGroup_CloneToDBLocation.disable(key: "localDBFile", onComplete: { nextKey in
            if nextKey == "localDBServer" || nextKey == "remoteDBServer" {
                self.loadBackupArchives(postgres: true)
            }
        })
        self.toggleGroup_CloneToDBLocation.selected = "localDBServer"
        self.toggleCreatePostgresDatabase(state: true)
        
        self.loadBackupArchives(postgres: true)
        
        if let postgresCommandPath = ExecutionEnvironment.default.findPostgresCommand(from: self.toggleGroup_InstalledPostgres.keys) {
            self.toggleGroup_InstalledPostgres.selected = postgresCommandPath
            self.txtLocalDBBinPath.stringValue = postgresCommandPath
        }else{
            self.lblDataCloneMessage.stringValue = "ERROR: Unable to find PostgreSQL from either Homebrew or PostgresApp. Please install first."
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
        
        
        self.toggleGroup_FaceModel = ToggleGroup([
            "major"       : self.chkMajorFaceRecognitionModel,
            "alternative" : self.chkAlternativeFaceRecognitionModel
        ])
        self.toggleGroup_FaceModel.selected = PreferencesController.faceRecognitionModel()
        
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
    
    
    var backupArchives:[(String, String, String, String)] = []
    
    var shouldLoadPostgresBackupArchives = true
}

// MARK: - BACKUP ARCHIVE TABLE VIEW

extension PreferencesController : NSTableViewDelegate, NSTableViewDataSource{
    
    func loadBackupArchives() {
        self.loadBackupArchives(postgres: self.shouldLoadPostgresBackupArchives)
    }
    
    func loadBackupArchives(postgres:Bool) {
        self.shouldLoadPostgresBackupArchives = postgres
        DispatchQueue.global().async {
            var list:[(String, String, String, String)] = []
            let files = ExecutionEnvironment.default.listDatabaseBackup()
            for file in files {
                let parts = file.components(separatedBy: "-")
                if parts.count == 5 && parts[3] == "on" {
                    if parts[2] == "sqlite" {
                        if postgres == false {
                            list.append((parts[1], parts[2], parts[4], file))
                        }
                    }else{
                        if postgres == true {
                            list.append((parts[1], parts[2], parts[4], file))
                        }
                    }
                }else if parts.count == 4 && parts[2] == "on" && postgres == false {
                    list.append((parts[1], "sqlite", parts[3], file))
                }
            }
            self.backupArchives = list
            
            DispatchQueue.main.async {
                self.tblDatabaseArchives.reloadData()
            }
        }
    }
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.backupArchives.count - 1) {
            return nil
        }
        let item = self.backupArchives[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("value1"):
                value = item.0
            case NSUserInterfaceItemIdentifier("value2"):
                value = item.2
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
            if row == tableView.selectedRow {
                colView.textField?.textColor = NSColor.yellow
            } else {
                colView.textField?.textColor = nil
            }
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        rowView.backgroundColor = NSColor.darkGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.backupArchives.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        // do nothing
    }
}
