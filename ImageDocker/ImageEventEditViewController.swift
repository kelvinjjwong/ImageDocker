//
//  ImageEventEditViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/3.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory
import nonamecat_swift_commons

class ImageEventEditViewController : NSViewController, ImageFlowListItemEditor {
    
    let logger = LoggerFactory.get(category: "ImageEdit", subCategory: "Event")
    
    @IBOutlet weak var tabs: NSTabView!
    
    // MARK: - VIEW
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var stackView: NSStackView!
    private var window:NSWindow? = nil
    private var tableViewController:TwoColumnTableViewController? = nil
    
    var flowListItems:[String:ImageFlowListItemViewController] = [:]
    
    // MARK: - EDIT
    @IBOutlet weak var editTreeView: NSOutlineView!
    @IBOutlet weak var editTableView: NSTableView!
    @IBOutlet weak var btnApply: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressLabel: NSTextField!
    var onApplyCompleted: (() -> Void)?
    
    private var editTableViewController:TwoColumnTableViewController? = nil
    var treeViewController: CheckableTreeViewControllerWrapper? = nil
    
    
    // MARK: - MANAGE
    @IBOutlet weak var manageEventBox: NSBox!
    @IBOutlet weak var lblEventName: NSTextField!
    @IBOutlet weak var txtEventName: NSTextField!
    @IBOutlet weak var lblEventCategory: NSTextField!
    @IBOutlet weak var ddlEventCategory: NSComboBox!
    @IBOutlet weak var btnSaveEvent: NSButton!
    @IBOutlet weak var btnDeleteEvent: NSButton!
    @IBOutlet weak var tblCheckableOwners: NSTableView!
    
    @IBOutlet weak var tblEvents: NSTableView!
    @IBOutlet weak var txtSearchEvent: NSSearchField!
    @IBOutlet weak var btnReloadEvents: NSButton!
    
    var ownersTableController : DictionaryTableViewController!
    var eventCategoryListController : TextListViewPopupController!
    var manageTableViewController : SearchableTableViewController!
    var managingEventId:String = ""
    
    init() {
        super.init(nibName: "ImageEventEditViewController", bundle: nil)
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
        
        self.treeViewController = CheckableTreeViewControllerWrapper(self.editTreeView, checkable: true, dataLoader: {
            return self.loadEvents()
        }, onCheckStateChanged: { oldValue, newValue, nodeType, nodeId in
            print("tree node changed: \(nodeType) - \(nodeId) - changed from \(oldValue) to \(newValue)")
            self.updateCheckedAmount()
        })
        self.progressIndicator.isHidden = true
        self.updateCheckedAmount()
        
        self.ownersTableController = DictionaryTableViewController(self.tblCheckableOwners)
        self.ownersTableController.enableCheckboxes()
        self.ownersTableController.load(self.loadOwners(), afterLoaded: {
        })
        
        self.eventCategoryListController = TextListViewPopupController(self.ddlEventCategory)
        self.eventCategoryListController.load(self.getEventCategories())
        
        self.manageTableViewController = SearchableTableViewController(table: self.tblEvents,
                                                                       search: self.txtSearchEvent,
                                                                       onReloadRecords: { keyword in
            var events:[ImageEvent] = []
            if keyword == "" {
                events = EventDao.default.getEvents()
            }else{
                events = EventDao.default.getEvents(byName: keyword)
            }
            var results:[[String:String]] = []
            for e in events {
                var r:[String:String] = [:]
                r["category"] = e.category
                r["name"] = e.name
                var owners:[String] = []
                if e.ownerNickname != "" {owners.append(e.ownerNickname)}
                if e.owner2Nickname != "" {owners.append(e.owner2Nickname)}
                if e.owner3Nickname != "" {owners.append(e.owner3Nickname)}
                r["owners"] = owners.joined(separator: ",")
                results.append(r)
            }
            return results
        }, onSelectRow: { record in
            self.txtEventName.stringValue = record["name"] ?? ""
            self.eventCategoryListController.select(record["category"] ?? "")
            let owners = (record["owners"] ?? "").components(separatedBy: ",")
            self.ownersTableController.setCheckedItems(column: "name", from: owners)
            
            self.managingEventId = record["name"] ?? ""
        })
        
        self.btnApply.title = Words.notes_apply.word()
        self.btnSaveEvent.title = Words.dialog_save.word()
        self.btnDeleteEvent.title = Words.dialog_delete.word()
        self.btnReloadEvents.title = Words.dialog_reload.word()
        
        self.tabs.tabViewItems[0].label = Words.editor_tab_view.word()
        self.tabs.tabViewItems[1].label = Words.editor_tab_edit.word()
        self.tabs.tabViewItems[2].label = Words.editor_tab_manage.word()
    }
    
    // MARK: - VIEW
    
    // MARK: STACK ITEMS
    
    func collectImagesDiff() {
        DispatchQueue.global().async {
            var array:[[String]] = []
            for vc in self.flowListItems.values {
                if let image = vc.data {
                    let t = self.getText(image: image)
                    array.append([t])
                }
            }
            let diff = ArrayDiff()
            let occurances = diff.calculateOccurance(array)
            
            var grid:[(String, String)] = []
            for o in occurances.sorted(by: { d1, d2 in
                return d1.value > d2.value
            }) {
                grid.append(("\(o.value * 100) %", o.key))
            }
            print("collectImagesDiff:")
            print(grid)
            
            DispatchQueue.main.async {
                self.tableViewController?.load(grid)
                self.editTableViewController?.load(grid)
            }
        }
    }
    
    func getText(image:Image) -> String {
        return image.event ?? Words.empty_event.word()
    }
    
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
                                    content: self.getText(image: image))
            
            self.flowListItems[image.id ?? ""] = viewController
            
            self.collectImagesDiff()
            self.checkLinkedEvents()
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
            self.checkLinkedEvents()
        }
    }
    
    
    func removeAllImageFlowListItems() {
        for vc in self.flowListItems.values {
            NSLayoutConstraint.deactivate(vc.view.constraints)
            self.stackView.removeView(vc.view)
        }
        self.flowListItems.removeAll()
        
        self.collectImagesDiff()
        self.checkLinkedEvents()
    }
    
    // MARK: - EDIT
    
    private func loadEvents() -> [CoreMember] {
        
        var coreMembers:[CoreMember] = []
        let ms = FaceDao.default.getCoreMembers()
        for m in ms {
            let coreMember = CoreMember()
            coreMember.id = m.id
            coreMember.name = m.name
            coreMember.nickname = m.shortName ?? m.name
            coreMember.groups = []
            
            let events = EventDao.default.getEventsByOwner(ownerId: m.id)

            for (category, eventName, owner1, owner2, owner3) in events {
                var owners:[String] = []
                if owner1 != "" {owners.append(owner1)}
                if owner2 != "" {owners.append(owner2)}
                if owner3 != "" {owners.append(owner3)}
                let group = PeopleGroup()
//                group.id = "\(owners.joined(separator: ","))_\(eventName)"
                group.id = eventName
                
                var partOwner = "(\(owners.joined(separator: ",")))"
                if coreMember.getText() == owners.joined(separator: ",") {
                    partOwner = ""
                }
                var partCategory = "[\(category)]"
                if coreMember.getText() == category || eventName.contains(find: category) {
                    partCategory = ""
                }
                var name = "\(eventName) \(partOwner) \(partCategory)".trimmingCharacters(in: .whitespacesAndNewlines)
                if name.count > 30 {
                    name = "\(name[0..<30])..."
                }
                group.name = name
                group.parent = coreMember
                group.members = []
                
                print("Add event: id:\(group.id) name:\(group.name)")
                coreMember.groups.append(group)
            }
            
            coreMembers.append(coreMember)
        }
        return coreMembers
        
    }
    
    func getLinkedEventIds() -> [String] {
        let imageIds = self.flowListItems.keys.sorted()
        return EventDao.default.getEvents(imageIds: imageIds)
    }
    
    func checkLinkedEvents() {
        self.treeViewController?.uncheckItems()
        self.treeViewController?.setCheckedItems(ids: self.getLinkedEventIds())
        self.updateCheckedAmount()
    }
    
    func updateCheckedAmount() {
        if let vc = self.treeViewController {
            self.progressLabel.stringValue = Words.selected_items.fill(arguments: "\(vc.getCheckedItems().count)")
        }
    }
    
    fileprivate var accumulator:Accumulator?
    
    @IBAction func onButtonApplyClicked(_ sender: NSButton) {
        let imageIds = self.flowListItems.keys.sorted()
        
        if imageIds.isEmpty {
            return
        }
        
        let _eventIds = self.treeViewController?.getCheckedItems().map({ treeNode in
            return treeNode.getId()
        }) ?? []
        
        var eventIds:Set<String> = []
        for ev in _eventIds {
            if ev != "" {
                eventIds.insert(ev)
            }
        }
        
        if eventIds.count > 1 {
            Alert.warning(message: Words.warning_should_not_select_multiple_items.word())
            return
        }
        let eventId = eventIds.first ?? ""
        
        if Alert.dialogOKCancel(question: Words.dialog_update_images.word()) {
            
            self.btnApply.isEnabled = false
            
            self.accumulator = Accumulator(target: imageIds.count, indicator: self.progressIndicator, suspended: false, lblMessage: self.progressLabel)
            
            DispatchQueue.global().async {
                for imageId in imageIds {
                    let _ = ImageRecordDao.default.updateEvent(imageId: imageId, event: eventId)
                    
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
    
    // MARK: - MANAGE
    
    func loadOwners() -> [[String:String]] {
        var list:[[String:String]] = []
        let coreMembers = FaceDao.default.getCoreMembers()
        for coreMember in coreMembers {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["name"] = coreMember.shortName ?? coreMember.name
            item["id"] = coreMember.id
            list.append(item)
        }
        return list
    }
    
    func getEventCategories() -> [String] {
        return EventDao.default.getEventCategories()
    }
    
    @IBAction func onButtonSaveClicked(_ sender: NSButton) {
        let name = self.txtEventName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let category = self.ddlEventCategory.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let owners = self.ownersTableController.getCheckedItems(column: "name")
        if self.managingEventId != name {
            let alertResponse = Alert.dialogTwoChoiceOrCancel(question: Words.dialog_event_new_or_update.fill(arguments: name,
                                                                                                              self.managingEventId,
                                                                                                              name),
                                                              choice1: Words.dialog_new.word(),
                                                              choice2: Words.dialog_update.word(),
                                                              width: 600)
            if alertResponse == .alertSecondButtonReturn { // update existing, rename
                
                if let ev = EventDao.default.getEvent(name: name) {
                    ev.name = name
                    ev.category = category
                    
                    ev.owner = ""
                    ev.owner2 = ""
                    ev.owner3 = ""
                    ev.ownerId = ""
                    ev.owner2Id = ""
                    ev.owner3Id = ""
                    ev.ownerNickname = ""
                    ev.owner2Nickname = ""
                    ev.owner3Nickname = ""
                    if owners.count >= 3 {
                        if let owner3 = FaceDao.default.getPerson(nickname: owners[2]) {
                            ev.owner3Id = owner3.id
                            ev.owner3 = owner3.name
                            ev.owner3Nickname = owner3.shortName ?? owner3.name
                        }
                    }
                    if owners.count >= 2 {
                        if let owner2 = FaceDao.default.getPerson(nickname: owners[1]) {
                            ev.owner2Id = owner2.id
                            ev.owner2 = owner2.name
                            ev.owner2Nickname = owner2.shortName ?? owner2.name
                        }
                    }
                    if owners.count >= 1 {
                        if let owner1 = FaceDao.default.getPerson(nickname: owners[0]) {
                            ev.ownerId = owner1.id
                            ev.owner = owner1.name
                            ev.ownerNickname = owner1.shortName ?? owner1.name
                        }
                    }
                    
                    let renameState = EventDao.default.renameEvent(oldName: self.managingEventId, newName: name)
                    if renameState == .OK {
                        self.managingEventId = name
                        
                        let executeState = EventDao.default.updateEventDetail(event: ev)
                        
                        if executeState == .OK {
                            self.manageTableViewController.refreshRecords()
                        }else{
                            Alert.criticalAlert(message: "Error: Failed to update event, please check log.")
                        }
                    }else{
                        Alert.criticalAlert(message: "Error: Failed to rename event, please check log.")
                    }
                }else{
                    Alert.criticalAlert(message: "Error: Unable to find this event, please check log and database.")
                }
                
            }else if alertResponse == .alertFirstButtonReturn { // create
                let ev = ImageEvent()
                ev.name = name
                ev.category = category
                
                ev.owner = ""
                ev.owner2 = ""
                ev.owner3 = ""
                ev.ownerId = ""
                ev.owner2Id = ""
                ev.owner3Id = ""
                ev.ownerNickname = ""
                ev.owner2Nickname = ""
                ev.owner3Nickname = ""
                if owners.count >= 3 {
                    if let owner3 = FaceDao.default.getPerson(nickname: owners[2]) {
                        ev.owner3Id = owner3.id
                        ev.owner3 = owner3.name
                        ev.owner3Nickname = owner3.shortName ?? owner3.name
                    }
                }
                if owners.count >= 2 {
                    if let owner2 = FaceDao.default.getPerson(nickname: owners[1]) {
                        ev.owner2Id = owner2.id
                        ev.owner2 = owner2.name
                        ev.owner2Nickname = owner2.shortName ?? owner2.name
                    }
                }
                if owners.count >= 1 {
                    if let owner1 = FaceDao.default.getPerson(nickname: owners[0]) {
                        ev.ownerId = owner1.id
                        ev.owner = owner1.name
                        ev.ownerNickname = owner1.shortName ?? owner1.name
                    }
                }
                
                let executeState = EventDao.default.createEvent(event: ev)
                
                if executeState == .OK {
                    self.manageTableViewController.refreshRecords()
                }else{
                    Alert.criticalAlert(message: "Error: Failed to create event, please check log.")
                }
            }
        }else{ // same name, update existing
            if Alert.dialogOKCancel(question: Words.dialog_event_update.word()) {
                if let ev = EventDao.default.getEvent(name: name) {
                    ev.name = name
                    ev.category = category
                    
                    ev.owner = ""
                    ev.owner2 = ""
                    ev.owner3 = ""
                    ev.ownerId = ""
                    ev.owner2Id = ""
                    ev.owner3Id = ""
                    ev.ownerNickname = ""
                    ev.owner2Nickname = ""
                    ev.owner3Nickname = ""
                    if owners.count >= 3 {
                        if let owner3 = FaceDao.default.getPerson(nickname: owners[2]) {
                            ev.owner3Id = owner3.id
                            ev.owner3 = owner3.name
                            ev.owner3Nickname = owner3.shortName ?? owner3.name
                        }
                    }
                    if owners.count >= 2 {
                        if let owner2 = FaceDao.default.getPerson(nickname: owners[1]) {
                            ev.owner2Id = owner2.id
                            ev.owner2 = owner2.name
                            ev.owner2Nickname = owner2.shortName ?? owner2.name
                        }
                    }
                    if owners.count >= 1 {
                        if let owner1 = FaceDao.default.getPerson(nickname: owners[0]) {
                            ev.ownerId = owner1.id
                            ev.owner = owner1.name
                            ev.ownerNickname = owner1.shortName ?? owner1.name
                        }
                    }
                    
                    let executeState = EventDao.default.updateEventDetail(event: ev)
                    
                    if executeState == .OK {
                        self.manageTableViewController.refreshRecords()
                    }else{
                        Alert.criticalAlert(message: "Error: Failed to update event, please check log.")
                    }
                }else{
                    Alert.criticalAlert(message: "Error: Unable to find this event, please check log and database.")
                }
            }
        }
    }
    
    @IBAction func onButtonDeleteClicked(_ sender: NSButton) {
        let name = self.txtEventName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let _ = EventDao.default.getEvent(name: name) {
            if Alert.dialogOKCancel(question: Words.dialog_event_delete.word()) {
                let executeState = EventDao.default.deleteEvent(name: name)
                
                if executeState == .OK {
                    self.manageTableViewController.refreshRecords()
                }else{
                    Alert.criticalAlert(message: "Error: Failed to delete event, please check log.")
                }
            }
        }else{
            Alert.criticalAlert(message: "Error: Unable to find this event, please check log and database.")
        }
    }
    
    
    @IBAction func onButtonReloadClicked(_ sender: NSButton) {
        self.manageTableViewController.refreshRecords()
    }
    
    @IBAction func onSearchEventsAction(_ sender: NSSearchField) {
        self.manageTableViewController.refreshRecords()
    }
    
    
}

