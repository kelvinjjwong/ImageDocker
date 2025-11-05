//
//  IPLocation.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2024/9/1.
//  Copyright © 2024 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory



public protocol IPAddressConsumer {
    
    func consume(ip:String)
}

public class IPLocation {
    
    static let logger = LoggerFactory.get(category: "IP", subCategory: "Location")
    
    fileprivate static let baseurlIP:String = "https://ifconfig.me/all.json"
    fileprivate static let baseurlDNS:String = "https://api.ipinfo.io/lite/ABCDEFG?token=c3b3ad40b3ba44"
    
    fileprivate static var cachedDNS:[String:String] = [:]
    
    public static func getIP(_ consumer:@escaping (String) -> Void) {
        let requestUrl:URL = URL(string:baseurlIP)!
        let request = URLRequest(url:requestUrl)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if error == nil, let usableData = data {
                let dataStr:String = String(data: usableData, encoding: String.Encoding.utf8)!
                print("getIP response:\(dataStr)")
                let json:JSON = JSON(parseJSON: dataStr)
                if json != JSON(NSNull()) {
                    let ip = json["ip_addr"].stringValue
                    consumer(ip)
                }
            }
        }
        task.resume()
    }
    
    public static func getDNS(ip:String, _ consumer:@escaping (String) -> Void) {
        if let _dns = cachedDNS[ip] {
            consumer("\(_dns)")
        }else{
            let requestUrl:URL = URL(string:baseurlDNS.replacingFirstOccurrence(of: "ABCDEFG", with: ip))!
            let request = URLRequest(url:requestUrl)
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                if error == nil, let usableData = data {
                    let dataStr:String = String(data: usableData, encoding: String.Encoding.utf8)!
                    print("getDNS response:\(dataStr)")
                    let json:JSON = JSON(parseJSON: dataStr)
                    if json != JSON(NSNull()) {
                        let continent = json["continent"].stringValue
                        let country = json["country"].stringValue
                        let represent = "\(continent)/\(country)"
                        cachedDNS[ip] = represent
                        consumer(represent)
                    }
                }
            }
            task.resume()
        }
    }
    
    public static func get() -> String{
        let pipe = Pipe()
        let pipe2 = Pipe()
        
        autoreleasepool { () -> Void in
            let exiftool = Process()
            exiftool.standardOutput = pipe
            exiftool.standardError = pipe2
            exiftool.launchPath = "/bin/bash"
            exiftool.arguments = ["-c", "curl -fsSL https://zh-hans.ipshu.com/my_info | grep '<li>' | egrep '名称:|地址:' | grep -v '<img' | tail -4 | sed 's/\\/a>//' | tr '</>' ' ' | awk -F' ' '{print $(NF-1)}'"]
            exiftool.launch()
            exiftool.waitUntilExit()
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string:String = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        
        let data2 = pipe2.fileHandleForReading.readDataToEndOfFile()
        let string2:String = String(data: data2, encoding: String.Encoding.utf8)!
        pipe2.fileHandleForReading.closeFile()
        
        logger.log(.trace, string)
        logger.log(.trace, string2)
        return string
    }
}
