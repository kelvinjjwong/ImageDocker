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
    
    let logger = ConsoleLogger(category: "AppDelegate")
    
    func applicationWillFinishLaunching(_ notification: Notification) {
//        DispatchQueue.global().async {
//            ExecutionEnvironment.default.createDataBackup(suffix:"-on-launch")
//            IPHONE.bridge.unmountFuse()
//        }
    }
    
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSUserNotificationCenter.default.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        DispatchQueue.global().async {
            let _ = ExecutionEnvironment.default.createDatabaseBackup(suffix:"-on-exit")
        }
        IPHONE.bridge.unmountFuse()
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
        var isDir : ObjCBool = false
        
        let _  = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        
        if !isDir.boolValue {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }catch{
                self.logger.log("Unable to create application directory")
                self.logger.log(error)
            }
        }
        
        return url
    }()

}

