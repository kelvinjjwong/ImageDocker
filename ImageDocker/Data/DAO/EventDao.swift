//
//  EventDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class EventDao {
    
    private let impl:EventDaoInterface
    
    init(_ impl:EventDaoInterface){
        self.impl = impl
    }
    
    static var `default`:EventDao {
        return EventDao(EventDaoPostgresCK())
    }
    
    func getOrCreateEvent(name:String) -> ImageEvent{
        return self.impl.getOrCreateEvent(name: name)
    }
    
    func createEvent(event:ImageEvent) -> ExecuteState {
        return self.impl.createEvent(event: event)
    }
    
    func updateEventDetail(event:ImageEvent) -> ExecuteState {
        return self.impl.updateEventDetail(event: event)
    }
    
    func getAllEvents() -> [ImageEvent] {
        return self.impl.getAllEvents()
    }
    
    func getEvents(byName names:String? = nil) -> [ImageEvent] {
        return self.impl.getEvents(byName: names)
    }
    
    func getEvents(categoriesQuotedSeparated:String? = nil, exclude:Bool = false) -> [ImageEvent] {
        return self.impl.getEvents(categoriesQuotedSeparated: categoriesQuotedSeparated, exclude: exclude)
    }
    
    func getEventCategories() -> [String] {
        return self.impl.getEventCategories()
    }
    
    func getEventActivities() -> [String] {
        return self.impl.getEventActivities()
    }
    
    func getEventActivities(category: String) -> [String] {
        return self.impl.getEventActivities(category: category)
    }
    
    func getAllEvents(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Event] {
        return self.impl.getAllEvents(imageSource: imageSource, cameraModel: cameraModel)
    }
    
    func renameEvent(oldName:String, newName:String) -> ExecuteState{
        return self.impl.renameEvent(oldName: oldName, newName: newName)
    }
    
    func deleteEvent(name:String) -> ExecuteState{
        return self.impl.deleteEvent(name: name)
    }
    
    func countImagesOfEvent(event:String) -> Int {
        return self.impl.countImagesOfEvent(event:event)
    }
    
    func importEventsFromImages() {
        return self.impl.importEventsFromImages()
    }
    
    func getEventsByCategories(categories:[String]) -> [String] {
        return self.impl.getEventsByCategories(categories: categories)
    }
    
    func getEventsByOwner(ownerId:String) -> [(String, String, String, String, String)] {
        return self.impl.getEventsByOwner(ownerId: ownerId)
    }
    
    func getEventCategoriesByOwner(ownerId:String) -> [String] {
        return self.impl.getEventCategoriesByOwner(ownerId: ownerId)
    }
    
    func getEventsByOwnerAndCategory(ownerId:String, category:String) -> [(String, String, String, String, String)] {
        return self.impl.getEventsByOwnerAndCategory(ownerId: ownerId, category: category.replacingOccurrences(of: "'", with: "''"))
    }
    
    func getEvents(imageIds:[String]) -> [String] {
        return self.impl.getEvents(imageIds: imageIds)
    }
    
    func getEvent(name:String) -> ImageEvent? {
        return self.impl.getEvent(name: name)
    }
}
