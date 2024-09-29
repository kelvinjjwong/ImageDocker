//
//  FamilyTreeViewControllerWrapper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/28.
//  Copyright © 2024 nonamecat. All rights reserved.
//
import Cocoa
import LoggerFactory

public class CheckableTreeViewControllerWrapper : NSViewController {
    
    private let logger = LoggerFactory.get(category: "FamilyTreeViewController")
    
    private var treeView: NSOutlineView!
    
    private var dataLoader:(() -> [TreeNodeData])?
    private var onDropTreeNode:(([TreeNodeData], Any?, String) -> Bool)?
    
    private var editable = false
    private var removable = false
    private var afterChange:(() -> Void)?
    
    private var checkable = false
    private var onCheckStateChanged:((Bool,Bool,String,String) -> Void)?
    
    private var coreMembers:[TreeNodeData] = []
    
    private var checkableItems:[String : CheckableTableCellView] = [:]
    
    public init(_ treeView: NSOutlineView,
                editable:Bool = false,
                removable:Bool = false,
                checkable:Bool = false,
                dataLoader:@escaping (() -> [TreeNodeData]),
                afterChange:(() -> Void)? = nil,
                onCheckStateChanged:((Bool,Bool,String,String) -> Void)? = nil,
                onDropTreeNode:(([TreeNodeData], Any?, String) -> Bool)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.dataLoader = dataLoader
        self.onDropTreeNode = onDropTreeNode
        self.treeView = treeView
        self.editable = editable
        self.removable = removable
        self.afterChange = afterChange
        self.checkable = checkable
        self.onCheckStateChanged = onCheckStateChanged
        self.treeView.dataSource = self
        self.treeView.delegate = self
        self.treeView.registerForDraggedTypes([.string])
        self.viewDidLoad()
        self.reloadNodes()
    }
        
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    public func reloadNodes() {
        print("tree view reload nodes")
        let checkedIds = self.getCheckedItems().map { $0.getId() }
        self.removeAllCheckableNodes()
        
        if let dataLoader = self.dataLoader {
            self.coreMembers = dataLoader()
        }
        
        self.treeView.reloadData()
        self.treeView.expandItem(nil, expandChildren: true)
        self.setCheckedItems(ids: checkedIds)
    }
    
    
    func getCheckedItems() -> [TreeNodeData] {
        var checkedGroups:[TreeNodeData] = []
        for cm in self.coreMembers {
            for g in cm.getChildren() {
                if g.checked() {
                    checkedGroups.append(g)
                }
            }
        }
//        for g in checkedGroups {
//            self.logger.log("checked \(Words.whose_family_group.fill(arguments: g.parent?.nickname ?? "", g.name))")
//        }
        return checkedGroups
    }
    
    func uncheckItems() {
        for node in self.checkableItems.values {
            node.checkbox.state = .off
            node.nodeData?.setCheckState(state: false)
        }
    }
    
    func setCheckedItems(ids:[String]) {
//        print("before set checked items, stored ids: \(self.checkableItems.keys)")
//        print("before set checked items, need check ids: \(ids)")
        for id in ids {
//            print("setCheckedItems id:\(id)")
            if let node = self.checkableItems[id] {
                node.checkbox.state = .on
                node.nodeData?.setCheckState(state: true)
            }
        }
        // verify
//        for cm in self.coreMembers {
//            for group in cm.groups {
//                print("setCheckedItems id:\(group.id) after set checked: \(group.isChecked)")
//            }
//        }
//        self.treeView.reloadData()
//        self.treeView.expandItem(nil, expandChildren: true)
        
    }
    
    func addCheckableNode(item: CheckableTableCellView) {
        if let nodeData = item.nodeData {
//            print("addCheckableNode id:\(nodeData.getId())")
            self.checkableItems[nodeData.getId()] = item
        }
    }
    
    func removeAllCheckableNodes() {
        self.checkableItems.removeAll()
    }
    
    func removeCheckableNode(id: String) {
        self.checkableItems.removeValue(forKey: id)
    }
}


extension CheckableTreeViewControllerWrapper: NSOutlineViewDataSource {

    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {

        if item == nil { // root
            return self.coreMembers.count
        }
        
        if let item = item as? TreeNodeData {
            if item.expandable() {
                return item.getChildren().count
            }
        }

        return 0 // anything else
    }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil { // root
            return self.coreMembers[index]
        }
        
        if let item = item as? TreeNodeData {
            if item.expandable() {
                return item.getChildren()[index]
            }
        }

        return "ERROR_PARENT_ITEM"
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? TreeNodeData {
            return item.expandable() && item.getChildren().count > 0
        }
        
        // otherwise
        return false
    }

    public func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let column = tableColumn, column.identifier.rawValue == "tree" {
            if let item = item as? TreeNodeData {
                return item.getText()
            }
        }
        return nil
    }
    
    public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return false
    }
    
    public func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem: Any?, proposedChildIndex: Int) -> NSDragOperation {
        outlineView.setDropRow(-1, dropOperation: .on)
        return .copy
    }
    
    public func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item destination: Any?, childIndex: Int) -> Bool {
        guard let draggedItem = info.draggingPasteboard.pasteboardItems?.first,
              let draggedData = draggedItem.data(forType: .string),
              let draggedString = String(data: draggedData, encoding: .utf8)
        else {return false}
        
        if let onDropTreeNode = self.onDropTreeNode {
            return onDropTreeNode(self.coreMembers, destination, draggedString)
        }else{
            return false
        }
    }
}

extension CheckableTreeViewControllerWrapper : NSOutlineViewDelegate {
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("treeItem"), owner: self) as! CheckableTableCellView
        if let item = item as? TreeNodeData {
            cell.table = outlineView
            cell.row = outlineView.row(forItem: item)
            cell.nodeData = item
            cell.textField!.stringValue = item.getText()
            cell.imageView!.image = item.nodeIcon()
            cell.checkbox.isEnabled = item.isCheckable() && self.checkable
            cell.checkbox.isHidden = !(item.isCheckable() && self.checkable)
//            print("refresh outlineView viewFor: id:\(item.id) check state: \(item.isChecked)")
            cell.checkbox.state = item.checked() ? .on : .off
            cell.removeButton.isEnabled = self.removable
            cell.removeButton.isHidden = !self.removable
            cell.removeButton.image = item.actionIcon()
            cell.editButton.isEnabled = item.isEditable() && self.editable
            cell.editButton.isHidden = !(item.isEditable() && self.editable)
            cell.textField?.isEditable = false
            cell.onCheckStateChanged = { oldValue, newValue, nodeType, nodeId in
                self.onCheckStateChanged?(oldValue, newValue, nodeType, nodeId)
            }
            cell.afterChange = {
                self.afterChange?()
            }
            if item.isCheckable() {
                self.addCheckableNode(item: cell)
            }
            return cell
        }
        
        return nil

    }
    
    public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return CGFloat(20)
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
//        if let _ = item as? CoreMember {
//            return true
//        }
//        if let _ = item as? PeopleGroup {
//            return true
//        }
        return false
    }
    
    public func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        return true
    }

    public func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        return true
    }
    
}
