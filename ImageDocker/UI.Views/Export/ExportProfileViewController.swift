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
    @IBOutlet weak var lblRepository: NSTextField!
    @IBOutlet weak var lblDuplicatedStrategy: NSTextField!
    @IBOutlet weak var lblEXIFPatching: NSTextField!
    @IBOutlet weak var lblSubFolder: NSTextField!
    @IBOutlet weak var lblFileNaming: NSTextField!
    @IBOutlet weak var lblPeople: NSTextField!
    @IBOutlet weak var lblEventCategory: NSTextField!
    @IBOutlet weak var lblEvent: NSTextField!
    @IBOutlet weak var lblFamilies: NSTextField!
    
    @IBOutlet weak var boxProfile: NSBox!
    @IBOutlet weak var lblProfileName: NSTextField!
    @IBOutlet weak var lblProfileToDirectory: NSTextField!
    @IBOutlet weak var lblProfileFileNaming: NSTextField!
    @IBOutlet weak var lblProfileExifPatching: NSTextField!
    @IBOutlet weak var lblProfileFromRepository: NSTextField!
    @IBOutlet weak var lblProfileSubFolder: NSTextField!
    @IBOutlet weak var lblProfileFilenameDuplicated: NSTextField!
    @IBOutlet weak var lblProfileFamilies: NSTextField!
    @IBOutlet weak var lblProfilePeople: NSTextField!
    @IBOutlet weak var lblProfileEventCategory: NSTextField!
    @IBOutlet weak var lblProfileEvent: NSTextField!
    
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
        self.lblProfileFileNaming.stringValue = Words.export_profile_item_file_naming.word()
        self.lblProfileExifPatching.stringValue = Words.export_profile_item_exif_patching.word()
        self.lblProfileFromRepository.stringValue = Words.export_profile_item_from_repository.word()
        self.lblProfileSubFolder.stringValue = Words.export_profile_item_sub_folder.word()
        self.lblProfileFilenameDuplicated.stringValue = Words.export_profile_item_duplicated_filename_strategy.word()
        self.lblProfileFamilies.stringValue = Words.export_profile_families.word()
        self.lblProfilePeople.stringValue = Words.export_profile_people.word()
        self.lblProfileEventCategory.stringValue = Words.export_profile_event_categories.word()
        self.lblProfileEvent.stringValue = Words.export_profile_events.word()
        
        self.btnEdit.title = Words.export_profile_item_edit.word()
        self.btnDelete.title = Words.export_profile_item_delete.word()
        
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
            
            var patching = Words.export_profile_item_none.word()
            if profile.patchImageDescription {
                patching += "\(Words.export_profile_exif_patching_image_description.word()), "
            }
            if profile.patchDateTime {
                patching += "\(Words.export_profile_exif_patching_photo_taken_date_time.word()), "
            }
            if profile.patchGeolocation {
                patching += "\(Words.export_profile_exif_patching_geolocation.word()), "
            }
            if patching != Words.export_profile_item_none.word() {
                patching = patching.substring(from: 0, to: -2)
            }
            self.lblEXIFPatching.stringValue = patching
            
            var eventCategories = Words.export_profile_item_no_limit.word()
            if !(profile.specifyEventCategory ?? false) || (profile.eventCategories ?? "") == "" {
                eventCategories = Words.export_profile_item_any_event.word()
            }else{
                eventCategories = (profile.eventCategories ?? "")
                    .replacingOccurrences(of: "include:", with: "\(Words.export_profile_include.word()):")
                    .replacingOccurrences(of: "exclude:", with: "\(Words.export_profile_exclude.word()):")
            }
            self.lblEventCategory.stringValue = eventCategories
            
            var events = Words.export_profile_item_no_limit.word()
            if !profile.specifyEvent || profile.events == "" {
                events = Words.export_profile_item_any_event.word()
            }else{
                events = profile.events
                    .replacingOccurrences(of: "include:", with: "\(Words.export_profile_include.word()):")
                    .replacingOccurrences(of: "exclude:", with: "\(Words.export_profile_exclude.word()):")
            }
            self.lblEvent.stringValue = events
            
            var family = Words.export_profile_item_no_limit.word()
            if !profile.specifyFamily || profile.family == "" {
                family = Words.export_profile_item_any_family.word()
            }else{
                family = profile.family
                    .replacingOccurrences(of: "include:", with: "\(Words.export_profile_include):")
                    .replacingOccurrences(of: "exclude:", with: "\(Words.export_profile_exclude):")
            }
            self.lblFamilies.stringValue = family
            
            var people = Words.export_profile_item_no_limit.word()
            if !profile.specifyPeople || profile.people == "" {
                people = Words.export_profile_item_any_people.word()
            }else{
                people = profile.people
                    .replacingOccurrences(of: "include:", with: "\(Words.export_profile_include.word()):")
                    .replacingOccurrences(of: "exclude:", with: "\(Words.export_profile_exclude.word()):")
            }
            self.lblPeople.stringValue = people
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
