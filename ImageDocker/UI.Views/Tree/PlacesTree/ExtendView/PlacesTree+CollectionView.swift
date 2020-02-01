//
//  PlacesTree+CollectionView.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/2/1.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Cocoa

extension ViewController {

    func reloadPlaceCollection(sender:NSButton) {
        if let collection = self.selectedCollection {
            self.createCollectionPaginationPopover()
            self.collectionPaginationViewController
                .initView(self.imagesLoader.lastRequest,
                          onCountTotal: {
                            return ModelStore.default.countPhotoFiles(year: collection.year, month: collection.month, day: collection.day,
                                                                      ignoreDate: !collection.isDateEntry,
                                                                      country: collection.countryData,
                                                                      province: collection.provinceData,
                                                                      city: collection.cityData,
                                                                      place: collection.placeData,
                                                                      imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                },
                          onCountHidden: {
                            return ModelStore.default.countHiddenPhotoFiles(year: collection.year, month: collection.month, day: collection.day,
                                                                            ignoreDate: !collection.isDateEntry,
                                                                            country: collection.countryData,
                                                                            province: collection.provinceData,
                                                                            city: collection.cityData,
                                                                            place: collection.placeData,
                                                                            imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                },
                          onLoad: { pageSize, pageNumber in
                            self.loadCollectionByPlace(collection, pageSize: pageSize, pageNumber: pageNumber)
                })
            
            let cellRect = sender.bounds
            self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .minY)
        }
    }
    
    // MARK: CLICK ACTION
    
    func loadCollectionByPlace(_ collection:PhotoCollection, pageSize:Int = 0, pageNumber:Int = 0){
        // disable click event on gov nodes
//        if collection.placeData == "" && collection.countryData == "" && collection.provinceData == "" && collection.cityData == "" {
//            print("SELECTED GOV COLLECTION:")
//            print("\(collection.countryData) | \(collection.provinceData) | \(collection.cityData) | \(collection.placeData)")
//            return
//        }
        print("SELECTED PLACE COLLECTION:")
        print("\(collection.countryData) | \(collection.provinceData) | \(collection.cityData) | \(collection.placeData)")
        
        self.selectedCollection = collection
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
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
            //print("GETTING COLLECTION \(collection.year) \(collection.month) \(collection.day) \(collection.place ?? "")")
            if self.imagesLoader.isLoading() {
                DispatchQueue.main.async {
                    self.indicatorMessage.stringValue = "Cancelling last request ..."
                }
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.load(
                        year: collection.year,
                        month: collection.month,
                        day: collection.day,
                        ignoreDate: !collection.isDateEntry,
                        country: collection.countryData,
                        province: collection.provinceData,
                        city: collection.cityData,
                        place: collection.placeData,
                        filterImageSource: self.filterImageSource,
                        filterCameraModel: self.filterCameraModel,
                        indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber)
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                })
            }else{
                self.imagesLoader.load(
                    year: collection.year,
                    month: collection.month,
                    day: collection.day,
                    ignoreDate: !collection.isDateEntry,
                    country: collection.countryData,
                    province: collection.provinceData,
                    city: collection.cityData,
                    place: collection.placeData,
                    filterImageSource: self.filterImageSource,
                    filterCameraModel: self.filterCameraModel,
                    indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber)
                self.refreshCollectionView()
                TaskManager.loadingImagesCollection = false
            }
            
        }
    }
}
