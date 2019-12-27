//
//  PlaceDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class PlaceDao {
    
    func getOrCreatePlace(name:String, location:Location) -> ImagePlace{
        return ModelStore.default.getOrCreatePlace(name: name, location: location)
    }
    
    func getPlace(name:String) -> ImagePlace? {
        return ModelStore.default.getPlace(name: name)
    }
    
    func getAllPlaces() -> [ImagePlace] {
        return ModelStore.default.getAllPlaces()
    }
    
    func getPlaces(byName names:String? = nil) -> [ImagePlace] {
        return ModelStore.default.getPlaces(byName: names)
    }
    
    func renamePlace(oldName:String, newName:String) -> ExecuteState{
        return ModelStore.default.renamePlace(oldName: oldName, newName: newName)
    }
    
    func updatePlace(name:String, location:Location) -> ExecuteState{
        return ModelStore.default.updatePlace(name: name, location: location)
    }
    
    func deletePlace(name:String) -> ExecuteState{
        return ModelStore.default.deletePlace(name: name)
    }
}
