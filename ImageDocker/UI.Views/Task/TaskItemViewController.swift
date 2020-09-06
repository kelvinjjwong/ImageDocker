//
//  TaskItemViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/9/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

class TaskItemViewController : NSViewController {
    
    @IBOutlet weak var lblTaskType: NSTextField!
    @IBOutlet weak var lblTaskId: NSTextField!
    @IBOutlet weak var lblTaskMessage: NSTextField!
    

    var onPauseResume: (() -> Void)? = nil
    
    var onCancel: (() -> Void)? = nil

    init() {
        super.init(nibName: "TaskItemViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.wantsLayer = true
        self.refreshFields()
    }
    
    private func refreshFields() {
    }
    
    func initView(task:Tasklet, onPauseResume: (() -> Void)? = nil, onCancel: (() -> Void)? = nil){
        self.onPauseResume = onPauseResume
        self.onCancel = onCancel
        self.lblTaskType.stringValue = task.type.uppercased()
        self.lblTaskId.stringValue = task.name
//        self.refreshFields()
    }
    
    func updateMessage(_ message:String){
        self.refreshFields()
    }
    
    @IBAction func onPauseResumeClicked(_ sender: NSButton) {
    }
    
    @IBAction func onCancelClicked(_ sender: NSButton) {
    }
    
}
