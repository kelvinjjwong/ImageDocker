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
    
    private var editTableViewController:TwoColumnTableViewController? = nil
    var treeViewController: FamilyTreeViewControllerWrapper? = nil
    
    // MARK: - MANAGE
    
    @IBOutlet weak var manageTreeView: NSOutlineView!
    var manageTreeViewController: FamilyTreeViewControllerWrapper? = nil
    
    
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
        
        self.treeViewController = FamilyTreeViewControllerWrapper(self.treeView, checkable: true, onCheckStateChanged: { oldValue, newValue, nodeType, nodeId in
            print("tree node changed: \(nodeType) - \(nodeId) - changed from \(oldValue) to \(newValue)")
            self.updateCheckedAmount()
        })
        self.progressIndicator.isHidden = true
        self.updateCheckedAmount()
        
        self.manageTreeViewController = FamilyTreeViewControllerWrapper(self.manageTreeView, editable: true, removable: true, afterChange: {
            print("after change tree view")
            self.treeViewController?.reloadNodes()
        })
        
    }
    
    // MARK: - VIEW
    
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
//            print("addImageFlowListItem, id:\(image.id ?? "") , total:\(self.flowListItems.count)")
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
//        self.logger.log("selected images: \(imageIds)")
//        self.logger.log("checked families: \(checkedGroupIds)")
        
        self.btnApply.isEnabled = false
        
        self.accumulator = Accumulator(target: imageIds.count, indicator: self.progressIndicator, suspended: false, lblMessage: self.progressLabel)
        
        DispatchQueue.global().async {
            for imageId in imageIds {
                guard imageId != "" else {continue}
                
                // unlink families
                let _ = ImageRecordDao.default.unlinkImageFamilies(imageId: imageId)
                
                // link families
                for peopleGroup in checkedGroups {
                    if let owner = peopleGroup.parent {
                        let familyId = peopleGroup.id
                        let ownerId = owner.id
                        let _ = ImageRecordDao.default.storeImageFamily(imageId: imageId, familyId: familyId, ownerId: ownerId, familyName: peopleGroup.name, owner: owner.nickname)
                    }else{
                        self.logger.log(.error, "PeopleGroup.parent is empty: PeopleGroup:\(peopleGroup.name), Image.id:\(imageId)")
                    }
                }
                
                DispatchQueue.main.async {
                    let _ = self.accumulator?.add("")
                }
            }
            DispatchQueue.main.async {
                self.btnApply.isEnabled = true
            }
        }
    }
    
}

protocol ImageFlowListItemEditor {
    func addImageFlowListItem(imageFile:ImageFile)
    func removeAllImageFlowListItems()
    func removeImageFlowListItem(imageFile:ImageFile)
}
