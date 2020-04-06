//
//  PlaceDaoInterface.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/18.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

protocol PlaceDaoInterface {
    
    func getOrCreatePlace(name:String, location:Location) -> ImagePlace
    
    func getPlace(name:String) -> ImagePlace?
    
    func getAllPlaces() -> [ImagePlace]
    
    func getPlaces(byName names:String?) -> [ImagePlace]
    
    func renamePlace(oldName:String, newName:String) -> ExecuteState
    
    func updatePlace(name:String, location:Location) -> ExecuteState
    
    func deletePlace(name:String) -> ExecuteState
}
