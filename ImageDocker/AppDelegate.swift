//
//  AppDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/22.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        DispatchQueue.global().async {
            self.createDataBackup(suffix:"-on-launch")
        }
    }
    
    func createDataBackup(suffix:String){
        print("\(Date()) Start to create db backup")
        let dbUrl = self.applicationDocumentsDirectory
        let dbFile = dbUrl.appendingPathComponent("ImageDocker.sqlite")
        let dbFileSHM = dbUrl.appendingPathComponent("ImageDocker.sqlite-shm")
        let dbFileWAL = dbUrl.appendingPathComponent("ImageDocker.sqlite-wal")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: dbFile.path) {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyyMMdd_HHmmss"
            let backupFolder = "DataBackup-\(dateFormat.string(from: Date()))\(suffix)"
            let backupUrl = dbUrl.appendingPathComponent(backupFolder)
            do{
                try fileManager.createDirectory(at: backupUrl, withIntermediateDirectories: true, attributes: nil)
                
                print("Backup data to: \(backupUrl.path)")
                try fileManager.copyItem(at: dbFile, to: backupUrl.appendingPathComponent("ImageDocker.sqlite"))
                if fileManager.fileExists(atPath: dbFileSHM.path){
                    try fileManager.copyItem(at: dbFileSHM, to: backupUrl.appendingPathComponent("ImageDocker.sqlite-shm"))
                }
                if fileManager.fileExists(atPath: dbFileWAL.path){
                    try fileManager.copyItem(at: dbFileWAL, to: backupUrl.appendingPathComponent("ImageDocker.sqlite-wal"))
                }
            }catch{
                print(error)
                return
            }
        }
        print("\(Date()) Finish create db backup")
    }
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        self.createDataBackup(suffix:"-on-exit")
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
        return appSupportURL.appendingPathComponent("ImageDocker")
    }()

}

