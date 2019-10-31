//
//  ExportConfigurationViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/30.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class ExportConfigurationViewController: NSViewController {
    
    // MARK: - CONTROLS
    
    @IBOutlet weak var chkPeople: NSButton!
    @IBOutlet weak var chkEvents: NSButton!
    
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtDirectory: NSTextField!
    
    @IBOutlet weak var txtPeople: NSTextField!
    @IBOutlet weak var txtEvents: NSTextField!
    
    @IBOutlet weak var btnClean: NSButton!
    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var btnAssign: NSButton!
    @IBOutlet weak var btnGoto: NSButton!
    @IBOutlet weak var btnSelectPeople: NSButton!
    @IBOutlet weak var btnSelectEvent: NSButton!
    
    @IBOutlet weak var chkOverwriteDuplicate: NSButton!
    @IBOutlet weak var chkDeviceNameSuffix: NSButton!
    @IBOutlet weak var chkDeviceModelSuffix: NSButton!
    @IBOutlet weak var chkNumberSuffix: NSButton!
    @IBOutlet weak var chkRepository: NSButton!
    @IBOutlet weak var txtRepository: NSTextField!
    @IBOutlet weak var btnSelectRepository: NSButton!
    
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
    
    
    @IBOutlet weak var stackView: NSStackView!
    
    var peopleOptions : OneColumnTablePopover!
    var eventsOptions : OneColumnTablePopover!
    var repositoryOptions : OneColumnTablePopover!
    
    var repoNames:[String:String] = [:]
    
    var profileStackItems:[String:ExportProfileViewController] = [:]
    
    // MARK: - PROPERTIES
    
    fileprivate var editingId = ""
    private var window:NSWindow? = nil
    
    // MARK: - INIT
    
    init() {
        super.init(nibName: NSNib.Name(rawValue: "ExportConfigurationViewController"), bundle: nil)
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
        
//        self.txtEvents.isEditable = false
//        self.txtPeople.isEditable = false
//        self.txtRepository.isEditable = false
//        self.txtDirectory.isEditable = false
        
        self.peopleOptions = OneColumnTablePopover(width: 100, height: 200, onClick: { (name, _, _) in
            // on click people name
            print("selected \(name)")
            var selected = self.txtPeople.stringValue.components(separatedBy: ",")
            if !selected.contains(name) {
                if selected[0] == "" {
                    selected.remove(at: 0)
                }
                selected.append(name)
                selected.sort()
                self.txtPeople.stringValue = selected.joined(separator: ",")
            }
        })
        
        self.eventsOptions = OneColumnTablePopover(width: 300, height: 200, onClick: { (name, _, _) in
            // on click event name
            print("selected \(name)")
            var selected = self.txtEvents.stringValue.components(separatedBy: ",")
            if !selected.contains(name) {
                if selected[0] == "" {
                    selected.remove(at: 0)
                }
                selected.append(name)
                selected.sort()
                self.txtEvents.stringValue = selected.joined(separator: ",")
            }
        })
        
        self.repositoryOptions = OneColumnTablePopover(width: 150, height: 200, onClick: { (path, name, _) in
            // on click repo path
            print("selected \(name)")
            let selected = self.txtRepository.stringValue
            if selected != name {
                self.txtRepository.stringValue = name
            }
        })
        
        var repoPaths:[(String, String)] = []
        let repos = ModelStore.default.getRepositories()
        for repo in repos {
            repoPaths.append((repo.path, repo.name))
            repoNames[repo.name] = repo.path
        }
        self.repositoryOptions.load(repoPaths)
        
        var eventNames:[String] = []
        let events = ModelStore.default.getEvents()
        for event in events {
            eventNames.append(event.name)
        }
        self.eventsOptions.load(eventNames)
        
        var peopleNames:[(String, String)] = []
        let people = ModelStore.default.getPeople()
        for person in people {
            peopleNames.append((person.name, person.shortName ?? ""))
        }
        self.peopleOptions.load(peopleNames)
        
        self.cleanFields()
        self.loadStackItems()
    }
    
    private func loadStackItems() {
        
        let profiles = ModelStore.default.getAllExportProfiles()
        for profile in profiles {
            self.addProfileItem(profile: profile)
        }
    }
    
    // MARK: - CLEAN FIELDS
    
    private func cleanFields() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        self.editingId = dateFormatter.string(from: Date())
        self.txtName.stringValue = ""
        self.txtDirectory.stringValue = ""
        self.txtRepository.stringValue = ""
        self.txtPeople.stringValue = ""
        self.txtEvents.stringValue = ""
        self.setFileNamingStrategy("DATETIME_BRIEF")
        self.setSubFolderStrategy("DATE_EVENT")
        self.setFilenameDuplicatedStrategy("OVERWRITE")
        self.chkPatchDateTime.state = .off
        self.chkPatchGeolocation.state = .off
        self.chkPatchImageDescription.state = .off
    }
    
    private func fillFields(profile:ExportProfile) {
        self.editingId = profile.id
        self.txtName.stringValue = profile.name
        self.txtDirectory.stringValue = profile.directory
        self.txtRepository.stringValue = profile.repositoryPath
        self.txtPeople.stringValue = profile.people
        self.txtEvents.stringValue = profile.events
        self.chkRepository.state = profile.specifyRepository ? .on : .off
        self.chkPeople.state = profile.specifyPeople ? .on : .off
        self.chkEvents.state = profile.specifyEvent ? .on : .off
        self.chkPatchImageDescription.state = profile.patchImageDescription ? .on : .off
        self.chkPatchGeolocation.state = profile.patchGeolocation ? .on : .off
        self.chkPatchDateTime.state = profile.patchDateTime ? .on : .off
        self.setFileNamingStrategy(profile.fileNaming)
        self.setSubFolderStrategy(profile.subFolder)
        self.setFilenameDuplicatedStrategy(profile.duplicateStrategy)
        
    }
    
    @IBAction func onCleanClicked(_ sender: NSButton) {
        self.cleanFields()
    }
    
    
    // MARK: - SAVE ACTION
    
    @IBAction func onSaveClicked(_ sender: NSButton) {
        let name = self.txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let path = self.txtDirectory.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let repos = self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let people = self.txtPeople.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let events = self.txtEvents.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let fileNaming = self.getFileNamingStrategy()
        let fileDuplicated = self.getFilenameDuplicatedStrategy()
        let subfolder = self.getSubFolderStrategy()
        
        let profile = ModelStore.default.getOrCreateExportProfile(id: self.editingId,
                                                    name: name,
                                                    directory: path,
                                                    repositoryPath: repos,
                                                    specifyPeople: self.chkPeople.state == .on,
                                                    specifyEvent: self.chkEvents.state == .on,
                                                    specifyRepository: self.chkRepository.state == .on,
                                                    people: people,
                                                    events: events,
                                                    duplicateStrategy: fileDuplicated,
                                                    fileNaming: fileNaming,
                                                    subFolder: subfolder,
                                                    patchImageDescription: self.chkPatchImageDescription.state == .on,
                                                    patchDateTime: self.chkPatchDateTime.state == .on,
                                                    patchGeolocation: self.chkPatchGeolocation.state == .on
                                                    )
        
        if let vc = self.profileStackItems[profile.id] {
            vc.updateView(profile: profile)
        }else{
            self.addProfileItem(profile: profile)
        }
    }
    
    // MARK: - STACK ITEMS
    
    /// Used to add a particular view controller as an item to our stack view.
    func addProfileItem(profile:ExportProfile) {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "ExportStackItems"), bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ExportProfile")) as! ExportProfileViewController
        
        viewController.initView(profile: profile,
                                onEdit: {
                                    self.fillFields(profile: profile)
        }, onDelete: {
            if Alert.dialogOKCancel(question: "DELETE PROFILE", text: "Do you confirm to delete profile [\(profile.name)] ?") {
                print("proceed delete")
                let state = ModelStore.default.deleteExportProfile(id: profile.id)
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
    
    // MARK: - PEOPLE, EVENTS
    
    @IBAction func onSelectPeopleClicked(_ sender: NSButton) {
        self.peopleOptions.show(sender)
    }
    
    @IBAction func onSelectEventClicked(_ sender: NSButton) {
        self.eventsOptions.show(sender)
    }
    
    @IBAction func onCheckPeopleClicked(_ sender: NSButton) {
    }
    
    @IBAction func onCheckEventsClicked(_ sender: NSButton) {
    }
    
    // MARK: - FROM REPOSITORY
    
    @IBAction func onCheckRepository(_ sender: NSButton) {
    }
    
    @IBAction func onSelectRepository(_ sender: NSButton) {
        self.repositoryOptions.show(sender)
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

class CustomStackView : NSStackView {
    
    override var isFlipped: Bool { return true }
}
