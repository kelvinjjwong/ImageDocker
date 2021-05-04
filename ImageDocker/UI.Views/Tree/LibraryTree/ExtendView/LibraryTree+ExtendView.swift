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
                    self.stackedTreeView.reloadTree("Libraries")
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

    func openRepositoryDetail(container:ImageContainer, url:URL, sender:NSButton) {
        self.createRepositoryDetailPopover()
        self.repositoryDetailViewController.initView(path: container.path,
                                                     onShowDeviceDialog: { device in
                                                        
                                                        self.openDeviceCopyView(device: device, connected: false)
        },
                                                     onConfigure: {
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
    
    func openContainerDetail(container:ImageContainer, url:URL, title:String, sender:NSButton) {
        self.createContainerDetailPopover()
        self.containerDetailViewController.initView(container, onLoad: { pageSize, pageNumber in
            print("CALLED ONLOAD \(pageSize) \(pageNumber)")
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
            
            let frame = CGRect(origin: .zero, size: CGSize(width: 1310, height: 390))
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
}
