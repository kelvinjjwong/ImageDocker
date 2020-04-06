//
//  DBEngine+GRDB.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import GRDB

public final class SQLiteGRDB : ImageDBInterface {
    
    static let `default` = SQLiteGRDB()
    
    internal var _sharedDBPool:DatabaseWriter?
    
    func sharedDBPool() -> (DatabaseWriter?, Error?) {
        let (connected, error) = self.testDatabase()
        if connected {
            return (_sharedDBPool, nil)
        }
        return (nil, error)
        
    }
        
    func testDatabase() -> (Bool, Error?) {
        if _sharedDBPool == nil {
//            if debug_attempt == debug_pass_at {
            do {
                //var config = Configuration()
                //config.trace = { print($0) }     // Prints all SQL statements
                
                _sharedDBPool = try DatabasePool(path: SQLiteDataSource.default.getDataSource()
                    //, configuration: config
                    )
            }catch{
                print(error) //SQLite error 5: database is locked
                return (false, error)
            }
//            }else{
//                debug_attempt += 1
//            }
            if _sharedDBPool == nil {
                return (false, nil)
            }else{
                return (true, nil)
            }
        }else{
            return (true, nil)
        }
    }
}
