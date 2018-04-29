//
//  MetaTableViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/23.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa


// MARK: TableView delegate functions

extension ViewController: NSTableViewDelegate {
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.metaInfo.count - 1) {
            return nil
        }
        let info:MetaInfo = self.metaInfo[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("category"):
                value = info.category
            case NSUserInterfaceItemIdentifier("subCategory"):
                value = info.subCategory
            case NSUserInterfaceItemIdentifier("title"):
                value = info.title
            case NSUserInterfaceItemIdentifier("value"):
                value = info.value
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = NSParagraphStyle.LineBreakMode.byWordWrapping
            if row == tableView.selectedRow {
                lastSelectedMetaInfoRow = row
                colView.textField?.textColor = NSColor.yellow
            } else {
                lastSelectedMetaInfoRow = nil
                colView.textField?.textColor = nil
            }
         /*
            if let tooltip = tip {
                colView.textField?.toolTip = tooltip
            }
         */
            return colView
        }
        return nil
    }
}

// MARK: TableView data source functions

extension ViewController: NSTableViewDataSource {
    
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.metaInfo.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let sorted = NSMutableArray(array: self.metaInfo)
        sorted.sort(using: tableView.sortDescriptors)
        self.metaInfo = sorted as! [MetaInfo]
        tableView.reloadData()
    }
}
