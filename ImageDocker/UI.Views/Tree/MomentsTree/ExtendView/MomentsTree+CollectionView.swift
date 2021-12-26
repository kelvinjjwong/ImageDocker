//
//  MomentsTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    fileprivate func countImagesOfMoment(moment:Moment) -> Int {
        return ImageCountDao.default.countPhotoFiles(year: moment.year, month: moment.month, day: moment.day, place: nil, imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
    }
    
    fileprivate func countHiddenImagesOfMoment(moment:Moment) -> Int {
        return ImageCountDao.default.countHiddenPhotoFiles(year: moment.year, month: moment.month, day: moment.day, place: nil, imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
    }
    
    func reloadMomentCollection(moment:Moment, sender:NSButton) {
        self.createCollectionPaginationPopover()
        self.collectionPaginationViewController
            .initView(self.imagesLoader.lastRequest,
                      onCountTotal: {
                        return self.countImagesOfMoment(moment: moment)
            },
                      onCountHidden: {
                        return self.countHiddenImagesOfMoment(moment: moment)
            },
                      onLoad: { pageSize, pageNumber in
                        self.loadCollectionByMoment(moment:moment, pageSize: pageSize, pageNumber: pageNumber)
            },
                      onPaginationStateChanges: { currentPage, totalPages in
                      self.changePaginationState(currentPage: currentPage, totalPages: totalPages)
                        
            })
        
        let cellRect = sender.bounds
        self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
    }
    
    func loadCollectionByMoment(moment:Moment, pageSize:Int = 0, pageNumber:Int = 0){
        self.selectedMoment = moment

        var totalRecords = self.countImagesOfMoment(moment: moment)
//        self.logger.log("total records including hidden: \(totalRecords)")
        if self.chbShowHidden.state == .off {
            totalRecords -= self.countHiddenImagesOfMoment(moment: moment)
        }
//        self.logger.log("total records excluding hidden: \(totalRecords)")
        self.changePaginationState(currentPage: pageNumber, pageSize: pageSize, totalRecords: totalRecords)
        
        self.loadCollectionByMoment(year: moment.year, month: moment.month, day: moment.day, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    func loadCollectionByMoment(year:Int, month:Int, day:Int, pageSize:Int = 0, pageNumber:Int = 0){
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
//        self.logger.log("select \(year) \(month) \(day)")
        
        loadCollection {
            self.imagesLoader.load(
                year: year,
                month: month,
                day: day,
                place: nil,
                filterImageSource: self.filterImageSource,
                filterCameraModel: self.filterCameraModel,
                indicator:self.collectionLoadingIndicator,
                pageSize: pageSize,
                pageNumber: pageNumber)
        }
    }
    
}
