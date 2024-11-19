//
//  ViewController+Main+CollectionArea.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/29.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    internal func configureCollectionView() {
        
        self.initPaginationController()
        self.collectionPaginationController?.hide()
        self.collectionProgressIndicator.isHidden = true
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 180.0, height: 150.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.minimumLineSpacing = 2.0
        collectionView.collectionViewLayout = flowLayout
        view.wantsLayer = true
        collectionView.backgroundColors = [Colors.DeepDarkGray]
        collectionView.layer?.backgroundColor = Colors.DeepDarkGray.cgColor
        collectionView.layer?.borderColor = Colors.DeepDarkGray.cgColor
        
        imagesLoader.singleSectionMode = false
        imagesLoader.clean()
        collectionView.reloadData()
    }
    
    internal func disableCollectionViewControls() {
        self.collectionPaginationController?.disable()
//        self.btnFilter.isEnabled = false
        self.btnCombineDuplicates.isEnabled = false
    }
    
    
    internal func enableCollectionViewControls() {
        self.collectionPaginationController?.enable()
//        self.btnFilter.isEnabled = true
        self.btnCombineDuplicates.isEnabled = true
    }
    
    internal func selectImageFile(_ imageFile:ImageFile){
        self.selectedImageFile = imageFile.fileName
        //self.logger.log(.trace, "selected image file: \(filename)")
        //let url:URL = (self.selectedImageFolder?.url.appendingPathComponent(imageFile.fileName, isDirectory: false))!
        DispatchQueue.main.async {
            self.loadImageMetaAndPreview(imageFile: imageFile)
        }
    }
    
    // MARK: - COLLECTION DATA LOAD
    
    func loadCollection(imagesLoader: @escaping (() -> Void) ){
        TaskManager.loadingImagesCollection = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        DispatchQueue.global().async {
            self.collectionLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: {data in
                TaskManager.loadingImagesCollection = false
            })
            if self.imagesLoader.isLoading() {
                DispatchQueue.main.async {
                    self.indicatorMessage.stringValue = "Cancelling last request ..."
                }
                self.imagesLoader.cancel(onCancelled: {
                    imagesLoader()
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                })
            }else{
                imagesLoader()
                self.refreshCollectionView()
                TaskManager.loadingImagesCollection = false
            }
            
        }
    }
}
