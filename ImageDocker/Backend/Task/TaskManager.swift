//
//  TaskHelper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/5/7.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class TaskManager {
    
    static var loadingImagesCollection = false
    static var scanningFileSystem = false
    static var readingImagesExif = false
    static var applyingSelectionModifies = false
    static var refreshingTrees = false
    static var refreshingRepositoryTree = false
    static var exporting = false
    
    static func printStatus() {
        print("loading collection: \(loadingImagesCollection), scanning filesys: \(scanningFileSystem), reading exif: \(readingImagesExif), refreshing trees: \(refreshingTrees), exporting: \(exporting), applying selection modifies: \(applyingSelectionModifies)")
    }
    
    static func allowRefreshTrees() -> Bool {
        printStatus()
        if loadingImagesCollection || refreshingTrees {
            print("DISALLOW REFRESH TREE")
            return false
        }else{
            print("ALLOW REFRESH TREE")
            return true
        }
    }
    
    static func allowScanFileSystem() -> Bool {
        printStatus()
        if scanningFileSystem || readingImagesExif || refreshingTrees || exporting {
            print("DISALLOW SCAN FILESYS")
            return false
        }else{
            print("ALLOW SCAN FILESYS")
            return true
        }
    }
    
    static func allowReadImagesExif() -> Bool {
        printStatus()
        if scanningFileSystem || readingImagesExif || refreshingTrees || exporting {
            print("DISALLOW READ EXIF")
            return false
        }else{
            print("ALLOW READ EXIF")
            return true
        }
    }
    
    static func allowExport() ->Bool {
        printStatus()
        if scanningFileSystem || readingImagesExif || refreshingTrees || exporting {
            print("DISALLOW EXPORT")
            return false
        }else{
            print("ALLOW EXPORT")
            return true
        }
    }
    
    static func allowApplySelectionModifies() -> Bool {
        printStatus()
        if applyingSelectionModifies {
            print("DISALLOW APPLY SELECTION MODIFIES")
            return false
        }else{
            print("ALLOW APPLY SELECTION MODIFIES")
            return true
        }
    }
    
}

class Tasklet {
    
    var type = "task"
    var id = ""
    var name = ""
    var description = ""
    var running = false
    var forceStop = false
    var forceStopped = false
    var total = 0
    var progress = 0
    var beginTime:Date
    var taskid = ""
    
    init(type:String, name:String) {
        self.id = UUID().uuidString
        self.taskid = "TASKLET_\(id)"
        self.name = name
        self.type = type
        self.beginTime = Date()
    }
    
    func notifyChange(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: taskid), object: self)
    }
    
    func addObserver(_ observer:Any, selector:Selector){
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: taskid), object: nil)
    }
    
    func removeObserver(_ observer:Any) {
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: taskid), object: nil)
    }
}

class TaskletManager {
    
    static let `default` = TaskletManager()
    
    var tasks:[Tasklet] = []
    
    func task(type:String, name:String) -> Tasklet {
        var t:Tasklet? = nil
        for task in tasks {
            if task.name == name && task.type == type {
                t = task
                break
            }
        }
        if t == nil {
            t = Tasklet(type:type, name:name)
            tasks.append(t!)
        }
        return t!
    }
    
    func running() -> [Tasklet] {
        var result:[Tasklet] = []
        for task in tasks {
            if task.running {
                result.append(task)
            }
        }
        return result
    }
    
}
