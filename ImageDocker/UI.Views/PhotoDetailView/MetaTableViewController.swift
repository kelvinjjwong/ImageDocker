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
    
    @objc func copyDateAction(sender: NSButton) {
        if sender.toolTip != nil && (sender.toolTip?.starts(with: "Copy "))! {
            let value = sender.toolTip!
            let components = value.components(separatedBy: " ")
            if components.count >= 3{
                let datetime:String = components[1] + " " + components[2]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                if let _ = dateFormatter.date(from: datetime) {
                    //self.editorDatePicker.dateValue = date
                }
                
                
            }
        }
    }
    
    // return view for requested column.
    func tableView(_ tableView: NSTableView,
                   viewFor tableColumn: NSTableColumn?,
                   row: Int) -> NSView? {
        if row > (self.img.metaInfoHolder.getInfos().count - 1) {
            return nil
        }
        let info:MetaInfo = self.img.metaInfoHolder.getInfos()[row]
        var value = ""
        //var tip: String? = nil
        if let id = tableColumn?.identifier {
            var isAction:Bool = false
            switch id {
            case NSUserInterfaceItemIdentifier("category"):
                value = Words.meta(info.category).word()
            case NSUserInterfaceItemIdentifier("subCategory"):
                value = Words.meta(info.subCategory).word()
            case NSUserInterfaceItemIdentifier("title"):
                value = Words.meta(info.title).word()
            case NSUserInterfaceItemIdentifier("value"):
                value = info.value ?? ""
            case NSUserInterfaceItemIdentifier("copy"):
                //self.logger.log(.trace, "action cell")
                
                isAction = true
                
            default:
                break
            }
            let colView = tableView.makeView(withIdentifier: id, owner: nil) as! NSTableCellView
            if isAction {
                colView.subviews.removeAll()
                
//                
//                if info.category == "DateTime" {
//                    let button:NSButton = NSButton(frame: NSRect(x: 2, y: 2, width: 12, height: 12))
//                    button.setButtonType(NSButton.ButtonType.momentaryPushIn)
//                    button.isBordered = false
//                    button.bezelStyle = NSButton.BezelStyle.smallSquare
//                    button.image = NSImage(named: .multipleDocuments)
//                    button.action = #selector(ViewController.copyDateAction(sender:))
//                    button.isHidden = false
//                    if info.value != nil {
//                        button.toolTip = "Copy " + info.value!
//                    }
//                    colView.addSubview(button)
//                }
                
                
                
            }else{
                colView.textField?.stringValue = value;
                colView.textField?.lineBreakMode = .byWordWrapping
                if row == tableView.selectedRow {
                    lastSelectedMetaInfoRow = row
//                    colView.textField?.textColor = NSColor.yellow
                } else {
                    lastSelectedMetaInfoRow = nil
//                    colView.textField?.textColor = nil
                }
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
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        
        //guard let tableView = tableView as? CustomTableView else { return }
        
        rowView.backgroundColor = row % 2 == 1
            ? Colors.MidGray
            : Colors.DarkGray
    }
}

// MARK: TableView data source functions

extension ViewController: NSTableViewDataSource {
    
    /// table size is one row per image in the images array
    func numberOfRows(in tableView: NSTableView) -> Int {
        if img == nil {
            return 0
        }
        return self.img.metaInfoHolder.getInfos().count
    }
    
    // table sorting by column contents
    func tableView(_ tableView: NSTableView,
                   sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
}


