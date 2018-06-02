//
//  LocationTextDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/30.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

class LocationTextDelegate : MetaInfoStoreDelegate {
    
    let infoDelegate:StandaloneMetaInfoStore
    var textField:NSTextField?
    
    init(){
        self.infoDelegate = StandaloneMetaInfoStore()
    }
    
    func setMetaInfo(_ info: MetaInfo?) {
        infoDelegate.setMetaInfo(info)
    }
    
    func setMetaInfo(_ info: MetaInfo?, ifNotExists: Bool) {
        infoDelegate.setMetaInfo(info, ifNotExists: ifNotExists)
    }
    
    func updateMetaInfoView() {
        if textField != nil {
            let address = getMeta(category: "Location", subCategory: "Baidu", title: "Address")
            let addressDescription = getMeta(category: "Location", subCategory: "Baidu", title: "Description")
            if address != nil {
                textField?.stringValue = "\(address ?? "") [\(addressDescription ?? "")]"
            }
        }
    }
    
    func getMeta(category: String, subCategory: String, title: String) -> String? {
        return infoDelegate.getMeta(category: category, subCategory: subCategory, title: title)
    }
    
    func getInfos() -> [MetaInfo] {
        return infoDelegate.getInfos()
    }
    
    
}
