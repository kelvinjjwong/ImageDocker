//
//  TextListComboController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2021/2/16.
//  Copyright © 2021 nonamecat. All rights reserved.
//

import Cocoa

class TextListComboController : NSObject, NSComboBoxCellDataSource, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var items:[String] = []
    weak var combobox:NSComboBox!
    private var onChange: ((String) -> Void)? = nil
    
    init(_ listView:NSComboBox, onChange: ((String) -> Void)? = nil){
        self.combobox = listView
        self.onChange = onChange
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
    
    func cleanSelection(){
        self.combobox.selectItem(withObjectValue:nil)
    }
    
    func clean() {
        self.items = []
        self.combobox.reloadData()
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return self.items.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return items[index] as AnyObject
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
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        if self.onChange == nil {return}
        if combobox == nil {return}
        if combobox!.indexOfSelectedItem < 0 || combobox!.indexOfSelectedItem >= items.count {return}
        let item = items[combobox!.indexOfSelectedItem]
        self.onChange!(item)
    }
    
    
}
