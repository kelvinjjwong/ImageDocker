//
//  ModelStore+ImagePlace.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class PlaceDaoGRDB : PlaceDaoInterface {
    
    // MARK: - CREATE
    
    func getOrCreatePlace(name:String, location:Location) -> ImagePlace{
        var place:ImagePlace?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                place = try ImagePlace.fetchOne(db, key: name)
            }
            if place == nil {
                try db.write { db in
                    place = ImagePlace(
                        name: name,
                        country:             location.country,
                        province:            location.province,
                        city:                location.city,
                        district:            location.district,
                        businessCircle:      location.businessCircle,
                        street:              location.street,
                        address:             location.address,
                        addressDescription:  location.addressDescription,
                        latitude:            location.coordinate?.latitude.description ?? "",
                        latitudeBD:          location.coordinateBD?.latitude.description ?? "",
                        longitude:           location.coordinate?.longitude.description ?? "",
                        longitudeBD:         location.coordinateBD?.longitude.description ?? "" )
                    try place?.save(db)
                }
            }
        }catch{
            print(error)
        }
        return place!
    }
    
    // MARK: - GETTER
    
    func getPlace(name:String) -> ImagePlace? {
        var place:ImagePlace?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                place = try ImagePlace.fetchOne(db, key: name)
            }
        }catch{
            print(error)
        }
        return place
    }
    
    // MARK: - SEARCH
    
    func getAllPlaces() -> [ImagePlace] {
        var places:[ImagePlace] = []
        
        do {
            let dbPool = ModelStoreGRDB.sharedDBPool()
            try dbPool.read { db in
                places = try ImagePlace.fetchAll(db)
            }
        }catch{
            print(error)
        }
        return places
    }
    
    func getPlaces(byName names:String? = nil) -> [ImagePlace] {
        var result:[ImagePlace] = []
        var stmt = ""
        if let names = names {
            let keys:[String] = names.components(separatedBy: " ")
            stmt = SQLHelper.likeArray(field: "name", array: keys)
        }
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                if stmt != "" {
                    result = try ImagePlace.filter(stmt).order(Column("name").asc).fetchAll(db)
                }else{
                    result = try ImagePlace.order(Column("name").asc).fetchAll(db)
                }
            }
        }catch{
            print(error)
        }
        return result
    }
    
    // MARK: - UPDATE
    
    
    func renamePlace(oldName:String, newName:String) -> ExecuteState{
        print("trying to rename place from \(oldName) to \(newName)")
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                if let _ = try ImagePlace.fetchOne(db, key: newName){ // already exists new name, just delete old one
                    //
                }else {
                    if var place = try ImagePlace.fetchOne(db, key: oldName) { // does not exist new name, create new name, and delete old one
                        place.name = newName
                        try place.save(db)
                    }
                }
                try db.execute(sql: "UPDATE Image SET assignPlace=? WHERE assignPlace=?", arguments: StatementArguments([newName, oldName]))
                try ImagePlace.deleteOne(db, key: oldName)  // delete old one at last
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    func updatePlace(name:String, location:Location) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                if var place = try ImagePlace.fetchOne(db, key: name) {
                    place.country = location.country
                    place.province = location.province
                    place.city = location.city
                    place.businessCircle = location.businessCircle
                    place.district = location.district
                    place.street = location.street
                    place.address = location.address
                    place.addressDescription = location.addressDescription
                    place.latitude = location.coordinate?.latitude.description ?? ""
                    place.longitude = location.coordinate?.longitude.description ?? ""
                    place.latitudeBD = location.coordinateBD?.latitude.description ?? ""
                    place.longitudeBD = location.coordinateBD?.longitude.description ?? ""
                    try place.save(db)
                    try db.execute(sql: "UPDATE Image SET AssignCountry=?,AssignProvince=?,AssignCity=?,AssignBusinessCircle=?,AssignDistrict=?,AssignStreet=?,AssignAddress=?,AssignAddressDescription=?,Latitude=?,longitude=?,latitudeBD=?,longitudeBD=? WHERE AssignPlace=?",
                                   arguments: StatementArguments([
                                    location.country,
                                    location.province,
                                    location.city,
                                    location.businessCircle,
                                    location.district,
                                    location.street,
                                    location.address,
                                    location.addressDescription,
                                    location.coordinate?.latitude.description ?? "",
                                    location.coordinate?.longitude.description ?? "",
                                    location.coordinateBD?.latitude.description ?? "",
                                    location.coordinateBD?.longitude.description ?? "",
                                    name]))
                }
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
    
    // MARK: - DELETE
    
    func deletePlace(name:String) -> ExecuteState{
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.write { db in
                let _ = try ImagePlace.deleteOne(db, key: name)
            }
        }catch{
            return SQLHelper.errorState(error)
        }
        return .OK
    }
}
