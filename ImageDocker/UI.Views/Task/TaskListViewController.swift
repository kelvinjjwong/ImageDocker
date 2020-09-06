//
//  TaskListViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/9/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

class TaskListViewController: NSViewController {
    
    @IBOutlet weak var stackView: CustomStackView!
    
    var stackItems:[String:TaskItemViewController] = [:]
    
    // MARK: - INIT VIEW
    
    init() {
        super.init(nibName: "TaskListViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        stackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        self.loadStackItems()
    }
    
    private func loadStackItems() {
        let tasks = TaskletManager.default.tasks
        for task in tasks {
            self.addTaskItem(task)
        }
    }
    
    // MARK: - STACK ITEMS
    
    /// Used to add a particular view controller as an item to our stack view.
    func addTaskItem(_ task:Tasklet) {
        
        let storyboard = NSStoryboard(name: "TaskStackItems", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "TaskItem") as! TaskItemViewController
        
        viewController.initView(task: task,
                                onPauseResume: {
                                    //
        }, onCancel: {
            //
        })
        
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
        
        self.stackItems[task.id] = viewController
        
    }
    
}
