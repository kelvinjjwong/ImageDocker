//
//  PlacesTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class PlacesTreeDataSource : TreeDataSource {
    
    let dao = ImageSearchDao.default
    
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
            gov = gov.replacingOccurrences(of: "特别行政区", with: "")
            place = place.replacingOccurrences(of: "特别行政区", with: "")
            
            moment.gov = gov
            moment.place = place
            
            //print("Got place \(gov) -> \(place)")
            
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
                print("ERROR: duplicated place entry \(gov) -> \(place)")
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
        if moment.day == 0 {
            node.expandable = true
        }
        return node
    }
    
    func loadChildren(_ collection: TreeCollection?) -> ([TreeCollection], String?) {
        if collection == nil {
            let moments = self.dao.getMomentsByPlace(.PLACE)
            return (self.convertPlacesToTreeCollections(moments), nil)
        }else{
            if let parentNode = collection, let parent = parentNode.relatedObject as? Moment {
                if parent.place != "" {
                    var nodes:[TreeCollection] = []
                    var moments:[Moment] = []
                    if parent.year == 0 {
                        print("loading years")
                        moments = self.dao.getMomentsByPlace(.YEAR, parent: parent)
                    }else if parent.month == 0 {
                        print("loading months")
                        moments = self.dao.getMomentsByPlace(.MONTH, parent: parent)
                    }else if parent.day == 0 {
                        print("loading days")
                        moments = self.dao.getMomentsByPlace(.DAY, parent: parent)
                    }
                    for moment in moments {
                        let node = self.convertDateToTreeCollection(moment)
                        nodes.append(node)
                    }
                    return (nodes, nil)
                }else{
                    print("parent place is empty")
                }
                
            }else{
                print("PlacesTreeDS: no related object")
            }
        }
        return ([], nil)
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
