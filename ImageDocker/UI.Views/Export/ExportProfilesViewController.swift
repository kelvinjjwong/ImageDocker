//
//  ExportProfilesViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/12/23.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class ExportProfilesViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "ExportProfilesViewController")
    
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
            viewController.btnExport.isEnabled = false
            viewController.btnStop.isHidden = false
            DispatchQueue.global().async {
                self.logger.log(.trace, ">>>>>>>>>> STARTED EXPORT PROFILE \(profile.id)")
                let (state, message) = ExportManager.default.withMessageBox(viewController.lblMessage).export(profile: profile, rehearsal: false, limit: nil)
                self.logger.log(.trace, "=================== EXPORT END ================")
                self.logger.log(.trace, "state= \(state)")
                self.logger.log(.trace, "message= \(message)")
                DispatchQueue.main.async {
                    viewController.btnExport.isEnabled = true
                    viewController.btnStop.isHidden = true
                }
            }
        }, onStop: {
            DispatchQueue.global().async {
                ExportManager.default.withMessageBox(viewController.lblMessage).stopTask(profileId: profile.id)
                self.logger.log(.trace, ">>>>>>>>>> STOPPED EXPORT PROFILE \(profile.id)")
                DispatchQueue.main.async {
                    viewController.btnExport.isEnabled = true
                    viewController.btnStop.isHidden = true
                }
            }
        })
        
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
        
        self.profileStackItems[profile.id] = viewController
        
    }
    
}
