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
    var message = ""
    var running = false
    var forceStop = false
    var forceStopped = false
    var total = 0
    var progress = 0
    var beginTime:Date
    var taskid = ""
    
    var taskCode: ((Tasklet) -> Void)? = nil
    
    var stopTaskCode: ((Tasklet) -> Void)? = nil
    
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
    
    @objc func onTaskChanged(notification: NSNotification) {
        TaskletManager.default.onTaskChanged(notification: notification)
    }
    
    func changeListener(selector:Selector){
        NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: taskid), object: nil)
    }
    
    func removeListener() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: taskid), object: nil)
    }
    
    func toString() -> String {
        let str = """
{type:\(type), id:\(id), taskid:\(taskid), name:"\(name)", message:"\(message)", total:\(total), progress:\(progress), begin:\(beginTime)}
"""
        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func setExecution(_ exec:@escaping ((Tasklet) -> Void), stop:@escaping ((Tasklet) -> Void)) {
        self.taskCode = exec
        self.stopTaskCode = stop
    }
    
    func startExecution() {
        if let exec = self.taskCode {
            exec(self)
        }
    }
    
    func stopExecution() {
        if let stop = self.stopTaskCode {
            stop(self)
        }
    }
}

class TaskletManager {
    
    static let `default` = TaskletManager()
    
    var viewManager:TaskProgressViewController? = nil
    
    var tasks:[Tasklet] = []
    
    func bindToView(view:TaskProgressViewController) -> TaskletManager {
        self.viewManager = view
        return self
    }
    
    private func getTask(type:String, name:String) -> Tasklet? {
        var t:Tasklet? = nil
        for task in tasks {
            if task.name == name && task.type == type {
                t = task
                break
            }
        }
        return t
    }
    
    private func getTask(id:String) -> Tasklet? {
        var t:Tasklet? = nil
        for task in tasks {
            if task.id == id {
                t = task
                break
            }
        }
        return t
    }
    
    func task(type:String, name:String) -> Tasklet {
        if let task = self.getTask(type: type, name: name) {
            return task
        }else {
            let task = Tasklet(type:type, name:name)
            task.message = "Ready to start"
            task.changeListener(selector: #selector(self.onTaskChanged))
            tasks.append(task)
            if let view = self.viewManager {
                view.addTask(task: task)
            }
            return task
        }
    }
    
    @objc func onTaskChanged(notification: NSNotification) {
        for task in tasks {
            if task.taskid == notification.name.rawValue {
                if let view = viewManager {
                    view.updateTask(task: task)
                }
                break
            }
        }
    }
    
    func setTotal(type:String, name:String, total:Int) {
        if let task = self.getTask(type: type, name: name) {
            task.total = total
            if let view = self.viewManager {
                view.setTotal(task: task, total: total)
            }
            task.notifyChange()
        }
    }
    
    func setTotal(id:String, total:Int) {
        if let task = self.getTask(id: id) {
            task.total = total
            if let view = self.viewManager {
                view.setTotal(task: task, total: total)
            }
            task.notifyChange()
        }
    }
    
    func updateMessage(type:String, name:String, message:String) {
        if let task = self.getTask(type: type, name: name) {
            task.message = message
            task.notifyChange()
        }
    }
    
    func updateMessage(id:String, message:String) {
        if let task = self.getTask(id: id) {
            task.message = message
            task.notifyChange()
        }
    }
    
    func increase(type:String, name:String, progress:Int = 1) {
        if let task = self.getTask(type: type, name: name) {
            task.progress += progress
            task.notifyChange()
        }
    }
    
    func increase(id:String, progress:Int = 1) {
        if let task = self.getTask(id: id) {
            task.progress += progress
            task.notifyChange()
        }
    }
    
    func rehearsal() {
        print("\(Date()) task manager rehearsal")
        self.updateMessage(type: "TEST", name: "test1234", message: "\(Date()) 1 changing")
        self.updateMessage(type: "TEST", name: "test2234", message: "\(Date()) 2 changing")
        self.updateMessage(type: "TEST", name: "test3234", message: "\(Date()) 3 changing")
        self.printAll()
    }
    
    func loadTasks() {
        self.fakeInit()
    }
    
    var fakeTasks:[String:Timer] = [:]
    
    func fakeInit() {
        self.task(type: "TEST", name: "test1234")
        self.task(type: "TEST", name: "test2234")
        self.task(type: "TEST", name: "test3234")
        
        self.setTotal(type: "TEST", name: "test2234", total: 10)
        
        self.setExecution(type: "TEST", name: "test1234", exec: { task in
            let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                self.updateMessage(type: "TEST", name: "test1234", message: "\(Date()) 1 changing")
            })
            self.fakeTasks[task.id] = timer
        }, stop: {task in
            if let timer = self.fakeTasks[task.id] {
                timer.invalidate()
            }
        })
        
        self.setExecution(type: "TEST", name: "test2234", exec: { task in
            let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                self.updateMessage(type: "TEST", name: "test2234", message: "\(Date()) 2 changing")
            })
            self.fakeTasks[task.id] = timer
        }, stop: {task in
            if let timer = self.fakeTasks[task.id] {
                timer.invalidate()
            }
        })
        
        self.setExecution(type: "TEST", name: "test3234", exec: { task in
            let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                self.updateMessage(type: "TEST", name: "test3234", message: "\(Date()) 3 changing")
            })
            self.fakeTasks[task.id] = timer
        }, stop: {task in
            if let timer = self.fakeTasks[task.id] {
                timer.invalidate()
            }
        })
        
        self.startExecution(type: "TEST", name: "test1234")
        self.startExecution(type: "TEST", name: "test2234")
        self.startExecution(type: "TEST", name: "test3234")
        
        
        
    }
    
    func setExecution(type:String, name:String, exec:@escaping ((Tasklet) -> Void), stop:@escaping ((Tasklet) -> Void)) {
        if let task = self.getTask(type: type, name: name) {
            task.setExecution(exec, stop: stop)
        }
    }
    
    func setExecution(id:String, exec:@escaping ((Tasklet) -> Void), stop:@escaping ((Tasklet) -> Void)) {
        if let task = self.getTask(id: id) {
            task.setExecution(exec, stop: stop)
        }
    }
    
    func startExecution(type:String, name:String) {
        if let task = self.getTask(type: type, name: name) {
            task.startExecution()
        }
    }
    
    func startExecution(id:String){
        if let task = self.getTask(id: id) {
            task.startExecution()
        }
    }
    
    func printAll() {
        print("===================================")
        print("Listing all tasks ...")
        for task in tasks {
            print(task.toString())
        }
        print("===================================")
    }
    
}
