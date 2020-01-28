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
        
        DispatchQueue.global().async {
            self.splashController.progressWillEnd(at: 5)
            self.splashController.message("Creating database backup ...", progress: 1)
            ExecutionEnvironment.default.createDataBackup(suffix: "-on-launch")
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
                self.splashController.message("Connecting database ... \(additionalMessage)\(retryDisplay)", progress: 2)
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
                let (connected, error) = ModelStore.default.testDatabase()
                if !connected {
                    
                    retry += 1
                    if let err = error {
                        additionalMessage = "\(err)"
                    }else{
                        additionalMessage = "failed with unknown reason"
                    }
                    
                }else{
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
                self.splashController.message("Initializing user interface ...", progress: 3)
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
        
        self.showMemories()
    }
    
    internal func doQuit() {
        NSApplication.shared.terminate(self)
    }
    
    internal func loadTreeOnStartup() {
        DispatchQueue.main.async {
            
            print("\(Date()) Loading view - configure tree - reloading source list view")
            
//            self.sortLibraryTreeRepositories()
//            self.sourceList.reloadData()
            self.treeIndicator.isEnabled = false
            self.treeIndicator.isHidden = true
            
//            self.showToolbarOfTree()
            self.showToolbarOfCollectionView()
            
            print("\(Date()) Loading view - configure tree - reloading source list view: DONE")
            
            if self.startingUp {
                self.splashController.message("Preparing UI ...", progress: 5)
            }
        }
    }
}
