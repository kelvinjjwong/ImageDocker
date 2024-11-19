//
//  TaskHelper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/5/7.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

class TaskManager {
    
    static let logger = LoggerFactory.get(category: "TaskManager", includeTypes: [.debug])
    
    static var loadingImagesCollection = false
    static var scanningFileSystem = false
    static var readingImagesExif = false
    static var applyingSelectionModifies = false
    static var refreshingTrees = false
    static var refreshingRepositoryTree = false
    static var exporting = false
    
    static func printStatus() {
        TaskManager.logger.log(.trace, "loading collection: \(loadingImagesCollection), scanning filesys: \(scanningFileSystem), reading exif: \(readingImagesExif), refreshing trees: \(refreshingTrees), exporting: \(exporting), applying selection modifies: \(applyingSelectionModifies)")
    }
    
    static func allowRefreshTrees() -> Bool {
        printStatus()
        if loadingImagesCollection || refreshingTrees {
            TaskManager.logger.log("DISALLOW REFRESH TREE")
            return false
        }else{
            TaskManager.logger.log("ALLOW REFRESH TREE")
            return true
        }
    }
    
    static func allowScanFileSystem() -> Bool {
        printStatus()
        if scanningFileSystem || readingImagesExif || refreshingTrees || exporting {
            TaskManager.logger.log("DISALLOW SCAN FILESYS")
            return false
        }else{
            TaskManager.logger.log("ALLOW SCAN FILESYS")
            return true
        }
    }
    
    static func allowReadImagesExif() -> Bool {
        printStatus()
        if scanningFileSystem || readingImagesExif || refreshingTrees || exporting {
            TaskManager.logger.log("DISALLOW READ EXIF")
            return false
        }else{
            TaskManager.logger.log("ALLOW READ EXIF")
            return true
        }
    }
    
    static func allowExport() ->Bool {
        printStatus()
        if scanningFileSystem || readingImagesExif || refreshingTrees || exporting {
            TaskManager.logger.log("DISALLOW EXPORT")
            return false
        }else{
            TaskManager.logger.log("ALLOW EXPORT")
            return true
        }
    }
    
    static func allowApplySelectionModifies() -> Bool {
        printStatus()
        if applyingSelectionModifies {
            TaskManager.logger.log("DISALLOW APPLY SELECTION MODIFIES")
            return false
        }else{
            TaskManager.logger.log("ALLOW APPLY SELECTION MODIFIES")
            return true
        }
    }
    
}

struct TasksStatus {
    var runningCount = 0
    var totalCount = 0
    
    public init(running:Int, total:Int) {
        self.runningCount = running
        self.totalCount = total
    }
}

class Tasklet {
    
    let logger = LoggerFactory.get(category: "Tasklet", includeTypes: [.debug])
    
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
    
    var isFixedDelayJob = false
    var fixedDelayInterval:Int = 0
    var timesOfRun = 0
    var timeOfNextRun = 0
    
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
    
    private func getRemainingTime(timeInSecond:Int) -> String {
        if timeInSecond < 60 {
            return "\(timeInSecond) sec"
        }else if timeInSecond < 3600 {
            let minutes = timeInSecond / 60
            let seconds = timeInSecond - minutes * 60
            return "\(minutes) min \(seconds) sec"
        }else {
            let hours = timeInSecond / 3600
            let mins = timeInSecond - hours * 3600
            let minutes = mins / 60
            let seconds = mins - minutes * 60
            return "\(hours) hours \(minutes) min \(seconds) sec"
        }
    }
    
    func startFixedDelayExecution(intervalInSecond:Int) {
        self.logger.log(.trace, "fixed delay execution - \(self.name) - \(self.state)")
        if let exec = self.taskCode {
            DispatchQueue.global().async {
                while(true) {
                    if TaskletManager.default.isTaskStopped(id: self.id) {
//                        self.logger.log(.trace, "stopped fixed delay job !!!!!!!!")
                        return
                    }
                    //self.logger.log(.trace, "fixed delay execution - \(self.name) - \(self.state)")
                    
                    if self.state == "COMPLETED" || self.state == "READY" {
                        self.state = "IN_PROGRESS"
                        exec(self) // support sync method, unsupport async method
                    }
                    
                    if self.state == "COMPLETED" || self.state == "READY" {
                        
//                        self.logger.log(.trace, "waiting \(intervalInSecond) sec for next fixedDelay run")
                        
                        if !TaskletManager.default.isSingleMode() {
                            var n = 0
                            while(n < intervalInSecond) {
                                if TaskletManager.default.isTaskStopped(id: self.id) {
    //                                self.logger.log(.trace, "stopped fixed delay job !!!!!!!!")
                                    return
                                }
                                
                                if let view = TaskletManager.default.viewManager {
                                    self.message = "Waiting for next run: \(self.getRemainingTime(timeInSecond: (intervalInSecond - n)))"
                                    view.updateMessage(task: self)
                                }
                                sleep(1)
                                n += 1
                            }

                            self.progress = 0
                            
                            if let view = TaskletManager.default.viewManager {
                                view.updatePanelForRestartTask(task: self)
                            }
                        }else{
                            break // if single mode, exit while loop. TaskletManager will push it to end of queue again.
                        }
                    }else{
                        sleep(1) // continue in progress
                    }
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
    
    static let NOTIFICATION_KEY_TASKCOUNT = "Task_Count"
    
    let logger = LoggerFactory.get(category: "TaskletManager", includeTypes: [.debug])
    
    static let `default` = TaskletManager()
    
    var viewManager:TaskProgressViewController? = nil
    
    func bindToView(view:TaskProgressViewController) -> TaskletManager {
        self.viewManager = view
        return self
    }
    
    var tasks:[Tasklet] = []
    
    var tasksStartStopState:[String:Bool] = [:]
    
    // MARK: - QUEUE for SINGLE MODE
    
    private var queue = Queue<Tasklet>()
    
    private var queueTimer:Timer? = nil
    
    public init() {
        self.startQueueTimer()
    }
    
    // MARK: - SINGLE THREAD MODE QUEUE TIMER
    
    func isSingleMode() -> Bool {
        return Setting.database.isSQLite()
    }
    
    func updateTasksCountInMainWindow() {
        let runningCount = self.tasks.count(where: { $0.state == "IN_PROGRESS" })
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TaskletManager.NOTIFICATION_KEY_TASKCOUNT), object: TasksStatus(running: runningCount, total: self.tasks.count))
    }
    
    func startQueueTimer() {
        self.queueTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if self.isSingleMode() {
                //self.logger.log(.trace, "===== single thread mode ======")
                self.printQueuedTasks()
                if !self.queue.isEmpty {
                    if let task = self.getPeakTaskFromQueue() {
                        if task.state == "READY" {
                            var shouldTrigger = false
                            if let state = self.tasksStartStopState[task.id] {
                                if state == false {
                                    shouldTrigger = true
                                }
                            }else{
                                shouldTrigger = true
                            }
                            
                            if shouldTrigger {
                                self.tasksStartStopState[task.id] = true
                                if task.isFixedDelayJob {
                                    if task.timesOfRun > 0 {
                                        let now = Int(Date().timeIntervalSince1970)
                                        if now < task.timeOfNextRun {
                                            // at next run, wait for remaining fixed delay interval if the time has not arrived
                                            let interval = task.timeOfNextRun - now
                                            sleep(UInt32(interval))
                                        }
                                        if let view = self.viewManager {
                                            view.setProgressValue(task: task, progressValue: 0)
                                        }
                                    }
                                    self.startFixedDelayExecution(task: task)
                                }else{
                                    self.startExecution(task: task)
                                }
                                
                                self.updateTasksCountInMainWindow()
                            }
                            
                        }else if task.state == "STOPPED" {
                            let _ = self.queue.dequeue()
                            self.updateTasksCountInMainWindow()
                        }else if task.state == "COMPLETED" {
                            let _ = self.queue.dequeue()
                            self.updateTasksCountInMainWindow()
                            if task.isFixedDelayJob { // queue for next run
                                // increase task timesOfRun,
                                task.timesOfRun += 1
                                // calculate/set the time of next run (in seconds)
                                // at next run, wait for remaining fixed delay interval if the time has not arrived
                                task.timeOfNextRun = Int(Date().timeIntervalSince1970) + task.fixedDelayInterval
                                task.state = "READY"
                                task.progress = 0
                                task.message = "Waiting for next run ..."
                                self.tasksStartStopState[task.id] = false
                                if let view = self.viewManager {
                                    view.updateMessage(task: task)
                                }
                                self.pushTaskToQueue(task: task, toEnd: true)
                            }
                        }
                    }
                }
                // end if single thread mode
            }else{
                //self.logger.log(.trace, "===== multi thread mode ======")
                // when suddenly changed from single thread mode to multi thread mode
                // clean the queue and execute all queued tasks
                let queuedTasks = self.queue.dequeueAll()
                if queuedTasks.count > 0 {
                    for task in queuedTasks {
                        if task.isFixedDelayJob {
                            self.startFixedDelayExecution(task: task)
                        }else{
                            self.startExecution(task: task)
                        }
                    }
                }
            }
            
        })
    }
    
    func printQueuedTasks() {
        self.logger.log(.trace, "==========================")
        self.logger.log(.trace, "Queued tasks: \(self.queue.list.count)")
        for task in self.queue.list {
            if task.isFixedDelayJob {
                self.logger.log(.trace, "\(task.name) - \(task.state) - ran \(task.timesOfRun) times - next run: \(task.timeOfNextRun) - startStopState: \(String(describing: self.tasksStartStopState[task.id]))")
            }else{
                self.logger.log(.trace, "\(task.name) - \(task.state)")
            }
        }
        self.logger.log(.trace, "==========================")
    }
    
    func getPeakTaskFromQueue() -> Tasklet? {
        for task in self.queue.list {
            if task.isFixedDelayJob && task.state == "STOPPED" {
                continue
            }
            return task
        }
        return nil
    }
    
    private func pushTaskToQueue(task:Tasklet, toEnd:Bool = false) {
        if toEnd {
            self.queue.list.removeAll { (obj) -> Bool in
                return obj.id == task.id
            }
            self.queue.enqueue(task)
        }else{
            if !self.isInQueue(task: task) {
                self.queue.enqueue(task)
            }
        }
    }
    
    private func isInQueue(task:Tasklet) -> Bool {
        if self.queue.isEmpty {
            return false
        }else{
            return self.queue.list.contains(where: { obj -> Bool in
                return obj.id == task.id
            })
        }
    }
    
    // MARK: - GET TASK
    
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
    
    // MARK: - CREATE TASK
    
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
    
    // MARK: - TASK's CHANGE LISTENER
    
    @objc func onTaskChanged(notification: NSNotification) {
        for task in tasks {
            if task.taskid == notification.name.rawValue {
                //self.logger.log(.trace, "=== onTaskChanged - \(task.taskid) - \(task.state)")
                //self.logger.log(.trace, "viewManager is nil ? \(viewManager == nil)")
                if let view = viewManager {
                    DispatchQueue.main.async {
                        view.updateTask(task: task)
                    }
                }
                break
            }
        }
    }
    
    // MARK: - TASK's RUNNING STATE
    
    func isTaskStopped(type:String, name:String) -> Bool {
        if let task = self.getTask(type: type, name: name) {
            if let state = self.tasksStartStopState[task.id] {
                return !state
            }
        }
        return true
    }
    
    func isTaskStopped(id:String) -> Bool {
        if id == "" { return false }
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
        
        self.updateTasksCountInMainWindow()
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
        
        self.updateTasksCountInMainWindow()
    }
    
    // MARK: - TASK's PROPERTIES
    
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
    
    // MARK: - UPDATE TASK PROGRESS
    
    func updateProgress(type:String, name:String, message:String, increase:Bool = false) {
        if let task = self.getTask(type: type, name: name) {
            self.updateProgress(task: task, message: message, increase: increase)
        }
    }
    
    func updateProgress(id:String, message:String, increase:Bool = false) {
        if id == "" {return}
        if let task = self.getTask(id: id) {
            self.updateProgress(task: task, message: message, increase: increase)
        }
    }
    
    func forceComplete(id:String) {
        if id == "" {return}
        if let task = self.getTask(id: id) {
            task.state = "COMPLETED"

            if self.isSingleMode() {
                self.tasksStartStopState[task.id] = false
            }else{
                if !task.isFixedDelayJob {
                    self.tasksStartStopState[task.id] = false
                }
            }

            task.notifyChange()
            self.logger.log(.trace, "forceComplete notifyChange \(task.name)")
            
            self.updateTasksCountInMainWindow()
        }
    }
    
    private func updateProgress(task:Tasklet, message:String, increase:Bool) {
        task.message = message
        
        if task.state != "STOPPED" && task.state != "COMPLETED" {
            task.state = "IN_PROGRESS"
//            self.logger.log(.trace, "\(task.name) in progress")
        }
        if increase && task.state == "IN_PROGRESS" {
            task.progress += 1
            
            if task.progress == task.total {
                task.state = "COMPLETED"
                if self.isSingleMode() {
                    self.tasksStartStopState[task.id] = false
                }else{
                    if !task.isFixedDelayJob {
                        self.tasksStartStopState[task.id] = false
                    }
                }
                self.updateTasksCountInMainWindow()
//                self.logger.log(.trace, "\(task.name) completed")
            }
        }
        task.notifyChange()
    }
    
    // MARK: - START TASK EXECUTION
    
    func startExecution(type:String, name:String) {
        if let task = self.getTask(type: type, name: name) {
            if self.isSingleMode() {
                self.pushTaskToQueue(task: task)
            }else{
                self.startExecution(task: task)
            }
        }
    }
    
    func startExecution(id:String){
        if let task = self.getTask(id: id) {
            if self.isSingleMode() {
                self.pushTaskToQueue(task: task)
            }else{
                self.startExecution(task: task)
            }
        }
    }
    
    private func startExecution(task:Tasklet) {
        task.state = "IN_PROGRESS"
        task.progress = 0
        self.tasksStartStopState[task.id] = true
        task.startExecution()
    }
    
    func startFixedDelayExecution(type:String, name:String) {
        if let task = self.getTask(type: type, name: name) {
            //self.logger.log(.trace, "===== arrange start fixed delay task: \(task.name) - \(task.state) - \(self.tasksStartStopState[task.id])")
            if self.isSingleMode() {
                if self.isInQueue(task: task) {
                    task.state = "READY"
                }else{
                    task.state = "READY"
                    self.pushTaskToQueue(task: task)
                }
            }else{
                self.startFixedDelayExecution(task: task)
            }
        }
    }
    
    func startFixedDelayExecution(id:String) {
        if let task = self.getTask(id: id) {
            //self.logger.log(.trace, "===== arrange start fixed delay task: \(task.name) - \(task.state) - \(self.tasksStartStopState[task.id])")
            if self.isSingleMode() {
                if self.isInQueue(task: task) {
                    task.state = "READY"
                }else{
                    self.logger.log(.trace, "push to queue - \(task.name)")
                    task.state = "READY"
                    self.pushTaskToQueue(task: task)
                }
            }else{
                self.startFixedDelayExecution(task: task)
            }
        }
    }
    
    private func startFixedDelayExecution(task:Tasklet) {
        task.state = "READY"
        task.progress = 0
        self.tasksStartStopState[task.id] = true
        task.startFixedDelayExecution(intervalInSecond: task.fixedDelayInterval) // TODO : in single mode, before each run, check if no other task is running
    }
    
    // MARK: - CREATE AND EXECUTE TASK
    
    func createAndStartTask(type:String, name:String, total:Int = 0, exec:@escaping ((Tasklet) -> Void), stop:@escaping ((Tasklet) -> Void)) -> Tasklet {
        let task = self.task(type: type, name: name)
        if total > 0 {
            self.setTotal(id: task.id, total: total)
        }
        self.setExecution(id: task.id, exec: exec, stop: stop)
        self.startExecution(id: task.id)
        
        self.updateTasksCountInMainWindow()
        return task
    }
    
    func createAndStartFixedDelayTask(type:String, name:String, total:Int = 0, intervalInSecond:Int, exec:@escaping ((Tasklet) -> Void), stop:@escaping ((Tasklet) -> Void)) -> Tasklet {
        let task = self.task(type: type, name: name)
        if total > 0 {
            self.setTotal(id: task.id, total: total)
        }
        self.setExecution(id: task.id, exec: exec, stop: stop)
        task.isFixedDelayJob = true
        task.fixedDelayInterval = intervalInSecond
        self.startFixedDelayExecution(id: task.id)
        return task
        
    }
    
    func searchRunningTask(name:String) -> Tasklet? {
        for task in tasks {
            if task.name == name && task.state != "COMPLETED" && task.state != "STOPPED"  {
                return task
            }
        }
        return nil
    }
    
    func searchRunningTask(name:String, type:String) -> Tasklet? {
        for task in tasks {
            if task.name == name && task.type == type && task.state != "COMPLETED" && task.state != "STOPPED" {
                return task
            }
        }
        return nil
    }
    
    func searchRunningTask(name:String, types:[String]) -> Tasklet? {
        for task in tasks {
            if task.name == name && types.contains(task.type) && task.state != "COMPLETED" && task.state != "STOPPED" {
                return task
            }
        }
        return nil
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
            
            self.updateTasksCountInMainWindow()
        }
    }
    
    func stopAllTasks(fromUI:Bool = false) {
        for task in self.tasks {
            if task.state != "COMPLETED" {
                self.stopTask(task: task, fromUI: fromUI)
            }
        }
        
        self.updateTasksCountInMainWindow()
    }
    
    func removeCompletedTasks() {
        for task in self.tasks {
            if task.state == "COMPLETED" {
                self.removeTask(task: task)
            }
        }
        
        self.updateTasksCountInMainWindow()
    }
    
    func removeAllTasks() {
        if let view = self.viewManager {
            for task in self.tasks {
                view.stopTask(task: task)
                self.removeTask(task: task)
            }
        }
        
        self.updateTasksCountInMainWindow()
    }
    
    func printAll() {
        self.logger.log(.trace, "===================================")
        self.logger.log(.trace, "Listing all tasks ...")
        for task in tasks {
            self.logger.log(task.toString())
        }
        self.logger.log(.trace, "===================================")
    }
    
}

// MARK: - MOCK UP FOR TESTING

class FakeTaskletManager {
    
    let logger = LoggerFactory.get(category: "FakeTaskletManager", includeTypes: [])
    
    static let `default` = FakeTaskletManager()
    
    var fakeTasks:[String:Timer] = [:]
    
    func stubJob(taskId:String) {
        var n = 1
        let total = 10
        TaskletManager.default.setTotal(id: taskId, total: total)
        while(n <= total) {
            if TaskletManager.default.isTaskStopped(id: taskId) == true {
                self.logger.log(.debug, "stopped !!!!!!!")
                return
            }
            sleep(3)
            self.logger.log(.debug, "doing step \(n)")
            TaskletManager.default.updateProgress(id: taskId, message: "Doing step \(n)", increase: true)
            
            n += 1
        }
    }
    
    func stubFixedDelayJob(task:Tasklet) {
        self.logger.log(.debug, ">>>>> start fixed delay body - \(task.name) - \(task.state)")
        
        var n = 0
        while(n < 10){
            
            if TaskletManager.default.isTaskStopped(id: task.id) {
                self.logger.log(.debug, "stopped fixed delay job body !!!!")
                return
            }
            
            self.logger.log(.debug, "running fixed delay body - \(task.name) - \(task.state)")
            TaskletManager.default.updateProgress(type: "TEST", name: "test5234", message: "\(Date()) running fixed delay body step \(n+1)", increase: true)
            
            sleep(5)
            
            n += 1
        }
    }
    
    func stubFixedDelayJob1(task:Tasklet) {
        self.logger.log(.debug, ">>>>> start fixed delay body - \(task.name) - \(task.state)")
        
        var n = 0
        while(n < 10){
            
            if TaskletManager.default.isTaskStopped(id: task.id) {
                self.logger.log(.debug, "stopped fixed delay job body !!!!")
                return
            }
            
            self.logger.log(.debug, "running fixed delay body - \(task.name) - \(task.state)")
            TaskletManager.default.updateProgress(type: "TEST", name: "test1234", message: "\(Date()) running fixed delay body step \(n+1)", increase: true)
            
            sleep(5)
            
            n += 1
        }
    }
    
    func rehearsal() {
        self.logger.log(.debug, "task manager rehearsal")
        
        let _ = TaskletManager.default.createAndStartTask(type: "TEST", name: "test4234", exec: { task in
            DispatchQueue.global().async {
                self.stubJob(taskId: task.id)
            }
        }, stop: {task in

        })
//
//        let _ = TaskletManager.default.createAndStartFixedDelayTask(type: "TEST", name: "test5234", total: 10, intervalInSecond: 5, exec: { task in
//            self.stubFixedDelayJob(task: task)
//
//        }, stop: {task in
//
//        })
//
//        let _ = TaskletManager.default.createAndStartFixedDelayTask(type: "TEST", name: "test1234", total: 10, intervalInSecond: 5, exec: { task in
//            self.stubFixedDelayJob1(task: task)
//
//        }, stop: {task in
//
//        })
        
//        let _ = TaskletManager.default.createAndStartTask(type: "TEST", name: "test2234", total: 10, exec: { task in
//            let timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
//                if TaskletManager.default.isTaskStopped(id: task.id) {
//                    return
//                }
//                TaskletManager.default.updateProgress(type: "TEST", name: "test2234", message: "\(Date()) 2 changing", increase: true)
//            })
//            self.fakeTasks[task.id] = timer
//        }, stop: {task in
//            if let timer = self.fakeTasks[task.id] {
//                timer.invalidate()
//            }
//        })
    }
}
