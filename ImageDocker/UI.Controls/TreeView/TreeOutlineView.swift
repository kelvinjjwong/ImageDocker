//
//  TreeOutlineView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/12/31.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

protocol TreeOutlineViewDelegate {
    
    func onClicked(row:Int, item:Any?)
}

class TreeOutlineView : NSOutlineView {
    
    var clickDelegate:TreeOutlineViewDelegate?
    
    func  outlineView(_ outlineView: NSOutlineView, didClickTableRow item: Any?, row:Int) {
        if let cd = clickDelegate {
            cd.onClicked(row: row, item: item)
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let globalLocation:NSPoint  = theEvent.locationInWindow
        let localLocation:NSPoint  = self.convert(globalLocation, from: nil)
        let clickedRow:Int = self.row(at: localLocation)

        super.mouseDown(with:theEvent)

        if (clickedRow != -1) {
            self.outlineView(self, didClickTableRow: self.item(atRow: clickedRow), row: clickedRow)
        }else{
//            self.logger.log("out of range")
        }
    }
}
