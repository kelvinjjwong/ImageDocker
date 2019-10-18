//
//  ViewController+Memories.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/10/12.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {

    /// open a window to display pictures taken in last years
    internal func showMemories() {
        let years = ModelStore.default.getYearsByTodayInPrevious()
        guard years.count > 0 else {return}
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "MemoriesViews"), bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "MemoriesViewController")) as! MemoriesViewController
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 900
        let windowHeight = 1000
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = "Today in Previous Years"
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.initView { (year, month, day) in
            self.selectMomentsTreeEntry(year: year, month: month, day: day, pageSize: 0, pageNumber: 0)
        }
    }

}
