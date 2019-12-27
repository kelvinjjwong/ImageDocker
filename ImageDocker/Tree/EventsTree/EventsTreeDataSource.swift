//
//  EventsTreeDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/12/27.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation

class EventsTreeDataSource : TreeDataSource {
    
    func convertFlatToTree() {
        
    }
    
    func loadChildren(_ collection: TreeCollection?) -> [TreeCollection] {
        return []
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
