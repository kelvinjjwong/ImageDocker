//
//  ModelStore+Image+Meta.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

extension ModelStore {
    
    // MARK: - Options
    
    func getImageSources() -> [String:Bool]{
        var results:[String:Bool] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT DISTINCT imageSource FROM Image")
                for row in rows {
                    let src = row["imageSource"] as String?
                    if let src = src, src != "" {
                        results[src] = false
                    }
                }
            }
        }catch{
            print(error)
        }
        
        return results
    }
    
    func getCameraModel() -> [String:Bool] {
        var results:[String:Bool] = [:]
        do {
            let db = ModelStore.sharedDBPool()
            try db.read { db in
                let rows = try Row.fetchAll(db, "SELECT DISTINCT cameraMaker,cameraModel FROM Image")
                for row in rows {
                    let name1:String = row["cameraMaker"] ?? ""
                    let name2:String = row["cameraModel"] ?? ""
                    if name1 != "" && name2 != "" {
                        results["\(name1),\(name2)"] = false
                    }
                }
            }
        }catch{
            print(error)
        }
        
        return results
    }

}
