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
        
        smallScreen = size.isSmallScreen
        
        if size.isSmallScreen {
            self.hideSelectionBatchEditors()
            self.btnBatchEditorToolbarSwitcher.image = NSImage(named: .goRightTemplate)
            self.btnBatchEditorToolbarSwitcher.toolTip = "Show event/datetime selectors"
            
            let constraintPlayerHeight = NSLayoutConstraint(item: self.playerContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 258)
            self.playerContainer.addConstraint(constraintPlayerHeight)
            self.playerContainer.setFrameSize(NSMakeSize(CGFloat(575), CGFloat(258)))
            self.playerContainer.display()
            
            self.splitviewPreview.setPosition(size.height - CGFloat(520) - CGFloat(40), ofDividerAt: 0)
        }else {
            print("BIG SCREEN")
            let constraintPlayerHeight = NSLayoutConstraint(item: self.playerContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 408)
            self.playerContainer.addConstraint(constraintPlayerHeight)
            self.playerContainer.setFrameSize(NSMakeSize(CGFloat(575), CGFloat(408)))
            self.playerContainer.display()
            
            self.splitviewPreview.setPosition(size.height - CGFloat(670) - CGFloat(40) - CGFloat(30), ofDividerAt: 0)
        }
        
        
        splashController.view.frame = self.view.bounds
        
        windowInitial = true
    }
}



// MARK: - WINDOW CONTROLLER
extension ViewController : NSWindowDelegate {
    
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(self)
    }
}
