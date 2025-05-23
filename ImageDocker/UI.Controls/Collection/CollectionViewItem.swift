//
//  CollectionViewItem.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//


import Cocoa
import LoggerFactory

class CollectionViewItem: NSCollectionViewItem {
    
    let logger = LoggerFactory.get(category: "CollectionViewItem")
  
    @IBOutlet weak var checkBox: NSButton!
    @IBOutlet weak var lblPlace: NSTextField!
    @IBOutlet weak var btnLook: NSButton!
//    @IBOutlet weak var btnCaution: NSButton!
    @IBOutlet weak var btnMenu: NSPopUpButton!
    @IBOutlet weak var moreMenu: NSMenu!
    @IBOutlet weak var colorLine: NSTextField!
    @IBOutlet weak var imgSourceTag: NSImageView!
    
    
    private var checkBoxDelegate:CollectionViewItemCheckDelegate?
    private var showDuplicatesDelegate:CollectionViewItemShowDuplicatesDelegate?
    private var quickLookDelegate:CollectionViewItemQuickLookDelegate?
    private var previewDelegate:CollectionViewItemPreviewDelegate?
    private var previewMessageDelegate:CollectionViewItemPreviewMessageDelegate?
    
    var onSelected:(() -> Void)? = nil
    var onUnselected:(() -> Void)? = nil
    
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
                imageFile.tagging()
                self.renderControls(imageFile)
            } else {
                imageView?.image = nil
                textField?.stringValue = ""
                lblPlace.stringValue = ""
                checkBox.state = NSButton.StateValue.off
//                btnCaution.isHidden = true
                self.disableMenu(at: 3)
            }
        }
    }
    
    var backgroundColor:NSColor?
    
    private var isControlsHidden = false
    
    func hideControls() {
        self.btnLook.isHidden = true
//        self.btnCaution.isHidden = true
        self.checkBox.isHidden = true
        self.btnMenu.isHidden = true
        self.isControlsHidden = true
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = (backgroundColor ?? Colors.DeepDarkGray).cgColor
        view.layer?.borderWidth = 0.0
        view.layer?.borderColor = NSColor(calibratedRed: 0.0, green: 0.5, blue: 1.0, alpha: 1.0).cgColor // Aqua

        self.btnLook.image = NSImage(named: NSImage.quickLookTemplateName)
//        self.btnCaution.isHidden = true
        self.disableMenu(at: 3)
    }
    
    func reloadFromDatabase(){
        CachePrefetch.default.refresh()
        if let oldImage = self.imageFile?.imageData, let imageId = oldImage.id  {
            if let image = ImageRecordDao.default.getImage(id: imageId) {
                self.imageFile = ImageFile(image: image)
            }
        }
    }
    
    func reRenderItem() {
        if let imageFile = self.imageFile {
            self.renderControls(imageFile)
        }
    }
    
    fileprivate func renderControls(_ imageFile:ImageFile) {
        DispatchQueue.main.async {
            self.setupMenu()
            var degree = 0
            if let imageData = imageFile.imageData, let rotationDegree = imageData.rotation {
                degree = rotationDegree
//                if imageFile.isVideo {
//                    self.logger.log(.trace, "video:\(imageFile.url) | rotate:\(rotationDegree)")
//                    degree = rotationDegree + -90
//                }
            }
            if let thumbnail = imageFile.thumbnail {
                if degree != 0 {
//                    if imageFile.isPhoto {
                        self.logger.log(.trace, "[renderControls] thumbnail rotate to \(degree) degree for \(imageFile.url)")
                        self.imageView?.image = thumbnail.rotate(degrees: CGFloat(degree))
//                    }else{
//                        self.imageView?.image = thumbnail
//                    }
                }else{
                    self.imageView?.image = thumbnail
                }
            }
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
            
            self.imgSourceTag.isHidden = true
            let tags = (image.tagx ?? "").removeLastBracket().removeFirstBracket().components(separatedBy: ",")
            if tags.contains(Words.tag_image_is_screen_shot.word()) {
                self.imgSourceTag.isHidden = false
                self.imgSourceTag.image = Icons.screenshot
                self.imgSourceTag.toolTip = Words.tag_image_is_screen_shot.word()
            }else if tags.contains(Words.tag_image_is_wechat_image.word()) {
                self.imgSourceTag.isHidden = false
                self.imgSourceTag.image = Icons.wechat
                self.imgSourceTag.toolTip = Words.tag_image_is_wechat_image.word()
            }else if tags.contains(Words.tag_image_is_qq_image.word()) {
                self.imgSourceTag.isHidden = false
                self.imgSourceTag.image = Icons.qq
                self.imgSourceTag.toolTip = Words.tag_image_is_qq_image.word()
            }else if tags.contains(Words.tag_image_is_app_edited_image.word()) {
                self.imgSourceTag.isHidden = false
                self.imgSourceTag.image = Icons.ps
                self.imgSourceTag.toolTip = Words.tag_image_is_app_edited_image.word()
            }
        }else{
            lblPlace.stringValue = imageFile.place
        }
        
        
        if imageFile.isHidden {
            self.btnLook.image = NSImage(named: NSImage.stopProgressTemplateName)
//            self.btnLook.toolTip = "Hidden"
        }else {
            self.btnLook.image = NSImage(named: NSImage.quickLookTemplateName)
//            self.btnLook.toolTip = "Visible"
        }
        
//        if !self.isControlsHidden {
//            btnCaution.isHidden = !imageFile.hasDuplicates
//        }
        if imageFile.hasDuplicates {
            self.enableMenu(at: 3)
        }else{
            self.disableMenu(at: 3)
        }
//        btnCaution.toolTip = imageFile.hasDuplicates ? "duplicates" : ""
        
        checkBox.state = imageFile.isChecked ? .on : .off // should base on ImageFile.checked state
        
        self.colorLine.drawsBackground = true
        self.colorLine.backgroundColor = NSColor(hex: imageFile.repositoryColor)
    }
  
    func setHighlight(selected: Bool, isMultipleSelection:Bool = false) {
        view.layer?.borderWidth = selected ? 5.0 : 0.0
        
        if selected {
            if isMultipleSelection {
                self.check()
            }
            onSelected?()
        }else{
            onUnselected?()
        }
    }
    
    func check(checkBySection:Bool = false){
        self.checkBox.state = .on
        self.checkBoxDelegate?.onCollectionViewItemCheck(self, checkBySection: checkBySection)
    }
    
    func uncheck(checkBySection:Bool = false){
        self.checkBox.state = .off
        self.checkBoxDelegate?.onCollectionViewItemUncheck(self, checkBySection: checkBySection)
    }
    
    func isChecked() -> Bool {
        if checkBox.state == .on {
            return true
        }else {
            return false
        }
    }
    
    @IBAction func onCheckBoxClicked(_ sender: NSButton) {
        if isChecked() {
            self.imageFile?.check()
            if checkBoxDelegate != nil {
                checkBoxDelegate?.onCollectionViewItemCheck(self, checkBySection: false)
            }
        }else{
            self.imageFile?.uncheck()
            if checkBoxDelegate != nil {
                checkBoxDelegate?.onCollectionViewItemUncheck(self, checkBySection: false)
            }
        }
    }
    
    var mouseLocation:NSPoint? = nil
    
    func setupMenu() {
        self.moreMenu.item(at: 1)?.title = Words.library_tree_reveal_in_finder.word()
        self.moreMenu.item(at: 3)?.title = Words.previewShowDuplicates.word()
        self.moreMenu.item(at: 5)?.title = Words.previewEditableVersion.word()
        self.moreMenu.item(at: 6)?.title = Words.previewBackupVersion.word()
        self.moreMenu.item(at: 7)?.title = Words.largeView.word()
        self.moreMenu.item(at: 9)?.title = Words.replaceImageWithBackupVersion.word()
        
        self.disableMenu(at: 3)
    }
    
    func enableMenu(at index:Int) {
        self.moreMenu.item(at: index)?.isEnabled = true
    }
    
    func disableMenu(at index:Int) {
        self.moreMenu.item(at: index)?.isEnabled = false
    }
    
    @IBAction func onPopUpButtonClicked(_ sender: NSPopUpButton) {
        
        self.mouseLocation = NSEvent.mouseLocation
        let i = sender.indexOfSelectedItem
        if i == 1 {
            self.revealInFinder()
        }else if i == 3 {
            if let imageFile = self.imageFile {
                if self.showDuplicatesDelegate != nil {
                    self.showDuplicatesDelegate?.onCollectionViewItemShowDuplicate(imageFile.duplicatesKey)
                }
            }
        }else if i == 5 {
            self.previewEditableVersion()
        }else if i == 6 {
            self.previewBackupVersion()
        }else if i == 7 {
            self.quicklook()
        }else if i == 9 {
            self.restoreBackupImage()
        }
    }
    
    @IBAction func onButtonLookClicked(_ sender: Any) {
        if let image = self.imageFile {
            if image.isHidden {
                image.show()
                self.btnLook.image = NSImage(named: NSImage.quickLookTemplateName)
                self.btnLook.toolTip = "Visible"
            }else {
                image.hide()
                self.btnLook.image = NSImage(named: NSImage.stopProgressTemplateName)
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
                self.previewDelegate?.onCollectionViewItemPreview(imageFile: imageFile, isRawVersion: false)
            }
        }else{
            self.previewMessageDelegate?.onCollectionViewItemPreviewMessage(description: "Selected image's editable version does not exist")
        }
    }
    
    fileprivate func previewBackupVersion() {
        if let imageFile = self.imageFile, let url = self.imageFile?.backupUrl, FileManager.default.fileExists(atPath: url.path) {
            if self.previewDelegate != nil {
                self.previewDelegate?.onCollectionViewItemPreview(imageFile: imageFile, isRawVersion: true)
            }
        }else{
            self.previewMessageDelegate?.onCollectionViewItemPreviewMessage(description: "Selected image's backup version does not exist")
        }
    }
    
    fileprivate func restoreBackupImage() {
        DispatchQueue.global().async {
            if let imageFile = self.imageFile, let url = self.imageFile?.url, FileManager.default.fileExists(atPath: url.path) {
                if let backupUrl = self.imageFile?.backupUrl, FileManager.default.fileExists(atPath: backupUrl.path) {
                    
                    let uuid = UUID().uuidString
                    let filename = imageFile.fileName
                    let tmpFolder = "/tmp/\(uuid)"
                    let tmpPath = "\(tmpFolder)/\(filename)"
                    do {
                        self.logger.log(.trace, "Restoring backup image from [\(backupUrl.path)] to [url.path]")
                        try FileManager.default.createDirectory(atPath: tmpFolder, withIntermediateDirectories: true, attributes: nil)
                        try FileManager.default.moveItem(atPath: url.path, toPath: tmpPath)
                        try FileManager.default.copyItem(atPath: backupUrl.path, toPath: url.path)
                        self.previewMessageDelegate?.onCollectionViewItemPreviewMessage(description: "Done replace selected image with backup version")
                    }catch{
                        self.logger.log(.error, "Unable to restore backup image from [\(backupUrl.path)] to [url.path]")
                        self.logger.log(.error, error)
                        self.previewMessageDelegate?.onCollectionViewItemPreviewMessage(description: "Failed to replace selected image with backup version.")
                        self.logger.log(.trace, "Restoring original editable version from \(tmpPath)")
                        do {
                            try FileManager.default.removeItem(atPath: url.path)
                            try FileManager.default.moveItem(atPath: tmpPath, toPath: url.path)
                        }catch{
                            self.logger.log(.error, "Unable to restore original editable version from [\(tmpPath)] to [\(url.path)]")
                            self.logger.log(.error, error)
                        }
                    }
                    do {
                        try FileManager.default.removeItem(atPath: tmpPath)
                        try FileManager.default.removeItem(atPath: tmpFolder)
                    }catch{
                        self.logger.log(.error, error)
                    }
                }else{
                    self.previewMessageDelegate?.onCollectionViewItemPreviewMessage(description: "Selected image's backup version does not exist")
                }
            }else{
                self.previewMessageDelegate?.onCollectionViewItemPreviewMessage(description: "Selected image's editable version does not exist")
            }
        }
    }
    
//    fileprivate func findFaces() {
//        if let _ = self.imageFile, let url = self.imageFile?.url {
//            DispatchQueue.global().async {
//                let _ = FaceTask.default.findFaces(path: url.path)
//            }
//
//        }else{
//            self.logger.log(.trace, "ERROR: Image object is null or file doesn't exist.")
//            return
//        }
//    }
//
//    func recognizeFaces() {
//        if let _ = self.imageFile, let url = self.imageFile?.url {
//            DispatchQueue.global().async {
//                let _ = FaceTask.default.recognizeFaces(path: url.path)
//            }
//        }else{
//            self.logger.log(.trace, "ERROR: Image object is null or file doesn't exist.")
//            return
//        }
//    }
    
}

extension CollectionViewItem : NSPopoverDelegate {
    
}
