//
//  ExportProfileViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/30.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class ExportProfileViewController : NSViewController {
    
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblDirectory: NSTextField!
    @IBOutlet weak var btnEdit: NSButton!
    @IBOutlet weak var btnDelete: NSButton!
    
    @IBOutlet weak var boxProfile: NSBox!
    @IBOutlet weak var lblProfileName: NSTextField!
    @IBOutlet weak var lblProfileToDirectory: NSTextField!
    
    var onEdit: (() -> Void)? = nil
    
    var onDelete: (() -> Void)? = nil
    
    init() {
        super.init(nibName: "ExportProfileViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.boxProfile.title = Words.export_profile_item.word()
        self.lblProfileName.stringValue = Words.export_profile_name.word()
        self.lblProfileToDirectory.stringValue = Words.export_profile_to_directory.word()
        
//        self.btnEdit.title = Words.export_profile_item_edit.word()
//        self.btnDelete.title = Words.export_profile_item_delete.word()
        
        view.wantsLayer = true
        self.refreshFields()
    }
    
    private func refreshFields() {
        if let profile = self.profile {
            self.lblName.stringValue = profile.name
            self.lblDirectory.stringValue = profile.directory
        }
    }
    
    var profile:ExportProfile? = nil
    
    func initView(profile:ExportProfile,
                  onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil){
        self.profile = profile
        self.onEdit = onEdit
        self.onDelete = onDelete
//        self.refreshFields()
    }
    
    func updateView(profile:ExportProfile){
        self.profile = profile
        self.refreshFields()
    }
    
    @IBAction func onEditClicked(_ sender: NSButton) {
        if onEdit != nil {
            onEdit!()
        }
    }
    
    @IBAction func onDeleteClicked(_ sender: NSButton) {
        if onDelete != nil {
            onDelete!()
        }
    }
    
    func toggleButtons(state: Bool) {
        self.btnEdit.isEnabled = state
        self.btnDelete.isEnabled = state
    }
    
}
