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
        
        let stackedTreeView = StackedTreeViewController(divideTo: 5)
        self.stackedTreeCanvasView.addSubview(stackedTreeView.view)

        stackedTreeView.view.boundToSuperView(superview: self.stackedTreeCanvasView)
        stackedTreeView.view.setWidth(TREEVIEW_WIDTH)
        
        let deviceTreeDataSource = DeviceTreeDataSource()
        let repositoryTreeDataSource = RepositoryTreeDataSource()
        let momentsTreeDataSource = MomentsTreeDataSource()
        let placesTreeDataSource = PlacesTreeDataSource()
        let eventsTreeDataSource = EventsTreeDataSource()

        stackedTreeView.addTreeView(title:"Devices",
                                    dataSource: deviceTreeDataSource,
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
                                        print("action on \(collection.path)")
                                        if collection.path == "Android" || collection.path == "iPhone" {
                                            stackedTreeView.expand(tree: "Devices", path: collection.path)
                                        }else{
                                            if let id = collection.relatedObjectId,
                                                let device = deviceTreeDataSource.getDeviceById(id),
                                                let state = collection.relatedObjectState {
                                                self.openDeviceCopyView(device: device, connected: state == 1)
                                            }
                                        }
        })

        stackedTreeView.addTreeView(title:"Moments",
                                    dataSource: momentsTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    nodeValue: { collection in
                                        if let moment = collection.relatedObject as? Moment {
                                            return moment.photoCount
                                        }else{
                                            return 0
                                        }
        },
                                    onNodeSelected: { collection in
                                        print("action on \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.loadCollectionByMoment(moment:moment, pageSize: 200, pageNumber: 1)
                                        }
        },
                                    moreActionOnHeader: { button in
                                        print("clicked moments more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on moments \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.reloadMomentCollection(moment:moment, sender:button)
                                        }
        })
        stackedTreeView.addTreeView(title:"Events",
                                    dataSource: eventsTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    nodeValue: { collection in
                                        if let moment = collection.relatedObject as? Moment {
                                            return moment.photoCount
                                        }else{
                                            return 0
                                        }
        },
                                    onNodeSelected: { collection in
                                        print("action on \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.loadCollectionByEvent(moment:moment, pageSize: 200, pageNumber: 1)
                                        }
        },
                                    moreActionOnHeader: { button in
                                        print("clicked events more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on events \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.reloadEventCollection(moment:moment, sender:button)
                                        }
        })


        stackedTreeView.addTreeView(title:"Places",
                                    dataSource: placesTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    nodeValue: { collection in
                                        if let moment = collection.relatedObject as? Moment {
                                            return moment.photoCount
                                        }else{
                                            return 0
                                        }
        },
                                    onNodeSelected: { collection in
                                        print("action on \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.loadCollectionByPlace(moment:moment, pageSize: 200, pageNumber: 1)
                                        }
        },
                                    moreActionOnHeader: { button in
                                        print("clicked places more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on places \(collection.path)")
                                        if let moment = collection.relatedObject as? Moment {
                                            self.reloadPlaceCollection(moment:moment, sender:button)
                                        }
        })


        stackedTreeView.addTreeView(title:"Libraries",
                                    dataSource: repositoryTreeDataSource,
                                    width: TREEVIEW_WIDTH,
                                    nodeIcon: { collection in
                                        return Icons.folder
        },
                                    onNodeSelected: { collection in
                                        print("action on \(collection.path)")
                                        if let container = collection.relatedObject as? ImageContainer {
                                            if PreferencesController.amountForPagination() > 0 && container.imageCount > PreferencesController.amountForPagination() {
                                                self.btnRefreshCollectionView.title = "Pages..."
                                                if container.path != "/" {
                                                    self.loadCollectionByContainer(name:container.name, url:URL(fileURLWithPath: container.path), pageSize: 200, pageNumber: 1, subdirectories: true)
                                                }else{
                                                    print("WARN: collection url is null")
                                                }
                                            }else{
                                                self.btnRefreshCollectionView.title = "Reload"
                                                self.loadCollectionByContainer(name:container.name, url:URL(fileURLWithPath: container.path))
                                                //self.loadCollectionByContainer(collection.imageFolder!)
                                            }
                                        }
                                        
        },
                                    moreActionOnHeader: { button in
                                        print("clicked libs more button")
                                        self.createLibrariesViewPopover()
                                        
                                        let cellRect = button.bounds
                                        self.librariesViewPopover?.show(relativeTo: cellRect, of: button, preferredEdge: .maxX)
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on libs \(collection.path)")
                                        if let container = collection.relatedObject as? ImageContainer {
                                            if container.parentFolder == "" {
                                                self.openRepositoryDetail(container: container, url: URL(fileURLWithPath: container.path), sender: button)
                                            }else{
                                                self.openContainerDetail(container: container, url: URL(fileURLWithPath: container.path), title: container.name, sender: button)
                                            }
                                        }
        })
        
        stackedTreeView.showTree("Moments")
        
        self.startupAggregateFlag = 0
        DispatchQueue.global().async {
            self.startupAggregateFlag += 5
        }
    }
    
    
    internal func updateLibraryTree() {
        //self.creatingRepository = true
        print("\(Date()) UPDATING CONTAINERS")
        DispatchQueue.global().async {
            ImageFolderTreeScanner.default.updateContainers(onCompleted: {
                
                print("\(Date()) UPDATING CONTAINERS: DONE")
                
                DispatchQueue.main.async {
                    print("\(Date()) UPDATING LIBRARY TREE")
//                    self.saveTreeItemsExpandState()
//                    self.refreshLibraryTree()
//                    self.restoreTreeItemsExpandState()
//                    self.restoreTreeSelection()
                    print("\(Date()) UPDATING LIBRARY TREE: DONE")
                    
                    //self.creatingRepository = false
                    
                    //                    if self.startingUp {
                    //                        self.splashController.message("Preparing UI ...", progress: 6)
                    //                    }
                    
                }
                
            })
        }
    }
    
    
    
    
}

