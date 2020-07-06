//
//  MomentsTree+ExtendView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/7/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    func createMomentsTreeHeaderMoreViewPopover(){
        var myPopover = self.momentsTreeHeaderMoreViewPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 160, height: 60))
            self.momentsTreeHeaderMoreViewController = MomentsTreeHeaderMoreViewController(onReload: {
                DispatchQueue.main.async {
                    
                    if self.momentsTreeCategory == "MOMENTS" {
                        self.stackedTreeView.reloadTree("Moments")
                    }else if self.momentsTreeCategory == "EVENTS" {
                        self.stackedTreeView.reloadTree("Events")
                    }else if self.momentsTreeCategory == "PLACES" {
                        self.stackedTreeView.reloadTree("Places")
                    }
                }
            })
            self.momentsTreeHeaderMoreViewController.view.frame = frame
            
            myPopover!.contentViewController = self.momentsTreeHeaderMoreViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.momentsTreeHeaderMoreViewPopover = myPopover
    }
    
    func openMomentsTreeHeaderExtendView(sender:NSButton) {
        createMomentsTreeHeaderMoreViewPopover()
        
        let cellRect = sender.bounds
        self.momentsTreeHeaderMoreViewPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
    }
}
