//
//  ProgresViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/4.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class ProgressViewController : NSViewController {
    
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var btnStop: NSButton!
    @IBOutlet weak var box: NSBox!
    
    init() {
        super.init(nibName: "ProgressViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var id = ""
    var message = ""
    var onStop: (() -> Void)? = nil
    var onComplete: (() -> Void)? = nil
    var isNoTask = false
    
    func noTask() {
        self.id = "No task"
        self.message = "No task is running now."
        self.isNoTask = true
    }
    
    func initView(id:String, message:String,
                  onStop: (() -> Void)? = nil, onComplete: (() -> Void)? = nil){
        self.id = id
        self.message = message
        self.onStop = onStop
        self.onComplete = onComplete
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.box.title = self.id
        self.lblMessage.stringValue = self.message
        if self.isNoTask {
            self.progress.isHidden = true
            self.btnStop.isHidden = true
        }
        
    }
    
    @IBAction func onStopClicked(_ sender: NSButton) {
        if self.onStop != nil {
            self.onStop!()
        }
    }
    
}
