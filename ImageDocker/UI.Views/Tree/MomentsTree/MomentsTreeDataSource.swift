//
//  MomentsTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class MomentsTreeDataSource : TreeDataSource {
    
    let dao = ImageSearchDao()
    
    func convertToTreeCollection(_ data:Moment) -> TreeCollection {
        let collection = TreeCollection(data.represent, id: data.id, object: data)
        if data.day == 0 {
            collection.expandable = true
        }
        return collection
    }
    
    func loadChildren(_ collection: TreeCollection?) -> ([TreeCollection], String?) {
        var nodes:[TreeCollection] = []
        var datas:[Moment] = []
        if collection == nil {
            datas = self.dao.getMoments(.YEAR)
        }else{
            if let parent = collection?.relatedObject as? Moment {
                if parent.month == 0 {
                    datas = self.dao.getMoments(.MONTH, year: parent.year)
                }else if parent.day == 0 {
                    datas = self.dao.getMoments(.DAY, year: parent.year, month: parent.month)
                }
            }
        }
        if datas.count > 0 {
            for data in datas {
                let node = self.convertToTreeCollection(data)
                nodes.append(node)
            }
        }
        return (nodes, nil)
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
