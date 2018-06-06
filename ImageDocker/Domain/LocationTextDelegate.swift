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
    
    init(){
    }
    
    func consume(location: Location) {
        if textField != nil {
            if location.address != "" {
                textField?.stringValue = "\(location.address) [\(location.addressDescription)]"
            }
        }
    }
    
    func alert(status: Int, message: String, popup: Bool) {
        print("\(status) : \(message)")
    }
    
    
    
}
