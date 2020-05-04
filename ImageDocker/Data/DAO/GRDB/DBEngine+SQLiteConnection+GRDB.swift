//
//  DBEngine+GRDB.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import GRDB

public final class SQLiteConnectionGRDB : ImageDBInterface {
    
    
    
    static let `default` = SQLiteConnectionGRDB()
    
    internal var _sharedDBPool:DatabaseWriter?
    
    func sharedDBPool() throws -> DatabaseWriter {
        if let pool = self._sharedDBPool {
            return pool
        }
        _sharedDBPool = try DatabasePool(path: SQLiteDataSource.default.getDataSource())
        return _sharedDBPool!
    }
    
    func testDatabase() -> (Bool, Error?) {
        do {
            let _ = try self.sharedDBPool()
            return (true, nil)
        }catch{
            return (false, error)
        }
        
    }
    
    func execute(sql: String) throws {
        let db = try SQLiteConnectionGRDB.default.sharedDBPool()
        let _ = try db.write { db in
            try db.execute(sql: sql)
        }
    }
    
    func execute(definition: DatabaseTableDefinition) throws {
        
    }
}
