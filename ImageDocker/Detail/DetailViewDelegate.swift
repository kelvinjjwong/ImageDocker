//
//  DetailViewDelegate.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/5/21.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa


extension ViewController: DropPlaceDelegate {
    func dropURLs(_ urls: [URL]) {
        processImageUrls(urls: urls)
    }
}

extension ViewController: MetaInfoStoreDelegate {
    
    func setMetaInfo(_ info:MetaInfo){
        setMetaInfo(info, ifNotExists: false)
    }
    
    func setMetaInfo(_ info:MetaInfo, ifNotExists: Bool){
        if info.value == nil || info.value == "" || info.value == "null" {return}
        var exists:Int = 0
        for exist:MetaInfo in self.metaInfo {
            if exist.category == info.category && exist.subCategory == info.subCategory && exist.title == info.title {
                if ifNotExists == false {
                    exist.value = info.value
                }
                exists = 1
            }
        }
        if exists == 0 {
            self.metaInfo.append(info)
        }
    }
    
    func updateMetaInfoView() {
        self.sortMetaInfoArray()
        self.metaInfoTableView.reloadData()
    }
    
    func getMeta(category:String, subCategory:String, title:String) -> String? {
        // TODO
        return nil
    }
}

extension ViewController: LocationDelegate {
    
    func handleLocation(address: String, latitude: Double, longitude: Double) {
        BaiduLocation.queryForMap(lat: latitude, lon: longitude, view: webPossibleLocation, zoom: zoomSizeForPossibleAddress)
    }
    
    func handleMessage(status: Int, message: String) {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("CLOSE", comment: "Close"))
        alert.messageText = NSLocalizedString("Location Service", comment: "")
        alert.informativeText = NSLocalizedString(message, comment: "")
        alert.runModal()
    }
}
