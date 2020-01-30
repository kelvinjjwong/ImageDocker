//
//  TreeController+LibrariesView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import Cocoa

extension ViewController {
    
    func createLibrariesViewPopover(){
        var myPopover = self.librariesViewPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 810, height: 390))
            self.librariesViewController = LibrariesViewController(onReload: {
                DispatchQueue.main.async {
                    self.refreshLibraryTree()
                }
            })
            self.librariesViewController.view.frame = frame
            
            myPopover!.contentViewController = self.librariesViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.librariesViewPopover = myPopover
    }
}
