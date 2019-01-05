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
    
    static func invalidBaiduMapAK() {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("Please setup API keys",
                                              comment: "Please setup API keys")
        alert.informativeText = NSLocalizedString("Please specify Baidu AK and SK in Menu / Preferences / Baidu tab.",
                                                  comment: "Please specify Baidu AK and SK in Menu / Preferences / Baidu tab.")
        alert.runModal()
    }
    
    static func invalidExportPath(){
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("Please setup destination path for exporting images",
                                              comment: "Please setup destination path for exporting images")
        alert.informativeText = NSLocalizedString("Please specify destination path for exporting images in Menu / Preferences / Export tab.",
                                                  comment: "Please specify destination path for exporting images in Menu / Preferences / Export tab.")
        alert.runModal()
    }
    
    static func invalidIOSMountPoint() {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("Please setup mount point for iOS devices",
                                              comment: "Please setup mount point for iOS devices")
        alert.informativeText = NSLocalizedString("Please specify mount point for iOS devices in Menu / Preferences / iPhone tab.",
                                                  comment: "Please specify mount point for iOS devices in Menu / Preferences / iPhone tab.")
        alert.runModal()
    }
    
    static func noImageSelected() {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("NO IMAGES SELECTED",
                                              comment: "NO IMAGES SELECTED")
        alert.informativeText = NSLocalizedString("Please select one or more images first",
                                                  comment: "Please select one or more images first")
        alert.runModal()
    }
    
    static func checkOneImage() {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("PLEASE CHECK ONE IMAGE",
                                              comment: "PLEASE CHECK ONE IMAGE")
        alert.informativeText = NSLocalizedString("Please check one image first",
                                                  comment: "Please check one image first")
        alert.runModal()
    }
    
    static func checkImages() {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("NO IMAGE CHECHED",
                                              comment: "NO IMAGE CHECHED")
        alert.informativeText = NSLocalizedString("Please check one or more images first",
                                                  comment: "Please check one or more images first")
        alert.runModal()
    }
    
    static func noAndroidDeviceFound() {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString("NO DEVICE FOUND",
                                              comment: "NO DEVICE FOUND")
        alert.informativeText = NSLocalizedString("Please connect your Android device with USB Debug Mode enabled",
                                                  comment: "Please connect your Android device with USB Debug Mode enabled")
        alert.runModal()
    }
    
    static func noOptionSelected(message:String) {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
        alert.messageText = NSLocalizedString(message,
                                              comment: message)
        alert.informativeText = NSLocalizedString("Please select one or more items first",
                                                  comment: "Please select one or more items first")
        alert.runModal()
    }
}

struct PopNotification {
    
    static func enableDebugMode() {
//        let notification = NSUserNotification()
//        notification.identifier = "image-docker-device-connectivity"
//        notification.title = "ImageDocker"
//        //notification.subtitle = "How are you?"
//        notification.informativeText = "If you've connected your phone via USB properly, please enable DEBUG MODE from [Settings >> System >> Developer Mode] on your phone."
//
//        notification.soundName = NSUserNotificationDefaultSoundName
//
//        print("deliver notification - debug mode")
//        NSUserNotificationCenter.default.deliver(notification)
        
    }
}
