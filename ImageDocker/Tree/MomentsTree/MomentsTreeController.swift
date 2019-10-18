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
    
    func loadMomentsToTreeFromDatabase(filterImageSource:[String]? = nil, filterCameraModel:[String]? = nil, onCompleted:( () -> Void )? = nil){
        print("\(Date()) LOAD MOMENTS TREE: BEGIN")
        DispatchQueue.global().async {
            
            autoreleasepool(invoking: { () -> Void in
                
                let dates:[Row] = ModelStore.default.getAllDates(imageSource: filterImageSource, cameraModel: filterCameraModel)
                if dates.count > 0 {
                    let moments:[Moment] = Moments().readMoments(dates)
                    
                    let duplicates:Duplicates = ModelStore.default.getDuplicatePhotos()
                    
                    for year in moments {
                        
                        var duplicateInYear:Bool = false
                        if duplicates.years.contains(year.year) {
                            duplicateInYear = true
                        }
                        year.hasDuplicates = duplicateInYear
                        
                        self.addMomentsTreeYearEntry(year: year)
                        for month in year.children {
                            
                            var duplicateInMonth:Bool = false
                            if duplicates.yearMonths.contains(month.year * 1000 + month.month) {
                                duplicateInMonth = true
                            }
                            month.hasDuplicates = duplicateInMonth
                            
                            self.addMomentsTreeMonthEntry(month: month)
                            for day in month.children {
                                
                                var duplicateInDay:Bool = false
                                if duplicates.yearMonthDays.contains(day.year * 100000 + day.month * 100 + day.day) {
                                    duplicateInDay = true
                                }
                                day.hasDuplicates = duplicateInDay
                                
                                self.addMomentsTreeDayEntry(day: day)
                            }
                        }
                    }
                    self.lastCheckPhotoTakenDateChange = Date()
                    print("\(Date()) LOAD MOMENTS TREE: DONE")
                    
                }else{
                    print("\(Date()) LOAD MOMENTS TREE: NONE")
                    print("no dates")
                }
                
                if onCompleted != nil {
                    onCompleted!()
                }
            })
        }
    }
    
    // MARK: REFRESH
    
    @objc func refreshMomentTree() {
        
        //print("REFRESHING MOMENT TREE at \(Date())")
        let count = self.momentItem().children.count
        // remove items in moments
        if count > 0 {
            for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
                //let index:Int = i - 1
                
                DispatchQueue.main.async {
                    self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                                inParent: self.momentItem(),
                                                withAnimation: NSTableView.AnimationOptions.slideUp)
                }
            }
            
            DispatchQueue.main.async {
                self.momentItem().children.removeAll()
            }
        }
        
        self.loadMomentsToTreeFromDatabase(filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel, onCompleted: {
            DispatchQueue.main.async {
                print("\(Date()) RELOADING SOURCE LIST DATASET: BEGIN")
                print("EVENT MOMENT ENTRIES: \(self.momentItem().hasChildren()) \(self.momentItem().children?.count ?? 0)")
                self.sourceList.reloadData()
                print("\(Date()) RELOADING SOURCE LIST DATASET: DONE")
            }
        })
        
    }
    
    // MARK: ADD NODES
    
    fileprivate func addMomentsTreeYearEntry(year:Moment){
        let collection:PhotoCollection = PhotoCollection(title: year.represent,
                                                         identifier: year.id,
                                                         type: year.photoCount == 0 ? .userCreated : .library,
                                                         source: .moment)
        collection.photoCount = year.photoCount
        collection.year = year.year
        collection.month = year.month
        collection.day = year.day
        self.showTreeNodeButton(collection: collection, image: NSImage(named: .slideshowTemplate))
        collection.buttonAction = { sender in
            self.onTreeItemQuickLook(collection: collection)
        }
        
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
        self.showTreeNodeButton(collection: collection, image: NSImage(named: .slideshowTemplate))
        collection.buttonAction = { sender in
            self.onTreeItemQuickLook(collection: collection)
        }
        
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
        self.showTreeNodeButton(collection: collection, image: NSImage(named: .slideshowTemplate))
        collection.buttonAction = { sender in 
            self.onTreeItemQuickLook(collection: collection)
        }
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: photosIcon)
        
        // add tree relationship
        self.parentsOfMomentsTree["\(day.year)-\(day.month)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollection["\(day.id)"] = collection
        
        self.treeIdItems[day.id] = item
    }
    
    
    
    func reloadMomentCollection(sender:NSButton) {
        if let collection = self.selectedCollection {
            self.createCollectionPaginationPopover()
            self.collectionPaginationViewController
                .initView(self.imagesLoader.lastRequest,
                          onCountTotal: {
                            return ModelStore.default.countPhotoFiles(year: collection.year, month: collection.month, day: collection.day, place: nil, imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                },
                          onCountHidden: {
                            return ModelStore.default.countHiddenPhotoFiles(year: collection.year, month: collection.month, day: collection.day, place: nil, imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                },
                          onLoad: { pageSize, pageNumber in
                            self.selectMomentsTreeEntry(collection, pageSize: pageSize, pageNumber: pageNumber)
                })
            
            let cellRect = sender.bounds
            self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .minY)
        }
    }
    
    // MARK: CLICK ACTION
    
    func selectMomentsTreeEntry(_ collection:PhotoCollection, pageSize:Int = 0, pageNumber:Int = 0){
        self.selectedCollection = collection
        self.selectMomentsTreeEntry(year: collection.year, month: collection.month, day: collection.day, pageSize: pageSize, pageNumber: pageNumber)
    }
    
    func selectMomentsTreeEntry(year:Int, month:Int, day:Int, pageSize:Int = 0, pageNumber:Int = 0){
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
        print("select \(year) \(month) \(day)")
        
        self.scaningRepositories = true
        
        self.imagesLoader.clean()
        collectionView.reloadData()
        
        self.imagesLoader.showHidden = self.chbShowHidden.state == .on
        
        DispatchQueue.global().async {
            self.collectionLoadingIndicator = Accumulator(target: 1000, indicator: self.collectionProgressIndicator, suspended: true, lblMessage:self.indicatorMessage, onCompleted: {data in
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
                    self.imagesLoader.load(year: year, month: month, day: day, place: nil, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel, indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber)
                    self.refreshCollectionView()
                })
            }else{
                self.imagesLoader.load(year: year, month: month, day: day, place: nil, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel,  indicator:self.collectionLoadingIndicator, pageSize: pageSize, pageNumber: pageNumber)
                self.refreshCollectionView()
            }
            
        }
    }
    
    
}
