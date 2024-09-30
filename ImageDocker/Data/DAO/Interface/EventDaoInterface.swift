//
//  EventDaoInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/18.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

protocol EventDaoInterface {
    
    func getOrCreateEvent(name:String) -> ImageEvent
    
    func createEvent(event:ImageEvent) -> ExecuteState
    
    func updateEventDetail(event:ImageEvent) -> ExecuteState
    
    func getAllEvents() -> [ImageEvent]
    
    func getEvents(byName names:String?) -> [ImageEvent]
    
    func getEvents(categoriesQuotedSeparated:String?, exclude:Bool) -> [ImageEvent]
    
    func getEventCategories() -> [String]
    
    func getEventActivities() -> [String]
    
    func getEventActivities(category: String) -> [String]
    
    func getAllEvents(imageSource:[String]?, cameraModel:[String]?) -> [Event]
    
    func renameEvent(oldName:String, newName:String) -> ExecuteState
    
    func deleteEvent(name:String) -> ExecuteState
    
    func countImagesOfEvent(event:String) -> Int
    
    func importEventsFromImages()
    
    func getEventsByCategories(categories:[String]) -> [String]
    
    func getEventsByOwner(ownerId:String) -> [(String, String, String, String, String)]
    
    func getEvents(imageIds:[String]) -> [String]
    
    func getEvent(name:String) -> ImageEvent?
}
