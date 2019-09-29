//
//  ViewController+Main+SelectionArea.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//


import Cocoa

extension ViewController {
    
    internal func configureSelectionView(){
        
        // init controller
        selectionViewController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "selectionView")) as! SelectionCollectionViewController
        selectionViewController.onItemClicked = { image in
            self.selectImageFile(image)
        }
        self.addChildViewController(selectionViewController)
        
        // outlet
        self.selectionCollectionView.dataSource = selectionViewController
        self.selectionCollectionView.delegate = selectionViewController
        
        // flow layout
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 180.0, height: 150.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        selectionCollectionView.collectionViewLayout = flowLayout
        
        // view layout
        selectionCollectionView.wantsLayer = true
        selectionCollectionView.backgroundColors = [NSColor.darkGray]
        selectionCollectionView.layer?.backgroundColor = NSColor.darkGray.cgColor
        selectionCollectionView.layer?.borderColor = NSColor.darkGray.cgColor
        
        // data model
        selectionViewController.collectionView = self.selectionCollectionView
        selectionViewController.imagesLoader.singleSectionMode = true
        selectionViewController.imagesLoader.clean()
        
        selectionCollectionView.reloadData()
        
    }
    
    internal func configureEditors(){
        batchEditIndicator.isHidden = true
        comboEventList.isEditable = false
        comboPlaceList.isEditable = false
    }
    
    
    
    internal func hideSelectionToolbar() {
        self.btnShare.isHidden = true
        self.btnCopyToDevice.isHidden = true
        self.btnShow.isHidden = true
        self.btnHide.isHidden = true
        self.selectionCheckAllBox.isHidden = true
        self.btnRemoveSelection.isHidden = true
        self.btnRemoveAllSelection.isHidden = true
    }
    
    internal func showSelectionToolbar() {
        self.btnShare.isHidden = false
        self.btnCopyToDevice.isHidden = false
        self.btnShow.isHidden = false
        self.btnHide.isHidden = false
        self.selectionCheckAllBox.isHidden = false
        self.btnRemoveSelection.isHidden = false
        self.btnRemoveAllSelection.isHidden = false
        
    }
    
    internal func switchSelectionToolbar() {
        
        if self.btnBatchEditorToolbarSwitcher.image == NSImage(named: NSImage.Name.goLeftTemplate) {
            self.hideSelectionBatchEditors()
            if smallScreen {
                self.showSelectionToolbar()
            }
            self.btnBatchEditorToolbarSwitcher.image = NSImage(named: NSImage.Name.goRightTemplate)
            self.btnBatchEditorToolbarSwitcher.toolTip = "Show event/datetime selectors"
        } else {
            self.showSelectionBatchEditors()
            if smallScreen {
                self.hideSelectionToolbar()
            }
            self.btnBatchEditorToolbarSwitcher.image = NSImage(named: NSImage.Name.goLeftTemplate)
            self.btnBatchEditorToolbarSwitcher.toolTip = "Hide event/datetime selectors"
        }
    }
    
    internal func hideSelectionBatchEditors() {
        self.comboEventList.isHidden = true
        self.btnAssignEvent.isHidden = true
        self.btnManageEvents.isHidden = true
        self.btnDatePicker.isHidden = true
        self.btnNotes.isHidden = true
        self.btnDuplicates.isHidden = true
    }
    
    internal func showSelectionBatchEditors() {
        self.comboEventList.isHidden = false
        self.btnAssignEvent.isHidden = false
        self.btnManageEvents.isHidden = false
        self.btnDatePicker.isHidden = false
        self.btnNotes.isHidden = false
        self.btnDuplicates.isHidden = false
    }
    
    internal func cleanUpSelectionArea() {
        // remove from selection
        var images:Set<String> = []
        for image in self.selectionViewController.imagesLoader.getItems() {
            images.insert(image.url.path)
        }
        self.selectionViewController.imagesLoader.clean()
        self.selectionCollectionView.reloadData()
        
        
        // uncheck in browser if exists there (if user changed to another folder, it won't be there)
        for item in self.collectionView.visibleItems() {
            let item = item as! CollectionViewItem
            if images.contains((item.imageFile?.url.path)!) {
                item.uncheck()
            }
        }
        self.selectionCheckAllBox.state = NSButton.StateValue.off
        self.chbSelectAll.state = NSButton.StateValue.off
    }
    
    internal func cleanSomeFromSelectionArea() {
        // collect which to be removed from selection
        var images:[ImageFile] = [ImageFile]()
        for item in self.selectionCollectionView.visibleItems() {
            let item = item as! CollectionViewItem
            if item.isChecked() {
                images.append(item.imageFile!)
            }
        }
        // remove from selection
        for image in images {
            self.selectionViewController.imagesLoader.removeItem(image)
        }
        self.selectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        
        // uncheck in browser if exists there (if user changed to another folder, it won't be there)
        for item in self.collectionView.visibleItems() {
            let item = item as! CollectionViewItem
            
            let i = images.index(where: { $0.url == item.imageFile?.url })
            if i != nil {
                item.uncheck()
            }
        }
        self.selectionCheckAllBox.state = NSButton.StateValue.off
    }
    
    internal func checkAllInSelectionArea() {
        if self.selectionViewController.imagesLoader.getItems().count == 0 {
            self.selectionCheckAllBox.state = NSButton.StateValue.off
            return
        }
        if self.selectionCheckAllBox.state == NSButton.StateValue.on {
            for i in 0...self.selectionViewController.imagesLoader.getItems().count-1 {
                let itemView = self.selectionCollectionView.item(at: i) as? CollectionViewItem
                if itemView != nil {
                    itemView!.check()
                }
            }
        }else {
            for i in 0...self.selectionViewController.imagesLoader.getItems().count-1 {
                let itemView = self.selectionCollectionView.item(at: i) as? CollectionViewItem
                if itemView != nil {
                    itemView!.uncheck()
                }
            }
        }
    }
    
    internal func hideSelectedImages() {
        guard self.selectionViewController.imagesLoader.getItems().count > 0 else {return}
        let accumulator:Accumulator = Accumulator(target: self.selectionViewController.imagesLoader.getItems().count, indicator: self.batchEditIndicator, suspended: false, lblMessage: nil)
        for item:ImageFile in self.selectionViewController.imagesLoader.getItems() {
            item.hide()
            let _ = accumulator.add()
        }
        //ModelStore.save()
        self.selectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        self.imagesLoader.reorganizeItems()
        self.collectionView.reloadData()
    }
    
    internal func visibleSelectedImages() {
        guard self.selectionViewController.imagesLoader.getItems().count > 0 else {return}
        let accumulator:Accumulator = Accumulator(target: self.selectionViewController.imagesLoader.getItems().count, indicator: self.batchEditIndicator, suspended: false, lblMessage: nil)
        for item:ImageFile in self.selectionViewController.imagesLoader.getItems() {
            item.show()
            let _ = accumulator.add()
        }
        //ModelStore.save()
        self.selectionViewController.imagesLoader.reorganizeItems()
        self.selectionCollectionView.reloadData()
        self.imagesLoader.reorganizeItems()
        self.collectionView.reloadData()
    }
    

}

