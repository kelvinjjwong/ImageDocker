//
//  ViewController+DeviceTree+Extension.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    func openDeviceCopyView(device: PhoneDevice, connected: Bool) {
        let storyboard = NSStoryboard(name: "DeviceCopyView", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "DeviceCopyViewController") as! DeviceCopyViewController
        let window = NSWindow(contentViewController: viewController)
        
        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
        let windowWidth = 850
        let windowHeight = 620
        let originX = (screenWidth - windowWidth) / 2
        let originY = (screenHeight - windowHeight) / 2
        
        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
        window.title = "Copy From Device"
        window.setFrame(frame, display: false)
        window.makeKeyAndOrderFront(self)
        viewController.viewInit(device: device, connected: connected)
    }
}
