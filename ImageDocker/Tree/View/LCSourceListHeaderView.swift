//
//  LCSourceListHeaderView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/1/10.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList

class MenuAction {
    
    var title:String = ""
    var action: (() -> Void)
    
    init(title:String, action: @escaping (() -> Void)) {
        self.title = title
        self.action = action
    }
}

class LCSourceListHeaderView : PXSourceListTableCellView {
    
    @IBOutlet weak var btnMore: NSButton!
    var buttonShouldShow = false
    
    var buttonAction: ((_ sender:NSButton) -> Void)? = nil
    
    func setUpTrackingArea()
    {
        let trackingArea = NSTrackingArea(rect: self.frame, options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeAlways], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    override func layout(){
        super.layout()
        setUpTrackingArea()
    }
    
    override func viewWillDraw() {
    }
    
    @IBAction func onMoreClicked(_ sender: NSButton) {
        if self.buttonAction != nil {
            self.buttonAction!(sender)
        }
    }
    
    override func mouseEntered(with: NSEvent) {
        if self.buttonShouldShow {
            self.btnMore.isHidden = false
        }
    }
    
    override func mouseExited(with: NSEvent) {
        if self.buttonShouldShow {
            self.btnMore.isHidden = true
        }
    }
    
    
    
}
