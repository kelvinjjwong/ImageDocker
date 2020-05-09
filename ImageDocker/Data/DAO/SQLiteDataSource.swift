//
//  SQLiteDataSource.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/5/8.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

public final class SQLiteDataSource {
    
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
