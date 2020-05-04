//
//  TableInfo.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

public enum DatabaseType {
    case int
    case double
    case string
    case date
    case unknown
}

public class TableInfo {
    
    var name: String = ""
    var columns:[PostgresColumnInfo] = []
    
    
    public init(_ name:String) {
        self.name = name
    }
    
    public func add(column:PostgresColumnInfo) {
        self.columns.append(column)
    }
    
    public func columnNames() -> [String] {
        var names:[String] = []
        for column in columns {
            names.append(column.column_name)
        }
        return names
    }
    
    public func columnTypes() -> [DatabaseType] {
        var types:[DatabaseType] = []
        for column in columns {
            types.append(column.type())
        }
        return types
    }
    
    
}

public class PostgresColumnInfo : Codable & EncodableDBRecord {
    
    var column_name:String = ""
    var data_type:String = ""
    var is_nullable:String = ""
    var is_identity:String = ""
    var character_maximum_length:Int? = nil
    var numeric_precision:Int? = nil
    var numeric_precision_radix:Int? = nil
    
    public init() {
        
    }
    
    public func isNullable() -> Bool {
        return is_nullable == "YES"
    }
    
    public func isIdentity() -> Bool {
        return is_identity == "YES"
    }
    
    public func type() -> DatabaseType {
        if data_type == "integer" {
            return .int
        }
        if data_type == "character varying" {
            return .string
        }
        if data_type == "date" {
            return .date
        }
        if data_type == "real" {
            return .double
        }
        return .unknown
    }
}
