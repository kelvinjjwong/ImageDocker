//
//  Location.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/29.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

protocol LocationConsumer {
    func consume(location:Location)
}

class Location : NSObject {
    
    var source:String?
    var responseStatus:String?
    var responseMessage:String?
    
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
            
            if addressDescription.contains("内") {
                let suggestPlace = (addressDescription.components(separatedBy: "内").first)!
                place = suggestPlace
            }else{
                place = businessCircle
            }
        }
    }
    var place:String = "" {
        didSet {
            self.setInfo(category: "Suggest Place", value: place)
        }
    }
    var latitude:Double?
    var longitude:Double?
    var latitudeBD:Double?
    var longitudeBD:Double?
}
