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
    var state = ""
    
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
    
    func startFixedDelayExecution(intervalInSecond:Int) {
        if let exec = self.taskCode {
            DispatchQueue.global().async {
                while(true) {
                    if TaskletManager.default.isTaskStopped(id: self.id) {
                        print("stopped fixed delay job !!!!!!!!")
                        return
                    }
                    print("\(Date()) running fixed delay execution")
                    
                    
                    exec(self)
                    
                    print("\(Date()) waiting \(intervalInSecond) sec for next fixedDelay run")
                    
                    sleep(UInt32(intervalInSecond))
                }
            }
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
    
    var tasksStartStopState:[String:Bool] = [:]
    
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
    
    // MARK: - CREATE
    
    func task(type:String, name:String) -> Tasklet {
        if let task = self.getTask(type: type, name: name) {
            task.state = "READY"
            return task
        }else {
            let task = Tasklet(type:type, name:name)
            task.message = "Ready to start"
            task.state = "READY"
            task.changeListener(selector: #selector(self.onTaskChanged))
            tasks.append(task)
            if let view = self.viewManager {
                let _ = view.addTask(task: task)
            }
            return task
        }
    }
    
    // MARK: - CHANGE LISTENER
    
    @objc func onTaskChanged(notification: NSNotification) {
        for task in tasks {
            if task.taskid == notification.name.rawValue {
                if let view = viewManager {
                    DispatchQueue.main.async {
                        view.updateTask(task: task)
                    }
                }
                break
            }
        }
    }
    
    // MARK: - TASK STATE
    
    func isTaskStopped(type:String, name:String) -> Bool {
        if let task = self.getTask(type: type, name: name) {
            if let state = self.tasksStartStopState[task.id] {
                return !state
            }
        }
        return true
    }
    
    func isTaskStopped(id:String) -> Bool {
        if let state = self.tasksStartStopState[id] {
            return !state
        }
        return true
    }
    
    func stopTask(type:String, name:String, fromUI:Bool = false) {
        if let task = self.getTask(type: type, name: name) {
            self.stopTask(task: task, fromUI: fromUI)
        }
    }
    
    func stopTask(id:String, fromUI:Bool = false) {
        if let task = self.getTask(id: id) {
            self.stopTask(task: task, fromUI: fromUI)
        }
    }
    
    private func stopTask(task:Tasklet, fromUI:Bool) {
        task.state = "STOPPED"
        self.tasksStartStopState[task.id] = false
        task.stopExecution()
        if !fromUI {
            if let view = self.viewManager {
                view.stopTask(task: task)
            }
        }
    }
    
    func removeTask(type:String, name:String) {
        if let task = self.getTask(type: type, name: name) {
            self.removeTask(task: task)
        }
    }
    
    func removeTask(id:String) {
        if let task = self.getTask(id: id) {
            self.removeTask(task: task)
        }
    }
    
    private func removeTask(task:Tasklet) {
        task.state = "REMOVED"
        self.tasks.removeAll { (obj) -> Bool in
            return task.id == obj.id
        }
        self.tasksStartStopState.removeValue(forKey: task.id)
        
        if let view = self.viewManager {
            view.removeTask(task: task)
        }
    }
    
    // MARK: - SET MESSAGE OR PROGRESS
    
    func setTotal(type:String, name:String, total:Int) {
        if let task = self.getTask(type: type, name: name) {
            self.setTotal(task: task, total: total)
        }
    }
    
    func setTotal(id:String, total:Int) {
        if let task = self.getTask(id: id) {
            self.setTotal(task: task, total: total)
        }
    }
    
    private func setTotal(task:Tasklet, total:Int) {
        task.total = total
        task.state = "READY"
        if let view = self.viewManager {
            DispatchQueue.main.async {
                view.setTotal(task: task, total: total)
            }
        }
        task.notifyChange()
    }
    
    func updateProgress(type:String, name:String, message:String, increase:Bool = false) {
        if let task = self.getTask(type: type, name: name) {
            self.updateProgress(task: task, message: message, increase: increase)
        }
    }
    
    func updateProgress(id:String, message:String, increase:Bool = false) {
        if let task = self.getTask(id: id) {
            self.updateProgress(task: task, message: message, increase: increase)
        }
    }
    
    private func updateProgress(task:Tasklet, message:String, increase:Bool) {
        task.message = message
        
        if task.state != "STOPPED" && task.state != "COMPLETED" {
            task.state = "IN_PROGRESS"
            print("\(task.name) in progress")
        }
        if increase {
            task.progress += 1
            
            if task.progress == task.total {
                task.state = "COMPLETED"
                print("\(task.name) completed")
            }
        }
        task.notifyChange()
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
            self.startExecution(task: task)
        }
    }
    
    func startExecution(id:String){
        if let task = self.getTask(id: id) {
            self.startExecution(task: task)
        }
    }
    
    private func startExecution(task:Tasklet) {
        task.state = "IN_PROGRESS"
        task.progress = 0
        self.tasksStartStopState[task.id] = true
        task.startExecution()
    }
    
    func startFixedDelayExecution(type:String, name:String, intervalInSecond:Int) {
        if let task = self.getTask(type: type, name: name) {
            self.tasksStartStopState[task.id] = true
            task.startFixedDelayExecution(intervalInSecond: intervalInSecond)
        }
    }
    
    func startFixedDelayExecution(id:String, intervalInSecond:Int) {
        if let task = self.getTask(id: id) {
            self.tasksStartStopState[task.id] = true
            task.startFixedDelayExecution(intervalInSecond: intervalInSecond)
        }
    }
    
    // MARK: - CREATE AND EXECUTE
    
    func createAndStartTask(type:String, name:String, total:Int = 0, exec:@escaping ((Tasklet) -> Void), stop:@escaping ((Tasklet) -> Void)) -> Tasklet {
        let task = self.task(type: type, name: name)
        if total > 0 {
            self.setTotal(id: task.id, total: total)
        }
        self.setExecution(id: task.id, exec: exec, stop: stop)
        self.startExecution(id: task.id)
        return task
    }
    
    func createAndStartFixedDelayTask(type:String, name:String, total:Int = 0, intervalInSecond:Int, exec:@escaping ((Tasklet) -> Void), stop:@escaping ((Tasklet) -> Void)) -> Tasklet {
        let task = self.task(type: type, name: name)
        if total > 0 {
            self.setTotal(id: task.id, total: total)
        }
        self.setExecution(id: task.id, exec: exec, stop: stop)
        self.startFixedDelayExecution(id: task.id, intervalInSecond: intervalInSecond)
        return task
        
    }
    
    // MARK: - FOR ALL TASKS
    
    func loadTasks() {
        if let view = self.viewManager {
            for task in self.tasks {
                if view.addTask(task: task) {
                    view.setTotal(task: task, total: task.total)
                    if task.total > 0 {
                        view.setProgressValue(task: task, progressValue: task.progress)
                        if task.progress == task.total {
                            view.setComplete(task: task)
                        }
                    }
                }
            }
        }
    }
    
    func stopAllTasks(fromUI:Bool = false) {
        for task in self.tasks {
            if task.state != "COMPLETED" {
                self.stopTask(task: task, fromUI: fromUI)
            }
        }
    }
    
    func removeCompletedTasks() {
        for task in self.tasks {
            if task.state == "COMPLETED" {
                self.removeTask(task: task)
            }
        }
    }
    
    func removeAllTasks() {
        if let view = self.viewManager {
            for task in self.tasks {
                view.stopTask(task: task)
                self.removeTask(task: task)
            }
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

class FakeTaskletManager {
    static let `default` = FakeTaskletManager()
    
    var fakeTasks:[String:Timer] = [:]
    
    func stubJob(taskId:String) {
        var n = 1
        let total = 10
        TaskletManager.default.setTotal(id: taskId, total: total)
        while(n <= total) {
            if TaskletManager.default.isTaskStopped(id: taskId) == true {
                print("stopped !!!!!!!")
                return
            }
            sleep(3)
            print("doing step \(n)")
            TaskletManager.default.updateProgress(id: taskId, message: "Doing step \(n)", increase: true)
            
            n += 1
        }
    }
    
    func rehearsal() {
        print("\(Date()) task manager rehearsal")
        
        let _ = TaskletManager.default.createAndStartTask(type: "TEST", name: "test4234", exec: { task in
            DispatchQueue.global().async {
                self.stubJob(taskId: task.id)
            }
        }, stop: {task in
            
        })
        
        let _ = TaskletManager.default.createAndStartTask(type: "TEST", name: "test1234", exec: { task in
            let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                TaskletManager.default.updateProgress(type: "TEST", name: "test1234", message: "\(Date()) 1 changing")
            })
            self.fakeTasks[task.id] = timer
        }, stop: {task in
            if let timer = self.fakeTasks[task.id] {
                timer.invalidate()
            }
        })
        
        let _ = TaskletManager.default.createAndStartTask(type: "TEST", name: "test2234", total: 10, exec: { task in
            let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                TaskletManager.default.updateProgress(type: "TEST", name: "test2234", message: "\(Date()) 2 changing", increase: true)
            })
            self.fakeTasks[task.id] = timer
        }, stop: {task in
            if let timer = self.fakeTasks[task.id] {
                timer.invalidate()
            }
        })
        
        let _ = TaskletManager.default.createAndStartTask(type: "TEST", name: "test3234", exec: { task in
            let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                TaskletManager.default.updateProgress(type: "TEST", name: "test3234", message: "\(Date()) 3 changing")
            })
            self.fakeTasks[task.id] = timer
        }, stop: {task in
            if let timer = self.fakeTasks[task.id] {
                timer.invalidate()
            }
        })
        
        let _ = TaskletManager.default.createAndStartFixedDelayTask(type: "TEST", name: "test5234", total: 10, intervalInSecond: 5, exec: { task in
            
            let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
                TaskletManager.default.updateProgress(id: task.id, message: "\(Date()) running fixed delay job", increase: true)
            })
            self.fakeTasks[task.id] = timer
        }, stop: {task in
            if let timer = self.fakeTasks[task.id] {
                timer.invalidate()
            }
            
        })
    }
}
