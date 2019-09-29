//
//  ViewController+Menu+Scan.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/30.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func setupScanMenu() {
        
        self.btnScan.menu?.addItem(NSMenuItem.separator())
        self.btnScan.menu?.addItem(withTitle: "Scan libraries now", action: #selector(scanMenuAction(_:)), keyEquivalent: "")
    }
    
    @objc func scanMenuAction(_ menuItem:NSMenuItem) {
        print("clicked scan menu scan now")
        self.btnScan.selectItem(at: 0)
        
        if let menuItem = self.btnScan.menu?.item(at: 2) {
            if menuItem.title == "Scan libraries now" {
                menuItem.title = "Stop scanning libraries"
                self.onScanEnabled()
            }else if menuItem.title == "Stop scanning libraries" {
                menuItem.title = "Scan libraries now"
                self.onScanDisabled()
            }
        }
    }
    
}
