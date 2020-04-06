//
//  ModelStore+Image.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/9/22.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class ImageRecordDaoGRDB : ImageRecordDaoInterface {
    
    
    // MARK: - CREATE
    
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String? = nil) -> Image{
        var image:Image?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                image = try Image.fetchOne(db, key: path)
            }
            if image == nil {
                let queue = try DatabaseQueue(path: SQLiteDataSource.default.getDataSource())
                try queue.write { db in
                    image = Image.new(filename: filename, path: path, parentFolder: parentPath, repositoryPath: repositoryPath ?? "")
                    try image?.save(db)
                }
                
            }
        }catch{
            print(error)
        }
        return image!
    }
    
    // MARK: - GETTER
    
    func getImage(path:String) -> Image?{
        var image:Image?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                image = try Image.fetchOne(db, key: path)
            }
        }catch{
            print(error)
        }
        return image
    }
    
    func getImage(id:String) -> Image? {
        var image:Image?
        do {
            let db = ModelStoreGRDB.sharedDBPool()
            try db.read { db in
                image = try Image.filter(sql: "id='\(id)'").fetchOne(db)
            }
        }catch{
            print(error)
        }
        return image
    }
    
}
