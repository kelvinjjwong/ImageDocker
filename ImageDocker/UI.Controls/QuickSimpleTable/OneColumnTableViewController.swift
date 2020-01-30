//
//  OneColumnTableViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/11.
//  Copyright © 2019年 nonamecat. All rights reserved.
//

import Cocoa

class OneColumnTableViewController: NSViewController {
    
    
    @IBOutlet weak var table: NSTableView!
    
    var items:[(String, String, String)] = []
    var onClick:((String, String, String) -> Void)? = nil
    var afterClick:((String, String, String) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.backgroundColor = NSColor.gray
    }
    
    func load(_ items:[String]) {
        lastSelectedRow = nil
        self.table.delegate = self
        self.table.dataSource = self
        
        var array:[(String, String, String)] = []
        for item in items {
            array.append((item, item, ""))
        }
        self.items = array
        print(items.count)
        self.table.reloadData()
    }
    
    func load(_ items:[(String, String)]) {
        lastSelectedRow = nil
        self.table.delegate = self
        self.table.dataSource = self
        
        var array:[(String, String, String)] = []
        for item in items {
            array.append((item.0, item.1, ""))
        }
        self.items = array
        print(items.count)
        self.table.reloadData()
    }
    
    func load(_ items:[(String, String,String)]) {
        lastSelectedRow = nil
        self.table.delegate = self
        self.table.dataSource = self
        self.items = items
        print(items.count)
        self.table.reloadData()
    }
    
    func clean(){
        self.load([(String, String)]())
    }
    
    // MARK: ACTION
    
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil && items.count > 0 && lastSelectedRow! < items.count {
                let selectedItem = items[lastSelectedRow!]
                //                if self.selectionDelegate != nil {
                //                    self.selectionDelegate?.select(selectedItem)
                if self.onClick != nil {
                    self.onClick!(selectedItem.0, selectedItem.1, selectedItem.2)
                }
                if self.afterClick != nil {
                    self.afterClick!(selectedItem.0, selectedItem.1, selectedItem.2)
                }
                //                }
            }
        }
    }
    
}



// MARK: TableView delegate functions

extension OneColumnTableViewController: NSTableViewDelegate {
    
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
                value = item.0
            case NSUserInterfaceItemIdentifier("name"):
                value = item.1
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = NSParagraphStyle.LineBreakMode.byWordWrapping
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
        
        rowView.backgroundColor = NSColor.gray
        
//                rowView.backgroundColor = row % 2 == 1
//                    ? NSColor.gray
//                    : NSColor.darkGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
}

// MARK: TableView data source functions

extension OneColumnTableViewController: NSTableViewDataSource {
    
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
