//
//  MenuPopover.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/12.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

/// Popover + TableView + Clickable, support up to 3 table-columns
/// Steps (1) init with onClick (2) load (3) show
class MenuPopover : NSObject, NSPopoverDelegate {
    
    fileprivate var popover:NSPopover!
    fileprivate var viewController:OneColumnTableViewController!
    
    init(width:Int = 100, height:Int = 100, onClick:@escaping ((String, String, String) -> Void)){
        super.init()
        self.popover = NSPopover()
            
        let frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        self.viewController = OneColumnTableViewController()
        self.viewController.view.frame = frame
        self.viewController.onClick = onClick
        self.viewController.afterClick = { _, _, _ in
            self.popover.close()
        }
        
        self.popover.contentViewController = self.viewController
        //self.popover.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
        //myPopover!.animates = true
        self.popover.delegate = self
        self.popover.behavior = NSPopover.Behavior.transient
    }
    
    func load(_ items:[String]){
        self.viewController.load(items)
    }
    
    func load(_ items:[(String, String)]){
        self.viewController.load(items)
    }
    
    func load(_ items:[(String, String, String)]){
        self.viewController.load(items)
    }
    
    func show(_ sender:NSButton){
        let cellRect = sender.bounds
        self.popover.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
}

class TwoColumnMenuPopover : NSObject, NSPopoverDelegate {
    
    fileprivate var popover:NSPopover!
    fileprivate var viewController:TwoColumnTableViewController!
    
    init(width:Int = 100, height:Int = 100, onClick:@escaping ((String, String, String) -> Void)){
        super.init()
        self.popover = NSPopover()
        
        let frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        self.viewController = TwoColumnTableViewController()
        self.viewController.view.frame = frame
        self.viewController.onClick = onClick
        self.viewController.afterClick = { _, _, _ in
            self.popover.close()
        }
        
        self.popover.contentViewController = self.viewController
        //self.popover.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
        //myPopover!.animates = true
        self.popover.delegate = self
        self.popover.behavior = NSPopover.Behavior.transient
    }
    
    func load(_ items:[String]){
        self.viewController.load(items)
    }
    
    func load(_ items:[(String, String)]){
        self.viewController.load(items)
    }
    
    func load(_ items:[(String, String, String)]){
        self.viewController.load(items)
    }
    
    func show(_ sender:NSButton){
        let cellRect = sender.bounds
        self.popover.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
}
