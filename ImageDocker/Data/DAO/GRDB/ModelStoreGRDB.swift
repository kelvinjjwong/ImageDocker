//
//  ModelStore.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2018/7/14.
//  Copyright © 2018年 nonamecat. All rights reserved.
//

import Foundation
import GRDB

class ModelStoreGRDB {
    
    
    
    init(){
        self.checkDatabase()
        self.versionCheck()
    }
    
    // MARK: - SHARED DATABASE INSTANCE
    
    private static var _sharedDBPool:DatabaseWriter?
    
    static func sharedDBPool() -> DatabaseWriter{
        if _sharedDBPool == nil {
            do {
                //var config = Configuration()
                //config.trace = { print($0) }     // Prints all SQL statements
                
                _sharedDBPool = try DatabasePool(path: SQLiteDataSource.default.getDataSource()
                    //, configuration: config
                                                )
            }catch{
                print(error) //SQLite error 5: database is locked
            }
            
        }
        return _sharedDBPool!
    }
    
    // MARK: - HEALTH CHECK
    
    func testDatabase() -> (Bool, Error?) {
        if ModelStoreGRDB._sharedDBPool == nil {
//            if debug_attempt == debug_pass_at {
                do {
                    //var config = Configuration()
                    //config.trace = { print($0) }     // Prints all SQL statements
                    
                    ModelStoreGRDB._sharedDBPool = try DatabasePool(path: SQLiteDataSource.default.getDataSource()
                        //, configuration: config
                        )
                }catch{
                    print(error) //SQLite error 5: database is locked
                    return (false, error)
                }
//            }else{
//                debug_attempt += 1
//            }
            if ModelStoreGRDB._sharedDBPool == nil {
                return (false, nil)
            }else{
                return (true, nil)
            }
        }else{
            return (true, nil)
        }
    }
    
    func checkDatabase() {
        let dbpath = URL(fileURLWithPath: SQLiteDataSource.default.getDataSource()).deletingLastPathComponent().path
        if !FileManager.default.fileExists(atPath: dbpath) {
            do {
                try FileManager.default.createDirectory(atPath: dbpath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Unable to create directory for database file")
                print(error)
            }
        }
    }
}
