//
//  EventsTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class EventsTreeDataSource : TreeDataSource {
    
    func convertEventsToTreeCollections(_ moments:[Moment]) -> [TreeCollection] {
        var events:[TreeCollection] = []
        for moment in moments {
            let lv1data = moment.eventCategoryData
            let lv2data = moment.eventData
            var lv1 = lv1data
            var lv2 = lv2data
            
            if lv1data == "" {
                lv1 = "未归类事件"
            }
            if lv2data == "" {
                lv2 = "未分配事件"
            }
            
            moment.eventCategory = lv1
            moment.event = lv2
            
            //print("Got event \(lv1) -> \(lv2)")
            
            var lv1Entry:TreeCollection
            var lv2Entry:TreeCollection
            
            if events.firstIndex(where: {$0.name == lv1}) == nil {
                lv1Entry = TreeCollection(lv1, id: "cat_\(lv1)", object: Moment(eventCategory: lv1))
                lv1Entry.expandable = true
                events.append(lv1Entry)
            }else{
                lv1Entry = events.first(where: {$0.name == lv1})!
            }
            
            if lv1Entry.children.firstIndex(where: {$0.name == lv2}) == nil {
                lv2Entry = TreeCollection(lv2, id: "cat_\(lv1)_event_\(lv2)", object:moment)
                lv2Entry.expandable = true
                lv1Entry.addChild(collection: lv2Entry)
            }else{
                //print("ERROR: duplicated event entry \(lv1) -> \(lv2)")
            }
        }
        
        // recount images from event-entries for each category
        for category in events {
            if let moment = category.relatedObject as? Moment {
                var imageCount = 0
                for event in category.children {
                    if let m = event.relatedObject as? Moment {
                        imageCount += m.photoCount
                    }
                }
                moment.photoCount = imageCount
                category.relatedObject = moment
            }
        }
        
        return events
        
    }
    
    func convertDateToTreeCollection(_ moment:Moment) -> TreeCollection {
        let node = TreeCollection(moment.represent, id: moment.id, object: moment)
        if moment.year == 0 && moment.month == 0 && moment.day == 0 {
            node.expandable = false
        }else if moment.day == 0 {
            node.expandable = true
        }
        return node
    }
    
    func loadChildren(_ collection: TreeCollection?, condition:SearchCondition?) -> ([TreeCollection], String?) {
        
        if collection == nil {
            let moments = ImageSearchDao.default.getImageEvents(condition: condition)
            return (self.convertEventsToTreeCollections(moments), nil)
        }else{
            if let parentNode = collection, let parent = parentNode.relatedObject as? Moment {
                if parent.event != "" {
                    var nodes:[TreeCollection] = []
                    let moments:[Moment] = ImageSearchDao.default.getMomentsByEvent(event: parent.event, category: parent.eventCategory, year: parent.year, month: parent.month, condition: condition)
                    for moment in moments {
                        let node = self.convertDateToTreeCollection(moment)
                        nodes.append(node)
                    }
                    return (nodes, nil)
                }else{
                    print("parent event is empty")
                }
                
            }else{
                print("EventsTreeDS: no related object")
            }
        }
        return ([], nil)
    }
    
    func findNode(path: String) -> TreeCollection? {
        return nil
    }
    
    func filter(keyword: String) {
        
    }
    
    func findNode(keyword: String) -> TreeCollection? {
        return nil
    }
    

}
