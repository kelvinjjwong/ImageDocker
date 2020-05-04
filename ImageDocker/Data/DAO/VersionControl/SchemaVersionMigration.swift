//
//  SchemaChanges.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/21.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

public protocol DBExecutor {
    func execute(sql:String) throws
    func count(sql:String) -> Int
}

public protocol SchemaSQLGenerator {
    
    func transform(_ definition:DatabaseTableDefinition) -> [String]
    func exists(version: String) -> String
    func initialise() -> String
    func cleanVersions() -> String
    func add(version: String) -> String
}

public protocol DatabaseChangeImplement {
    
    func apply(change:DatabaseTableDefinition) throws
    func exists(version:String) -> Bool
    func add(version:String) throws
    func initialise() throws
    func cleanVersions() throws
}

public final class DatabaseChange {
    
    private let impl:DatabaseChangeImplement
    
    init(impl: DatabaseChangeImplement){
        self.impl = impl
    }
    
    public func createSequence(name:String) throws {
        let definition = DatabaseTableDefinition(name: name, action: .createSequence)
        try self.impl.apply(change: definition)
    }
    
    public func dropSequence(name:String) throws {
        let definition = DatabaseTableDefinition(name: name, action: .dropSequence)
        try self.impl.apply(change: definition)
    }
    
    public func create(table name: String, body collect:(DatabaseTableDefinition) -> Void) throws {
        let definition = DatabaseTableDefinition(name: name, action: .create)
        collect(definition)
        try self.impl.apply(change: definition)
    }
    
    public func alter(table name: String, body collect: (DatabaseTableDefinition) -> Void) throws {
        let alteration = DatabaseTableDefinition(name: name, action: .alter)
        collect(alteration)
        try self.impl.apply(change: alteration)
    }
    
    public func drop(table name: String) throws {
        let drop = DatabaseTableDefinition(name: name, action: .drop)
        try self.impl.apply(change: drop)
    }
    
    public func update(sql:String) throws {
        let update = DatabaseTableDefinition(sql: sql)
        try self.impl.apply(change: update)
    }
}

public final class DefaultDatabaseChangeImplementer : DatabaseChangeImplement {
    
    private let sqlGenerator:SchemaSQLGenerator
    private let sqlExecutor:DBExecutor
    
    public init(sqlGenerator:SchemaSQLGenerator, sqlExecutor:DBExecutor) {
        self.sqlGenerator = sqlGenerator
        self.sqlExecutor = sqlExecutor
    }
    
    public func apply(change: DatabaseTableDefinition) throws {
        let sqls = self.sqlGenerator.transform(change)
        for sql in sqls {
            try self.sqlExecutor.execute(sql: sql)
        }
    }
    
    public func exists(version: String) -> Bool {
        let count = self.sqlExecutor.count(sql: self.sqlGenerator.exists(version: version))
        return count > 0
    }
    
    public func add(version:String) throws {
        try self.sqlExecutor.execute(sql: self.sqlGenerator.add(version: version))
    }
    
    public func initialise() throws {
        try self.sqlExecutor.execute(sql: self.sqlGenerator.initialise())
    }
    
    public func cleanVersions() throws {
        try self.sqlExecutor.execute(sql: self.sqlGenerator.cleanVersions())
    }
    
}


public final class DatabaseVersionMigrator {
    
    var versions:[String] = []
    var migrators:[String : ((DatabaseChange) throws -> Void)] = [:]
    
    private let impl: DatabaseChangeImplement
    
    init(sqlGenerator:SchemaSQLGenerator, sqlExecutor:DBExecutor) {
        self.impl = DefaultDatabaseChangeImplementer(sqlGenerator: sqlGenerator, sqlExecutor: sqlExecutor)
    }
    
    init(impl: DatabaseChangeImplement) {
        self.impl = impl
    }
    
    func version(_ version:String, migrate: @escaping (DatabaseChange) throws -> Void) {
        self.migrators[version] = migrate
        self.versions.append(version)
    }
    
    func migrate(cleanVersions:Bool = false) throws {
        if versions.count > 0 {
            let database = DatabaseChange(impl: impl)
            try impl.initialise()
            if cleanVersions {
                try impl.cleanVersions()
            }
            for version in versions {
                if let migration = migrators[version] {
                    if !impl.exists(version: version) {
                        try migration(database)
                        try impl.add(version: version)
                    }
                }
            }
        }
    }
}




