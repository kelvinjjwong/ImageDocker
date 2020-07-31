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
    @IBOutlet weak var lblDescription: NSTextField!
    @IBOutlet weak var btnEdit: NSButton!
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var lblRepository: NSTextField!
    @IBOutlet weak var lblDuplicatedStrategy: NSTextField!
    @IBOutlet weak var lblEXIFPatching: NSTextField!
    @IBOutlet weak var lblSubFolder: NSTextField!
    @IBOutlet weak var lblFileNaming: NSTextField!
    
    
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
        
        view.wantsLayer = true
        self.refreshFields()
    }
    
    private func refreshFields() {
        if let profile = self.profile {
            self.lblName.stringValue = profile.name
            self.lblDirectory.stringValue = profile.directory
            if !profile.specifyRepository {
                self.lblRepository.stringValue = "any"
            }else{
                self.lblRepository.stringValue = profile.repositoryPath
            }
            self.lblDuplicatedStrategy.stringValue = profile.duplicateStrategy
            self.lblSubFolder.stringValue = profile.subFolder
            self.lblFileNaming.stringValue = profile.fileNaming
            var patching = ""
            if profile.patchImageDescription {
                patching += "Image Description, "
            }
            if profile.patchDateTime {
                patching += "Photo Taken Date, "
            }
            if profile.patchGeolocation {
                patching += "GeoLocation, "
            }
            patching = patching.substring(from: 0, to: -2)
            self.lblEXIFPatching.stringValue = patching
            
            var people = ""
            if !profile.specifyPeople || profile.people == "" {
                people = "Any people"
            }else{
                people = profile.people
            }
            var events = ""
            if !profile.specifyEvent || profile.events == "" {
                events = "Any event"
            }else{
                events = profile.events
            }
            var family = ""
            if !profile.specifyFamily || profile.family == "" {
                family = "Any family"
            }else{
                family = profile.family
            }
            self.lblDescription.stringValue = "People: \(people) ; Event: \(events) ; Family: \(family)"
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
    
}
