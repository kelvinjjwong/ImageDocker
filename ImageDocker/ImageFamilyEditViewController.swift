//
//  ImageFamilyEditViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/3.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory
import nonamecat_swift_commons

class ImageFamilyEditViewController : NSViewController, ImageFlowListItemEditor {
    
    let logger = LoggerFactory.get(category: "ImageEdit", subCategory: "Family")
    
    @IBOutlet weak var tabs: NSTabView!
    
    // MARK: - VIEW
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var stackView: NSStackView!
    private var window:NSWindow? = nil
    private var tableViewController:TwoColumnTableViewController? = nil
    
    var flowListItems:[String:ImageFlowListItemViewController] = [:]
    
    // MARK: - EDIT
    
    @IBOutlet weak var editTableView: NSTableView!
    @IBOutlet weak var treeView: NSOutlineView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var btnApply: NSButton!
    var onApplyCompleted: (() -> Void)?
    
    private var editTableViewController:TwoColumnTableViewController? = nil
    var treeViewController: CheckableTreeViewControllerWrapper? = nil
    
    // MARK: - MANAGE
    
    @IBOutlet weak var manageTreeView: NSOutlineView!
    var manageTreeViewController: CheckableTreeViewControllerWrapper? = nil
    
    // MARK: - INIT
    
    init() {
        super.init(nibName: "ImageFamilyEditViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        stackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        self.tableViewController = TwoColumnTableViewController()
        self.tableViewController?.table = self.tableView
        
        self.editTableViewController = TwoColumnTableViewController()
        self.editTableViewController?.table = self.editTableView
        
        self.treeViewController = CheckableTreeViewControllerWrapper(self.treeView, checkable: true, dataLoader: {
            return self.loadPeopleGroups()
        }, onCheckStateChanged: { oldValue, newValue, nodeType, nodeId in
            self.logger.log(.trace, "tree node changed: \(nodeType) - \(nodeId) - changed from \(oldValue) to \(newValue)")
            self.updateCheckedAmount()
        })
        self.progressIndicator.isHidden = true
        self.updateCheckedAmount()
        
        self.manageTreeViewController = CheckableTreeViewControllerWrapper(self.manageTreeView, editable: true, removable: true, dataLoader: {
            return self.loadPeopleGroups()
        }, onEditNodeInline: { newValue, treeNode in
            
            // save to db, change group name
            if let item = treeNode as? PeopleGroup, let family = FaceDao.default.getFamily(id: item.getId()) {
                family.name = newValue
                let _ = FaceDao.default.saveFamily(familyId: family.id, name: family.name, type: family.category ?? PeopleGroup.default_group_category, owner: family.owner)
                
                if let coreMember = item.parent {
                    for peopleGroup in coreMember.groups {
                        if peopleGroup.getId() == item.getId() {
                            peopleGroup.name = newValue
                        }
                    }
                }
                
                return true
            }
            return false
            
        }, onRemoveNode: { treeNode in
            
            if let item = treeNode as? CoreMember {
                self.logger.log(.trace, "add empty people group for: \(item.nickname)")
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
                
                return true
                
            }
            if let item = treeNode as? PeopleGroup {
                self.logger.log(.trace, "remove people group: \(item.name)")
                
                // delete people group
                
                if let coreMember = item.parent {
                    coreMember.groups.removeAll { group in
                        return group.id == item.id
                    }
                    
                    // save to db, delete group and all group members
                    let executeState = FaceDao.default.deleteFamily(id: item.id)
                    
                    if executeState == .OK {
                        return true
                    }
                    
                }
            }
            if let item = treeNode as? PeopleGroupMember {
                self.logger.log(.trace, "remove people: \(item.id)")
                
                if let peopleGroup = item.parent {
                    peopleGroup.members.removeAll { member in
                        return member.id == item.id
                    }
                    
                    // save to db, delete group member
                    let executeState = FaceDao.default.deleteFamilyMember(peopleId: item.id, familyId: peopleGroup.id)
                    
                    if executeState == .OK {
                        return true
                    }
                    
                }
            }
            return false
            
        }, afterChange: {
            self.logger.log(.trace, "after change tree view")
            self.treeViewController?.reloadNodes()
        })
        
        self.btnApply.title = Words.notes_apply.word()
        
        self.tabs.tabViewItems[0].label = Words.editor_tab_view.word()
        self.tabs.tabViewItems[1].label = Words.editor_tab_edit.word()
        self.tabs.tabViewItems[2].label = Words.editor_tab_manage.word()
        
    }
    
    
    // MARK: - VIEW
    
    func collectImagesDiff() {
        DispatchQueue.global().async {
            var array:[[String]] = []
            for vc in self.flowListItems.values {
                if let image = vc.data {
                    array.append(self.getText(image: image))
                }
            }
            
            let diff = ArrayDiff()
            let occurances = diff.calculateOccurance(array)
            
            var grid:[(String, String)] = []
            for o in occurances.sorted(by: { d1, d2 in
                return d1.value > d2.value
            }) {
                grid.append(("\(String(format: "%0.2f", o.value * 100)) %", o.key))
            }
            
            DispatchQueue.main.async {
                self.tableViewController?.load(grid)
                self.editTableViewController?.load(grid)
            }
        }
    }
    
    func getText(image:Image) -> [String] {
        if let id = image.id {
            let families = ImageFamilyDao.default.getFamilies(imageId: id)
            if families.count > 0 {
                var list:[String] = []
                for f in families {
                    list.append(f.familyName.hasPrefix("自拍") ? Words.whose_family.fill(arguments: f.owner, f.familyName) : Words.who_and_family.fill(arguments: f.owner, f.familyName))
                }
                return list.sorted()
            }else{
                return [Words.empty_family.word()]
            }
        }else{
            return [Words.empty_family.word()]
        }
    }
    
    // MARK: STACK ITEMS
    
    /// Used to add a particular view controller as an item to our stack view.
    func addImageFlowListItem(imageFile:ImageFile) {
        
        let storyboard = NSStoryboard(name: "ImageFlowListItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "ImageFlowListItem") as! ImageFlowListItemViewController
        
        if let image = imageFile.imageData {
            
            stackView.addArrangedSubview(viewController.view)
            //addChildViewController(viewController)
            viewController.initView(image: image,
                                    nsImage: imageFile.image,
                                    dateTime: "\(imageFile.photoTakenTime())",
                                    content: self.getText(image: image).joined(separator: ", "))
            
            self.flowListItems[image.id ?? ""] = viewController
//            self.logger.log(.trace, "addImageFlowListItem, id:\(image.id ?? "") , total:\(self.flowListItems.count)")
            self.collectImagesDiff()
            self.checkLinkedFamilies()
        }
        
    }
    
    func removeImageFlowListItem(imageFile:ImageFile) {
        if let image = imageFile.imageData {
            if let vc = self.flowListItems[image.id ?? ""] {
                NSLayoutConstraint.deactivate(vc.view.constraints)
                self.stackView.removeView(vc.view)
            }
            self.flowListItems.removeValue(forKey: image.id ?? "")
            
            self.collectImagesDiff()
            self.checkLinkedFamilies()
        }
    }
    
    
    func removeAllImageFlowListItems() {
        for vc in self.flowListItems.values {
            NSLayoutConstraint.deactivate(vc.view.constraints)
            self.stackView.removeView(vc.view)
        }
        self.flowListItems.removeAll()
        
        self.collectImagesDiff()
        self.checkLinkedFamilies()
    }
    
    // MARK: - EDIT
    
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
    
    func getLinkedFamilyIds() -> [String] {
        let imageIds = self.flowListItems.keys.sorted()
        
        return ImageFamilyDao.default.getFamilyIds(imageIds: imageIds)
    }
    
    func checkLinkedFamilies() {
        self.treeViewController?.uncheckItems()
        self.treeViewController?.setCheckedItems(ids: self.getLinkedFamilyIds())
        self.updateCheckedAmount()
    }
    
    func updateCheckedAmount() {
        if let vc = self.treeViewController {
            self.progressLabel.stringValue = Words.selected_items.fill(arguments: "\(vc.getCheckedItems().count)")
        }
    }
    
    private func onDragFamilyDropToTreeNode(treeNodes:[TreeNodeData], destination:Any?, draggedString:String) -> Bool {
        let json = JSON.init(parseJSON: draggedString)
        
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
        self.logger.log(.trace, "dragged \(draggedString) to group:\(peopleGroupName)")
        
        let newMember = PeopleGroupMember()
        newMember.id = json["id"].stringValue
        newMember.name = json["name"].stringValue
        newMember.nickname = json["nickName"].stringValue
        newMember.groupId = peopleGroupId
        newMember.groupName = peopleGroupName
        
        for coreMember in treeNodes {
            for peopleGroup in coreMember.getChildren() {
                if peopleGroup.getId() == peopleGroupId {
                    if !peopleGroup.getChildren().contains(where: { member in
                        return member.getId() == newMember.id
                    }){
                        newMember.setParent(peopleGroup)
                        peopleGroup.addChild(newMember)
                        
                        // save to db, append group member
                        let _ = FaceDao.default.saveFamilyMember(peopleId: newMember.id, familyId: peopleGroup.getId())
                        
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
    
    fileprivate var accumulator:Accumulator?
    
    @IBAction func onButtonApplyClicked(_ sender: NSButton) {
        let imageIds = self.flowListItems.keys.sorted()
        
        if imageIds.isEmpty {
            return
        }
        
        let checkedGroups = self.treeViewController?.getCheckedItems() ?? []
        
//        let checkedGroupIds = checkedGroups.map { g in
//            return g.id
//        }
//        self.logger.log(.trace, "selected images: \(imageIds)")
//        self.logger.log(.trace, "checked families: \(checkedGroupIds)")
        
        if Alert.dialogOKCancel(question: Words.dialog_update_images.word()) {
            self.btnApply.isEnabled = false
            
            self.accumulator = Accumulator(target: imageIds.count, indicator: self.progressIndicator, suspended: false, lblMessage: self.progressLabel)
            
            DispatchQueue.global().async {
                for imageId in imageIds {
                    guard imageId != "" else {continue}
                    
                    // unlink families
                    let _ = ImageRecordDao.default.unlinkImageFamilies(imageId: imageId)
                    
                    // link families
                    for peopleGroup in checkedGroups {
                        if let peopleGroup = peopleGroup as? PeopleGroup {
                            if let owner = peopleGroup.parent {
                                let familyId = peopleGroup.getId()
                                let ownerId = owner.getId()
                                let _ = ImageRecordDao.default.storeImageFamily(imageId: imageId, familyId: familyId, ownerId: ownerId, familyName: peopleGroup.name, owner: owner.nickname)
                            }else{
                                self.logger.log(.error, "PeopleGroup.parent is empty: PeopleGroup:\(peopleGroup.name), Image.id:\(imageId)")
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        let _ = self.accumulator?.add("")
                    }
                }
                DispatchQueue.main.async {
                    self.btnApply.isEnabled = true
                    self.onApplyCompleted?()
                }
            }
        }
    }
    
}

protocol ImageFlowListItemEditor {
    func addImageFlowListItem(imageFile:ImageFile)
    func removeAllImageFlowListItems()
    func removeImageFlowListItem(imageFile:ImageFile)
}
