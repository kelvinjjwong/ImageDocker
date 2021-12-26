//
//  HeaderViewController.swift
//  TreeView
//
//  Created by Kelvin Wong on 2019/12/14.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

class StackHeaderViewController : NSViewController, StackItemHeader {
    
    let logger = ConsoleLogger(category: "StackHeaderViewController")
    
    @IBOutlet weak var headerTextField: NSTextField!
    @IBOutlet weak var showHideButton: NSButton!
    @IBOutlet weak var searchField: NSTokenField!
    @IBOutlet weak var btnMore: NSButton!
    
    var disclose: (() -> ())? // This state will be set by the item view controller.
    
    var beforeExpand: (() -> ())? // optional extendable method
    
    var afterExpand: (() -> ())? // optional extendable method
    
    var gotoAction: ((String) -> ())? // optional extendable method
    
    var filterAction: (() -> ())? // optional extendable method
    
    var moreAction: ((NSButton) -> ())? // optional extendable method
    
    var searchCondition: String {
        get {
            return searchField.tokenStringValue
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        headerTextField.stringValue = title!
        
        // We want the header's color to be different color than its associated stack item.
        view.wantsLayer = true
        view.layer?.backgroundColor = Colors.DarkGray.cgColor // NSColor.windowBackgroundColor.cgColor
        
        self.configureSearchBar()
        
        if self.moreAction == nil {
            self.btnMore.isHidden = true
        }else{
            self.btnMore.isHidden = false
        }
        
        if self.filterAction == nil {
            self.searchField.isHidden = true
        }else{
            self.searchField.isHidden = false
        }
    }
    
    func configureSearchBar() {
        self.searchField.convertToACBTokenField()
        self.searchField.shouldEnableTokenMenu = true
        self.searchField.shouldDisplaySearchIcon = true
        self.searchField.shouldEnableTokenMenu = true
        self.searchField.tokenDelegate = self
        self.searchField.isEnabled = true
        self.searchField.tokenSeparator = "||"
        self.searchField.target = self
        self.searchField.action = #selector(processSearch)
    }
    
    @objc func processSearch() {
        self.logger.log("===== TREE search: \(self.searchField.tokenStringValue)")
        if self.filterAction != nil {
            self.filterAction!()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showHidePressed(_ sender: AnyObject) {
        
        disclose?()
    }
    
    @IBAction func onMoreClicked(_ sender: NSButton) {
        moreAction?(sender)
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

extension StackHeaderViewController : NSTokenFieldDelegate {

    public func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        
        return SearchCondition.createTokenFieldCompletionMenu(for: substring, separator: "|")
    }
    
    public func tokenField(_ tokenField: NSTokenField, menuForRepresentedObject representedObject: Any) -> NSMenu? {
        self.logger.log(representedObject)
        if let token = representedObject as? ACBToken {
            var substring = token.name
            if substring.contains("|") {
                let components = substring.components(separatedBy: "|")
                substring = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            let nameList = SearchCondition.createTokenFieldCompletionMenu(for: substring, separator: "|")
            let menu = NSMenu()
            nameList.forEach {
                menu.addItem(withTitle: $0,
                             action: #selector(tokenFieldMenuItemTapped(_:)),
                             keyEquivalent: "").target = self
            }
            return menu
        }
        return nil
    }
    
    @objc private func tokenFieldMenuItemTapped(_ menuItem: NSMenuItem) {
        if let fieldEditor = searchField.currentEditor() {
            let textRange = fieldEditor.selectedRange
            let replaceString = menuItem.title
            fieldEditor.replaceCharacters(in: textRange, with: replaceString)
            fieldEditor.selectedRange = NSMakeRange(textRange.location, replaceString.count)
            searchField.window?.makeFirstResponder(nil)
            
        }
    }
    
    public func tokenField(_ tokenField: NSTokenField, styleForRepresentedObject representedObject: Any) -> NSTokenField.TokenStyle {
        
        return .rounded
    }

    public func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
        return true
    }
}

