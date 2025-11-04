//
//  AppDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/22.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var editMenu: NSMenu!
    @IBOutlet weak var windowMenu: NSMenu!
    
    var terminateWithoutBackupDB = false
    
    static let logger = LoggerFactory.get(category: "AppDelegate")
    
    func setupMainMenu() {
        self.mainMenu.item(at: 0)?.title = Words.mainmenu_about.word()
        self.mainMenu.item(at: 2)?.title = Words.mainmenu_preferences.word()
        self.mainMenu.item(at: 3)?.title = Words.mainmenu_database_and_backup.word()
        self.mainMenu.item(at: 4)?.title = Words.mainmenu_local_environment.word()
        self.mainMenu.item(at: 5)?.title = Words.mainmenu_external_api.word()
        self.mainMenu.item(at: 7)?.title = Words.mainmenu_logfile.word()
        self.mainMenu.item(at: 8)?.title = Words.mainmenu_logfolder.word()
        self.mainMenu.item(at: 10)?.title = Words.mainmenu_quit.word()
        
        self.mainMenu.item(at: 7)?.action = #selector(open_log_file(_:))
        self.mainMenu.item(at: 8)?.action = #selector(open_log_folder(_:))
    }
    
    @objc func open_log_file(_ menuItem:NSMenuItem) {
        autoreleasepool { () -> Void in
            let proc = Process()
            proc.launchPath = "/usr/bin/open"
            proc.arguments = [URL(fileURLWithPath: AppDelegate.logFilePath()).appendingPathComponent(AppDelegate.defaultLoggingFilename()).path()]
            proc.launch()
        }
    }
    
    @objc func open_log_folder(_ menuItem:NSMenuItem) {
        let url = URL(fileURLWithPath: AppDelegate.logFilePath())
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
//        DispatchQueue.global().async {
//            ExecutionEnvironment.default.createDataBackup(suffix:"-on-launch")
//            IPHONE.bridge.unmountFuse()
//        }
    }
    
    static fileprivate var _defaultLoggingFilename = ""
    
    static func defaultLoggingFilename() -> String {
        if self._defaultLoggingFilename != "" {
            return self._defaultLoggingFilename
        }else{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HHmm"
            let datePart = dateFormatter.string(from: Date())
            self._defaultLoggingFilename = "\(datePart).log"
            return self._defaultLoggingFilename
        }
    }
    
    static fileprivate var _logFilePath = ""
    fileprivate var _toolsPath = ""
    
    static func logFilePath() -> String {
        if self._logFilePath == "" {
            self._logFilePath = Self.applicationDocumentsDirectory.appending(component: "log").appending(component: self.defaultLoggingFilename()).path
        }
        return self._logFilePath
    }
    
    func toolsPath() -> String{
        if self._toolsPath == "" {
            self._toolsPath = AppDelegate.applicationDocumentsDirectory.appending(component: "tools").path
        }
        return self._toolsPath
    }
    
    static func setupLogger() {
        print("Setup LoggerFactory ...")
        LoggerFactory.append(logWriter: ConsoleLogger())
        LoggerFactory.append(logWriter: FileLogger(pathOfFolder: self.logFilePath()))
        LoggerFactory.enable([.info, .error, .warning, .debug])
//        LoggerFactory.enable(category: "DB", types: [.info, .error, .warning, .trace])
        self.logger.log(.info, "Testing logger ...")
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        NSUserNotificationCenter.default.delegate = self
        self.setupMainMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        
        DeviceBridge.IPHONE().unmountFuse()
        
        if ExecutionEnvironment.default.getDatabaseBackupVolume() == "" {
            self.terminateWithoutBackupDB = true
        }
        
        if !self.terminateWithoutBackupDB {
            let alert = NSAlert()
            DispatchQueue.global().async {
                if let databaseProfile = Setting.database.selectedDatabaseProfile() {
                    let _ = ExecutionEnvironment.default.createDatabaseBackup(profile: databaseProfile, suffix:"-on-exit")
                    
                    DispatchQueue.main.async {
                        alert.buttons[0].title = "Quit"
                        alert.buttons[0].isEnabled = true
                        alert.window.close()
                        exit(0)
                    }
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
    
    static var applicationDocumentsDirectory: Foundation.URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.apple.toolsQA.CocoaApp_CD" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        let url = appSupportURL.appendingPathComponent("ImageDocker")
        
        if !url.path.isDirectoryExists() {
            let (created, error) = url.path.mkdirs(logger: logger)
            if !created {
                AppDelegate.logger.log(.error, "Unable to create application directory - \(error)")
            }
        }
        
        return url
    }()

}

