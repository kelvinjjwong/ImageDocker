//
//  ImageFamilyEditViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/3.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class ImageFamilyEditViewController : NSViewController, ImageFlowListItemEditor {
    
    let logger = LoggerFactory.get(category: "ImageEdit", subCategory: "Family")
    
    @IBOutlet weak var stackView: NSStackView!
    private var window:NSWindow? = nil
    
    var flowListItems:[String:ImageFlowListItemViewController] = [:]
    
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
    }
    
    // MARK: - STACK ITEMS
    
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
        }
        
    }
    
    func removeImageFlowListItem(imageFile:ImageFile) {
        if let image = imageFile.imageData {
            self.flowListItems.removeValue(forKey: image.id ?? "")
        }
    }
    
    
    func removeAllImageFlowListItems() {
        self.flowListItems.removeAll()
    }
}

protocol ImageFlowListItemEditor {
    func addImageFlowListItem(imageFile:ImageFile)
    func removeAllImageFlowListItems()
    func removeImageFlowListItem(imageFile:ImageFile)
}
