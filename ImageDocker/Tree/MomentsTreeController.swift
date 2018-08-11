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
    
    func loadMomentsToTreeFromDatabase(filterImageSource:[String]? = nil, filterCameraModel:[String]? = nil){
        let dates:[Row] = ModelStore.default.getAllDates(imageSource: filterImageSource, cameraModel: filterCameraModel)
        if dates.count > 0 {
            let moments:[Moment] = Moments().readMoments(dates)
            
            let duplicates:Duplicates = ModelStore.default.getDuplicatePhotos()
            
            for year in moments {
                
                var duplicateInYear:Bool = false
                if duplicates.duplicates.index(where: {$0.year == year.year}) != nil {
                    duplicateInYear = true
                }
                year.hasDuplicates = duplicateInYear
                
                self.addMomentsTreeYearEntry(year: year)
                for month in year.children {
                    
                    var duplicateInMonth:Bool = false
                    if duplicates.duplicates.index(where: {$0.year == month.year && $0.month == month.month}) != nil {
                        duplicateInMonth = true
                    }
                    month.hasDuplicates = duplicateInMonth
                    
                    self.addMomentsTreeMonthEntry(month: month)
                    for day in month.children {
                        
                        var duplicateInDay:Bool = false
                        if duplicates.duplicates.index(where: {$0.year == day.year && $0.month == day.month && $0.day == day.day}) != nil {
                            duplicateInDay = true
                        }
                        day.hasDuplicates = duplicateInDay
                        
                        self.addMomentsTreeDayEntry(day: day)
                    }
                }
            }
            self.lastCheckPhotoTakenDateChange = Date()
            
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
        self.loadMomentsToTreeFromDatabase(filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel)
        self.sourceList.reloadData()
        
    }
    
    // MARK: ADD NODES
    
    fileprivate func addMomentsTreeYearEntry(year:Moment){
        let collection:PhotoCollection = PhotoCollection(title: year.represent,
                                                         identifier: year.id,
                                                         type: year.photoCount == 0 ? .userCreated : .library,
                                                         source: .moment)
        collection.photoCount = year.photoCount
        collection.year = year.year
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        // add tree relationship
        self.momentItem().addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollection["\(year.id)"] = collection
        
        // for children to find parent
        self.parentsOfMomentsTree["\(year.year)"] = item
        
        self.treeIdItems[year.id] = item
    }
    
    fileprivate func addMomentsTreeMonthEntry(month:Moment){
        let collection:PhotoCollection = PhotoCollection(title: month.represent,
                                                         identifier: month.id,
                                                         type: month.photoCount == 0 ? .userCreated : .library,
                                                         source: .moment)
        collection.photoCount = month.photoCount
        collection.year = month.year
        collection.month = month.month
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        // add tree relationship
        self.parentsOfMomentsTree["\(month.year)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollection["\(month.id)"] = collection
        
        // for children to find parent
        self.parentsOfMomentsTree["\(month.year)-\(month.month)"] = item
        
        
        self.treeIdItems[month.id] = item
    }
    
    fileprivate func addMomentsTreeDayEntry(day:Moment){
        let collection:PhotoCollection = PhotoCollection(title: day.represent,
                                                         identifier: day.id,
                                                         type: day.photoCount == 0 ? .userCreated : .library,
                                                         source: .moment)
        collection.photoCount = day.photoCount
        collection.year = day.year
        collection.month = day.month
        collection.day = day.day
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        // add tree relationship
        self.parentsOfMomentsTree["\(day.year)-\(day.month)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollection["\(day.id)"] = collection
        
        self.treeIdItems[day.id] = item
    }
    
    // MARK: CLICK ACTION
    
    func selectMomentsTreeEntry(_ collection:PhotoCollection){
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
                    self.imagesLoader.load(year: collection.year, month: collection.month, day: collection.day, place: nil, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel, indicator:self.collectionLoadingIndicator)
                    self.refreshCollectionView()
                })
            }else{
                self.imagesLoader.load(year: collection.year, month: collection.month, day: collection.day, place: nil, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel,  indicator:self.collectionLoadingIndicator)
                self.refreshCollectionView()
            }
            
        }
    }
}
