//
//  DarkTableView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/24.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

public class DarkTableView: NSTableView {
    
    var bgColor: NSColor = NSColor.gray
    var alternateBackgroundColor: NSColor = NSColor.darkGray
    
    public override func drawBackground(inClipRect clipRect: NSRect) {
        
        super.drawBackground(inClipRect: clipRect)
        
        guard usesAlternatingRowBackgroundColors else { return }
        
        drawTopAlternatingBackground(inClipRect: clipRect)
        drawBottomAlternatingBackground(inClipRect: clipRect)
    }
    
    fileprivate func drawTopAlternatingBackground(inClipRect clipRect: NSRect) {
        
        guard clipRect.origin.y < 0 else { return }
        
        let backgroundColor = self.bgColor
        let alternateColor = self.alternateBackgroundColor
        
        let rectHeight = rowHeight + intercellSpacing.height
        let minY = NSMinY(clipRect)
        var row = 0
        
        while true {
            
            if row % 2 == 0 {
                backgroundColor.setFill()
            } else {
                alternateColor.setFill()
            }
            
            let rowRect = NSRect(
                x: 0,
                y: (rectHeight * CGFloat(row) - rectHeight),
                width: NSMaxX(clipRect),
                height: rectHeight)
            __NSRectFill(rowRect)
            
            if rowRect.origin.y < minY { break }
            
            row -= 1
        }
    }
    
    fileprivate func drawBottomAlternatingBackground(inClipRect clipRect: NSRect) {
        
        let backgroundColor = self.bgColor
        let alternateColor = self.alternateBackgroundColor
        
        let rectHeight = rowHeight + intercellSpacing.height
        let maxY = NSMaxY(clipRect)
        var row = rows(in: clipRect).location
        
        while true {
            
            if row % 2 == 1 {
                backgroundColor.setFill()
            } else {
                alternateColor.setFill()
            }
            
            let rowRect = NSRect(
                x: 0,
                y: (rectHeight * CGFloat(row)),
                width: NSMaxX(clipRect),
                height: rectHeight)
            __NSRectFill(rowRect)
            
            if rowRect.origin.y > maxY { break }
            
            row += 1
        }
    }
}
