//
//  ViewController+Main+SelectionArea.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//


import Cocoa

extension ViewController {
    
    func configureSelectionView() {
        self.selectionViewController = (storyboard?.instantiateController(withIdentifier: "SelectionViewController") as! SelectionViewController)
        self.addChild(self.selectionViewController)
        self.bottomView.addSubview(self.selectionViewController.view)
        self.selectionViewController.initView()
        
        self.centralHorizontalSplitView.setPosition((self.view.window?.screen?.visibleFrame.height ?? 0) - 305, ofDividerAt: 0)
        
        self.selectionViewController.isSmallScreen = {
            return self.smallScreen
        }
        
        self.selectionViewController.reloadMainCollectionView = {
            self.imagesLoader.reload()
            self.imagesLoader.reorganizeItems(considerPlaces: true)
            self.collectionView.reloadData()
        }
        
        self.selectionViewController.selectImage = { image in
            return self.selectImageFile(image)
        }
        
        self.selectionViewController.getMainCollectionVisibleItems = {
            return self.collectionView.visibleItems() as! [CollectionViewItem]
        }
        
        self.selectionViewController.selectAllInMainCollectionView = { state in
//            self.chbSelectAll.state = state ? .on : .off
        }
    }
}

