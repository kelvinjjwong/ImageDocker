//
//  LocationTextDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/30.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa
import LoggerFactory

class LocationTextDelegate : LocationConsumer {
    
    let logger = LoggerFactory.get(category: "LocationTextDelegate")
    
    var textField:NSTextField?
    
    var coordinateAPI:LocationAPI = .baidu
    
    var location:Location = Location()
    
    init(){
    }
    
    func consume(location: Location) {
        self.location = location
        self.logger.log(location.country)
        self.logger.log(location.province)
        self.logger.log(location.city)
        self.logger.log(location.district)
        self.logger.log(location.address)
        if textField != nil {
            if location.address != "" {
                var desc = ""
                if location.addressDescription != "" && location.addressDescription != location.address {
                    desc = " [\(location.addressDescription)]"
                }
                textField?.stringValue = "\(location.address)\(desc)"
            }
            if location.country == "" && self.coordinateAPI == .google && location.source != "Google" {
                if location.searchKeyword != "" {
                    GoogleLocation.queryForAddress(address: location.searchKeyword, locationConsumer: self, modifyLocation: location)
                }else{
                    self.logger.log(.trace, "== no address detail, no keyword for google searching")
                }
            }
        }
    }
    
    func alert(status: Int, message: String, popup: Bool) {
        self.logger.log(.trace, "\(status) : \(message)")
    }
    
    
    
}
