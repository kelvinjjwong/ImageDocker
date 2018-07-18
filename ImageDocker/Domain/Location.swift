//
//  Location.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/29.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import CoreLocation


// A shorter name for a type I'll often use
typealias Coord = CLLocationCoordinate2D

class Location : NSObject {
    
    var source:String?
    var searchKeyword:String = ""
    var responseStatus:String?
    var responseMessage:String?
    
    private var convert:Bool = true
    
    var coordinate:Coord? {
        didSet {
            //print("SET ORI COORD TO \(coordinate?.latitude) \(coordinate?.longitude)")
            if coordinateBD == nil && convert {
                coordinateBD = coordinate?.fromWGS84toBD09()
            }
        }
    }
    var coordinateBD:Coord? {
        didSet {
            if coordinate == nil && convert {
                coordinate = coordinateBD?.fromBD09toWGS84()
            }
            //print("SET BD COORD TO \(coordinateBD?.latitude) \(coordinateBD?.longitude)")
        }
    }
    
    public func setCoordinateWithoutConvert(coord:Coord){
        self.convert = false
        self.coordinate = coord
        self.coordinateBD = coord
        self.convert = true
    }
    
    public func setCoordinateWithoutConvert(coord:Coord, coordBD:Coord){
        if coord.isZero || coordBD.isZero {
            print("coord zero? \(coord.isZero) coordBD zero? \(coordBD.isZero)")
        }
        self.convert = false
        self.coordinate = coord
        self.coordinateBD = coordBD
        self.convert = true
    }
    
    var info:[MetaInfo] = [MetaInfo]()
    
    fileprivate func setInfo(category:String, value:String){
        let i = info.index(where: {$0.category == category} )
        if i != nil {
            info.remove(at: i!)
        }
        info.append(MetaInfo(category: category, title: "", value: value))
    }
    
    var country:String = "" {
        didSet {
            self.setInfo(category: "Country", value: country)
        }
    }
    var province:String = "" {
        didSet {
            self.setInfo(category: "Province", value: province)
        }
    }
    var city:String = "" {
        didSet {
            self.setInfo(category: "City", value: city)
        }
    }
    var district:String = "" {
        didSet {
            self.setInfo(category: "District", value: district)
        }
    }
    var street:String = "" {
        didSet {
            self.setInfo(category: "Street", value: street)
        }
    }
    var businessCircle:String = "" {
        didSet {
            place = businessCircle
            self.setInfo(category: "BusinessCircle", value: businessCircle)
        }
    }
    var address:String = "" {
        didSet {
            self.setInfo(category: "Address", value: address)
        }
    }
    var addressDescription:String = "" {
        didSet {
            self.setInfo(category: "Description", value: addressDescription)
            for desc:String in addressDescription.components(separatedBy: ",").reversed(){
                
                if desc.contains("内") {
                    let suggestPlace = (desc.components(separatedBy: "内").first)!
                    place = suggestPlace
                    break
                }
            }
            if place == "" {
                place = businessCircle
            }
        }
    }
    var place:String = "" {
        didSet {
            self.setInfo(category: "Suggest Place", value: place)
        }
    }
    var latitude:Double? {
        guard coordinate != nil else {return nil}
        return coordinate?.latitude
    }
    var longitude:Double? {
        guard coordinate != nil else {return nil}
        return coordinate?.longitude
    }
    var latitudeBD:Double? {
        guard coordinateBD != nil else {return nil}
        return coordinateBD?.latitude
    }
    var longitudeBD:Double? {
        guard coordinateBD != nil else {return nil}
        return coordinateBD?.longitude
    }
}
