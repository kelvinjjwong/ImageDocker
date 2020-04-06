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
    
    func getAllEvents() -> [ImageEvent]
    
    func getEvents(byName names:String?) -> [ImageEvent]
    
    func getAllEvents(imageSource:[String]?, cameraModel:[String]?) -> [Event]
    
    func renameEvent(oldName:String, newName:String) -> ExecuteState
    
    func deleteEvent(name:String) -> ExecuteState
}
