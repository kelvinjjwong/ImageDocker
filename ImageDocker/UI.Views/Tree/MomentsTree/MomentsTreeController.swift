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
        self.showTreeNodeButton(collection: collection, image: Icons.moreHorizontal)
        collection.buttonAction = { sender in
            self.onTreeItemQuickLook(collection: collection)
        }
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: Icons.photos)
        
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
        self.showTreeNodeButton(collection: collection, image: Icons.moreHorizontal)
        collection.buttonAction = { sender in
            self.onTreeItemQuickLook(collection: collection)
        }
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: Icons.photos)
        
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
        self.showTreeNodeButton(collection: collection, image: Icons.moreHorizontal)
        collection.buttonAction = { sender in 
            self.onTreeItemQuickLook(collection: collection)
        }
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: Icons.photos)
        
        // add tree relationship
        self.parentsOfMomentsTree["\(day.year)-\(day.month)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.momentToCollection["\(day.id)"] = collection
        
        self.treeIdItems[day.id] = item
    }
    
}
