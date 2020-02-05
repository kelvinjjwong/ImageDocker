//
//  ViewController+Main+TreeArea.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList

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
        
        let dataSource1 = SampleDataSource1()
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
        },
                                    moreActionOnHeader: { button in
                                        print("clicked moments more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on moments \(collection.path)")
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
        },
                                    moreActionOnHeader: { button in
                                        print("clicked events more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on events \(collection.path)")
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
        },
                                    moreActionOnHeader: { button in
                                        print("clicked places more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on places \(collection.path)")
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
            
//            self.initTreeDataModel()
//            self.startupAggregateFlag += 1
//            print("\(Date()) Loading view - configure tree - loading path to tree from db")
//            self.loadPathToTreeFromDatabase(onCompleted: {
//
//                self.startupAggregateFlag += 1
//            })
//
//            print("\(Date()) Loading view - configure tree - loading moments to tree from db")
//            self.loadMomentsToTreeFromDatabase(onCompleted: {
//                self.startupAggregateFlag += 1
//            })
//            print("\(Date()) Loading view - configure tree - loading places to tree from db")
//            self.loadPlacesToTreeFromDatabase(onCompleted: {
//
//                self.startupAggregateFlag += 1
//            })
//            print("\(Date()) Loading view - configure tree - loading events to tree from db")
//            self.loadEventsToTreeFromDatabase(onCompleted: {
//                self.startupAggregateFlag += 1
//            })
            
            self.startupAggregateFlag += 5
        }
    }
    
    internal func hideToolbarOfTree() {
//        self.btnAddRepository.isHidden = true
//        self.btnRemoveRepository.isHidden = true
//        self.btnRefreshRepository.isHidden = true
//        self.btnFilterRepository.isHidden = true
    }
    
    internal func showToolbarOfTree() {
//        self.btnAddRepository.isHidden = false
//        self.btnRemoveRepository.isHidden = false
//        self.btnRefreshRepository.isHidden = false
//        self.btnFilterRepository.isHidden = false
    }
    
    func showTreeNodeButton(collection: PhotoCollection, image: NSImage? = nil) {
//        collection.enableMoreButton = true
//        if let img = image {
//            collection.treeNodeView?.btnMore.image = img
//            collection.imageOfMoreButton = img
//        }
    }
    
    func hideTreeNodeButton(collection: PhotoCollection){
//        collection.enableMoreButton = false
    }
    
    internal func refreshTree(fast:Bool = true) {
        
//        DispatchQueue.main.async {
//            self.hideToolbarOfTree()
//            self.hideToolbarOfCollectionView()
//
//            self.treeIndicator.doubleValue = 0.0
//            self.treeIndicator.isHidden = false
//            self.treeIndicator.isEnabled = true
//        }
//        DispatchQueue.global().async {
//
//            self.saveTreeItemsExpandState()
//            DispatchQueue.main.async {
//                self.treeIndicator.doubleValue = 1.0
//            }
//
//            self.refreshLibraryTree(fast: fast)
//            DispatchQueue.main.async {
//                self.treeIndicator.doubleValue = 2.0
//            }
//            self.refreshMomentTree()
//            DispatchQueue.main.async {
//                self.treeIndicator.doubleValue = 3.0
//            }
//            self.refreshLocationTree()
//            DispatchQueue.main.async {
//                self.treeIndicator.doubleValue = 4.0
//            }
//            self.refreshEventTree()
//            DispatchQueue.main.async {
//                self.treeIndicator.doubleValue = 5.0
//            }
//
//            DispatchQueue.main.async {
//                self.restoreTreeItemsExpandState()
//                self.restoreTreeSelection()
//
//                self.treeIndicator.isHidden = true
//                self.treeIndicator.isEnabled = false
//
//                self.showToolbarOfTree()
//                self.showToolbarOfCollectionView()
//            }
//        }
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

