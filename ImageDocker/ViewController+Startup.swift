//
//  ViewController+Startup.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa
import PostgresModelFactory

extension ViewController {
    
    
    
    internal func doStartWork() {
        self.logger.log(.info, "Starting app...")
        print("Starting app...")
        self.startingUp = true
        
        self.txtSearch.isEnabled = false
        
        let _ = Setting.database.predefinedLocalDBFilePath // must do in main thread
        
        
        var dbConnected = false
        var additionalMessage = ""
        
        DispatchQueue.global().async {
            self.splashController.progressWillEnd(at: 5)
            
            let exiftool = ExifTool.helper
            
            // current database info
            
            
            if let databaseProfile = Setting.database.selectedDatabaseProfile() {
                // create database backup
                self.splashController.message(Words.splash_creatingDatabaseBackup.word(), progress: 1)
                let dbBackupRealUrl = ExecutionEnvironment.default.getDatabaseBackupVolume()
                self.splashController.showSubMessage(message: Words.splash_backing_up_database.fill(arguments: "\(databaseProfile.engine) \(databaseProfile.host)/\(databaseProfile.database)", dbBackupRealUrl))
                if dbBackupRealUrl == "" {
                    self.splashController.message(Words.splash_creatingDatabaseBackup_failed_missing_volumes.fill(arguments: dbBackupRealUrl), progress: 1)
                    self.splashController.decideQuit = true
                    self.splashController.showQuit(countdown: 120, disableButton: false) {
                        self.doQuit(withoutBackupDB: true)
                    }
                    return
                }
                
                let _ = ExecutionEnvironment.default.createDatabaseBackup(profile: databaseProfile, suffix: "-on-launch")
                self.splashController.hideSubMessage()
                
                
                // connect to database
                let idleSeconds = 15
                let maxAttempt = 3
                var retry = 0
                
                self.splashController.showSubMessage(message: Words.splash_connecting_database.fill(arguments: "\(databaseProfile.engine) \(databaseProfile.host)/\(databaseProfile.database)"))
                
                while(!dbConnected && retry < maxAttempt) {
                    
                    if self.splashController.decideQuit {
                        break
                    }
                    let retryDisplay = retry > 0 ? ", retrying \(retry)/\(maxAttempt)" : ""
                    self.splashController.message("\(Words.splash_connectingDatabase.word()) \(additionalMessage)\(retryDisplay)", progress: 2)
                    if retry > 0 {
                        for i in 0..<idleSeconds {
                            if self.splashController.cancelWaiting {
                                self.splashController.cancelWaiting = false
                                break
                            }else{
                                self.splashController.showRetry(15 - i)
                                sleep(1)
                            }
                        }
                    }
                    if self.splashController.decideQuit {
                        break
                    }
                    
                    let db = Database(profile: databaseProfile)
                    do {
                        try db.connect()
                        let schemaVersion = Setting.database.checkSchemaVersion(profile: databaseProfile)
                        if schemaVersion.starts(with: "v") {
                            dbConnected = true
                            ImageDB.current().versionCheck()
                            self.splashController.hideRetry()
                        }else{
                            additionalMessage = Words.preference_tab_backup_no_schema.word()
                        }
                    }catch{
                        additionalMessage = "\(error)"
                    }
                    if !dbConnected {
                        retry += 1
                    }
                    
//                    let (connected, error) =  ImageDB.current().testDatabase()
//                    if !connected {
//                        
//                        retry += 1
//                        if let err = error {
//                            additionalMessage = "\(err)"
//                        }else{
//                            additionalMessage = Words.splash_failedWithUnknownReason.word()
//                        }
//                        
//                    }else{
//                        ImageDB.current().versionCheck()
//                        self.splashController.hideRetry()
//                    }
//                    dbConnected = connected
                }
            }
            
//            let (_dbLocation, _dbEngine, dbServer, dbName) = Setting.database.configuredDatabaseInfo()
//            self.logger.log(.trace, _dbLocation)
//            self.logger.log(.trace, _dbEngine)
//            self.logger.log(.trace, dbServer)
//            self.logger.log(.trace, dbName)
//            var dbEngine = ""
//            if(_dbLocation == "local") {
//                if dbEngine == "SQLite" {
//                    dbEngine = Words.preference_tab_backup_local_sqlite.word()
//                }else{
//                    dbEngine = Words.preference_tab_backup_local_postgresql.word()
//                }
//            }else{
//                dbEngine = Words.preference_tab_backup_remote_postgresql.word()
//            }
//            
//            if _dbEngine == "PostgreSQL" {
//                dbEngine = "\(dbEngine) \(dbServer)/\(dbName)"
//            }
            
            
            if self.splashController.decideQuit {
                print("user decide quit")
                self.splashController.showQuit(countdown: 5, disableButton: true) {
                    self.doQuit(withoutBackupDB: true)
                }
            }
            
            if !dbConnected {
                print("db not connected")
                self.splashController.showQuit(countdown: 5, disableButton: true) {
                    self.doQuit(withoutBackupDB: true)
                }
            }else{
                self.splashController.hideSubMessage()
                
                self.splashController.message(Words.splash_initializingUI.word(), progress: 3)
                DispatchQueue.main.async {
                    self.initView()
                    
                    if self.splashController.decideQuit {
                        
                        self.splashController.showQuit(countdown: 5, disableButton: true) {
                            self.doQuit(withoutBackupDB: true)
                        }
                    }
                }
            }
        }
    }
    
    internal func didStartWork() {
        self.view.subviews.removeLast()
        self.startingUp = false
        self.logger.log(.trace, "FINISHED STARTUP WORK")
        
        self.centralSplitViewDelegate = CentralSplitViewDelegate(view: self)
        self.centralHorizontalSplitView.delegate = self.centralSplitViewDelegate

        self.configureMainSearchBar()
        self.showMemories()
    }
    
    internal func doQuit(withoutBackupDB:Bool = false) {
        if(withoutBackupDB) {
            AppDelegate.current.terminateWithoutBackupDB = true
        }
        NSApplication.shared.terminate(self)
    }
    
    internal func prepareToolbarsOnStartup() {
        DispatchQueue.main.async {
            
            if self.startingUp {
                self.splashController.message(Words.splash_preparingUI.word(), progress: 5)
            }
        }
    }
}
