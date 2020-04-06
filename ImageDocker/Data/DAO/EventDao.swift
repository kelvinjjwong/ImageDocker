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
    
    static let `default` = EventDao(EventDaoGRDB())
    
    func getOrCreateEvent(name:String) -> ImageEvent{
        return self.impl.getOrCreateEvent(name: name)
    }
    
    func getAllEvents() -> [ImageEvent] {
        return self.impl.getAllEvents()
    }
    
    func getEvents(byName names:String? = nil) -> [ImageEvent] {
        return self.impl.getEvents(byName: names)
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
}
