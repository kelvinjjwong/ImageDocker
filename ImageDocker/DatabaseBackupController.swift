//
//  DatabaseBackupController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2022/2/13.
//  Copyright © 2022 nonamecat. All rights reserved.
//

import Cocoa

final class DatabaseBackupController: NSViewController {
    
    let logger = ConsoleLogger(category: "DatabaseBackupController")
    
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
    
    
    @IBOutlet weak var tabs: NSTabView!
    
    
    // MARK: DATABASE
    
    
    @IBOutlet weak var btnSaveDatabase: NSButton!
    
    @IBOutlet weak var boxLocalSQLite: NSBox!
    @IBOutlet weak var boxLocalPostgres: NSBox!
    @IBOutlet weak var boxRemotePostgres: NSBox!
    
    @IBOutlet weak var chkLocalLocation: NSButton!
    @IBOutlet weak var chkLocalDBServer: NSButton!
    @IBOutlet weak var chkNetworkLocation: NSButton!
    
    @IBOutlet weak var lblLocalSQLitePath: NSTextField!
    
    @IBOutlet weak var txtLocalDBFilePath: NSTextField!
    @IBOutlet weak var btnLocalDBFileTest: NSButton!
    @IBOutlet weak var btnLocalDBFileBackup: NSButton!
    @IBOutlet weak var lblLocalDBFileMessage: NSTextField!
    @IBOutlet weak var btnBrowseLocalDBFilePath: NSButton!
    @IBOutlet weak var btnGotoLocalDBFilePath: NSButton!
    
    @IBOutlet weak var lblLocalPgServer: NSTextField!
    @IBOutlet weak var lblLocalPgPort: NSTextField!
    @IBOutlet weak var lblLocalPgUser: NSTextField!
    @IBOutlet weak var lblLocalPgPassword: NSTextField!
    @IBOutlet weak var lblLocalPgSchema: NSTextField!
    @IBOutlet weak var lblLocalPgDatabase: NSTextField!
    
    @IBOutlet weak var txtLocalDBServer: NSTextField!
    @IBOutlet weak var txtLocalDBPort: NSTextField!
    @IBOutlet weak var txtLocalDBUser: NSTextField!
    @IBOutlet weak var txtLocalDBPassword: NSSecureTextField!
    @IBOutlet weak var txtLocalDBSchema: NSTextField!
    @IBOutlet weak var txtLocalDBDatabase: NSTextField!
    @IBOutlet weak var btnLocalDBServerTest: NSButton!
    @IBOutlet weak var chkLocalDBNoPassword: NSButton!
    @IBOutlet weak var btnLocalDBServerBackup: NSButton!
    @IBOutlet weak var lblLocalDBServerMessage: NSTextField!
    
    @IBOutlet weak var lblRemotePgServer: NSTextField!
    @IBOutlet weak var lblRemotePgPort: NSTextField!
    @IBOutlet weak var lblRemotePgUser: NSTextField!
    @IBOutlet weak var lblRemotePgPassword: NSTextField!
    @IBOutlet weak var lblRemotePgSchema: NSTextField!
    @IBOutlet weak var lblRemotePgDatabase: NSTextField!
    
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
    
    @IBOutlet weak var boxBackup: NSBox!
    @IBOutlet weak var boxDataClone: NSBox!
    
    @IBOutlet weak var lblDatabaseBackupPath: NSTextField!
    @IBOutlet weak var lblDBBackupUsedSpace: NSTextField!
    @IBOutlet weak var btnBackupNow: NSButton!
    @IBOutlet weak var btnCalculateBackupDiskSpace: NSButton!
    @IBOutlet weak var btnGotoDBBackupPath: NSButton!
    
    
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
    
    @IBOutlet weak var txtLocalDBBinPath: NSTextField!
    @IBOutlet weak var chkPostgresInApp: NSButton!
    @IBOutlet weak var chkPostgresByBrew: NSButton!
    
    @IBOutlet weak var lblBackupLocation: NSTextField!
    @IBOutlet weak var lblDataCloneFrom: NSTextField!
    @IBOutlet weak var lblDataCloneTo: NSTextField!
    @IBOutlet weak var lblDataCloneToDatabase: NSTextField!
    @IBOutlet weak var lblDataCloneToPgCmdline: NSTextField!
    
    // MARK: - DATABASE SAVE BUTTON
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        self.saveDatabaseSection(defaults)
        self.dismiss(sender)
    }
    
    // MARK: - ACTION FOR DATABASE SECTION
    
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
    
    @IBAction func onGotoLocalDBFilePathClicked(_ sender: NSButton) {
        self.lblLocalDBFileMessage.stringValue = "TODO."
    }
    
    
    @IBAction func onBackupLocalClicked(_ sender: NSButton) {
        self.btnLocalDBFileBackup.isEnabled = false
        self.lblLocalDBFileMessage.stringValue = Words.preference_tab_creating_backup.word()
        DispatchQueue.global().async {
            let (backupFolder, status, error) = ExecutionEnvironment.default.createDatabaseBackup(.localFile, suffix: "-on-runtime")
            DispatchQueue.main.async {
                self.btnLocalDBFileBackup.isEnabled = true
                if status == false {
                    self.lblLocalDBFileMessage.stringValue = Words.preference_tab_backup_failed.fill(arguments: "\(error.debugDescription)")
                }else{
                    self.lblLocalDBFileMessage.stringValue = Words.preference_tab_backup_created.fill(arguments: "\(backupFolder)")
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
        self.lblLocalDBServerMessage.stringValue = Words.preference_tab_creating_backup.word()
        DispatchQueue.global().async {
            let (backupFolder, status, error) = ExecutionEnvironment.default.createDatabaseBackup(.localDBServer, suffix: "-on-runtime")
            DispatchQueue.main.async {
                self.btnLocalDBServerBackup.isEnabled = true
                if status == false {
                    self.lblLocalDBServerMessage.stringValue = Words.preference_tab_backup_failed.fill(arguments: "\(error.debugDescription)")
                }else{
                    self.lblLocalDBServerMessage.stringValue = Words.preference_tab_backup_created.fill(arguments: "\(backupFolder)")
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
                    self.lblLocalDBServerMessage.stringValue = Words.preference_tab_backup_no_schema.word()
                }
            }
        }
    }
    
    // MARK: REMOTE DB SERVER
    
    @IBAction func onBackupRemoteServerClicked(_ sender: NSButton) {
        self.btnRemoteDBServerBackup.isEnabled = false
        self.lblRemoteDBServerMessage.stringValue = Words.preference_tab_creating_backup.word()
        DispatchQueue.global().async {
            let (backupFolder, status, error) = ExecutionEnvironment.default.createDatabaseBackup(.remoteDBServer, suffix: "-on-runtime")
            DispatchQueue.main.async {
                self.btnRemoteDBServerBackup.isEnabled = true
                if status == false {
                    self.lblRemoteDBServerMessage.stringValue = Words.preference_tab_backup_failed.fill(arguments: "\(error.debugDescription)")
                }else{
                    self.lblRemoteDBServerMessage.stringValue = Words.preference_tab_backup_created.fill(arguments: "\(backupFolder)")
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
            self.lblDBBackupUsedSpace.stringValue = Words.preference_tab_backup_used_space.fill(arguments: "\(Double(sizeGB).rounded(toPlaces: 2))", "\(spaceFree)")
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
        self.lblDBBackupUsedSpace.stringValue = Words.preference_tab_creating_backup.word()
        DispatchQueue.global().async {
            let (backupFolder, status, error) = ExecutionEnvironment.default.createDatabaseBackup(suffix: "-on-runtime")
            DispatchQueue.main.async {
                self.btnBackupNow.isEnabled = true
                if status == false {
                    self.lblDBBackupUsedSpace.stringValue = Words.preference_tab_backup_failed.fill(arguments: "\(error.debugDescription)")
                }else{
                    self.lblDBBackupUsedSpace.stringValue = Words.preference_tab_backup_created.fill(arguments: "\(backupFolder)")
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
                self.lblDataCloneMessage.stringValue = Words.preference_tab_data_clone_one_row_should_be_selected.word()
                return
            }
            guard let cmd = DatabaseBackupController.getPostgresCommandPath() else {
                self.lblDataCloneMessage.stringValue = Words.preference_tab_data_clone_unable_to_locate_psql_command.word()
                return
            }
            let database = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let checkDatabase = self.lblCheckDatabaseName.stringValue
            guard database != "" else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblCheckDatabaseName.stringValue = Words.preference_tab_data_clone_empty_database_name.word()
                return
            }
            self.logger.log(checkDatabase)
            guard (checkDatabase == Words.preference_tab_backup_not_exist_database.word()
                   || checkDatabase == Words.preference_tab_backup_created_database.word()
                   || checkDatabase == Words.preference_tab_backup_empty_database.word()) else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblDataCloneMessage.stringValue = Words.preference_tab_data_clone_check_target_database_exist_empty.word()
                return
            }
            let row = self.tblDatabaseArchives.selectedRow
            let timestamp = self.backupArchives[row].0
            let folder = self.backupArchives[row].3
            self.logger.log("restore from \(folder)")
            
            var host = ""
            var port = 5432
            var user = ""
            var message = ""
            if self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
                host = DatabaseBackupController.localDBServer()
                port = DatabaseBackupController.localDBPort()
                user = DatabaseBackupController.localDBUsername()
                message = Words.preference_tab_backup_restoring_archive_to_local_postgres.fill(arguments: "\(timestamp)", "\(database)")
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = DatabaseBackupController.remoteDBServer()
                port = DatabaseBackupController.remoteDBPort()
                user = DatabaseBackupController.remoteDBUsername()
                message = Words.preference_tab_backup_restoring_archive_to_remote_postgres.fill(arguments: "\(timestamp)", "\(database)")
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
                    self.lblDataCloneMessage.stringValue = Words.preference_tab_backup_restore_archive_completed.fill(arguments: "\(timestamp)", "\(database)")
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
                host = DatabaseBackupController.localDBServer()
                port = DatabaseBackupController.localDBPort()
                user = DatabaseBackupController.localDBUsername()
                database = DatabaseBackupController.localDBDatabase()
                psw = DatabaseBackupController.localDBPassword()
                nopsw = DatabaseBackupController.localDBNoPassword()
                schema = DatabaseBackupController.localDBSchema()
                message = Words.preference_tab_data_clone_from_sqlite_to_local_postgres.word()
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = DatabaseBackupController.remoteDBServer()
                port = DatabaseBackupController.remoteDBPort()
                user = DatabaseBackupController.remoteDBUsername()
                database = DatabaseBackupController.remoteDBDatabase()
                psw = DatabaseBackupController.remoteDBPassword()
                nopsw = DatabaseBackupController.remoteDBNoPassword()
                schema = DatabaseBackupController.remoteDBSchema()
                message = Words.preference_tab_data_clone_from_sqlite_to_remote_postgres.word()
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
                        self.lblDataCloneMessage.stringValue = Words.preference_tab_data_clone_completed.word()
                    }
                })
            }
        }else if self.toggleGroup_CloneFromDBLocation.selected == "localDBServer" {
            
            guard let cmd = DatabaseBackupController.getPostgresCommandPath() else {
                self.lblDataCloneMessage.stringValue = Words.preference_tab_data_clone_unable_to_locate_psql_command.word()
                return
            }
            let database = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let checkDatabase = self.lblCheckDatabaseName.stringValue
            guard database != "" else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblCheckDatabaseName.stringValue = Words.preference_tab_backup_empty_database.word()
                return
            }
            self.logger.log(checkDatabase)
            guard (checkDatabase == Words.preference_tab_backup_not_exist_database.word()
                   || checkDatabase == Words.preference_tab_backup_created_database.word()
                   || checkDatabase == Words.preference_tab_backup_empty_database.word()) else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblDataCloneMessage.stringValue = Words.preference_tab_data_clone_check_target_database_exist_empty.word()
                return
            }
            var host = ""
            var port = 5432
            var user = ""
            var message = ""
            if       self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
                host = DatabaseBackupController.localDBServer()
                port = DatabaseBackupController.localDBPort()
                user = DatabaseBackupController.localDBUsername()
                message = Words.preference_tab_data_clone_from_local_postgres_to_local_postgres.word()
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = DatabaseBackupController.remoteDBServer()
                port = DatabaseBackupController.remoteDBPort()
                user = DatabaseBackupController.remoteDBUsername()
                message = Words.preference_tab_data_clone_from_local_postgres_to_remote_postgres.word()
            }else{
                self.lblDataCloneMessage.stringValue = "TODO from local postgres to sqlite"
                return
            }
            self.toggleDatabaseClonerButtons(state: false)
            self.lblDataCloneMessage.stringValue = message
            DispatchQueue.global().async {
                let (_, _) = PostgresConnection.default.cloneDatabase(commandPath: cmd,
                                                                      srcDatabase: DatabaseBackupController.localDBDatabase(),
                                                                      srcHost: DatabaseBackupController.localDBServer(),
                                                                      srcPort: DatabaseBackupController.localDBPort(),
                                                                      srcUser: DatabaseBackupController.localDBUsername(),
                                                                      destDatabase: database,
                                                                      destHost: host,
                                                                      destPort: port,
                                                                      destUser: user)
                DispatchQueue.main.async {
                    self.toggleDatabaseClonerButtons(state: true)
                    self.lblDataCloneMessage.stringValue = Words.preference_tab_data_clone_from_local_postgres_completed.fill(arguments: "\(database)")
                }
            }
        }else if self.toggleGroup_CloneFromDBLocation.selected == "remoteDBServer" {
            
            guard let cmd = DatabaseBackupController.getPostgresCommandPath() else {
                self.lblDataCloneMessage.stringValue = Words.preference_tab_data_clone_unable_to_locate_psql_command.word()
                return
            }
            let database = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let checkDatabase = self.lblCheckDatabaseName.stringValue
            guard database != "" else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblCheckDatabaseName.stringValue = Words.preference_tab_backup_empty_database.word()
                return
            }
            self.logger.log(checkDatabase)
            guard (checkDatabase == Words.preference_tab_backup_not_exist_database.word()
                   || checkDatabase == Words.preference_tab_backup_created_database.word()
                   || checkDatabase == Words.preference_tab_backup_empty_database.word()) else{
                self.txtRestoreToDatabaseName.layer?.borderColor = NSColor.red.cgColor
                self.txtRestoreToDatabaseName.layer?.borderWidth = 1.0
                self.lblDataCloneMessage.stringValue = Words.preference_tab_data_clone_check_target_database_exist_empty.word()
                return
            }
            var host = ""
            var port = 5432
            var user = ""
            var message = ""
            if       self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
                host = DatabaseBackupController.localDBServer()
                port = DatabaseBackupController.localDBPort()
                user = DatabaseBackupController.localDBUsername()
                message = Words.preference_tab_data_clone_from_remote_postgres_to_local_postgres.word()
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = DatabaseBackupController.remoteDBServer()
                port = DatabaseBackupController.remoteDBPort()
                user = DatabaseBackupController.remoteDBUsername()
                message = Words.preference_tab_data_clone_from_remote_postgres_to_remote_postgres.word()
            }else{
                self.lblDataCloneMessage.stringValue = "TODO from remote postgres to sqlite"
                return
            }
            self.toggleDatabaseClonerButtons(state: false)
            self.lblDataCloneMessage.stringValue = message
            DispatchQueue.global().async {
                let (_, _) = PostgresConnection.default.cloneDatabase(commandPath: cmd,
                                                                      srcDatabase: DatabaseBackupController.remoteDBDatabase(),
                                                                      srcHost: DatabaseBackupController.remoteDBServer(),
                                                                      srcPort: DatabaseBackupController.remoteDBPort(),
                                                                      srcUser: DatabaseBackupController.remoteDBUsername(),
                                                                      destDatabase: database,
                                                                      destHost: host,
                                                                      destPort: port,
                                                                      destUser: user)
                DispatchQueue.main.async {
                    self.toggleDatabaseClonerButtons(state: true)
                    self.lblDataCloneMessage.stringValue = Words.preference_tab_data_clone_from_remote_postgres_completed.fill(arguments: "\(database)")
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
        let backupPath = URL(fileURLWithPath: DatabaseBackupController.databasePath()).appendingPathComponent("DataBackup")
        DispatchQueue.global().async {
            for folder in selected {
                let url = backupPath.appendingPathComponent(folder)
                
                self.logger.log("delete backup folder \(folder)")
                do{
                    try FileManager.default.removeItem(at: url)
                }catch{
                    self.logger.log("Unable to delete backup archive: \(url.path)")
                    self.logger.log(error)
                }
            }
            self.loadBackupArchives()
            self.calculateBackupUsedSpace(path: backupPath.path)
        }
    }
    
    @IBAction func onCheckBackupToDatabaseName(_ sender: NSButton) {
        guard let cmd = DatabaseBackupController.getPostgresCommandPath() else {
            self.logger.log("Unable to locate psql command in macOS, check db exist aborted.")
            return
        }
        var host = ""
        var port = 5432
        var user = ""
        if self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
            host = DatabaseBackupController.localDBServer()
            port = DatabaseBackupController.localDBPort()
            user = DatabaseBackupController.localDBUsername()
        }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
            host = DatabaseBackupController.remoteDBServer()
            port = DatabaseBackupController.remoteDBPort()
            user = DatabaseBackupController.remoteDBUsername()
        }else{
            self.logger.log("Selected to-database is not postgres. check db exist aborted.")
            return
        }
        let targetDatabase = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard targetDatabase != "" else {
            self.lblCheckDatabaseName.stringValue = Words.preference_tab_backup_empty_database.word()
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
                let remotedb = PostgresConnection.database(host: host, port: port, user: user, database: targetDatabase, schema: "public", password: "", nopsw: true)
                let tables = remotedb.queryTableInfos()
                if tables.count == 0 {
                    DispatchQueue.main.async {
                        self.lblCheckDatabaseName.stringValue = Words.preference_tab_backup_empty_database.word()
                        self.btnCreateDatabase.isHidden = true
                    }
                }else{
                    DispatchQueue.main.async {
                        self.lblCheckDatabaseName.stringValue = Words.preference_tab_backup_non_empty_database.word()
                        self.btnCreateDatabase.isHidden = true
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.lblCheckDatabaseName.stringValue = Words.preference_tab_backup_not_exist_database.word()
                    self.btnCreateDatabase.isHidden = false
                }
            }
        }
    }
    
    
    @IBAction func onCreateDatabaseClicked(_ sender: NSButton) {
        let databaseName = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard databaseName != "" else {
            self.logger.log("Error: database name is empty")
            return
        }
        guard let cmd = DatabaseBackupController.getPostgresCommandPath() else {
            self.logger.log("Unable to locate pg_dump command in macOS, createdb aborted.")
            return
        }
        var host = ""
        var port = 5432
        var user = ""
        if self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
            host = DatabaseBackupController.localDBServer()
            port = DatabaseBackupController.localDBPort()
            user = DatabaseBackupController.localDBUsername()
        }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
            host = DatabaseBackupController.remoteDBServer()
            port = DatabaseBackupController.remoteDBPort()
            user = DatabaseBackupController.remoteDBUsername()
        }else{
            self.logger.log("Selected to-database is not postgres. createdb aborted.")
            return
        }
        
        self.btnCreateDatabase.isEnabled = false
        
        // TODO: SAVE ALL FIELDS BEFORE START CREATEDB
        DispatchQueue.global().async {
            
            let (status, _, pgError, err) = PostgresConnection.default.createDatabase(commandPath: cmd, database: databaseName, host: host, port: port, user: user)
            
            if status == true {
                self.logger.log("created database \(databaseName) on \(user)@\(host):\(port)")
                DispatchQueue.main.async {
                    self.btnCreateDatabase.isEnabled = true
                    self.lblCheckDatabaseName.stringValue = Words.preference_tab_backup_created_database.word()
                }
            }else{
                self.logger.log("Unable to create database \(databaseName) on \(user)@\(host):\(port)")
                self.logger.log(pgError)
                if let error = err {
                    self.logger.log(error)
                }
                DispatchQueue.main.async {
                    self.btnCreateDatabase.isEnabled = true
                    self.lblCheckDatabaseName.stringValue = Words.preference_tab_backup_create_database_failed.word()
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
            self.lblDataCloneMessage.stringValue = Words.preference_tab_backup_installed_by_homebrew_error.fill(arguments: path)
            sender.state = .off
        }
       
    }
    
    @IBAction func onCheckInstallPostgresInApp(_ sender: NSButton) {
        let path = "/Applications/Postgres.app/Contents/Versions/latest/bin"
        if let postgresCommandPath = ExecutionEnvironment.default.findPostgresCommand(from: [path]) {
            self.toggleGroup_InstalledPostgres.selected = postgresCommandPath
            self.txtLocalDBBinPath.stringValue = postgresCommandPath
        }else{
            self.lblDataCloneMessage.stringValue = Words.preference_tab_backup_installed_by_postgresapp_error.fill(arguments: path)
            sender.state = .off
        }
    }
    
    // MARK: DATABASE
    
    static let predefinedLocalDBFilePath = AppDelegate.current.applicationDocumentsDirectory.path
    
    class func configuredDatabaseInfo() -> (String, String, String, String) {
        var dbEngine = ""
        var location = databaseLocation()
        if location == "local" {
            dbEngine = "SQLite"
        }else if location == "localServer" {
            dbEngine = "PostgreSQL"
            location = "local"
        }else if location == "network" {
            dbEngine = "PostgreSQL"
            location = "remote"
        }
        
        var server = ""
        var dbName = ""
        if dbEngine == "PostgreSQL" {
            if location == "local" {
                server = localDBServer()
                dbName = localDBDatabase()
            }else {
                server = remoteDBServer()
                dbName = remoteDBDatabase()
            }
        }
        return (location, dbEngine, server, dbName)
    }
    
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
    
    class func isSQLite() -> Bool {
        if databaseLocation() == "local" {
            return true
        }else{
            return false
        }
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
    
    // MARK: - SAVE SETTINGS
    
    
    func saveDatabaseSection(_ defaults:UserDefaults) {
        
        defaults.set(self.toggleGroup_DBLocation.selected,
                     forKey: DatabaseBackupController.databaseLocationKey)
        
        defaults.set(txtLocalDBFilePath.stringValue,
                     forKey: DatabaseBackupController.databasePathKey)
        
        defaults.set(txtRemoteDBServer.stringValue,
                     forKey: DatabaseBackupController.remoteDBServerKey)
        
        if let _ = Int(txtRemoteDBPort.stringValue) {
            defaults.set(txtRemoteDBPort.stringValue,
                         forKey: DatabaseBackupController.remoteDBPortKey)
        }else{
            defaults.set("5432",
                         forKey: DatabaseBackupController.remoteDBPortKey)
        }
        
        defaults.set(txtRemoteDBUser.stringValue,
                     forKey: DatabaseBackupController.remoteDBUsernameKey)
        
        defaults.set(txtRemoteDBPassword.stringValue,
                     forKey: DatabaseBackupController.remoteDBPasswordKey)
        
        defaults.set(txtRemoteDBSchema.stringValue,
                     forKey: DatabaseBackupController.remoteDBSchemaKey)
        
        defaults.set(txtRemoteDBDatabase.stringValue,
                     forKey: DatabaseBackupController.remoteDBDatabaseKey)
        
        defaults.set(chkRemoteDBNoPassword.state == .on ? "true" : "false",
                     forKey: DatabaseBackupController.remoteDBNoPasswordKey)
        
        
        
        defaults.set(txtLocalDBServer.stringValue,
                     forKey: DatabaseBackupController.localDBServerKey)
        
        if let _ = Int(txtLocalDBPort.stringValue) {
            defaults.set(txtLocalDBPort.stringValue,
                         forKey: DatabaseBackupController.localDBPortKey)
        }else{
            defaults.set("5432",
                         forKey: DatabaseBackupController.localDBPortKey)
        }
        
        defaults.set(txtLocalDBUser.stringValue,
                     forKey: DatabaseBackupController.localDBUsernameKey)
        
        defaults.set(txtLocalDBPassword.stringValue,
                     forKey: DatabaseBackupController.localDBPasswordKey)
        
        defaults.set(txtLocalDBSchema.stringValue,
                     forKey: DatabaseBackupController.localDBSchemaKey)
        
        defaults.set(txtLocalDBDatabase.stringValue,
                     forKey: DatabaseBackupController.localDBDatabaseKey)
        
        defaults.set(chkLocalDBNoPassword.state == .on ? "true" : "false",
                     forKey: DatabaseBackupController.localDBNoPasswordKey)
    }
    
    func saveBackupSection(_ defaults:UserDefaults) {
        
    }
    
    
    
    // MARK: - INIT SECTIONS
    
    
    func initDatabaseSection() {
        self.boxLocalSQLite.title = Words.preference_tab_database_box_local_sqlite.word()
        self.boxLocalPostgres.title = Words.preference_tab_database_box_local_postgres.word()
        self.boxRemotePostgres.title = Words.preference_tab_database_box_remote_postgres.word()
        self.lblLocalSQLitePath.stringValue = Words.preference_tab_database_sqlite_location.word()
        self.btnBrowseLocalDBFilePath.title = Words.preference_tab_database_browse.word()
        self.btnGotoLocalDBFilePath.title = Words.preference_tab_database_goto.word()
        self.btnLocalDBFileBackup.title = Words.preference_tab_database_backup_now.word()
        self.btnLocalDBFileTest.title = Words.preference_tab_database_test_connect.word()
        self.lblLocalPgServer.stringValue = Words.preference_tab_database_postgre_server.word()
        self.lblLocalPgPort.stringValue = Words.preference_tab_database_postgre_port.word()
        self.lblLocalPgUser.stringValue = Words.preference_tab_database_postgre_user.word()
        self.lblLocalPgPassword.stringValue = Words.preference_tab_database_postgre_password.word()
        self.lblLocalPgSchema.stringValue = Words.preference_tab_database_postgre_schema.word()
        self.lblLocalPgDatabase.stringValue = Words.preference_tab_database_postgre_database.word()
        self.chkLocalDBNoPassword.title = Words.preference_tab_database_postgre_no_password.word()
        self.btnLocalDBServerBackup.title = Words.preference_tab_database_backup_now.word()
        self.btnLocalDBServerTest.title = Words.preference_tab_database_test_connect.word()
        self.lblRemotePgServer.stringValue = Words.preference_tab_database_postgre_server.word()
        self.lblRemotePgPort.stringValue = Words.preference_tab_database_postgre_port.word()
        self.lblRemotePgUser.stringValue = Words.preference_tab_database_postgre_user.word()
        self.lblRemotePgPassword.stringValue = Words.preference_tab_database_postgre_password.word()
        self.lblRemotePgSchema.stringValue = Words.preference_tab_database_postgre_schema.word()
        self.lblRemotePgDatabase.stringValue = Words.preference_tab_database_postgre_database.word()
        self.chkRemoteDBNoPassword.title = Words.preference_tab_database_postgre_no_password.word()
        self.btnRemoteDBServerBackup.title = Words.preference_tab_database_backup_now.word()
        self.btnRemoteDBTest.title = Words.preference_tab_database_test_connect.word()
        
        txtLocalDBFilePath.stringValue = DatabaseBackupController.databasePath()
        
        txtRemoteDBServer.stringValue = DatabaseBackupController.remoteDBServer()
        txtRemoteDBPort.stringValue = "\(DatabaseBackupController.remoteDBPort())"
        txtRemoteDBUser.stringValue = DatabaseBackupController.remoteDBUsername()
        txtRemoteDBPassword.stringValue = DatabaseBackupController.remoteDBPassword()
        txtRemoteDBSchema.stringValue = DatabaseBackupController.remoteDBSchema()
        txtRemoteDBDatabase.stringValue = DatabaseBackupController.remoteDBDatabase()
        
        let remoteDBNoPassword = DatabaseBackupController.remoteDBNoPassword()
        if remoteDBNoPassword {
            self.chkRemoteDBNoPassword.state = .on
            self.txtRemoteDBPassword.isEditable = false
        }else{
            self.chkRemoteDBNoPassword.state = .off
            self.txtRemoteDBPassword.isEditable = true
        }
        
        txtLocalDBServer.stringValue = DatabaseBackupController.localDBServer()
        txtLocalDBPort.stringValue = "\(DatabaseBackupController.localDBPort())"
        txtLocalDBUser.stringValue = DatabaseBackupController.localDBUsername()
        txtLocalDBPassword.stringValue = DatabaseBackupController.localDBPassword()
        txtLocalDBSchema.stringValue = DatabaseBackupController.localDBSchema()
        txtLocalDBDatabase.stringValue = DatabaseBackupController.localDBDatabase()
        
        let localDBNoPassword = DatabaseBackupController.localDBNoPassword()
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
        self.boxBackup.title = Words.preference_tab_backup_box_backup.word()
        self.boxDataClone.title = Words.preference_tab_backup_box_data_clone.word()
        self.lblBackupLocation.stringValue = Words.preference_tab_backup_box_backup_location.word()
        self.btnBackupNow.title = Words.preference_tab_database_backup_now.word()
        self.btnCalculateBackupDiskSpace.title = Words.preference_tab_backup_calc_disk_space.word()
        self.btnGotoDBBackupPath.title = Words.preference_tab_database_goto.word()
        self.lblDataCloneFrom.stringValue = Words.preference_tab_backup_from.word()
        self.lblDataCloneTo.stringValue = Words.preference_tab_backup_to.word()
        self.chkDeleteAllBeforeClone.title = Words.preference_tab_backup_delete_original_data.word()
        self.btnCloneLocalToRemote.title = Words.preference_tab_backup_clone_now.word()
        self.chkFromLocalDBFile.title = Words.preference_tab_backup_local_sqlite.word()
        self.chkFromLocalDBServer.title = Words.preference_tab_backup_local_postgresql.word()
        self.chkFromRemoteDBServer.title = Words.preference_tab_backup_remote_postgresql.word()
        self.chkFromBackupArchive.title = Words.preference_tab_backup_restore_from_backup.word()
        self.chkToLocalDBFile.title = Words.preference_tab_backup_local_sqlite.word()
        self.chkToLocalDBServer.title = Words.preference_tab_backup_local_postgresql.word()
        self.chkToRemoteDBServer.title = Words.preference_tab_backup_remote_postgresql.word()
        self.lblDataCloneToDatabase.stringValue = Words.preference_tab_backup_to_database.word()
        self.lblDataCloneToPgCmdline.stringValue = Words.preference_tab_backup_pg_cmdline.word()
        self.chkPostgresByBrew.title = Words.preference_tab_backup_installed_by_homebrew.word()
        self.chkPostgresInApp.title = Words.preference_tab_backup_installed_by_postgresapp.word()
        self.btnDeleteDBArchives.title = Words.preference_tab_backup_delete_backup.word()
        self.btnReloadDBArchives.title = Words.preference_tab_backup_reload_backup.word()
        
        self.tblDatabaseArchives.backgroundColor = NSColor.black
        self.tblDatabaseArchives.delegate = self
        self.tblDatabaseArchives.dataSource = self
        self.tblDatabaseArchives.allowsMultipleSelection = true
        
        self.btnCreateDatabase.isHidden = true
        
        self.lblDatabaseBackupPath.stringValue = URL(fileURLWithPath: DatabaseBackupController.databasePath()).appendingPathComponent("DataBackup").path
        
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
                    self.txtRestoreToDatabaseName.stringValue = DatabaseBackupController.localDBDatabase()
                }else if option == "remoteDBServer" {
                    self.txtRestoreToDatabaseName.stringValue = DatabaseBackupController.remoteDBDatabase()
                }
        })
        
        self.toggleGroup_DBLocation.selected = DatabaseBackupController.databaseLocation()
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
            self.lblDataCloneMessage.stringValue = Words.preference_tab_backup_installed_error.word()
        }
        
    }
    
    // MARK: VIEW INIT
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Words.preference_dialog_title.word()
        // Do any additional setup after loading the view.
        self.setupTabs()
        self.initDatabaseSection()
        self.initBackupSection()
        
    }
    
    func setupTabs() {
        self.view.window?.title = Words.mainmenu_database_and_backup.word()
        self.btnSaveDatabase.title = Words.apply.word()
        self.tabs.tabViewItem(at: 0).label = Words.preference_tab_database.word()
        self.tabs.tabViewItem(at: 1).label = Words.preference_tab_backup.word()
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

extension DatabaseBackupController : NSTableViewDelegate, NSTableViewDataSource{
    
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
        rowView.backgroundColor = Colors.DarkGray
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
