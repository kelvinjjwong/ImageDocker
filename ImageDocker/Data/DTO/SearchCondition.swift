//
//  SearchHelper.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/5/10.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

struct SearchCondition {
    
    var years:[Int]
    var months:[Int]
    var days:[Int]
    var peopleIds:[String]
    var keywords:[String]
    var includeHidden:Bool
    
    static func get(from query:String, includeHidden:Bool = false) -> SearchCondition {
        var peopleIds:[String] = []
        var keys:[String] = []
        var years:[Int] = []
        var months:[Int] = []
        var days:[Int] = []
        let keywords = query.components(separatedBy: " ")
        for kw in keywords {
            let keyword = kw.replacingOccurrences(of: "'", with: "")
            if let i = Int(keyword), keyword.count == 4 {
                years.append(i)
            }else if keyword.count == 5 && keyword.hasSuffix("年") {
                let index = keyword.index(keyword.startIndex, offsetBy: 4)
                let year = keyword.prefix(upTo: index)
                if let y = Int(year) {
                    years.append(y)
                }else{
                    keys.append(keyword)
                }
            }else if keyword.count <= 3 && keyword.hasSuffix("月") {
                let index = keyword.index(keyword.startIndex, offsetBy: keyword.count-1)
                let month = keyword.prefix(upTo: index)
                if let m = Int(month) {
                    months.append(m)
                }else{
                    keys.append(keyword)
                }
            }else if keyword.count <= 3 && (keyword.hasSuffix("日") || keyword.hasSuffix("号")) {
                let index = keyword.index(keyword.startIndex, offsetBy: keyword.count-1)
                let day = keyword.prefix(upTo: index)
                if let d = Int(day) {
                    print("search day: \(d)")
                    days.append(d)
                }else{
                    keys.append(keyword)
                }
            }else if let peopleId = FaceTask.default.peopleId(name: keyword) {
                peopleIds.append(peopleId)
                //keys.append(keyword)
            }else{
                keys.append(keyword)
            }
        }
        return SearchCondition(years: years, months: months, days: days, peopleIds: peopleIds, keywords: keys, includeHidden: includeHidden)
    }
}
