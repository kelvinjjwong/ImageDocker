//
//  ViewController+NotificationMessage.swift
//  ImageDocker
//
//  Created by Kelvin JJ Wong on 2023/4/16.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    @objc func notificationMessageObserver(notification:Notification) {
        if let obj = notification.object {
            if let notificationMessage = obj as? NotificationMessage {
//                DispatchQueue.main.async {
//                    // do to
                self.logger.log("notificationMessageObserver: \(notificationMessage.id)")
//                }
            }
            
        }
    }
    
    internal func createNotificationsPopover(){
        var myPopover = self.notificationMessagesPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 650, height: 300))
            self.notificationMessageViewController = NotificationMessageViewController()
            self.notificationMessageViewController.view.frame = frame
            
            myPopover!.contentViewController = self.notificationMessageViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.notificationMessagesPopover = myPopover
    }
    
    internal func popNotifications(_ sender:NSButton) {
        self.createNotificationsPopover()
        
        let cellRect = sender.bounds
        self.notificationMessagesPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
        self.notificationMessageViewController.onPopoverShow()
    }
}
