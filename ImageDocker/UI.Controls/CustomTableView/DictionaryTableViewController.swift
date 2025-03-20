//
//  DictionaryTableViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/9.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class DictionaryTableViewController: NSObject {
    
    let logger = LoggerFactory.get(category: "DictionaryTableViewController")

    var checkboxes:[String:NSButton] = [:]
    var items:[[String:String]] = []
    var onClick:(([String:String]) -> Void)? = nil
    var onCheck:((String, Bool) -> Void)? = nil
    var onAction:((String) -> Void)? = nil
    var onValueChanged:((String, String, String, String) -> Void)? = nil // id, column, origin value, new value
    var actionIcon:NSImage? = nil
    var editableColumns:[String] = []
    
    // MARK: CONTROLS
    
    weak var table: NSTableView!
    
    // MARK: INIT
    
    init(_ table:NSTableView) {
        self.table = table
    }
    
    func load(_ items:[[String:String]], afterLoaded:(() -> Void)? = nil) {
        lastSelectedRow = nil
        self.table.delegate = self
        self.table.dataSource = self
        self.items = items
        //self.logger.log(items.count)
        self.table.reloadData()
        
        if let afterLoaded = afterLoaded {
            self.logger.log(.trace, "item amount = \(items.count) , checkbox amount = \(self.checkboxes.count)")
            afterLoaded()
        }
    }
    
    func clean(){
        self.load([[String:String]]())
    }
    
    func disableCheckboxes() {
        for (_, checkbox) in checkboxes {
            checkbox.isEnabled = false
        }
    }
    
    func enableCheckboxes() {
        for (_, checkbox) in checkboxes {
            checkbox.isEnabled = true
        }
    }
    
    func setCheckedItems(column:String, from array:[String]) {
        self.logger.log(.trace, "setCheckedItems() array: \(array)")
        var indexes:[Int] = []
        for i in 0..<items.count {
            let item = items[i]
            if let columnValue = item[column] {
                //self.logger.log(.trace, "checking \(columnValue)")
                if array.contains(columnValue) {
                    //self.logger.log(.trace, "containes \(columnValue)")
                    indexes.append(i)
                }
            }
        }
        for (_, checkbox) in self.checkboxes {
            checkbox.state = .off
        }
        for i in indexes {
            var edititem = items[i]
            edititem["check"] = "true"
            items[i] = edititem
            if let id = edititem["id"], let checkbox = self.checkboxes["checkbox_\(id)"] {
                self.logger.log(.trace, "turn \(id) on")
                checkbox.state = .on
            }
        }
    }
    
    func uncheckAll() {
        self.logger.log(.trace, "uncheckAll()")
        for i in 0..<items.count {
            var item = items[i]
            item["check"] = "false"
            items[i] = item
            
            if let id = item["id"], let checkbox = self.checkboxes["checkbox_\(id)"] {
                self.logger.log(.trace, "turn \(id) off")
                checkbox.state = .off
            }
        }
    }
    
    func checkAll() {
        for i in 0..<items.count {
            var item = items[i]
            item["check"] = "true"
            items[i] = item
            
            if let id = item["id"], let checkbox = self.checkboxes["checkbox_\(id)"] {
                self.logger.log(.trace, "turn \(id) on")
                checkbox.state = .on
            }
        }
    }
    
    func setCheckedItems(column:String, from separatedValue:String, separator:String, quoted:Bool) {
        if separatedValue.trimmingCharacters(in: .whitespacesAndNewlines) == "" {return}
        var array:[String] = []
        let separated = separatedValue.components(separatedBy: separator)
        if quoted == true {
            for value in separated {
                let length = value.lengthOfBytes(using: .utf8)
                if length > 0 {
                    let newValue = value.replacingOccurrences(of: "\"", with: "")
                    self.logger.log(.trace, "unquoted: \(newValue)")
                    array.append(newValue)
                }
            }
        }else{
            array = separated
        }
        self.setCheckedItems(column: column, from: array)
    }
    
    func getCheckedItems(column:String) -> [String] {
        var result:[String] = []
        for item in items {
            if item["check"] == "true" || item["check"] == "yes" || item["check"] == "on" {
                if let value = item[column] {
                    result.append(value)
                }
            }
        }
        return result
    }
    
    func getCheckedItemAsString(column:String, separator:String) -> String {
        let items = self.getCheckedItems(column: column)
        return items.joined(separator: separator)
    }
    
    func getCheckedItemAsQuotedString(column:String, separator:String) -> String {
        let items = self.getCheckedItems(column: column)
        return items.joinedQuoted(separator: separator)
    }
    
    func getCheckedItemAsSingleQuotedString(column:String, separator:String) -> String {
        let items = self.getCheckedItems(column: column)
        return items.joinedSingleQuoted(separator: separator)
    }
    
    // MARK: ACTION
    
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil && items.count > 0 && lastSelectedRow! < items.count {
                let item = self.items[lastSelectedRow!]
                //                if self.selectionDelegate != nil {
                //                    self.selectionDelegate?.select(selectedItem)
                if self.onClick != nil {
                    self.onClick!(item)
                }
                //                }
            }
        }
    }
    
}


// MARK: TableView delegate functions

extension DictionaryTableViewController: NSTableViewDelegate, NSTextFieldDelegate {
    
    @objc @IBAction func onActionClicked(sender:NSButton) {
        let id = sender.identifier?.rawValue.replacingFirstOccurrence(of: "action_", with: "") ?? ""
        
        var index = -1
        for i in 0..<items.count {
            let item = items[i]
            if item["id"] == id {
                index = i
                break
                
            }
        }
        
        if index >= 0 {
            var edititem = items[index]
            
            self.logger.log(.trace, "actioned: \(edititem)")
            self.onAction?(id)
        }
    }
    
    @objc @IBAction func onCheckboxClicked(sender:NSButton) {
        //self.logger.log(.trace, "checkbox clicked \(sender.identifier?.rawValue ?? "")")
//        self.logger.log(.trace, sender.identifier?.rawValue)
        let id = sender.identifier?.rawValue.replacingFirstOccurrence(of: "checkbox_", with: "") ?? ""
//        if id != "" {
            var index = -1
            for i in 0..<items.count {
                let item = items[i]
                if item["id"] == id {
                    index = i
                    break
                    
                }
            }
            if index >= 0 {
                var edititem = items[index]
                if sender.state == .on {
                    edititem["check"] = "true"
                }else{
                    edititem["check"] = "false"
                }
                items[index] = edititem
            }
            self.logger.log(.trace, "checked: \(self.getCheckedItemAsQuotedString(column: "name", separator: ","))")
            if self.onCheck != nil {
                self.onCheck!(id, sender.state == .on)
            }
//        }
    }
    
    @objc func textFieldDidChange(_ textField: NSTextField) {

    }
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.items.count - 1) {
            return nil
        }
        let item = self.items[row]
        var value = ""
        var columnKey = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            var isAction = false
            var isCheckbox = false
            if id == NSUserInterfaceItemIdentifier("checkbox") {
                isCheckbox = true
            }else{
                if id == NSUserInterfaceItemIdentifier("action") {
                    isAction = true
                }else{
                    for key in item.keys {
                        if id == NSUserInterfaceItemIdentifier(key) {
                            columnKey = key
                            value = item[key] ?? ""
                            //self.logger.log(.trace, "LOOP RESULT: \(key), \(value)")
                            break
                        }
                    }
                }
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            if isCheckbox {
                colView.subviews.removeAll()
                
                let id = "checkbox_\(item["id"] ?? UUID().uuidString)"
                
                let button:NSButton = NSButton(frame: NSRect(x: 0, y: 0, width: 18, height: 18))
                button.setButtonType(NSButton.ButtonType.switch)
                button.action = #selector(DictionaryTableViewController.onCheckboxClicked(sender:))
                button.identifier = NSUserInterfaceItemIdentifier(id)
                button.target = self
                value = item["check"] ?? ""
                if value == "on" || value == "true" || value == "yes" {
                    button.state = .on
                }else{
                    button.state = .off
                }
                
                self.checkboxes[id] = button
                
                colView.addSubview(button)
            }else{
                if isAction {
                    colView.subviews.removeAll()
                    
                    let id = "action_\(item["id"] ?? UUID().uuidString)"
                    
                    let button:NSButton = NSButton(frame: NSRect(x: 0, y: 0, width: 22, height: 18))
                    button.setButtonType(.momentaryChange)
                    button.action = #selector(DictionaryTableViewController.onActionClicked(sender:))
                    button.identifier = NSUserInterfaceItemIdentifier(id)
                    button.target = self
                    if let icon = self.actionIcon {
                        button.image = icon
                        button.imagePosition = .imageOnly
                        button.setWidth(40)
                        button.isBordered = false
                        button.alignment = .center
                    }else{
                        button.title = "X"
                        button.imagePosition = .noImage
                    }
                    
                    colView.addSubview(button)
                }else{
                    colView.textField?.stringValue = value;
                    colView.textField?.lineBreakMode = .byClipping
                    if columnKey != "" && self.editableColumns.contains(columnKey) && !(item["id"] ?? "").hasPrefix("fixed_") {
                        colView.textField?.isEditable = true
                    }
                    colView.textField?.identifier = NSUserInterfaceItemIdentifier("id_\(item["id"] ?? UUID().uuidString)_column_\(columnKey)_datatype_\(item["datatype"] ?? "")")
                    colView.textField?.delegate = self
                    
                    if row == tableView.selectedRow {
                        lastSelectedRow = row
                        //                    colView.textField?.textColor = NSColor.yellow
                    } else {
                        lastSelectedRow = nil
                        //                    colView.textField?.textColor = nil
                    }
                }
            }
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
        //        rowView.backgroundColor = row % 2 == 1
        //            ? NSColor.gray
        //            : NSColor.darkGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
    
    // MARK: - NSTextFieldDelegate -

    public func controlTextDidEndEditing(_ obj: Notification) {
        // check the identifier to be sure you have the correct textfield if more are used
        if let textField = obj.object as? NSTextField {
            let identifier = textField.identifier?.rawValue ?? ""
            let part = identifier.components(separatedBy: "_")
            let id = part[1]
            let column = part[3]
            let datatype = part[5]
            let originValue = DictionaryHelper.getValue(forColumn: column, whichId: id, in: self.items) ?? ""
            let newValue = textField.stringValue
            // changable value
            if ["int", "integer", "float", "double", "decimal"].contains(datatype.lowercased()){
                if !newValue.isNumber {
                    textField.stringValue = originValue
                    return
                }
            }
            self.items = DictionaryHelper.updateValue(value: newValue, forColumn: column, whichId: id, in: self.items)
            
            self.onValueChanged?(id, column, originValue, newValue)
        }
    }
}

// MARK: TableView data source functions

extension DictionaryTableViewController: NSTableViewDataSource {
    
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.items.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        // do nothing
    }
    
}
