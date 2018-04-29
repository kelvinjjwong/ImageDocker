//
//  TreeListController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/28.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList

extension ViewController {
    
    func addNumberOfPhotoObjects(_ numberOfObjects:UInt, toCollection collection:PhotoCollection) {
        var photos:NSMutableArray = NSMutableArray()
        for _ in 0...numberOfObjects {
            photos.add(Photo())
        }
        collection.photos = photos as! [Any]
    }
    
    func libraryItem() -> PXSourceListItem {
        return self.sourceListItems![0] as! PXSourceListItem
    }
    
    func albumItem() -> PXSourceListItem {
        return self.sourceListItems![1] as! PXSourceListItem
    }
    
    func setUpSourceListDataModel() {
        self.sourceListItems = NSMutableArray(array:[])
        
        let photoCollection:PhotoCollection = PhotoCollection(title: "Photos", identifier: "photos", type: PhotoCollectionType.library)
        self.addNumberOfPhotoObjects(264, toCollection: photoCollection)
        
        let landscapePhotoCollection:PhotoCollection = PhotoCollection(title: "Landscape", identifier: "landscape", type: PhotoCollectionType.userCreated)
        self.addNumberOfPhotoObjects(102, toCollection: landscapePhotoCollection)
        
        let portraitPhotoCollection:PhotoCollection = PhotoCollection(title: "Portrait", identifier: "portrait", type: PhotoCollectionType.userCreated)
        self.addNumberOfPhotoObjects(102, toCollection: portraitPhotoCollection)
        
        let eventsCollection:PhotoCollection = PhotoCollection(title: "Events", identifier: "events", type: PhotoCollectionType.library)
        self.addNumberOfPhotoObjects(101, toCollection: eventsCollection)
        
        let snapshotCollection:PhotoCollection = PhotoCollection(title: "Holidays", identifier: "holidays", type: PhotoCollectionType.userCreated)
        self.addNumberOfPhotoObjects(201, toCollection: snapshotCollection)
        
        
        self.modelObjects = NSMutableArray(array:[photoCollection, landscapePhotoCollection, portraitPhotoCollection, eventsCollection, snapshotCollection])
        
        let photosImage:NSImage = NSImage(imageLiteralResourceName: "photos")
        photosImage.isTemplate = true
        let eventsImage:NSImage = NSImage(imageLiteralResourceName: "events")
        eventsImage.isTemplate = true
        let peopleImage:NSImage = NSImage(imageLiteralResourceName: "people")
        peopleImage.isTemplate = true
        let placesImage:NSImage = NSImage(imageLiteralResourceName: "places")
        placesImage.isTemplate = true
        let albumImage:NSImage = NSImage(imageLiteralResourceName: "album")
        albumImage.isTemplate = true
        
        let portraitCollectionItem:PXSourceListItem = PXSourceListItem(representedObject: portraitPhotoCollection, icon: albumImage)
        
        let landscapeCollectionItem:PXSourceListItem = PXSourceListItem(representedObject: landscapePhotoCollection, icon: albumImage)
        
        let photoCollectionItem:PXSourceListItem = PXSourceListItem(representedObject: photoCollection, icon: photosImage)
        
        let eventsCollectionItem:PXSourceListItem = PXSourceListItem(representedObject: eventsCollection, icon: eventsImage)
        
        photoCollectionItem.children = [portraitCollectionItem, landscapeCollectionItem]
        
        let libraryItem:PXSourceListItem = PXSourceListItem(title: "LIBRARY", identifier: "")
        libraryItem.children = [photoCollectionItem, eventsCollectionItem]
        
        let albumsItem:PXSourceListItem = PXSourceListItem(title: "ALBUMS", identifier: "")
        let snapshotCollectionItem:PXSourceListItem = PXSourceListItem(representedObject: snapshotCollection, icon: albumImage)
        albumsItem.addChildItem(snapshotCollectionItem)
        albumsItem.children = [snapshotCollectionItem]
        
        self.sourceListItems = NSMutableArray(array:[libraryItem, albumsItem])
        
    }
}


extension ViewController : PXSourceListDelegate {
    
    func sourceList(_ sourceList: PXSourceList!, isGroupAlwaysExpanded group: Any!) -> Bool {
        return true
    }
    
    func sourceList(_ aSourceList:PXSourceList!, viewForItem item: Any!) -> NSView {
        var cellView: LCSourceListTableCellView? = nil
        print("----------")
        if let sourceListItem: PXSourceListItem = item as? PXSourceListItem {
            
            if aSourceList.level(forItem: item) == 0 {
                var sectionCellView:PXSourceListTableCellView = (aSourceList.makeView(withIdentifier: NSUserInterfaceItemIdentifier("HeaderCell"), owner: nil) as! PXSourceListTableCellView)
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
                if sourceTitle != nil && sourceListItem.title != "" {
                    cellView?.textField?.stringValue = sourceListItem.title
                } else {
                    if collectionTitle != nil && collection.title != "" {
                        cellView?.textField?.stringValue = collection.title
                    }
                }
                if sourceTitle == nil && collectionTitle != nil {
                    cellView?.textField?.stringValue = collection.title
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
        var removeButtonEnabled:Bool = false
        var newLabel:String = ""
        if let selectedItem:PXSourceListItem = self.sourceList.item(atRow: self.sourceList.selectedRow) as? PXSourceListItem {
            if self.albumItem().hasChildren() {
                if let children:NSMutableArray = NSMutableArray(array:self.albumItem().children) {
                    if children.contains(selectedItem) {
                        removeButtonEnabled = true
                    }
                }
            }
            
            if let collection:PhotoCollection = selectedItem.representedObject as? PhotoCollection {
                if collection.identifier != nil && collection.identifier != "" {
                    newLabel = "\(collection.identifier) collection selected."
                }else{
                    newLabel = "User-created collection selected."
                }
            }
            print(newLabel)
            // set content label
            // enable btnRemove
            
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
            return UInt(2)
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
