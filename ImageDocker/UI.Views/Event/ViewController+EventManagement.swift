//
//  ViewController+EventManagement.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/10/20.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    func createEventPopover(){
        var myPopover = self.eventPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 1150, height: 420))
            self.eventViewController = EventListViewController()
            self.eventViewController.view.frame = frame
            self.eventViewController.refreshDelegate = self
            
            myPopover!.contentViewController = self.eventViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.eventPopover = myPopover
    }
    
}

// from SelectionViewController (ViewController+SelectionArea+AssignEvent.swift)
extension ViewController : EventListRefreshDelegate{
    
    func refreshEventList() {
        
    }
    
    func selectEvent(event: ImageEvent) {
        
    }
    
    
}
