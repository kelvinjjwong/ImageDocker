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
    var afterChange:(() -> Void)?
    
    @IBAction func onCheckClicked(_ sender: NSButton) {
        if let item = nodeData as? CoreMember {
            print("checkbox: core member: \(item.nickname) , state: \(sender.state == .on)")
            let ov = item.isChecked
            self.isChecked = (sender.state == .on)
            item.isChecked = (sender.state == .on)
            if ov != item.isChecked {
                self.onCheckStateChanged?(ov, item.isChecked, "CoreMember", item.id)
            }
        }
        if let item = nodeData as? PeopleGroup {
            print("checkbox: people group: \(item.name) , state: \(sender.state == .on)")
            let ov = item.isChecked
            self.isChecked = (sender.state == .on)
            item.isChecked = (sender.state == .on)
            if ov != item.isChecked {
                self.onCheckStateChanged?(ov, item.isChecked, "PeopleGroup", item.id)
            }
        }
        if let item = nodeData as? PeopleGroupMember {
            print("checkbox: people: \(item.id) , state: \(sender.state == .on)")
            let ov = item.isChecked
            self.isChecked = (sender.state == .on)
            item.isChecked = (sender.state == .on)
            if ov != item.isChecked {
                self.onCheckStateChanged?(ov, item.isChecked, "PeopleGroupMember", item.id)
            }
        }
    }
    
    @IBAction func onRemoveClicked(_ sender: NSButton) { // on update or remove, shared button
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
            
            // save to db, append group to core member
            if let persisted_groupId = FaceDao.default.saveFamily(name: peopleGroup.name, type: PeopleGroup.default_group_category, owner: item.id) {
                peopleGroup.id = persisted_groupId
            }
            
            
            if let table = self.table {
                table.deselectAll(nil)
                table.reloadData()
            }
            self.afterChange?()
            
        }
        if let item = nodeData as? PeopleGroup {
            print("remove people group: \(item.name) , state: \(sender.state == .on)")
            
            // delete people group
            
            if let coreMember = item.parent {
                coreMember.groups.removeAll { group in
                    return group.id == item.id
                }
                
                // save to db, delete group and all group members
                let _ = FaceDao.default.deleteFamily(id: item.id)
                
                if let table = self.table {
                    table.deselectAll(nil)
                    table.reloadData()
                }
                self.afterChange?()
                
            }
        }
        if let item = nodeData as? PeopleGroupMember {
            print("remove people: \(item.id) , state: \(sender.state == .on)")
            
            if let peopleGroup = item.parent {
                peopleGroup.members.removeAll { member in
                    return member.id == item.id
                }
                
                // save to db, delete group member
                let _ = FaceDao.default.deleteFamilyMember(peopleId: item.id, familyId: peopleGroup.id)
                
                if let table = self.table {
                    table.deselectAll(nil)
                    table.reloadData()
                }
                self.afterChange?()
                
            }
        }
    }
    
    @IBAction func onEditClicked(_ sender: NSButton) {
        
        if let item = nodeData as? PeopleGroup {
            
            if self.isEditing {
                // save editing
                if let textField = self.textField, let editor = textField.currentEditor() {
                    textField.endEditing(editor)
                }
                self.textField?.isEditable = false
                self.isEditing = false
                self.editButton.image = Icons.edit
                
                let newGroupName = self.textField?.stringValue ?? item.name
                
                if newGroupName != item.name {
                    // save to db, change group name
                    if let family = FaceDao.default.getFamily(id: item.id) {
                        family.name = newGroupName
                        let _ = FaceDao.default.saveFamily(familyId: family.id, name: family.name, type: family.category ?? PeopleGroup.default_group_category, owner: family.owner)
                        
                        if let coreMember = item.parent {
                            for peopleGroup in coreMember.groups {
                                if peopleGroup.id == item.id {
                                    peopleGroup.name = newGroupName
                                }
                            }
                        }
                        
                        if let table = self.table {
                            table.deselectAll(nil)
                            table.reloadData()
                        }
                        self.afterChange?()
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
        }
    }
    
}
