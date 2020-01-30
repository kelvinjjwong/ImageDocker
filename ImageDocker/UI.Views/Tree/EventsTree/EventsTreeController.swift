//
//  EventsTreeController.swift
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
    
    func loadEventsToTreeFromDatabase(onCompleted:( () -> Void )? = nil) {
        print("\(Date()) LOAD EVENTS TREE: BEGIN")
        DispatchQueue.global().async {
            
            autoreleasepool(invoking: { () -> Void in
                let dates:[Row] = ModelStore.default.getAllEvents(imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                if dates.count > 0 {
                    let events:[Event] = Events().read(dates)
                    for event in events {
                        if event.event == ""{
                            continue
                        }
                        self.addEventTreeEntry(event: event)
                        for month in event.children {
                            self.addEventMonthTreeEntry(month: month)
                            for day in month.children {
                                self.addEventDayTreeEntry(day: day)
                            }
                        }
                    }
                    self.lastCheckEventChange = Date()
                    
                    print("\(Date()) LOAD EVENTS TREE: DONE")
                }else{
                    print("\(Date()) LOAD EVENTS TREE: NONE")
                    print("no events")
                }
                
                if onCompleted != nil {
                    onCompleted!()
                }
            })
        }
    }
    
    // MARK: REFRESH
    
    @objc func refreshEventTree() {
        //print("REFRESHING EVENT TREE at \(Date())")
        let count = self.eventItem().children.count
        // remove items in moments
        
        if count > 0 {
            for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
                //let index:Int = i - 1
                
                DispatchQueue.main.async {
                    self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                                inParent: self.eventItem(),
                                                withAnimation: NSTableView.AnimationOptions.slideUp)
                }
            }
            
            DispatchQueue.main.async {
                self.eventItem().children.removeAll()
            }
        }
        
        self.loadEventsToTreeFromDatabase(onCompleted: {
            DispatchQueue.main.async {
                print("\(Date()) RELOADING SOURCE LIST DATASET: BEGIN")
                print("EVENT MAJOR ENTRIES: \(self.eventItem().hasChildren()) \(self.eventItem().children?.count ?? 0)")
                self.sourceList.reloadData()
                print("\(Date()) RELOADING SOURCE LIST DATASET: DONE")
            }
        })
    }
    
    // MARK: ADD NODES
    
    fileprivate func addEventTreeEntry(event:Event){
        let collection:PhotoCollection = PhotoCollection(title: event.represent,
                                                         identifier: event.represent,
                                                         type: event.photoCount == 0 ? .userCreated : .library,
                                                         source: .event)
        collection.photoCount = event.photoCount
        collection.event = event.event
        collection.year = event.year
        collection.month = event.month
        collection.day = event.day
        self.showTreeNodeButton(collection: collection, image: moreHorizontalIcon)
        collection.buttonAction = { sender in 
            self.onTreeItemQuickLook(collection: collection, event: event.event)
        }
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: eventsIcon)
        
        // add tree relationship
        self.eventItem().addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.eventToCollection["\(event.id)"] = collection
        
        // for children to find parent
        self.parentsOfEventsTree["\(event.event)"] = item
        
        self.treeIdItems[event.id] = item
    }
    
    fileprivate func addEventMonthTreeEntry(month:Event){
        let collection:PhotoCollection = PhotoCollection(title: month.represent,
                                                         identifier: month.represent,
                                                         type: month.photoCount == 0 ? .userCreated : .library,
                                                         source: .event)
        collection.photoCount = month.photoCount
        collection.event = month.event
        collection.year = month.year
        collection.month = month.month
        self.showTreeNodeButton(collection: collection, image: moreHorizontalIcon)
        collection.buttonAction = { sender in
            self.onTreeItemQuickLook(collection: collection, event: month.event)
        }
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: eventsIcon)
        
        //print(self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)"])
        // add tree relationship
        self.parentsOfEventsTree["\(month.event)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.eventToCollection["\(month.id)"] = collection
        
        // for children to find parent
        self.parentsOfEventsTree["\(month.event)-\(month.year)-\(month.month)"] = item
        //print(self.parentsOfMomentsTreeGroupByPlace["\(month.place)-\(month.year)-\(month.month)"])
        
        self.treeIdItems[month.id] = item
        
    }
    
    fileprivate func addEventDayTreeEntry(day:Event){
        let collection:PhotoCollection = PhotoCollection(title: day.represent,
                                                         identifier: day.represent,
                                                         type: day.photoCount == 0 ? .userCreated : .library,
                                                         source: .event)
        collection.photoCount = day.photoCount
        collection.event = day.event
        collection.year = day.year
        collection.month = day.month
        collection.day = day.day
        collection.place = day.place
        self.showTreeNodeButton(collection: collection, image: moreHorizontalIcon)
        collection.buttonAction = { sender in 
            self.onTreeItemQuickLook(collection: collection, event: day.event)
        }
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: eventsIcon)
        
        //print(self.parentsOfMomentsTreeGroupByPlace["\(day.place)-\(day.year)-\(day.month)"])
        // add tree relationship
        self.parentsOfEventsTree["\(day.event)-\(day.year)-\(day.month)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.eventToCollection["\(day.id)"] = collection
        
        self.treeIdItems[day.id] = item
        
    }
    
    func reloadEventCollection(sender:NSButton) {
        if let collection = self.selectedCollection {
            self.createCollectionPaginationPopover()
            self.collectionPaginationViewController
                .initView(self.imagesLoader.lastRequest,
                          onCountTotal: {
                            return ModelStore.default.countPhotoFiles(year: collection.year, month: collection.month, day: collection.day,
                                                                      event: collection.event, place: collection.place,
                                                                      imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                },
                          onCountHidden: {
                            return ModelStore.default.countHiddenPhotoFiles(year: collection.year, month: collection.month, day: collection.day,
                                                                            event: collection.event, place: collection.place,
                                                                            imageSource: self.filterImageSource, cameraModel: self.filterCameraModel)
                },
                          onLoad: { pageSize, pageNumber in
                            self.selectEvent(collection, pageSize: pageSize, pageNumber: pageNumber)
                })
            
            let cellRect = sender.bounds
            self.collectionPaginationPopover?.show(relativeTo: cellRect, of: sender, preferredEdge: .minY)
        }
    }
    
    // MARK: CLICK ACTION
    
    func selectEvent(_ collection:PhotoCollection, pageSize:Int = 0, pageNumber:Int = 0) {
        //guard !self.scaningRepositories && !self.creatingRepository else {return}
        self.selectedCollection = collection
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
            if self.imagesLoader.isLoading() {
                DispatchQueue.main.async {
                    self.indicatorMessage.stringValue = "Cancelling last request ..."
                }
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.load(year: collection.year, month: collection.month, day: collection.day,
                                           event: collection.event,
                                           place: collection.place,
                                           filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel,
                                           indicator:self.collectionLoadingIndicator,
                                           pageSize: pageSize, pageNumber: pageNumber)
                    self.refreshCollectionView()
                    TaskManager.loadingImagesCollection = false
                })
            }else{
                self.imagesLoader.load(year: collection.year, month: collection.month, day: collection.day,
                                       event: collection.event,
                                       place: collection.place,
                                       filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel,
                                       indicator:self.collectionLoadingIndicator,
                                       pageSize: pageSize, pageNumber: pageNumber)
                self.refreshCollectionView()
                TaskManager.loadingImagesCollection = false
            }
            
        }
    }
    
}
