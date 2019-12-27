//
//  EventDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class EventDao {
    
    func getOrCreateEvent(name:String) -> ImageEvent{
        return ModelStore.default.getOrCreateEvent(name: name)
    }
    
    func getAllEvents() -> [ImageEvent] {
        return ModelStore.default.getAllEvents()
    }
    
    func getEvents(byName names:String? = nil) -> [ImageEvent] {
        return ModelStore.default.getEvents(byName: names)
    }
    
    func getAllEvents(imageSource:[String]? = nil, cameraModel:[String]? = nil) -> [Event] {
        let result = ModelStore.default.getAllEvents(imageSource: imageSource, cameraModel: cameraModel)
        return Events().read(result)
    }
    
    func renameEvent(oldName:String, newName:String) -> ExecuteState{
        return ModelStore.default.renameEvent(oldName: oldName, newName: newName)
    }
    
    func deleteEvent(name:String) -> ExecuteState{
        return ModelStore.default.deleteEvent(name: name)
    }
}
