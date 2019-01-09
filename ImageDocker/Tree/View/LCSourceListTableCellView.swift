//
//  LCSourceListTableCellView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/29.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList

let badgeTextColor:NSColor = NSColor(calibratedRed: (35/255.0), green: (123/255.0), blue: (246/255.0), alpha: 1)
//let badgeBackgroundColor:NSColor = NSColor(calibratedRed: (152/255.0), green: (168/255.0), blue: (202/255.0), alpha: 1)
let badgeBackgroundColor:NSColor = NSColor(calibratedRed: (255/255.0), green: (255/255.0), blue: (255/255.0), alpha: 0.9)
let badgeHiddenBackgroundColor:NSColor = NSColor(deviceWhite: (180/255.0), alpha: 1)
let badgeSelectedTextColor:NSColor = NSColor.keyboardFocusIndicatorColor
let badgeSelectedUnfocusedTextColor:NSColor = NSColor(calibratedRed: (153/255.0), green: (169/255.0), blue: (203/255.0), alpha: 1)
let badgeSelectedHiddenTextColor:NSColor = NSColor(calibratedWhite: (170/255.0), alpha: 1)

class LCSourceListTableCellView : PXSourceListTableCellView {
    
    @IBOutlet public weak var badge:NSTextField?
    @IBOutlet weak var btnMore: NSButton!
    
    
    override func layout(){
        super.layout()
    }
    
    override func viewWillDraw() {
        if badge != nil {
            badge?.layer?.backgroundColor = NSColor(calibratedWhite: 0.1, alpha: 0.8).cgColor //badgeBackgroundColor.cgColor
            badge?.textColor = NSColor(calibratedWhite: 0.9, alpha: 0.8) // badgeTextColor
            badge?.layer?.cornerRadius = CGFloat(6)
        }
        
    }
    
    @IBAction func onMoreClicked(_ sender: NSButton) {
    }
    
    
}
