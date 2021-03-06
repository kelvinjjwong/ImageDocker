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
        
        let _ = PreferencesController.predefinedLocalDBFilePath // must do in main thread
        
        DispatchQueue.global().async {
            self.splashController.progressWillEnd(at: 5)
            self.splashController.message(Words.splash_creatingDatabaseBackup.word(), progress: 1)
            let _ = ExecutionEnvironment.default.createDatabaseBackup(suffix: "-on-launch")

            IPHONE.bridge.unmountFuse()
            
            
            let idleSeconds = 15
            let maxAttempt = 3
            var retry = 0
            var dbConnected = false
            var additionalMessage = ""
            
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
                self.doQuit()
            }
            
            if !dbConnected {
                self.splashController.showQuit()
            }else{
                self.splashController.message(Words.splash_initializingUI.word(), progress: 3)
                DispatchQueue.main.async {
                    self.initView()
                }
            }
        }
    }
    
    internal func didStartWork() {
        self.view.subviews.removeLast()
        self.startingUp = false
        print("FINISHED STARTUP WORK")

        self.configureMainSearchBar()
        self.showMemories()
    }
    
    internal func doQuit() {
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
