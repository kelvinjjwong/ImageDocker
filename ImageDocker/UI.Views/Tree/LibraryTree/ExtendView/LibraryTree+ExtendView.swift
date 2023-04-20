//
//  LibraryTree+ExtendView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//


import Cocoa

extension ViewController {
    
    func createLibrariesViewPopover(){
        var myPopover = self.librariesViewPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 900, height: 450))
            self.librariesViewController = LibrariesViewController(onReload: {
                DispatchQueue.main.async {
                    self.stackedTreeView.reloadTree(Words.nav_cat_libraries.word())
                }
            })
            self.librariesViewController.view.frame = frame
            
            myPopover!.contentViewController = self.librariesViewController
            myPopover!.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)!
            //myPopover!.animates = true
            myPopover!.delegate = self
            myPopover!.behavior = NSPopover.Behavior.transient
        }
        self.librariesViewPopover = myPopover
    }

    func openRepositoryDetail(repository:ImageRepository, sender:NSButton) {
        self.createRepositoryDetailPopover()
        let path = Naming.Image.generateFullAbsoluteRepositoryPath(repositoryVolume: repository.repositoryVolume, repositoryPath: repository.repositoryPath)
        self.repositoryDetailViewController.initView(id: repository.id,
                                                     path: path,
                                                     onShowDeviceDialog: { device in
                                                        
                                                        self.openDeviceCopyView(device: device, connected: false)
                                                     },
                                                     onConfigure: {
            
                                                        let viewController = EditRepositoryViewController()
                                                        let window = NSWindow(contentViewController: viewController)
                                                        
                                                        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
                                                        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
                                                        let windowWidth = 1080
                                                        let windowHeight = 820
                                                        let originX = (screenWidth - windowWidth) / 2
                                                        let originY = (screenHeight - windowHeight) / 2
                                                        
                                                        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
                                                        window.title = Words.repositoryConfiguration.word()
                                                        window.setFrame(frame, display: false)
                                                        window.makeKeyAndOrderFront(self)
                                                        viewController.initEdit(path: path, window: window)
                                                     },
                                                     onManageSubContainers: {
            
                                                        let viewController = SubContainersManageViewController()
                                                        let window = NSWindow(contentViewController: viewController)
                                                        
                                                        let screenWidth = Int(NSScreen.main?.frame.width ?? 0)
                                                        let screenHeight = Int(NSScreen.main?.frame.height ?? 0)
                                                        let windowWidth = 1600
                                                        let windowHeight = 820
                                                        let originX = (screenWidth - windowWidth) / 2
                                                        let originY = (screenHeight - windowHeight) / 2
                                                        
                                                        let frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: windowWidth, height: windowHeight))
                                                        window.title = Words.repositoryConfiguration.word()
                                                        window.setFrame(frame, display: false)
                                                        window.makeKeyAndOrderFront(self)
                                                        viewController.initView(containerPath: path)
                                                     }
        )
        
        let cellRect = sender.bounds
        self.repositoryDetailPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
    }
    
    func openContainerDetail(container:ImageContainer, url:URL, title:String, sender:NSButton) {
        self.createContainerDetailPopover()
        self.containerDetailViewController.initView(container, onLoad: { pageSize, pageNumber in
            self.logger.log("CALLED ONLOAD \(pageSize) \(pageNumber)")
            self.loadCollectionByContainer(name:title, url:url,
                                           pageSize: pageSize, pageNumber: pageNumber, subdirectories: true)
        })
        
        let cellRect = sender.bounds
        self.containerDetailPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
    }
    
    // MARK: - POPOVER
    
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
    
    
    func createRepositoryDetailPopover(){
        var myPopover = self.repositoryDetailPopover
        if(myPopover == nil){
            myPopover = NSPopover()
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 1310, height: 500))
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
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 1310, height: 400))
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
}
