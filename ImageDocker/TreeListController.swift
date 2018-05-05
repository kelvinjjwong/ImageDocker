//
//  TreeListController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList

let photosIcon:NSImage = NSImage(imageLiteralResourceName: "photos")
let eventsIcon:NSImage = NSImage(imageLiteralResourceName: "events")
let peopleIcon:NSImage = NSImage(imageLiteralResourceName: "people")
let placesIcon:NSImage = NSImage(imageLiteralResourceName: "places")
let albumIcon:NSImage = NSImage(imageLiteralResourceName: "album")

extension ViewController {
    
    func setUpSourceListDataModel() {
        placesIcon.isTemplate = true
        peopleIcon.isTemplate = true
        eventsIcon.isTemplate = true
        photosIcon.isTemplate = true
        albumIcon.isTemplate = true
        
        self.sourceListItems = NSMutableArray(array:[])
        self.modelObjects = NSMutableArray(array:[])
        
        let library = self.addSourceListSection(title: "LIBRARY")
            
        let startingPath:String = "/MacStorage/photo.huawei.honor8.wjj"
    
        self.imageFolders = ImageFolderScanner.default.scanImageFolder(path: startingPath)
        
        if imageFolders.count > 0 {
            for imageFolder:ImageFolder in imageFolders {
                self.addSourceListEntry(imageFolder: imageFolder, icon: photosIcon, root: library)
            }
        }
    }
    
    func addNumberOfPhotoObjects(_ numberOfObjects:UInt, toCollection collection:PhotoCollection) {
        let photos:NSMutableArray = NSMutableArray()
        for _ in 0...numberOfObjects {
            photos.add(Photo())
        }
        collection.photos = photos as! [Any]
    }
    
    func libraryItem() -> PXSourceListItem {
        return self.sourceListItems![0] as! PXSourceListItem
    }
    
    func addSourceListSection(title:String) -> PXSourceListItem {
        let item:PXSourceListItem = PXSourceListItem(title: title, identifier: "")
        self.sourceListItems?.add(item)
        self.sourceListIdentifiers[title] = item
        return item
    }
    
    func addSourceListEntry(imageFolder:ImageFolder, icon:NSImage, root:PXSourceListItem) {
        var _parent:PXSourceListItem
        if imageFolder.parent == nil {
            _parent = root
        }else{
            _parent = self.sourceListIdentifiers[(imageFolder.parent?.url.path)!]!
        }
        
        let collection:PhotoCollection = PhotoCollection(title: imageFolder.getPathExcludeParent(),
                                                         identifier: imageFolder.url.path,
                                                         type: imageFolder.children.count == 0 ? .userCreated : .library)
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: icon)
        self.modelObjects?.add(collection)
        _parent.addChildItem(item)
        self.addNumberOfPhotoObjects(UInt(imageFolder.countOfImages), toCollection: collection)
        
        self.sourceListIdentifiers[imageFolder.url.path] = item
        
        collection.imageFolder = imageFolder
        imageFolder.photoCollection = collection
        
    }
}


extension ViewController : PXSourceListDelegate {
    
    func sourceList(_ sourceList: PXSourceList!, isGroupAlwaysExpanded group: Any!) -> Bool {
        return true
    }
    
    func sourceList(_ aSourceList:PXSourceList!, viewForItem item: Any!) -> NSView {
        var cellView: LCSourceListTableCellView? = nil
        if let sourceListItem: PXSourceListItem = item as? PXSourceListItem {
            
            if aSourceList.level(forItem: item) == 0 {
                let sectionCellView:PXSourceListTableCellView = (aSourceList.makeView(withIdentifier: NSUserInterfaceItemIdentifier("HeaderCell"), owner: nil) as! PXSourceListTableCellView)
                sectionCellView.textField?.stringValue = sourceListItem.title
                return sectionCellView
            } else {
                cellView = (aSourceList.makeView(withIdentifier: NSUserInterfaceItemIdentifier("DataCell"), owner: nil) as! LCSourceListTableCellView)
            }
            if let t:String = sourceListItem.title {
                cellView?.textField?.stringValue = t
                print(t)
            }
            
            cellView?.imageView?.image = sourceListItem.icon
            
            if sourceListItem.representedObject == nil {
                // section, do nothing
            }else{
                let collection: PhotoCollection = sourceListItem.representedObject as! PhotoCollection
                
                let sourceTitle:String? = sourceListItem.title
                let collectionTitle:String? = collection.title
                if sourceTitle != nil && sourceTitle != "" {
                    cellView?.textField?.stringValue = sourceListItem.title
                } else {
                    if collectionTitle != nil && collectionTitle != "" {
                        cellView?.textField?.stringValue = collection.title
                    }
                }
                if sourceTitle == nil && collectionTitle != nil {
                    cellView?.textField?.stringValue = collectionTitle!
                }
                cellView?.badge?.stringValue = " \(collection.photos.count) "
                cellView?.badge?.isHidden = (collection.photos.count == 0)
                
            
            }
            return cellView!
        }else {
            return cellView!
        }
    }
    
    func sourceListSelectionDidChange(_ notification: Notification!) {
        //var removeButtonEnabled:Bool = false
        if let selectedItem:PXSourceListItem = self.sourceList.item(atRow: self.sourceList.selectedRow) as? PXSourceListItem {
            if self.libraryItem().hasChildren() {
                //if let children:NSMutableArray = NSMutableArray(array:self.libraryItem().children) {
                    //if children.contains(selectedItem) {
                        //removeButtonEnabled = true
                    //}
                //}
            }
            
            if let collection:PhotoCollection = selectedItem.representedObject as? PhotoCollection {
                print("\(collection.identifier) collection selected.")
            }
        }
    }
    
}

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
            return UInt(1)
        }
    }
    
    func sourceList(_ aSourceList: PXSourceList!, child index: UInt, ofItem item: Any!) -> Any! {
        if let node = item as? PXSourceListItem {
            return node.children[Int(index)]
        }else{
            return self.sourceListItems![Int(index)]
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
