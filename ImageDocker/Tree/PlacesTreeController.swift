//
//  PlacesTreeController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/11.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

import Cocoa
import PXSourceList
import GRDB


extension ViewController {
    
    // MARK: DATA SOURCE
    
    func loadPlacesToTreeFromDatabase(filterImageSource:[String]? = nil, filterCameraModel:[String]? = nil){
        let dates:[Row] = ModelStore.default.getAllPlacesAndDates(imageSource: filterImageSource, cameraModel: filterCameraModel)
        //print("!!! \(dates.count)")
        if dates.count > 0 {
            let places:[Moment] = Moments().readPlaces(dates)
            
            let duplicates:Duplicates = ModelStore.default.getDuplicatePhotos()
            
            for gov in places {
                self.addPlacesTreeGovEntry(place: gov)
                
                //print("GOV \(gov.gov)")
                for place in gov.children {
                    if place.place == "" {
                        continue
                    }
                    //print("     PLACE \(place.place)")
                    self.addPlacesTreePlaceEntry(place: place)
                    for year in place.children {
                        //print("          YEAR \(year.year)")
                        var duplicateInYear:Bool = false
                        if duplicates.years.contains(year.year) {
                            duplicateInYear = true
                        }
                        year.hasDuplicates = duplicateInYear
                        
                        self.addPlacesTreeYearEntry(year: year)
                        for month in year.children {
                            //print("              MONTH \(month.month)")
                            var duplicateInMonth:Bool = false
                            if duplicates.yearMonths.contains(month.year * 1000 + month.month) {
                                duplicateInMonth = true
                            }
                            month.hasDuplicates = duplicateInMonth
                            
                            self.addPlacesTreeMonthEntry(month: month)
                            for day in month.children {
                                //print("                   DAY \(day.day)")
                                var duplicateInDay:Bool = false
                                if duplicates.yearMonthDays.contains(day.year * 100000 + day.month * 100 + day.day) {
                                    duplicateInDay = true
                                }
                                day.hasDuplicates = duplicateInDay
                                
                                self.addPlacesTreeDayEntry(day: day)
                            }
                        }
                    }
                }
            }
            
            
            
            self.lastCheckLocationChange = Date()
                
            
        }else{
            print("no dates")
        }
    }
    
    // MARK: REFRESH
    
    @objc func refreshLocationTree() {
        //print("REFRESHING LOCATION TREE at \(Date())")
        let count = self.placeItem().children.count
        // remove item in places
        
        if count > 0 {
            for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
                //let index:Int = i - 1
                
                DispatchQueue.main.async {
                    self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                                inParent: self.placeItem(),
                                                withAnimation: NSTableView.AnimationOptions.slideUp)
                }
            }
            
            DispatchQueue.main.async {
                self.placeItem().children.removeAll()
            }
        }
        
        DispatchQueue.main.async {
            self.loadPlacesToTreeFromDatabase(filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel)
            self.sourceList.reloadData()
        }
    }
    
    // MARK: ADD NODES
    
    fileprivate func addPlacesTreeGovEntry(place:Moment){
        let collection:PhotoCollection = PhotoCollection(title: place.gov,
                                                         identifier: place.id,
                                                         type: place.photoCount == 0 ? .userCreated : .library,
                                                         source: .place)
        collection.photoCount = place.photoCount
        collection.year = place.year
        collection.month = place.month
        collection.day = place.day
        collection.gov = place.gov
        collection.isDateEntry = false
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: placesIcon)
        
        // add tree relationship
        self.placeItem().addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollectionGroupByPlace["\(place.id)"] = collection
        
        // for children to find parent
        self.parentsOfMomentsTreeGroupByPlace["\(place.gov)"] = item
        
        self.treeIdItems[place.id] = item
    }
    
    fileprivate func addPlacesTreePlaceEntry(place:Moment){
        let collection:PhotoCollection = PhotoCollection(title: place.represent,
                                                         identifier: place.id,
                                                         type: place.photoCount == 0 ? .userCreated : .library,
                                                         source: .place)
        collection.photoCount = place.photoCount
        collection.place = place.place
        collection.countryData = place.countryData
        collection.provinceData = place.provinceData
        collection.cityData = place.cityData
        collection.placeData = place.placeData
        collection.isDateEntry = false
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: placesIcon)
        
        // add tree relationship
        self.parentsOfMomentsTreeGroupByPlace["\(place.gov)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollectionGroupByPlace["\(place.id)"] = collection
        
        // for children to find parent
        self.parentsOfMomentsTreeGroupByPlace["\(place.gov)-\(place.place)"] = item
        
        self.treeIdItems[place.id] = item
    }
    
    fileprivate func addPlacesTreeYearEntry(year:Moment){
        let collection:PhotoCollection = PhotoCollection(title: year.represent,
                                                         identifier: year.id,
                                                         type: year.photoCount == 0 ? .userCreated : .library,
                                                         source: .place)
        collection.photoCount = year.photoCount
        collection.year = year.year
        collection.countryData = year.countryData
        collection.provinceData = year.provinceData
        collection.cityData = year.cityData
        collection.placeData = year.placeData
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        collection.place = year.place
        
        // add tree relationship
        self.parentsOfMomentsTreeGroupByPlace["\(year.gov)-\(year.place)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollectionGroupByPlace["\(year.id)"] = collection
        
        // for children to find parent
        self.parentsOfMomentsTreeGroupByPlace["\(year.gov)-\(year.place)-\(year.year)"] = item
        
        self.treeIdItems[year.id] = item
    }
    
    fileprivate func addPlacesTreeMonthEntry(month:Moment){
        let collection:PhotoCollection = PhotoCollection(title: month.represent,
                                                         identifier: month.id,
                                                         type: month.photoCount == 0 ? .userCreated : .library,
                                                         source: .place)
        collection.photoCount = month.photoCount
        collection.year = month.year
        collection.month = month.month
        collection.countryData = month.countryData
        collection.provinceData = month.provinceData
        collection.cityData = month.cityData
        collection.placeData = month.placeData
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        collection.place = month.place
        //print(self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)"])
        // add tree relationship
        self.parentsOfMomentsTreeGroupByPlace["\(month.gov)-\(month.place)-\(month.year)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollectionGroupByPlace["\(month.id)"] = collection
        
        // for children to find parent
        self.parentsOfMomentsTreeGroupByPlace["\(month.gov)-\(month.place)-\(month.year)-\(month.month)"] = item
        //print(self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)-\(month.month)"])
        
        self.treeIdItems[month.id] = item
    }
    
    fileprivate func addPlacesTreeDayEntry(day:Moment){
        let collection:PhotoCollection = PhotoCollection(title: day.represent,
                                                         identifier: day.id,
                                                         type: day.photoCount == 0 ? .userCreated : .library,
                                                         source: .place)
        collection.photoCount = day.photoCount
        collection.year = day.year
        collection.month = day.month
        collection.day = day.day
        collection.countryData = day.countryData
        collection.provinceData = day.provinceData
        collection.cityData = day.cityData
        collection.placeData = day.placeData
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        collection.place = day.place
        //print(self.parentsOfMomentsTreeGroupByPlace["\(day.place)-\(day.year)-\(day.month)"])
        // add tree relationship
        self.parentsOfMomentsTreeGroupByPlace["\(day.gov)-\(day.place)-\(day.year)-\(day.month)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollectionGroupByPlace["\(day.id)"] = collection
        
        
        self.treeIdItems[day.id] = item
    }
    
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
                            self.selectMomentsTreeEntry(collection, pageSize: pageSize, pageNumber: pageNumber)
                })
            
            let cellRect = sender.bounds
            self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .minY)
        }
    }
    
    // MARK: CLICK ACTION
    
    func selectPlacesTreeEntry(_ collection:PhotoCollection, pageSize:Int = 0, pageNumber:Int = 0){
        if collection.placeData == "" && collection.countryData == "" && collection.provinceData == "" && collection.cityData == "" {
            return
        }
        self.selectedCollection = collection
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
        self.scaningRepositories = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        self.imagesLoader.showHidden = self.chbShowHidden.state == .on
        
        DispatchQueue.global().async {
            self.collectionLoadingIndicator = Accumulator(target: collection.photoCount, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: {data in
                self.scaningRepositories = false
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
            }
            
        }
    }
}
