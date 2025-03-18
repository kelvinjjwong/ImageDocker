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
    
    private let logger = LoggerFactory.get(category: "CheckableTreeView")
    
    private var treeView: NSOutlineView!
    
    private var dataLoader:(() -> [TreeNodeData])?
    private var onDropTreeNode:(([TreeNodeData], Any?, String) -> Bool)?
    
    private var editable = false
    private var removable = false
    
    private var isEditInline = true
    private var onEditNodeInline:((String,TreeNodeData) -> Bool)?
    private var onEditNode:((TreeNodeData) -> Bool)?
    private var onRemoveNode:((TreeNodeData) -> Bool)?
    
    private var afterChange:(() -> Void)?
    
    private var checkable = false
    private var onCheckStateChanged:((Bool,Bool,String,String) -> Void)?
    
    private var coreMembers:[TreeNodeData] = []
    
    private var checkableItems:[String : (TreeNodeData, CheckableTableCellView?)] = [:] // FIXME: add cache to fix when cell view has not init (has not scrolled down to)
    
    public init(_ treeView: NSOutlineView,
                editable:Bool = false,
                removable:Bool = false,
                checkable:Bool = false,
                isEditNodeInline:Bool = true,
                dataLoader:@escaping (() -> [TreeNodeData]),
                onEditNodeInline:((String,TreeNodeData) -> Bool)? = nil,
                onEditNode:((TreeNodeData) -> Bool)? = nil,
                onRemoveNode:((TreeNodeData) -> Bool)? = nil,
                afterChange:(() -> Void)? = nil,
                onCheckStateChanged:((Bool,Bool,String,String) -> Void)? = nil,
                onDropTreeNode:(([TreeNodeData], Any?, String) -> Bool)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.dataLoader = dataLoader
        self.onDropTreeNode = onDropTreeNode
        self.treeView = treeView
        self.editable = editable
        self.removable = removable
        self.isEditInline = isEditNodeInline
        self.onEditNodeInline = onEditNodeInline
        self.onEditNode = onEditNode
        self.onRemoveNode = onRemoveNode
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
        self.logger.log(.trace, "tree view reload nodes")
        let checkedIds = self.getCheckedItems().map { $0.getId() }
        self.removeAllCheckableNodes()
        
        if let dataLoader = self.dataLoader {
            self.coreMembers = dataLoader()
        }
        
        self.treeView.reloadData()
        self.treeView.expandItem(nil, expandChildren: true)
        self.setCheckedItems(ids: checkedIds)
    }
    
    public func refresh() {
        self.treeView.reloadData()
    }
    
    func setTreeNodeDataCheckState(id:String, state:Bool) {
        for c in self.coreMembers {
            if c.getId() == id {
                c.setCheckState(state: state)
            }
            for g in c.getChildren() {
                if g.getId() == id {
                    g.setCheckState(state: state)
                }
                for m in g.getChildren() {
                    if m.getId() == id {
                        m.setCheckState(state: state)
                    }
                }
            }
        }
    }
    
    func getTreeNodeDataCheckState(id:String) -> Bool {
        for c in self.coreMembers {
            if c.getId() == id {
                return c.checked()
            }
            for g in c.getChildren() {
                if g.getId() == id {
                    return g.checked()
                }
                for m in g.getChildren() {
                    if m.getId() == id {
                        return m.checked()
                    }
                }
            }
        }
        return false
    }
    
    
    func getCheckedItems() -> [TreeNodeData] {
        var checkedGroups:[TreeNodeData] = []
        for cm in self.coreMembers {
            for g in cm.getChildren() {
                if g.checked() {
                    checkedGroups.append(g)
                    for m in g.getChildren() {
                        if m.checked() {
                            checkedGroups.append(m)
                        }
                    }
                }
            }
        }
//        for g in checkedGroups {
//            self.logger.log(.trace, "checked \(Words.whose_family_group.fill(arguments: g.parent?.nickname ?? "", g.name))")
//        }
        return checkedGroups
    }
    
    func uncheckItems() {
        for (node, cell) in self.checkableItems.values {
            cell?.checkbox.state = .off
            node.setCheckState(state: false)
        }
    }
    
    func setCheckedItems(nodes:[TreeNodeData]) {
        for node in nodes {
            self.addCheckableNode(node: node, item: nil)
        }
    }
    
    func getCheckableTreeNodes(ids:[String]) -> [TreeNodeData] {
        var result:[TreeNodeData] = []
        for c in self.coreMembers {
            for g in c.getChildren() {
                if ids.contains(g.getId()) {
                    result.append(g)
                }
            }
        }
        return result
    }
    
    func setCheckedItems(ids:[String]) {
        self.setCheckedItems(nodes: self.getCheckableTreeNodes(ids: ids))
        
//        self.logger.log(.trace, "before set checked items, stored ids: \(self.checkableItems.keys)")
//        for id in self.checkableItems.keys {
//            self.logger.log(.trace, "id:\(id) text:\(self.checkableItems[id]?.0.getText())")
//        }
//        self.logger.log(.trace, "before set checked items, need check ids: \(ids)")
        for id in ids {
//            self.logger.log(.trace, "want to setCheckedItems id:\(id) to true")
            if let (node, cell) = self.checkableItems[id] {
                node.setCheckState(state: true)
            }
        }
        self.treeView.reloadData()
        // verify
//        for cm in self.coreMembers {
//            for group in cm.getChildren() {
//                self.logger.log(.trace, "setCheckedItems id:\(group.getId()) \(group.getText()) after set checked: \(group.checked())")
//            }
//        }
//        self.treeView.reloadData()
//        self.treeView.expandItem(nil, expandChildren: true)
        
    }
    
    public func addCheckableNode(node:TreeNodeData, item: CheckableTableCellView?) {
//        self.logger.log(.trace, "addCheckableNode id:\(node.getId()) \(node.getText()) item not nil:\(item != nil)")
        if let (n, c) = self.checkableItems[node.getId()] {
            // existing stored
            if c == nil { // overwrite
                self.checkableItems[node.getId()] = (node, item)
            }
        }else{
            // not existing stored
            self.checkableItems[node.getId()] = (node, item)
        }
    }
    
    public func getCheckableNode(id:String) -> (TreeNodeData, CheckableTableCellView?)? {
        return self.checkableItems[id]
    }
    
    public func getCheckableNodeIds() -> [String] {
        return self.checkableItems.keys.sorted()
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
//            self.logger.log(.trace, "refresh outlineView viewFor: id:\(item.id) check state: \(item.isChecked)")
            
            cell.checkbox.state = self.getTreeNodeDataCheckState(id: item.getId()) ? .on : .off
//            if let (node, _) = self.checkableItems[item.getId()] {
//                cell.checkbox.state = node.checked() ? .on : .off
//            }else{
//                cell.checkbox.state = item.checked() ? .on : .off
//            }
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
            cell.isEditInline = self.isEditInline
            cell.onEditNodeInline = { newValue, treeNode in
                return self.onEditNodeInline?(newValue, treeNode) ?? false
            }
            cell.onEditNode = { treeNode in
                return self.onEditNode?(treeNode) ?? false
            }
            cell.onRemoveNode = { treeNode in
                return self.onRemoveNode?(treeNode) ?? false
            }
            if item.isCheckable() {
                self.addCheckableNode(node: item, item: cell)
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
