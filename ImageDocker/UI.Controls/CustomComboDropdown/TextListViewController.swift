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
    weak var combobox:NSPopUpButton!
    
    init(_ listView:NSPopUpButton){
        self.combobox = listView
    }
    
    func load(_ items:[String]){
        self.items = items
        self.combobox.removeAllItems()
        self.combobox.addItems(withTitles: items)
    }
    
    func select(_ value:String){
        self.combobox.selectItem(withTitle: value)
    }
    
    func clean() {
        self.items = []
        self.combobox.removeAllItems()
    }
    
    func indexOfSelectedItem() -> Int? {
        if self.items.count == 0 {
            return nil
        }
        return self.combobox.indexOfSelectedItem
    }
}
