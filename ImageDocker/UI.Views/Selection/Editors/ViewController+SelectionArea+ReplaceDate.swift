//
//  ViewController+SelectionArea+ReplaceDate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension SelectionViewController {
    
    
    func createCalenderPopover(){
        var myPopover = self.calendarPopover
        if(myPopover == nil){
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 1200, height: 700))
            self.calendarViewController = DateTimeViewController()
            self.calendarViewController.view.frame = frame
            
            myPopover = NSPopover()
            myPopover!.contentViewController = self.calendarViewController
            myPopover!.appearance = NSAppearance(named: .vibrantDark)!
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.applicationDefined
        }
        self.calendarPopover = myPopover
    }
    
    func openDatePicker(_ sender: NSButton, with referenceDate:String? = nil) {
        if self.collectionViewController.imagesLoader.getItems().count == 0 {
            Alert.noImageSelected()
            return
        }
        self.createCalenderPopover()
        
        let cellRect = sender.bounds
        self.calendarPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
        self.calendarViewController.loadFrom(images: self.collectionViewController.imagesLoader.getItems(),
                                             with: referenceDate,
                                             onBeforeChanges: {
                                                TaskManager.applyingSelectionModifies = true
                                                
        },
                                             onApplyChanges: {
                                                self.collectionViewController.imagesLoader.reload()
                                                self.collectionViewController.imagesLoader.reorganizeItems()
                                                self.selectionCollectionView.reloadData()
                                                
                                                TaskManager.applyingSelectionModifies = false
        },
                                             onClose: {
                                                self.calendarPopover?.close()
        })
    }
}

extension ViewController : LunarCalendarViewDelegate {
    @objc func didSelectDate(_ selectedDate: Date) {
        print(selectedDate)
    }
}
