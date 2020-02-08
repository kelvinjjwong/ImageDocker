//
//  DropPlaceDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/25.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import AppKit
import AVKit

protocol DropPlaceDelegate {
    func dropURLs(_ urls: [URL])
}

class DropPlace {
    static fileprivate let lineWidth: CGFloat = 10.0
    
    static fileprivate var imagesTypes:[String] = [String]()
    
    static let pasteboardTypes:[NSPasteboard.PasteboardType] = [NSPasteboard.PasteboardType.fileURL]
    
    static var acceptTypes:[String]{
        if imagesTypes.count > 0 {return imagesTypes}
        for s in NSImage.imageTypes {
            imagesTypes.append(s)
        }
        for s in AVMovie.movieTypes() {
            imagesTypes.append(s.rawValue)
        }
        return imagesTypes
    }
    
    static func drawBounds(_ view:NSView){
        NSColor.selectedControlColor.set()
        
        let path = NSBezierPath(rect: view.bounds)
        path.lineWidth = lineWidth
        path.stroke()
    }
    
    static func allow(_ draggingInfo: NSDraggingInfo) -> Bool {
        var canAccept = false
        let pasteBoard = draggingInfo.draggingPasteboard
        let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes : DropPlace.acceptTypes]
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            canAccept = true
        }
        return canAccept
    }
    
    static func read(_ draggingInfo: NSDraggingInfo) -> [URL] {
        let pasteBoard = draggingInfo.draggingPasteboard
        let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes: DropPlace.acceptTypes]
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: filteringOptions) as? [URL], urls.count > 0 {
            return urls
        }
        return [URL]()
    }
}
