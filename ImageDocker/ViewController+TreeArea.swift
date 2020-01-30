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
        


        stackedTreeView.addTreeView(title:"Devices",
                                    dataSource: dataSource1,
                                    width: TREEVIEW_WIDTH,
                                    onNodeSelected: { collection in
                                        print("action on \(collection.path)")
        },
                                    moreActionOnHeader: {
                                        print("clicked devices more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on devices \(collection.path)")
        })

        stackedTreeView.addTreeView(title:"Moments",
                                    dataSource: dataSource1,
                                    width: TREEVIEW_WIDTH,
                                    onNodeSelected: { collection in
                                        print("action on \(collection.path)")
        },
                                    moreActionOnHeader: {
                                        print("clicked moments more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on moments \(collection.path)")
        })
        stackedTreeView.addTreeView(title:"Events",
                                    dataSource: dataSource1,
                                    width: TREEVIEW_WIDTH,
                                    onNodeSelected: { collection in
                                        print("action on \(collection.path)")
        },
                                    moreActionOnHeader: {
                                        print("clicked events more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on events \(collection.path)")
        })


        stackedTreeView.addTreeView(title:"Places",
                                    dataSource: dataSource1,
                                    width: TREEVIEW_WIDTH,
                                    onNodeSelected: { collection in
                                        print("action on \(collection.path)")
        },
                                    moreActionOnHeader: {
                                        print("clicked places more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on places \(collection.path)")
        })


        stackedTreeView.addTreeView(title:"Libraries",
                                    dataSource: dataSource1,
                                    width: TREEVIEW_WIDTH,
                                    onNodeSelected: { collection in
                                        print("action on \(collection.path)")
        },
                                    moreActionOnHeader: {
                                        print("clicked libs more button")
        },
                                    moreActionOnNode: { collection, button in
                                        print("more on libs \(collection.path)")
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


class SampleDataSource1: StaticTreeDataSource {
    
    override init() {
        super.init()
        var tree_data:[TreeCollection] = []
        for i in 1...3 {
            let tree = TreeCollection("root_\(i)")
            tree.addChild("leaf_1")
            tree.addChild("leaf_2")
            tree.addChild("leaf_3")
            tree.getChild("leaf_1")!.addChild("grand_1")
            tree.getChild("leaf_1")!.addChild("grand_2")
            tree.getChild("leaf_1")!.addChild("grand_3")
            tree.getChild("leaf_3")!.addChild("grand_a")
            tree.getChild("leaf_3")!.addChild("grand_b")
            tree.getChild("leaf_3")!.addChild("grand_c")
            tree.getChild("leaf_3")!.addChild("grand_d_very_long_long_long_long_text_to_see_next_line")
            tree_data.append(tree)
        }
        for data in tree_data {
            flattable_all.append(data)
            print("flatted: \(data.path)")
            flattable_all.append(contentsOf: data.getUnlimitedDepthChildren())
        }
        print("total \(flattable_all.count) node")
        self.filter(keyword: "")
        self.convertFlatToTree()
        
    }
}
