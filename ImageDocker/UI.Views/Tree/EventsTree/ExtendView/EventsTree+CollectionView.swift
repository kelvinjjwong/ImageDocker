//
//  EventsTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    func reloadEventCollection(moment:Moment, sender:NSButton) {
        self.createCollectionPaginationPopover()
        self.collectionPaginationViewController
            .initView(self.imagesLoader.lastRequest,
                      onCountTotal: {
                        return ModelStore.default.countPhotoFiles(year: moment.year, month: moment.month, day: moment.day,
                                                                  event: moment.event, place: moment.place,
                                                                  imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
            },
                      onCountHidden: {
                        return ModelStore.default.countHiddenPhotoFiles(year: moment.year, month: moment.month, day: moment.day,
                                                                        event: moment.event, place: moment.place,
                                                                        imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
            },
                      onLoad: { pageSize, pageNumber in
                        self.loadCollectionByEvent(moment:moment, pageSize: pageSize, pageNumber: pageNumber)
            })
        
        let cellRect = sender.bounds
        self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
    }
    
    // MARK: CLICK ACTION
    
    func loadCollectionByEvent(moment:Moment, pageSize:Int = 0, pageNumber:Int = 0) {
        self.selectedMoment = moment
        TaskManager.loadingImagesCollection = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        self.imagesLoader.showHidden = self.chbShowHidden.state == .on
        
        DispatchQueue.global().async {
            self.collectionLoadingIndicator = Accumulator(target: moment.photoCount, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: {data in
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
                    self.imagesLoader.load(year: moment.year, month: moment.month, day: moment.day,
                                           event: moment.event,
                                           place: moment.place,
                                           filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel,
                                           indicator:self.collectionLoadingIndicator,
                                           pageSize: pageSize, pageNumber: pageNumber)
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                })
            }else{
                self.imagesLoader.load(year: moment.year, month: moment.month, day: moment.day,
                                       event: moment.event,
                                       place: moment.place,
                                       filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel,
                                       indicator:self.collectionLoadingIndicator,
                                       pageSize: pageSize, pageNumber: pageNumber)
                self.refreshCollectionView()
                TaskManager.loadingImagesCollection = false
            }
            
        }
    }
    
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
