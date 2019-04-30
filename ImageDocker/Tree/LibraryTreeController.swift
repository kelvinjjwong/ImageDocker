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
                                // hide by parent
                                // ignore this one
                            }else{
                                if let parent = imageFolder.parent {
                                    if let parentContainer = parent.containerFolder, !parentContainer.manyChildren {
                                        // parent has a few children
                                        if imageFolder.countOfImages > 0 {
                                            self.addLibraryTreeEntry(imageFolder: imageFolder)
                                        }
                                    }else{
                                        // parent has many children
                                        // ignore this one
                                    }
                                }else{ // no parent
                                    if imageFolder.countOfImages > 0 {
                                        self.addLibraryTreeEntry(imageFolder: imageFolder)
                                    }
                                }
                            }
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
    
    // MARK: REFRESH
    
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
                self.sourceList.reloadData()
                print("\(Date()) RELOADING SOURCE LIST DATASET: DONE")
            }
        })
    }
    
    // MARK: ADD NODES
    
    fileprivate func addLibraryTreeEntry(imageFolder:ImageFolder) {
        var _parent:PXSourceListItem
        if imageFolder.parent == nil {
            _parent = self.libraryItem() //self.librarySectionOfTree!
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
            collection.buttonAction = { sender in
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
            collection.buttonAction = { sender in 
                
                if let container = imageFolder.containerFolder {
                    self.createContainerDetailPopover()
                    self.containerDetailViewController.initView(container, onLoad: { pageSize, pageNumber in
                        print("CALLED ONLOAD \(pageSize) \(pageNumber)")
                        self.selectImageFolder(imageFolder, pageSize: pageSize, pageNumber: pageNumber, subdirectories: container.manyChildren)
                    })
                    
                    let cellRect = sender.bounds
                    self.containerDetailPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
                }
            }
        }
        
        self.identifiersOfLibraryTree[imageFolder.url.path] = item
        
        collection.imageFolder = imageFolder
        imageFolder.photoCollection = collection
        
        self.treeIdItems[imageFolder.url.path] = item
        
    }
    
    func reloadImageFolder(sender:NSButton) {
        if let imageFolder = self.selectedImageFolder, let container = imageFolder.containerFolder {
            self.createCollectionPaginationPopover()
            self.collectionPaginationViewController
                .initView(self.imagesLoader.lastRequest,
                          onCountTotal: {
                            return ModelStore.default.countImages(repositoryRoot: container.path.withStash())
                },
                          onCountHidden: {
                            return ModelStore.default.countHiddenImages(repositoryRoot: container.path.withStash())
                },
                          onLoad: { pageSize, pageNumber in
                            print("CALLED ONLOAD \(pageSize) \(pageNumber)")
                            self.selectImageFolder(imageFolder, pageSize: pageSize, pageNumber: pageNumber, subdirectories: container.manyChildren)
            })
            
            let cellRect = sender.bounds
            self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .minY)
        }
    }
    
    // MARK: CLICK ACTION, LOAD COLLECTION
    
    func selectImageFolder(_ imageFolder:ImageFolder, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false){
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
        self.selectedImageFolder = imageFolder
        //print("selected image folder: \(imageFolder.url.path)")
        self.scaningRepositories = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        self.imagesLoader.showHidden = self.chbShowHidden.state == .on
        
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
                DispatchQueue.main.async {
                    self.indicatorMessage.stringValue = "Cancelling last request ..."
                }
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.load(from: imageFolder.url, indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
                    self.refreshCollectionView()
                })
            }else{
                print("LOADING from library entry \(imageFolder.name)")
                self.imagesLoader.load(from: imageFolder.url, indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
                self.refreshCollectionView()
            }
        }
    }
    
    func createContainerDetailPopover(){
        var myPopover = self.containerDetailPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 540, height: 390))
            self.containerDetailViewController = ContainerDetailViewController()
            self.containerDetailViewController.view.frame = frame
            
            myPopover!.contentViewController = self.containerDetailViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.containerDetailPopover = myPopover
    }
    
    func createCollectionPaginationPopover(){
        var myPopover = self.collectionPaginationPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 540, height: 180))
            self.collectionPaginationViewController = CollectionPaginationViewController()
            self.collectionPaginationViewController.view.frame = frame
            
            myPopover!.contentViewController = self.collectionPaginationViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.collectionPaginationPopover = myPopover
    }
}
