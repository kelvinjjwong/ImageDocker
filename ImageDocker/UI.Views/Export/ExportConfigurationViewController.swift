//
//  ExportConfigurationViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/30.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class ExportConfigurationViewController: NSViewController {
    
    let logger = ConsoleLogger(category: "ExportConfigurationViewController")
    
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
    
    @IBOutlet weak var btnClean: NSButton!
    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var btnAssign: NSButton!
    @IBOutlet weak var btnGoto: NSButton!
    
    @IBOutlet weak var chkRepository: NSButton!
    @IBOutlet weak var chkIncludeRepository: NSButton!
    @IBOutlet weak var chkExcludeRepository: NSButton!
    @IBOutlet weak var tblRepository: NSTableView!
    
    var repositoryTableController : DictionaryTableViewController!
    
    @IBOutlet weak var chkEvents: NSButton!
    @IBOutlet weak var chkIncludeEvent: NSButton!
    @IBOutlet weak var chkExcludeEvent: NSButton!
    @IBOutlet weak var tblEvent: NSTableView!
    
    var eventTableController : DictionaryTableViewController!
    
    var eventCategoriesTableController : DictionaryTableViewController!
    
    @IBOutlet weak var chkPeople: NSButton!
    @IBOutlet weak var chkIncludePeople: NSButton!
    @IBOutlet weak var chkExcludePeople: NSButton!
    @IBOutlet weak var tblPeople: NSTableView!
    
    var peopleTableController : DictionaryTableViewController!
    
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
    
    @IBOutlet weak var boxName: NSBox!
    @IBOutlet weak var boxAction: NSBox!
    @IBOutlet weak var boxRepositories: NSBox!
    @IBOutlet weak var boxEvents: NSBox!
    @IBOutlet weak var boxFamilies: NSBox!
    @IBOutlet weak var boxPeople: NSBox!
    
    
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
        self.btnClean.title = Words.export_profile_new.word()
        self.btnAssign.title = Words.export_profile_assign_to_directory.word()
        self.btnGoto.title = Words.export_profile_goto_to_directory.word()
        
        self.boxRepositories.title = Words.export_profile_repositories.word()
        self.chkRepository.title = Words.export_profile_has_limit.word()
        self.boxEvents.title = Words.export_profile_events.word()
        self.chkEvents.title = Words.export_profile_has_limit.word()
        self.boxPeople.title = Words.export_profile_people.word()
        self.chkPeople.title = Words.export_profile_has_limit.word()
        self.boxFamilies.title = Words.export_profile_families.word()
        self.chkFamilies.title = Words.export_profile_has_limit.word()
        self.boxEventCategories.title = Words.export_profile_event_categories.word()
        self.chkEventCategories.title = Words.export_profile_has_limit.word()
        
        self.chkIncludeRepository.title = Words.export_profile_include.word()
        self.chkExcludeRepository.title = Words.export_profile_exclude.word()
        self.chkIncludeEvent.title = Words.export_profile_include.word()
        self.chkExcludeEvent.title = Words.export_profile_exclude.word()
        self.chkIncludePeople.title = Words.export_profile_include.word()
        self.chkExcludePeople.title = Words.export_profile_exclude.word()
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
        self.btnExport.title = Words.export_profile_export.word()
        self.btnRehearsal.title = Words.export_profile_rehearsal.word()
        self.lstRehearsalAmount.item(at: 0)?.title = Words.export_profile_rehearsal_n_images.fill(arguments: "10")
        self.lstRehearsalAmount.item(at: 1)?.title = Words.export_profile_rehearsal_n_images.fill(arguments: "100")
        self.lstRehearsalAmount.item(at: 2)?.title = Words.export_profile_rehearsal_n_images.fill(arguments: "500")
        self.lstRehearsalAmount.item(at: 3)?.title = Words.export_profile_rehearsal_all_images.word()
    }
    
    private var toggleGroup_Repository:ToggleGroup!
    private var toggleGroup_Event:ToggleGroup!
    private var toggleGroup_EventCategory:ToggleGroup!
    private var toggleGroup_People:ToggleGroup!
    private var toggleGroup_Family:ToggleGroup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.toggleGroup_Repository = ToggleGroup([
            "include" : self.chkIncludeRepository,
            "exclude" : self.chkExcludeRepository
        ], keysOrderred: ["include", "exclude"])
        
        self.toggleGroup_Repository.selected = "include"
        
        self.toggleGroup_EventCategory = ToggleGroup([
            "include" : self.chkIncludeEventCategories,
            "exclude" : self.chkExcludeEventCategories
        ], keysOrderred: ["include", "exclude"])
        
        self.toggleGroup_EventCategory.selected = "include"
        
        self.toggleGroup_Event = ToggleGroup([
            "include" : self.chkIncludeEvent,
            "exclude" : self.chkExcludeEvent
        ], keysOrderred: ["include", "exclude"])
        
        self.toggleGroup_Event.selected = "include"
        
        self.toggleGroup_People = ToggleGroup([
            "include" : self.chkIncludePeople,
            "exclude" : self.chkExcludePeople
        ], keysOrderred: ["include", "exclude"])
        
        self.toggleGroup_People.selected = "include"
        
        self.toggleGroup_Family = ToggleGroup([
            "include" : self.chkIncludeFamily,
            "exclude" : self.chkExcludeFamily
        ], keysOrderred: ["include", "exclude"])
        
        self.toggleGroup_Family.selected = "include"
        
        
        view.wantsLayer = true
        stackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        self.chkRepository.state = .off
        self.repositoryTableController = DictionaryTableViewController(self.tblRepository)
        
        var repoPaths:[[String:String]] = []
        let repos = RepositoryDao.default.getRepositories()
        for repo in repos {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["name"] = repo.name
            item["path"] = repo.path
            item["id"] = repo.path
            repoPaths.append(item)
        }
        self.repositoryTableController.load(repoPaths)
        self.tblRepository.isEnabled = false
        
        self.chkEvents.state = .off
        self.eventTableController = DictionaryTableViewController(self.tblEvent)
        
        var eventNames:[[String:String]] = []
        let events = EventDao.default.getEvents()
        for event in events {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["name"] = event.name
            item["id"] = event.name
            eventNames.append(item)
        }
        self.eventTableController.load(eventNames)
        self.tblEvent.isEnabled = false
        
        self.chkEventCategories.state = .off
        self.eventCategoriesTableController = DictionaryTableViewController(self.tblEventCategories)
        
        var eventCategoryNames:[[String:String]] = []
        let eventCategories = EventDao.default.getEventCategories()
        for eventCategory in eventCategories {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["name"] = eventCategory
            item["id"] = eventCategory
            eventCategoryNames.append(item)
        }
        self.eventCategoriesTableController.load(eventCategoryNames)
        self.tblEventCategories.isEnabled = false
        
        self.chkPeople.state = .off
        self.peopleTableController = DictionaryTableViewController(self.tblPeople)
        
        var peopleNames:[[String:String]] = []
        let people = FaceDao.default.getPeople()
        for person in people {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["name"] = person.name
            item["shortName"] = person.shortName ?? person.name
            item["id"] = person.id
            peopleNames.append(item)
        }
        self.peopleTableController.load(peopleNames)
        self.tblPeople.isEnabled = false
        
        self.chkFamilies.state = .off
        self.familyTableController = DictionaryTableViewController(self.tblFamily)
        
        var familyNames:[[String:String]] = []
        let families = FaceDao.default.getFamilies()
        for family in families {
            var item:[String:String] = [:]
            item["check"] = "false"
            item["name"] = family.name
            item["id"] = family.id
            familyNames.append(item)
        }
        self.familyTableController.load(familyNames)
        self.tblFamily.isEnabled = false
        
        self.cleanFields()
        self.loadStackItems()
        
        self.toggleRepository(false)
        self.toggleEvent(false)
        self.togglePeople(false)
        self.toggleFamily(false)
        
        
        // TODO remove if not debug
        self.txtName.stringValue = "Auto Profile - \(Date())"
        self.txtDirectory.stringValue = "/Volumes/PhotoStorage/Images.export/"
    }
    
    private func loadStackItems() {
        
        let profiles = ExportDao.default.getAllExportProfiles()
        for profile in profiles {
            self.addProfileItem(profile: profile)
        }
    }
    
    private var isNewRecord = true
    
    // MARK: - CLEAN FIELDS
    
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
        
        self.chkRepository.state = .off
        self.repositoryTableController.uncheckAll()
        self.repositoryTableController.disableCheckboxes()
        
        self.chkEvents.state = .off
        self.eventTableController.uncheckAll()
        self.eventTableController.disableCheckboxes()
        
        self.chkPeople.state = .off
        self.peopleTableController.uncheckAll()
        self.peopleTableController.disableCheckboxes()
        
        self.chkFamilies.state = .off
        self.familyTableController.uncheckAll()
        self.familyTableController.disableCheckboxes()
    }
    
    private func fillFields(profile:ExportProfile) {
        self.isNewRecord = false
        self.editingId = profile.id
        self.txtName.stringValue = profile.name
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
            self.toggleGroup_Repository.enable()
            self.toggleGroup_Repository.selected = "include"
            let value = repos.replacingFirstOccurrence(of: "include:", with: "")
            self.logger.log("repo: \(value)")
            self.repositoryTableController.setCheckedItems(column: "name", from: value, separator: ",", quoted: true)
            self.repositoryTableController.enableCheckboxes()
        }else if repos.hasPrefix("exclude:") {
            self.toggleGroup_Repository.enable()
            self.toggleGroup_Repository.selected = "exclude"
            let value = repos.replacingFirstOccurrence(of: "exclude:", with: "")
            self.logger.log("repo: \(value)")
            self.repositoryTableController.setCheckedItems(column: "name", from: value, separator: ",", quoted: true)
            self.repositoryTableController.enableCheckboxes()
        }
        if !profile.specifyRepository {
            self.repositoryTableController.disableCheckboxes()
        }
        
        self.chkEvents.state = profile.specifyEvent ? .on : .off
        let events = profile.events
        if events.hasPrefix("include:") {
            self.toggleGroup_Event.enable()
            self.toggleGroup_Event.selected = "include"
            let value = events.replacingFirstOccurrence(of: "include:", with: "")
            self.logger.log("event: \(value)")
            self.eventTableController.setCheckedItems(column: "name", from: value, separator: ",", quoted: true)
            self.eventTableController.enableCheckboxes()
        }else if events.hasPrefix("exclude:") {
            self.toggleGroup_Event.enable()
            self.toggleGroup_Event.selected = "exclude"
            let value = events.replacingFirstOccurrence(of: "exclude:", with: "")
            self.logger.log("event: \(value)")
            self.eventTableController.setCheckedItems(column: "name", from: value, separator: ",", quoted: true)
            self.eventTableController.enableCheckboxes()
        }
        if !profile.specifyEvent {
            self.eventTableController.disableCheckboxes()
        }
        
        self.chkPeople.state = profile.specifyPeople ? .on : .off
        let people = profile.people
        if people.hasPrefix("include:") {
            self.toggleGroup_People.enable()
            self.toggleGroup_People.selected = "include"
            let value = people.replacingFirstOccurrence(of: "include:", with: "")
            self.logger.log("people: \(value)")
            self.peopleTableController.setCheckedItems(column: "name", from: value, separator: ",", quoted: true)
            self.peopleTableController.enableCheckboxes()
        }else if people.hasPrefix("exclude:") {
            self.toggleGroup_People.enable()
            self.toggleGroup_People.selected = "exclude"
            let value = people.replacingFirstOccurrence(of: "exclude:", with: "")
            self.logger.log("people: \(value)")
            self.peopleTableController.setCheckedItems(column: "name", from: value, separator: ",", quoted: true)
            self.peopleTableController.enableCheckboxes()
        }
        if !profile.specifyPeople {
            self.peopleTableController.disableCheckboxes()
        }
        
        self.chkFamilies.state = profile.specifyFamily ? .on : .off
        let family = profile.family
        if family.hasPrefix("include:") {
            self.toggleGroup_Family.enable()
            self.toggleGroup_Family.selected = "include"
            let value = family.replacingFirstOccurrence(of: "include:", with: "")
            self.logger.log("family: \(value)")
            self.familyTableController.setCheckedItems(column: "name", from: value, separator: ",", quoted: true)
            self.familyTableController.enableCheckboxes()
        }else if family.hasPrefix("exclude:") {
            self.toggleGroup_Family.enable()
            self.toggleGroup_Family.selected = "exclude"
            let value = family.replacingFirstOccurrence(of: "exclude:", with: "")
            self.logger.log("family: \(value)")
            self.familyTableController.setCheckedItems(column: "name", from: value, separator: ",", quoted: true)
            self.familyTableController.enableCheckboxes()
        }
        if !profile.specifyFamily {
            self.familyTableController.disableCheckboxes()
        }
        
    }
    
    @IBAction func onCleanClicked(_ sender: NSButton) {
        self.cleanFields()
    }
    
    
    // MARK: - SAVE ACTION
    
    private func fillProfileFromForm(profile:ExportProfile) -> ExportProfile {
        let name = self.txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let path = self.txtDirectory.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileNaming = self.getFileNamingStrategy()
        let fileDuplicated = self.getFilenameDuplicatedStrategy()
        let subfolder = self.getSubFolderStrategy()
        
        // convert checkboxes to string
        var people = ""
        var eventCategories = ""
        var events = ""
        var repos = ""
        var family = ""
        
        if self.chkRepository.state == .on {
            let checked = self.repositoryTableController.getCheckedItemAsQuotedString(column: "name", separator: ",")
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
                }else if self.chkIncludeEventCategories.state == .on {
                    eventCategories = "exclude:\(checked)"
                }
            }
        }
        
        if self.chkEvents.state == .on {
            let checked = self.eventTableController.getCheckedItemAsQuotedString(column: "name", separator: ",")
            if checked != "" {
                if self.chkIncludeEvent.state == .on {
                    events = "include:\(checked)"
                }else if self.chkExcludeEvent.state == .on {
                    events = "exclude:\(checked)"
                }
            }
        }
        
        if self.chkPeople.state == .on {
            let checked = self.peopleTableController.getCheckedItemAsQuotedString(column: "name", separator: ",")
            if checked != "" {
                if self.chkIncludePeople.state == .on {
                    people = "include:\(checked)"
                }else if self.chkExcludePeople.state == .on {
                    people = "exclude:\(checked)"
                }
            }
        }
        
        if self.chkFamilies.state == .on {
            let checked = self.familyTableController.getCheckedItemAsQuotedString(column: "name", separator: ",")
            if checked != "" {
                if self.chkIncludeFamily.state == .on {
                    family = "include:\(checked)"
                }else if self.chkExcludeFamily.state == .on {
                    family = "exclude:\(checked)"
                }
            }
        }
        
        profile.name = name
        profile.directory = path
        profile.duplicateStrategy = fileDuplicated
        profile.specifyPeople = self.chkPeople.state == .on
        profile.specifyEvent = self.chkEvents.state == .on
        profile.specifyRepository = self.chkRepository.state == .on
        profile.specifyFamily = self.chkFamilies.state == .on
        profile.people = people
        profile.events = events
        profile.repositoryPath = repos
        profile.family = family
        profile.patchImageDescription = self.chkPatchImageDescription.state == .on
        profile.patchDateTime = self.chkPatchDateTime.state == .on
        profile.patchGeolocation = self.chkPatchGeolocation.state == .on
        profile.fileNaming = fileNaming
        profile.subFolder = subfolder
        profile.eventCategories = eventCategories
        
        return profile
    }
    
    @IBAction func onSaveClicked(_ sender: NSButton) {
        
        let form = self.fillProfileFromForm(profile: ExportProfile())
        
        var profile = ExportDao.default.getOrCreateExportProfile(id: self.editingId,
                                                                 name: form.name,
                                                                 directory: form.directory,
                                                                 repositoryPath: form.repositoryPath,
                                                                 specifyPeople: form.specifyPeople,
                                                                 specifyEvent: form.specifyEvent,
                                                                 specifyRepository: form.specifyRepository,
                                                                 people: form.people,
                                                                 events: form.events,
                                                                 duplicateStrategy: form.duplicateStrategy,
                                                                 fileNaming: form.fileNaming,
                                                                 subFolder: form.subFolder,
                                                                 patchImageDescription: form.patchImageDescription,
                                                                 patchDateTime: form.patchDateTime,
                                                                 patchGeolocation: form.patchGeolocation,
                                                                 specifyFamily: form.specifyFamily,
                                                                 family: form.family,
                                                                 eventCategories: form.eventCategories ?? ""
                                                                )
        if !self.isNewRecord {
            let status = ExportDao.default.updateExportProfile(id: self.editingId,
                                                               name: form.name,
                                                               directory: form.directory,
                                                               duplicateStrategy: form.duplicateStrategy,
                                                               specifyPeople: form.specifyPeople,
                                                               specifyEvent: form.specifyEvent,
                                                               specifyRepository: form.specifyRepository,
                                                               specifyFamily: form.specifyFamily,
                                                               people: form.people,
                                                               events: form.events,
                                                               repositoryPath: form.repositoryPath,
                                                               family: form.family,
                                                               patchImageDescription: form.patchImageDescription,
                                                               patchDateTime: form.patchDateTime,
                                                               patchGeolocation: form.patchGeolocation,
                                                               fileNaming: form.fileNaming,
                                                               subFolder: form.subFolder,
                                                               eventCategories: form.eventCategories ?? ""
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
                                    self.fillFields(profile: profile)
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
                    self.txtDirectory.stringValue = url.path
                }
            }
        }
    }
    
    @IBAction func onGotoDirectoryClicked(_ sender: NSButton) {
        if self.txtDirectory.stringValue == "" {
            Alert.show(message: "Please assign directory first.")
            return
        }
        
        let url = URL(fileURLWithPath: self.txtDirectory.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    // MARK: - CALCULATE & REHEARSAL
    
    private func getRehearsalAmount() -> Int? {
        var amount:Int? = nil
        if let selection = self.lstRehearsalAmount.titleOfSelectedItem {
            let number = selection.components(separatedBy: " ")[0]
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
    
    @IBAction func onExportClicked(_ sender: NSButton) {
        // real export with file i/o and amount limitation
        
        let profile = self.getProfile()
        let amount = self.getRehearsalAmount()
        
        DispatchQueue.global().async {
            let (state, message) = ExportManager.default.withMessageBox(self.lblCalculate).export(profile: profile, rehearsal: false, limit: amount)
            DispatchQueue.main.async {

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
        
        let profile = self.getProfile()
        let amount = self.getRehearsalAmount()
        
        DispatchQueue.global().async {
            let (state, message) = ExportManager.default.withMessageBox(self.lblCalculate).export(profile: profile, rehearsal: true, limit: amount)
            DispatchQueue.main.async {

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
    
    
    // MARK: - TOGGLES
    
    func toggleRepository(_ state:Bool) {
        if state == true {
            self.toggleGroup_Repository.enable()
            self.repositoryTableController.enableCheckboxes()
        }else{
            self.toggleGroup_Repository.disable()
            self.repositoryTableController.disableCheckboxes()
        }
    }
    
    @IBAction func onCheckRepository(_ sender: NSButton) {
        self.toggleRepository(sender.state == .on)
    }
    
    func toggleEvent(_ state:Bool) {
        if state == true {
            self.toggleGroup_Event.enable()
            self.eventTableController.enableCheckboxes()
        }else{
            self.toggleGroup_Event.disable()
            self.eventTableController.disableCheckboxes()
        }
    }
    
    
    @IBAction func onCheckEventsClicked(_ sender: NSButton) {
        self.toggleEvent(sender.state == .on)
    }
    
    @IBAction func onCheckEventCategoryClicked(_ sender: NSButton) {
        self.toggleEventCategory(sender.state == .on)
    }
    
    func toggleEventCategory(_ state:Bool) {
        if state == true {
            self.toggleGroup_EventCategory.enable()
            self.eventCategoriesTableController.enableCheckboxes()
        }else{
            self.toggleGroup_EventCategory.disable()
            self.eventCategoriesTableController.disableCheckboxes()
        }
    }
    
    func togglePeople(_ state:Bool) {
        if state == true {
            self.toggleGroup_People.enable()
            self.peopleTableController.enableCheckboxes()
        }else{
            self.toggleGroup_People.disable()
            self.peopleTableController.disableCheckboxes()
        }
    }
    
    @IBAction func onCheckPeopleClicked(_ sender: NSButton) {
        self.togglePeople(sender.state == .on)
    }
    
    func toggleFamily(_ state:Bool) {
        if state == true {
            self.toggleGroup_Family.enable()
            self.familyTableController.enableCheckboxes()
        }else{
            self.toggleGroup_Family.disable()
            self.familyTableController.disableCheckboxes()
        }
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
    
    @IBAction func onIncludeEventClicked(_ sender: NSButton) {
        self.toggleGroup_Event.selected = "include"
    }
    
    @IBAction func onExcludeEventClicked(_ sender: NSButton) {
        self.toggleGroup_Event.selected = "exclude"
    }
    
    @IBAction func onIncludeEventCategoryClicked(_ sender: NSButton) {
        self.toggleGroup_EventCategory.selected = "include"
    }
    
    @IBAction func onExcludeEventCategoryClicked(_ sender: NSButton) {
        self.toggleGroup_EventCategory.selected = "exclude"
    }
    
    @IBAction func onIncludePeopleClicked(_ sender: NSButton) {
        self.toggleGroup_People.selected = "include"
    }
    
    @IBAction func onExcludePeopleClicked(_ sender: NSButton) {
        self.toggleGroup_People.selected = "exclude"
    }
    
    @IBAction func onIncludeFamilyClicked(_ sender: NSButton) {
        self.toggleGroup_Family.selected = "include"
    }
    
    @IBAction func onExcludeFamilyClicked(_ sender: NSButton) {
        self.toggleGroup_Family.selected = "exclude"
    }
    
    
    // MARK: - SUB FOLDER STRATEGY
    
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
    
    // MARK: - FILE NAMING STRATEGY
    
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
    
    // MARK: - EXIF PATCHING OPTIONS
    
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
    
    // MARK: - DUPLICATED FILENAME RENAMING STRATEGY
    
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
    
    
}
