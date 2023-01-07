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
                host = Setting.database.localPostgres.server()
                port = Setting.database.localPostgres.port()
                user = Setting.database.localPostgres.username()
                message = Words.preference_tab_backup_restoring_archive_to_local_postgres.fill(arguments: "\(timestamp)", "\(database)")
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = Setting.database.remotePostgres.server()
                port = Setting.database.remotePostgres.port()
                user = Setting.database.remotePostgres.username()
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
                host = Setting.database.localPostgres.server()
                port = Setting.database.localPostgres.port()
                user = Setting.database.localPostgres.username()
                database = Setting.database.localPostgres.database()
                psw = Setting.database.localPostgres.password()
                nopsw = Setting.database.localPostgres.noPassword()
                schema = Setting.database.localPostgres.schema()
                message = Words.preference_tab_data_clone_from_sqlite_to_local_postgres.word()
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = Setting.database.remotePostgres.server()
                port = Setting.database.remotePostgres.port()
                user = Setting.database.remotePostgres.username()
                database = Setting.database.remotePostgres.database()
                psw = Setting.database.remotePostgres.password()
                nopsw = Setting.database.remotePostgres.noPassword()
                schema = Setting.database.remotePostgres.schema()
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
                host = Setting.database.localPostgres.server()
                port = Setting.database.localPostgres.port()
                user = Setting.database.localPostgres.username()
                message = Words.preference_tab_data_clone_from_local_postgres_to_local_postgres.word()
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = Setting.database.remotePostgres.server()
                port = Setting.database.remotePostgres.port()
                user = Setting.database.remotePostgres.username()
                message = Words.preference_tab_data_clone_from_local_postgres_to_remote_postgres.word()
            }else{
                self.lblDataCloneMessage.stringValue = "TODO from local postgres to sqlite"
                return
            }
            self.toggleDatabaseClonerButtons(state: false)
            self.lblDataCloneMessage.stringValue = message
            DispatchQueue.global().async {
                let (_, _) = PostgresConnection.default.cloneDatabase(commandPath: cmd,
                                                                      srcDatabase: Setting.database.localPostgres.database(),
                                                                      srcHost: Setting.database.localPostgres.server(),
                                                                      srcPort: Setting.database.localPostgres.port(),
                                                                      srcUser: Setting.database.localPostgres.username(),
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
                host = Setting.database.localPostgres.server()
                port = Setting.database.localPostgres.port()
                user = Setting.database.localPostgres.username()
                message = Words.preference_tab_data_clone_from_remote_postgres_to_local_postgres.word()
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                host = Setting.database.remotePostgres.server()
                port = Setting.database.remotePostgres.port()
                user = Setting.database.remotePostgres.username()
                message = Words.preference_tab_data_clone_from_remote_postgres_to_remote_postgres.word()
            }else{
                self.lblDataCloneMessage.stringValue = "TODO from remote postgres to sqlite"
                return
            }
            self.toggleDatabaseClonerButtons(state: false)
            self.lblDataCloneMessage.stringValue = message
            DispatchQueue.global().async {
                let (_, _) = PostgresConnection.default.cloneDatabase(commandPath: cmd,
                                                                      srcDatabase: Setting.database.remotePostgres.database(),
                                                                      srcHost: Setting.database.remotePostgres.server(),
                                                                      srcPort: Setting.database.remotePostgres.port(),
                                                                      srcUser: Setting.database.remotePostgres.username(),
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
        let backupPath = URL(fileURLWithPath: Setting.database.sqlite.databasePath()).appendingPathComponent("DataBackup")
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
            host = Setting.database.localPostgres.server()
            port = Setting.database.localPostgres.port()
            user = Setting.database.localPostgres.username()
        }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
            host = Setting.database.remotePostgres.server()
            port = Setting.database.remotePostgres.port()
            user = Setting.database.remotePostgres.username()
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
            host = Setting.database.localPostgres.server()
            port = Setting.database.localPostgres.port()
            user = Setting.database.localPostgres.username()
        }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
            host = Setting.database.remotePostgres.server()
            port = Setting.database.remotePostgres.port()
            user = Setting.database.remotePostgres.username()
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
    
    // MARK: - SAVE SETTINGS
    
    
    func saveDatabaseSection(_ defaults:UserDefaults) {
        Setting.database.saveDatabaseLocation(self.toggleGroup_DBLocation.selected)
        
        Setting.database.sqlite.saveDatabasePath(txtLocalDBFilePath.stringValue)
        
        Setting.database.localPostgres.saveHost(txtLocalDBServer.stringValue)
        Setting.database.localPostgres.savePort(txtLocalDBPort.stringValue)
        Setting.database.localPostgres.saveUsername(txtLocalDBUser.stringValue)
        Setting.database.localPostgres.savePassword(txtLocalDBPassword.stringValue)
        Setting.database.localPostgres.saveNoPassword(chkLocalDBNoPassword.state == .on)
        Setting.database.localPostgres.saveSchema(txtLocalDBSchema.stringValue)
        Setting.database.localPostgres.saveDatabase(txtLocalDBDatabase.stringValue)
        
        Setting.database.remotePostgres.saveHost(txtRemoteDBServer.stringValue)
        Setting.database.remotePostgres.savePort(txtRemoteDBPort.stringValue)
        Setting.database.remotePostgres.saveUsername(txtRemoteDBUser.stringValue)
        Setting.database.remotePostgres.savePassword(txtRemoteDBPassword.stringValue)
        Setting.database.remotePostgres.saveNoPassword(chkRemoteDBNoPassword.state == .on)
        Setting.database.remotePostgres.saveSchema(txtRemoteDBSchema.stringValue)
        Setting.database.remotePostgres.saveDatabase(txtRemoteDBDatabase.stringValue)
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
        
        txtLocalDBFilePath.stringValue = Setting.database.sqlite.databasePath()
        
        txtRemoteDBServer.stringValue = Setting.database.remotePostgres.server()
        txtRemoteDBPort.stringValue = "\(Setting.database.remotePostgres.port())"
        txtRemoteDBUser.stringValue = Setting.database.remotePostgres.username()
        txtRemoteDBPassword.stringValue = Setting.database.remotePostgres.password()
        txtRemoteDBSchema.stringValue = Setting.database.remotePostgres.schema()
        txtRemoteDBDatabase.stringValue = Setting.database.remotePostgres.database()
        
        let remoteDBNoPassword = Setting.database.remotePostgres.noPassword()
        if remoteDBNoPassword {
            self.chkRemoteDBNoPassword.state = .on
            self.txtRemoteDBPassword.isEditable = false
        }else{
            self.chkRemoteDBNoPassword.state = .off
            self.txtRemoteDBPassword.isEditable = true
        }
        
        txtLocalDBServer.stringValue = Setting.database.localPostgres.server()
        txtLocalDBPort.stringValue = "\(Setting.database.localPostgres.port())"
        txtLocalDBUser.stringValue = Setting.database.localPostgres.username()
        txtLocalDBPassword.stringValue = Setting.database.localPostgres.password()
        txtLocalDBSchema.stringValue = Setting.database.localPostgres.schema()
        txtLocalDBDatabase.stringValue = Setting.database.localPostgres.database()
        
        let localDBNoPassword = Setting.database.localPostgres.noPassword()
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
        
        self.lblDatabaseBackupPath.stringValue = URL(fileURLWithPath: Setting.database.sqlite.databasePath()).appendingPathComponent("DataBackup").path
        
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
                    self.txtRestoreToDatabaseName.stringValue = Setting.database.localPostgres.database()
                }else if option == "remoteDBServer" {
                    self.txtRestoreToDatabaseName.stringValue = Setting.database.remotePostgres.database()
                }
        })
        
        self.toggleGroup_DBLocation.selected = Setting.database.databaseLocation()
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
        self.title = Words.database_backup_dialog_title.word()
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
