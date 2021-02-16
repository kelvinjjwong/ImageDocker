//
//  ViewController+SelectionArea+Export.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    
    internal func createCopyToDevicePopover(images:[ImageFile]){
        var myPopover = self.copyToDevicePopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 800, height: 550))
            self.deviceFolderViewController = DeviceFolderViewController(images: images)
            self.deviceFolderViewController.view.frame = frame
            
            myPopover!.contentViewController = self.deviceFolderViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }else{
            self.deviceFolderViewController.reinit(images)
        }
        self.copyToDevicePopover = myPopover
    }
    
    internal func openExportToDeviceDialog(_ sender: NSButton) {
        let images = self.selectionViewController.imagesLoader.getItems()
        //let devices = Android.bridge.devices()
        if images.count == 0 {
            Alert.noImageSelected()
            return
        }
        //        if devices.count == 0 {
        //            Alert.noAndroidDeviceFound()
        //            return
        //        }
        self.createCopyToDevicePopover(images: images)
        let cellRect = sender.bounds
        self.copyToDevicePopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
    }
    
    internal func share(_ sender: NSButton) {
        let images = self.selectionViewController.imagesLoader.getItems()
        if images.count == 0 {
            Alert.noImageSelected()
            return
        }
        var nsImages:[NSImage] = []
        for image in images {
            if let nsImage = image.loadNSImage() {
                nsImages.append(nsImage)
            }
        }
        if nsImages.count == 0 {
            Alert.noImageSelected()
            return
        }
        let sharingPicker = NSSharingServicePicker.init(items: nsImages)
        sharingPicker.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
    }
}
