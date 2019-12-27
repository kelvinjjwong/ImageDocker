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
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        //self.modelObjects?.add(collection)
        _parent.addChildItem(item)
        collection.photoCount = imageCount
        
        self.showTreeNodeButton(collection: collection, image: moreHorizontalIcon)
        if parentPath == nil { // repository
            collection.buttonAction = { sender in
                if let container = container { // show popover only if has container data
                    self.createRepositoryDetailPopover()
                    self.repositoryDetailViewController.initView(path: container.path, onConfigure: {
                        let viewController = EditRepositoryViewController()
                        let window = NSWindow(contentViewController: viewController)
                        
                        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
                        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
                        let windowWidth = 980
                        let windowHeight = 820
                        let originX = (screenWidth - windowWidth) / 2
                        let originY = (screenHeight - windowHeight) / 2
                        
                        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
                        window.title = "Repository Configuration"
                        window.setFrame(frame, display: false)
                        window.makeKeyAndOrderFront(self)
                        viewController.initEdit(path: url.path, window: window)
                        
//                        if let window = self.repositoryWindowController.window {
//                            if self.repositoryWindowController.isWindowLoaded {
//                                window.makeKeyAndOrderFront(self)
//                                print("order to front")
//                            }else{
//                                self.repositoryWindowController.showWindow(self)
//                                print("show window")
//                            }
//                            let vc = window.contentViewController as! EditRepositoryViewController
//                        }
                    })
                    
                    let cellRect = sender.bounds
                    self.repositoryDetailPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
                }
            }
        }else{ // sub-container
            collection.buttonAction = { sender in 
                
                if let container = container, container.imageCount > 0 {
                    self.createContainerDetailPopover()
                    self.containerDetailViewController.initView(container, onLoad: { pageSize, pageNumber in
                        print("CALLED ONLOAD \(pageSize) \(pageNumber)")
                        self.loadCollectionByContainer(name:title, url:url,
                                                       pageSize: pageSize, pageNumber: pageNumber, subdirectories: container.manyChildren)
                    })
                    
                    let cellRect = sender.bounds
                    self.containerDetailPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
                }
            }
        }
        
        self.identifiersOfLibraryTree[url.path] = item
        
//        collection.imageFolder = imageFolder
//        imageFolder.photoCollection = collection
        
        self.cachedTreeCollections.append(collection)
        
        self.treeIdItems[url.path] = item
        
    }
    
    // MARK: - LOAD COLLECTION
    
    internal func loadCollectionByContainer(_ imageFolder:ImageFolder, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false){
        self.selectedImageFolder = imageFolder
        if imageFolder.url.path == "/" {
            print("ERROR: imageFolder.url.path is null")
            return
        }
        self.loadCollectionByContainer(name: imageFolder.name, url: imageFolder.url,
                                       pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
    }
    
    internal func loadCollectionByContainer(name:String, url:URL, pageSize:Int = 0, pageNumber:Int = 0, subdirectories:Bool = false){
        TaskManager.loadingImagesCollection = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        self.imagesLoader.showHidden = self.chbShowHidden.state == .on
        
        DispatchQueue.global().async {
            self.collectionLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: { data in
                    TaskManager.loadingImagesCollection = false
                }
            )
            if self.imagesLoader.isLoading() {
                DispatchQueue.main.async {
                    self.indicatorMessage.stringValue = "Cancelling last request ..."
                }
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.load(from: url, indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                })
            }else{
                print("LOADING from library entry \(name)")
                self.imagesLoader.load(from: url, indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber, subdirectories: subdirectories)
                self.refreshCollectionView()
                TaskManager.loadingImagesCollection = false
            }
        }
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
                            self.loadCollectionByContainer(imageFolder, pageSize: pageSize, pageNumber: pageNumber, subdirectories: container.manyChildren)
                })
            
            let cellRect = sender.bounds
            self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .minY)
        }
    }
    
    // MARK: - POPOVER
    
    func createRepositoryDetailPopover(){
        var myPopover = self.repositoryDetailPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 660, height: 360))
            self.repositoryDetailViewController = RepositoryDetailViewController()
            self.repositoryDetailViewController.view.frame = frame
            
            myPopover!.contentViewController = self.repositoryDetailViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.repositoryDetailPopover = myPopover
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
