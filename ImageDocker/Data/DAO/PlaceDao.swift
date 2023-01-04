//
//  PlaceDao.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class PlaceDao {
    
    private let impl:PlaceDaoInterface
    
    init(_ impl:PlaceDaoInterface){
        self.impl = impl
    }
    
    static var `default`:PlaceDao {
        let location = DatabaseBackupController.databaseLocation()
        if location == "local" {
            return PlaceDao(PlaceDaoGRDB())
        }else{
            return PlaceDao(PlaceDaoPostgresCK())
        }
    }
    
    func getOrCreatePlace(name:String, location:Location) -> ImagePlace{
        return self.impl.getOrCreatePlace(name: name, location: location)
    }
    
    func getPlace(name:String) -> ImagePlace? {
        return self.impl.getPlace(name: name)
    }
    
    func getAllPlaces() -> [ImagePlace] {
        return self.impl.getAllPlaces()
    }
    
    func getPlaces(byName names:String? = nil) -> [ImagePlace] {
        return self.impl.getPlaces(byName: names)
    }
    
    func renamePlace(oldName:String, newName:String) -> ExecuteState{
        return self.impl.renamePlace(oldName: oldName, newName: newName)
    }
    
    func updatePlace(name:String, location:Location) -> ExecuteState{
        return self.impl.updatePlace(name: name, location: location)
    }
    
    func deletePlace(name:String) -> ExecuteState{
        return self.impl.deletePlace(name: name)
    }
}
