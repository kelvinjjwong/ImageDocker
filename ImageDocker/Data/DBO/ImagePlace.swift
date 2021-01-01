//
//  ImagePlace.swift
//  DummyWindow
//
//  Created by Kelvin Wong on 2018/7/8.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

public final class ImagePlace : Codable {
    //var id: Int64?      // <- the row id
    var name: String = ""
    var latitude:String?
    var latitudeBD:String?
    var longitude:String?
    var longitudeBD:String?
    var country: String?
    var province: String?
    var city: String?
    var district: String?
    var businessCircle: String?
    var street: String?
    var address: String?
    var addressDescription: String?
    
    public init() {
        
    }
    
    public init(name:String,
                country:String?,
                province:String?,
                city:String?,
                district:String?,
                businessCircle:String?,
                street:String?,
                address:String?,
                addressDescription:String?,
                latitude:String?,
                latitudeBD:String?,
                longitude:String?,
                longitudeBD:String?) {
        self.name = name
        self.country = country
        self.province = province
        self.city = city
        self.district = district
        self.businessCircle = businessCircle
        self.street = street
        self.address = address
        self.addressDescription = addressDescription
        self.latitude = latitude
        self.latitudeBD = latitudeBD
        self.longitude = longitude
        self.longitudeBD = longitudeBD
    }
}

extension ImagePlace: FetchableRecord, MutablePersistableRecord, TableRecord {

}


extension ImagePlace : PostgresRecord {
    public func postgresTable() -> String {
        return "ImagePlace"
    }
    
    public func primaryKeys() -> [String] {
        return ["name"]
    }
    
    
}
