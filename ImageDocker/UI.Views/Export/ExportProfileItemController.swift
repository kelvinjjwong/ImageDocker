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
    @IBOutlet weak var lblDescription: NSTextField!
    @IBOutlet weak var btnExport: NSButton!
    @IBOutlet weak var btnStop: NSButton!
    @IBOutlet weak var lblRepository: NSTextField!
    @IBOutlet weak var lblDuplicatedStrategy: NSTextField!
    @IBOutlet weak var lblEXIFPatching: NSTextField!
    @IBOutlet weak var lblSubFolder: NSTextField!
    @IBOutlet weak var lblFileNaming: NSTextField!
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
            self.lblMessage.stringValue = ""
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
