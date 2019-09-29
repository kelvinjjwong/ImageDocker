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
        self.btnExport.menu?.addItem(withTitle: "Export Now", action: #selector(exportMenuExportAction(_:)), keyEquivalent: "")
    }
    
    @objc func exportMenuConfigAction(_ menuItem:NSMenuItem) {
        print("clicked export menu configuration")
        self.btnExport.selectItem(at: 0)
    }
    
    @objc func exportMenuExportAction(_ menuItem:NSMenuItem) {
        print("clicked export menu export now")
        self.btnExport.selectItem(at: 0)
        
        if PreferencesController.exportDirectory() == "" {
            Alert.invalidExportPath()
            return
        }
        
        if let menuItem = self.btnScan.menu?.item(at: 4) {
            if menuItem.title == "Export Now" {
                menuItem.title = "Stop exporting images"
                
                print("enabled export")
                self.suppressedExport = false
                ExportManager.default.suppressed = false
                
                // start exporting immediatetly
                if !ExportManager.default.working {
                    DispatchQueue.global().async {
                        ExportManager.default.export(after: self.lastExportPhotos!)
                        self.lastExportPhotos = Date()
                    }
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
