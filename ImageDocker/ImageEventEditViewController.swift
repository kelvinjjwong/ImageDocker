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
    
    private var editTableViewController:TwoColumnTableViewController? = nil
    var treeViewController: CheckableTreeViewControllerWrapper? = nil
    
    
    // MARK: - MANAGE
    @IBOutlet weak var manageTreeView: NSOutlineView!
    @IBOutlet weak var manageEventBox: NSBox!
    @IBOutlet weak var lblEventName: NSTextField!
    @IBOutlet weak var txtEventName: NSTextField!
    @IBOutlet weak var lblEventCategory: NSTextField!
    @IBOutlet weak var ddlEventCategory: NSComboBox!
    @IBOutlet weak var btnSaveEvent: NSButton!
    @IBOutlet weak var btnDeleteEvent: NSButton!
    @IBOutlet weak var tblCheckableOwners: NSTableView!
    
    var manageTreeViewController: CheckableTreeViewControllerWrapper? = nil
    
    
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
        
        
        self.manageTreeViewController = CheckableTreeViewControllerWrapper(self.manageTreeView, editable: true, dataLoader: {
            return self.loadEvents()
        })
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
                group.name = "\(eventName) \(partOwner) \(partCategory)".trimmingCharacters(in: .whitespacesAndNewlines)
                group.parent = coreMember
                group.members = []
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
    }
    
    // MARK: - MANAGE
    
    @IBAction func onButtonSaveClicked(_ sender: NSButton) {
    }
    
    @IBAction func onButtonDeleteClicked(_ sender: NSButton) {
    }
    
    
}
