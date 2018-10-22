//
//  CustomRowView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/10/19.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class CustomRowView: NSTableRowView {
    
    override func drawSelection(in dirtyRect: NSRect) {
        NSColor.systemBlue.set()
        __NSRectFill(dirtyRect)
    }
}
