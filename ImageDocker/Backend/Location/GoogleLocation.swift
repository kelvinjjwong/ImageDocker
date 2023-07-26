//
//  GoogleLocation.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/7/6.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
//import SwiftyJSON


class GoogleLocation {
    
    static let logger = LoggerFactory.get(category: "GoogleLocation")
    
    fileprivate static func ak() -> String {
        return Setting.externalApi.googleAPIKey()
    }
    
    
    public static func queryForCoordinate(address:String, coordinateConsumer: CoordinateConsumer){
        
        let encodedAddress:String = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let urlString:String = "https://www.google.com/maps/search/?api=1&query=\(encodedAddress.replacingOccurrences(of: " ", with: "+"))"
        
        let requestUrl:URL = URL(string:urlString)!
        let request = URLRequest(url:requestUrl)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 10
        
        let task = URLSession(configuration: configuration).dataTask(with: request) {
            (data, response, error) in
            if error == nil, let usableData = data {
                let dataStr:String = String(data: usableData, encoding: String.Encoding.utf8)!
                if dataStr.count > 0 {
                    let metas = dataStr.components(separatedBy: "meta content=\"")
                    if metas.count > 0{
                        for meta in metas {
                            if meta.starts(with: "https://maps.google.com") {
                                let parts = meta.components(separatedBy: "&amp;")
                                if parts.count > 0 {
                                    let param = parts[0].replacingOccurrences(of: "https://maps.google.com/maps/api/staticmap?center=", with: "")
                                    let pair = param.components(separatedBy: "%2C")
                                    if pair.count > 0{
                                        let coord:Coord = Coord(latitude: Double(pair[0]) ?? 0, longitude: Double(pair[1]) ?? 0)
                                        //self.logger.log(coord.latitude)
                                        //self.logger.log(coord.longitude)
                                        //self.logger.log("long,lati=\(coord.longitude),\(coord.latitude)")
                                        
                                        DispatchQueue.main.async {
                                            
                                            // no need to transform
                                            coordinateConsumer.consume(coordinate: coord)
                                        }
                                    }
                                }
                                break
                            }
                        }
                    }
                }
                //self.logger.log(dataStr)
                
            }else{
                GoogleLocation.logger.log(error ?? "unknown error")
                NotificationMessageManager.default.createNotificationMessage(type: "GoogleMap", name: address, message: "\(error)")
            }
        }
        
        task.resume()
    }
    
    public static func queryForAddress(address:String, locationConsumer:LocationConsumer, textConsumer:LocationConsumer? = nil, modifyLocation:Location? = nil){
        guard self.ak() != "" else {
            locationConsumer.alert(status: -1, message: "ERROR: Google API Key has not specified", popup: false)
            if textConsumer != nil {
                textConsumer?.alert(status: -1, message: "ERROR: Google API Key has not specified", popup: false)
            }
            return
        }
        
        let encodedAddress:String = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString:String = "https://maps.googleapis.com/maps/api/geocode/json?address=\(encodedAddress.replacingOccurrences(of: " ", with: "+"))&key=\(ak())"
        let requestUrl:URL = URL(string:urlString)!
        let request = URLRequest(url:requestUrl)
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 15
        
        let task = URLSession(configuration: configuration).dataTask(with: request) {
            (data, response, error) in
            if error == nil, let usableData = data {
                let dataStr:String = String(data: usableData, encoding: String.Encoding.utf8)!
                let json:JSON = JSON(parseJSON: dataStr)
                if json != JSON(NSNull()) {
                    let status:String = json["status"].stringValue
                    if status == "OK" && (json["results"].array?.count)! > 0 {
                        
                        let location:Location = modifyLocation ?? Location()
                        location.source = "Google"
                        
                        let result = json["results"].array![0]
                        let addr = result["formatted_address"].stringValue
                        let lat = result["geometry"]["location"]["lat"].doubleValue
                        let lon = result["geometry"]["location"]["lng"].doubleValue
                        
                        let coord = Coord(latitude: lat, longitude: lon)
                        location.setCoordinateWithoutConvert(coord: coord)
                        
                        var gov:[String] = []
                        var country:String = ""
                        var province:String = ""
                        var city:String = ""
                        var district:String = ""
                        var street:String = ""
                        for entry in result["address_components"].arrayValue.reversed() {
                            let types = entry["types"].arrayValue
                            if types.count == 1 && types[0].stringValue == "postal_code" {
                                continue
                            }
                            gov.append(entry["long_name"].stringValue)
                        }
                        if gov.count > 0 {
                            country = gov[0]
                        }
                        if gov.count > 1 {
                            province = gov[1]
                        }
                        if gov.count > 2 {
                            city = gov[2]
                        }
                        if gov.count > 3 {
                            district = gov[3]
                        }
                        if gov.count > 4 {
                            street = gov[4]
                        }
                        if gov.count > 5 {
                            street = "\(gov[5]) \(gov[4])"
                        }
                        
                        location.country = country
                        location.province = province
                        location.city = city
                        location.district = district
                        location.street = street
                        location.address = addr
                        location.addressDescription = addr
                        location.businessCircle = ""
                        
                        DispatchQueue.main.async {
                            locationConsumer.consume(location: location)
                            if textConsumer != nil {
                                textConsumer?.consume(location: location)
                            }
                        }
                        
                    }else{
                        let location:Location = modifyLocation ?? Location()
                        location.source = "Google"
                        
                        location.country = ""
                        location.province = ""
                        location.city = ""
                        location.district = ""
                        location.street = ""
                        location.address = ""
                        location.addressDescription = ""
                        location.businessCircle = ""
                        
                        DispatchQueue.main.async {
                            locationConsumer.consume(location: location)
                            if textConsumer != nil {
                                textConsumer?.consume(location: location)
                            }
                        }
                        
                    }
                }else{
                    locationConsumer.alert(status: -1, message: "Unexpected ERROR!", popup: false)
                    if textConsumer != nil {
                        textConsumer?.alert(status: -1, message: "Unexpected ERROR!", popup: false)
                    }
                }
            }else{
                GoogleLocation.logger.log(error ?? "")
                NotificationMessageManager.default.createNotificationMessage(type: "GoogleMap", name: address, message: "\(error)")
                locationConsumer.alert(status: -1, message: "Unexpected ERROR!", popup: false)
                if textConsumer != nil {
                    textConsumer?.alert(status: -1, message: "Unexpected ERROR!", popup: false)
                }
            }
        }
        task.resume()
        
    }
}
