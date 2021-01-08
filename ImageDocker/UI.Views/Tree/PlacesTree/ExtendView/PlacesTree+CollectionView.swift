//
//  PlacesTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {

    func reloadPlaceCollection(moment:Moment, sender:NSButton) {
        self.createCollectionPaginationPopover()
        self.collectionPaginationViewController
            .initView(self.imagesLoader.lastRequest,
                      onCountTotal: {
                        return ImageCountDao.default.countPhotoFiles(year: moment.year, month: moment.month, day: moment.day,
                                                                  ignoreDate: (moment.year == 0),
                                                                  country: moment.countryData == "" ? (moment.gov == "未知国家" ? "" : moment.gov) : moment.countryData,
                                                                  province: moment.provinceData,
                                                                  city: moment.cityData,
                                                                  place: moment.placeData == "" ? (moment.place == "未知地点" ? "" : moment.place) : moment.placeData,
                                                                  imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
            },
                      onCountHidden: {
                        return ImageCountDao.default.countHiddenPhotoFiles(year: moment.year, month: moment.month, day: moment.day,
                                                                        ignoreDate: (moment.year == 0),
                                                                        country: moment.countryData == "" ? (moment.gov == "未知国家" ? "" : moment.gov) : moment.countryData,
                                                                        province: moment.provinceData,
                                                                        city: moment.cityData,
                                                                        place: moment.placeData == "" ? (moment.place == "未知地点" ? "" : moment.place) : moment.placeData,
                                                                        imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
            },
                      onLoad: { pageSize, pageNumber in
                        self.loadCollectionByPlace(moment:moment, pageSize: pageSize, pageNumber: pageNumber)
            })
        
        let cellRect = sender.bounds
        self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .maxX)
    }
    
    // MARK: CLICK ACTION
    
    func loadCollectionByPlace(moment:Moment, pageSize:Int = 0, pageNumber:Int = 0){
        print("SELECTED PLACE COLLECTION:")
        print("\(moment.countryData) | \(moment.provinceData) | \(moment.cityData) | \(moment.placeData)")
            
        self.selectedMoment = moment
        
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
