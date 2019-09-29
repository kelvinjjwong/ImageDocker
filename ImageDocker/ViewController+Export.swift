//
//  ViewController+Export.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func startExport() {
        if PreferencesController.exportDirectory() == "" {
            self.chbExport.state = .off
            Alert.invalidExportPath()
            return
        }
        if self.chbExport.state == NSButton.StateValue.on {
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
            //ExportManager.enable()
        }else {
            print("disabled export")
            self.suppressedExport = true
            ExportManager.default.suppressed = true
            //ExportManager.disable()
        }
    }
}
