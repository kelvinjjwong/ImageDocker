//
//  MomentsTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    func reloadMomentCollection(sender:NSButton) {
        if let collection = self.selectedCollection {
            self.createCollectionPaginationPopover()
            self.collectionPaginationViewController
                .initView(self.imagesLoader.lastRequest,
                          onCountTotal: {
                            return ModelStore.default.countPhotoFiles(year: collection.year, month: collection.month, day: collection.day, place: nil, imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                },
                          onCountHidden: {
                            return ModelStore.default.countHiddenPhotoFiles(year: collection.year, month: collection.month, day: collection.day, place: nil, imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                },
                          onLoad: { pageSize, pageNumber in
                            self.loadCollectionByMoment(collection, pageSize: pageSize, pageNumber: pageNumber)
                })
            
            let cellRect = sender.bounds
            self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .minY)
        }
    }
    
    func loadCollectionByMoment(_ collection:PhotoCollection, pageSize:Int = 0, pageNumber:Int = 0){
        self.selectedCollection = collection
        self.loadCollectionByMoment(year: collection.year, month: collection.month, day: collection.day, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    func loadCollectionByMoment(year:Int, month:Int, day:Int, pageSize:Int = 0, pageNumber:Int = 0){
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
        print("select \(year) \(month) \(day)")
        
        TaskManager.loadingImagesCollection = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        self.imagesLoader.showHidden = self.chbShowHidden.state == .on
        
        DispatchQueue.global().async {
            self.collectionLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: {data in
                TaskManager.loadingImagesCollection = false
                //                let total:Int = data["total"] ?? 0
                //                let hidden:Int = data["hidden"] ?? 0
                //                let message:String = "\(total) images, \(hidden) hidden"
                //                self.indicatorMessage.stringValue = message
            })
            //print("GETTING COLLECTION \(collection.year) \(collection.month) \(collection.day) \(collection.place ?? "")")
            if self.imagesLoader.isLoading() {
                DispatchQueue.main.async {
                    self.indicatorMessage.stringValue = "Cancelling last request ..."
                }
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.load(year: year, month: month, day: day, place: nil, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel, indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber)
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                })
            }else{
                self.imagesLoader.load(year: year, month: month, day: day, place: nil, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel,  indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber)
                self.refreshCollectionView()
                TaskManager.loadingImagesCollection = false
            }
            
        }
    }
    
}
