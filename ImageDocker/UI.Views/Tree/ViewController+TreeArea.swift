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
//        self.treeIndicator.isEnabled = false
//        self.treeIndicator.isHidden = true
//        self.treeIndicator.doubleValue = 0.0
        
        let TREEVIEW_WIDTH:CGFloat = 290
        
        self.stackedTreeView = StackedTreeViewController(divideTo: 5)
        self.stackedTreeCanvasView.addSubview(stackedTreeView.view)

        stackedTreeView.view.boundToSuperView(superview: self.stackedTreeCanvasView)
        stackedTreeView.view.setWidth(TREEVIEW_WIDTH)
//
//        stackedTreeView.addTreeView(title:Words.nav_cat_devices.word(),
//                                    dataSource: self.deviceTreeDataSource,
//                                    width: TREEVIEW_WIDTH,
//                                    disableFilter: true,
//                                    nodeIcon: { collection in
//                                        if let state = collection.relatedObjectState {
//                                            return state == 1 ? Icons.phoneConnected : Icons.phone
//                                        }else{
//                                            return Icons.phone
//                                        }
//        },
//                                    nodeValue: { collection in
//                                        if collection.path == "Android" || collection.path == "iPhone" {
//                                            return "📲 \(collection.childrenCount) 🔌 \(collection.connectedCount)"
//                                        }else{
//                                            if let state = collection.relatedObjectState {
//                                                if state == 1 {
//                                                    return "🟢"
//                                                }else {
//                                                    return ""
//                                                }
//                                            }else{
//                                                return ""
//                                            }
//                                        }
//        },
//                                    onNodeSelected: { collection in
////                                        self.logger.log("action on \(collection.path)")
//                                        if collection.path == "Android" || collection.path == "iPhone" {
//                                            self.logger.log("expand device tree")
//                                            self.stackedTreeView.expand(tree: Words.nav_cat_devices.word(), path: collection.path)
//                                        }else{
//                                            if let id = collection.relatedObjectId,
//                                                let device = self.deviceTreeDataSource.getDeviceById(id),
//                                                let state = collection.relatedObjectState {
//                                                self.openDeviceCopyView(device: device, connected: state == 1)
//                                            }else{
//                                                self.logger.log("device collection id is nil")
//                                            }
//                                        }
//        },
//                                    notificationHolder: self.btnAlertMessage)

        stackedTreeView.addTreeView(title:Words.nav_cat_moments.word(),
                                    dataSource: self.momentsTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    nodeValue: { collection in
                                        if let moment = collection.relatedObject as? Moment {
                                            if collection.expandable {
                                                return "📂 \(moment.photoCount)"
                                            }else{
                                                return "🏞️ \(moment.photoCount)"
                                            }
                                            
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
                                            self.collectionPaginationController?.reload()
                                        }
        },
                                    notificationHolder: self.btnAlertMessage)
        
        
        stackedTreeView.addTreeView(title:Words.nav_cat_events.word(),
                                    dataSource: self.eventsTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    nodeValue: { collection in
                                        if let moment = collection.relatedObject as? Moment {
                                            if collection.expandable {
                                                return "📂 \(moment.photoCount)"
                                            }else{
                                                return "🏞️ \(moment.photoCount)"
                                            }
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
                                            if collection.expandable {
                                                return "📂 \(moment.photoCount)"
                                            }else{
                                                return "🏞️ \(moment.photoCount)"
                                            }
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
                                    nodeValue: { collection in
            if collection.subImagesCount == 0 {
                return "📂 \(collection.subContainersCount)"
            }else if collection.subContainersCount == 0 {
                return "🏞️ \(collection.subImagesCount)"
            }else {
                return "📂 \(collection.subContainersCount) 🏞️ \(collection.subImagesCount)"
            }
        },
                                    onNodeSelected: { collection in
//                                        self.logger.log("action on \(collection.path)")
                                        if let container = collection.relatedObject as? ImageContainer {
                                            self.selectedImageContainer = container
                                            self.logger.log("[TREE-onNodeSelected] container.id:\(container.id), repositoryId:\(container.repositoryId)")
                                            if let repository = RepositoryDao.default.getRepository(id: container.repositoryId) {
                                                if Setting.performance.amountForPagination() > 0 && container.imageCount > Setting.performance.amountForPagination() {
                                                    self.btnRefreshCollectionView.title = Words.pages.word()
                                                    self.loadCollectionByContainer(name: container.name, containerId: container.id, repositoryId: repository.id, repositoryVolume: repository.repositoryVolume, rawVolume: repository.storageVolume, pageSize: 200, pageNumber: 1)
                                                }else{
                                                    self.btnRefreshCollectionView.title = Words.reload.word()
                                                    self.loadCollectionByContainer(name: container.name, containerId: container.id, repositoryId: repository.id, repositoryVolume: repository.repositoryVolume, rawVolume: repository.storageVolume)
//                                                    self.loadCollectionByContainer(name:container.name, url:URL(fileURLWithPath: container.path))
                                                }
                                            }else{
                                                self.logger.log(.error, "[TREE-onNodeSelected] Unable to get repository by id for container id:\(container.id)")
                                            }
                                            
                                        }
                                        
        },
                                    moreActionOnHeader: { button in
                                        self.logger.log(.trace, "clicked tree-library more button")
                                        
                                        self.createLibrariesViewPopover()
                                        
                                        let cellRect = button.bounds
                                        self.librariesViewPopover?.show(relativeTo: cellRect, of: button, preferredEdge: .maxX)
        },
                                    moreActionOnNode: { collection, button in
//                                        self.logger.log("more on libs \(collection.path)")
                                        if let repository = collection.relatedObject as? ImageRepository {
                                            self.openRepositoryDetail(repository: repository, sender: button)
                                        }
                                        else if let container = collection.relatedObject as? ImageContainer {
                                            self.openContainerDetail(container: container, title: container.name, sender: button)
                                        }
        },
                                    notificationHolder: self.btnAlertMessage)
        
        stackedTreeView.showTree(Words.nav_cat_moments.word())
        
        self.startupAggregateFlag = 0
        DispatchQueue.global().async {
            self.startupAggregateFlag += 5
        }
    }
    
    
    internal func updateLibraryTree() {
        //self.creatingRepository = true
//        self.logger.log("UPDATING CONTAINERS")
//        DispatchQueue.global().async {
//            ImageFolderTreeScanner.default.updateAllContainersFileCount(onCompleted: {
                
//                self.logger.log("UPDATING CONTAINERS: DONE")
                
//                DispatchQueue.main.async {
//                    self.logger.log("UPDATING LIBRARY TREE")
//                    self.saveTreeItemsExpandState()
//                    self.refreshLibraryTree()
//                    self.restoreTreeItemsExpandState()
//                    self.restoreTreeSelection()
//                    self.logger.log("UPDATING LIBRARY TREE: DONE")
                    
                    //self.creatingRepository = false
                    
                    //                    if self.startingUp {
                    //                        self.splashController.message("Preparing UI ...", progress: 6)
                    //                    }
                    
//                }
//
//            })
//        }
    }
    
    
    
    
}

