//
//  EditRepositoryViewController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/12/30.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class EditRepositoryViewController: NSViewController {
    
    // MARK: FIELDS
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtHomePath: NSTextField!
    @IBOutlet weak var txtStoragePath: NSTextField!
    @IBOutlet weak var txtRepository: NSTextField!
    @IBOutlet weak var txtFacePath: NSTextField!
    @IBOutlet weak var txtCropPath: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    @IBOutlet weak var lblMessage: NSTextField!
    @IBOutlet weak var btnBrowseHomePath: NSButton!
    @IBOutlet weak var btnBrowseStoragePath: NSButton!
    @IBOutlet weak var btnBrowseRepositoryPath: NSButton!
    @IBOutlet weak var btnBrowseFacePath: NSButton!
    @IBOutlet weak var btnBrowseCropPath: NSButton!
    @IBOutlet weak var btnFindHomePath: NSButton!
    @IBOutlet weak var btnFindStoragePath: NSButton!
    @IBOutlet weak var btnFindRepositoryPath: NSButton!
    @IBOutlet weak var btnFindFacePath: NSButton!
    @IBOutlet weak var btnFindCropPath: NSButton!
    @IBOutlet weak var lblNameRemark: NSTextField!
    @IBOutlet weak var lblHomePathRemark: NSTextField!
    @IBOutlet weak var lblStoragePathRemark: NSTextField!
    @IBOutlet weak var lblRepositoryPathRemark: NSTextField!
    @IBOutlet weak var lblFacePathRemark: NSTextField!
    @IBOutlet weak var lblCropPathRemark: NSTextField!
    @IBOutlet weak var btnFollowHomePath: NSButton!
    @IBOutlet weak var btnUpdate: NSButton!
    
    
    // MARK: INIT
    
    init(){
        super.init(nibName: NSNib.Name(rawValue: "EditRepositoryViewController"), bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private var window:NSWindow? = nil
    
    // MARK: ACTIONS
    
    fileprivate var onCompleted: (() -> Void)?
    
    fileprivate func emtpyTextFields() {
        self.txtName.stringValue = ""
        self.lblNameRemark.stringValue = ""
        self.txtHomePath.stringValue = ""
        self.lblHomePathRemark.stringValue = ""
        self.txtStoragePath.stringValue = ""
        self.lblStoragePathRemark.stringValue = ""
        self.txtRepository.stringValue = ""
        self.lblRepositoryPathRemark.stringValue = ""
        self.txtFacePath.stringValue = ""
        self.lblFacePathRemark.stringValue = ""
        self.txtCropPath.stringValue = ""
        self.lblCropPathRemark.stringValue = ""
    }
    
    func initNew(window:NSWindow, onOK: (() -> Void)? = nil) {
        self.onCompleted = onOK
        self.window = window
        self.emtpyTextFields()
    }
    
    func initEdit(path:String, window:NSWindow, onOK: (() -> Void)? = nil) {
        self.onCompleted = onOK
        self.window = window
        self.emtpyTextFields()
    }
    
    fileprivate func checkDirectory(path:String, messageBox:NSTextField) -> Bool {
        var isDir:ObjCBool = false
        var pass = true
        let trimPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
        if FileManager.default.fileExists(atPath: trimPath, isDirectory: &isDir) { // exist as a file
            if isDir.boolValue == false {
                pass = false
                messageBox.stringValue = "Path is occupied by a file. You need a folder."
            }
        }else{ // not exist
            do {
                try FileManager.default.createDirectory(atPath: trimPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                pass = false
                messageBox.stringValue = "Unable to create directory at \(path)"
                print(error)
            }
        }
        return pass
    }
    
    @IBAction func onOKClicked(_ sender: Any) {
        if self.txtName.stringValue == "" {
            self.lblNameRemark.stringValue = "Please give me a name."
        }
        if self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
        }
        if self.txtStoragePath.stringValue == "" {
            self.lblStoragePathRemark.stringValue = "Please assign path for storing RAW copies."
        }
        if self.txtRepository.stringValue == "" {
            self.lblRepositoryPathRemark.stringValue = "Please assign path for storing modifies."
        }
        if self.txtFacePath.stringValue == "" {
            self.lblFacePathRemark.stringValue = "Please assign path for storing recognized pictures."
        }
        if self.txtCropPath.stringValue == "" {
            self.lblCropPathRemark.stringValue = "Please assign path for storing faces within pictures."
        }
        guard self.txtName.stringValue != ""
            && self.txtHomePath.stringValue != ""
            && self.txtStoragePath.stringValue != ""
            && self.txtRepository.stringValue != ""
            && self.txtFacePath.stringValue != ""
            && self.txtCropPath.stringValue != ""
            else {return}
        var pass = true
        pass = pass && self.checkDirectory(path: self.txtHomePath.stringValue, messageBox: self.lblHomePathRemark)
        pass = pass && self.checkDirectory(path: self.txtStoragePath.stringValue, messageBox: self.lblStoragePathRemark)
        pass = pass && self.checkDirectory(path: self.txtRepository.stringValue, messageBox: self.lblRepositoryPathRemark)
        pass = pass && self.checkDirectory(path: self.txtFacePath.stringValue, messageBox: self.lblFacePathRemark)
        pass = pass && self.checkDirectory(path: self.txtCropPath.stringValue, messageBox: self.lblCropPathRemark)
        
        guard pass else {return}
        
        ImageFolderTreeScanner.createRepository(name: self.txtName.stringValue.trimmingCharacters(in: .whitespacesAndNewlines),
                                                path: self.txtRepository.stringValue.trimmingCharacters(in: .whitespacesAndNewlines),
                                                homePath: self.txtHomePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines),
                                                storagePath: self.txtStoragePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines),
                                                facePath: self.txtFacePath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines),
                                                cropPath: self.txtCropPath.stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
        if self.onCompleted != nil {
            self.onCompleted!()
        }
    }
    
    @IBAction func onFollowHomePathClicked(_ sender: NSButton) {
        
        if self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
            return
        }
        
        if !self.checkDirectory(path: self.txtHomePath.stringValue, messageBox: self.lblHomePathRemark) {
            return
        }
        
        let home = URL(fileURLWithPath: self.txtHomePath.stringValue)
        let storage = home.appendingPathComponent("import")
        let repository = home.appendingPathComponent("repository")
        let face = home.appendingPathComponent("faces")
        let crop = home.appendingPathComponent("crop")
        
        self.lblRepositoryPathRemark.stringValue = "original: \(self.txtRepository.stringValue)"
        self.lblStoragePathRemark.stringValue = "original: \(self.txtStoragePath.stringValue)"
        self.lblFacePathRemark.stringValue = "original: \(self.txtFacePath.stringValue)"
        self.lblCropPathRemark.stringValue = "original: \(self.txtCropPath.stringValue)"
        
        self.txtRepository.stringValue = repository.path
        self.txtStoragePath.stringValue = storage.path
        self.txtFacePath.stringValue = face.path
        self.txtCropPath.stringValue = crop.path
    }
    
    
    @IBAction func onUpdateClicked(_ sender: NSButton) {
        // TODO: update something?
        print("update something?")
    }
    
    
    @IBAction func onBrowseHomePath(_ sender: NSButton) {
        if let win = self.window {
        
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true

            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    self.lblHomePathRemark.stringValue = "previous: \(self.txtHomePath.stringValue)"
                    self.txtHomePath.stringValue = url.path
                }
            }
        }
    }
    
    @IBAction func onBrowseStoragePathClicked(_ sender: NSButton) {
        if let win = self.window {
            
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true
            
            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    self.lblStoragePathRemark.stringValue = "previous: \(self.txtStoragePath.stringValue)"
                    self.txtStoragePath.stringValue = url.path
                }
            }
        }
    }
    
    @IBAction func onBrowseRepositoryPathClicked(_ sender: NSButton) {
        if let win = self.window {
            
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true
            
            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    self.lblRepositoryPathRemark.stringValue = "previous: \(self.txtRepository.stringValue)"
                    self.txtRepository.stringValue = url.path
                }
            }
        }
    }
    
    @IBAction func onBrowseFacePathClicked(_ sender: NSButton) {
        if let win = self.window {
            
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true
            
            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    self.lblFacePathRemark.stringValue = "previous: \(self.txtFacePath.stringValue)"
                    self.txtFacePath.stringValue = url.path
                }
            }
        }
    }
    
    @IBAction func onBrowseCropPath(_ sender: NSButton) {
        if let win = self.window {
            
            let openPanel = NSOpenPanel()
            openPanel.canChooseDirectories  = true
            openPanel.canChooseFiles        = false
            openPanel.showsHiddenFiles      = false
            openPanel.canCreateDirectories  = true
            
            openPanel.beginSheetModal(for: win) { (response) -> Void in
                guard response == NSApplication.ModalResponse.OK else {return}
                if let url = openPanel.url {
                    self.lblCropPathRemark.stringValue = "previous: \(self.txtCropPath.stringValue)"
                    self.txtCropPath.stringValue = url.path
                }
            }
        }
    }
    
    @IBAction func onFindHomePath(_ sender: NSButton) {
        if self.txtHomePath.stringValue == "" {
            self.lblHomePathRemark.stringValue = "Please assign path for home of this repository."
            return
        }
        
        if !self.checkDirectory(path: self.txtHomePath.stringValue, messageBox: self.lblHomePathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: self.txtHomePath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onFindStoragePathClicked(_ sender: NSButton) {
        if self.txtStoragePath.stringValue == "" {
            self.lblStoragePathRemark.stringValue = "Please assign path for storing RAW copies."
            return
        }
        
        if !self.checkDirectory(path: self.txtStoragePath.stringValue, messageBox: self.lblStoragePathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: self.txtStoragePath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onFindRepositoryPathClicked(_ sender: NSButton) {
        if self.txtRepository.stringValue == "" {
            self.lblRepositoryPathRemark.stringValue = "Please assign path for storing modifies."
            return
        }
        
        if !self.checkDirectory(path: self.txtRepository.stringValue, messageBox: self.lblRepositoryPathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: self.txtRepository.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onFindFaceRepositoryPathClicked(_ sender: NSButton) {
        if self.txtFacePath.stringValue == "" {
            self.lblFacePathRemark.stringValue = "Please assign path for storing recognized pictures."
            return
        }
        
        if !self.checkDirectory(path: self.txtFacePath.stringValue, messageBox: self.lblFacePathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: self.txtFacePath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onFindCropPath(_ sender: NSButton) {
        if self.txtCropPath.stringValue == "" {
            self.lblCropPathRemark.stringValue = "Please assign path for storing faces within pictures."
            return
        }
        
        if !self.checkDirectory(path: self.txtCropPath.stringValue, messageBox: self.lblCropPathRemark) {
            return
        }
        
        let url = URL(fileURLWithPath: self.txtCropPath.stringValue)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
}
