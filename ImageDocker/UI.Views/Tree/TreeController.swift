//
//  TreeListController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList
import GRDB


extension ViewController {
    
    // MARK: INIT
    
    func initTreeDataModel() {
        placesIcon.isTemplate = true
        peopleIcon.isTemplate = true
        eventsIcon.isTemplate = true
        photosIcon.isTemplate = true
        albumIcon.isTemplate = true
        phoneIcon.isTemplate = true
        
        self.sourceListItems = NSMutableArray(array:[])
        //self.modelObjects = NSMutableArray(array:[])
        
        if self.deviceSectionOfTree == nil {
            self.deviceSectionOfTree = self.addTreeSection(title: "DEVICES")
        }
        
        if self.momentSectionOfTree == nil {
            self.momentSectionOfTree = self.addTreeSection(title: "MOMENTS")
        }
        
        if self.eventSectionOfTree == nil {
            self.eventSectionOfTree = self.addTreeSection(title: "EVENTS")
        }
        
        if self.placeSectionOfTree == nil {
            self.placeSectionOfTree = self.addTreeSection(title: "PLACES")
        }
        
        self.addDeviceTypeTreeEntry(type: "Android")
        self.addDeviceTypeTreeEntry(type: "iPhone")
        
        if self.librarySectionOfTree == nil {
            self.librarySectionOfTree = self.addTreeSection(title: "LIBRARY")
        }
 
    }
    
    // MARK: SECTIONS
    
    func deviceItem() -> PXSourceListItem {
        return self.sourceListItems![0] as! PXSourceListItem
    }
    
    func momentItem() -> PXSourceListItem {
        return self.sourceListItems![1] as! PXSourceListItem
    }
    
    func eventItem() -> PXSourceListItem {
        return self.sourceListItems![2] as! PXSourceListItem
    }
    
    func placeItem() -> PXSourceListItem {
        return self.sourceListItems![3] as! PXSourceListItem
    }
    
    func libraryItem() -> PXSourceListItem {
        return self.sourceListItems![4] as! PXSourceListItem
    }
    
    func addTreeSection(title:String) -> PXSourceListItem {
        let item:PXSourceListItem = PXSourceListItem(title: title, identifier: "")
        self.sourceListItems?.add(item)
        self.identifiersOfLibraryTree[title] = item
        return item
    }
    
    // MARK: BEFORE and AFTER REFRESH
    
    func saveTreeItemsExpandState() {
        
        // save expandable state of all items, mark by moment.id
        for idItem in self.treeIdItems {
            DispatchQueue.main.async {
                let expanded = self.sourceList.isItemExpanded(idItem.value)
                self.treeIdItemsExpandState[idItem.key] = expanded
            }
            //if expanded {
            //    print("EXPANDED \(idItem.key)")
            //}
        }
    }
    
    func restoreTreeItemsExpandState() {
        // restore expanded state of expanded items, search by moment.id
        for parent in self.treeIdItemsExpandState.sorted(by: { $0.key.localizedCaseInsensitiveCompare($1.key) == ComparisonResult.orderedAscending }) {
            if parent.value {
                //print("EXPANDING \(parent.key)")
                let item = self.treeIdItems[parent.key]
                self.sourceList.expandItem(item)
            }
        }
    }
    
    func restoreTreeSelection(){
        guard self.treeLastSelectedIdentifier != "" && !treeRefreshing else {return}
        treeRefreshing = true
        // restore selection
        for idItem in self.treeIdItems {
            if idItem.key == self.treeLastSelectedIdentifier {
                //print("SELECT \(idItem.key)")
                let row = self.sourceList.row(forItem: idItem.value)
                self.sourceList.scrollRowToVisible(row)
                self.sourceList.selectRowIndexes(NSIndexSet(index: row) as IndexSet, byExtendingSelection: false)
                //self.sourceList.highlightSelection(inClipRect: self.sourceList.rect(ofRow: row))
                break
            }
        }
        treeRefreshing = false
    }
    
}

// MARK: VIEW and CLICK ACTION

extension ViewController : PXSourceListDelegate {
    
    func sourceList(_ sourceList: PXSourceList!, isGroupAlwaysExpanded group: Any!) -> Bool {
        return true
    }
    
    func sourceList(_ aSourceList:PXSourceList!, viewForItem item: Any!) -> NSView {
        var cellView: LCSourceListTableCellView? = nil
        var sectionCellView: LCSourceListHeaderView? = nil
        if let sourceListItem: PXSourceListItem = item as? PXSourceListItem {
            
            // SECTION
            if aSourceList.level(forItem: item) == 0 {
                sectionCellView = (aSourceList.makeView(withIdentifier: NSUserInterfaceItemIdentifier("HeaderCell"), owner: nil) as! LCSourceListHeaderView)
                
                if let cv = sectionCellView {
                    
                    if let textField = cv.textField {
                        textField.textColor = NSColor.white
                        textField.stringValue = sourceListItem.title ?? ""
                    }
                    if let title = sourceListItem.title {
                        
                        if title == "EVENTS" {
                            cv.buttonShouldShow = true
                            cv.btnMore.isHidden = false
                            cv.buttonAction = { sender in
                                DispatchQueue.main.async {
                                    self.refreshEventTree()
                                }
                            }
                        }else if title == "PLACES" {
                            cv.buttonShouldShow = true
                            cv.btnMore.isHidden = false
                            cv.buttonAction = { sender in
                                DispatchQueue.main.async {
                                    self.refreshLocationTree()
                                }
                            }
                        }else if title == "MOMENTS" {
                            cv.buttonShouldShow = true
                            cv.btnMore.isHidden = false
                            cv.buttonAction = { sender in
                                DispatchQueue.main.async {
                                    self.refreshMomentTree()
                                }
                            }
                        }else if title == "LIBRARY" {
                            cv.buttonShouldShow = true
                            cv.btnMore.isHidden = false

                            cv.buttonAction = { sender in
                                self.createLibrariesViewPopover()
                                
                                let cellRect = sender.bounds
                                self.librariesViewPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
                            }
                        }else{
                            cv.btnMore.isHidden = true
                            cv.buttonShouldShow = false
                        }
                    }
                    
                    return cv
                }
                
                return sectionCellView!
            }
            
            // ITEM
            cellView = (aSourceList.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DataCell"), owner: nil) as! LCSourceListTableCellView)
            
            if let cv = cellView {
                if let t:String = sourceListItem.title {
                    if let textField = cv.textField {
                        textField.stringValue = t
                    }
                    //print(t)
                }
                
                if let imageView = cv.imageView {
                    imageView.image = sourceListItem.icon
                }
                
                //print(sourceListItem.representedObject)
                
                if sourceListItem.representedObject == nil {
                    // section, do nothing
                    //print("COLLECTION IS NULL \(sourceListItem.title ?? "")")
                    
                    //if self.momentToCollection[sourceListItem.title] != nil {
                    //    let _ = self.momentToCollection[sourceListItem.title]!
                        //print("found collection: \(collection.title) \(collection.photoCount)")
                    //}
                }else{
                    let collection: PhotoCollection = sourceListItem.representedObject as! PhotoCollection
                    collection.treeNodeView = cv
                    
                    //print("COLLECTION: \(collection.title) , count: \(collection.photoCount)")
                    
                    let sourceTitle:String? = sourceListItem.title
                    let collectionTitle:String? = collection.title
                    
                    if let textField = cv.textField {
                    
                        if sourceTitle != nil && sourceTitle != "" {
                            textField.stringValue = sourceListItem.title
                        } else {
                            if collectionTitle != nil && collectionTitle != "" {
                                textField.stringValue = collection.title
                            }
                        }
                        if sourceTitle == nil && collectionTitle != nil {
                            textField.stringValue = collectionTitle!
                        }
                    }
                    if let badge = cv.badge {
                        badge.stringValue = " \(collection.photoCount) "
                        badge.isHidden = (collection.photoCount == 0)
                    }
                    
                    if collection.enableMoreButton {
                        cv.btnMore.isEnabled = true
                        cv.btnMore.isHidden = false
                        if let img = collection.imageOfMoreButton {
                            cv.btnMore.image = img
                        }
                        if collection.buttonAction != nil {
                            cv.buttonAction = collection.buttonAction
                        }
                        if collection.buttonMenu.count > 0 {
                            cv.buttonMenuItems = collection.buttonMenu
                        }
                        cv.buttonShouldShow = true
                    }else{
                        cv.btnMore.isHidden = true
                        cv.btnMore.isEnabled = false
                        cv.buttonShouldShow = false
                    }
                
                }
                return cv
            }
            return cellView!
        }else {
            return cellView!
        }
    }
    
    func sourceListSelectionDidChange(_ notification: Notification!) {
        guard !self.treeRefreshing else {
            //self.indicatorMessage.stringValue = "Updating tree, please wait for a while"
            return
        }
        //var removeButtonEnabled:Bool = false
        if let selectedItem:PXSourceListItem = self.sourceList.item(atRow: self.sourceList.selectedRow) as? PXSourceListItem {
            
            if let collection:PhotoCollection = selectedItem.representedObject as? PhotoCollection {
                
                if collection.source! == .library {
                    if PreferencesController.amountForPagination() > 0 && collection.photoCount > PreferencesController.amountForPagination() {
                        self.btnRefreshCollectionView.title = "Pages..."
                        if collection.url.path != "/" {
                            self.loadCollectionByContainer(name:collection.title, url:collection.url, pageSize: 200, pageNumber: 1, subdirectories: true)
                        }else{
                            print("WARN: collection url is null")
                        }
                    }else{
                        self.btnRefreshCollectionView.title = "Reload"
                        self.loadCollectionByContainer(name:collection.title, url:collection.url)
                        //self.loadCollectionByContainer(collection.imageFolder!)
                    }
                }else if collection.source! == .moment {
                    //print("selected moment \(collection.title)")
                    if PreferencesController.amountForPagination() > 0 && collection.photoCount > PreferencesController.amountForPagination() {
                        self.btnRefreshCollectionView.title = "Pages..."
                        self.selectMomentsTreeEntry(collection, pageSize: 200, pageNumber: 1)
                    }else{
                        self.btnRefreshCollectionView.title = "Reload"
                        self.selectMomentsTreeEntry(collection)
                    }
                }else if collection.source! == .place {
                    //print("selected place moment \(collection.title)")
                    if PreferencesController.amountForPagination() > 0 && collection.photoCount > PreferencesController.amountForPagination() {
                        self.btnRefreshCollectionView.title = "Pages..."
                        self.selectPlacesTreeEntry(collection, pageSize: 200, pageNumber: 1)
                    }else{
                        self.btnRefreshCollectionView.title = "Reload"
                        self.selectPlacesTreeEntry(collection)
                    }
                }else if collection.source! == .event {
                    //print("selected place moment \(collection.title)")
                    if PreferencesController.amountForPagination() > 0 && collection.photoCount > PreferencesController.amountForPagination() {
                        self.btnRefreshCollectionView.title = "Pages..."
                        self.selectEvent(collection, pageSize: 200, pageNumber: 1)
                    }else{
                        self.btnRefreshCollectionView.title = "Reload"
                        self.selectEvent(collection)
                    }
                }else if collection.source! == .device {
                    self.selectDeviceNode(collection)
                }
                
                self.treeLastSelectedIdentifier = collection.identifier
            }
        }
    }
    
}

// MARK: DATA SOURCE

extension ViewController : PXSourceListDataSource {
    func sourceList(_ sourceList: PXSourceList!, numberOfChildrenOfItem item: Any!) -> UInt {
        if item != nil {
            if let node = item as? PXSourceListItem {
                return UInt(node.children.count)
            }else {
                return UInt(self.sourceListItems!.count)
            }
        } else{
            // when just init sections
            return UInt(5)
        }
    }
    
    func sourceList(_ aSourceList: PXSourceList!, child index: UInt, ofItem item: Any!) -> Any! {
        if let node = item as? PXSourceListItem {
            //print("getting child of item \(node.title) \(index)/\(node.children.count)")
            return node.children[Int(index)]
        }else{
            return self.sourceListItems?[Int(index)] ?? PXSourceListItem()
        }
    }
    
    func sourceList(_ aSourceList: PXSourceList!, isItemExpandable item: Any!) -> Bool {
        if let node = item as? PXSourceListItem {
            return node.hasChildren()
        }else{
            return false
        }
    }
    
    
}
