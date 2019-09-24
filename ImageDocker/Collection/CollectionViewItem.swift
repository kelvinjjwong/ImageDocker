//
//  CollectionViewItem.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//


import Cocoa

class CollectionViewItem: NSCollectionViewItem {
  
    @IBOutlet weak var checkBox: NSButton!
    @IBOutlet weak var lblPlace: NSTextField!
    @IBOutlet weak var btnLook: NSButton!
    @IBOutlet weak var btnCaution: NSButton!
    @IBOutlet weak var btnMenu: NSPopUpButton!
    
    private var checkBoxDelegate:CollectionViewItemCheckDelegate?
    private var showDuplicatesDelegate:CollectionViewItemShowDuplicatesDelegate?
    private var quickLookDelegate:CollectionViewItemQuickLookDelegate?
    private var previewDelegate:CollectionViewItemPreviewDelegate?
    private var previewMessageDelegate:CollectionViewItemPreviewMessageDelegate?
    
    var sectionIndex:Int?
    
    func setCheckBoxDelegate(_ delegate:CollectionViewItemCheckDelegate){
        self.checkBoxDelegate = delegate
    }
    
    func setShowDuplicatesDelegate(_ delegate:CollectionViewItemShowDuplicatesDelegate) {
        self.showDuplicatesDelegate = delegate
    }
    
    func setQuickLookDelegate(_ delegate:CollectionViewItemQuickLookDelegate) {
        self.quickLookDelegate = delegate
    }
    
    func setPreviewDelegate(_ delegate:CollectionViewItemPreviewDelegate) {
        self.previewDelegate = delegate
    }
    
    func setPreviewMessageDelegate(_ delegate:CollectionViewItemPreviewMessageDelegate) {
        self.previewMessageDelegate = delegate
    }
    
    var displayDateFormat:String = "HH:mm:ss"
    
    var imageFile: ImageFile? {
        didSet {
            guard isViewLoaded else { return }
            if let imageFile = imageFile {
                self.renderControls(imageFile)
            } else {
                imageView?.image = nil
                textField?.stringValue = ""
                lblPlace.stringValue = ""
                checkBox.state = NSButton.StateValue.off
                btnCaution.isHidden = true
            }
        }
    }
    
    var backgroundColor:NSColor?
    
    private var isControlsHidden = false
    
    func hideControls() {
        self.btnLook.isHidden = true
        self.btnCaution.isHidden = true
        self.checkBox.isHidden = true
        self.btnMenu.isHidden = true
        self.isControlsHidden = true
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = (backgroundColor ?? NSColor.darkGray).cgColor
        view.layer?.borderWidth = 0.0
        view.layer?.borderColor = NSColor(calibratedRed: 0.0, green: 0.5, blue: 1.0, alpha: 1.0).cgColor // Aqua

        self.btnLook.image = NSImage(named: NSImage.Name.quickLookTemplate)
        self.btnCaution.isHidden = true
    }
    
    func reloadFromDatabase(){
        if let oldImage = self.imageFile?.imageData  {
            if let image = ModelStore.default.getImage(path: oldImage.path) {
                self.imageFile = ImageFile(photoFile: image)
            }
        }
    }
    
    fileprivate func renderControls(_ imageFile:ImageFile) {
        DispatchQueue.main.async {
            self.imageView?.image = imageFile.thumbnail
        }
        if imageFile.photoTakenDate() != nil {
            textField?.stringValue = imageFile.dateString(imageFile.photoTakenDate(), format: displayDateFormat)
        }else {
            textField?.stringValue = imageFile.fileName
        }
        if let image = imageFile.imageData {
            if image.shortDescription != nil && image.shortDescription != "" {
                lblPlace.stringValue = image.shortDescription ?? imageFile.place
            }else{
                lblPlace.stringValue = imageFile.place
            }
        }else{
            lblPlace.stringValue = imageFile.place
        }
        
        checkBox.state = NSButton.StateValue.off
        
        if imageFile.isHidden {
            self.btnLook.image = NSImage(named: NSImage.Name.stopProgressTemplate)
            self.btnLook.toolTip = "Hidden"
        }else {
            self.btnLook.image = NSImage(named: NSImage.Name.quickLookTemplate)
            self.btnLook.toolTip = "Visible"
        }
        
        if !self.isControlsHidden {
            btnCaution.isHidden = !imageFile.hasDuplicates
        }
        btnCaution.toolTip = imageFile.hasDuplicates ? "duplicates" : ""
        
    }
  
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 5.0 : 0.0
    }
    
    func check(checkBySection:Bool = false){
        checkBox.state = NSButton.StateValue.on
        if checkBoxDelegate != nil {
            checkBoxDelegate?.onCollectionViewItemCheck(self, checkBySection: checkBySection)
        }
    }
    
    func uncheck(checkBySection:Bool = false){
        checkBox.state = NSButton.StateValue.off
        if checkBoxDelegate != nil {
            checkBoxDelegate?.onCollectionViewItemUncheck(self, checkBySection: checkBySection)
        }
    }
    
    func isChecked() -> Bool {
        if checkBox.state == NSButton.StateValue.on {
            return true
        }else {
            return false
        }
    }
    
    @IBAction func onCheckBoxClicked(_ sender: NSButton) {
        if isChecked() {
            if checkBoxDelegate != nil {
                checkBoxDelegate?.onCollectionViewItemCheck(self, checkBySection: false)
            }
        }else{
            if checkBoxDelegate != nil {
                checkBoxDelegate?.onCollectionViewItemUncheck(self, checkBySection: false)
            }
        }
    }
    
    var mouseLocation:NSPoint? = nil
    
    @IBAction func onPopUpButtonClicked(_ sender: NSPopUpButton) {
        
        self.mouseLocation = NSEvent.mouseLocation
        let i = sender.indexOfSelectedItem
        if i == 1 {
            self.revealInFinder()
        }else if i == 3 {
            self.previewEditableVersion()
        }else if i == 4 {
            self.previewBackupVersion()
        }else if i == 5 {
            self.quicklook()
        }else if i == 7 {
            self.findFaces()
        }else if i == 8 {
            self.recognizeFaces()
        }else if i == 9 {
            // TODO: REPLACE WITH BACKUP VERSION
            // copy physical file
        }
    }
    
    @IBAction func onButtonLookClicked(_ sender: Any) {
        if let image = self.imageFile {
            if image.isHidden {
                image.show()
                self.btnLook.image = NSImage(named: NSImage.Name.quickLookTemplate)
                self.btnLook.toolTip = "Visible"
            }else {
                image.hide()
                self.btnLook.image = NSImage(named: NSImage.Name.stopProgressTemplate)
                self.btnLook.toolTip = "Hidden"
            }
            //ModelStore.save()
        }
    }
    
    @IBAction func onDuplicatesClicked(_ sender: NSButton) {
        if let imageFile = self.imageFile {
            if self.showDuplicatesDelegate != nil {
                self.showDuplicatesDelegate?.onCollectionViewItemShowDuplicate(imageFile.duplicatesKey)
            }
        }
    }
    
    
    fileprivate func revealInFinder(){
        if let url = self.imageFile?.url {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
    
    fileprivate func quicklook(){
        if let imageFile = self.imageFile, let url = self.imageFile?.url, FileManager.default.fileExists(atPath: url.path) {
            if self.quickLookDelegate != nil {
                self.quickLookDelegate?.onCollectionViewItemQuickLook(imageFile)
            }
        }
    }
    
    fileprivate func previewEditableVersion() {
        if let imageFile = self.imageFile, let url = self.imageFile?.url, FileManager.default.fileExists(atPath: url.path) {
            if self.previewDelegate != nil {
                self.previewDelegate?.onCollectionViewItemPreview(url: url, isPhoto: imageFile.isPhoto)
                self.previewMessageDelegate?.onCollectionViewItemPreviewMessage(description: "EDITABLE VERSION PREVIEW")
            }
        }else{
            self.previewMessageDelegate?.onCollectionViewItemPreviewMessage(description: "EDITABLE VERSION DOES NOT EXIST")
        }
    }
    
    fileprivate func previewBackupVersion() {
        if let imageFile = self.imageFile, let url = self.imageFile?.backupUrl, FileManager.default.fileExists(atPath: url.path) {
            if self.previewDelegate != nil {
                self.previewDelegate?.onCollectionViewItemPreview(url: url, isPhoto: imageFile.isPhoto)
                self.previewMessageDelegate?.onCollectionViewItemPreviewMessage(description: "BACKUP VERSION PREVIEW")
            }
        }else{
            self.previewMessageDelegate?.onCollectionViewItemPreviewMessage(description: "BACKUP VERSION DOES NOT EXIST")
        }
    }
    
    fileprivate func findFaces() {
        if let _ = self.imageFile, let url = self.imageFile?.url {
            DispatchQueue.global().async {
                FaceTask.default.findFaces(path: url.path)
            }
            
        }else{
            print("ERROR: Image object is null or file doesn't exist.")
            return
        }
    }
    
    func recognizeFaces() {
        if let _ = self.imageFile, let url = self.imageFile?.url {
            DispatchQueue.global().async {
                FaceTask.default.recognizeFaces(path: url.path)
            }
        }else{
            print("ERROR: Image object is null or file doesn't exist.")
            return
        }
    }
    
}

extension CollectionViewItem : NSPopoverDelegate {
    
}
