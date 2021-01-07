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
        print("======== process main search === \(self.txtSearch.tokenStringValue)")
    }
    
    internal func search(_ keyword:String) {
        guard !runningSearch else {
            return
        }
        runningSearch = true
        if keyword != "" {
            let condition = SearchCondition.get(from: keyword)
            
            TaskManager.loadingImagesCollection = true
            
            self.imagesLoader.clean()
            collectionView.reloadData()
            
            self.imagesLoader.showHidden = self.chbShowHidden.state == .on
            
            DispatchQueue.global().async {
                self.collectionLoadingIndicator = Accumulator(target: 100, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: {data in
                    TaskManager.loadingImagesCollection = false
                    //                let total:Int = data["total"] ?? 0
                    //                let hidden:Int = data["hidden"] ?? 0
                    //                let message:String = "\(total) images, \(hidden) hidden"
                    //                self.indicatorMessage.stringValue = message
                })
                if self.imagesLoader.isLoading() {
                    DispatchQueue.main.async {
                        self.indicatorMessage.stringValue = "Cancelling last request ..."
                    }
                    self.imagesLoader.cancel(onCancelled: {
                        self.imagesLoader.search(conditions: condition, indicator: self.collectionLoadingIndicator, pageSize: 200, pageNumber: 1)
                        self.refreshCollectionView()
                        TaskManager.loadingImagesCollection = false
                    })
                }else{
                    self.imagesLoader.search(conditions: condition, indicator: self.collectionLoadingIndicator, pageSize: 200, pageNumber: 1)
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                }
                self.runningSearch = false
                
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
    
    private func createTokenFieldCompletionMenu(for text:String) -> [String] {
        if let number = Int(text) {
            if number >= 1950 && number <= 10000 {
                return [
                    "\(text) | Year",
                    "\(text) | Event",
                    "\(text) | Place"
                ]
            }else if number > 0 && number <= 12 {
                return [
                    "\(text) | Month",
                    "\(text) | Day",
                    "\(text) | Event",
                    "\(text) | Place"
                ]
            }else if number > 0 && number <= 31 {
                return [
                    "\(text) | Day",
                    "\(text) | Event",
                    "\(text) | Place"
                ]
            }
        }
        return [
            "\(text) | Event",
            "\(text) | Place",
            "\(text) | Camera",
        ]
    }

    public func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        
        return self.createTokenFieldCompletionMenu(for: substring)
    }
    
    public func tokenField(_ tokenField: NSTokenField, menuForRepresentedObject representedObject: Any) -> NSMenu? {
        print(representedObject)
        if let token = representedObject as? ACBToken {
            var substring = token.name
            if substring.contains("|") {
                let components = substring.components(separatedBy: "|")
                substring = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            let nameList = self.createTokenFieldCompletionMenu(for: substring)
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
