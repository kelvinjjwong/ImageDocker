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
    @IBOutlet weak var btnStopAll: NSButton!
    @IBOutlet weak var btnRemoveAll: NSButton!
    @IBOutlet weak var btnRemoveCompleted: NSButton!
    
    init() {
        super.init(nibName: "TaskProgressViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var tasks:[Tasklet] = []
    var tasksView:[String:ProgressViewController] = [:]
    
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
    func addTask(task:Tasklet) -> Bool {
        
        if let _ = self.tasksView[task.id] {
            return false
        }
        
        if self.tasks.count == 0 && self.stackView.views.count > 0 {
            let noTask = self.stackView.views[0]
            self.stackView.removeView(noTask)
        }
        
        let storyboard = NSStoryboard(name: "TaskProgressStackItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "TaskProgress") as! ProgressViewController
        
        viewController.initView(task: task,
                                onStop: {
                                    print("onStop - \(task.name) - \(task.state) - \(task.isFixedDelayJob)")
                                    if task.state == "STOPPED" {
                                        self.restartTask(task: task)
                                        return
                                    }
                                    self.stopTask(task: task)
                                }, onComplete: {
                                    self.onTaskComplete(task: task)
                                })
        self.tasks.append(task)
        self.tasksView[task.id] = viewController
        //task.state = "READY"
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
        viewController.progress.isHidden = true
        return true
    }
    
    func onTaskComplete(task:Tasklet) {
        //task.state = "COMPLETED"
        print("TaskProgressViewController: task \(task.id) completed")
    }
    
    func stopTask(task:Tasklet) {
        if let viewController = self.tasksView[task.id] {
            viewController.btnStop.title = "RESTART"
            viewController.btnStop.image = Icons.play
        }
        //task.state = "STOPPED"
        TaskletManager.default.stopTask(id: task.id, fromUI: true)
        print("TaskProgressViewController: task \(task.id) stopped")
    }
    
    func updatePanelForRestartTask(task:Tasklet) {
        if let viewController = self.tasksView[task.id] {
            DispatchQueue.main.async {
                
                viewController.btnStop.title = "STOP"
                viewController.btnStop.image = NSImage(named: NSImage.stopProgressFreestandingTemplateName)
                viewController.btnStop.isEnabled = true
                
                viewController.progress.doubleValue = 0
                
                if !TaskletManager.default.isSingleMode() {
                    viewController.lblMessage.stringValue = "Restarting ..."
                }            }
        }
    }
    
    func restartTask(task:Tasklet) {
        self.updatePanelForRestartTask(task: task)
        print("TaskProgressViewController: task \(task.id) restarted")
        if task.isFixedDelayJob {
            TaskletManager.default.startFixedDelayExecution(id: task.id)
        }else{
            TaskletManager.default.startExecution(id: task.id)
        }
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
        
        self.tasksView.removeValue(forKey: task.id)
    }
    
    func updateMessage(task:Tasklet) {
        if let viewController = self.tasksView[task.id] {
            DispatchQueue.main.async {
                viewController.lblMessage.stringValue = task.message
            }
        }
    }
    
    func updateTask(task:Tasklet) {
        if task.state == "STOPPED" {
            return
        }
        
        if let viewController = self.tasksView[task.id] {
            
            viewController.lblMessage.stringValue = task.message
            viewController.box.title = "\(task.type): \(task.name) - \(task.state)"
            

            if task.state == "COMPLETED" {
                if viewController.progress.doubleValue != viewController.progress.maxValue {
                    viewController.progress.increment(by: 1)
                }
                if !task.isFixedDelayJob {
                    self.updatePanelForCompletedTask(task: task, viewController: viewController)
                }
            }else if task.state == "IN_PROGRESS" {
                if task.total > 0 {
                    viewController.progress.increment(by: 1)
                }
            }
        }
        
    }
    
    func setComplete(task:Tasklet) {
        if !task.isFixedDelayJob {
            if let viewController = self.tasksView[task.id] {
                self.updatePanelForCompletedTask(task: task, viewController: viewController)
            }
        }
    }
    
    private func updatePanelForCompletedTask(task:Tasklet, viewController:ProgressViewController) {
        viewController.btnStop.title = "COMPLETED"
        viewController.btnStop.image = nil
        viewController.btnStop.isEnabled = false
    }
    
    func setTotal(task:Tasklet, total:Int) {
        if let viewController = self.tasksView[task.id] {
            viewController.progress.maxValue = Double(total)
            viewController.progress.minValue = 0
            viewController.progress.doubleValue = 0
            
            if total > 0 {
                viewController.progress.isHidden = false
            }
        }
    }
    
    func setProgressValue(task:Tasklet, progressValue:Int) {
        if let viewController = self.tasksView[task.id] {
            viewController.progress.doubleValue = Double(progressValue)
        }
    }
    
    @IBAction func onRemoveCompletedClicked(_ sender: NSButton) {
        TaskletManager.default.removeCompletedTasks()
    }
    
    @IBAction func onRemoveAllClicked(_ sender: NSButton) {
        TaskletManager.default.removeAllTasks()
    }
    
    @IBAction func onStopAllClicked(_ sender: NSButton) {
        TaskletManager.default.stopAllTasks()
    }
    
    
}
