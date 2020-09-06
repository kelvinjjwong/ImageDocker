//
//  TaskProgressViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/4.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class TaskProgressViewController: NSViewController {
    
    @IBOutlet weak var stackView: NSStackView!
    
    init() {
        super.init(nibName: "TaskProgressViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var tasks:[Tasklet] = []
    var tasksView:[String:ProgressViewController] = [:]
    var tasksState:[String:String] = [:]
    
    // run only once
    override func viewDidLoad() {
        super.viewDidLoad()
        print("popover did load")
        view.wantsLayer = true
        stackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        self.addNoTaskNotice()
        
        TaskletManager.default.bindToView(view: self).loadTasks()
    }
    
    func addNoTaskNotice() {
        let storyboard = NSStoryboard(name: "TaskProgressStackItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "TaskProgress") as! ProgressViewController
        viewController.noTask()
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
    }
    
    /// Used to add a particular view controller as an item to our stack view.
    func addTask(task:Tasklet) {
        
        if self.tasks.count == 0 && self.stackView.views.count > 0 {
            let noTask = self.stackView.views[0]
            self.stackView.removeView(noTask)
        }
        
        let storyboard = NSStoryboard(name: "TaskProgressStackItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "TaskProgress") as! ProgressViewController
        
        viewController.initView(task: task,
                                onStop: {
                                    if let state = self.tasksState[task.id] {
                                        if state == "STOPPED" {
                                            self.restartTask(task: task)
                                            return
                                        }
                                    }
                                    self.stopTask(task: task)
                                }, onComplete: {
                                    self.onTaskComplete(task: task)
                                })
        self.tasks.append(task)
        self.tasksView[task.id] = viewController
        self.tasksState[task.id] = "READY"
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
    }
    
    func onTaskComplete(task:Tasklet) {
        self.tasksState[task.id] = "COMPLETED"
        print("TaskProgressViewController: task \(task.id) completed")
    }
    
    func stopTask(task:Tasklet) {
        task.stopExecution()
        if let viewController = self.tasksView[task.id] {
            viewController.btnStop.title = "RESTART"
            viewController.btnStop.image = Icons.play
        }
        self.tasksState[task.id] = "STOPPED"
        print("TaskProgressViewController: task \(task.id) stopped")
    }
    
    func restartTask(task:Tasklet) {
        if let viewController = self.tasksView[task.id] {
            viewController.btnStop.title = "STOP"
            viewController.btnStop.image = NSImage(named: NSImage.stopProgressFreestandingTemplateName)
            
            viewController.progress.doubleValue = 0
        }
        self.tasksState[task.id] = "READY"
        print("TaskProgressViewController: task \(task.id) restarted")
        task.startExecution()
    }
    
    func removeTask(task:Tasklet) {
        self.tasks.removeAll(where: { (obj) -> Bool in
            return obj.id == task.id
        })
        
        if let viewController = self.tasksView[task.id] {
            NSLayoutConstraint.deactivate(viewController.view.constraints)
            self.stackView.removeView(viewController.view)
        }
        
        if self.tasks.count == 0 {
            self.addNoTaskNotice()
        }
    }
    
    func updateTask(task:Tasklet) {
        if let state = self.tasksState[task.id] {
            if state == "COMPLETED" || state == "STOPPED" {
                return
            }
        }

        self.tasksState[task.id] = "IN_PROGRESS"
        if let viewController = self.tasksView[task.id] {
            viewController.lblMessage.stringValue = task.message
            if task.total > 0 && task.progress <= task.total {
                viewController.progress.increment(by: 1)
                if viewController.progress.doubleValue == viewController.progress.maxValue {
                    viewController.btnStop.title = "COMPLETED"
                    viewController.btnStop.image = nil
                    viewController.btnStop.isEnabled = false

                    self.tasksState[task.id] = "COMPLETED"
                }
            }
        }
    }
    
    func setTotal(task:Tasklet, total:Int) {
        if let viewController = self.tasksView[task.id] {
            viewController.progress.maxValue = Double(total)
            viewController.progress.minValue = 0
        }
    }
    
}
