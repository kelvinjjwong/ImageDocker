//
//  Alert.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/9/12.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

struct Alert {
    
    static func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    static func invalidExportPath(){
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("Please setup destination path for exporting images", comment: "Please setup destination path for exporting images")
        alert.informativeText = NSLocalizedString("Please specify destination path for exporting images in Menu / Preferences / Path Tab.", comment: "Please specify destination path for exporting images in Menu / Preferences / Path Tab.")
        alert.runModal()
    }
    
    static func invalidIOSMountPoint() {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("Please setup mount point for iOS devices", comment: "Please setup mount point for iOS devices")
        alert.informativeText = NSLocalizedString("Please specify mount point for iOS devices in Menu / Preferences / iPhone Tab.", comment: "Please specify mount point for iOS devices in Menu / Preferences / iPhone Tab.")
        alert.runModal()
    }
    
    static func noImageSelected() {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("NO IMAGES SELECTED", comment: "NO IMAGES SELECTED")
        alert.informativeText = NSLocalizedString("Please select one or more images first", comment: "Please select one or more images first")
        alert.runModal()
    }
    
    static func noAndroidDeviceFound() {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("NO DEVICE FOUND", comment: "NO DEVICE FOUND")
        alert.informativeText = NSLocalizedString("Please connect your Android device with USB Debug Mode enabled", comment: "Please connect your Android device with USB Debug Mode enabled")
        alert.runModal()
    }
    
    static func invalidBaiduMapAK() {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("CLOSE", comment: "Close"))
        alert.messageText = NSLocalizedString("Please setup API keys", comment: "Please setup API keys")
        alert.informativeText = NSLocalizedString("Please specify Baidu AK and SK in Preferences menu/dialog.", comment: "Please specify Baidu AK and SK in Preferences menu/dialog.")
        alert.runModal()
    }
}
