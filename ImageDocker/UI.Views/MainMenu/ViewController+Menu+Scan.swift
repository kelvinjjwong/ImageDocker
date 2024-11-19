//
//  ViewController+Menu+Scan.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/30.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func titlesOfScanMenu(_ number:Int, _ enabled:Bool = true) -> String {
        switch(number){
        case 1:
            if enabled {
                return Words.scanAndImportImages.word()
            }else{
                return Words.stopScanningRepository.word()
            }
        case 2:
            return Words.scanAndExtractExif.word()
        default:
            return ""
        }
    }
    
    internal func setupScanMenu() {
        
//        self.btnScan.menu?.addItem(NSMenuItem.separator())
//        self.btnScan.menu?.addItem(withTitle: self.titlesOfScanMenu(1), action: #selector(scanMenuAction(_:)), keyEquivalent: "")
//        self.btnScan.menu?.addItem(withTitle: self.titlesOfScanMenu(2), action: #selector(scanMenuAction(_:)), keyEquivalent: "")
    }
//    
//    @objc func scanMenuAction(_ menuItem:NSMenuItem) {
//        self.logger.log(.trace, "clicked scan menu scan now")
//        let title = menuItem.title
//        self.btnScan.selectItem(at: 0)
//        
//        if title == self.titlesOfScanMenu(1, true) {
//                menuItem.title = self.titlesOfScanMenu(1, false)
//                self.onScanEnabled()
//        }else if title == self.titlesOfScanMenu(1, false) {
//            menuItem.title = self.titlesOfScanMenu(1, true)
//            self.onScanDisabled()
//        }else if title == self.titlesOfScanMenu(2) {
//            self.logger.log(.trace, "clicked extract exif")
//        }
//    }
    
}
