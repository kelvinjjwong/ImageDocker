//
//  PlacesTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class PlacesTreeDataSource : TreeDataSource {
    
    func convertPlacesToTreeCollections(_ moments:[Moment]) -> [TreeCollection] {
        var govs:[TreeCollection] = []
        for moment in moments {
            let country = moment.countryData
            let province = moment.provinceData
            let city = moment.cityData
            var place = moment.placeData
            var gov = ""
            
            if country == "" && province == "" && city == "" && place == "" {
                gov = "未知国家"
                place = "未知地点"
            }else if country == "" && province == "" && city == "" && place != "" {
                gov = place
            }else {
                if country == "中国" {
                    if province == city {
                        gov = city
                    }else{
                        gov = "\(province)\(city)"
                    }
                }else{
                    gov = "\(country)"
                }
            }
            
            if place == "" && (country != "" || province != "" || city != "") {
                if city != "" {
                    place = city
                }
                if place == "" && province != "" {
                    place = province
                }
                if place == "" && country != "" {
                    place = country
                }
            }
            gov = gov.replacingOccurrences(of: Words.section_SAR.word(), with: "")
            place = place.replacingOccurrences(of: Words.section_SAR.word(), with: "")
            
            moment.gov = gov
            moment.place = place
            
            //self.logger.log(.trace, "Got place \(gov) -> \(place)")
            
            var govEntry:TreeCollection
            var placeEntry:TreeCollection
            
            if govs.firstIndex(where: {$0.name == gov}) == nil {
                var momentGov:Moment
                if country == "中国" {
                    momentGov = Moment(gov: country)
                    momentGov.countryData = moment.countryData
                    momentGov.provinceData = moment.provinceData
                    momentGov.cityData = moment.cityData
                    momentGov.placeData = ""
                }else{
                    momentGov = Moment(gov: country)
                }
                govEntry = TreeCollection(gov, id: "gov_\(gov)", object: momentGov)
                govEntry.expandable = true
                govs.append(govEntry)
            }else{
                govEntry = govs.first(where: {$0.name == gov})!
            }
            
            if govEntry.children.firstIndex(where: {$0.name == place}) == nil {
                placeEntry = TreeCollection(place, id: "gov_\(gov)_place_\(place)", object:moment)
                placeEntry.expandable = true
                govEntry.addChild(collection: placeEntry)
            }else{
                //self.logger.log(.trace, "ERROR: duplicated place entry \(gov) -> \(place)")
            }
        }
        
        // recount images from place-entries for each gov
        for gov in govs {
            if let moment = gov.relatedObject as? Moment {
                var imageCount = 0
                for place in gov.children {
                    if let m = place.relatedObject as? Moment {
                        imageCount += m.photoCount
                    }
                }
                moment.photoCount = imageCount
                gov.relatedObject = moment
            }
        }
        
        return govs
        
    }
    
    func convertDateToTreeCollection(_ moment:Moment) -> TreeCollection {
        let node = TreeCollection(moment.represent, id: moment.id, object: moment)
        if moment.year == 0 && moment.month == 0 && moment.day == 0 {
            node.expandable = false
        }else if moment.day == 0 {
            node.expandable = true
        }
        return node
    }
    
    func loadChildren(_ collection: TreeCollection?, condition:SearchCondition?) -> ([TreeCollection], String?, String?) {
        
        if collection == nil {
            let moments = ImageSearchDao.default.getMomentsByPlace(.PLACE, condition: condition)
            return (self.convertPlacesToTreeCollections(moments), nil, nil)
        }else{
            if let parentNode = collection, let parent = parentNode.relatedObject as? Moment {
                if parent.place != "" {
                    var nodes:[TreeCollection] = []
                    var moments:[Moment] = []
                    if parent.year == 0 {
//                        self.logger.log(.trace, "loading years")
                        moments = ImageSearchDao.default.getMomentsByPlace(.YEAR, parent: parent, condition: condition)
                    }else if parent.month == 0 {
//                        self.logger.log(.trace, "loading months")
                        moments = ImageSearchDao.default.getMomentsByPlace(.MONTH, parent: parent, condition: condition)
                    }else if parent.day == 0 {
//                        self.logger.log(.trace, "loading days")
                        moments = ImageSearchDao.default.getMomentsByPlace(.DAY, parent: parent, condition: condition)
                    }
                    for moment in moments {
                        let node = self.convertDateToTreeCollection(moment)
                        nodes.append(node)
                    }
                    return (nodes, nil, nil)
                }else{
//                    self.logger.log(.trace, "parent place is empty")
                }
                
            }else{
//                self.logger.log(.trace, "PlacesTreeDS: no related object")
            }
        }
        return ([], nil, nil)
    }
    
    func findNode(path: String) -> TreeCollection? {
        return nil
    }
    
    func filter(keyword: String) {
        
    }
    
    func findNode(keyword: String) -> TreeCollection? {
        return nil
    }
    

}
