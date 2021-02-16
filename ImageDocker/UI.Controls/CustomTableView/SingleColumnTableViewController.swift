//
//  FaceCategoryListViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/7.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

//protocol FaceCategoryListSelectionDelegate {
//    func select(_ category:String)
//}

class SingleColumnTableViewController: NSObject {
    
//    var selectionDelegate:FaceCategoryListSelectionDelegate?
    var items:[String] = []
    var onClick:((String) -> Void)? = nil
    
    // MARK: CONTROLS
    
    weak var table: NSTableView!
    
    // MARK: INIT
    
    init(_ table:NSTableView) {
        self.table = table
    }
    
    func load(_ items:[String]) {
        lastSelectedRow = nil
        self.table.delegate = self
        self.table.dataSource = self
        self.items = items
        print(items.count)
        self.table.reloadData()
    }
    
    func load(_ items:[Int]){
        var strings:[String] = []
        for item in items {
            strings.append("\(item)")
        }
        self.load(strings)
    }
    
    func clean(){
        self.load([String]())
    }
    
    // MARK: ACTION
    
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil && items.count > 0 && lastSelectedRow! < items.count {
                let selectedItem = items[lastSelectedRow!]
//                if self.selectionDelegate != nil {
//                    self.selectionDelegate?.select(selectedItem)
                    if self.onClick != nil {
                        self.onClick!(selectedItem)
                    }
//                }
            }
        }
    }
    
}


// MARK: TableView delegate functions

extension SingleColumnTableViewController: NSTableViewDelegate {
    
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
            switch id {
            case NSUserInterfaceItemIdentifier("value"):
                value = item
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = .byWordWrapping
            if row == tableView.selectedRow {
                lastSelectedRow = row
                colView.textField?.textColor = NSColor.yellow
            } else {
                lastSelectedRow = nil
                colView.textField?.textColor = nil
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

extension SingleColumnTableViewController: NSTableViewDataSource {
    
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
