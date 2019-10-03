//
//  ExportConfigurationViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/30.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class ExportConfigurationViewController: NSViewController {
    
    @IBOutlet weak var chkPeople: NSButton!
    @IBOutlet weak var chkEvents: NSButton!
    
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtDirectory: NSTextField!
    
    @IBOutlet weak var txtPeople: NSTextField!
    @IBOutlet weak var txtEvents: NSTextField!
    
    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var btnAssign: NSButton!
    @IBOutlet weak var btnGoto: NSButton!
    @IBOutlet weak var btnSelectPeople: NSButton!
    @IBOutlet weak var btnSelectEvent: NSButton!
    
    @IBOutlet weak var chkOverwriteDuplicate: NSButton!
    @IBOutlet weak var chkDeviceNameSuffix: NSButton!
    @IBOutlet weak var chkDeviceModelSuffix: NSButton!
    @IBOutlet weak var chkNumberSuffix: NSButton!
    
    
    @IBOutlet weak var stackView: NSStackView!
    
    fileprivate var editingId = ""
    
    init() {
        super.init(nibName: NSNib.Name(rawValue: "ExportConfigurationViewController"), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        stackView.setHuggingPriority(NSLayoutConstraint.Priority.defaultHigh, for: .horizontal)
        
        
        self.addViewController(id: "1", name: "test1", path: "~/Pictures/nas", options: "any people, any event, any place")
        self.addViewController(id: "2", name: "test2", path: "~/Pictures/Photos", options: "family, water, any place")
        self.addViewController(id: "3", name: "test3", path: "~/Pictures/Plex", options: "company, biz trip, any place")
        self.addViewController(id: "4", name: "test4", path: "~/Pictures/Plex", options: "friend, vacation trip, any place")
    }
    
    /// Used to add a particular view controller as an item to our stack view.
    func addViewController(id:String, name:String, path:String, options:String) {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "ExportStackItems"), bundle: nil)
        let viewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "ExportProfile")) as! ExportProfileViewController
        
        viewController.initView(id: id, name: name, path: path, options: options,
                                onEdit: {
                                    self.editingId = id
                                    self.txtName.stringValue = name
                                    self.txtDirectory.stringValue = path
                                }, onDelete: {
                                    if Alert.dialogOKCancel(question: "DELETE PROFILE", text: "Do you confirm to delete profile [\(name)] ?") {
                                        print("proceed delete")
                                        NSLayoutConstraint.deactivate(viewController.view.constraints)
                                        //self.stackView.removeArrangedSubview(viewController.view)
                                        self.stackView.removeView(viewController.view)
                                    }
                                })
        
        stackView.addArrangedSubview(viewController.view)
        //addChildViewController(viewController)
        
    }
    
    @IBAction func onSaveClicked(_ sender: NSButton) {
        let name = self.txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let path = self.txtDirectory.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        var people = self.txtPeople.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        var events = self.txtEvents.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if chkPeople.state == .off || people == "" {
            people = "any people"
        }
        if chkEvents.state == .off || events == "" {
            events = "any event"
        }
        
        self.addViewController(id: "X", name: name, path: path, options: "People: \(people); Events: \(events)")
    }
    
    @IBAction func onAssignDirectoryClicked(_ sender: NSButton) {
    }
    
    @IBAction func onGotoDirectoryClicked(_ sender: NSButton) {
    }
    
    @IBAction func onSelectPeopleClicked(_ sender: NSButton) {
    }
    
    @IBAction func onSelectEventClicked(_ sender: NSButton) {
    }
    
    @IBAction func onCheckPeopleClicked(_ sender: NSButton) {
    }
    
    @IBAction func onCheckEventsClicked(_ sender: NSButton) {
    }
    
    
}

class CustomStackView : NSStackView {
    
    override var isFlipped: Bool { return true }
}
