//
//  LocationTextDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/30.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class LocationTextDelegate : LocationConsumer {
    
    var textField:NSTextField?
    
    var coordinateAPI:LocationAPI = .baidu
    
    var location:Location = Location()
    
    init(){
    }
    
    func consume(location: Location) {
        self.location = location
        print(location.country)
        print(location.province)
        print(location.city)
        print(location.district)
        print(location.address)
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
                    print("== no address detail, no keyword for google searching")
                }
            }
        }
    }
    
    func alert(status: Int, message: String, popup: Bool) {
        print("\(status) : \(message)")
    }
    
    
    
}
