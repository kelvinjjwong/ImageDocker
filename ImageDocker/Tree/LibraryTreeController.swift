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
    
    // MARK: DATA SOURCE
    
    func loadPathToTree(_ startingPath:String){
        let imageFolders = ImageFolderTreeScanner.default.scanImageFolder(path: startingPath)
        
        if imageFolders.count > 0 {
            for imageFolder:ImageFolder in imageFolders {
                self.addLibraryTreeEntry(imageFolder: imageFolder)
            }
            
            ExportManager.disable()
            // scan photo files
            //let startingFolder:ImageFolder = imageFolders[0]
            DispatchQueue.global().async {
                for folder in imageFolders {
                    self.collectionLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage,
                                                                  onCompleted: { data in
                                                                    self.creatingRepository = false
                                                                    ExportManager.enable()
                    })
                    self.imagesLoader.load(from: folder.url, indicator:self.collectionLoadingIndicator)
                    //self.refreshCollectionView()
                }
                
            }
        }
    }
    
    func loadPathToTreeFromDatabase(fast:Bool = true) {
        print("\(Date()) Loading image folders from db ")
        let imageFolders = ImageFolderTreeScanner.default.scanImageFolderFromDatabase(fast: fast)
        
        print("\(Date()) Adding image folders as tree entries ")
        if imageFolders.count > 0 {
            for imageFolder:ImageFolder in imageFolders {
                self.addLibraryTreeEntry(imageFolder: imageFolder)
            }
        }
    }
    
    // MARK: REFRESH
    
    func refreshLibraryTree(fast:Bool = true) {
        //print("REFRESHING MOMENT TREE at \(Date())")
        let count = self.libraryItem().children.count
        // remove items in moments
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
        self.loadPathToTreeFromDatabase(fast: fast)
        
        DispatchQueue.main.async {
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
        
        let collection:PhotoCollection = PhotoCollection(title: imageFolder.getPathExcludeParent(),
                                                         identifier: imageFolder.url.path,
                                                         type: imageFolder.children.count == 0 ? .userCreated : .library,
                                                         source: .library)
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        //self.modelObjects?.add(collection)
        _parent.addChildItem(item)
        collection.photoCount = imageFolder.countOfImages
        
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
                self.imagesLoader.load(from: imageFolder.url, indicator:self.collectionLoadingIndicator)
                self.refreshCollectionView()
            }
        }
    }
}
