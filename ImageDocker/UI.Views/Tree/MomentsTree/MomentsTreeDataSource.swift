//
//  MomentsTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory

class MomentsTreeDataSource : TreeDataSource {
    
    let logger = LoggerFactory.get(category: "Tree", subCategory: "Moments", types: [.trace])
    
    func convertToTreeCollection(_ data:Moment) -> TreeCollection {
        let collection = TreeCollection(data.represent, id: data.id, object: data)
        if data.year == 0 && data.month == 0 && data.day == 0 {
            collection.expandable = false
        }else if data.day == 0 {
            collection.expandable = true
        }
        return collection
    }
    
    func loadChildren(_ collection: TreeCollection?, condition:SearchCondition?) -> ([TreeCollection], String?, String?) {
        self.logger.log(.trace, "loadChildren of collection \(collection) with condition: \(condition)")
        var nodes:[TreeCollection] = []
        var datas:[Moment] = []
        
        if collection == nil {
            datas = ImageSearchDao.default.getMoments(.YEAR, condition: condition)
        }else{
            if let parent = collection?.relatedObject as? Moment {
                if parent.month == 0 {
                    datas = ImageSearchDao.default.getMoments(.MONTH, year: parent.year, condition: condition)
                }else if parent.day == 0 {
                    datas = ImageSearchDao.default.getMoments(.DAY, year: parent.year, month: parent.month, condition: condition)
                }
            }
        }
        if datas.count > 0 {
            for data in datas {
                let node = self.convertToTreeCollection(data)
                nodes.append(node)
            }
        }
        return (nodes, nil, nil)
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
