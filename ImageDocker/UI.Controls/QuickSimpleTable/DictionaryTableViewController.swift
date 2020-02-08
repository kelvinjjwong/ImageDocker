//
//  DictionaryTableViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/9.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class DictionaryTableViewController: NSObject {
    
    //    var selectionDelegate:FaceCategoryListSelectionDelegate?
    var items:[[String:String]] = []
    var onClick:(([String:String]) -> Void)? = nil
    var onCheck:((String, Bool) -> Void)? = nil
    
    // MARK: CONTROLS
    
    weak var table: NSTableView!
    
    // MARK: INIT
    
    init(_ table:NSTableView) {
        self.table = table
    }
    
    func load(_ items:[[String:String]]) {
        lastSelectedRow = nil
        self.table.delegate = self
        self.table.dataSource = self
        self.items = items
        print(items.count)
        self.table.reloadData()
    }
    
    func clean(){
        self.load([[String:String]]())
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

extension DictionaryTableViewController: NSTableViewDelegate {
    
    @objc @IBAction func onCheckboxClicked(sender:NSButton) {
        print("checkbox clicked \(sender.identifier?.rawValue ?? "")")
        let id = sender.identifier?.rawValue.replacingFirstOccurrence(of: "checkbox_", with: "") ?? ""
        if id != "" && self.onCheck != nil {
            self.onCheck!(id, sender.state == .on)
        }
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
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            var isAction = false
            if id == NSUserInterfaceItemIdentifier("checkbox") {
                isAction = true
            }else{
                for key in item.keys {
                    if id == NSUserInterfaceItemIdentifier(key) {
                        value = item[key] ?? ""
                        print("LOOP RESULT: \(key), \(value)")
                        break
                    }
                }
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            if isAction {
                colView.subviews.removeAll()
                
                let button:NSButton = NSButton(frame: NSRect(x: 0, y: 0, width: 18, height: 18))
                button.setButtonType(NSButton.ButtonType.switch)
                button.action = #selector(DictionaryTableViewController.onCheckboxClicked(sender:))
                button.identifier = NSUserInterfaceItemIdentifier("checkbox_\(item["id"] ?? "")")
                button.target = self
                value = item["checkbox"] ?? ""
                if value == "on" || value == "true" || value == "yes" {
                    button.state = .on
                }else{
                    button.state = .off
                }
                print("checkbox state: \(value) - \(item["id"] ?? "")")
                
                colView.addSubview(button)
            }else{
                colView.textField?.stringValue = value;
                colView.textField?.lineBreakMode = .byClipping
                if row == tableView.selectedRow {
                    lastSelectedRow = row
                    colView.textField?.textColor = NSColor.yellow
                } else {
                    lastSelectedRow = nil
                    colView.textField?.textColor = nil
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
