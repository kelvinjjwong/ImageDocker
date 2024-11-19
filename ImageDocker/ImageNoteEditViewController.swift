//
//  ImageNoteEditViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/3.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory
import nonamecat_swift_commons

class ImageNoteEditViewController : NSViewController, ImageFlowListItemEditor {
    
    let logger = LoggerFactory.get(category: "ImageEdit", subCategory: "Note")
    
    
    @IBOutlet weak var tabs: NSTabView!
    
    // MARK: - VIEW
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var stackView: NSStackView!
    private var window:NSWindow? = nil
    private var tableViewController:TwoColumnTableViewController? = nil
    
    var flowListItems:[String:ImageFlowListItemViewController] = [:]
    
    // MARK: - EDIT
    
    @IBOutlet weak var editTableView: NSTableView!
    @IBOutlet weak var chkShortDescription: NSButton!
    @IBOutlet weak var chkLongDescription: NSButton!
    @IBOutlet weak var txtShortDescription: NSTextField!
    @IBOutlet weak var txtLongDescription: NSTextField!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var btnApply: NSButton!
    var onApplyCompleted: (() -> Void)?
    
    private var editTableViewController:TwoColumnTableViewController? = nil
    
    
    init() {
        super.init(nibName: "ImageNoteEditViewController", bundle: nil)
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
//        self.tableViewController?.view.frame = self.tableView.frame
        
        self.editTableViewController = TwoColumnTableViewController()
        self.editTableViewController?.table = self.editTableView
        
        self.progressIndicator.isHidden = true
        self.progressLabel.isHidden = true
        self.progressLabel.stringValue = ""
        self.chkShortDescription.state = .off
        self.chkLongDescription.state = .off
        
        self.chkShortDescription.title = Words.notes_brief.word()
        self.chkLongDescription.title = Words.notes_detailed.word()
        self.btnApply.title = Words.notes_apply.word()
        
        self.tabs.tabViewItems[0].label = Words.editor_tab_view.word()
        self.tabs.tabViewItems[1].label = Words.editor_tab_edit.word()
        
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
            self.logger.log(.trace, "collectImagesDiff:")
            self.logger.log(.trace, grid)
            
            DispatchQueue.main.async {
                self.tableViewController?.load(grid)
                self.editTableViewController?.load(grid)
            }
        }
    }
    
    func getText(image:Image) -> String {
        return image.shortDescription ?? Words.empty_note.word()
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
                                    content: """
\(image.shortDescription ?? "(没有描述)")
\(image.longDescription ?? "")
""")
            
            self.flowListItems[image.id ?? ""] = viewController
            
            self.collectImagesDiff()
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
        }
    }
    
    
    func removeAllImageFlowListItems() {
        for vc in self.flowListItems.values {
            NSLayoutConstraint.deactivate(vc.view.constraints)
            self.stackView.removeView(vc.view)
        }
        self.flowListItems.removeAll()
        
        self.collectImagesDiff()
    }
    
    // MARK: - EDIT
    
//    fileprivate var accumulator:Accumulator?
    
    @IBAction func onButtonApplyClicked(_ sender: NSButton) {
        let imageIds = self.flowListItems.keys.sorted()
        
        if imageIds.isEmpty {
            return
        }
        
        guard self.chkShortDescription.state == .on || self.chkLongDescription.state == .on else {
            return
        }
        if Alert.dialogOKCancel(question: Words.dialog_update_images.word()) {
            self.btnApply.isEnabled = false
            self.progressLabel.isHidden = false
            self.progressLabel.stringValue = "Updating \(imageIds.count) images..."
            
            let shortDescription = self.chkShortDescription.state == .on ? self.txtShortDescription.stringValue : ""
            let longDescription = self.chkLongDescription.state == .on ? self.txtLongDescription.stringValue : ""
            
            DispatchQueue.global().async {
                if self.chkShortDescription.state == .on && self.chkLongDescription.state == .on {
                    let _ = ImageRecordDao.default.updateImageShortAndLongDescription(shortDescription: shortDescription, longDescription: longDescription, imageIds: imageIds)
                }else if self.chkShortDescription.state == .on {
                    let _ = ImageRecordDao.default.updateImageShortDescription(shortDescription: shortDescription, imageIds: imageIds)
                }else if self.chkLongDescription.state == .on {
                    let _ = ImageRecordDao.default.updateImageLongDescription(longDescription: longDescription, imageIds: imageIds)
                }
                DispatchQueue.main.async {
                    self.btnApply.isEnabled = true
                    self.progressLabel.isHidden = false
                    self.progressLabel.stringValue = "Completed update \(imageIds.count) images."
                    self.onApplyCompleted?()
                }
            }
        }
    }
    
}
