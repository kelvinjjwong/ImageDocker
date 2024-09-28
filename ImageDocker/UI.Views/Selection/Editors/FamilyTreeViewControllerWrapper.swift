//
//  FamilyTreeViewControllerWrapper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/28.
//  Copyright © 2024 nonamecat. All rights reserved.
//
import Cocoa
import LoggerFactory

public class FamilyTreeViewControllerWrapper : NSViewController {
    
    private let logger = LoggerFactory.get(category: "FamilyTreeViewController")
    
    private var treeView: NSOutlineView!
    
    private var editable = false
    private var removable = false
    private var checkable = false
    
    private var onCheckStateChanged:((Bool,Bool,String,String) -> Void)?
    
    private var coreMembers:[CoreMember] = []
    
    private var checkableItems:[String : PeopleManageCheckableTableCellView] = [:]
    
    public init(_ treeView: NSOutlineView, editable:Bool = false, removable:Bool = false, checkable:Bool = false, onCheckStateChanged:((Bool,Bool,String,String) -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.treeView = treeView
        self.editable = editable
        self.removable = removable
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
    
    private func reloadNodes() {
        self.removeAllCheckableNodes()
        self.coreMembers = self.loadPeopleGroups()
        
        self.treeView.reloadData()
        self.treeView.expandItem(nil, expandChildren: true)
    }
    
    private func loadPeopleGroups() -> [CoreMember] {
        
        var peopleIdToPeople:[String:People] = [:]
        let people = FaceDao.default.getPeople()
        
        for p in people {
            peopleIdToPeople[p.id] = p
        }
        
        var familyIdToPeople:[String:[PeopleGroupMember]] = [:]
        let familyMembers = FaceDao.default.getFamilyMembers()
        for fm in familyMembers {
            if let family = familyIdToPeople[fm.familyId] {
                if let p = peopleIdToPeople[fm.peopleId] {
                    let pgm = PeopleGroupMember()
                    pgm.id = p.id
                    pgm.name = p.name
                    pgm.nickname = p.shortName ?? p.name
                    // FIXME: load pgm.isChecked from db
                    familyIdToPeople[fm.familyId]?.append(pgm)
                }
            }else{
                familyIdToPeople[fm.familyId] = []
                if let p = peopleIdToPeople[fm.peopleId] {
                    let pgm = PeopleGroupMember()
                    pgm.id = p.id
                    pgm.name = p.name
                    pgm.nickname = p.shortName ?? p.name
                    // FIXME: load pgm.isChecked from db
                    familyIdToPeople[fm.familyId]?.append(pgm)
                }
            }
        }
        
        var families:[String:[Family]] = [:]
        let fs = FaceDao.default.getFamilies()
        for f in fs {
            if let fam = families[f.owner] {
                families[f.owner]?.append(f)
            }else{
                families[f.owner] = []
                families[f.owner]?.append(f)
            }
        }
        
        var coreMembers:[CoreMember] = []
        let ms = FaceDao.default.getCoreMembers()
        for m in ms {
            let coreMember = CoreMember()
            coreMember.id = m.id
            coreMember.name = m.name
            coreMember.nickname = m.shortName ?? m.name
            coreMember.groups = []
            
            if let fam = families[coreMember.id] {
                for f in fam {
                    let group = PeopleGroup()
                    group.id = f.id
                    group.name = f.name
                    group.parent = coreMember
                    group.members = []
                    coreMember.groups.append(group)
                }
            }
            
            coreMembers.append(coreMember)
        }
        return coreMembers
        
    }
    
    func getCheckedItems() -> [PeopleGroup] {
        var checkedGroups:[PeopleGroup] = []
        for cm in self.coreMembers {
            for g in cm.groups {
                if g.isChecked {
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
    
    func addCheckableNode(item: PeopleManageCheckableTableCellView) {
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


extension FamilyTreeViewControllerWrapper: NSOutlineViewDataSource {

    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {

        if item == nil { // root
            return self.coreMembers.count
        }

        if let item = item as? CoreMember {
            return item.groups.count
        }
        
        if let item = item as? PeopleGroup {
            return item.members.count
        }

        return 0 // anything else
    }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil { // root
            return self.coreMembers[index]
        }

        if let item = item as? CoreMember {
            return item.groups[index]
        }
        
        if let item = item as? PeopleGroup {
            return item.members[index]
        }

        return "ERROR_PARENT_ITEM"
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? CoreMember {
            return item.groups.count > 0
        }
        
        if let item = item as? PeopleGroup {
            return item.members.count > 0
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
        
        var peopleGroupId = ""
        var peopleGroupName = ""
        if let peopleGroup = destination as? PeopleGroup {
            peopleGroupId = peopleGroup.id
            peopleGroupName = peopleGroup.name
        }else if let pgm = destination as? PeopleGroupMember {
            peopleGroupId = pgm.groupId
            peopleGroupName = pgm.groupName
        }else {
            return false
        }
        
        print("dragged \(draggedString) to group:\(peopleGroupName)")
        
        let json = JSON.init(parseJSON: draggedString)
        
        let newMember = PeopleGroupMember()
        newMember.id = json["id"].stringValue
        newMember.name = json["name"].stringValue
        newMember.nickname = json["nickName"].stringValue
        newMember.groupId = peopleGroupId
        newMember.groupName = peopleGroupName
        
        for coreMember in self.coreMembers {
            for peopleGroup in coreMember.groups {
                if peopleGroup.id == peopleGroupId {
                    if !peopleGroup.members.contains(where: { member in
                        return member.id == newMember.id
                    }){
                        newMember.parent = peopleGroup
                        peopleGroup.members.append(newMember)
                        
                        // save to db, append group member
                        let _ = FaceDao.default.saveFamilyMember(peopleId: newMember.id, familyId: peopleGroup.id)
                        
                        self.treeView.deselectAll(nil)
                        self.treeView.reloadData()
                        self.treeView.expandItem(nil, expandChildren: true)
                    }
                    break
                }
            }
        }
        
        return true
    }
}

extension FamilyTreeViewControllerWrapper : NSOutlineViewDelegate {
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("treeItem"), owner: self) as! PeopleManageCheckableTableCellView
        if let item = item as? CoreMember {
            cell.table = outlineView
            cell.row = outlineView.row(forItem: item)
            cell.nodeData = item
            cell.textField!.stringValue = item.getText()
            cell.imageView!.image = item.nodeIcon()
            cell.checkbox.isEnabled = item.isCheckable()
            cell.checkbox.isHidden = !item.isCheckable()
//            print("refresh outlineView viewFor: id:\(item.id) check state: \(item.isChecked)")
            cell.checkbox.state = item.isChecked ? .on : .off
            cell.removeButton.isEnabled = self.removable
            cell.removeButton.isHidden = !self.removable
            cell.removeButton.image = item.actionIcon()
            cell.editButton.isEnabled = false
            cell.editButton.isHidden = true
            cell.textField?.isEditable = false
            cell.onCheckStateChanged = { oldValue, newValue, nodeType, nodeId in
                self.onCheckStateChanged?(oldValue, newValue, nodeType, nodeId)
            }
            if item.isCheckable() {
                self.addCheckableNode(item: cell)
            }
            return cell
        }
        if let item = item as? PeopleGroup {
            cell.table = outlineView
            cell.row = outlineView.row(forItem: item)
            cell.nodeData = item
            cell.textField!.stringValue = item.getText()
            cell.imageView!.image = item.nodeIcon()
            cell.checkbox.isEnabled = item.isCheckable() && self.checkable
            cell.checkbox.isHidden = !(item.isCheckable() && self.checkable)
//            print("refresh outlineView viewFor: id:\(item.id) check state: \(item.isChecked)")
            cell.checkbox.state = item.isChecked ? .on : .off
            cell.removeButton.isEnabled = self.removable
            cell.removeButton.isHidden = !self.removable
            cell.removeButton.image = item.actionIcon()
            cell.editButton.isEnabled = self.editable
            cell.editButton.isHidden = !self.editable
            cell.textField?.isEditable = false
            cell.onCheckStateChanged = { oldValue, newValue, nodeType, nodeId in
                self.onCheckStateChanged?(oldValue, newValue, nodeType, nodeId)
            }
            if item.isCheckable() {
                self.addCheckableNode(item: cell)
            }
            return cell
        }
        if let item = item as? PeopleGroupMember {
            cell.table = outlineView
            cell.row = outlineView.row(forItem: item)
            cell.nodeData = item
            cell.textField!.stringValue = item.getText()
            cell.imageView!.image = item.nodeIcon()
            cell.checkbox.isEnabled = false
            cell.checkbox.isHidden = true
//            print("refresh outlineView viewFor: id:\(item.id) check state: \(item.isChecked)")
            cell.checkbox.state = item.isChecked ? .on : .off
            cell.removeButton.isEnabled = item.isCheckable() && self.removable
            cell.removeButton.isHidden = !(item.isCheckable() && self.checkable)
            cell.removeButton.image = item.actionIcon()
            cell.editButton.isEnabled = self.editable
            cell.editButton.isHidden = !self.editable
            cell.textField?.isEditable = false
            cell.onCheckStateChanged = { oldValue, newValue, nodeType, nodeId in
                self.onCheckStateChanged?(oldValue, newValue, nodeType, nodeId)
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

public protocol TreeNodeData {
    
    func getId() -> String
    
    func getText() -> String
    
    func setCheckState(state:Bool)
    
    func isCheckable() -> Bool
    
    func nodeIcon() -> NSImage
    
    func actionIcon() -> NSImage
}
