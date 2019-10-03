//
//  ExportConfigurationViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/30.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class ExportConfigurationViewController: NSViewController {
    
    @IBOutlet weak var stackView: NSStackView!
    
    init() {
        super.init(nibName: NSNib.Name(rawValue: "ExportConfigurationViewController"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        stackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        
        self.addViewController(id: "1", name: "test1", path: "~/Pictures/nas", options: "any people, any event, any place")
        self.addViewController(id: "2", name: "test2", path: "~/Pictures/Photos", options: "family, water, any place")
        self.addViewController(id: "3", name: "test3", path: "~/Pictures/Plex", options: "company, biz trip, any place")
        self.addViewController(id: "4", name: "test4", path: "~/Pictures/Plex", options: "friend, vacation trip, any place")
    }
    
    /// Used to add a particular view controller as an item to our stack view.
    func addViewController(id:String, name:String, path:String, options:String) {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "ExportStackItems"), bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ExportProfile")) as! ExportProfileViewController
        
        viewController.initView(id: id, name: name, path: path, options: options)
        
        stackView.addArrangedSubview(viewController.view)
        addChildViewController(viewController)
        
    }
    
}

class CustomStackView : NSStackView {
    
    override var isFlipped: Bool { return true }
}
