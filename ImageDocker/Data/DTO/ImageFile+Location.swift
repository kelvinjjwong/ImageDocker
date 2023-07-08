//
//  ImageFile+Location.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/23.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import Cocoa
import AppKit
import CoreLocation
//import SwiftyJSON
//import AVFoundation
//import GRDB

extension ImageFile {
    
    func isNeedLoadLocation() -> Bool {
        //self.logger.log("loaded image coordinate: \(self.latitudeBaidu) \(self.longitudeBaidu)")
        var needLoadLocation:Bool = false
        
        // force update location
        if self.imageData != nil && self.imageData!.latitudeBD != "0.0" && self.imageData!.country == "" {
            needLoadLocation = true
        }
        
        //self.logger.log("coordBD zero? \(self.location.coordinateBD?.isZero) country empty? \(self.location.country == "")")
        if self.location.coordinateBD != nil && self.location.coordinateBD!.isNotZero && self.location.country == "" {
            //self.logger.log("NEED LOAD LOCATION")
            needLoadLocation = true
        }
        if self.imageData?.updateLocationDate == nil {
            if self.location.coordinate != nil && self.location.coordinate!.isNotZero {
                //BaiduLocation.queryForAddress(lat: self.latitudeBaidu, lon: self.longitudeBaidu, locationConsumer: self)
                //self.logger.log("COORD NOT ZERO")
                needLoadLocation = true
            }
        }else {
            // if latitude not zero, but location is empty, update location
            if self.location.coordinate != nil && self.location.coordinate!.isNotZero && self.location.country == "" {
//                self.logger.log("COORD NOT ZERO BUT LOCATION IS EMPTY: \(self.url.path)")
                needLoadLocation = true
            }
        }
        return needLoadLocation
    }
    
    func assignLocation(location:Location){
        //self.logger.log("location address is \(location.address)")
        //self.logger.log("location addressDesc is \(location.addressDescription)")
        //self.logger.log("location place is \(location.place)")
        
        if imageData != nil {
            //self.logger.log("photo file not nil")
            imageData?.assignLatitude = location.latitude?.description
            imageData?.assignLongitude = location.longitude?.description
            imageData?.assignLatitudeBD = location.latitudeBD?.description
            imageData?.assignLongitudeBD = location.longitudeBD?.description
            
            imageData?.assignCountry = location.country
            imageData?.assignProvince = location.province
            imageData?.assignCity = location.city
            imageData?.assignDistrict = location.district
            imageData?.assignStreet = location.street
            imageData?.assignBusinessCircle = location.businessCircle
            imageData?.assignAddress = location.address
            imageData?.assignAddressDescription = location.addressDescription
            imageData?.assignPlace = location.place
            
            imageData?.updateLocationDate = Date()
        }
        self.location = location
        self.recognizePlace()
        
        self.transformDomainToMetaInfo()
    }
    
    
    
    // MARK: RECOGNIZE PLACE
    
    func recognizePlace() {
        if let data = self.imageData {
            self.place = Naming.Place.recognize(from: data)
        }else{
            self.place = ""
        }
    }
    
    // MARK: LOAD LOCATION
    
    func setCoordinate(latitude:Double, longitude:Double){
        guard latitude > 0 && longitude > 0 else {return}
        
        //self.logger.log("SET COORD 1: \(latitude) \(longitude) - \(fileName)")
        location.coordinate = Coord(latitude: latitude, longitude: longitude)
        
        if self.imageData != nil {
            if self.location.coordinate != nil && self.location.coordinate?.latitude != nil && self.location.coordinate?.longitude != nil {
                self.imageData?.latitude = "\(self.location.coordinate?.latitude ?? 0)"
                self.imageData?.longitude = "\(self.location.coordinate?.longitude ?? 0)"
            }
            if self.location.coordinateBD != nil && self.location.coordinateBD?.latitude != nil && self.location.coordinateBD?.longitude != nil {
                self.imageData?.latitudeBD = "\(self.location.coordinateBD?.latitude ?? 0)"
                self.imageData?.longitudeBD = "\(self.location.coordinateBD?.longitude ?? 0)"
            }
        }
        
        //hasCoordinate = true
    }
    
    public func loadLocation(locationConsumer:LocationConsumer? = nil, textConsumer:LocationConsumer? = nil) {
        if location.address != "" && location.coordinate != nil && location.coordinate!.isNotZero {
            //self.logger.log("\(self.fileName) METAINFO.address: \(address ?? "")")
            //self.logger.log("\(self.fileName) LOCATION.address: \(location?.address ?? "")")
//            self.logger.log("LOAD LOCATION 2 FROM ImageFile.location - \(fileName)")
            if locationConsumer != nil {
                //self.logger.log("\(self.fileName) getting location from meta by location consumer")
                locationConsumer?.consume(location: self.location)
            }
            if textConsumer != nil {
                //self.logger.log("\(self.fileName) getting location from meta by text consumer")
                textConsumer?.consume(location: self.location)
            }
        }else {
            if location.coordinateBD != nil && location.coordinateBD!.isNotZero {
                //self.logger.log("------")
                //self.logger.log("\(self.fileName) calling baidu location")
//                self.logger.log("LOAD LOCATION 2 FROM Baidu WebService - \(fileName) - \(self.location.coordinateBD?.latitude) \(self.location.coordinateBD?.longitude)")
                BaiduLocation.queryForAddress(coordinateBD: self.location.coordinateBD!, locationConsumer: locationConsumer ?? self, textConsumer: textConsumer)
            }else{
//                self.logger.log("LOAD LOCATION 3 FROM ImageFile.location - \(fileName)")
                if locationConsumer != nil {
                    //self.logger.log("\(self.fileName) getting location from meta by location consumer")
                    locationConsumer?.consume(location: self.location)
                }
                if textConsumer != nil {
                    //self.logger.log("\(self.fileName) getting location from meta by text consumer")
                    textConsumer?.consume(location: self.location)
                }
            }
        }
    }

}


// MARK: LOCATION CONSUMER
extension ImageFile : LocationConsumer {
    func consume(location: Location) {
        
        //self.location = location
        self.location.country = location.country
        self.location.province = location.province
        self.location.city = location.city
        self.location.district = location.district
        self.location.businessCircle = location.businessCircle
        self.location.street = location.street
        self.location.address = location.address
        self.location.addressDescription = location.addressDescription
        self.location.place = location.place
        
        if imageData != nil {
            
            imageData?.country = location.country
            imageData?.province = location.province
            imageData?.city = location.city
            imageData?.district = location.district
            imageData?.street = location.street
            imageData?.businessCircle = location.businessCircle
            imageData?.address = location.address
            imageData?.addressDescription = location.addressDescription
            imageData?.suggestPlace = location.place
        }
        
        self.recognizePlace()
        
        imageData?.updateLocationDate = Date()
        
        self.logger.log("[ImageFile.consume:location] UPDATE LOCATION for image \(url.path)")
        let _ = save()
        
    }
    
    func alert(status: Int, message: String, popup: Bool) {
        self.logger.log("\(status) : \(message)")
    }
    
    
}
