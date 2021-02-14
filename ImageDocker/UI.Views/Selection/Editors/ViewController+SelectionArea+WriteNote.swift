//
//  ViewController+SelectionArea+Note.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    
    func createNotesPopover(){
        var myPopover = self.notesPopover
        if(myPopover == nil){
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 480, height: 280))
            self.notesViewController = NotesViewController()
            self.notesViewController.view.frame = frame
            
            myPopover = NSPopover()
            myPopover!.contentViewController = self.notesViewController
            myPopover!.appearance = NSAppearance(named: .vibrantDark)!
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.notesPopover = myPopover
    }
    
    func openNoteWriter(_ sender: NSButton) {
        if self.selectionViewController.imagesLoader.getItems().count == 0 {
            Alert.noImageSelected()
            return
        }
        self.createNotesPopover()
        
        let cellRect = sender.bounds
        self.notesPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
        self.notesViewController.loadFrom(images: self.selectionViewController.imagesLoader.getItems(),
                                          onApplyChanges: {
                                            self.selectionViewController.imagesLoader.reload()
                                            self.selectionViewController.imagesLoader.reorganizeItems()
                                            self.selectionCollectionView.reloadData()
                                            
                                            self.imagesLoader.reload()
                                            self.imagesLoader.reorganizeItems()
                                            self.collectionView.reloadData()
        })
    }
}
