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
    
    private var checkBoxDelegate:CollectionViewItemCheckDelegate?
    
    var sectionIndex:Int?
    
    func setCheckBoxDelegate(_ delegate:CollectionViewItemCheckDelegate){
        self.checkBoxDelegate = delegate
    }
    
    var displayDateFormat:String = "HH:mm:ss"
    
    var imageFile: ImageFile? {
    didSet {
      guard isViewLoaded else { return }
      if let imageFile = imageFile {
        DispatchQueue.main.async {
            self.imageView?.image = imageFile.thumbnail
        }
        if imageFile.photoTakenDate() != nil {
            textField?.stringValue = imageFile.dateString(imageFile.photoTakenDate(), format: displayDateFormat)
        }else {
            textField?.stringValue = imageFile.fileName
        }
        lblPlace.stringValue = imageFile.place
        
        checkBox.state = NSButton.StateValue.off
        
      } else {
        imageView?.image = nil
        textField?.stringValue = ""
        lblPlace.stringValue = ""
        checkBox.state = NSButton.StateValue.off
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.darkGray.cgColor
    view.layer?.borderWidth = 0.0
    view.layer?.borderColor = NSColor(calibratedRed: 0.0, green: 0.5, blue: 1.0, alpha: 1.0).cgColor // Aqua
  }
  
  func setHighlight(selected: Bool) {
    view.layer?.borderWidth = selected ? 5.0 : 0.0
    /*
    if selected {
        if !self.isChecked() {
            self.check()
        }else {
            self.uncheck()
        }
    }
 */
    
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
    @IBAction func onOpenFinderClicked(_ sender: Any) {
        if self.imageFile != nil && self.imageFile?.url != nil {
            NSWorkspace.shared.activateFileViewerSelecting([imageFile?.url as! URL])
        }
    }
    
}
