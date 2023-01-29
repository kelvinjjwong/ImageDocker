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
    
    
    
    let logger = ConsoleLogger(category: "DB", subCategory: "ImageRecordDaoGRDB")
    
    
    // MARK: - QUERY
    
    func getImage(path:String) -> Image?{
        var image:Image?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                image = try Image.fetchOne(db, key: path)
            }
        }catch{
            self.logger.log(error)
        }
        return image
    }
    
    func getImage(id:String) -> Image? {
        var image:Image?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
            try db.read { db in
                image = try Image.filter(sql: "id='\(id)'").fetchOne(db)
            }
        }catch{
            self.logger.log(error)
        }
        return image
    }
    
    func findImage(repositoryVolume:String, repositoryPath:String, subPath:String) -> Image? {
        self.logger.log(.todo, "TODO function for SQLite")
        return nil
    }
    
    func findImage(repositoryId:Int, subPath:String) -> Image? {
        self.logger.log(.todo, "TODO function for SQLite")
        return nil
    }
    
    // MARK: - CRUD
    
    func createImage(repositoryId:Int, containerId:Int, repositoryVolume:String, repositoryPath:String, subPath:String) -> Image? {
        self.logger.log(.todo, "TODO function for SQLite")
        return nil
    }
    
    func getOrCreatePhoto(filename:String, path:String, parentPath:String, repositoryPath:String? = nil) -> Image{
        var image:Image?
        do {
            let db = try SQLiteConnectionGRDB.default.sharedDBPool()
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
            self.logger.log(error)
        }
        return image!
    }
    
    func deleteImage(id: String, updateFlag: Bool) -> ExecuteState {
        self.logger.log(.todo, "TODO function for SQLite")
        return .ERROR
    }
    
    // MARK: UPDATE ID
    
    func updateImageWithContainerId(id:String, repositoryId:Int, containerId:Int) -> ExecuteState {
        self.logger.log(.todo, "TODO function for SQLite")
        return .ERROR
    }
    
    func generateImageIdByPath(repositoryVolume:String, repositoryPath:String, subPath:String) -> (ExecuteState, String) {
        self.logger.log(.todo, "TODO function for SQLite")
        return (.ERROR, "")
    }
    
    func generateImageIdByContainerIdAndSubPath(containerId:Int, subPath:String) -> (ExecuteState, String) {
        self.logger.log(.todo, "TODO function for SQLite")
        return (.ERROR, "")
    }
    
}
