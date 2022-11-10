//
//  ViewController+Window.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func resize(width:CGFloat = 600, height:CGFloat = 500) {
        guard !windowInitial else {return}
        let size = UIHelper.windowSize()
        
        let windowSize = NSMakeSize(size.width, size.height)
        let windowBounds = NSRect(x: 0, y: 0, width: width, height: height)
        let windowMinSize = NSMakeSize(CGFloat(600), CGFloat(500))
        let windowMaxSize = NSMakeSize(size.widthMax, size.heightMax - CGFloat(5))
        
//        self.view.window?.setFrame(windowBounds, display: true)
//        self.view.setFrameOrigin(windowBounds.origin)
//        self.view.setFrameSize(windowBounds.size)
//        self.view.setBoundsOrigin(windowBounds.origin)
//        self.view.setBoundsSize(windowBounds.size)
        
//        self.view.window?.setFrame(windowBounds, display: true)
//        self.view.setFrameSize(windowBounds.size)
        
        smallScreen = size.isSmallScreen
        
        if size.isSmallScreen {
            
            var windowFrame = self.view.window?.frame
            windowFrame?.size = windowSize
            windowFrame?.origin = size.originPoint
            self.view.window?.maxSize = windowMaxSize
            self.view.window?.minSize = windowMinSize
            self.view.window?.setFrame(windowFrame!, display: true)
            
            splashController.view.frame =  self.view.bounds
            
            self.selectionViewController.hideSelectionBatchEditors()
            self.selectionViewController.btnBatchEditorToolbarSwitcher.image = NSImage(named: NSImage.goRightTemplateName)
            self.selectionViewController.btnBatchEditorToolbarSwitcher.toolTip = "Show event/datetime selectors"
            
            if let _ = self.playerContainer {
                let constraintPlayerHeight = NSLayoutConstraint(item: self.playerContainer!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 258)
                self.playerContainer.addConstraint(constraintPlayerHeight)
                self.playerContainer.setFrameSize(NSMakeSize(CGFloat(575), CGFloat(258)))
                self.playerContainer.display()
            }
        }else {
            self.logger.log("BIG SCREEN \(windowBounds)")
            
            splashController.view.frame = self.view.bounds
            
            if let _ = self.playerContainer {
                let constraintPlayerHeight = NSLayoutConstraint(item: self.playerContainer!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 403)
                self.playerContainer.addConstraint(constraintPlayerHeight)
                self.playerContainer.setFrameSize(NSMakeSize(CGFloat(575), CGFloat(403)))
                self.playerContainer.display()
            }
        }
        
        self.resizePreviewHoriztontalDivider()
        
        windowInitial = true
    }
    
    internal func resizePreviewHoriztontalDivider() {
        let size = UIHelper.windowSize()
        if size.isSmallScreen {
            self.splitviewPreview.setPosition(size.height - CGFloat(565), ofDividerAt: 0)
        }else{
            self.splitviewPreview.setPosition(size.height - CGFloat(805), ofDividerAt: 0)
        }
    }
}



// MARK: - WINDOW CONTROLLER
extension ViewController : NSWindowDelegate {
    
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self)
    }
}
