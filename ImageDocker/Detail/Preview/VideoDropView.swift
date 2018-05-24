//
//  VideoDropView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/25.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import AppKit
import AVFoundation
import AVKit

class VideoDropView: AVPlayerView {
    
    var dropDelegate: DropPlaceDelegate?
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override func awakeFromNib() {
        registerForDraggedTypes(DropPlace.pasteboardTypes)
        super.awakeFromNib()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isReceivingDrag {
            DropPlace.drawBounds(self)
        }
        super.draw(dirtyRect)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = DropPlace.allow(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = DropPlace.allow(sender)
        return allow
    }
    
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        isReceivingDrag = false
        let urls:[URL] = DropPlace.read(draggingInfo)
        if urls.count > 0 {
            dropDelegate?.dropURLs(urls)
            return true
        }
        return false
    }
}
