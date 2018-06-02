//
//  BaiduLocation.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/26.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import WebKit
import SwiftyJSON

final class BaiduLocation {
    
    fileprivate static let baseurl:String = "http://api.map.baidu.com"
    
    fileprivate static func ak() -> String {
        return PreferencesController.baiduAK()
    }
    
    fileprivate static func sk() -> String {
        return PreferencesController.baiduSK()
    }
    
    fileprivate static func sn(_ queryStr:String) -> String {
        let encodedStr:String = queryStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let rawStr:String = encodedStr + sk()
        let rawStrEncode:String = rawStr.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!.replacingOccurrences(of: "%2E", with: ".")
        return rawStrEncode.md5()
    }
    
    public static func urlForAddress(lat latitudeBaidu:Double, lon longitudeBaidu:Double) -> String{
        let queryStr:String = "/geocoder/v2/?output=json&pois=0&ak=\(ak())&location=\(latitudeBaidu),\(longitudeBaidu)"
        return "\(baseurl)\(queryStr)&sn=\(sn(queryStr))"
    }
    
    public static func urlForMap(width: Int, height: Int, zoom: Int, lat latitudeBaidu:Double, lon longitudeBaidu:Double) -> String {
        return "\(baseurl)/staticimage?center=\(longitudeBaidu),\(latitudeBaidu)&width=\(width)&height=\(height)&zoom=\(zoom)&scale=2&markers=\(longitudeBaidu),\(latitudeBaidu)&markerStyles=l,A"
    }
    
    public static func urlForCoordinate(address:String) -> String{
        let encodedAddress:String = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let queryStr:String = "/geocoder/v2/?address=\(encodedAddress)&output=json&ak=\(ak())"
        let queryStrForSn:String = "/geocoder/v2/?address=\(address)&output=json&ak=\(ak())"
        return "\(baseurl)\(queryStr)&sn=\(sn(queryStrForSn))"
    }
    
    public static func queryForCoordinate(address:String, locationDelegate: LocationDelegate){
        let urlString:String = BaiduLocation.urlForCoordinate(address: address)
        //print(urlString)
        let requestUrl:URL = URL(string:urlString)!
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil, let usableData = data {
                let dataStr:String = String(data: usableData, encoding: String.Encoding.utf8)!
                print(dataStr)
                let json:JSON = JSON(parseJSON: dataStr)
                if json != JSON(NSNull()) {
                    let status:Int = json["status"].intValue
                    if status == 0 {
                        let latitudeBaidu:Double = json["result"]["location"]["lat"].doubleValue
                        let longitudeBaidu:Double = json["result"]["location"]["lng"].doubleValue
                        
                        DispatchQueue.main.async {
                            
                            let coordBD = Coord(latitude: latitudeBaidu, longitude: longitudeBaidu)
                            let coord = coordBD.fromBD09toWGS84()
                            let location:Location = Location()
                            location.address = address
                            location.latitudeBD = latitudeBaidu
                            location.longitudeBD = longitudeBaidu
                            location.latitude = coord.latitude
                            location.longitude = coord.longitude
                            locationDelegate.handleLocation(location: location)
                        }
                        
                    } else {
                        let message:String = json["message"].stringValue
                        print(message)
                    }
                }
            }
        }
        task.resume()
    }
    
    public static func queryForAddress(lat latitudeBaidu:Double, lon longitudeBaidu:Double, metaInfoStore:MetaInfoStoreDelegate, consumer:MetaInfoConsumeDelegate? = nil){
        let urlString:String = BaiduLocation.urlForAddress(lat: latitudeBaidu, lon: longitudeBaidu)
        guard let requestUrl = URL(string:urlString) else { return }
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil,let usableData = data {
                // let jsonString:String = String(data: data!, encoding: String.Encoding.utf8)!
                
                let location:Location = Location()
                location.source = "Baidu"
                
                location.latitudeBD = latitudeBaidu
                location.longitudeBD = longitudeBaidu
                
                let coordBD = Coord(latitude: latitudeBaidu, longitude: longitudeBaidu)
                let coord = coordBD.fromBD09toWGS84()
                location.latitude = coord.latitude
                location.longitude = coord.longitude
                
                let json = try? JSON(data: usableData)
                location.responseStatus = json!["status"].description
                location.responseMessage = json!["message"].description
                if location.responseStatus != "0" {
                    DispatchQueue.main.async {
                        metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Status", value: location.responseStatus))
                        metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Message", value: location.responseMessage))
                        metaInfoStore.updateMetaInfoView()
                        if consumer != nil {
                            consumer?.consume(metaInfoStore.getInfos())
                        }
                    }
                }else{
                    
                    location.address = json!["result"]["formatted_address"].description
                    location.businessCircle = json!["result"]["business"].description
                    location.country = json!["result"]["addressComponent"]["country"].description
                    location.province = json!["result"]["addressComponent"]["province"].description
                    location.city = json!["result"]["addressComponent"]["city"].description
                    location.district = json!["result"]["addressComponent"]["district"].description
                    location.street = json!["result"]["addressComponent"]["street"].description
                    location.addressDescription = json!["result"]["sematic_description"].description
                    
                    if location.address != "" {
                        DispatchQueue.main.async {
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Country", value: location.country))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Province", value: location.province))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "City", value: location.city))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "District", value: location.district))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Street", value: location.street))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "BusinessCircle", value: location.businessCircle))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Address", value: location.address))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Description", value: location.addressDescription))
                            
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Suggest Place", value: location.place))
                            
                            metaInfoStore.updateMetaInfoView()
                            if consumer != nil {
                                consumer?.consume(metaInfoStore.getInfos())
                            }
                        }
                    }
                }
                
            }
        }
        task.resume()
    }
    
    public static func queryForMap(lat latitudeBaidu:Double, lon longitudeBaidu:Double, view:WKWebView, zoom: Int){
        let width:Int = Int(min(CGFloat(512), view.frame.size.width))
        let height:Int = Int(min(CGFloat(512), view.frame.size.height))
        let requestBaiduUrl = urlForMap(width: width, height: height, zoom: zoom, lat: latitudeBaidu, lon: longitudeBaidu)
        guard let requestUrl = URL(string: requestBaiduUrl) else {return}
        let req = URLRequest(url: requestUrl)
        view.load(req)
    }
}
