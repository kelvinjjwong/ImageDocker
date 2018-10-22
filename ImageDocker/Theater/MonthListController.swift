//
//  MonthListController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/10/19.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class MonthListController : NSObject {
    
    var onClick: ((_ month:String) -> Void)? = nil
    
    var months:[String] = []
    var lastSelectedRow:Int? {
        didSet {
            if lastSelectedRow != nil {
                let month:String = self.months[lastSelectedRow!]
                if onClick != nil {
                    onClick!(month)
                }
            }
        }
    }
    
}

extension MonthListController : NSTableViewDelegate {
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.months.count - 1) {
            return nil
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSize = 3
        
        let info:String = self.months[row]
        //print(info)
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            switch id {
            case NSUserInterfaceItemIdentifier("month"):
                value = info
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            colView.textField?.stringValue = value;
            colView.textField?.lineBreakMode = NSParagraphStyle.LineBreakMode.byWordWrapping
            //            if row == tableView.selectedRow {
            //                lastSelectedRow = row
            //            } else {
            //                lastSelectedRow = nil
            //            }
            
            return colView
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
        //        rowView.backgroundColor = row % 2 == 1
        //            ? NSColor.white
        //            : NSColor.lightGray
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        lastSelectedRow = row
        return true
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let myCustomView = CustomRowView()
        return myCustomView
    }
}

extension MonthListController : NSTableViewDataSource {
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.months.count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}
