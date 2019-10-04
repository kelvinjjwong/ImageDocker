//
//  ViewController+Progress.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    @objc func taskletObserver(notification:Notification) {
        if let obj = notification.object {
            if let tasklet = obj as? Tasklet {
                DispatchQueue.main.async {
                    self.lblProgressMessage.stringValue = "\(tasklet.name): \(tasklet.progress) / \(tasklet.total)"
                }
                if tasklet.progress == tasklet.total {
                    DispatchQueue.main.async {
                        self.lblProgressMessage.stringValue = ""
                        self.btnStop.isHidden = true
                    }
                    self.runningFaceTask = false
                    self.stopFacesTask = false
                    tasklet.removeObserver(self)
                }
            }
            
        }
    }
    
    internal func createTaskProgressPopover(){
        var myPopover = self.taskProgressPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 650, height: 200))
            self.taskProgressViewController = TaskProgressViewController()
            self.taskProgressViewController.view.frame = frame
            
            myPopover!.contentViewController = self.taskProgressViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.taskProgressPopover = myPopover
    }
    
    internal func popTasks(_ sender:NSButton) {
        self.createTaskProgressPopover()
        
        let cellRect = sender.bounds
        self.taskProgressPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
}
