//
//  BaiduLocation.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/26.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation

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
}
