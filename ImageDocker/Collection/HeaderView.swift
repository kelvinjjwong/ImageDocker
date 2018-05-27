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
    
    var sectionIndex:Int?
    
    private var checkBoxDelegate:CollectionViewHeaderCheckDelegate?
    
    func setCheckBoxDelegate(_ delegate:CollectionViewHeaderCheckDelegate){
        self.checkBoxDelegate = delegate
    }
  
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor(calibratedWhite: 0.1, alpha: 0.8).set()
        __NSRectFillUsingOperation(dirtyRect, NSCompositingOperation.sourceOver)
    }
    
    
    
    func check(_ ignoreDelegate:Bool = false){
        checkBox.state = NSButton.StateValue.on
        if checkBoxDelegate != nil && !ignoreDelegate {
            checkBoxDelegate?.onCollectionViewHeaderCheck(self)
        }
    }
    
    func uncheck(_ ignoreDelegate:Bool = false){
        checkBox.state = NSButton.StateValue.off
        if checkBoxDelegate != nil && !ignoreDelegate {
            checkBoxDelegate?.onCollectionViewHeaderUncheck(self)
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
                checkBoxDelegate?.onCollectionViewHeaderCheck(self)
            }
        }else{
            if checkBoxDelegate != nil {
                checkBoxDelegate?.onCollectionViewHeaderUncheck(self)
            }
        }
    }
}
