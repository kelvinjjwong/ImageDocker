//
//  ViewController+Startup.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    
    
    internal func doStartWork() {
        self.startingUp = true
        
        self.txtSearch.isEnabled = false
        
        let _ = Setting.database.sqlite.predefinedLocalDBFilePath // must do in main thread
        
        DispatchQueue.global().async {
            self.splashController.progressWillEnd(at: 5)
            
            IPHONE.bridge.unmountFuse()
            
            // current database info
            let (_dbLocation, _dbEngine, dbServer, dbName) = Setting.database.configuredDatabaseInfo()
            print(_dbLocation)
            print(_dbEngine)
            print(dbServer)
            print(dbName)
            var dbEngine = ""
            if(_dbLocation == "local") {
                if dbEngine == "SQLite" {
                    dbEngine = Words.preference_tab_backup_local_sqlite.word()
                }else{
                    dbEngine = Words.preference_tab_backup_local_postgresql.word()
                }
            }else{
                dbEngine = Words.preference_tab_backup_remote_postgresql.word()
            }
            
            if _dbEngine == "PostgreSQL" {
                dbEngine = "\(dbEngine) \(dbServer)/\(dbName)"
            }
            // create database backup
            self.splashController.message(Words.splash_creatingDatabaseBackup.word(), progress: 1)
            let dbBackupRealUrl = ExecutionEnvironment.default.getDatabaseBackupVolume()
            self.splashController.showSubMessage(message: Words.splash_backing_up_database.fill(arguments: dbEngine, dbBackupRealUrl))
            if dbBackupRealUrl == "" {
                self.splashController.message(Words.splash_creatingDatabaseBackup_failed_missing_volumes.fill(arguments: dbBackupRealUrl), progress: 1)
                self.splashController.decideQuit = true
                self.splashController.showQuit(countdown: 8, disableButton: true) {
                    self.doQuit(withoutBackupDB: true)
                }
                return
            }
            
            let _ = ExecutionEnvironment.default.createDatabaseBackup(suffix: "-on-launch")
            self.splashController.hideSubMessage()
            
            
            // connect to database
            
            let idleSeconds = 15
            let maxAttempt = 3
            var retry = 0
            var dbConnected = false
            var additionalMessage = ""
            
            
            self.splashController.showSubMessage(message: Words.splash_connecting_database.fill(arguments: dbEngine))
            
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
                let (connected, error) = ImageDB.current().testDatabase()
                if !connected {
                    
                    retry += 1
                    if let err = error {
                        additionalMessage = "\(err)"
                    }else{
                        additionalMessage = Words.splash_failedWithUnknownReason.word()
                    }
                    
                }else{
                    ImageDB.current().versionCheck()
                    self.splashController.hideRetry()
                }
                dbConnected = connected
            }
            
            if self.splashController.decideQuit {
                self.splashController.showQuit(countdown: 5, disableButton: true) {
                    self.doQuit(withoutBackupDB: true)
                }
            }
            
            if !dbConnected {
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
        self.logger.log("FINISHED STARTUP WORK")

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
            self.showToolbarOfCollectionView()
            
            
            if self.startingUp {
                self.splashController.message(Words.splash_preparingUI.word(), progress: 5)
            }
        }
    }
}
