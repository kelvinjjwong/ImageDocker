//
//  LCSourceListTableCellView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/29.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList

let badgeBackgroundColor:NSColor = NSColor(calibratedRed: (152/255.0), green: (168/255.0), blue: (202/255.0), alpha: 1)
let badgeHiddenBackgroundColor:NSColor = NSColor(deviceWhite: (180/255.0), alpha: 1)
let badgeSelectedTextColor:NSColor = NSColor.keyboardFocusIndicatorColor
let badgeSelectedUnfocusedTextColor:NSColor = NSColor(calibratedRed: (153/255.0), green: (169/255.0), blue: (203/255.0), alpha: 1)
let badgeSelectedHiddenTextColor:NSColor = NSColor(calibratedWhite: (170/255.0), alpha: 1)

class LCSourceListTableCellView : PXSourceListTableCellView {
    
    @IBOutlet public weak var badge:NSTextField?
    
    override func layout(){
        super.layout()
    }
    
    override func viewWillDraw() {
        if badge != nil {
            badge?.layer?.backgroundColor = badgeBackgroundColor.cgColor
            badge?.layer?.cornerRadius = CGFloat(6)
        }
    }
}
