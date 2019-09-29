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
}
