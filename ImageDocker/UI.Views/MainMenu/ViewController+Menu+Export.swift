//
//  ViewController+Menu+Export.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/30.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {

    internal func setupExportMenu() {
        self.btnExport.menu?.item(at: 0)?.title = Words.mainmenu_export.word()
        self.btnExport.menu?.addItem(NSMenuItem.separator())
        self.btnExport.menu?.addItem(withTitle: Words.mainmenu_export_configuration.word(), action: #selector(exportMenuConfigAction(_:)), keyEquivalent: "")
        self.btnExport.menu?.addItem(NSMenuItem.separator())
        self.btnExport.menu?.addItem(withTitle: Words.mainmenu_export_export.word(), action: #selector(exportMenuExportProfilesAction(_:)), keyEquivalent: "")
    }
    
    @objc func exportMenuConfigAction(_ menuItem:NSMenuItem) {
//        self.logger.log("clicked export menu configuration")
        self.btnExport.selectItem(at: 0)
        
        let viewController = ExportConfigurationViewController()
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 1920
        let windowHeight = 970
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = Words.exportManager.word()
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.initView(window: window)
        
        
    }
    
    @objc func exportMenuExportProfilesAction(_ menuItem:NSMenuItem) {
//        self.logger.log("clicked export menu export action")
        self.btnExport.selectItem(at: 0)
        
        let viewController = ExportProfilesViewController()
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 1230
        let windowHeight = 800
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = Words.exportManager.word()
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.initView(window: window)
    }
}
