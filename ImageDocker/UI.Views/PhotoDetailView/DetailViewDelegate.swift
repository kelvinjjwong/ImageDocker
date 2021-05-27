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

extension ViewController: LocationConsumer {
    
    func consume(location: Location) {
//        self.possibleLocation = location
        
        img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Country", value: location.country))
        img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Province", value: location.province))
        img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "City", value: location.city))
        img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "District", value: location.district))
        img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Street", value: location.street))
        img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "BusinessCircle", value: location.businessCircle))
        img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Address", value: location.address))
        img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Description", value: location.addressDescription))
        
        img.metaInfoHolder.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Suggest Place", value: location.place))
        
        img.recognizePlace()
        
        self.metaInfoTableView.reloadData()
    }
    
    func alert(status: Int, message: String, popup:Bool = false) {
        print("LOCATION ALERT: \(status) : \(message)")
    }
    
    
}
