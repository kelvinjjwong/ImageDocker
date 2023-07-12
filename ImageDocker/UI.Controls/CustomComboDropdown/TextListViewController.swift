//
//  TextListViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/9.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class TextListViewPopupController {
    
    var items:[String] = []
    fileprivate var isPopupButton = true
    weak var popupButton:NSPopUpButton!
    weak var combobox:NSComboBox!
    
    init(){
    }
    
    convenience init(_ listView:NSPopUpButton) {
        self.init()
        self.isPopupButton = true
        self.popupButton = listView
        self.combobox = NSComboBox()
    }
    
    convenience init(_ listView:NSComboBox) {
        self.init()
        self.isPopupButton = false
        self.popupButton = NSPopUpButton()
        self.combobox = listView
        
    }
    
    func load(_ items:[String]){
        self.items = items
        if self.isPopupButton {
            self.popupButton.removeAllItems()
            self.popupButton.addItems(withTitles: items)
        }else{
            self.combobox.removeAllItems()
            self.combobox.addItems(withObjectValues: items)
        }
    }
    
    func select(_ value:String){
        if self.isPopupButton {
            self.popupButton.selectItem(withTitle: value)
            
        }else{
            self.combobox.selectItem(withObjectValue: value)
        }
    }
    
    func clean() {
        self.items = []
        
        if self.isPopupButton {
            self.popupButton.removeAllItems()
        }else{
            self.combobox.removeAllItems()
        }
    }
    
    func indexOfSelectedItem() -> Int? {
        if self.items.count == 0 {
            return nil
        }
        if self.isPopupButton {
            return self.popupButton.indexOfSelectedItem
        }else{
            return self.combobox.indexOfSelectedItem
        }
    }
}
