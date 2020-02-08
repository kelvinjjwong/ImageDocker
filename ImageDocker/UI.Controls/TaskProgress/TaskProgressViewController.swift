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
    
    var tasks:[String] = []
    // TODO: maintenance tasks' progress centralized
    

    // run only once
    override func viewDidLoad() {
        super.viewDidLoad()
        print("popover did load")
        view.wantsLayer = true
        stackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        self.addTaskProgress(id: "task 1", message: "in progress")
        self.addTaskProgress(id: "task 2", message: "in progress")
        self.addTaskProgress(id: "task 3", message: "in progress")
        self.addTaskProgress(id: "task 4", message: "in progress")
    }
    
    func addNoTaskNotice() {
        let storyboard = NSStoryboard(name: "TaskProgressStackItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "TaskProgress") as! ProgressViewController
        viewController.noTask()
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
    }
    
    /// Used to add a particular view controller as an item to our stack view.
    func addTaskProgress(id:String, message:String) {
        
        if self.tasks.count == 0 && self.stackView.views.count > 0 {
            let noTask = self.stackView.views[0]
            self.stackView.removeView(noTask)
        }
        
        let storyboard = NSStoryboard(name: "TaskProgressStackItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "TaskProgress") as! ProgressViewController
        
        viewController.initView(id: id, message: message,
                                onStop: {
                                    self.tasks.removeAll(where: { (key) -> Bool in
                                        return key == id
                                    })
                                    NSLayoutConstraint.deactivate(viewController.view.constraints)
                                    self.stackView.removeView(viewController.view)
                                    
                                    if self.tasks.count == 0 {
                                        self.addNoTaskNotice()
                                    }
                                }, onComplete: {
                                    
                                })
        self.tasks.append(id)
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
        
    }
    
}
