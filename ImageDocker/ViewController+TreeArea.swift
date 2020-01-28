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
