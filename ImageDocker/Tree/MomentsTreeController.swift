//
//  MomentsTreeController.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/8/6.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import PXSourceList
import GRDB


extension ViewController {
    
    // MARK: DATA SOURCE
    
    func loadMomentsToTreeFromDatabase(groupByPlace:Bool = false, filterImageSource:[String]? = nil, filterCameraModel:[String]? = nil){
        let dates:[Row] = ModelStore.default.getAllDates(groupByPlace: groupByPlace, imageSource: filterImageSource, cameraModel: filterCameraModel)
        if dates.count > 0 {
            let moments:[Moment] = Moments().read(dates, groupByPlace: groupByPlace)
            
            let duplicates:Duplicates = ModelStore.default.getDuplicatePhotos()
            
            if groupByPlace {
                for place in moments {
                    if place.place == "" {
                        continue
                    }
                    //print("PLACE \(place.place)")
                    self.addMomentPlaceTreeEntry(place: place)
                    for year in place.children {
                        //print("     YEAR \(year.year)")
                        var duplicateInYear:Bool = false
                        if duplicates.duplicates.index(where: {$0.year == year.year}) != nil {
                            duplicateInYear = true
                        }
                        year.hasDuplicates = duplicateInYear
                        
                        self.addMomentYearTreeEntry(year: year, groupByPlace: true)
                        for month in year.children {
                            //print("         MONTH \(month.month)")
                            var duplicateInMonth:Bool = false
                            if duplicates.duplicates.index(where: {$0.year == month.year && $0.month == month.month}) != nil {
                                duplicateInMonth = true
                            }
                            month.hasDuplicates = duplicateInMonth
                            
                            self.addMomentMonthTreeEntry(month: month, groupByPlace: true)
                            for day in month.children {
                                //print("              DAY \(day.day)")
                                var duplicateInDay:Bool = false
                                if duplicates.duplicates.index(where: {$0.year == day.year && $0.month == day.month && $0.day == day.day}) != nil {
                                    duplicateInDay = true
                                }
                                day.hasDuplicates = duplicateInDay
                                
                                self.addMomentDayTreeEntry(day: day, groupByPlace: true)
                            }
                        }
                    }
                }
                
                self.lastCheckLocationChange = Date()
                
            }else{
                for year in moments {
                    
                    var duplicateInYear:Bool = false
                    if duplicates.duplicates.index(where: {$0.year == year.year}) != nil {
                        duplicateInYear = true
                    }
                    year.hasDuplicates = duplicateInYear
                    
                    self.addMomentYearTreeEntry(year: year, groupByPlace: false)
                    for month in year.children {
                        
                        var duplicateInMonth:Bool = false
                        if duplicates.duplicates.index(where: {$0.year == month.year && $0.month == month.month}) != nil {
                            duplicateInMonth = true
                        }
                        month.hasDuplicates = duplicateInMonth
                        
                        self.addMomentMonthTreeEntry(month: month, groupByPlace: false)
                        for day in month.children {
                            
                            var duplicateInDay:Bool = false
                            if duplicates.duplicates.index(where: {$0.year == day.year && $0.month == day.month && $0.day == day.day}) != nil {
                                duplicateInDay = true
                            }
                            day.hasDuplicates = duplicateInDay
                            
                            self.addMomentDayTreeEntry(day: day, groupByPlace: false)
                        }
                    }
                }
                self.lastCheckPhotoTakenDateChange = Date()
            }
        }else{
            print("no dates")
        }
    }
    
    // MARK: REFRESH
    
    func refreshMomentTree() {
        
        
        //print("REFRESHING MOMENT TREE at \(Date())")
        let count = self.momentItem().children.count
        // remove items in moments
        for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
            //let index:Int = i - 1
            self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                        inParent: self.momentItem(),
                                        withAnimation: NSTableView.AnimationOptions.slideUp)
        }
        self.momentItem().children.removeAll()
        self.loadMomentsToTreeFromDatabase(groupByPlace: false, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel)
        self.sourceList.reloadData()
        
        
    }
    
    func refreshLocationTree() {
        //print("REFRESHING LOCATION TREE at \(Date())")
        let count = self.placeItem().children.count
        // remove item in places
        for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
            //let index:Int = i - 1
            self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                        inParent: self.placeItem(),
                                        withAnimation: NSTableView.AnimationOptions.slideUp)
        }
        self.placeItem().children.removeAll()
        self.loadMomentsToTreeFromDatabase(groupByPlace: true, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel)
        self.sourceList.reloadData()
    }
    
    // MARK: ADD NODES
    
    func addMomentPlaceTreeEntry(place:Moment){
        let collection:PhotoCollection = PhotoCollection(title: place.represent,
                                                         identifier: place.id,
                                                         type: place.photoCount == 0 ? .userCreated : .library,
                                                         source: .place)
        collection.photoCount = place.photoCount
        collection.place = place.place
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: placesIcon)
        
        // add tree relationship
        self.placeItem().addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollectionGroupByPlace["\(place.id)"] = collection
        
        // for children to find parent
        self.parentsOfMomentsTreeGroupByPlace["\(place.place)"] = item
        
        self.treeIdItems[place.id] = item
    }
    
    func addMomentYearTreeEntry(year:Moment, groupByPlace:Bool = false){
        if !groupByPlace {
            //print("YEAR \(year.represent) \(year.year) , count \(year.photoCount)")
        }
        let collection:PhotoCollection = PhotoCollection(title: year.represent,
                                                         identifier: year.id,
                                                         type: year.photoCount == 0 ? .userCreated : .library,
                                                         source: groupByPlace ? .place : .moment)
        collection.photoCount = year.photoCount
        collection.year = year.year
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        if groupByPlace {
            collection.place = year.place
            
            // add tree relationship
            self.parentsOfMomentsTreeGroupByPlace["\(year.place)"]?.addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollectionGroupByPlace["\(year.id)"] = collection
            
            // for children to find parent
            self.parentsOfMomentsTreeGroupByPlace["\(year.place)-\(year.year)"] = item
            
        }else{
            // add tree relationship
            self.momentItem().addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollection["\(year.id)"] = collection
            
            // for children to find parent
            self.parentsOfMomentsTree["\(year.year)"] = item
        }
        
        self.treeIdItems[year.id] = item
    }
    
    func addMomentMonthTreeEntry(month:Moment, groupByPlace:Bool = false){
        if !groupByPlace {
            //print("MONTH \(month.represent) \(month.year) , count \(month.photoCount)")
        }
        let collection:PhotoCollection = PhotoCollection(title: month.represent,
                                                         identifier: month.id,
                                                         type: month.photoCount == 0 ? .userCreated : .library,
                                                         source: groupByPlace ? .place : .moment)
        collection.photoCount = month.photoCount
        collection.year = month.year
        collection.month = month.month
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        if groupByPlace  {
            collection.place = month.place
            //print(self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)"])
            // add tree relationship
            self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)"]?.addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollectionGroupByPlace["\(month.id)"] = collection
            
            // for children to find parent
            self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)-\(month.month)"] = item
            //print(self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)-\(month.month)"])
            
        }else {
            // add tree relationship
            self.parentsOfMomentsTree["\(month.year)"]?.addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollection["\(month.id)"] = collection
            
            // for children to find parent
            self.parentsOfMomentsTree["\(month.year)-\(month.month)"] = item
        }
        
        self.treeIdItems[month.id] = item
    }
    
    func addMomentDayTreeEntry(day:Moment, groupByPlace:Bool = false){
        let collection:PhotoCollection = PhotoCollection(title: day.represent,
                                                         identifier: day.id,
                                                         type: day.photoCount == 0 ? .userCreated : .library,
                                                         source: groupByPlace ? .place : .moment)
        collection.photoCount = day.photoCount
        collection.year = day.year
        collection.month = day.month
        collection.day = day.day
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        if groupByPlace  {
            collection.place = day.place
            //print(self.parentsOfMomentsTreeGroupByPlace["\(day.place)-\(day.year)-\(day.month)"])
            // add tree relationship
            self.parentsOfMomentsTreeGroupByPlace["\(day.place)-\(day.year)-\(day.month)"]?.addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollectionGroupByPlace["\(day.id)"] = collection
            
        }else {
            
            // add tree relationship
            self.parentsOfMomentsTree["\(day.year)-\(day.month)"]?.addChildItem(item)
            
            // avoid collection object to be purged from memory
            self.momentToCollection["\(day.id)"] = collection
        }
        
        self.treeIdItems[day.id] = item
    }
    
    // MARK: CLICK ACTION
    
    func selectMoment(_ collection:PhotoCollection, groupByPlace:Bool = false){
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
        self.scaningRepositories = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
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
                    self.imagesLoader.load(year: collection.year, month: collection.month, day: collection.day, place: groupByPlace ? collection.place : nil, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel, indicator:self.collectionLoadingIndicator)
                    self.refreshCollectionView()
                })
            }else{
                self.imagesLoader.load(year: collection.year, month: collection.month, day: collection.day, place: groupByPlace ? collection.place : nil, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel,  indicator:self.collectionLoadingIndicator)
                self.refreshCollectionView()
            }
            
        }
    }
}
