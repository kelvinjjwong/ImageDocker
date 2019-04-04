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
    
    func loadPathToTreeFromDatabase(fast:Bool = true) {
        print("\(Date()) Loading image folders from db ")
        DispatchQueue.global().async {
            
            autoreleasepool(invoking: { () -> Void in
                
                let imageFolders = ImageFolderTreeScanner.default.scanImageFolderFromDatabase(fast: fast)
                
                print("\(Date()) Adding image folders as tree entries ")
                if imageFolders.count > 0 {
                    DispatchQueue.main.async {
                        for imageFolder:ImageFolder in imageFolders {
                            if let container = imageFolder.containerFolder, container.hideByParent {
                                // hide by parent
                                // ignore this one
                            }else{
                                if let parent = imageFolder.parent {
                                    if let parentContainer = parent.containerFolder, !parentContainer.manyChildren {
                                        // parent has a few children
                                        self.addLibraryTreeEntry(imageFolder: imageFolder)
                                    }else{
                                        // parent has many children
                                        // ignore this one
                                    }
                                }else{ // no parent
                                    self.addLibraryTreeEntry(imageFolder: imageFolder)
                                }
                            }
                        }
                    }
                }
            })
            
        }
    }
    
    // MARK: REFRESH
    
    @objc func refreshLibraryTree(fast:Bool = true) {
        //print("REFRESHING MOMENT TREE at \(Date())")
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
        
        DispatchQueue.main.async {
            self.loadPathToTreeFromDatabase(fast: fast)
            self.sourceList.reloadData()
        }
    }
    
    // MARK: ADD NODES
    
    fileprivate func addLibraryTreeEntry(imageFolder:ImageFolder) {
        var _parent:PXSourceListItem
        if imageFolder.parent == nil {
            _parent = self.librarySectionOfTree!
        }else{
            _parent = self.identifiersOfLibraryTree[(imageFolder.parent?.url.path)!]!
        }
        
        let collection:PhotoCollection = PhotoCollection(title: imageFolder.name,
                                                         identifier: imageFolder.url.path,
                                                         type: imageFolder.children.count == 0 ? .userCreated : .library,
                                                         source: .library)
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        //self.modelObjects?.add(collection)
        _parent.addChildItem(item)
        collection.photoCount = imageFolder.countOfImages
        
        self.showTreeNodeButton(collection: collection, image: moreHorizontalIcon)
        if imageFolder.parent == nil {
            collection.buttonAction = {
                if let window = self.repositoryWindowController.window {
                    if self.repositoryWindowController.isWindowLoaded {
                        window.makeKeyAndOrderFront(self)
                        print("order to front")
                    }else{
                        self.repositoryWindowController.showWindow(self)
                        print("show window")
                    }
                    let vc = window.contentViewController as! EditRepositoryViewController
                    vc.initEdit(path: imageFolder.url.path, window: window)
                }
            }
        }else{
            collection.buttonAction = {
                if let window = self.containerWindowController.window {
                    if self.containerWindowController.isWindowLoaded {
                        window.makeKeyAndOrderFront(self)
                        print("order to front")
                    }else{
                        self.containerWindowController.showWindow(self)
                        print("show window")
                    }
                    let vc = window.contentViewController as! ContainerViewController
                    vc.initContainer(path: imageFolder.url.path)
                }
            }
        }
        
        self.identifiersOfLibraryTree[imageFolder.url.path] = item
        
        collection.imageFolder = imageFolder
        imageFolder.photoCollection = collection
        
        self.treeIdItems[imageFolder.url.path] = item
        
    }
    
    // MARK: CLICK ACTION
    
    func selectImageFolder(_ imageFolder:ImageFolder){
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
        self.selectedImageFolder = imageFolder
        //print("selected image folder: \(imageFolder.url.path)")
        self.scaningRepositories = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        DispatchQueue.global().async {
            self.collectionLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: { data in
                    self.scaningRepositories = false
                    //                let total:Int = data["total"] ?? 0
                    //                let hidden:Int = data["hidden"] ?? 0
                    //                let message:String = "\(total) images, \(hidden) hidden"
                    //                self.indicatorMessage.stringValue = message
                }
            )
            if self.imagesLoader.isLoading() {
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.load(from: imageFolder.url, indicator:self.collectionLoadingIndicator)
                    self.refreshCollectionView()
                })
            }else{
                print("LOADING from library entry \(imageFolder.name)")
                self.imagesLoader.load(from: imageFolder.url, indicator:self.collectionLoadingIndicator)
                self.refreshCollectionView()
            }
        }
    }
}
