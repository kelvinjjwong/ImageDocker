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
                        return ImageCountDao.default.countPhotoFiles(year: moment.year, month: moment.month, day: moment.day,
                                                                  event: moment.event, place: moment.place,
                                                                  imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
            },
                      onCountHidden: {
                        return ImageCountDao.default.countHiddenPhotoFiles(year: moment.year, month: moment.month, day: moment.day,
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
        
        loadCollection {
            self.imagesLoader.load(year: moment.year, month: moment.month, day: moment.day,
                                   event: moment.event,
                                   place: moment.place,
                                   filterImageSource: self.filterImageSource,
                                   filterCameraModel: self.filterCameraModel,
                                   indicator:self.collectionLoadingIndicator,
                                   pageSize: pageSize,
                                   pageNumber: pageNumber)
        }
    }
    
}
