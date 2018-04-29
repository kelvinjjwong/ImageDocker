//
//  PrimaryViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

let kAddFolderNotification = "AddFolderNotification"
let kRemoveFolderNotification = "RemoveFolderNotification"

class PrimaryViewController : NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(selectionDidChange), name: Notification.Name("NSOutlineViewSelectionDidChangeNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentReceived), name: Notification.Name("kReceivedContentNotification"), object: nil)
    }
    
    @objc func contentReceived(_ notif:NSNotification) {
        // hide progress indicator
    }
    
    @objc func selectionDidChange(_ notification:NSNotification) {
        let outlineView:NSOutlineView = notification.object as! NSOutlineView
        let selectedRow:Int = outlineView.selectedRow
        if selectedRow == -1 {
            // disable remove button
            // clear url
        }else{
            // enable remove button
            let item:BaseNode = outlineView.item(atRow: selectedRow) as! BaseNode
            if item.isBookmark() {
                // print url.absoluteString or empty
            }else{
                // print url.path or empty
            }
            
            if item.isDirectory() {
                // enable progress indicator
            }
        }
    }
}

