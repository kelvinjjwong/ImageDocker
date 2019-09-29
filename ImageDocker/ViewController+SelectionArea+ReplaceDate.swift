//
//  ViewController+SelectionArea+ReplaceDate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    
    func createCalenderPopover(){
        var myPopover = self.calendarPopover
        if(myPopover == nil){
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 1200, height: 650))
            self.calendarViewController = DateTimeViewController()
            self.calendarViewController.view.frame = frame
            
            myPopover = NSPopover()
            myPopover!.contentViewController = self.calendarViewController
            myPopover!.appearance = NSAppearance(named: .aqua)!
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.applicationDefined
        }
        self.calendarPopover = myPopover
    }
    
    func openDatePicker(_ sender: NSButton) {
        if self.selectionViewController.imagesLoader.getItems().count == 0 {
            Alert.noImageSelected()
            return
        }
        self.createCalenderPopover()
        
        let cellRect = sender.bounds
        self.calendarPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxY)
        self.calendarViewController.loadFrom(images: self.selectionViewController.imagesLoader.getItems(),
                                             onApplyChanges: {
                                                self.selectionViewController.imagesLoader.reload()
                                                self.selectionViewController.imagesLoader.reorganizeItems()
                                                self.selectionCollectionView.reloadData()
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
