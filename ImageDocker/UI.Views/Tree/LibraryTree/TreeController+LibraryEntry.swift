//
//  LibraryTreeController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/6.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList
import GRDB


extension ViewController {
    
    // MARK: - LOADER
    
    func loadPathToTreeFromDatabase(fast:Bool = true, onCompleted:( () -> Void )? = nil) {
        print("\(Date()) Loading image folders from db ")
        DispatchQueue.global().async {
            
            autoreleasepool(invoking: { () -> Void in
                
                let imageFolders = ImageFolderTreeScanner.default.scanImageFolderFromDatabase(fast: fast)
                
                print("\(Date()) Adding image folders as tree entries: BEGIN")
                
                if imageFolders.count > 0 {
                    DispatchQueue.main.async {
                        for imageFolder:ImageFolder in imageFolders {
                            if let container = imageFolder.containerFolder, container.hideByParent {
                                continue
                            }
                            if let parent = imageFolder.parent, let parentContainer = parent.containerFolder, parentContainer.manyChildren {
                                continue
                            }
                            self.addLibraryTreeEntry(imageFolder: imageFolder)
                        }
                    }
                }
                print("\(Date()) Adding image folders as tree entries: DONE")
                
                
                
                if onCompleted != nil {
                    onCompleted!()
                }
            })
            
        }
    }
                
    
    // MARK: - REFRESH TREE
    
    @objc func refreshLibraryTree(fast:Bool = true) {
        print("\(Date()) REFRESHING LIBRARY TREE")
        let count = self.libraryItem().children.count
        // remove items in moments
        
        if count > 0 {
            for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
                //let index:Int = i - 1
                DispatchQueue.main.async {
                    self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                                inParent: self.libraryItem(),
                                                withAnimation: NSTableView.AnimationOptions.slideUp)
                }
            }
            
            DispatchQueue.main.async {
                self.libraryItem().children.removeAll()
            }
        }
        
        
        self.loadPathToTreeFromDatabase(fast: fast, onCompleted: {
            DispatchQueue.main.async {
                print("\(Date()) RELOADING SOURCE LIST DATASET: BEGIN")
                print("EVENT LIBRARY ENTRIES: \(self.libraryItem().hasChildren()) \(self.libraryItem().children?.count ?? 0)")
                
                self.sortLibraryTreeRepositories()
                self.sourceList.reloadData()
                print("\(Date()) RELOADING SOURCE LIST DATASET: DONE")
            }
        })
    }
    
    func sortLibraryTreeRepositories() {
        // sort root repositories ascending
        self.libraryItem().children.sort(by: { (left, right) -> Bool in
            if let a1:PXSourceListItem = left as? PXSourceListItem, let a2:PXSourceListItem = right as? PXSourceListItem {
                if let c1:PhotoCollection = a1.representedObject as? PhotoCollection, let c2:PhotoCollection = a2.representedObject as? PhotoCollection {
                    return c1.title < c2.title
                }
            }
            return false
        })
    }
    
    // MARK: - ADD TREE NODES
    
    fileprivate func addLibraryTreeEntry(imageFolder:ImageFolder) {
        self.addLibraryTreeEntry(title: imageFolder.name, url: imageFolder.url,
                                 imageCount: imageFolder.countOfImages,
                                 parentPath: imageFolder.parent?.url.path,
                                 container: imageFolder.containerFolder)
    }
    
    fileprivate func addLibraryTreeEntry(title:String, url:URL, imageCount:Int, parentPath:String?, container:ImageContainer?) {
        var _parent:PXSourceListItem
        if let parentPath = parentPath, let parentNode = self.identifiersOfLibraryTree[parentPath] {
            _parent = parentNode
        }else{
            _parent = self.libraryItem()
        }
        
        let collection:PhotoCollection = PhotoCollection(title: title,
                                                         identifier: url.path,
                                                         type: .library,
                                                         source: .library)
        collection.url = url
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: Icons.photos)
        //self.modelObjects?.add(collection)
        _parent.addChildItem(item)
        collection.photoCount = imageCount
        
        self.showTreeNodeButton(collection: collection, image: Icons.moreHorizontal)
        if parentPath == nil { // repository
            collection.buttonAction = { sender in
                if let container = container { // show popover only if has container data
                    self.openRepositoryDetail(container: container, url: url, sender: sender)
                }
            }
        }else{ // sub-container
            collection.buttonAction = { sender in 
                
                if let container = container, container.imageCount > 0 {
                    self.openContainerDetail(container: container, url: url, title: title, sender: sender)
                }
            }
        }
        
        self.identifiersOfLibraryTree[url.path] = item
        
//        collection.imageFolder = imageFolder
//        imageFolder.photoCollection = collection
        
        self.cachedTreeCollections.append(collection)
        
        self.treeIdItems[url.path] = item
        
    }
}
