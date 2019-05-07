//
//  TaskHelper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/5/7.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class Tasklet {
    
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
    
    init(_ name:String) {
        self.id = UUID().uuidString
        self.taskid = "TASKLET_\(id)"
        self.name = name
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
    
    func task(name:String) -> Tasklet {
        var t:Tasklet? = nil
        for task in tasks {
            if task.name == name {
                t = task
                break
            }
        }
        if t == nil {
            t = Tasklet(name)
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
