//
//  PeopleSelectionViewController.swift
//  ImageDocker
//
//  Created by kelvinwong on 2023/10/4.
//  Copyright © 2023 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class PeopleSelectionViewController: NSViewController {
    
    
    let logger = LoggerFactory.get(category: "PeopleSelectionViewController")
    
    @IBOutlet weak var btnApply: NSButton!
    
    @IBOutlet weak var treeView: NSOutlineView!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var lblMessage: NSTextField!
    
    var coreMembers:[CoreMember] = []
    
    fileprivate var accumulator:Accumulator?
    fileprivate var onApplyChanges: (() -> Void)?
    fileprivate var images:[ImageFile] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.treeView.dataSource = self
        self.treeView.delegate = self
        self.treeView.registerForDraggedTypes([.string])
    }
    
    func initView(images:[ImageFile], onApplyChanges: (() -> Void)? = nil ) {
        self.coreMembers = self.loadPeopleGroups()
        self.treeView.reloadData()
        self.treeView.expandItem(nil, expandChildren: true)
        
        self.onApplyChanges = onApplyChanges
        self.images = images
        
        self.progressIndicator.isHidden = true
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
            
            if let fam = families[coreMember.id] {
                for f in fam {
                    let group = PeopleGroup()
                    group.id = f.id
                    group.name = f.name
                    group.parent = coreMember
                    group.members = []
                    
                    
//                    if let groupMembers = familyIdToPeople[f.id] {
//                        group.members = groupMembers
//                        
//                        for pgm in group.members {
//                            pgm.groupId = group.id
//                            pgm.groupName = group.name
//                            pgm.parent = group
//                        }
//                    }
                    coreMember.groups.append(group)
                }
            }
            
            coreMembers.append(coreMember)
        }
        return coreMembers
        
    }
    
    @IBAction func onApplyClicked(_ sender: NSButton) {
        var checkedGroups:[PeopleGroup] = []
        for cm in self.coreMembers {
            for g in cm.groups {
                if g.isChecked {
                    checkedGroups.append(g)
                }
            }
        }
        for g in checkedGroups {
            print("checked \(Words.whose_family_group.fill(arguments: g.parent?.nickname ?? "", g.name))")
        }
        
        if checkedGroups.isEmpty {
            return
        }
        
        self.btnApply.isEnabled = false
        
        self.accumulator = Accumulator(target: self.images.count, indicator: self.progressIndicator, suspended: false, lblMessage: self.lblMessage)
        
        DispatchQueue.global().async {
            for image in self.images {
                if let img = image.imageData {
                    if let id = img.id {
                        for peopleGroup in checkedGroups {
                            if let owner = peopleGroup.parent {
                                let familyId = peopleGroup.id
                                let ownerId = owner.id
                                let _ = ImageRecordDao.default.storeImageFamily(imageId: img.id ?? "", familyId: familyId, ownerId: ownerId, familyName: peopleGroup.name, owner: owner.nickname)
                            }else{
                                self.logger.log(.error, "PeopleGroup.parent is empty: PeopleGroup:\(peopleGroup.name), Image.path:\(img.path)")
                            }
                        }
                    }else{
                        self.logger.log(.error, "image id is empty: Image.path:\(img.path)")
                    }
                    
                }
                
                DispatchQueue.main.async {
                    let _ = self.accumulator?.add("")
                }
            }
            DispatchQueue.main.async {
                self.btnApply.isEnabled = true
                if self.onApplyChanges != nil {
                    self.onApplyChanges!()
                }
            }
        }
    }
    
    
    init(){
        super.init(nibName: "PeopleSelectionViewController", bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


extension PeopleSelectionViewController: NSOutlineViewDataSource {

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

extension PeopleSelectionViewController : NSOutlineViewDelegate {
    
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
            cell.checkbox.isEnabled = true
            cell.checkbox.isHidden = false
            cell.removeButton.isEnabled = false
            cell.removeButton.isHidden = true
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
            cell.removeButton.isEnabled = false
            cell.removeButton.isHidden = true
            cell.removeButton.image = Icons.remove
            cell.textField?.isEditable = false
            return cell
        }
        
        return nil

    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
//        if let _ = item as? CoreMember {
//            return true
//        }
//        if let _ = item as? PeopleGroup {
//            return true
//        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        return true
    }
    
}
