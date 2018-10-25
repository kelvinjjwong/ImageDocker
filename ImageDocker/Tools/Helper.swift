//
//  Helper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/4/25.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Cocoa

extension String {
    
    func paddingLeft(_ width:Int, with:String = " ") -> String{
        let toPad:Int = width - self.count
        if toPad < 1 {return self}
        var str = self
        for _ in 1...toPad {
            str = with + str
        }
        return str
    }
    
    var numberValue: NSNumber? {
        if let value = Int(self) {
            return NSNumber(value: value)
        }
        return nil
    }
    
    
    func matches(for regex: String!) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = self as NSString
            let results = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
            var match = [String]()
            for result in results {
                for i in 0..<result.numberOfRanges {
                    match.append(nsString.substring( with: result.range(at: i) ))
                }
            }
            return match
            //return results.map { nsString.substringWithRange( $0.range )} //rangeAtIndex(0)
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
