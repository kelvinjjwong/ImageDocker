//
//  ViewController+SelectionArea+PeopleSelection.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/10/4.
//  Copyright © 2023 nonamecat. All rights reserved.
//


import Cocoa

extension SelectionViewController {
    
    
    func createPeopleSelectionPopover(){
        var myPopover = self.peopleSelectionPopover
        if(myPopover == nil){
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 350))
            self.peopleSelectionViewController = PeopleSelectionViewController()
            self.peopleSelectionViewController.view.frame = frame
            
            myPopover = NSPopover()
            myPopover!.contentViewController = self.peopleSelectionViewController
            myPopover!.appearance = NSAppearance(named: .vibrantDark)!
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.peopleSelectionPopover = myPopover
    }
    
    func openPeopleSelection(_ sender: NSButton) {
        self.createPeopleSelectionPopover()
        
        let cellRect = sender.bounds
        self.peopleSelectionPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
        self.peopleSelectionViewController.initView(images: self.collectionViewController.imagesLoader.getItems(),
                                                    onApplyChanges: {
                                                      self.collectionViewController.imagesLoader.reload()
                                                      self.collectionViewController.imagesLoader.reorganizeItems()
                                                      self.selectionCollectionView.reloadData()
                                                      
                                                      self.reloadMainCollectionView?()
                  })
    }
}
