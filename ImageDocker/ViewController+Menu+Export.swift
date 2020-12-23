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
        
        self.btnExport.menu?.addItem(NSMenuItem.separator())
        self.btnExport.menu?.addItem(withTitle: "Configuration", action: #selector(exportMenuConfigAction(_:)), keyEquivalent: "")
        self.btnExport.menu?.addItem(NSMenuItem.separator())
        self.btnExport.menu?.addItem(withTitle: "Export Profiles ...", action: #selector(exportMenuExportProfilesAction(_:)), keyEquivalent: "")
        self.btnExport.menu?.addItem(NSMenuItem.separator())
        self.btnExport.menu?.addItem(withTitle: "Export Now (deprecated)", action: #selector(exportMenuDummyAction(_:)), keyEquivalent: "")
    }
    
    internal func updateExportMenu() {
        if let menu = self.btnExport.menu?.item(withTitle: "Export Now") {
            if menu.hasSubmenu {
                menu.submenu?.removeAllItems()
            }else{
                menu.submenu = NSMenu()
            }
            
            menu.submenu?.addItem(withTitle: "All Profiles", action: #selector(exportMenuExportAllAction(_:)), keyEquivalent: "")
            menu.submenu?.addItem(NSMenuItem.separator())
            let profiles = ExportDao.default.getAllExportProfiles()
            for profile in profiles {
                if profile.enabled {
                    menu.submenu?.addItem(withTitle: profile.name, action: #selector(exportMenuExportProfileAction(_:)), keyEquivalent: "")
                }
            }
        }
    }
    
    @objc func exportMenuConfigAction(_ menuItem:NSMenuItem) {
        print("clicked export menu configuration")
        self.btnExport.selectItem(at: 0)
        
        let viewController = ExportConfigurationViewController()
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 1230
        let windowHeight = 800
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = "Export Manager"
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.initView(window: window)
        
        
    }
    
    
    
    @objc func exportMenuExportProfilesAction(_ menuItem:NSMenuItem) {
        print("clicked export menu export action")
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
        window.title = "Export Manager"
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.initView(window: window)
    }
    
    @objc func exportMenuDummyAction(_ menuItem:NSMenuItem) {
        // do nothing
    }
    
    @objc func exportMenuExportAllAction(_ menuItem:NSMenuItem) {
        // TODO export all profiles
        print("TODO export all profiles")
    }
    
    
    @objc func exportMenuExportProfileAction(_ menuItem:NSMenuItem) {
        // TODO export single profile
        let title = menuItem.title
        print("TODO export single profile \(title)")
        DispatchQueue.global().async {
            if let profile = ExportDao.default.getExportProfile(name: title) {
                print("Got export profile id \(profile.id)")
                let images = ExportDao.default.getImagesForExport(profile: profile, pageSize: nil, pageNumber: nil)
                print("loaded images: \(images.count)")
            }
        }
    }
 
    @objc func exportMenuExportAction(_ menuItem:NSMenuItem) {
        print("clicked export menu export now")
        self.btnExport.selectItem(at: 0)
        
        if let menuItem = self.btnScan.menu?.item(at: 4) {
            if menuItem.title == "Export Now" {
                menuItem.title = "Stop exporting images"
                
                print("enabled export")
                self.suppressedExport = false
                ExportManager.default.suppressed = false
                
                // start exporting immediatetly
                if TaskManager.allowExport() {
                    // TODO: change export function
//                    DispatchQueue.global().async {
//                        ExportManager.default.export(after: self.lastExportPhotos!)
//                        self.lastExportPhotos = Date()
//                    }
                }
            }else if menuItem.title == "Stop exporting images" {
                menuItem.title = "Export Now"
                
                print("disabled export")
                self.suppressedExport = true
                ExportManager.default.suppressed = true
            }
        }
    }
}
