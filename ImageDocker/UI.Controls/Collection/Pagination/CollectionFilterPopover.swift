//
//  CollectionFilterPopover.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/9/24.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    func persistCollectionFilter(filter: CollectionFilter) {
        print(filter.represent())
    }
    
    
    func createCollectionFilterPopover(){
        var myPopover = self.collectionFilterPopover
        if(myPopover == nil){
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 600, height: 350))
            self.collectionFilterViewController = CollectionFilterViewController()
            self.collectionFilterViewController.persist = self.persistCollectionFilter(filter:)
            self.collectionFilterViewController.view.frame = frame
            
            myPopover = NSPopover()
            myPopover!.contentViewController = self.collectionFilterViewController
            myPopover!.appearance = NSAppearance(named: .darkAqua)!
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.collectionFilterPopover = myPopover
        
    }
    
    func popoverCollectionFilter() {
//        let currentMouseLocation = NSEvent.mouseLocation
//        let posX = currentMouseLocation.x
//        let posY = currentMouseLocation.y
        
        self.createCollectionFilterPopover()
//        let invisibleWindow = NSWindow(contentRect: NSMakeRect(0, 0, 20, 5), styleMask: .borderless, backing: .buffered, defer: false)
//        invisibleWindow.backgroundColor = .red
//        invisibleWindow.alphaValue = 0
//
//        invisibleWindow.setFrameOrigin(NSPoint(x: posX, y: posY))
//        invisibleWindow.makeKeyAndOrderFront(self)
        
        let cellRect = self.btnFilter.bounds
        
        self.collectionFilterPopover?.show(relativeTo: cellRect, of: self.btnFilter, preferredEdge: .maxY)
        self.collectionFilterViewController.initView()
    }
}
