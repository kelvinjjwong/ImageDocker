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


extension ViewController: CoordinateConsumer {
    
    func consume(coordinate:Coord){
        //self.possibleLocation = location
        let coordBD:Coord = coordinate.fromWGS84toBD09()
        
        BaiduLocation.queryForAddress(lat: coordBD.latitude, lon: coordBD.longitude, locationConsumer: self.locationTextDelegate!)
        BaiduLocation.queryForMap(lat: coordBD.latitude, lon: coordBD.longitude, view: webPossibleLocation, zoom: zoomSizeForPossibleAddress)
    }
    
    func alert(status: Int, message: String) {
        let alert = NSAlert()
        alert.addButton(withTitle: NSLocalizedString("CLOSE", comment: "Close"))
        alert.messageText = NSLocalizedString("Location Service", comment: "")
        alert.informativeText = NSLocalizedString(message, comment: "")
        alert.runModal()
    }
}

extension ViewController: LocationConsumer {
    
    func consume(location: Location) {
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
        if popup {
            let alert = NSAlert()
            alert.addButton(withTitle: NSLocalizedString("CLOSE", comment: "Close"))
            alert.messageText = NSLocalizedString("Location Service", comment: "")
            alert.informativeText = NSLocalizedString(message, comment: "")
            alert.runModal()
        }else{
            print("LOCATION ALERT: \(status) : \(message)")
        }
    }
    
    
}
