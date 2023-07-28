//
//  PlacesTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {
    
    fileprivate func countImagesOfPlace(moment:Moment) -> Int {
        return ImageCountDao.default.countPhotoFiles(year: moment.year,
                                                    month: moment.month,
                                                    day: moment.day,
                                                    ignoreDate: (moment.year == 0),
                                                    country: moment.countryData == "" ? (moment.gov == "未知国家" ? "" : moment.gov) : moment.countryData,
                                                    province: moment.provinceData,
                                                    city: moment.cityData,
                                                    place: moment.placeData == "" ? (moment.place == "未知地点" ? "" : moment.place) : moment.placeData,
                                                    imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
    }
    
    fileprivate func countHiddenImagesOfPlace(moment:Moment) -> Int {
        return ImageCountDao.default.countHiddenPhotoFiles(year: moment.year, month: moment.month, day: moment.day,
                                                            ignoreDate: (moment.year == 0),
                                                            country: moment.countryData == "" ? (moment.gov == "未知国家" ? "" : moment.gov) : moment.countryData,
                                                            province: moment.provinceData,
                                                            city: moment.cityData,
                                                            place: moment.placeData == "" ? (moment.place == "未知地点" ? "" : moment.place) : moment.placeData,
                                                            imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
    }

    func reloadPlaceCollection(moment:Moment, sender:NSButton) {
        self.createCollectionPaginationPopover()
        self.collectionPaginationViewController
            .initView(self.imagesLoader.lastRequest,
                      onCountTotal: {
                        return self.countImagesOfPlace(moment: moment)
            },
                      onCountHidden: {
                        return self.countHiddenImagesOfPlace(moment: moment)
            },
                      onLoad: { pageSize, pageNumber in
                        self.loadCollectionByPlace(moment:moment, pageSize: pageSize, pageNumber: pageNumber)
            },
                      onPaginationStateChanges: { currentPage, totalPages in
                      self.changePaginationState(currentPage: currentPage, totalPages: totalPages)
                        
            })
        
        let cellRect = sender.bounds
        self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
    }
    
    // MARK: CLICK ACTION
    
    func loadCollectionByPlace(moment:Moment, pageSize:Int = 0, pageNumber:Int = 0){
//        self.logger.log("SELECTED PLACE COLLECTION:")
//        self.logger.log("\(moment.countryData) | \(moment.provinceData) | \(moment.cityData) | \(moment.placeData)")
            
        self.selectedMoment = moment
        
        var totalRecords = self.countImagesOfPlace(moment: moment)
//        if self.chbShowHidden.state == .off {
//            totalRecords -= self.countHiddenImagesOfPlace(moment: moment)
//        }
        self.changePaginationState(currentPage: pageNumber, pageSize: pageSize, totalRecords: totalRecords)
        
        loadCollection {
            self.imagesLoader.load(
                year: moment.year,
                month: moment.month,
                day: moment.day,
                ignoreDate: (moment.year == 0),
                country: moment.countryData,
                province: moment.provinceData,
                city: moment.cityData,
                place: moment.placeData,
                filterImageSource: self.filterImageSource,
                filterCameraModel: self.filterCameraModel,
                indicator:self.collectionLoadingIndicator,
                pageSize: pageSize,
                pageNumber: pageNumber)
        }
    }
    
    
}
