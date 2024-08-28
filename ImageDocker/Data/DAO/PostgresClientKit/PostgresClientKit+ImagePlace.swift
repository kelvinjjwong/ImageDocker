//
//  PostgresClientKit+ImagePlace.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

class PlaceDaoPostgresCK : PlaceDaoInterface {
    
    let logger = LoggerFactory.get(category: "PlaceDaoPostgresCK")
    
    func getOrCreatePlace(name: String, location: Location) -> ImagePlace {
        let db = PostgresConnection.database()
        
        let dummy = ImagePlace(
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
        do {
            if let place = try ImagePlace.fetchOne(db, parameters: ["name": name]) {
                return place
            }else{
                try dummy.save(db)
                return dummy
            }
        }catch{
            self.logger.log(.error, "Unable to save place", error)
            return dummy
        }
    }
    
    func getPlace(name: String) -> ImagePlace? {
        let db = PostgresConnection.database()
        do {
            return try ImagePlace.fetchOne(db, parameters: ["name" : name])
        }catch{
            self.logger.log(.error, "Unable to query place", error)
            return nil
        }
    }
    
    func getAllPlaces() -> [ImagePlace] {
        let db = PostgresConnection.database()
        do {
            return try ImagePlace.fetchAll(db)
        }catch{
            self.logger.log(.error, "Unable to query place", error)
            return []
        }
    }
    
    func getPlaces(byName names: String?) -> [ImagePlace] {
        let db = PostgresConnection.database()
        var whereStmt = ""
        if let names = names {
            let keys:[String] = names.components(separatedBy: " ")
            whereStmt = SQLHelper.likeArray(field: "name", array: keys)
        }
        do {
            return try ImagePlace.fetchAll(db, where: whereStmt, orderBy: "name")
        }catch{
            self.logger.log(.error, "Unable to query place", error)
            return []
        }
    }
    
    func renamePlace(oldName: String, newName: String) -> ExecuteState {
        let db = PostgresConnection.database()
        
        do {
            if try !ImagePlace.exists(db, parameters: ["name" : newName]) {
                if let place = try ImagePlace.fetchOne(db, parameters: ["name": oldName]) {
                    place.name = newName
                    try place.save(db)
                }
            }
            try db.execute(sql: "UPDATE \"Image\" SET \"assignPlace\"=$1 WHERE \"assignPlace\"=$2", parameterValues: [newName, oldName])
            let oldPlace = ImagePlace()
            oldPlace.name = oldName
            try oldPlace.delete(db)
        }catch {
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    
    func updatePlace(name: String, location: Location) -> ExecuteState {
        let db = PostgresConnection.database()
        do {
            if let place = try ImagePlace.fetchOne(db, parameters: ["name" : name]) {
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
                return .OK
            }else{
                return .NO_RECORD
            }
        }catch {
            self.logger.log(.error, error)
            return .ERROR
        }
    }
    
    func deletePlace(name: String) -> ExecuteState {
        let db = PostgresConnection.database()
        let place = ImagePlace()
        place.name = name
        do {
            try place.delete(db)
        }catch {
            self.logger.log(.error, error)
            return .ERROR
        }
        return .OK
    }
    

}
