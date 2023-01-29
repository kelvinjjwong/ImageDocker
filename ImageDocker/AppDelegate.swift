//
//  AppDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/22.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var editMenu: NSMenu!
    @IBOutlet weak var windowMenu: NSMenu!
    
    var terminateWithoutBackupDB = false
    
    let logger = ConsoleLogger(category: "AppDelegate")
    
    func setupMainMenu() {
        self.mainMenu.item(at: 0)?.title = Words.mainmenu_about.word()
        self.mainMenu.item(at: 2)?.title = Words.mainmenu_preferences.word()
        self.mainMenu.item(at: 3)?.title = Words.mainmenu_database_and_backup.word()
        self.mainMenu.item(at: 4)?.title = Words.mainmenu_local_environment.word()
        self.mainMenu.item(at: 5)?.title = Words.mainmenu_external_api.word()
        self.mainMenu.item(at: 7)?.title = Words.mainmenu_quit.word()
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
//        DispatchQueue.global().async {
//            ExecutionEnvironment.default.createDataBackup(suffix:"-on-launch")
//            IPHONE.bridge.unmountFuse()
//        }
    }
    
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSUserNotificationCenter.default.delegate = self
        self.setupMainMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        IPHONE.bridge.unmountFuse()
        
        if ExecutionEnvironment.default.getDatabaseBackupVolume() == "" {
            self.terminateWithoutBackupDB = true
        }
        
        if !self.terminateWithoutBackupDB {
            let alert = NSAlert()
            DispatchQueue.global().async {
                let _ = ExecutionEnvironment.default.createDatabaseBackup(suffix:"-on-exit")
                
                DispatchQueue.main.async {
                    alert.buttons[0].title = "Quit"
                    alert.buttons[0].isEnabled = true
                    alert.window.close()
                    exit(0)
                }
            }
            
            
            alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
            alert.messageText = NSLocalizedString("Quiting application",
                                                  comment: "Backup database in progress ...")
            alert.buttons[0].title = "Backup database in progress ..."
            alert.buttons[0].isEnabled = false
            alert.runModal()
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    //MARK: app termination
    
    func applicationShouldTerminateAfterLastWindowClosed(_ theApplication: NSApplication) -> Bool {
        return true
    }
    
    static var current : AppDelegate {
        return NSApp.delegate as! AppDelegate
    }
    
    lazy var applicationDocumentsDirectory: Foundation.URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.apple.toolsQA.CocoaApp_CD" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        let url = appSupportURL.appendingPathComponent("ImageDocker")
        
        if !url.path.isDirectoryExists() {
            if !url.path.mkdirs(logger: logger) {
                self.logger.log("Unable to create application directory")
            }
        }
        
        return url
    }()

}

