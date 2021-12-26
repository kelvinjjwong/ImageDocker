//
//  ViewController+Search.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    func configureMainSearchBar() {
        self.txtSearch.convertToACBTokenField()
        self.txtSearch.shouldEnableTokenMenu = true
        self.txtSearch.shouldDisplaySearchIcon = true
        self.txtSearch.shouldEnableTokenMenu = true
        self.txtSearch.tokenDelegate = self
        self.txtSearch.isEnabled = true
        self.txtSearch.tokenSeparator = "||"
        self.txtSearch.target = self
        self.txtSearch.action = #selector(processMainSearch)
    }
    
    @objc func processMainSearch() {
//        self.logger.log("======== process main search === \(self.txtSearch.tokenStringValue)")
        let keywords = self.txtSearch.tokenStringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if keywords != "" {
            let conditions = SearchCondition.get(from: keywords, includeHidden: (self.chbShowHidden.state == .on))
            
            loadCollection {
                self.imagesLoader.search(
                    conditions: conditions,
                    indicator: self.collectionLoadingIndicator,
                    pageSize: 200, pageNumber: 1)
            }
        }else{
            self.imagesLoader.clean()
            collectionView.reloadData()
            self.imagesLoader.clearSearch(pageSize: 200, pageNumber: 1)
            DispatchQueue.global().async {
                self.imagesLoader.reload()
                self.refreshCollectionView()
                self.runningSearch = false
            }
        }
    }
    
    internal func search(_ keyword:String) {
        guard !runningSearch else {
            return
        }
        runningSearch = true
        if keyword != "" {
            let condition = SearchCondition.get(from: keyword)
            
            loadCollection {
                self.imagesLoader.search(
                    conditions: condition,
                    indicator: self.collectionLoadingIndicator,
                    pageSize: 200, pageNumber: 1)
            }
        }else{
            self.imagesLoader.clean()
            collectionView.reloadData()
            self.imagesLoader.clearSearch(pageSize: 200, pageNumber: 1)
            DispatchQueue.global().async {
                self.imagesLoader.reload()
                self.refreshCollectionView()
                self.runningSearch = false
            }
        }
    }
}

// shared among all token fields who set delegate to viewController
extension ViewController: NSTokenFieldDelegate {

    public func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        
        return SearchCondition.createTokenFieldCompletionMenu(for: substring, separator: " | ")
    }
    
    public func tokenField(_ tokenField: NSTokenField, menuForRepresentedObject representedObject: Any) -> NSMenu? {
//        self.logger.log(representedObject)
        if let token = representedObject as? ACBToken {
            var substring = token.name
            if substring.contains("|") {
                let components = substring.components(separatedBy: "|")
                substring = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            let nameList = SearchCondition.createTokenFieldCompletionMenu(for: substring, separator: " | ")
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
        if let fieldEditor = txtSearch?.currentEditor() {
            let textRange = fieldEditor.selectedRange
            let replaceString = menuItem.title
            fieldEditor.replaceCharacters(in: textRange, with: replaceString)
            fieldEditor.selectedRange = NSMakeRange(textRange.location, replaceString.count)
            txtSearch?.window?.makeFirstResponder(nil)
            
        }
    }
    
    public func tokenField(_ tokenField: NSTokenField, styleForRepresentedObject representedObject: Any) -> NSTokenField.TokenStyle {
        
        return .rounded
    }

    public func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
        return true
    }
}
