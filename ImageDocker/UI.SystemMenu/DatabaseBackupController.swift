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
    
    
    
    
    func initDatabaseSection() {
        
        self.databaseProfilesStackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        self.lblDatabaseMessage.stringValue = ""
        self.chkDatabaseMysql.state = .off
        self.chkDatabasePostgresql.state = .on
        self.chkDatabaseUseSSL.state = .off
        self.chkDatabaseNoPsw.state = .on
        self.lstDatabaseTimeout.integerValue = 10
        
        self.loadDatabaseProfiles()
        
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
    @IBOutlet weak var btnCheckDatabaseName: NSButton!
    
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
            if !vc.lblContent3.stringValue.starts(with: "v") {
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
            vc.updateSchemaStatus("")
        }
        if profile.engine.lowercased() == "postgresql" {
            DispatchQueue.global().async {
                let rtn = self.checkPostgreSQLVersion(profile: profile)
                print(">>> rtn >>> \(rtn) <<<")
                if rtn.starts(with: "PostgreSQL") {
                    let parts = rtn.components(separatedBy: " ")
                    let version = parts[1]
                    
                    let schemaVersion = Setting.database.checkSchemaVersion(profile: profile)
                    
                    DispatchQueue.main.async {
                        if let vc = self.databaseProfileFlowListItems[profile.id()] {
                            vc.updateStatus2(version)
                            vc.updateStatus1("Connectable")
                            
                            if schemaVersion.starts(with: "v") {
                                vc.updateSchemaStatus(schemaVersion)
                            }else if schemaVersion.starts(with: "error_") {
                                if let rtnMessage = schemaVersion.components(separatedBy: "\n").map({ line in
                                    return line.trimmingCharacters(in: .whitespacesAndNewlines)
                                }).first(where: { line in
                                    return line.starts(with: "message: ")
                                })?.replacingFirstOccurrence(of: "message: ", with: "") {
                                    if rtnMessage == "database \"\(profile.database)\" does not exist" {
                                        vc.updateSchemaStatus(Words.preference_tab_backup_not_exist_database.word())
                                    }else if rtnMessage == "relation \"version_migrations\" does not exist" {
                                        vc.updateSchemaStatus(Words.preference_tab_backup_empty_database.word())
                                    }else{
                                        vc.updateSchemaStatus(rtnMessage)
                                    }
                                }else{
                                    vc.updateSchemaStatus(schemaVersion)
                                }
                            }else{
                                vc.updateSchemaStatus(Words.preference_tab_backup_empty_database.word())
                            }
                        }
                    }
                }else if rtn.contains(find: "socketError") {
                    DispatchQueue.main.async {
                        if let vc = self.databaseProfileFlowListItems[profile.id()] {
                            vc.updateStatus2("")
                            vc.updateStatus1("Unreachable")
                        }
                    }
                }else if rtn.contains(find: "sqlError") {
                    if let rtnMessage = rtn.components(separatedBy: "\n").map({ line in
                        return line.trimmingCharacters(in: .whitespacesAndNewlines)
                    }).first(where: { line in
                        return line.starts(with: "message: ")
                    })?.replacingFirstOccurrence(of: "message: ", with: "") {
                        if rtnMessage == "database \"\(profile.database)\" does not exist" {
                            DispatchQueue.main.async {
                                if let vc = self.databaseProfileFlowListItems[profile.id()] {
                                    vc.updateSchemaStatus(Words.preference_tab_backup_not_exist_database.word())
                                }
                            }
                        }else if rtnMessage == "relation \"version_migrations\" does not exist" {
                            DispatchQueue.main.async {
                                if let vc = self.databaseProfileFlowListItems[profile.id()] {
                                    vc.updateSchemaStatus(Words.preference_tab_backup_empty_database.word())
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                if let vc = self.databaseProfileFlowListItems[profile.id()] {
                                    vc.updateSchemaStatus(rtnMessage)
                                }
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                            if let vc = self.databaseProfileFlowListItems[profile.id()] {
                                vc.updateSchemaStatus("SQL Error: \(rtn)")
                            }
                        }
                    }
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
        let profile1 = DatabaseProfile()
        profile1.engine = profile.engine
        profile1.host = profile.host
        profile1.port = profile.port
        profile1.database = "postgres"
        profile1.schema = "public"
        profile1.user = "postgres"
        profile1.nopsw = true
        profile1.ssl = profile.ssl
        profile1.socketTimeoutInSeconds = profile.socketTimeoutInSeconds
        
        let db1 = Database(profile: profile1)
        do {
            try db1.connect()
            return try db1.version()
        }catch{
            return "\(error)"
        }
    }
    
    func checkIfDatabaseExist(profile:DatabaseProfile) -> String {
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
        self.txtDatabasePort.stringValue = "\(profile.port)"
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
        
        self.btnCheckDatabaseName.isEnabled = false
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
                    
                    if tables.count == 0 {
                        DispatchQueue.main.async {
                            self.lblDatabaseMessage.stringValue = Words.preference_tab_backup_empty_database.word()
                            self.btnCreateDatabase.isHidden = true
                            self.btnCheckDatabaseName.isEnabled = true
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.lblDatabaseMessage.stringValue = Words.preference_tab_backup_non_empty_database.word()
                            self.btnCreateDatabase.isHidden = true
                            self.btnCheckDatabaseName.isEnabled = true
                        }
                    }
                }catch{
                    self.logger.log(.error, error)
                    let rtn = "\(error)"
                    if rtn.contains(find: "sqlError") {
                        if let rtnMessage = rtn.components(separatedBy: "\n").map({ line in
                            return line.trimmingCharacters(in: .whitespacesAndNewlines)
                        }).first(where: { line in
                            return line.starts(with: "message: ")
                        })?.replacingFirstOccurrence(of: "message: ", with: "") {
                            if rtnMessage == "database \"\(databaseProfile.database)\" does not exist" {
                                DispatchQueue.main.async {
                                    self.lblDatabaseMessage.stringValue = Words.preference_tab_backup_not_exist_database.word()
                                    self.btnCheckDatabaseName.isEnabled = true
                                }
                            }else if rtnMessage == "relation \"version_migrations\" does not exist" {
                                DispatchQueue.main.async {
                                    self.lblDatabaseMessage.stringValue = Words.preference_tab_backup_empty_database.word()
                                    self.btnCheckDatabaseName.isEnabled = true
                                }
                            }else{
                                DispatchQueue.main.async {
                                    self.lblDatabaseMessage.stringValue = rtnMessage
                                    self.btnCheckDatabaseName.isEnabled = true
                                }
                            }
                        }else{
                            DispatchQueue.main.async {
                                self.lblDatabaseMessage.stringValue = "\(error)"
                                self.btnCheckDatabaseName.isEnabled = true
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.lblDatabaseMessage.stringValue = "\(error)"
                            self.btnCheckDatabaseName.isEnabled = true
                        }
                    }
                    
                }
            }else{
                DispatchQueue.main.async {
                    self.lblDatabaseMessage.stringValue = Words.preference_tab_backup_not_exist_database.word()
                    self.btnCreateDatabase.isHidden = false
                    self.btnCheckDatabaseName.isEnabled = true
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
        
        self.toggleGroup_InstalledPostgres = ToggleGroup([
            "/Applications/Postgres.app/Contents/Versions/latest/bin" : self.chkPostgresInApp,
            "/usr/local/bin"                                          : self.chkPostgresByBrew
        ], keysOrderred: [
            "/Applications/Postgres.app/Contents/Versions/latest/bin",
            "/usr/local/bin"
            ])
        
        if let postgresCommandPath = ExecutionEnvironment.default.findPostgresCommand(from: self.toggleGroup_InstalledPostgres.keys) {
            self.toggleGroup_InstalledPostgres.selected = postgresCommandPath
            self.txtLocalDBBinPath.stringValue = postgresCommandPath
        }else{
            self.lblBackupMessage.stringValue = Words.preference_tab_backup_installed_error.word()
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
    @IBOutlet weak var boxBackupDestination: NSBox!
    
    @IBOutlet weak var lblBackupMessage: NSTextField!
    @IBOutlet weak var imgBackupStatus: NSImageView!
    
    
    @IBOutlet weak var lblDatabaseBackupPath: NSTextField!
    @IBOutlet weak var lblDBBackupUsedSpace: NSTextField!
    @IBOutlet weak var btnCloneLocalToRemote: NSButton!
    @IBOutlet weak var btnCalculateBackupDiskSpace: NSButton!
    @IBOutlet weak var btnGotoDBBackupPath: NSButton!
    
    
    @IBOutlet weak var chkDeleteAllBeforeClone: NSButton!
    
    @IBOutlet weak var scrDatabaseArchives: NSScrollView!
    @IBOutlet weak var tblDatabaseArchives: NSTableView!
    
    
    @IBOutlet weak var btnReloadDBArchives: NSButton!
    @IBOutlet weak var btnDeleteDBArchives: NSButton!
    
    @IBOutlet weak var lblBackupLocation: NSTextField!
    @IBOutlet weak var lblDataCloneFrom: NSTextField!
    @IBOutlet weak var lblDataCloneTo: NSTextField!
    
    @IBOutlet weak var imgBackupSource: NSImageView!
    @IBOutlet weak var lblBackupSourceStatus1: NSTextField!
    @IBOutlet weak var lblBackupSourceStatus2: NSTextField!
    @IBOutlet weak var lblBackupSourceContent1: NSTextField!
    @IBOutlet weak var lblBackupSourceContent2: NSTextField!
    @IBOutlet weak var lblBackupSourceContent3: NSTextField!
    
    @IBOutlet weak var imgBackupDestination: NSImageView!
    @IBOutlet weak var lblBackupDestinationStatus1: NSTextField!
    @IBOutlet weak var lblBackupDestinationStatus2: NSTextField!
    @IBOutlet weak var lblBackupDestinationContent1: NSTextField!
    @IBOutlet weak var lblBackupDestinationContent2: NSTextField!
    @IBOutlet weak var lblBackupDestinationContent3: NSTextField!
    
    @IBOutlet weak var chkSourceOrTarget: NSSegmentedControl!
    @IBOutlet weak var btnNewBackupArchive: NSButton!
    
    @IBOutlet weak var bkDatabaseProfilesStackView: NSStackView!
    var bkDatabaseProfileFlowListItems:[String:DatabaseProfileFlowListItemController] = [:]
    var bkDatabaseProfiles:[String:DatabaseProfile] = [:]
    
    
    func saveBackupSection(_ defaults:UserDefaults) {
        
    }
    
    
    func initBackupSection() {
        self.boxBackup.title = Words.preference_tab_backup_box_backup.word()
        self.boxDataClone.title = Words.preference_tab_backup_box_data_clone.word()
        self.lblBackupLocation.stringValue = Words.preference_tab_backup_box_backup_location.word()
        self.btnCalculateBackupDiskSpace.title = Words.preference_tab_backup_calc_disk_space.word()
        self.btnGotoDBBackupPath.title = Words.preference_tab_database_goto.word()
        self.lblDataCloneFrom.stringValue = Words.preference_tab_backup_from.word()
        self.lblDataCloneTo.stringValue = Words.preference_tab_backup_to.word()
        self.chkDeleteAllBeforeClone.title = Words.preference_tab_backup_delete_original_data.word()
        self.btnCloneLocalToRemote.title = Words.preference_tab_backup_clone_now.word()
        self.btnDeleteDBArchives.title = Words.preference_tab_backup_delete_backup.word()
        self.btnReloadDBArchives.title = Words.preference_tab_backup_reload_backup.word()
        
        self.tblDatabaseArchives.backgroundColor = NSColor.black
        self.tblDatabaseArchives.delegate = self
        self.tblDatabaseArchives.dataSource = self
        self.tblDatabaseArchives.allowsMultipleSelection = true
        
        
        self.lblDatabaseBackupPath.stringValue = URL(fileURLWithPath: Setting.database.databasePath()).appendingPathComponent("DataBackup").path
        
        self.chkDeleteAllBeforeClone.state = .on
        self.chkDeleteAllBeforeClone.isEnabled = false
        
        self.backupSourceDatabaseProfile = nil
        self.backupDestinationDatabaseProfile = nil
        
        self.changeBackupNowButtonState()
        self.loadBackupArchives(postgres: true)
        self.loadBackupDatabaseProfiles()
        self.calculateBackupUsedSpace(path: URL(fileURLWithPath: Setting.database.databasePath()).appendingPathComponent("DataBackup").path)
    }
    
    @IBAction func onFindDatabaseBackupClicked(_ sender: NSButton) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: self.lblDatabaseBackupPath.stringValue)])
    }
    
    func changeBackupNowButtonState() {
        self.btnCloneLocalToRemote.isEnabled = false
        self.btnCloneLocalToRemote.title = Words.preference_tab_backup_clone_now.word()
        if let source = self.backupSourceDatabaseProfile, let target = self.backupDestinationDatabaseProfile {
            if self.lblBackupSourceContent3.textColor == Colors.Red || self.lblBackupDestinationContent3.stringValue == Words.preference_tab_backup_not_exist_database.word() {
                self.btnCloneLocalToRemote.isEnabled = false
            }else{
                if source.engine.lowercased() == "archive" && target.engine.lowercased() == "archive" {
                    self.btnCloneLocalToRemote.isEnabled = false
                }else if self.lblBackupSourceStatus1.stringValue == "Connectable" && self.lblBackupDestinationStatus1.stringValue == "Connectable" {
                    if source.engine.lowercased() == "archive" {
                        self.btnCloneLocalToRemote.isEnabled = true
                    }else if self.lblBackupSourceContent3.stringValue.starts(with: "v"){
                        self.btnCloneLocalToRemote.isEnabled = true
                    }else{
                        self.btnCloneLocalToRemote.isEnabled = false
                    }
                }else if target.database == "ImageDocker.backup.gz" && self.lblBackupSourceStatus1.stringValue == "Connectable" && self.lblBackupSourceContent3.stringValue.starts(with: "v") {
                    self.btnCloneLocalToRemote.isEnabled = true
                }else{
                    self.btnCloneLocalToRemote.isEnabled = false
                }
                if source.engine.lowercased() == "archive" {
                    self.btnCloneLocalToRemote.title = Words.preference_tab_backup_restore_now.word()
                }
                if target.engine.lowercased() == "archive" {
                    self.btnCloneLocalToRemote.title = Words.preference_tab_database_backup_now.word()
                }
            }
        }else{
            self.btnCloneLocalToRemote.isEnabled = false
        }
    }
    
    func loadBackupDatabaseProfiles() {
        let json = Setting.database.databaseJson()
        print(json)
        let profiles = self.databaseProfilesFromJSON(json).sorted { p1, p2 in
            return p1.id() < p2.id()
        }
        var dict:[String:DatabaseProfile] = [:]
        for profile in profiles {
            dict[profile.id()] = profile
        }
        self.bkDatabaseProfiles = dict
        
        for profile in profiles {
            profile.selected = false
            self.updateBackupDatabaseProfile(profile: profile)
        }
        
        if self.bkDatabaseProfileFlowListItems.count == 0 {
            self.addEmptyBackupDatabaseProfile()
        }
    }
    
    func addEmptyBackupDatabaseProfile() {
        let profile = DatabaseProfile()
        profile.host = "127.0.0.1"
        profile.database = "ImageDocker"
        profile.engine = "PostgreSQL"
        profile.port = 5432
        profile.schema = "public"
        profile.user = "postgres"
        profile.nopsw = true
        profile.ssl = false
        profile.socketTimeoutInSeconds = 10
        profile.selected = false
        self.updateBackupDatabaseProfile(profile: profile)
    }
    
    func updateBackupDatabaseProfile(profile:DatabaseProfile) {
        if let viewController = self.bkDatabaseProfileFlowListItems[profile.id()] {
            viewController.updateFields(databaseProfile: profile)
            self.bkDatabaseProfiles[profile.id()] = profile
        }else{
            self.addBackupDatabaseProfile(profile: profile)
        }
    }
    
    func addBackupDatabaseProfile(profile:DatabaseProfile) {
        if self.bkDatabaseProfileFlowListItems[profile.id()] != nil {
            return
        }
        let storyboard = NSStoryboard(name: "DatabaseProfileFlowListItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "DatabaseProfileFlowListItem") as! DatabaseProfileFlowListItemController
        
        self.bkDatabaseProfiles[profile.id()] = profile
        viewController.initView(databaseProfile: profile, editable: false, deletable: false,
        onSelect: {
            if let profile = self.bkDatabaseProfiles[profile.id()] {
                self.selectBackupDatabaseProfile(profile: profile)
            }
        })

        self.bkDatabaseProfilesStackView.addArrangedSubview(viewController.view)
        self.bkDatabaseProfileFlowListItems[profile.id()] = viewController
        //addChildViewController(viewController)
    }
    
    var backupSourceDatabaseProfile:DatabaseProfile?
    var backupDestinationDatabaseProfile:DatabaseProfile?
    
    func selectBackupDatabaseProfile(profile:DatabaseProfile) {
        for vc in self.bkDatabaseProfileFlowListItems.values {
            vc.unselect()
        }
        for profile in self.bkDatabaseProfiles.values {
            profile.selected = false
        }
        if let vc = self.bkDatabaseProfileFlowListItems[profile.id()] {
            vc.select()
        }
        if let profile = self.bkDatabaseProfiles[profile.id()] {
            profile.selected = true
//            self.changeSelectedProfileId(profile: profile)
        }
        
        if self.chkSourceOrTarget.selectedSegment == 0 {
            self.backupSourceDatabaseProfile = profile
            self.imgBackupSource.image = Icons.databaseIcon(engine: profile.engine)
            self.lblBackupSourceContent1.stringValue = "\(profile.host):\(profile.port) \(profile.ssl ? "(ssl)" : "")"
            self.lblBackupSourceContent2.stringValue = "\(profile.user):\(profile.database)"
            self.lblBackupSourceContent3.stringValue = ""
            if self.backupSourceDatabaseProfile?.id() ?? "" == self.backupDestinationDatabaseProfile?.id() ?? "" {
                self.imgBackupDestination.image = nil
                self.lblBackupDestinationStatus1.stringValue = ""
                self.lblBackupDestinationStatus2.stringValue = ""
                self.lblBackupDestinationContent1.stringValue = ""
                self.lblBackupDestinationContent2.stringValue = ""
                self.lblBackupDestinationContent3.stringValue = ""
                self.backupDestinationDatabaseProfile = nil
            }
            self.tblDatabaseArchives.deselectRow(self.lastSelectedBackupArchiveRow ?? -1)
            self.checkBackupDatabaseVersion(profile: profile, isSource: true)
        }else{
            self.backupDestinationDatabaseProfile = profile
            self.imgBackupDestination.image = Icons.databaseIcon(engine: profile.engine)
            self.lblBackupDestinationContent1.stringValue = "\(profile.host):\(profile.port) \(profile.ssl ? "(ssl)" : "")"
            self.lblBackupDestinationContent2.stringValue = "\(profile.user):\(profile.database)"
            self.lblBackupDestinationContent3.stringValue = ""
            if self.backupSourceDatabaseProfile?.id() ?? "" == self.backupDestinationDatabaseProfile?.id() ?? "" {
                self.imgBackupSource.image = nil
                self.lblBackupSourceStatus1.stringValue = ""
                self.lblBackupSourceStatus2.stringValue = ""
                self.lblBackupSourceContent1.stringValue = ""
                self.lblBackupSourceContent2.stringValue = ""
                self.lblBackupSourceContent3.stringValue = ""
                self.backupSourceDatabaseProfile = nil
            }
            self.checkBackupDatabaseVersion(profile: profile, isSource: false)
        }
        self.changeBackupNowButtonState()
    }
    
    @IBAction func onNewBackupArchiveClicked(_ sender: NSButton) {
        let profile = DatabaseProfile()
        profile.engine = "archive"
        profile.host = URL(fileURLWithPath: Setting.database.databasePath()).appendingPathComponent("DataBackup").path
        profile.database = "ImageDocker.backup.gz"
        profile.schema = "-on-runtime"
        
        self.backupDestinationDatabaseProfile = profile
        self.imgBackupDestination.image = Icons.databaseIcon(engine: profile.engine)
        self.lblBackupDestinationContent1.stringValue = Words.preference_tab_backup_from.word()
        self.lblBackupDestinationContent2.stringValue = profile.database
        self.lblBackupDestinationContent3.stringValue = ""
        self.lblBackupDestinationStatus1.stringValue = ""
        self.lblBackupDestinationStatus2.stringValue = ""
        
        self.changeBackupNowButtonState()
    }
    
    func selectBackupArchiveAsSource(archive:(String, String, String, String)) {
        let profile = DatabaseProfile()
        profile.engine = "archive"
        profile.host = URL(fileURLWithPath: Setting.database.databasePath()).appendingPathComponent("DataBackup").path
        profile.database = archive.0
        profile.schema = "DataBackup-\(archive.0)-\(archive.1)-on-\(archive.2)"
        
        self.backupSourceDatabaseProfile = profile
        self.imgBackupSource.image = Icons.databaseIcon(engine: profile.engine)
        self.lblBackupSourceContent1.stringValue = Words.preference_tab_backup_from.word()
        self.lblBackupSourceContent2.stringValue = profile.database
        self.lblBackupSourceContent3.stringValue = ""
        
        self.checkBackupDatabaseVersion(profile: profile, isSource: true)
        
        self.changeBackupNowButtonState()
    }
    
    func checkBackupDatabaseVersion(profile:DatabaseProfile, isSource:Bool) {
        if isSource {
            self.lblBackupSourceStatus2.stringValue = ""
            self.lblBackupSourceStatus1.stringValue = "Connecting..."
            self.lblBackupSourceStatus1.textColor = Colors.White
        }else{
            self.lblBackupDestinationStatus2.stringValue = ""
            self.lblBackupDestinationStatus1.stringValue = "Connecting..."
            self.lblBackupDestinationStatus1.textColor = Colors.White
        }
        if profile.engine.lowercased() == "postgresql" {
            DispatchQueue.global().async {
                let rtn = self.checkPostgreSQLVersion(profile: profile)
                print(">>> rtn >>> \(rtn) <<<")
                if rtn.starts(with: "PostgreSQL") {
                    let parts = rtn.components(separatedBy: " ")
                    let version = parts[1]
                    
                    DispatchQueue.main.async {
                        if isSource {
                            self.lblBackupSourceStatus2.stringValue = version
                            self.lblBackupSourceStatus1.stringValue = "Connectable"
                            self.lblBackupSourceStatus1.textColor = Colors.Green
                        }else{
                            self.lblBackupDestinationStatus2.stringValue = version
                            self.lblBackupDestinationStatus1.stringValue = "Connectable"
                            self.lblBackupDestinationStatus1.textColor = Colors.Green
                        }
                        self.changeBackupNowButtonState()
                    }
                    let schemaVersion = Setting.database.checkSchemaVersion(profile: profile)
                    
                    if schemaVersion.starts(with: "v") {
                        DispatchQueue.main.async {
                            if isSource {
                                self.lblBackupSourceContent3.stringValue = schemaVersion
                                self.lblBackupSourceContent3.textColor = Colors.Green
                            }else{
                                self.lblBackupDestinationContent3.stringValue = schemaVersion
                                self.lblBackupDestinationContent3.textColor = Colors.Green
                            }
                            self.changeBackupNowButtonState()
                        }
                    }else if schemaVersion.starts(with: "error_"){
                        if let rtnMessage = schemaVersion.components(separatedBy: "\n").map({ line in
                            return line.trimmingCharacters(in: .whitespacesAndNewlines)
                        }).first(where: { line in
                            return line.starts(with: "message: ")
                        })?.replacingFirstOccurrence(of: "message: ", with: "") {
                            if rtnMessage == "database \"\(profile.database)\" does not exist" {
                                DispatchQueue.main.async {
                                    if isSource {
                                        self.lblBackupSourceContent3.stringValue = Words.preference_tab_backup_not_exist_database.word()
                                        self.lblBackupSourceContent3.textColor = Colors.Red
                                    }else{
                                        self.lblBackupDestinationContent3.stringValue = Words.preference_tab_backup_not_exist_database.word()
                                        self.lblBackupDestinationContent3.textColor = Colors.Red
                                    }
                                    self.changeBackupNowButtonState()
                                }
                            }else if rtnMessage == "relation \"version_migrations\" does not exist" {
                                DispatchQueue.main.async {
                                    if isSource {
                                        self.lblBackupSourceContent3.stringValue = Words.preference_tab_backup_empty_database.word()
                                        self.lblBackupSourceContent3.textColor = Colors.Red
                                    }else{
                                        self.lblBackupDestinationContent3.stringValue = Words.preference_tab_backup_empty_database.word()
                                        self.lblBackupDestinationContent3.textColor = Colors.Red
                                    }
                                    self.changeBackupNowButtonState()
                                }
                            }else{
                                if isSource {
                                    self.lblBackupSourceContent3.stringValue = "数据库错误 \(rtnMessage)"
                                    self.lblBackupSourceContent3.textColor = Colors.Red
                                }else{
                                    self.lblBackupDestinationContent3.stringValue = "数据库错误 \(rtnMessage)"
                                    self.lblBackupDestinationContent3.textColor = Colors.Red
                                }
                                self.changeBackupNowButtonState()
                            }
                        }else{
                            DispatchQueue.main.async {
                                if isSource {
                                    self.lblBackupSourceContent3.stringValue = "数据库错误 \(schemaVersion)"
                                    self.lblBackupSourceContent3.textColor = Colors.Red
                                }else{
                                    self.lblBackupDestinationContent3.stringValue = "数据库错误 \(schemaVersion)"
                                    self.lblBackupDestinationContent3.textColor = Colors.Red
                                }
                                self.changeBackupNowButtonState()
                            }
                        }
                        
                    }else{
                        DispatchQueue.main.async {
                            if isSource {
                                self.lblBackupSourceContent3.stringValue = Words.preference_tab_backup_no_schema.word()
                                self.lblBackupSourceContent3.textColor = Colors.Red
                            }else{
                                self.lblBackupDestinationContent3.stringValue = Words.preference_tab_backup_no_schema.word()
                                self.lblBackupDestinationContent3.textColor = Colors.Red
                            }
                            self.changeBackupNowButtonState()
                        }
                    }
                    
                    
                }else if rtn.contains(find: "socketError") {
                    DispatchQueue.main.async {
                        if isSource {
                            self.lblBackupSourceStatus2.stringValue = ""
                            self.lblBackupSourceStatus1.stringValue = "Unreachable"
                            self.lblBackupSourceStatus1.textColor = Colors.Red
                        }else{
                            self.lblBackupDestinationStatus2.stringValue = ""
                            self.lblBackupDestinationStatus1.stringValue = "Unreachable"
                            self.lblBackupDestinationStatus1.textColor = Colors.Red
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        if isSource {
                            self.lblBackupSourceStatus2.stringValue = ""
                            self.lblBackupSourceStatus1.stringValue = "Unauthorized"
                            self.lblBackupSourceStatus1.textColor = Colors.Red
                        }else{
                            self.lblBackupDestinationStatus2.stringValue = ""
                            self.lblBackupDestinationStatus1.stringValue = "Unauthorized"
                            self.lblBackupDestinationStatus1.textColor = Colors.Red
                        }
                    }
                }
            }
            
        }else if profile.engine.lowercased() == "archive" {
            DispatchQueue.global().async {
                let path = URL(fileURLWithPath: Setting.database.databasePath()).appendingPathComponent("DataBackup").appendingPathComponent(profile.schema).appendingPathComponent("ImageDocker.backup.gz").path
                if path.isFileExists() {
                    DispatchQueue.main.async {
                        if isSource {
                            self.lblBackupSourceStatus2.stringValue = ""
                            self.lblBackupSourceStatus1.stringValue = "Connectable"
                            self.lblBackupSourceStatus1.textColor = Colors.Green
                        }else{
                            self.lblBackupDestinationStatus2.stringValue = ""
                            self.lblBackupDestinationStatus1.stringValue = "Connectable"
                            self.lblBackupDestinationStatus1.textColor = Colors.Green
                        }
                        self.changeBackupNowButtonState()
                    }
                }else{
                    DispatchQueue.main.async {
                        if isSource {
                            self.lblBackupSourceStatus2.stringValue = ""
                            self.lblBackupSourceStatus1.stringValue = "Unreachable"
                            self.lblBackupSourceStatus1.textColor = Colors.Red
                        }else{
                            self.lblBackupDestinationStatus2.stringValue = ""
                            self.lblBackupDestinationStatus1.stringValue = "Unreachable"
                            self.lblBackupDestinationStatus1.textColor = Colors.Red
                        }
                        self.changeBackupNowButtonState()
                    }
                }
            }
        }
    }
    
    private func toggleDatabaseClonerButtons(state: Bool) {
        self.btnCloneLocalToRemote.isEnabled = state
        self.tblDatabaseArchives.isEnabled = state
        self.btnDeleteDBArchives.isEnabled = state
        self.btnReloadDBArchives.isEnabled = state
    }
    
    func backupNow(profile:DatabaseProfile) {
        self.lblBackupMessage.stringValue = Words.preference_tab_creating_backup.word()
        DispatchQueue.global().async {
            let (backupFolder, status, error) = ExecutionEnvironment.default.createDatabaseBackup(profile: profile, suffix: "-on-runtime")
            DispatchQueue.main.async {
                if status == false {
                    self.lblBackupMessage.stringValue = Words.preference_tab_backup_failed.fill(arguments: "\(error.debugDescription)")
                }else{
                    self.lblBackupMessage.stringValue = Words.preference_tab_backup_created.fill(arguments: "\(backupFolder)")
                }
                self.toggleDatabaseClonerButtons(state: true)
                Icons.show_gif(name: "success", view: self.imgBackupStatus, loopCount: 1)
            }
        }
    }
    
    func restoreNow(source:DatabaseProfile, target:DatabaseProfile) {
        guard let cmd = DatabaseBackupController.getPostgresCommandPath() else {
            self.lblBackupMessage.stringValue = Words.preference_tab_data_clone_unable_to_locate_psql_command.word()
            Icons.show_gif(name: "failure", view: self.imgBackupStatus, loopCount: 1)
            return
        }
        DispatchQueue.global().async {
            let (_, _) = PostgresConnection.default.restoreDatabase(commandPath: cmd, database: target.database, host: target.host, port: target.port, user: target.user, backupFolder: source.schema)
            DispatchQueue.main.async {
                self.toggleDatabaseClonerButtons(state: true)
                Icons.show_gif(name: "success", view: self.imgBackupStatus, loopCount: 1)
                self.lblBackupMessage.stringValue = Words.preference_tab_backup_restore_archive_completed.fill(arguments: "\(source.database)", "\(target.database)")
            }
        }
    }
    
    func cloneNow(source:DatabaseProfile, target:DatabaseProfile) {
        guard let cmd = DatabaseBackupController.getPostgresCommandPath() else {
            self.lblBackupMessage.stringValue = Words.preference_tab_data_clone_unable_to_locate_psql_command.word()
            Icons.show_gif(name: "failure", view: self.imgBackupStatus, loopCount: 1)
            return
        }
        DispatchQueue.global().async {
            let (_, _) = PostgresConnection.default.cloneDatabase(commandPath: cmd, source: source, target: target)
            DispatchQueue.main.async {
                self.toggleDatabaseClonerButtons(state: true)
                Icons.show_gif(name: "success", view: self.imgBackupStatus, loopCount: 1)
                self.lblBackupMessage.stringValue = Words.preference_tab_data_clone_from_remote_postgres_completed.fill(arguments: "\(source.database)")
            }
        }
    }
    
    
    
    @IBAction func onCloneLocalToRemoteClicked(_ sender: NSButton) {
        if !self.btnCloneLocalToRemote.isEnabled {
            return
        }
        if let source = self.backupSourceDatabaseProfile, let target = self.backupDestinationDatabaseProfile {
            self.lblBackupMessage.stringValue = ""
            self.toggleDatabaseClonerButtons(state: false)
            Icons.show_gif(name: "loading_colorful", view: self.imgBackupStatus)
            if self.btnCloneLocalToRemote.title == Words.preference_tab_database_backup_now.word() {
                self.backupNow(profile: source)
            }else if self.btnCloneLocalToRemote.title == Words.preference_tab_backup_restore_now.word() {
                self.restoreNow(source: source, target: target)
            }else{
                self.cloneNow(source: source, target: target)
            }
        }
    }
    
    
    
    // MARK: BACKUP ARCHIVE USED SPACE
    
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
    
    // MARK: BACKUP ARCHIVE TABLE
    
    @IBAction func onReloadDBArchivesClicked(_ sender: NSButton) {
        self.loadBackupArchives(postgres: true)
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
        let backupPath = URL(fileURLWithPath: Setting.database.databasePath()).appendingPathComponent("DataBackup")
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
    
    
    
    var backupArchives:[(String, String, String, String)] = []
    
    var shouldLoadPostgresBackupArchives = true
    
    var lastSelectedBackupArchiveRow:Int? {
        didSet {
            if let row = lastSelectedBackupArchiveRow, row >= 0 {
                let archive = self.backupArchives[row]
                self.selectBackupArchiveAsSource(archive: archive)
            }
        }
    }
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
        lastSelectedBackupArchiveRow = row
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
