//
//  TextListViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/9.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class TextListComboController : NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var items:[String] = []
    weak var combobox:NSComboBox!
    
    init(_ listView:NSComboBox){
        self.combobox = listView
    }
    
    func load(_ items:[String]){
        self.combobox.delegate = self
        self.combobox.dataSource = self
        self.items = items
        self.combobox.reloadData()
    }
    
    func select(_ value:String){
        self.combobox.selectItem(withObjectValue: value)
    }
    
    func clean() {
        self.items = []
        self.combobox.reloadData()
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return(items.count)
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return(items[index] as AnyObject)
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        var i = 0
        for item in items {
            if item == string{
                return i
            }
            i += 1
        }
        return -1
    }
    
    
}
