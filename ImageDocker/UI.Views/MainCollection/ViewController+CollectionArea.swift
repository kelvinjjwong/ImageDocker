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
        imagesLoader.showHidden = false
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
    
    internal func switchShowHideState() {
        self.imagesLoader.showHidden = false // self.chbShowHidden.state == .on
        
        TaskManager.loadingImagesCollection = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        DispatchQueue.global().async {
            if self.imagesLoader.isLoading(){
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.reload()
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                })
            }else{
                self.imagesLoader.reload()
                self.refreshCollectionView()
                TaskManager.loadingImagesCollection = false
            }
            
        }
    }
    
    internal func previousPageCollection() {
        print("## previousPageCollection")
//        self.collectionPaginationController?.changePaginationState(currentPage: self.currentPageOfCollection - 1, totalPages: self.totalPagesOfCollection)
//        self.loadCollection {
//            self.imagesLoader.previousPage()
//        }
    }
    
    internal func nextPageCollection() {
        print("## nextPageCollection")
//        self.collectionPaginationController?.changePaginationState(currentPage: self.currentPageOfCollection + 1, totalPages: self.totalPagesOfCollection)
//        self.loadCollection {
//            self.imagesLoader.nextPage()
//        }
    }
    
    internal func refreshCollection(_ sender: NSButton) {
        self.logger.log("refreshCollection(sender) clicked")
        if self.imagesLoader.lastRequest.loadSource == .repository && self.imagesLoader.lastRequest.pageNumber > 0 && self.imagesLoader.lastRequest.pageSize > 0 {
//            self.logger.log("clicked repo collection reload button")
            self.reloadCollectionFromImageContainer(sender: sender)
        }else if self.imagesLoader.lastRequest.loadSource == .moment && self.imagesLoader.lastRequest.pageNumber > 0 && self.imagesLoader.lastRequest.pageSize > 0 {
            if self.imagesLoader.lastRequest.place == nil {
                if let moment = self.selectedMoment {
                    self.reloadMomentCollection(moment: moment, sender: sender)
                }else{
//                    self.logger.log("no selected moment")
                }
            }else{
                if let moment = self.selectedMoment {
                    self.reloadPlaceCollection(moment: moment, sender: sender)
                }else{
//                    self.logger.log("no selected moment")
                }
            }
        }else if self.imagesLoader.lastRequest.loadSource == .event && self.imagesLoader.lastRequest.pageNumber > 0 && self.imagesLoader.lastRequest.pageSize > 0 {
            if let moment = self.selectedMoment {
                self.reloadEventCollection(moment: moment, sender: sender)
            }else{
//                self.logger.log("no selected moment")
            }
        }else{
            self.refreshCollection()
        }
    }
    
    internal func selectImageFile(_ imageFile:ImageFile){
        self.selectedImageFile = imageFile.fileName
        //self.logger.log("selected image file: \(filename)")
        //let url:URL = (self.selectedImageFolder?.url.appendingPathComponent(imageFile.fileName, isDirectory: false))!
        DispatchQueue.main.async {
            self.loadImageMetaAndPreview(imageFile: imageFile)
        }
    }
    
    internal func refreshCollection(){
        self.logger.log("refreshCollection() clicked")
        DispatchQueue.global().async {
            if self.imagesLoader.isLoading() {
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.reload()
                    self.refreshCollectionView()
                })
            }else {
                self.imagesLoader.reload()
                self.refreshCollectionView()
            }
            
        }
    }
    
    // MARK: - COLLECTION DATA LOAD
    
    func loadCollection(imagesLoader: @escaping (() -> Void) ){
        TaskManager.loadingImagesCollection = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        self.imagesLoader.showHidden = false // self.chbShowHidden.state == .on
        
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
