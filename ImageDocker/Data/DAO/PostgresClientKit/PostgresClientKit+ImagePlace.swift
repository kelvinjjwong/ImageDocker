//
//  PostgresClientKit+ImagePlace.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

class PlaceDaoPostgresCK : PlaceDaoInterface {
    
    func getOrCreatePlace(name: String, location: Location) -> ImagePlace {
        let db = PostgresConnection.database()
        if let place = ImagePlace.fetchOne(db, parameters: ["name": name]) {
            return place
        }else{
            let place = ImagePlace(
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
            place.save(db)
            return place
        }
    }
    
    func getPlace(name: String) -> ImagePlace? {
        let db = PostgresConnection.database()
        return ImagePlace.fetchOne(db, parameters: ["name" : name])
    }
    
    func getAllPlaces() -> [ImagePlace] {
        let db = PostgresConnection.database()
        return ImagePlace.fetchAll(db)
    }
    
    func getPlaces(byName names: String?) -> [ImagePlace] {
        let db = PostgresConnection.database()
        var whereStmt = ""
        if let names = names {
            let keys:[String] = names.components(separatedBy: " ")
            whereStmt = SQLHelper.likeArray(field: "name", array: keys)
        }
        return ImagePlace.fetchAll(db, where: whereStmt, orderBy: "name")
    }
    
    func renamePlace(oldName: String, newName: String) -> ExecuteState {
        let db = PostgresConnection.database()
        if !ImagePlace.exists(db, parameters: ["name" : newName]) {
            if let place = ImagePlace.fetchOne(db, parameters: ["name": oldName]) {
                place.name = newName
                place.save(db)
            }
        }
        do {
            try db.execute(sql: "UPDATE Image SET assignPlace=$1 WHERE assignPlace=$2", parameterValues: [newName, oldName])
            let oldPlace = ImagePlace()
            oldPlace.name = oldName
            oldPlace.delete(db)
        }catch {
            print(error)
            return .ERROR
        }
        return .OK
    }
    
    func updatePlace(name: String, location: Location) -> ExecuteState {
        let db = PostgresConnection.database()
        if let place = ImagePlace.fetchOne(db, parameters: ["name" : name]) {
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
            place.save(db)
            return .OK
        }else{
            return .NO_RECORD
        }
    }
    
    func deletePlace(name: String) -> ExecuteState {
        let db = PostgresConnection.database()
        let place = ImagePlace()
        place.name = name
        place.delete(db)
        return .OK
    }
    

}
