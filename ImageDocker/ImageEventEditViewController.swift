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
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var stackView: NSStackView!
    private var window:NSWindow? = nil
    private var tableViewController:TwoColumnTableViewController? = nil
    
    var flowListItems:[String:ImageFlowListItemViewController] = [:]
    
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
    }
    
    // MARK: - STACK ITEMS
    
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
}
