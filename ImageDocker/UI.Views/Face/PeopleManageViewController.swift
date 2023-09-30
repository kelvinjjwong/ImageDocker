//
//  PeopleManageViewController.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/9/24.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa

class CoreMember {
    var id:String = ""
    var name:String = ""
    var nickname:String = ""
    
    var groups:[PeopleGroup] = []
}

class PeopleGroup {
    var id:String = ""
    var name:String = ""
    var parent:CoreMember? = nil
    var members:[PeopleGroupMember] = []
}

class PeopleGroupMember {
    var id:String = ""
    var name:String = ""
    var nickname:String = ""
    var groupId:String = ""
    var groupName:String = ""
    var parent:PeopleGroup? = nil
}

class PeopleManageViewController: NSViewController {
    
    fileprivate var selectedPeopleId = ""
    
    @IBOutlet weak var boxBio: NSBox!
    @IBOutlet weak var boxMemberOf: NSBox!
    @IBOutlet weak var lblId: NSTextField!
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblNickName: NSTextField!
    @IBOutlet weak var txtId: NSTextField!
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtNickName: NSTextField!
    
    @IBOutlet weak var chkCoreMember: NSButton!
    
    @IBOutlet weak var tblPeopleList: NSTableView!
    
    @IBOutlet weak var treeView: NSOutlineView!
    
    var coreMembers:[CoreMember] = []
    
    
    var peopleListController : SingleColumnTableViewController!
    
    func setupView() {
        self.boxBio.title = Words.bio.word()
        self.boxMemberOf.title = Words.member_of.word()
        self.chkCoreMember.title = Words.core_member.word()
        self.lblName.stringValue = Words.person_name.word()
        self.lblNickName.stringValue = Words.person_nick_name.word()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.treeView.dataSource = self
        self.treeView.delegate = self
        self.treeView.registerForDraggedTypes([.string])
        
        self.setupView()
        self.peopleListController = SingleColumnTableViewController(self.tblPeopleList)
        self.peopleListController.onClick = { value in
//            self.onFaceCategoryClicked(value)
            print("selected \(value)")
            if let person = FaceDao.default.getPerson(name: value) {
                self.selectedPeopleId = person.id
                self.txtId.stringValue = person.id
                self.txtName.stringValue = person.name
                self.txtNickName.stringValue = person.shortName ?? person.name
                
                if person.coreMember {
                    self.chkCoreMember.state = .on
                }else{
                    self.chkCoreMember.state = .off
                }
                self.chkCoreMember.isEnabled = true
            }else{
                self.selectedPeopleId = ""
                self.txtId.stringValue = ""
                self.txtName.stringValue = ""
                self.txtNickName.stringValue = ""
                
                self.chkCoreMember.state = .off
                self.chkCoreMember.isEnabled = false
            }
        }
    }
    
    @IBAction func onCheckCoreMember(_ sender: NSButton) {
        let state = ( sender.state == .on )
        if self.selectedPeopleId != "" {
            if let _ = FaceDao.default.getPerson(id: self.selectedPeopleId) {
                let _ = FaceDao.default.updatePersonIsCoreMember(id: self.selectedPeopleId, isCoreMember: state)
                self.reloadPeople()
            }
        }
    }
    
    func initView() {
        self.reloadPeople()
        self.coreMembers = self.loadPeopleGroups()
        self.treeView.reloadData()
        self.treeView.expandItem(nil, expandChildren: true)
    }
    
    func loadPeopleGroups() -> [CoreMember] {
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
                    familyIdToPeople[fm.familyId]?.append(pgm)
                }
            }else{
                familyIdToPeople[fm.familyId] = []
                if let p = peopleIdToPeople[fm.peopleId] {
                    let pgm = PeopleGroupMember()
                    pgm.id = p.id
                    pgm.name = p.name
                    pgm.nickname = p.shortName ?? p.name
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
            
            if let fam = families[coreMember.nickname] {
                for f in fam {
                    let group = PeopleGroup()
                    group.id = f.id
                    group.name = f.name
                    group.parent = coreMember
                    group.members = []
                    
                    
                    if let groupMembers = familyIdToPeople[f.id] {
                        group.members = groupMembers
                        
                        for pgm in group.members {
                            pgm.groupId = group.id
                            pgm.groupName = group.name
                            pgm.parent = group
                        }
                    }
                    coreMember.groups.append(group)
                }
            }
            
            coreMembers.append(coreMember)
        }
        return coreMembers
        
    }
    
    func reloadPeople() {
        var names:[String] = []
        let people = FaceDao.default.getPeople()
        for p in people {
            let json = """
{"id": "\(p.id)", "name": "\(p.name)", "nickName": "\(p.shortName ?? p.name)"}
"""
            names.append(json)
        }
        self.peopleListController.isJSON = true
        self.peopleListController.jsonKey = "nickName"
        self.peopleListController.load(names)
    }
    
    @IBAction func onTreeViewDoubleClicked(_ sender: NSOutlineView) {
        let item = sender.item(atRow: sender.clickedRow)
        
        if let item = item as? PeopleGroup {
            print("double clicked people group \(item.name)")
            let view = sender.view(atColumn: 0, row: sender.clickedRow, makeIfNecessary: false)
            if let cellView = view as? PeopleManageCheckableTableCellView {
                cellView.textField?.isEditable = true
                sender.editColumn(0, row: sender.clickedRow, with: nil, select: false)
                cellView.isEditing = true
                cellView.removeButton.image = NSImage(named: NSImage.menuOnStateTemplateName)
            }
        }
    }
    
    
    init(){
        super.init(nibName: "PeopleManageViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}



class PeopleManageCheckableTableCellView: NSTableCellView {
    
    @IBOutlet weak var checkbox: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    
    var isEditing = false
    var table:NSTableView? = nil
    var nodeData:Any? = nil
    
    @IBAction func onCheckClicked(_ sender: NSButton) {
        if let item = nodeData as? CoreMember {
            print("checkbox: core member: \(item.nickname) , state: \(sender.state == .on)")
        }
        if let item = nodeData as? PeopleGroup {
            print("checkbox: people group: \(item.name) , state: \(sender.state == .on)")
        }
        if let item = nodeData as? PeopleGroupMember {
            print("checkbox: people: \(item.id) , state: \(sender.state == .on)")
        }
    }
    
    @IBAction func onRemoveClicked(_ sender: NSButton) {
        if let item = nodeData as? CoreMember {
            print("add empty people group for: \(item.nickname)")
            let idx = item.groups.count + 1
            let groupId = "\(item.id)_group_\(idx)"
            let groupName = "\(Words.new_people_group.word()) \(idx)"
            let peopleGroup = PeopleGroup()
            peopleGroup.id = groupId
            peopleGroup.name = groupName
            peopleGroup.parent = item
            peopleGroup.members = []
            
            item.groups.append(peopleGroup)
            
            // TODO: save to db, append group to core member
            
            if let table = self.table {
                table.deselectAll(nil)
                table.reloadData()
            }
            
        }
        if let item = nodeData as? PeopleGroup {
            print("remove people group: \(item.name) , state: \(sender.state == .on)")
            
            if self.isEditing {
                // save editing
                if let textField = self.textField, let editor = textField.currentEditor() {
                    textField.endEditing(editor)
                }
                self.textField?.isEditable = false
                self.removeButton.image = Icons.remove
                
                let newGroupName = self.textField?.stringValue ?? item.name
                
                if newGroupName != item.name {
                    // TODO: save to db, change group name
                }
                
            }else{
                // delete people group
                
                if let coreMember = item.parent {
                    coreMember.groups.removeAll { group in
                        return group.id == item.id
                    }
                    
                    // TODO: save to db, delete group and all group members
                    
                    if let table = self.table {
                        table.deselectAll(nil)
                        table.reloadData()
                    }
                    
                }
                
            }
        }
        if let item = nodeData as? PeopleGroupMember {
            print("remove people: \(item.id) , state: \(sender.state == .on)")
            
            if let peopleGroup = item.parent {
                peopleGroup.members.removeAll { member in
                    return member.id == item.id
                }
                
                // TODO: save to db, delete group member
                
                if let table = self.table {
                    table.deselectAll(nil)
                    table.reloadData()
                }
                
            }
        }
    }
    
}



extension PeopleManageViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {

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

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
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
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? CoreMember {
            return item.groups.count > 0
        }
        
        if let item = item as? PeopleGroup {
            return item.members.count > 0
        }
        
        // otherwise
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let column = tableColumn, column.identifier.rawValue == "tree" {
            if let item = item as? CoreMember {
                return item.nickname
            }
            if let item = item as? PeopleGroup {
                return item.name
            }
            if let item = item as? PeopleGroupMember {
                return item.nickname
            }
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem: Any?, proposedChildIndex: Int) -> NSDragOperation {
        outlineView.setDropRow(-1, dropOperation: .on)
        return .copy
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item destination: Any?, childIndex: Int) -> Bool {
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
                        self.treeView.deselectAll(nil)
                        self.treeView.reloadData()
                        self.treeView.expandItem(nil, expandChildren: true)
                        // TODO: save to db, append group member
                    }
                    break
                }
            }
        }
        
        return true
    }
}

extension PeopleManageViewController : NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("treeItem"), owner: self) as! PeopleManageCheckableTableCellView
        if let item = item as? CoreMember {
            cell.table = outlineView
            cell.nodeData = item
            cell.textField!.stringValue = item.nickname
            cell.imageView!.image = Icons.person
            cell.checkbox.isEnabled = false
            cell.checkbox.isHidden = true
            cell.removeButton.isEnabled = true
            cell.removeButton.isHidden = false
            cell.removeButton.image = NSImage.init(named: NSImage.addTemplateName)
            cell.textField?.isEditable = false
            return cell
        }
        if let item = item as? PeopleGroup {
            cell.table = outlineView
            cell.nodeData = item
            cell.textField!.stringValue = item.name
            cell.imageView!.image = Icons.people
            cell.checkbox.isEnabled = false
            cell.checkbox.isHidden = true
            cell.removeButton.isEnabled = true
            cell.removeButton.isHidden = false
            cell.removeButton.image = Icons.remove
            cell.textField?.isEditable = false
            return cell
        }
        if let item = item as? PeopleGroupMember {
            cell.table = outlineView
            cell.nodeData = item
            cell.textField!.stringValue = item.nickname
            cell.imageView!.image = Icons.smile
            cell.checkbox.isEnabled = false
            cell.checkbox.isHidden = true
            cell.removeButton.isEnabled = true
            cell.removeButton.isHidden = false
            cell.removeButton.image = Icons.remove
            cell.textField?.isEditable = false
            return cell
        }
        
        return nil

    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        if let _ = item as? CoreMember {
            return true
        }
        if let _ = item as? PeopleGroup {
            return true
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        return true
    }
    
}
