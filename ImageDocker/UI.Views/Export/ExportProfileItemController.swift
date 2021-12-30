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
    
    @IBOutlet weak var boxProfile: NSBox!
    @IBOutlet weak var lblProfileName: NSTextField!
    @IBOutlet weak var lblProfileToDirectory: NSTextField!
    @IBOutlet weak var lblProfileFileNaming: NSTextField!
    @IBOutlet weak var lblProfileExifPatching: NSTextField!
    @IBOutlet weak var lblProfileFromRepository: NSTextField!
    @IBOutlet weak var lblProfileSubFolder: NSTextField!
    @IBOutlet weak var lblProfileFilenameDuplicated: NSTextField!
    
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
        self.lblProfileExifPatching.stringValue = Words.export_profile_item_exif_patching.word()
        self.lblProfileFromRepository.stringValue = Words.export_profile_item_from_repository.word()
        self.lblProfileSubFolder.stringValue = Words.export_profile_item_sub_folder.word()
        self.lblProfileFilenameDuplicated.stringValue = Words.export_profile_item_duplicated_filename_strategy.word()
        
        self.btnExport.title = Words.export_profile_item_export.word()
        self.btnStop.title = Words.export_profile_item_stop.word()
        
        view.wantsLayer = true
        self.refreshFields()
    }
    
    private func refreshFields() {
        if let profile = self.profile {
            self.lblName.stringValue = profile.name
            self.lblDirectory.stringValue = profile.directory
            
            if !profile.specifyRepository {
                self.lblRepository.stringValue = Words.export_profile_item_any.word()
            }else{
                self.lblRepository.stringValue = profile.repositoryPath
                    .replacingOccurrences(of: "include:", with: "\(Words.export_profile_include.word()):")
                    .replacingOccurrences(of: "exclude:", with: "\(Words.export_profile_exclude.word()):")
            }
            
            self.lblDuplicatedStrategy.stringValue = Words.export_profile_when_filename_is_duplicated_options.word(profile.duplicateStrategy)
            self.lblSubFolder.stringValue = Words.export_profile_sub_folder_options.word(profile.subFolder)
            self.lblFileNaming.stringValue = Words.export_profile_file_naming_options.word(profile.fileNaming)
            
            var patching = ""
            if profile.patchImageDescription {
                patching += "\(Words.export_profile_exif_patching_image_description.word()), "
            }
            if profile.patchDateTime {
                patching += "\(Words.export_profile_exif_patching_photo_taken_date_time.word()), "
            }
            if profile.patchGeolocation {
                patching += "\(Words.export_profile_exif_patching_geolocation.word()), "
            }
            patching = patching.substring(from: 0, to: -2)
            self.lblEXIFPatching.stringValue = patching
            
            var people = ""
            if !profile.specifyPeople || profile.people == "" {
                people = Words.export_profile_item_any_people.word()
            }else{
                people = profile.people
                    .replacingOccurrences(of: "include:", with: "\(Words.export_profile_include.word()):")
                    .replacingOccurrences(of: "exclude:", with: "\(Words.export_profile_exclude.word()):")
            }
            var events = ""
            if !profile.specifyEvent || profile.events == "" {
                events = Words.export_profile_item_any_event.word()
            }else{
                events = profile.events
                    .replacingOccurrences(of: "include:", with: "\(Words.export_profile_include.word()):")
                    .replacingOccurrences(of: "exclude:", with: "\(Words.export_profile_exclude.word()):")
            }
            var family = ""
            if !profile.specifyFamily || profile.family == "" {
                family = Words.export_profile_item_any_family.word()
            }else{
                family = profile.family
                    .replacingOccurrences(of: "include:", with: "\(Words.export_profile_include.word()):")
                    .replacingOccurrences(of: "exclude:", with: "\(Words.export_profile_exclude.word()):")
            }
            self.lblDescription.stringValue = "\(Words.export_profile_people.word()) \(people) ; \(Words.export_profile_events.word()) \(events) ; \(Words.export_profile_families.word()) \(family)"
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
