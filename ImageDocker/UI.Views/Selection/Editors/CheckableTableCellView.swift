//
//  CheckableTableCellView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/29.
//  Copyright © 2024 nonamecat. All rights reserved.
//
import Cocoa

public class CheckableTableCellView: NSTableCellView {
    
    @IBOutlet weak var checkbox: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    @IBOutlet weak var editButton: NSButton!
    
    var row = -1
    var isEditing = false
    var table:NSTableView? = nil
    var nodeData:TreeNodeData? = nil
    var isChecked = false
    var onCheckStateChanged:((Bool,Bool,String,String) -> Void)?
    var isEditInline = true
    var onEditNodeInline:((String,TreeNodeData) -> Bool)?
    var onEditNode:((TreeNodeData) -> Bool)?
    var onRemoveNode:((TreeNodeData) -> Bool)?
    var afterChange:(() -> Void)?
    
    @IBAction func onCheckClicked(_ sender: NSButton) {
        if let item = nodeData {
            print("checkbox: people: \(item.getId()) , \(String(describing: type(of: item))), state: \(sender.state == .on)")
            let ov = item.checked()
            self.isChecked = (sender.state == .on)
            item.setCheckState(state: (sender.state == .on))
            if ov != item.checked() {
                self.onCheckStateChanged?(ov, item.checked(), String(describing: type(of: item)), item.getId())
            }
        }
    }
    
    @IBAction func onRemoveClicked(_ sender: NSButton) { // on update or remove, shared button
        if let onRemoveNode = self.onRemoveNode, let item = nodeData {
            if onRemoveNode(item) {
                if let table = self.table {
                    table.deselectAll(nil)
                    table.reloadData()
                }
                self.afterChange?()
            }
        }
        
    }
    
    @IBAction func onEditClicked(_ sender: NSButton) {
        
        if let item = nodeData {
            
            if self.isEditInline {
                
                if self.isEditing {
                    // save editing
                    if let textField = self.textField, let editor = textField.currentEditor() {
                        textField.endEditing(editor)
                    }
                    self.textField?.isEditable = false
                    self.isEditing = false
                    self.editButton.image = Icons.edit
                    
                    let newGroupName = self.textField?.stringValue ?? item.getText()
                    
                    if newGroupName != item.getText() {
                        
                        if let onEditNodeInline = self.onEditNodeInline {
                            if onEditNodeInline(newGroupName, item) {
                                if let table = self.table {
                                    table.deselectAll(nil)
                                    table.reloadData()
                                }
                                self.afterChange?()
                            }
                        }
                    }
                }else{
                    // start editing
                    self.textField?.isEditable = true
                    if let table = self.table {
                        table.editColumn(0, row: self.row, with: nil, select: false)
                    }
                    self.isEditing = true
                    self.editButton.image = Icons.saveEdit
                }
            }else{
                let _ = self.onEditNode?(item)
            }
        }
    }
    
}
