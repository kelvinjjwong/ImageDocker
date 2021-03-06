//
//  EventsTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    fileprivate func countImagesOfEvent(moment:Moment) -> Int {
        return ImageCountDao.default.countPhotoFiles(year: moment.year,
                                                     month: moment.month,
                                                     day: moment.day,
                                                     event: moment.event,
                                                     place: moment.place,
                                                     imageSource: self.filterImageSource,
                                                     cameraModel: self.filterCameraModel
        )
    }
    
    fileprivate func countHiddenImagesOfEvent(moment:Moment) -> Int {
        return ImageCountDao.default.countHiddenPhotoFiles(year: moment.year, month: moment.month, day: moment.day,
        event: moment.event, place: moment.place,
        imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
    }
    
    func reloadEventCollection(moment:Moment, sender:NSButton) {
        self.createCollectionPaginationPopover()
        self.collectionPaginationViewController
            .initView(self.imagesLoader.lastRequest,
                      onCountTotal: {
                        return self.countImagesOfEvent(moment: moment)
            },
                      onCountHidden: {
                        return self.countHiddenImagesOfEvent(moment: moment)
            },
                      onLoad: { pageSize, pageNumber in
                        self.loadCollectionByEvent(moment:moment, pageSize: pageSize, pageNumber: pageNumber)
            },
                      onPaginationStateChanges: { currentPage, totalPages in
                      self.changePaginationState(currentPage: currentPage, totalPages: totalPages)
                        
            })
        
        let cellRect = sender.bounds
        self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
    }
    
    // MARK: CLICK ACTION
    
    func loadCollectionByEvent(moment:Moment, pageSize:Int = 0, pageNumber:Int = 0) {
        self.selectedMoment = moment
        
        var totalRecords = self.countImagesOfEvent(moment: moment)
        if self.chbShowHidden.state == .off {
            totalRecords -= self.countHiddenImagesOfEvent(moment: moment)
        }
        self.changePaginationState(currentPage: pageNumber, pageSize: pageSize, totalRecords: totalRecords)
        
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
