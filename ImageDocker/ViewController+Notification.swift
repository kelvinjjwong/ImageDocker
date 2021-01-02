//
//  ViewControllerUtils.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/1/9.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    // legacy
    func createNotificationPopover(message:String){
        var myPopover = self.notificationPopover
        if(myPopover == nil){
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 600, height: 150))
            self.notificationViewController = NotificationViewController()
            self.notificationViewController.view.frame = frame
            
            myPopover = NSPopover()
            myPopover!.contentViewController = self.notificationViewController
            myPopover!.appearance = NSAppearance(named: .aqua)!
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.notificationPopover = myPopover
        self.notificationViewController.lblMessage.stringValue = message
    }
    
    // legacy
    func popoverNotification(message:String) {
        let currentMouseLocation = NSEvent.mouseLocation
        let posX = currentMouseLocation.x
        let posY = currentMouseLocation.y
        
        self.createNotificationPopover(message: message)
        let invisibleWindow = NSWindow(contentRect: NSMakeRect(0, 0, 20, 5), styleMask: .borderless, backing: .buffered, defer: false)
        invisibleWindow.backgroundColor = .red
        invisibleWindow.alphaValue = 0
        
        invisibleWindow.setFrameOrigin(NSPoint(x: posX, y: posY))
        invisibleWindow.makeKeyAndOrderFront(self)
        
        self.notificationPopover?.show(relativeTo: invisibleWindow.contentView!.frame, of: invisibleWindow.contentView!, preferredEdge: .maxY)
    }
    
    func popNotification(message:String){
        DispatchQueue.main.async {
            self.btnAlertMessage.title = message
            self.btnAlertMessage.isHidden = false
        }
    }
    
    func hideNotification() {
        self.btnAlertMessage.isHidden = true
    }
    
    
}
