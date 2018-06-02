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
    
    func getInfos() -> [MetaInfo] {
        return self.metaInfo
    }
    
    func setMetaInfo(_ info:MetaInfo?){
        setMetaInfo(info, ifNotExists: false)
    }
    
    func setMetaInfo(_ info:MetaInfo?, ifNotExists: Bool){
        let info = info!
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
        for meta in metaInfo {
            if meta.category == category && meta.subCategory == subCategory && meta.title == title {
                return meta.value
            }
        }
        return nil
    }
}

extension ViewController: LocationDelegate {
    
    func handleLocation(location:Location){
        self.possibleLocation = location
        
        BaiduLocation.queryForAddress(lat: location.latitudeBD!, lon: location.longitudeBD!, metaInfoStore: self.locationTextDelegate!)
        BaiduLocation.queryForMap(lat: location.latitudeBD!, lon: location.longitudeBD!, view: webPossibleLocation, zoom: zoomSizeForPossibleAddress)
    }
    
    func handleMessage(status: Int, message: String) {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("CLOSE", comment: "Close"))
        alert.messageText = NSLocalizedString("Location Service", comment: "")
        alert.informativeText = NSLocalizedString(message, comment: "")
        alert.runModal()
    }
}
