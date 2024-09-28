//
//  ExportConfigurationViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/30.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class ExportConfigurationViewController: NSViewController {
    
    let logger = LoggerFactory.get(category: "ExportConfigurationViewController")
    
    // MARK: - CONTROLS
    
    @IBOutlet weak var boxEditProfile: NSBox!
    @IBOutlet weak var lblProfileName: NSTextField!
    @IBOutlet weak var lblProfileToRepository: NSTextField!
    
    @IBOutlet weak var boxFileNaming: NSBox!
    @IBOutlet weak var boxExifPatching: NSBox!
    @IBOutlet weak var boxFilenameDuplicated: NSBox!
    @IBOutlet weak var boxSubFolder: NSBox!
    
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtDirectory: NSTextField!
    
    @IBOutlet weak var ddlTargetVolume: NSComboBox!
    
    
    @IBOutlet weak var btnClean: NSButton!
    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var btnAssign: NSButton!
    @IBOutlet weak var btnGoto: NSButton!
    
    @IBOutlet weak var chkRepository: NSButton!
    @IBOutlet weak var chkIncludeRepository: NSButton!
    @IBOutlet weak var chkExcludeRepository: NSButton!
    @IBOutlet weak var tblRepository: NSTableView!
    
    var repositoryTableController : DictionaryTableViewController!
    
    var eventCategoriesTableController : DictionaryTableViewController!
    
    @IBOutlet weak var chkFamilies: NSButton!
    @IBOutlet weak var chkIncludeFamily: NSButton!
    @IBOutlet weak var chkExcludeFamily: NSButton!
    @IBOutlet weak var tblFamily: NSTableView!
    
    var familyTableController : DictionaryTableViewController!
    
    @IBOutlet weak var chkOverwriteDuplicate: NSButton!
    @IBOutlet weak var chkDeviceNameSuffix: NSButton!
    @IBOutlet weak var chkDeviceModelSuffix: NSButton!
    @IBOutlet weak var chkNumberSuffix: NSButton!
    
    @IBOutlet weak var chkPatchImageDescription: NSButton!
    @IBOutlet weak var chkPatchDateTime: NSButton!
    @IBOutlet weak var chkPatchGeolocation: NSButton!
    
    
    @IBOutlet weak var chkNoSubFolder: NSButton!
    @IBOutlet weak var chkDateEventSubFolder: NSButton!
    @IBOutlet weak var chkEventSubFolder: NSButton!
    @IBOutlet weak var chkExportDateTimeSubFolder: NSButton!
    
    @IBOutlet weak var chkOriginFilename: NSButton!
    @IBOutlet weak var chkDateTimeFilename: NSButton!
    @IBOutlet weak var chkDateTimeBriefFilename: NSButton!
    
    
    @IBOutlet weak var btnCalculate: NSButton!
    @IBOutlet weak var lstRehearsalAmount: NSPopUpButton!
    
    @IBOutlet weak var stackView: NSStackView!
    @IBOutlet weak var lblCalculate: NSTextField!
    @IBOutlet weak var btnCopySQLToClipboard: NSButton!
    @IBOutlet weak var btnRehearsal: NSButton!
    @IBOutlet weak var btnExport: NSButton!
    
    @IBOutlet weak var btnLogFile: NSButton!
    
    
    @IBOutlet weak var boxName: NSBox!
    @IBOutlet weak var boxAction: NSBox!
    @IBOutlet weak var boxRepositories: NSBox!
    @IBOutlet weak var boxFamilies: NSBox!
    
    
    @IBOutlet weak var boxEventCategories: NSBox!
    @IBOutlet weak var chkEventCategories: NSButton!
    @IBOutlet weak var chkIncludeEventCategories: NSButton!
    @IBOutlet weak var chkExcludeEventCategories: NSButton!
    @IBOutlet weak var tblEventCategories: NSTableView!
    
    var repoNames:[String:String] = [:]
    
    var profileStackItems:[String:ExportProfileViewController] = [:]
    
    // MARK: - PROPERTIES
    
    fileprivate var editingId = ""
    private var window:NSWindow? = nil
    
    // MARK: - INIT VIEW
    
    init() {
        super.init(nibName: "ExportConfigurationViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initView(window:NSWindow){
        self.window = window
        
        self.boxEditProfile.title = Words.export_profile_edit_profile.word()
        self.boxName.title = Words.export_profile_name_and_path.word()
        self.boxAction.title = Words.export_profile_action.word()
        self.boxFileNaming.title = Words.export_profile_file_naming.word()
        self.boxExifPatching.title = Words.export_profile_exif_patching.word()
        self.boxFilenameDuplicated.title = Words.export_profile_when_filename_is_duplicated.word()
        self.boxSubFolder.title = Words.export_profile_sub_folder.word()
        
        self.lblProfileName.stringValue = Words.export_profile_name.word()
        self.lblProfileToRepository.stringValue = Words.export_profile_to_directory.word()
        
        self.btnSave.title = Words.export_profile_save.word()
        self.btnClean.title = Words.export_profile_clean_fields.word()
        self.btnAssign.title = Words.export_profile_assign_to_directory.word()
        self.btnGoto.title = Words.export_profile_goto_to_directory.word()
        
        self.boxRepositories.title = Words.export_profile_repositories.word()
        self.chkRepository.title = Words.export_profile_has_limit.word()
        self.boxFamilies.title = Words.export_profile_families.word()
        self.chkFamilies.title = Words.export_profile_has_limit.word()
        self.boxEventCategories.title = Words.export_profile_event_categories.word()
        self.chkEventCategories.title = Words.export_profile_has_limit.word()
        
        self.chkIncludeRepository.title = Words.export_profile_include.word()
        self.chkExcludeRepository.title = Words.export_profile_exclude.word()
        self.chkIncludeFamily.title = Words.export_profile_include.word()
        self.chkExcludeFamily.title = Words.export_profile_exclude.word()
        self.chkIncludeEventCategories.title = Words.export_profile_include.word()
        self.chkExcludeEventCategories.title = Words.export_profile_exclude.word()
        
        self.chkOriginFilename.title = Words.export_profile_file_naming_keep_origin.word()
        self.chkDateTimeFilename.title = Words.export_profile_file_naming_date_time.word()
        self.chkDateTimeBriefFilename.title = Words.export_profile_file_naming_date_time_brief.word()
        
        self.chkPatchImageDescription.title = Words.export_profile_exif_patching_image_description.word()
        self.chkPatchDateTime.title = Words.export_profile_exif_patching_photo_taken_date_time.word()
        self.chkPatchGeolocation.title = Words.export_profile_exif_patching_geolocation.word()
        
        self.chkOverwriteDuplicate.title = Words.export_profile_when_filename_is_duplicated_overwrite.word()
        self.chkDeviceNameSuffix.title = Words.export_profile_when_filename_is_duplicated_use_device_name_as_suffix.word()
        self.chkDeviceModelSuffix.title = Words.export_profile_when_filename_is_duplicated_use_device_model_as_suffix.word()
        self.chkNumberSuffix.title = Words.export_profile_when_filename_is_duplicated_use_number_as_suffix.word()
        
        self.chkNoSubFolder.title = Words.export_profile_sub_folder_no_subfolder.word()
        self.chkDateEventSubFolder.title = Words.export_profile_sub_folder_year_month_event.word()
        self.chkEventSubFolder.title = Words.export_profile_sub_folder_event.word()
        self.chkExportDateTimeSubFolder.title = Words.export_profile_sub_folder_export_date_time.word()
        
        self.btnCalculate.title = Words.export_profile_calculate_images.word()
        self.btnCopySQLToClipboard.title = Words.export_profile_copy_sql_to_clipboard.word()
        self.btnExport.title = Words.export_profile_rehearsal_export.word()
        self.btnRehearsal.title = Words.export_profile_rehearsal.word()
        self.lstRehearsalAmount.item(at: 0)?.title = Words.export_profile_rehearsal_n_images.fill(arguments: "10")
        self.lstRehearsalAmount.item(at: 1)?.title = Words.export_profile_rehearsal_n_images.fill(arguments: "100")
        self.lstRehearsalAmount.item(at: 2)?.title = Words.export_profile_rehearsal_n_images.fill(arguments: "500")
        self.lstRehearsalAmount.item(at: 3)?.title = Words.export_profile_rehearsal_all_images.word()
        
        self.reloadTables()
        self.cleanFields()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        self.txtName.stringValue = Words.export_auto_profile.fill(arguments: "\(date)")
        self.ddlTargetVolume.selectItem(at: 0)
        self.txtDirectory.stringValue = "/Images.export/"
        
        self.loadStackItems()
    }
    
    private var volumesListController : TextListViewPopupController!
    
    private var toggleGroup_Repository:ToggleGroup!
    private var toggleGroup_EventCategory:ToggleGroup!
    private var toggleGroup_Family:ToggleGroup!
    
    
    // MARK: INIT VIEW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.volumesListController = TextListViewPopupController(self.ddlTargetVolume)
        self.init_toggles()
        
        view.wantsLayer = true
        stackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        self.logger.log("view did load")
    }
    
    func refreshMountedVolumes(append items:[String] = []) {
        
        var mountedVolumes = LocalDirectory.bridge.listMountedVolumes()
        
        for item in items {
            if !mountedVolumes.contains(item) {
                mountedVolumes.append(item)
            }
        }
        
        self.volumesListController.load(mountedVolumes)
    }
    
    private func loadStackItems() {
        
        let profiles = ExportDao.default.getAllExportProfiles()
        for profile in profiles {
            self.addProfileItem(profile: profile)
        }
    }
    
    private var isNewRecord = true
    
    // MARK: - CLEAN FIELDS
    
    private func reloadTables() {
        self.refreshMountedVolumes()
        
        self.repositoryTableController.load(self.loadRepositoryOwners(), afterLoaded: {
        })
        
        self.eventCategoriesTableController.load(self.loadEventCategories(), afterLoaded: {
        })
        
        self.familyTableController.load(self.loadFamilies(), afterLoaded: {
        })
    }
    
    private func toggleButtons(state: Bool) {
        self.txtName.isEditable = state
        self.ddlTargetVolume.isEditable = state
        self.ddlTargetVolume.isSelectable = state
        self.txtDirectory.isEditable = state
        
        self.btnSave.isEnabled = state
        self.btnAssign.isEnabled = state
        self.btnClean.isEnabled = state
        self.btnCalculate.isEnabled = state
        self.btnRehearsal.isEnabled = state
        
        self.btnExport.isEnabled = state
        self.btnCopySQLToClipboard.isEnabled = state
        
        self.chkRepository.isEnabled = state
        self.chkFamilies.isEnabled = state
        self.chkEventCategories.isEnabled = state
        
        if state {
            self.repositoryTableController.enableCheckboxes()
            self.familyTableController.enableCheckboxes()
            self.eventCategoriesTableController.enableCheckboxes()
            
            self.toggleGroup_Repository.enable()
            self.toggleGroup_Family.enable()
            self.toggleGroup_EventCategory.enable()
            
        }else{
            self.repositoryTableController.disableCheckboxes()
            self.familyTableController.disableCheckboxes()
            self.eventCategoriesTableController.disableCheckboxes()
            
            self.toggleGroup_Repository.disable()
            self.toggleGroup_Family.disable()
            self.toggleGroup_EventCategory.disable()
        }
        
        self.chkPatchGeolocation.isEnabled = state
        self.chkPatchDateTime.isEnabled = state
        self.chkPatchImageDescription.isEnabled = state
        
        self.chkOriginFilename.isEnabled = state
        self.chkDateTimeFilename.isEnabled = state
        self.chkDateTimeBriefFilename.isEnabled = state
        
        self.chkNoSubFolder.isEnabled = state
        self.chkEventSubFolder.isEnabled = state
        self.chkDateEventSubFolder.isEnabled = state
        self.chkExportDateTimeSubFolder.isEnabled = state
        
        self.chkOverwriteDuplicate.isEnabled = state
        self.chkDeviceModelSuffix.isEnabled = state
        self.chkNumberSuffix.isEnabled = state
        self.chkDeviceNameSuffix.isEnabled = state
        
        for vc in self.profileStackItems.values {
            vc.toggleButtons(state: state)
        }
    }
    
    private func cleanFields() {
        self.isNewRecord = true
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        self.editingId = dateFormatter.string(from: Date())
        self.txtName.stringValue = ""
        self.txtDirectory.stringValue = ""
        self.setFileNamingStrategy("DATETIME_BRIEF")
        self.setSubFolderStrategy("DATE_EVENT")
        self.setFilenameDuplicatedStrategy("OVERWRITE")
        self.chkPatchDateTime.state = .off
        self.chkPatchGeolocation.state = .off
        self.chkPatchImageDescription.state = .off
        
        self.toggleRepository(true, uncheckAll: true)
        self.toggleEventCategory(true, uncheckAll: true)
        self.toggleFamily(true, uncheckAll: true)
        
        self.btnExport.isEnabled = false
    }
    
    private func fillFields(profile:ExportProfile) {
        self.isNewRecord = false
        
        self.btnExport.isEnabled = true
        
        self.editingId = profile.id
        self.txtName.stringValue = profile.name
        
        self.volumesListController.select(profile.targetVolume)
        
        self.txtDirectory.stringValue = profile.directory
        self.chkPatchImageDescription.state = profile.patchImageDescription ? .on : .off
        self.chkPatchGeolocation.state = profile.patchGeolocation ? .on : .off
        self.chkPatchDateTime.state = profile.patchDateTime ? .on : .off
        self.setFileNamingStrategy(profile.fileNaming)
        self.setSubFolderStrategy(profile.subFolder)
        self.setFilenameDuplicatedStrategy(profile.duplicateStrategy)
        
        self.chkRepository.state = profile.specifyRepository ? .on : .off
        let repos = profile.repositoryPath
        if repos.hasPrefix("include:") {
            self.toggleGroup_Repository.selected = "include"
            let value = repos.replacingFirstOccurrence(of: "include:", with: "")
            self.logger.log("repo: \(value)")
            self.repositoryTableController.setCheckedItems(column: "id", from: value, separator: ",", quoted: true)
        }else if repos.hasPrefix("exclude:") {
            self.toggleGroup_Repository.selected = "exclude"
            let value = repos.replacingFirstOccurrence(of: "exclude:", with: "")
            self.logger.log("repo: \(value)")
            self.repositoryTableController.setCheckedItems(column: "id", from: value, separator: ",", quoted: true)
        }
        if !profile.specifyRepository {
            self.repositoryTableController.disableCheckboxes()
            self.toggleGroup_Repository.disable()
        }else{
            self.repositoryTableController.enableCheckboxes()
            self.toggleGroup_Repository.enable()
        }
        
        let specifyEventCategory = profile.specifyEventCategory ?? false
        self.chkEventCategories.state = specifyEventCategory ? .on : .off
        let eventCategories = profile.eventCategories ?? ""
        if eventCategories.hasPrefix("include:") {
            self.toggleGroup_EventCategory.selected = "include"
            let value = eventCategories.replacingFirstOccurrence(of: "include:", with: "")
            self.logger.log("eventCategory: \(value)")
            self.eventCategoriesTableController.setCheckedItems(column: "name", from: value, separator: ",", quoted: true)
        }else if eventCategories.hasPrefix("exclude:") {
            self.toggleGroup_EventCategory.selected = "exclude"
            let value = eventCategories.replacingFirstOccurrence(of: "exclude:", with: "")
            self.logger.log("eventCategory: \(value)")
            self.eventCategoriesTableController.setCheckedItems(column: "name", from: value, separator: ",", quoted: true)
        }
        if !specifyEventCategory {
            self.eventCategoriesTableController.disableCheckboxes()
            self.toggleGroup_EventCategory.disable()
        }else{
            self.eventCategoriesTableController.enableCheckboxes()
            self.toggleGroup_EventCategory.enable()
        }
        
        self.chkFamilies.state = profile.specifyFamily ? .on : .off
        let family = profile.family
        if family.hasPrefix("include:") {
            self.toggleGroup_Family.selected = "include"
            let value = family.replacingFirstOccurrence(of: "include:", with: "")
            self.logger.log("family: \(value)")
            self.familyTableController.setCheckedItems(column: "id", from: value, separator: ",", quoted: true)
        }else if family.hasPrefix("exclude:") {
            self.toggleGroup_Family.selected = "exclude"
            let value = family.replacingFirstOccurrence(of: "exclude:", with: "")
            self.logger.log("family: \(value)")
            self.familyTableController.setCheckedItems(column: "id", from: value, separator: ",", quoted: true)
        }
        if !profile.specifyFamily {
            self.familyTableController.disableCheckboxes()
            self.toggleGroup_Family.disable()
        }else{
            self.familyTableController.enableCheckboxes()
            self.toggleGroup_Family.enable()
        }
        
    }
    
    @IBAction func onCleanClicked(_ sender: NSButton) {
        self.cleanFields()
        self.repositoryTableController.uncheckAll()
        self.eventCategoriesTableController.uncheckAll()
        self.familyTableController.uncheckAll()
    }
    
    
    // MARK: - SAVE ACTION
    
    private func fillProfileFromForm(profile:ExportProfile) -> ExportProfile {
        let name = self.txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let targetVolume = self.ddlTargetVolume.stringValue
        
        let path = self.txtDirectory.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileNaming = self.getFileNamingStrategy()
        let fileDuplicated = self.getFilenameDuplicatedStrategy()
        let subfolder = self.getSubFolderStrategy()
        
        // convert checkboxes to string
        var eventCategories = ""
        var repos = ""
        var family = ""
        
        if self.chkRepository.state == .on {
            let checked = self.repositoryTableController.getCheckedItemAsQuotedString(column: "id", separator: ",")
            if checked != "" {
                if self.chkIncludeRepository.state == .on {
                    repos = "include:\(checked)"
                }else if self.chkExcludeRepository.state == .on {
                    repos = "exclude:\(checked)"
                }
            }
        }
        
        if self.chkEventCategories.state == .on {
            let checked = self.eventCategoriesTableController.getCheckedItemAsQuotedString(column: "name", separator: ",")
            if checked != "" {
                if self.chkIncludeEventCategories.state == .on {
                    eventCategories = "include:\(checked)"
                }else if self.chkExcludeEventCategories.state == .on {
                    eventCategories = "exclude:\(checked)"
                }
            }
        }
        self.logger.log("selected category: \(eventCategories)")
        
        if self.chkFamilies.state == .on {
            let checked = self.familyTableController.getCheckedItemAsQuotedString(column: "id", separator: ",")
            if checked != "" {
                if self.chkIncludeFamily.state == .on {
                    family = "include:\(checked)"
                }else if self.chkExcludeFamily.state == .on {
                    family = "exclude:\(checked)"
                }
            }
        }
        
        profile.name = name
        profile.targetVolume = targetVolume
        profile.directory = path
        profile.duplicateStrategy = fileDuplicated
        profile.specifyRepository = self.chkRepository.state == .on
        profile.specifyFamily = self.chkFamilies.state == .on
        profile.repositoryPath = repos
        profile.family = family
        profile.patchImageDescription = self.chkPatchImageDescription.state == .on
        profile.patchDateTime = self.chkPatchDateTime.state == .on
        profile.patchGeolocation = self.chkPatchGeolocation.state == .on
        profile.fileNaming = fileNaming
        profile.subFolder = subfolder
        profile.eventCategories = eventCategories
        profile.specifyEventCategory = self.chkEventCategories.state == .on
        
        return profile
    }
    
    @IBAction func onSaveClicked(_ sender: NSButton) {
        
        let form = self.fillProfileFromForm(profile: ExportProfile())
        
        var profile = ExportDao.default.getOrCreateExportProfile(id: self.editingId,
                                                                 name: form.name,
                                                                 targetVolume: form.targetVolume,
                                                                 directory: form.directory,
                                                                 repositoryPath: form.repositoryPath,
                                                                 specifyRepository: form.specifyRepository,
                                                                 duplicateStrategy: form.duplicateStrategy,
                                                                 fileNaming: form.fileNaming,
                                                                 subFolder: form.subFolder,
                                                                 patchImageDescription: form.patchImageDescription,
                                                                 patchDateTime: form.patchDateTime,
                                                                 patchGeolocation: form.patchGeolocation,
                                                                 specifyFamily: form.specifyFamily,
                                                                 family: form.family,
                                                                 eventCategories: form.eventCategories ?? "",
                                                                 specifyEventCategory: form.specifyEventCategory ?? false
                                                                )
        if !self.isNewRecord {
            let status = ExportDao.default.updateExportProfile(id: self.editingId,
                                                               name: form.name,
                                                               targetVolume: form.targetVolume,
                                                               directory: form.directory,
                                                               duplicateStrategy: form.duplicateStrategy,
                                                               specifyRepository: form.specifyRepository,
                                                               specifyFamily: form.specifyFamily,
                                                               repositoryPath: form.repositoryPath,
                                                               family: form.family,
                                                               patchImageDescription: form.patchImageDescription,
                                                               patchDateTime: form.patchDateTime,
                                                               patchGeolocation: form.patchGeolocation,
                                                               fileNaming: form.fileNaming,
                                                               subFolder: form.subFolder,
                                                               eventCategories: form.eventCategories ?? "",
                                                               specifyEventCategory: form.specifyEventCategory ?? false
                                                            )
            
            if status != .OK {
                self.logger.log(status)
                self.logger.log("Unable to update export profile id=\(self.editingId)")
                return
            }else{
                profile = form
                profile.id = self.editingId
            }
        }
        
        self.logger.log("profile id \(profile.id)")
        if let vc = self.profileStackItems[profile.id] {
            self.logger.log("going to update view \(profile.id)")
            vc.updateView(profile: profile)
        }else{
            self.addProfileItem(profile: profile)
        }
    }
    
    // MARK: - STACK ITEMS
    
    /// Used to add a particular view controller as an item to our stack view.
    func addProfileItem(profile:ExportProfile) {
        
        let storyboard = NSStoryboard(name: "ExportProfileItemConfig", bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: "ExportProfile") as! ExportProfileViewController
        
        viewController.initView(profile: profile,
                                onEdit: {
                                    self.cleanFields()
            if let persisted_profile = ExportDao.default.getExportProfile(id: profile.id) {
                self.fillFields(profile: persisted_profile)
            }else{
                self.fillFields(profile: profile)
            }
        }, onDelete: {
            if Alert.dialogOKCancel(question: "DELETE PROFILE", text: "Do you confirm to delete profile [\(profile.name)] ?") {
                self.logger.log("proceed delete")
                let state = ExportDao.default.deleteExportProfile(id: profile.id)
                if state == .OK {
                    NSLayoutConstraint.deactivate(viewController.view.constraints)
                    //self.stackView.removeArrangedSubview(viewController.view)
                    self.stackView.removeView(viewController.view)
                    self.profileStackItems.removeValue(forKey: profile.id)
                }else {
                    Alert.show(message: "\(state): Cannot delete profile [\(profile.name)]")
                }
            }
        })
        
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
        
        self.profileStackItems[profile.id] = viewController
        
    }
    
    // MARK: - TO DIRECTORY
    
    @IBAction func onAssignDirectoryClicked(_ sender: NSButton) {
        if let win = self.window {
            
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true
            
            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    let (vol, path) = url.path.getVolumeFromThisPath()
                    self.ddlTargetVolume.stringValue = vol
                    self.txtDirectory.stringValue = path
                }
            }
        }
    }
    
    @IBAction func onGotoDirectoryClicked(_ sender: NSButton) {
        if self.ddlTargetVolume.stringValue == "" {
            Alert.show(message: "Please assign directory first.")
            return
        }
        if self.txtDirectory.stringValue == "" {
            Alert.show(message: "Please assign directory first.")
            return
        }
        
        let url = URL(fileURLWithPath: "\(self.ddlTargetVolume.stringValue)\(self.txtDirectory.stringValue)")
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    // MARK: - CALCULATE & REHEARSAL
    
    private func getRehearsalAmount() -> Int? {
        var amount:Int? = nil
        if let selection = self.lstRehearsalAmount.titleOfSelectedItem {
            let number = selection.components(separatedBy: " ")[1]
            if number == "10" {
                amount = 10
            }else if number == "100" {
                amount = 100
            }else if number == "500" {
                amount = 500
            }
        }
        return amount
        
    }
    
    private func getProfile() -> ExportProfile {
        var profile:ExportProfile
        if let pf = ExportDao.default.getExportProfile(id: self.editingId) {
            profile = pf
        }else{
            let pf = self.fillProfileFromForm(profile: ExportProfile())
            profile = pf
        }
        return profile
    }
    
    // MARK: ACTION BUTTONS
    
    @IBAction func onExportClicked(_ sender: NSButton) {
        // real export with file i/o and amount limitation
        self.toggleButtons(state: false)
        
        let profile = self.getProfile()
        let amount = self.getRehearsalAmount()
        
        DispatchQueue.global().async {
            let (state, message) = ExportManager.default.withMessageBox(self.lblCalculate).export(profile: profile, rehearsal: false, limit: amount)
            DispatchQueue.main.async {
                self.toggleButtons(state: true)
                
                if state == true {
                    self.lblCalculate.stringValue = message
                }else{
                    self.lblCalculate.stringValue = "ERROR: \(message)"
                }
            }
        }
    }
    
    
    @IBAction func onRehearsalClicked(_ sender: NSButton) {
        // rehearsal export (query from db, no file i/o)
        self.toggleButtons(state: false)
        
        let profile = self.getProfile()
        let amount = self.getRehearsalAmount()
        
        DispatchQueue.global().async {
            let (state, message) = ExportManager.default.withMessageBox(self.lblCalculate).export(profile: profile, rehearsal: true, limit: amount)
            DispatchQueue.main.async {
                self.toggleButtons(state: true)
                
                if state == true {
                    self.lblCalculate.stringValue = message
                }else{
                    self.lblCalculate.stringValue = "ERROR: \(message)"
                }
            }
        }
    }
    
    @IBAction func onCopySQLClicked(_ sender: NSButton) {
        var profile:ExportProfile
        if let pf = ExportDao.default.getExportProfile(id: self.editingId) {
            profile = pf
        }else{
            let pf = self.fillProfileFromForm(profile: ExportProfile())
            profile = pf
        }
        let sql = ExportDao.default.getSQLForImageExport(profile: profile)
//        self.logger.log(sql)
        self.lblCalculate.stringValue = "Copied SQL to clipboard."
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(sql, forType: .string)
    }
    
    @IBAction func onCalculateClicked(_ sender: NSButton) {
        self.lblCalculate.stringValue = "Calculating affected images ..."
        var profile:ExportProfile
        if let pf = ExportDao.default.getExportProfile(id: self.editingId) {
            profile = pf
        }else{
            let pf = self.fillProfileFromForm(profile: ExportProfile())
            profile = pf
        }
        
        DispatchQueue.global().async {
            let count = ExportDao.default.countImagesForExport(profile: profile)
            let exported = ExportDao.default.countExportedImages(profile: profile)
            DispatchQueue.main.async {
                self.lblCalculate.stringValue = "Profile affects \(count) images. Exported \(exported) images."
            }
        }
    }
    
    
    // MARK: - TOGGLE GROUP - DATA LOADER
    
    func loadRepositoryOwners() -> [[String:String]] {
        var list:[[String:String]] = []
        let coreMembers = FaceDao.default.getCoreMembers()
        for coreMember in coreMembers {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["name"] = coreMember.shortName ?? coreMember.name
            item["id"] = coreMember.id
            list.append(item)
        }
        var shared:[String:String] = [:]
        shared["check"] = "false"
        shared["name"] = Words.owner_public_shared.word()
        shared["id"] = "shared"
        list.append(shared)
        return list
    }
    
    func loadFamilies() -> [[String:String]] {
        var coreMemberIdToName:[String:String] = [:]
        var familyNames:[[String:String]] = []
        let coreMembers = FaceDao.default.getCoreMembers()
        for coreMember in coreMembers {
            coreMemberIdToName[coreMember.id] = coreMember.shortName ?? coreMember.name
        }
        let families = FaceDao.default.getFamilies()
        for family in families {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["name"] = family.name.hasPrefix("自拍") ? Words.whose_family.fill(arguments: coreMemberIdToName[family.owner] ?? "", family.name) : Words.who_and_family.fill(arguments: coreMemberIdToName[family.owner] ?? "", family.name)
            item["id"] = family.id
            familyNames.append(item)
        }
        return familyNames
    }
    
    func loadEventCategories() -> [[String:String]] {
        var eventCategoryNames:[[String:String]] = []
        let eventCategories = EventDao.default.getEventCategories()
        for eventCategory in eventCategories {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["name"] = eventCategory
            item["id"] = eventCategory
            eventCategoryNames.append(item)
        }
        return eventCategoryNames
    }
    
    // MARK: - TOGGLE GROUP - INIT
    
    func init_toggles() {
        self.toggleGroup_Repository = ToggleGroup([
            "include" : self.chkIncludeRepository,
            "exclude" : self.chkExcludeRepository
        ], keysOrderred: ["include", "exclude"], defaultValue: "include")
        
//        self.toggleGroup_Repository.selected = "include"
        
        self.toggleGroup_EventCategory = ToggleGroup([
            "include" : self.chkIncludeEventCategories,
            "exclude" : self.chkExcludeEventCategories
        ], keysOrderred: ["include", "exclude"], defaultValue: "include")
        
//        self.toggleGroup_EventCategory.selected = "include"
        
        self.toggleGroup_Family = ToggleGroup([
            "include" : self.chkIncludeFamily,
            "exclude" : self.chkExcludeFamily
        ], keysOrderred: ["include", "exclude"], defaultValue: "include")
        
//        self.toggleGroup_Family.selected = "include"
        
        self.repositoryTableController = DictionaryTableViewController(self.tblRepository)
        
        self.eventCategoriesTableController = DictionaryTableViewController(self.tblEventCategories)
        self.eventCategoriesTableController.onCheck = { id, state in
            
            let categories = self.eventCategoriesTableController.getCheckedItemAsSingleQuotedString(column: "name", separator: ",")
            self.logger.log("event category checked: \(categories)")
        }
        
        self.familyTableController = DictionaryTableViewController(self.tblFamily)
        self.familyTableController.onCheck = { id, state in
            
            let families = self.familyTableController.getCheckedItemAsSingleQuotedString(column: "id", separator: ",")
            self.logger.log("family checked: \(families)")
        }
    }
    
    // MARK: - TOGGLE GROUP
    
    func toggleBox(state: Bool,
                   uncheckAll:Bool,
                   checkBox:NSButton,
                   toggleGroup:ToggleGroup,
                   tableController:DictionaryTableViewController) {
        if state == true {
            checkBox.state = .on
            toggleGroup.enable()
            tableController.table.isEnabled = true
            tableController.enableCheckboxes()
        }else{
            checkBox.state = .off
            toggleGroup.disable()
            tableController.table.isEnabled = false
            tableController.disableCheckboxes()
            self.logger.log("toggled off")
        }
        if uncheckAll {
            tableController.uncheckAll()
        }
    }
    
    func toggleRepository(_ state:Bool, uncheckAll:Bool = false) {
        self.toggleBox(state: state,
                       uncheckAll: uncheckAll,
                       checkBox: self.chkRepository,
                       toggleGroup: self.toggleGroup_Repository,
                       tableController: self.repositoryTableController)
    }
    
    @IBAction func onCheckRepository(_ sender: NSButton) {
        self.toggleRepository(sender.state == .on)
    }
    
    func toggleEventCategory(_ state:Bool, uncheckAll:Bool = false) {
        self.toggleBox(state: state,
                       uncheckAll: uncheckAll,
                       checkBox: self.chkEventCategories,
                       toggleGroup: self.toggleGroup_EventCategory,
                       tableController: self.eventCategoriesTableController)
    }
    
    @IBAction func onCheckEventCategoryClicked(_ sender: NSButton) {
        self.toggleEventCategory(sender.state == .on)
    }
    
    func toggleFamily(_ state:Bool, uncheckAll:Bool = false) {
        self.toggleBox(state: state,
                       uncheckAll: uncheckAll,
                       checkBox: self.chkFamilies,
                       toggleGroup: self.toggleGroup_Family,
                       tableController: self.familyTableController)
    }
    
    @IBAction func onCheckFamilyClicked(_ sender: NSButton) {
        self.toggleFamily(sender.state == .on)
    }
    
    @IBAction func onIncludeRepositoryClicked(_ sender: NSButton) {
        self.toggleGroup_Repository.selected = "include"
    }
    
    @IBAction func onExcludeRepositoryClicked(_ sender: NSButton) {
        self.toggleGroup_Repository.selected = "exclude"
    }
    
    @IBAction func onIncludeEventCategoryClicked(_ sender: NSButton) {
        self.toggleGroup_EventCategory.selected = "include"
    }
    
    @IBAction func onExcludeEventCategoryClicked(_ sender: NSButton) {
        self.toggleGroup_EventCategory.selected = "exclude"
    }
    
    @IBAction func onIncludeFamilyClicked(_ sender: NSButton) {
        self.toggleGroup_Family.selected = "include"
    }
    
    @IBAction func onExcludeFamilyClicked(_ sender: NSButton) {
        self.toggleGroup_Family.selected = "exclude"
    }
    
    
    // MARK: - TOGGLE GROUP - SUB FOLDER STRATEGY
    
    private func getSubFolderStrategy() -> String {
        if self.chkNoSubFolder.state == .on {return "NONE"}
        if self.chkEventSubFolder.state == .on {return "EVENT"}
        if self.chkDateEventSubFolder.state == .on {return "DATE_EVENT"}
        if self.chkExportDateTimeSubFolder.state == .on {return "EXPORT_TIME"}
        return ""
    }
    
    private func setSubFolderStrategy(_ value:String) {
        self.chkNoSubFolder.state = .off
        self.chkEventSubFolder.state = .off
        self.chkDateEventSubFolder.state = .off
        self.chkExportDateTimeSubFolder.state = .off
        if value == "NONE" {
            self.chkNoSubFolder.state = .on
        }else if value == "EVENT" {
            self.chkEventSubFolder.state = .on
        }else if value == "DATE_EVENT" {
            self.chkDateEventSubFolder.state = .on
        }else if value == "EXPORT_TIME" {
            self.chkExportDateTimeSubFolder.state = .on
        }else{
            // default
            self.chkDateEventSubFolder.state = .on
        }
    }
    
    @IBAction func onNoSubFolderClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkDateEventSubFolder.state = .off
            self.chkEventSubFolder.state = .off
            self.chkExportDateTimeSubFolder.state = .off
        }else {
            if self.getSubFolderStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onDateEventSubFolderClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkNoSubFolder.state = .off
            self.chkEventSubFolder.state = .off
            self.chkExportDateTimeSubFolder.state = .off
        }else {
            if self.getSubFolderStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    
    @IBAction func onEventSubFolderClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkDateEventSubFolder.state = .off
            self.chkNoSubFolder.state = .off
            self.chkExportDateTimeSubFolder.state = .off
        }else {
            if self.getSubFolderStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onExportDateTimeSubFolderClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkDateEventSubFolder.state = .off
            self.chkEventSubFolder.state = .off
            self.chkNoSubFolder.state = .off
        }else {
            if self.getSubFolderStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    // MARK: - TOGGLE GROUP - FILE NAMING STRATEGY
    
    private func getFileNamingStrategy() -> String {
        if self.chkOriginFilename.state == .on {return "ORIGIN"}
        if self.chkDateTimeFilename.state == .on {return "DATETIME"}
        if self.chkDateTimeBriefFilename.state == .on {return "DATETIME_BRIEF"}
        return ""
    }
    
    private func setFileNamingStrategy(_ value:String) {
        self.chkOriginFilename.state = .off
        self.chkDateTimeFilename.state = .off
        self.chkDateTimeBriefFilename.state = .off
        if value == "ORIGIN" {
            self.chkOriginFilename.state = .on
        }else if value == "DATETIME" {
            self.chkDateTimeFilename.state = .on
        }else if value == "DATETIME_BRIEF" {
            self.chkDateTimeBriefFilename.state = .on
        }else{
            // default
            self.chkDateTimeBriefFilename.state = .on
        }
    }
    
    @IBAction func onOriginFilenameClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkDateTimeFilename.state = .off
            self.chkDateTimeBriefFilename.state = .off
        }else {
            if self.getFileNamingStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onDateTimeFilenameClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkOriginFilename.state = .off
            self.chkDateTimeBriefFilename.state = .off
        }else {
            if self.getFileNamingStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onDateTimeBriefFilenameClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkDateTimeFilename.state = .off
            self.chkOriginFilename.state = .off
        }else {
            if self.getFileNamingStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    // MARK: - TOGGLE GROUP - EXIF PATCHING OPTIONS
    
    private func getExifPatching() -> String {
        if self.chkPatchImageDescription.state == .on {return "DESCRIPTION"}
        if self.chkPatchDateTime.state == .on {return "DATETIME"}
        if self.chkPatchGeolocation.state == .on {return "GEOLOCATION"}
        return ""
    }
    
    private func setExifPatching(_ value:String) {
        self.chkPatchImageDescription.state = .off
        self.chkPatchDateTime.state = .off
        self.chkPatchGeolocation.state = .off
        if value.contains("DESCRIPTION") {
            self.chkPatchImageDescription.state = .on
        }
        if value.contains("DATETIME") {
            self.chkPatchDateTime.state = .on
        }
        if value.contains("GEOLOCATION") {
            self.chkPatchGeolocation.state = .on
        }
    }
    
    @IBAction func onPatchImageDescriptionClicked(_ sender: NSButton) {
    }
    
    @IBAction func onPatchDateTimeClicked(_ sender: NSButton) {
    }
    
    @IBAction func onPatchGeolocationClicked(_ sender: NSButton) {
    }
    
    // MARK: - TOGGLE GROUP - DUPLICATED FILENAME RENAMING STRATEGY
    
    private func getFilenameDuplicatedStrategy() -> String {
        if self.chkOverwriteDuplicate.state == .on {return "OVERWRITE"}
        if self.chkDeviceNameSuffix.state == .on {return "DEVICE_NAME"}
        if self.chkDeviceModelSuffix.state == .on {return "DEVICE_MODEL"}
        if self.chkNumberSuffix.state == .on {return "NUMBER"}
        return ""
    }
    
    private func setFilenameDuplicatedStrategy(_ value:String) {
        self.chkOverwriteDuplicate.state = .off
        self.chkDeviceNameSuffix.state = .off
        self.chkDeviceModelSuffix.state = .off
        self.chkNumberSuffix.state = .off
        if value == "OVERWRITE" {
            self.chkOverwriteDuplicate.state = .on
        }else if value == "DEVICE_NAME" {
            self.chkDeviceNameSuffix.state = .on
        }else if value == "DEVICE_MODEL" {
            self.chkDeviceModelSuffix.state = .on
        }else if value == "NUMBER" {
            self.chkNumberSuffix.state = .on
        }else{
            // default
            self.chkOverwriteDuplicate.state = .on
        }
    }
    
    @IBAction func onOverwriteClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkNumberSuffix.state = .off
            self.chkDeviceNameSuffix.state = .off
            self.chkDeviceModelSuffix.state = .off
        }else {
            if self.getFilenameDuplicatedStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onDeviceNameSuffixClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkNumberSuffix.state = .off
            self.chkOverwriteDuplicate.state = .off
            self.chkDeviceModelSuffix.state = .off
        }else {
            if self.getFilenameDuplicatedStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onDeviceModelSuffixClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkNumberSuffix.state = .off
            self.chkDeviceNameSuffix.state = .off
            self.chkOverwriteDuplicate.state = .off
        }else {
            if self.getFilenameDuplicatedStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onNumberSuffixClicked(_ sender: NSButton) {
        if sender.state == .on {
            self.chkOverwriteDuplicate.state = .off
            self.chkDeviceNameSuffix.state = .off
            self.chkDeviceModelSuffix.state = .off
        }else {
            if self.getFilenameDuplicatedStrategy() == "" {
                sender.state = .on
            }
        }
    }
    
    @IBAction func onLogFileClicked(_ sender: NSButton) {
        let url = URL(fileURLWithPath: AppDelegate.current.logFilePath())
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    
}
