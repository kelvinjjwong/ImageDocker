//
//  HeaderView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/20.
//  Copyright © 2018年 razeware. All rights reserved.
//

import Cocoa

class HeaderView: NSView, NSCollectionViewElement {

    @IBOutlet weak var sectionTitle: NSTextField!
    @IBOutlet weak var imageCount: NSTextField!
    @IBOutlet weak var checkBox: NSButton!
    
    @IBOutlet weak var iconPlace: NSImageView!
    @IBOutlet weak var iconPeople: NSImageView!
    @IBOutlet weak var lblPlace: NSTextField!
    @IBOutlet weak var lblPeople: NSTextField!
    
    @IBOutlet weak var iconSummary: NSImageView!
    @IBOutlet weak var lblSummary: NSTextField!
    
    var title = ""
    var place = ""
    var peopleGroups = ""
    
    var sectionIndex:Int?
    
    private var checkBoxDelegate:CollectionViewHeaderCheckDelegate?
    
    func setCheckBoxDelegate(_ delegate:CollectionViewHeaderCheckDelegate){
        self.checkBoxDelegate = delegate
    }
  
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
//        NSColor(calibratedWhite: 0.1, alpha: 0.8).set()
        
//        __NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.sourceOver)
    }
    
    
    
    func check(ignoreDelegate:Bool = false){
        checkBox.state = .on
        if checkBoxDelegate != nil && !ignoreDelegate {
            checkBoxDelegate?.onCollectionViewHeaderCheck(self)
        }
    }
    
    func uncheck(ignoreDelegate:Bool = false){
        checkBox.state = .off
        if checkBoxDelegate != nil && !ignoreDelegate {
            checkBoxDelegate?.onCollectionViewHeaderUncheck(self)
        }
    }
    
    func isChecked() -> Bool {
        return checkBox.state == .on
    }
    
    @IBAction func onCheckBoxClicked(_ sender: NSButton) {
        if isChecked() {
            checkBoxDelegate?.onCollectionViewHeaderCheck(self)
        }else{
            checkBoxDelegate?.onCollectionViewHeaderUncheck(self)
        }
    }
}
