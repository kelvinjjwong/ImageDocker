//
//  ExportProfilesViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/12/23.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

class ExportProfilesViewController: NSViewController {
    
    @IBOutlet weak var stackView: NSStackView!
    private var window:NSWindow? = nil
    
    var profileStackItems:[String:ExportProfileItemController] = [:]
    
    // MARK: - INIT VIEW
    
    init() {
        super.init(nibName: "ExportProfilesViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initView(window:NSWindow){
        self.window = window
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        stackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        self.loadStackItems()
    }
    
    private func loadStackItems() {
        
        let profiles = ExportDao.default.getAllExportProfiles()
        for profile in profiles {
            self.addProfileItem(profile: profile)
        }
    }
    
    // MARK: - STACK ITEMS
    
    /// Used to add a particular view controller as an item to our stack view.
    func addProfileItem(profile:ExportProfile) {
        
        let storyboard = NSStoryboard(name: "ExportProfileItem", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "ExportProfile") as! ExportProfileItemController
        
        viewController.initView(profile: profile,
                                
        onExport: {
            // GO
        }, onStop: {
            // STOP
        })
        
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
        
        self.profileStackItems[profile.id] = viewController
        
    }
    
}
