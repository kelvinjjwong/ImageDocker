//
//  ExportProfileItemController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/12/23.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

class ExportProfileItemController : NSViewController {
    
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblDirectory: NSTextField!
    @IBOutlet weak var btnExport: NSButton!
    @IBOutlet weak var btnStop: NSButton!
    @IBOutlet weak var lblFileNaming: NSTextField!
    
    @IBOutlet weak var boxProfile: NSBox!
    @IBOutlet weak var lblProfileName: NSTextField!
    @IBOutlet weak var lblProfileToDirectory: NSTextField!
    @IBOutlet weak var lblProfileFileNaming: NSTextField!
    @IBOutlet weak var lblMessage: NSTextField!
    
    var onExport: (() -> Void)? = nil
    
    var onStop: (() -> Void)? = nil
    
    init() {
        super.init(nibName: "ExportProfileItemController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.boxProfile.title = Words.export_profile_item.word()
        self.lblProfileName.stringValue = Words.export_profile_name.word()
        self.lblProfileToDirectory.stringValue = Words.export_profile_to_directory.word()
        self.lblProfileFileNaming.stringValue = Words.export_profile_item_file_naming.word()
        
        self.btnExport.title = Words.export_profile_item_export.word()
        self.btnStop.title = Words.export_profile_item_stop.word()
        
        view.wantsLayer = true
        self.refreshFields()
    }
    
    private func refreshFields() {
        if let profile = self.profile {
            self.lblName.stringValue = profile.name
            self.lblDirectory.stringValue = profile.directory
            
            self.lblFileNaming.stringValue = Words.export_profile_file_naming_options.word(profile.fileNaming)
            self.btnStop.isHidden = true
        }
    }
    
    var profile:ExportProfile? = nil
    
    func initView(profile:ExportProfile,
                  onExport: (() -> Void)? = nil, onStop: (() -> Void)? = nil){
        self.profile = profile
        self.onExport = onExport
        self.onStop = onStop
//        self.refreshFields()
    }
    
    func updateView(profile:ExportProfile){
        self.profile = profile
        self.refreshFields()
    }
    
    
    
    @IBAction func onExportClicked(_ sender: NSButton) {
        if onExport != nil {
            onExport!()
        }
    }
    
    @IBAction func onStopClicked(_ sender: NSButton) {
        if onStop != nil {
            onStop!()
        }
    }
    
}
