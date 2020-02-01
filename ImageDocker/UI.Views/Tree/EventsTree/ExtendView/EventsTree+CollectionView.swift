//
//  EventsTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    func reloadEventCollection(sender:NSButton) {
        if let collection = self.selectedCollection {
            self.createCollectionPaginationPopover()
            self.collectionPaginationViewController
                .initView(self.imagesLoader.lastRequest,
                          onCountTotal: {
                            return ModelStore.default.countPhotoFiles(year: collection.year, month: collection.month, day: collection.day,
                                                                      event: collection.event, place: collection.place,
                                                                      imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                },
                          onCountHidden: {
                            return ModelStore.default.countHiddenPhotoFiles(year: collection.year, month: collection.month, day: collection.day,
                                                                            event: collection.event, place: collection.place,
                                                                            imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                },
                          onLoad: { pageSize, pageNumber in
                            self.loadCollectionByEvent(collection, pageSize: pageSize, pageNumber: pageNumber)
                })
            
            let cellRect = sender.bounds
            self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .minY)
        }
    }
    
    // MARK: CLICK ACTION
    
    func loadCollectionByEvent(_ collection:PhotoCollection, pageSize:Int = 0, pageNumber:Int = 0) {
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
        self.selectedCollection = collection
        TaskManager.loadingImagesCollection = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        self.imagesLoader.showHidden = self.chbShowHidden.state == .on
        
        DispatchQueue.global().async {
            self.collectionLoadingIndicator = Accumulator(target: collection.photoCount, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: {data in
                TaskManager.loadingImagesCollection = false
                //                let total:Int = data["total"] ?? 0
                //                let hidden:Int = data["hidden"] ?? 0
                //                let message:String = "\(total) images, \(hidden) hidden"
                //                self.indicatorMessage.stringValue = message
            })
            if self.imagesLoader.isLoading() {
                DispatchQueue.main.async {
                    self.indicatorMessage.stringValue = "Cancelling last request ..."
                }
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.load(year: collection.year, month: collection.month, day: collection.day,
                                           event: collection.event,
                                           place: collection.place,
                                           filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel,
                                           indicator:self.collectionLoadingIndicator,
                                           pageSize: pageSize, pageNumber: pageNumber)
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                })
            }else{
                self.imagesLoader.load(year: collection.year, month: collection.month, day: collection.day,
                                       event: collection.event,
                                       place: collection.place,
                                       filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel,
                                       indicator:self.collectionLoadingIndicator,
                                       pageSize: pageSize, pageNumber: pageNumber)
                self.refreshCollectionView()
                TaskManager.loadingImagesCollection = false
            }
            
        }
    }
}
