//
//  DBEngine.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

public final class ImageDB {
    
    let impl:ImageDBInterface
    
    let dataSource:ImageDBDataSource
    
    static let LocalSQLite = ImageDB(impl: SQLiteGRDB.default, dataSource: SQLiteDataSource.default)
    
    private init(impl:ImageDBInterface, dataSource:ImageDBDataSource) {
        self.impl = impl
        self.dataSource = dataSource
    }
    
    func testDatabase() -> (Bool, Error?) {
        return self.impl.testDatabase()
    }
    
    func checkDatabase() -> (Bool, Error?) {
        return self.dataSource.exists()
    }
    
}

protocol ImageDBInterface {
    
    func testDatabase() -> (Bool, Error?)
    
}

// MARK: - Data Source

protocol ImageDBDataSource {
    
    func getDataSource() -> String
    
    func exists() -> (Bool, Error?)
}

protocol ImageDBFileDataSource : ImageDBDataSource {
    
}

extension ImageDBFileDataSource {
    
    func exists() -> (Bool, Error?) {
        let dbpath = URL(fileURLWithPath: getDataSource()).deletingLastPathComponent().path
        if !FileManager.default.fileExists(atPath: dbpath) {
            do {
                try FileManager.default.createDirectory(atPath: dbpath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Unable to create directory for database file")
                print(error)
                return (false, error)
            }
        }
        return (true, nil)
    }
}

public final class SQLiteDataSource : ImageDBFileDataSource {
    
    static let `default` = SQLiteDataSource()
    
    private static var customs : [String : SQLiteDataSource] = [:]
    
    static func custom(name:String, path:String, filename: String) -> SQLiteDataSource {
        if let inst = customs[name] {
            return inst
        }else{
            let instance = SQLiteDataSource()
            instance._dbFile = "\(path)/\(filename)"
            customs[name] = instance
            return instance
        }
    }
    
    static func get(name: String) -> SQLiteDataSource? {
        return customs[name]
    }
    
    private var _dbFile = ""
    
    func getDataSource() -> String {
        if _dbFile == "" {
            _dbFile = PreferencesController.databasePath(filename: "ImageDocker.sqlite")
        }
        return _dbFile
    }
}

