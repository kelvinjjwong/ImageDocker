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
                            locationDelegate.handleLocation(address: address, latitude: latitudeBaidu, longitude: longitudeBaidu)
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
                
                let json = try? JSON(data: usableData)
                let status:String = json!["status"].description
                let message:String = json!["message"].description
                if status != "0" {
                    DispatchQueue.main.async {
                        metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Status", value: status))
                        metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Message", value: message))
                        metaInfoStore.updateMetaInfoView()
                        if consumer != nil {
                            consumer?.consume(metaInfoStore.getInfos())
                        }
                    }
                }else{
                    
                    let address:String = json!["result"]["formatted_address"].description
                    let businessCircle:String = json!["result"]["business"].description
                    let country:String = json!["result"]["addressComponent"]["country"].description
                    let province:String = json!["result"]["addressComponent"]["province"].description
                    let city:String = json!["result"]["addressComponent"]["city"].description
                    let district:String = json!["result"]["addressComponent"]["district"].description
                    let street:String = json!["result"]["addressComponent"]["street"].description
                    let description:String = json!["result"]["sematic_description"].description
                    
                    if address != "" {
                        DispatchQueue.main.async {
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Country", value: country))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Province", value: province))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "City", value: city))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "District", value: district))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Street", value: street))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "BusinessCircle", value: businessCircle))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Address", value: address))
                            metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Description", value: description))
                            if description.contains("内") {
                                let suggestPlace = (description.components(separatedBy: "内").first)!
                                metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Suggest Place", value: suggestPlace))
                            }else{
                                metaInfoStore.setMetaInfo(MetaInfo(category: "Location", subCategory: "Baidu", title: "Suggest Place", value: businessCircle))
                            }
                            
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
