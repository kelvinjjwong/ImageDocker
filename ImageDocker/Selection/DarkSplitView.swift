//
//  DarkSplitView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/27.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class DarkSplitView : NSSplitView {
    
    override var dividerColor: NSColor {
        return NSColor(calibratedWhite: 0.3, alpha: 1)
    }
}
