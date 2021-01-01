//
//  ViewController+Window.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    
    internal func resize() {
        guard !windowInitial else {return}
        let size = UIHelper.windowSize()
        
        let windowSize = NSMakeSize(size.width, size.height)
        let windowMinSize = NSMakeSize(CGFloat(600), CGFloat(500))
        let windowMaxSize = NSMakeSize(size.widthMax, size.heightMax - CGFloat(5))
        
        var windowFrame = self.view.window?.frame
        windowFrame?.size = windowSize
        windowFrame?.origin = size.originPoint
        self.view.window?.maxSize = windowMaxSize
        self.view.window?.minSize = windowMinSize
        self.view.window?.setFrame(windowFrame!, display: true)
        
        splashController.view.frame = self.view.bounds
        
        smallScreen = size.isSmallScreen
        
        if size.isSmallScreen {
            self.hideSelectionBatchEditors()
            self.btnBatchEditorToolbarSwitcher.image = NSImage(named: NSImage.goRightTemplateName)
            self.btnBatchEditorToolbarSwitcher.toolTip = "Show event/datetime selectors"
            
            let constraintPlayerHeight = NSLayoutConstraint(item: self.playerContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 258)
            self.playerContainer.addConstraint(constraintPlayerHeight)
            self.playerContainer.setFrameSize(NSMakeSize(CGFloat(575), CGFloat(258)))
            self.playerContainer.display()
            
            self.splitviewPreview.setPosition(size.height - CGFloat(565), ofDividerAt: 0)
        }else {
            print("BIG SCREEN")
            let constraintPlayerHeight = NSLayoutConstraint(item: self.playerContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 408)
            self.playerContainer.addConstraint(constraintPlayerHeight)
            self.playerContainer.setFrameSize(NSMakeSize(CGFloat(575), CGFloat(408)))
            self.playerContainer.display()
            
            self.splitviewPreview.setPosition(size.height - CGFloat(745), ofDividerAt: 0)
        }
        
        windowInitial = true
    }
}



// MARK: - WINDOW CONTROLLER
extension ViewController : NSWindowDelegate {
    
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self)
    }
}
