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
        return ImageCountDao.default.countPhotoFiles(year: moment.year, month: moment.month, day: moment.day, place: nil)
    }
    
    fileprivate func countHiddenImagesOfMoment(moment:Moment) -> Int {
        return ImageCountDao.default.countHiddenPhotoFiles(year: moment.year, month: moment.month, day: moment.day, place: nil)
    }
    
    // 1
    func loadCollectionByMoment(moment:Moment, pageSize:Int = 0, pageNumber:Int = 0){
        self.logger.log(.trace, "loadCollectionByMoment(moment, pageSize, pageNumber)")
        self.selectedMoment = moment
        
        self.collectionPaginationController?.initPageSize(pageSize: pageSize)
        self.collectionPaginationController?.initPageNumber(pageNumber: pageNumber)
        self.collectionPaginationController?.initCounter(onCountTotal: {
            return self.countImagesOfMoment(moment: moment)
        }, onCountHidden: {
            return self.countHiddenImagesOfMoment(moment: moment)
        })
        self.collectionPaginationController?.initLoader(onLoad: { pageSize, pageNumber in
            self.loadCollectionByMoment(year: moment.year, month: moment.month, day: moment.day, pageSize: pageSize, pageNumber: pageNumber)
        })
        self.collectionPaginationController?.load()
    }
    
    // 2
    func loadCollectionByMoment(year:Int, month:Int, day:Int, pageSize:Int = 0, pageNumber:Int = 0){
        self.logger.log(.trace, "loadCollectionByMoment(year, month, day, pageSize, pageNumber)")
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
//        self.logger.log(.trace, "select \(year) \(month) \(day)")
        
        loadCollection {
            self.imagesLoader.load(
                year: year,
                month: month,
                day: day,
                place: nil,
                indicator:self.collectionLoadingIndicator,
                pageSize: pageSize,
                pageNumber: pageNumber)
        }
    }
    
}
