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
    
    func loadEventsToTreeFromDatabase() {
        let dates:[Row] = ModelStore.default.getAllEvents(imageSource: filterImageSource, cameraModel: filterCameraModel)
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
        }else{
            print("no events")
        }
    }
    
    // MARK: REFRESH
    
    func refreshEventTree() {
        //print("REFRESHING MOMENT TREE at \(Date())")
        let count = self.eventItem().children.count
        // remove items in moments
        for _ in (count > 1 ? 1 : count)...(count > 1 ? count : 1) {
            //let index:Int = i - 1
            self.sourceList.removeItems(at: NSIndexSet(index: 0) as IndexSet,
                                        inParent: self.eventItem(),
                                        withAnimation: NSTableView.AnimationOptions.slideUp)
        }
        self.eventItem().children.removeAll()
        self.loadEventsToTreeFromDatabase()
        self.sourceList.reloadData()
    }
    
    // MARK: ADD NODES
    
    func addEventTreeEntry(event:Event){
        let collection:PhotoCollection = PhotoCollection(title: event.represent,
                                                         identifier: event.represent,
                                                         type: event.photoCount == 0 ? .userCreated : .library,
                                                         source: .event)
        collection.photoCount = event.photoCount
        collection.event = event.event
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: eventsIcon)
        
        // add tree relationship
        self.eventItem().addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.eventToCollection["\(event.id)"] = collection
        
        // for children to find parent
        self.parentsOfEventsTree["\(event.event)"] = item
        
        self.treeIdItems[event.id] = item
    }
    
    func addEventMonthTreeEntry(month:Event){
        let collection:PhotoCollection = PhotoCollection(title: month.represent,
                                                         identifier: month.represent,
                                                         type: month.photoCount == 0 ? .userCreated : .library,
                                                         source: .event)
        collection.photoCount = month.photoCount
        collection.event = month.event
        collection.year = month.year
        collection.month = month.month
        
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
    
    func addEventDayTreeEntry(day:Event){
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
        
        let item:PXSourceListItem = PXSourceListItem(representedObject: collection, icon: eventsIcon)
        
        //print(self.parentsOfMomentsTreeGroupByPlace["\(day.place)-\(day.year)-\(day.month)"])
        // add tree relationship
        self.parentsOfEventsTree["\(day.event)-\(day.year)-\(day.month)"]?.addChildItem(item)
        
        // avoid collection object to be purged from memory
        self.eventToCollection["\(day.id)"] = collection
        
        self.treeIdItems[day.id] = item
        
    }
    
    // MARK: CLICK ACTION
    
    func selectEvent(_ collection:PhotoCollection) {
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
            if self.imagesLoader.isLoading() {
                self.imagesLoader.cancel(onCancelled: {
                    self.imagesLoader.load(year: collection.year, month: collection.month, day: collection.day, event: collection.event, place: collection.place, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel, indicator:self.collectionLoadingIndicator)
                    self.refreshCollectionView()
                })
            }else{
                self.imagesLoader.load(year: collection.year, month: collection.month, day: collection.day, event: collection.event, place: collection.place, filterImageSource: self.filterImageSource, filterCameraModel: self.filterCameraModel, indicator:self.collectionLoadingIndicator)
                self.refreshCollectionView()
            }
            
        }
    }
    
}
