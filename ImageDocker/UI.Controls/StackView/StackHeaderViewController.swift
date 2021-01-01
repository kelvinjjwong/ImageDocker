//
//  HeaderViewController.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/12/14.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class StackHeaderViewController : NSViewController, StackItemHeader {
    
    @IBOutlet weak var headerTextField: NSTextField!
    @IBOutlet weak var showHideButton: NSButton!
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var btnGoto: NSButton!
    @IBOutlet weak var btnFilter: NSButton!
    @IBOutlet weak var btnMore: NSButton!
    
    var disclose: (() -> ())? // This state will be set by the item view controller.
    
    var beforeExpand: (() -> ())? // optional extendable method
    
    var afterExpand: (() -> ())? // optional extendable method
    
    var gotoAction: ((String) -> ())? // optional extendable method
    
    var filterAction: ((String) -> ())? // optional extendable method
    
    var moreAction: ((NSButton) -> ())? // optional extendable method
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        headerTextField.stringValue = title!
        
        // We want the header's color to be different color than its associated stack item.
        view.wantsLayer = true
        view.layer?.backgroundColor = Colors.DarkGray.cgColor // NSColor.windowBackgroundColor.cgColor
        
        if self.moreAction == nil {
            self.btnMore.isHidden = true
        }else{
            self.btnMore.isHidden = false
        }
        
        if self.filterAction == nil {
            self.searchField.isHidden = true
            self.btnGoto.isHidden = true
            self.btnFilter.isHidden = true
        }else{
            self.searchField.isHidden = false
            self.btnGoto.isHidden = false
            self.btnFilter.isHidden = false
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showHidePressed(_ sender: AnyObject) {
        
        disclose?()
    }
    
    @IBAction func onGotoClicked(_ sender: NSButton) {
        let text = self.searchField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        gotoAction?(text)
    }
    
    @IBAction func onFilterClicked(_ sender: NSButton) {
        let text = self.searchField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        print("filter button clicked with \(text)")
        if text != "" {
            filterAction?(text)
        }
    }
    
    @IBAction func onMoreClicked(_ sender: NSButton) {
        moreAction?(sender)
    }
    
    @IBAction func onSearchAction(_ sender: NSSearchField) {
        let text = self.searchField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        print("filter button clicked with \(text)")
        if text != "" {
            filterAction?(text)
        }
    }
    
    // MARK: - StackItemHeader Procotol
    
    func update(toDisclosureState: StackItemContainer.DisclosureState) {
        
        switch toDisclosureState {
        case .open:
            showHideButton.state = .on
        case .closed:
            showHideButton.state = .off
        }
        
        // Save the disclosure state to user defaults for next launch.
        UserDefaults().set(toDisclosureState.rawValue, forKey: headerTextField.stringValue)
    }
    
    
    
}

