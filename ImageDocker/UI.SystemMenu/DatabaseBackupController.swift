//
//  DatabaseBackupController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2022/2/13.
//  Copyright © 2022 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory
import PostgresModelFactory
import CryptoSwift

final class DatabaseBackupController: NSViewController {
    
    let logger = LoggerFactory.get(category: "DatabaseBackupController")
    
    
    // MARK: - VIEW INIT
    @IBOutlet weak var tabs: NSTabView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Words.database_backup_dialog_title.word()
        // Do any additional setup after loading the view.
        self.setupTabs()
        self.initDatabaseSection()
        self.initBackupSection()
        self.initEngineSection()
        
    }
    
    func setupTabs() {
        self.view.window?.title = Words.mainmenu_database_and_backup.word()
        self.btnSaveDatabase.title = Words.apply.word()
        self.tabs.tabViewItem(at: 0).label = Words.preference_tab_database.word()
        self.tabs.tabViewItem(at: 1).label = Words.preference_tab_backup.word()
        self.tabs.tabViewItem(at: 2).label = Words.preference_tab_engine.word()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    // MARK: - DATABASE
    
    
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
    
    
    func initDatabaseSection() {
        
        self.databaseProfilesStackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
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
        
        self.chkDatabaseMysql.state = .off
        self.chkDatabasePostgresql.state = .on
        self.chkDatabaseUseSSL.state = .off
        self.chkDatabaseNoPsw.state = .on
        
        self.lblDatabaseMessage.stringValue = ""
        self.loadDatabaseProfiles()
        
    }
    
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
    
    // MARK: DATABASE SAVE BUTTON
    @IBAction func onButtonApplyClick(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        self.saveDatabaseSection(defaults)
        self.dismiss(sender)
    }
    
    // MARK: ACTION FOR DATABASE SECTION
    
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
            final class Version : DatabaseRecord {
                var ver:Int = 0
                public init() {}
            }
            do {
                if let version = try Version.fetchOne(PostgresConnection.database(.localDBServer), sql: "select substring(ver, '\\d+')::int versions from version_migrations order by versions desc") {
                    DispatchQueue.main.async {
                        self.lblLocalDBServerMessage.stringValue = "v\(version.ver)"
                    }
                }else{
                    DispatchQueue.main.async {
                        self.lblLocalDBServerMessage.stringValue = Words.preference_tab_backup_no_schema.word()
                    }
                }
            }catch{
                self.logger.log(.error, error)
                DispatchQueue.main.async {
                    self.lblLocalDBServerMessage.stringValue = "DB ERROR"
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
    
    // MARK: - DATABASE PROFILES
    
    
    @IBOutlet weak var databaseProfilesStackView: NSStackView!
    var databaseProfileFlowListItems:[String:DatabaseProfileFlowListItemController] = [:]
    var databaseProfiles:[String:DatabaseProfile] = [:]
    
    @IBOutlet weak var boxDatabaseProfile: NSBox!
    @IBOutlet weak var btnNewDatabaseProfile: NSButton!
    @IBOutlet weak var lblDatabaseEngine: NSTextField!
    @IBOutlet weak var lblDatabaseHost: NSTextField!
    @IBOutlet weak var lblDatabasePort: NSTextField!
    @IBOutlet weak var lblDatabaseName: NSTextField!
    @IBOutlet weak var lblDatabaseSchema: NSTextField!
    @IBOutlet weak var lblDatabaseUsername: NSTextField!
    @IBOutlet weak var lblDatabasePassword: NSTextField!
    @IBOutlet weak var lblDatabaseNoPsw: NSTextField!
    @IBOutlet weak var imgDatabasePostgresql: NSImageView!
    @IBOutlet weak var imgDatabaseMysql: NSImageView!
    @IBOutlet weak var chkDatabasePostgresql: NSButton!
    @IBOutlet weak var chkDatabaseMysql: NSButton!
    @IBOutlet weak var txtDatabaseHost: NSTextField!
    @IBOutlet weak var txtDatabasePort: NSTextField!
    @IBOutlet weak var txtDatabaseName: NSTextField!
    @IBOutlet weak var txtDatabaseSchema: NSTextField!
    @IBOutlet weak var txtDatabaseUsername: NSTextField!
    @IBOutlet weak var chkDatabaseUseSSL: NSButton!
    @IBOutlet weak var chkDatabaseNoPsw: NSButton!
    @IBOutlet weak var btnSaveDatabaseProfile: NSButton!
    @IBOutlet weak var btnClearDatabaseProfile: NSButton!
    @IBOutlet weak var txtDatabasePassword: DSFSecureTextField!
    @IBOutlet weak var lblDatabaseTimeout: NSTextField!
    @IBOutlet weak var lstDatabaseTimeout: NSComboBox!
    @IBOutlet weak var lblDatabaseMessage: NSTextField!
    
    @IBOutlet weak var btnCreateDatabase: NSButton!
    
    func saveDatabaseProfiles() {
        Setting.database.saveDatabaseJson(self.databaseProfilesToJSON())
    }
    
    var _selectedProfileId = ""
    
    func changeSelectedProfileId(profile:DatabaseProfile) {
        if _selectedProfileId != profile.id() && _selectedProfileId != "" {
            self.lblDatabaseMessage.stringValue = "You have changed database, would you like a restart?"
        }
    }
    
    func loadDatabaseProfiles() {
        self.lblDatabaseMessage.stringValue = ""
        let json = Setting.database.databaseJson()
        print(json)
        let profiles = self.databaseProfilesFromJSON(json).sorted { p1, p2 in
            return p1.id() < p2.id()
        }
        if let selectedProfile = profiles.first(where: { p in
            return p.selected
        }) {
            self.changeSelectedProfileId(profile: selectedProfile)
        }
        var dict:[String:DatabaseProfile] = [:]
        for profile in profiles {
            dict[profile.id()] = profile
        }
        self.databaseProfiles = dict
        
        for profile in profiles {
            self.updateDatabaseProfile(profile: profile)
            
            
        }
        
        if self.databaseProfileFlowListItems.count == 0 {
            self.addEmptyDatabaseProfile()
        }
    }
    
    
    
    public func databaseProfilesToJSON() -> String {
        let array = self.databaseProfiles.values.map { dp in
            return dp
        }
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(array)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)
            return json ?? "{}"
        }catch{
            print(error)
            return "{}"
        }
    }
    
    public func databaseProfilesFromJSON(_ jsonString:String) -> [DatabaseProfile]{
        let jsonDecoder = JSONDecoder()
        do{
            return try jsonDecoder.decode([DatabaseProfile].self, from: jsonString.data(using: .utf8)!)
        }catch{
            print(error)
            return []
        }
    }
    
    func addEmptyDatabaseProfile() {
        let profile = DatabaseProfile()
        profile.host = "127.0.0.1"
        profile.database = "ImageDocker"
        profile.engine = "PostgreSQL"
        profile.port = 5432
        profile.schema = "public"
        profile.user = "postgres"
        profile.nopsw = true
        profile.ssl = false
        profile.selected = true
        self.updateDatabaseProfile(profile: profile)
    }
    
    func updateDatabaseProfile(profile:DatabaseProfile) {
        if let viewController = self.databaseProfileFlowListItems[profile.id()] {
            viewController.updateFields(databaseProfile: profile)
            self.databaseProfiles[profile.id()] = profile
        }else{
            self.addDatabaseProfile(profile: profile)
        }
        self.saveDatabaseProfiles()
        self.checkDatabaseVersion(profile: profile)
    }
    
    func selectDatabaseProfile(profile:DatabaseProfile) {
        self.lblDatabaseMessage.stringValue = ""
        if let vc = self.databaseProfileFlowListItems[profile.id()] {
            if !vc.isConnectable() {
                vc.unselect()
                return
            }
        }else{
            return
        }
        for vc in self.databaseProfileFlowListItems.values {
            vc.unselect()
        }
        for profile in self.databaseProfiles.values {
            profile.selected = false
        }
        if let vc = self.databaseProfileFlowListItems[profile.id()] {
            vc.select()
        }
        if let profile = self.databaseProfiles[profile.id()] {
            profile.selected = true
            self.changeSelectedProfileId(profile: profile)
        }
        self.saveDatabaseProfiles()
    }
    
    func deleteDatabaseProfile(profile:DatabaseProfile) {
        self.lblDatabaseMessage.stringValue = ""
        if profile.selected {
            return
        }
        if let vc = self.databaseProfileFlowListItems[profile.id()] {
            NSLayoutConstraint.deactivate(vc.view.constraints)
            self.databaseProfilesStackView.removeView(vc.view)
        }
        self.databaseProfileFlowListItems.removeValue(forKey: profile.id())
        self.databaseProfiles.removeValue(forKey: profile.id())
        
        self.saveDatabaseProfiles()
        
        if self.databaseProfileFlowListItems.count == 0 {
            self.addEmptyDatabaseProfile()
        }
    }
    
    func checkDatabaseVersion(profile:DatabaseProfile) {
        if let vc = self.databaseProfileFlowListItems[profile.id()] {
            vc.updateStatus2("")
            vc.updateStatus1("Connecting...")
        }
        if profile.engine.lowercased() == "postgresql" {
            DispatchQueue.global().async {
                let rtn = self.checkPostgreSQLVersion(profile: profile)
                if rtn.starts(with: "PostgreSQL") {
                    let parts = rtn.components(separatedBy: " ")
                    let version = parts[1]
                    
                    DispatchQueue.main.async {
                        if let vc = self.databaseProfileFlowListItems[profile.id()] {
                            vc.updateStatus2(version)
                            vc.updateStatus1("Connectable")
                        }
                    }
                }else if rtn.contains(find: "socketError") {
                    DispatchQueue.main.async {
                        if let vc = self.databaseProfileFlowListItems[profile.id()] {
                            vc.updateStatus2("")
                            vc.updateStatus1("Unreachable")
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        if let vc = self.databaseProfileFlowListItems[profile.id()] {
                            vc.updateStatus2("")
                            vc.updateStatus1("Unauthorized")
                        }
                    }
                }
            }
            
        }
    }
    
    func checkPostgreSQLVersion(profile:DatabaseProfile) -> String {
        let db = Database(profile: profile)
        do {
            try db.connect()
            return try db.version()
        }catch{
            return "\(error)"
        }
    }
    
    func addDatabaseProfile(profile:DatabaseProfile) {
        self.lblDatabaseMessage.stringValue = ""
        if self.databaseProfileFlowListItems[profile.id()] != nil {
            return
        }
        let storyboard = NSStoryboard(name: "DatabaseProfileFlowListItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "DatabaseProfileFlowListItem") as! DatabaseProfileFlowListItemController
        
        self.databaseProfiles[profile.id()] = profile
        viewController.initView(databaseProfile: profile,
        onSelect: {
            if let profile = self.databaseProfiles[profile.id()] {
                self.selectDatabaseProfile(profile: profile)
            }
        }, onEdit: {
            if let profile = self.databaseProfiles[profile.id()] {
                self.databaseProfileToForm(profile: profile)
            }
        }, onDelete: {
            if let profile = self.databaseProfiles[profile.id()] {
                self.deleteDatabaseProfile(profile: profile)
            }
        })

        self.databaseProfilesStackView.addArrangedSubview(viewController.view)
        self.databaseProfileFlowListItems[profile.id()] = viewController
        //addChildViewController(viewController)
    }
    
    func databaseProfileFromForm() -> DatabaseProfile {
        let profile = DatabaseProfile()
        profile.engine = self.chkDatabasePostgresql.state == .on ? "PostgreSQL" : "MySQL"
        profile.host = self.txtDatabaseHost.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.port = self.txtDatabasePort.integerValue
        profile.database = self.txtDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.schema = self.txtDatabaseSchema.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.user = self.txtDatabaseUsername.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.password =  self.txtDatabasePassword.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.ssl = self.chkDatabaseUseSSL.state == .on
        profile.nopsw = self.chkDatabaseNoPsw.state == .on
        profile.socketTimeoutInSeconds = self.lstDatabaseTimeout.integerValue
        return profile
    }
    
    func databaseProfileToForm(profile:DatabaseProfile) {
        self.txtDatabaseHost.stringValue = profile.host
        self.txtDatabasePort.integerValue = profile.port
        self.txtDatabaseName.stringValue = profile.database
        self.txtDatabaseSchema.stringValue = profile.schema
        self.txtDatabaseUsername.stringValue = profile.user
        self.txtDatabasePassword.stringValue = profile.password
        self.chkDatabaseUseSSL.state = profile.ssl ? .on : .off
        self.chkDatabaseNoPsw.state = profile.nopsw ? .on : .off
        
        self.chkDatabasePostgresql.state = .off
        self.chkDatabaseMysql.state = .off
        
        switch(profile.engine.lowercased()) {
        case "postgresql":
            self.chkDatabasePostgresql.state = .on
            break
        case "mysql":
            self.chkDatabaseMysql.state = .on
        default:
            break
        }
        
        self.lstDatabaseTimeout.integerValue = profile.socketTimeoutInSeconds
    }
    
    @IBAction func onNewDatabaseProfileClicked(_ sender: NSButton) {
        self.lblDatabaseMessage.stringValue = ""
        let profile = DatabaseProfile()
        profile.host = "127.0.0.1"
        profile.database = "ImageDocker"
        profile.engine = "PostgreSQL"
        profile.port = 5432
        profile.schema = "public"
        profile.user = "postgres"
        profile.nopsw = true
        profile.ssl = false
        profile.selected = false
        profile.socketTimeoutInSeconds = 10
        self.databaseProfileToForm(profile: profile)
    }
    
    @IBAction func onSaveDatabaseProfileClicked(_ sender: NSButton) {
        self.lblDatabaseMessage.stringValue = ""
        if self.txtDatabaseHost.stringValue == "" || self.txtDatabaseName.stringValue == "" {
            return
        }
        let profile = self.databaseProfileFromForm()
        self.updateDatabaseProfile(profile: profile)
    }
    
    @IBAction func onClearDatabaseProfileClicked(_ sender: NSButton) {
        self.lblDatabaseMessage.stringValue = ""
        let profile = DatabaseProfile()
        profile.host = "127.0.0.1"
        profile.database = "ImageDocker"
        profile.engine = "PostgreSQL"
        profile.port = 5432
        profile.schema = "public"
        profile.user = "postgres"
        profile.nopsw = true
        profile.ssl = false
        profile.selected = false
        profile.socketTimeoutInSeconds = 10
        self.databaseProfileToForm(profile: profile)
    }
    
    /// Used to add a particular view controller as an item to our stack view.
    func addDatabaseProfileFlowListItem(databaseProfile:DatabaseProfile) {
        
        let storyboard = NSStoryboard(name: "DatabaseProfileFlowListItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "DatabaseProfileFlowListItem") as! DatabaseProfileFlowListItemController
        
            
        self.databaseProfilesStackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
        viewController.initView(databaseProfile: databaseProfile)
        
        self.databaseProfileFlowListItems[databaseProfile.id()] = viewController
        
    }
    
    func removeDatabaseProfileFlowListItem(databaseProfile:DatabaseProfile) {
        if let vc = self.databaseProfileFlowListItems[databaseProfile.id()] {
            NSLayoutConstraint.deactivate(vc.view.constraints)
            self.databaseProfilesStackView.removeView(vc.view)
        }
        self.databaseProfileFlowListItems.removeValue(forKey: databaseProfile.id())
    }
    
    
    func removeAllDatabaseProfileFlowListItems() {
        for vc in self.databaseProfileFlowListItems.values {
            NSLayoutConstraint.deactivate(vc.view.constraints)
            self.databaseProfilesStackView.removeView(vc.view)
        }
        self.databaseProfileFlowListItems.removeAll()
    }
    
    @IBAction func onDatabasePostgresqlClicked(_ sender: NSButton) {
        self.chkDatabasePostgresql.state = .off
        self.chkDatabaseMysql.state = .off
        
        self.chkDatabasePostgresql.state = .on
    }
    
    @IBAction func onDatabaseMysqlClicked(_ sender: NSButton) {
        self.chkDatabasePostgresql.state = .off
        self.chkDatabaseMysql.state = .off
        
        self.chkDatabaseMysql.state = .on
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
    
    @IBAction func onCheckBackupToDatabaseName(_ sender: NSButton) {
        self.lblDatabaseMessage.stringValue = ""
        guard let cmd = DatabaseBackupController.getPostgresCommandPath() else {
            let msg = "Unable to locate psql command in macOS, check db exist aborted."
            self.lblDatabaseMessage.stringValue = msg
            self.logger.log(.error, msg)
            return
        }
        let databaseProfile = self.databaseProfileFromForm()
        
        guard databaseProfile.database != "" && databaseProfile.host != "" else {
            self.btnCreateDatabase.isHidden = true
            return
        }
        DispatchQueue.global().async {
            let databases = PostgresConnection.default.getExistDatabases(commandPath: cmd, host: databaseProfile.host, port: databaseProfile.port)
            var exists = false
            for database in databases {
                if database == databaseProfile.database {
                    exists = true
                    break
                }
            }
            if exists {
                let remotedb = PostgresConnection.database(databaseProfile: databaseProfile)
                var tables:[TableInfo] = []
                do {
                    tables = try remotedb.queryTableInfos()
                }catch{
                    self.logger.log(.error, error)
                    self.lblDatabaseMessage.stringValue = "\(error)"
                }
                if tables.count == 0 {
                    DispatchQueue.main.async {
                        self.lblDatabaseMessage.stringValue = Words.preference_tab_backup_empty_database.word()
                        self.btnCreateDatabase.isHidden = true
                    }
                }else{
                    DispatchQueue.main.async {
                        self.lblDatabaseMessage.stringValue = Words.preference_tab_backup_non_empty_database.word()
                        self.btnCreateDatabase.isHidden = true
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.lblDatabaseMessage.stringValue = Words.preference_tab_backup_not_exist_database.word()
                    self.btnCreateDatabase.isHidden = false
                }
            }
        }
    }
    
    
    @IBAction func onCreateDatabaseClicked(_ sender: NSButton) {
        self.lblDatabaseMessage.stringValue = ""
        let profile = self.databaseProfileFromForm()
        
        guard profile.host != "" && profile.database != "" else {
            let msg = "Error: database host or name is empty"
            self.logger.log(.error, msg)
            self.lblDatabaseMessage.stringValue = msg
            return
        }
        guard let cmd = DatabaseBackupController.getPostgresCommandPath() else {
            let msg = "Unable to locate pg_dump command in macOS, createdb aborted."
            self.logger.log(.error, msg)
            self.lblDatabaseMessage.stringValue = msg
            return
        }
        if profile.engine.lowercased() != "postgresql" {
            let msg = "Selected database is not postgres. createdb aborted."
            self.logger.log(.error, msg)
            self.lblDatabaseMessage.stringValue = msg
            return
        }
        
        self.btnCreateDatabase.isEnabled = false
        
        DispatchQueue.global().async {
            
            let (status, _, pgError, err) = PostgresConnection.default.createDatabase(commandPath: cmd, database: profile.database, host: profile.host, port: profile.port, user: profile.user)
            
            if status == true {
                self.logger.log(.error, "created database \(profile.database) on \(profile.user)@\(profile.host):\(profile.port)")
                DispatchQueue.main.async {
                    self.btnCreateDatabase.isEnabled = true
                    self.lblDatabaseMessage.stringValue = "\(Words.preference_tab_backup_created_database.word()) \(profile.database)@\(profile.host):\(profile.port)"
                }
            }else{
                self.logger.log(.error, "Unable to create database \(profile.database) on \(profile.user)@\(profile.host):\(profile.port)")
                self.logger.log(.error, pgError)
                if let error = err {
                    self.logger.log(.error, error)
                }
                DispatchQueue.main.async {
                    self.btnCreateDatabase.isEnabled = true
                    self.lblDatabaseMessage.stringValue = "\(Words.preference_tab_backup_create_database_failed.word()) \(profile.database)@\(profile.host):\(profile.port)"
                }
            }
        }
    }
    
    // MARK: - ENGINE
    
    @IBOutlet weak var txtLocalDBBinPath: NSTextField!
    @IBOutlet weak var lblDataCloneToPgCmdline: NSTextField!
    @IBOutlet weak var lblDatabaseEngineMessage: NSTextField!
    @IBOutlet weak var chkPostgresInApp: NSButton!
    @IBOutlet weak var chkPostgresByBrew: NSButton!
    
    
    func initEngineSection() {
        
        self.lblDataCloneToPgCmdline.stringValue = Words.preference_tab_backup_pg_cmdline.word()
        self.chkPostgresByBrew.title = Words.preference_tab_backup_installed_by_homebrew.word()
        self.chkPostgresInApp.title = Words.preference_tab_backup_installed_by_postgresapp.word()
        
        self.lblDatabaseEngineMessage.stringValue = ""
        self.txtLocalDBBinPath.isEditable = false
        
        if let postgresCommandPath = ExecutionEnvironment.default.findPostgresCommand(from: self.toggleGroup_InstalledPostgres.keys) {
            self.toggleGroup_InstalledPostgres.selected = postgresCommandPath
            self.txtLocalDBBinPath.stringValue = postgresCommandPath
        }else{
            self.lblDataCloneMessage.stringValue = Words.preference_tab_backup_installed_error.word()
        }
    }
    
    
    
    // MARK: ENGINE - TOGGLE GROUP - Postgres Command Path
    
    var toggleGroup_InstalledPostgres:ToggleGroup!
    
    @IBAction func onCheckInstallPostgresByBrew(_ sender: NSButton) {
        let path = "/usr/local/bin"
        if let postgresCommandPath = ExecutionEnvironment.default.findPostgresCommand(from: [path]) {
            self.toggleGroup_InstalledPostgres.selected = postgresCommandPath
            self.txtLocalDBBinPath.stringValue = postgresCommandPath
        }else{
            self.lblDatabaseEngineMessage.stringValue = Words.preference_tab_backup_installed_by_homebrew_error.fill(arguments: path)
            sender.state = .off
        }
       
    }
    
    @IBAction func onCheckInstallPostgresInApp(_ sender: NSButton) {
        let path = "/Applications/Postgres.app/Contents/Versions/latest/bin"
        if let postgresCommandPath = ExecutionEnvironment.default.findPostgresCommand(from: [path]) {
            self.toggleGroup_InstalledPostgres.selected = postgresCommandPath
            self.txtLocalDBBinPath.stringValue = postgresCommandPath
        }else{
            self.lblDatabaseEngineMessage.stringValue = Words.preference_tab_backup_installed_by_postgresapp_error.fill(arguments: path)
            sender.state = .off
        }
    }
    
    
    
    
    
    // MARK: - BACKUP
    
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
    
    
    @IBOutlet weak var btnReloadDBArchives: NSButton!
    @IBOutlet weak var btnDeleteDBArchives: NSButton!
    
    @IBOutlet weak var lblBackupLocation: NSTextField!
    @IBOutlet weak var lblDataCloneFrom: NSTextField!
    @IBOutlet weak var lblDataCloneTo: NSTextField!
    @IBOutlet weak var lblDataCloneToDatabase: NSTextField!
    
    
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
            self.logger.log(.trace, "restore from \(folder)")
            
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
            var message = ""
            var databaseProfile = DatabaseProfile()
            databaseProfile.host = ""
            databaseProfile.port = 5432
            databaseProfile.user = ""
            databaseProfile.database = ""
            databaseProfile.schema = ""
            databaseProfile.password = ""
            databaseProfile.nopsw = false
            if       self.toggleGroup_CloneToDBLocation.selected == "localDBServer" {
                databaseProfile.host = Setting.database.localPostgres.server()
                databaseProfile.port = Setting.database.localPostgres.port()
                databaseProfile.user = Setting.database.localPostgres.username()
                databaseProfile.database = Setting.database.localPostgres.database()
                databaseProfile.password = Setting.database.localPostgres.password()
                databaseProfile.nopsw = Setting.database.localPostgres.noPassword()
                databaseProfile.schema = Setting.database.localPostgres.schema()
                message = Words.preference_tab_data_clone_from_sqlite_to_local_postgres.word()
            }else if self.toggleGroup_CloneToDBLocation.selected == "remoteDBServer" {
                databaseProfile.host = Setting.database.remotePostgres.server()
                databaseProfile.port = Setting.database.remotePostgres.port()
                databaseProfile.user = Setting.database.remotePostgres.username()
                databaseProfile.database = Setting.database.remotePostgres.database()
                databaseProfile.password = Setting.database.remotePostgres.password()
                databaseProfile.nopsw = Setting.database.remotePostgres.noPassword()
                databaseProfile.schema = Setting.database.remotePostgres.schema()
                message = Words.preference_tab_data_clone_from_sqlite_to_remote_postgres.word()
            }else{
                // more options?
                return
            }
            if self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) != "" && self.lblCheckDatabaseName.stringValue == "Created" {
                databaseProfile.database = self.txtRestoreToDatabaseName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            self.toggleDatabaseClonerButtons(state: false)
            self.lblDataCloneMessage.stringValue = message
            DispatchQueue.global().async {
                ImageDBCloner.default.fromLocalSQLiteToPostgreSQL(dropBeforeCreate: dropBeforeCreate,
                    postgresDB: { () -> PostgresDB in
                        return PostgresConnection.database(databaseProfile: databaseProfile)
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
                
                self.logger.log(.trace, "delete backup folder \(folder)")
                do{
                    try FileManager.default.removeItem(at: url)
                }catch{
                    self.logger.log(.trace, "Unable to delete backup archive: \(url.path)")
                    self.logger.log(.error, error)
                }
            }
            self.loadBackupArchives()
            self.calculateBackupUsedSpace(path: backupPath.path)
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
    
    
    func saveBackupSection(_ defaults:UserDefaults) {
        
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
        
        self.toggleGroup_InstalledPostgres = ToggleGroup([
            "/Applications/Postgres.app/Contents/Versions/latest/bin" : self.chkPostgresInApp,
            "/usr/local/bin"                                          : self.chkPostgresByBrew
        ], keysOrderred: [
            "/Applications/Postgres.app/Contents/Versions/latest/bin",
            "/usr/local/bin"
            ])
        
        self.toggleGroup_DBLocation = ToggleGroup([
//            "local"       : self.chkLocalLocation,
            "localServer" : self.chkLocalDBServer,
            "network"     : self.chkNetworkLocation
        ], keysOrderred: ["local", "localServer", "network"])
        
        self.toggleGroup_CloneFromDBLocation = ToggleGroup([
//            "localDBFile"   :self.chkFromLocalDBFile,
            "localDBServer" :self.chkFromLocalDBServer,
            "remoteDBServer":self.chkFromRemoteDBServer,
            "backupArchive" :self.chkFromBackupArchive
            ], keysOrderred: ["localDBFile", "localDBServer", "remoteDBServer", "backupArchive"])
        
        self.toggleGroup_CloneToDBLocation = ToggleGroup([
//            "localDBFile"   :self.chkToLocalDBFile,
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
        self.toggleGroup_CloneFromDBLocation.selected = "localDBServer"
        self.toggleGroup_CloneToDBLocation.disable(key: "localDBFile", onComplete: { nextKey in
            if nextKey == "localDBServer" || nextKey == "remoteDBServer" {
                self.loadBackupArchives(postgres: true)
            }
        })
        self.toggleGroup_CloneToDBLocation.selected = "remoteDBServer"
        self.toggleCreatePostgresDatabase(state: true)
        
        self.loadBackupArchives(postgres: true)
        
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
//                colView.textField?.textColor = NSColor.yellow
            } else {
//                colView.textField?.textColor = nil
            }
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        rowView.backgroundColor = Colors.DeepDarkGray
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
