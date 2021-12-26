//
//  ViewController+Main+TreeArea.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    
    
    // init trees
    internal func configureTree(){
        //self.sourceList.backgroundColor = NSColor.darkGray
        
//        self.hideToolbarOfTree()
        self.hideToolbarOfCollectionView()
//        self.treeIndicator.isEnabled = false
//        self.treeIndicator.isHidden = true
//        self.treeIndicator.doubleValue = 0.0
        
        let TREEVIEW_WIDTH:CGFloat = 290
        
        self.stackedTreeView = StackedTreeViewController(divideTo: 5)
        self.stackedTreeCanvasView.addSubview(stackedTreeView.view)

        stackedTreeView.view.boundToSuperView(superview: self.stackedTreeCanvasView)
        stackedTreeView.view.setWidth(TREEVIEW_WIDTH)

        stackedTreeView.addTreeView(title:Words.nav_cat_devices.word(),
                                    dataSource: self.deviceTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    disableFilter: true,
                                    nodeIcon: { collection in
                                        if let state = collection.relatedObjectState {
                                            return state == 1 ? Icons.phoneConnected : Icons.phone
                                        }else{
                                            return Icons.phone
                                        }
        },
                                    onNodeSelected: { collection in
//                                        self.logger.log("action on \(collection.path)")
                                        if collection.path == "Android" || collection.path == "iPhone" {
                                            self.stackedTreeView.expand(tree: Words.nav_cat_devices.word(), path: collection.path)
                                        }else{
                                            if let id = collection.relatedObjectId,
                                                let device = self.deviceTreeDataSource.getDeviceById(id),
                                                let state = collection.relatedObjectState {
                                                self.openDeviceCopyView(device: device, connected: state == 1)
                                            }
                                        }
        },
                                    notificationHolder: self.btnAlertMessage)

        stackedTreeView.addTreeView(title:Words.nav_cat_moments.word(),
                                    dataSource: self.momentsTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    nodeValue: { collection in
                                        if let moment = collection.relatedObject as? Moment {
                                            return "\(moment.photoCount)"
                                        }else{
                                            return "0"
                                        }
        },
                                    onNodeSelected: { collection in
//                                        self.logger.log("action on \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.loadCollectionByMoment(moment:moment, pageSize: 200, pageNumber: 1)
                                        }
        },
                                    moreActionOnHeader: { button in
//                                        self.logger.log("clicked moments more button")
                                        self.momentsTreeCategory = "MOMENTS"
                                        self.openMomentsTreeHeaderExtendView(sender: button)
        },
                                    moreActionOnNode: { collection, button in
//                                        self.logger.log("more on moments \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.reloadMomentCollection(moment:moment, sender:button)
                                        }
        },
                                    notificationHolder: self.btnAlertMessage)
        
        
        stackedTreeView.addTreeView(title:Words.nav_cat_events.word(),
                                    dataSource: self.eventsTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    nodeValue: { collection in
                                        if let moment = collection.relatedObject as? Moment {
                                            return "\(moment.photoCount)"
                                        }else{
                                            return "0"
                                        }
        },
                                    onNodeSelected: { collection in
//                                        self.logger.log("action on \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.loadCollectionByEvent(moment:moment, pageSize: 200, pageNumber: 1)
                                        }
        },
                                    moreActionOnHeader: { button in
//                                        self.logger.log("clicked events more button")
                                        self.momentsTreeCategory = "EVENTS"
                                        self.openMomentsTreeHeaderExtendView(sender: button)
        },
                                    moreActionOnNode: { collection, button in
//                                        self.logger.log("more on events \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.reloadEventCollection(moment:moment, sender:button)
                                        }
        },
                                    notificationHolder: self.btnAlertMessage)


        stackedTreeView.addTreeView(title:Words.nav_cat_places.word(),
                                    dataSource: self.placesTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    nodeValue: { collection in
                                        if let moment = collection.relatedObject as? Moment {
                                            return "\(moment.photoCount)"
                                        }else{
                                            return "0"
                                        }
        },
                                    onNodeSelected: { collection in
//                                        self.logger.log("action on \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.loadCollectionByPlace(moment:moment, pageSize: 200, pageNumber: 1)
                                        }
        },
                                    moreActionOnHeader: { button in
//                                        self.logger.log("clicked places more button")
                                        self.momentsTreeCategory = "PLACES"
                                        self.openMomentsTreeHeaderExtendView(sender: button)
        },
                                    moreActionOnNode: { collection, button in
//                                        self.logger.log("more on places \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.reloadPlaceCollection(moment:moment, sender:button)
                                        }
        },
                                    notificationHolder: self.btnAlertMessage)


        stackedTreeView.addTreeView(title:Words.nav_cat_libraries.word(),
                                    dataSource: self.repositoryTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    nodeIcon: { collection in
                                        return Icons.folder
        },
                                    onNodeSelected: { collection in
//                                        self.logger.log("action on \(collection.path)")
                                        if let container = collection.relatedObject as? ImageContainer {
                                            self.selectedImageContainer = container
                                            if PreferencesController.amountForPagination() > 0 && container.imageCount > PreferencesController.amountForPagination() {
                                                self.btnRefreshCollectionView.title = Words.pages.word()
                                                if container.path != "/" {
                                                    self.loadCollectionByContainer(name:container.name, url:URL(fileURLWithPath: container.path), pageSize: 200, pageNumber: 1, subdirectories: true)
                                                }else{
//                                                    self.logger.log("WARN: collection url is null")
                                                }
                                            }else{
                                                self.btnRefreshCollectionView.title = Words.reload.word()
                                                self.loadCollectionByContainer(name:container.name, url:URL(fileURLWithPath: container.path))
                                            }
                                        }
                                        
        },
                                    moreActionOnHeader: { button in
//                                        self.logger.log("clicked libs more button")
                                        self.createLibrariesViewPopover()
                                        
                                        let cellRect = button.bounds
                                        self.librariesViewPopover?.show(relativeTo: cellRect, of: button, preferredEdge: .maxX)
        },
                                    moreActionOnNode: { collection, button in
//                                        self.logger.log("more on libs \(collection.path)")
                                        if let container = collection.relatedObject as? ImageContainer {
                                            if container.parentFolder == "" {
                                                self.openRepositoryDetail(container: container, url: URL(fileURLWithPath: container.path), sender: button)
                                            }else{
                                                self.openContainerDetail(container: container, url: URL(fileURLWithPath: container.path), title: container.name, sender: button)
                                            }
                                        }
        },
                                    notificationHolder: self.btnAlertMessage)
        
        stackedTreeView.showTree("Moments")
        
        self.startupAggregateFlag = 0
        DispatchQueue.global().async {
            self.startupAggregateFlag += 5
        }
    }
    
    
    internal func updateLibraryTree() {
        //self.creatingRepository = true
//        self.logger.log("\(Date()) UPDATING CONTAINERS")
        DispatchQueue.global().async {
            ImageFolderTreeScanner.default.updateContainers(onCompleted: {
                
//                self.logger.log("\(Date()) UPDATING CONTAINERS: DONE")
                
                DispatchQueue.main.async {
//                    self.logger.log("\(Date()) UPDATING LIBRARY TREE")
//                    self.saveTreeItemsExpandState()
//                    self.refreshLibraryTree()
//                    self.restoreTreeItemsExpandState()
//                    self.restoreTreeSelection()
//                    self.logger.log("\(Date()) UPDATING LIBRARY TREE: DONE")
                    
                    //self.creatingRepository = false
                    
                    //                    if self.startingUp {
                    //                        self.splashController.message("Preparing UI ...", progress: 6)
                    //                    }
                    
                }
                
            })
        }
    }
    
    
    
    
}

