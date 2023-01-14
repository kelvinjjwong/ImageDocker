//
//  PostgresSchemaGenerator.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/22.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

public final class PostgresSchemaSQLGenerator : SchemaSQLGenerator {
    
    private let dropBeforeCreate:Bool
    
    public init(dropBeforeCreate:Bool = false){
        self.dropBeforeCreate = dropBeforeCreate
    }
    
    private func sqlType(of type: ColumnType?) -> String {
        if let type = type {
            switch type {
            case .text:
                return "TEXT"
            case .blob:
                return "TEXT"
            case .boolean:
                return "BOOL"
            case .date:
                return "timestamp"
            case .datetime:
                return "timestamp"
            case .double:
                return "FLOAT8"
            case .integer:
                return "INTEGER"
            case .smallinteger:
                return "SMALLINTEGER"
            case .biginteger:
                return "BIGINTEGER"
            case .serial:
                return "SERIAL"
            case .smallserial:
                return "SMALLSERIAL"
            case .bigserial:
                return "BIGSERIAL"
            case .numeric:
                return "DECIMAL"
            default:
                return "TEXT"
            }
        }else {
            return ""
        }
    }
    
    public func transform(_ definition:DatabaseTableDefinition) -> [String] {
        if definition.isCreate() {
            return self.createTable(definition, dropBeforeCreate: self.dropBeforeCreate)
        }else if definition.isAlter() {
            return self.alterTable(definition, dropBeforeCreate: self.dropBeforeCreate)
        }else if definition.isDrop() {
            return self.dropTable(definition)
        }else if definition.isPureSQL() {
            return [definition.getSqlStatement()]
        }else if definition.isCreateSequence() {
            return [self.createSequence(definition)]
        }else if definition.isDropSequence() {
            return [self.dropSequence(definition)]
        }
        return []
    }
    
    public func createSequence(_ definition:DatabaseTableDefinition) -> String {
        return "CREATE SEQUENCE IF NOT EXISTS \(definition.getName().quotedDatabaseIdentifier)"
    }
    
    public func dropSequence(_ definition:DatabaseTableDefinition) -> String {
        return "DROP SEQUENCE IF EXISTS \(definition.getName().quotedDatabaseIdentifier)"
    }
    
    public func createTable(_ definition:DatabaseTableDefinition, dropBeforeCreate:Bool = false) -> [String] {
        var sqls:[String] = []
        if dropBeforeCreate {
            sqls.append("DROP TABLE IF EXISTS \(definition.getName().quotedDatabaseIdentifier)")
        }
        var sql = "CREATE TABLE IF NOT EXISTS \(definition.getName().quotedDatabaseIdentifier) (\n\t"
        
        var cols:[String] = []
        
        for column in definition.getColumns() {
            let sqlType = self.sqlType(of: column.getType())
            let col = "\(column.getName().quotedDatabaseIdentifier) \(sqlType)"
            cols.append(col)
        }
        sql += cols.joined(separator: ",\n\t")
        sql += "\n)"
        sqls.append(sql)
        let constraints = self.collectColumnConstraints(definition, dropBeforeCreate: dropBeforeCreate)
        sqls.append(contentsOf: constraints)
        return sqls
        
    }
    
    public func alterTable(_ definition:DatabaseTableDefinition, dropBeforeCreate:Bool = false) -> [String] {
        var cols:[String] = []
        for column in definition.getColumns() {
            if column.action() == .create {
                let sqlType = self.sqlType(of: column.getType())
                cols.append("ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) ADD \(column.getName().quotedDatabaseIdentifier) \(sqlType) ")
            }
            
            if column.action() == .alter {
                if column.getType() != nil {
                    let sqlType = self.sqlType(of: column.getType())
                    cols.append("ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) ALTER COLUMN \(column.getName().quotedDatabaseIdentifier) TYPE \(sqlType)")
                }
            }
            
            if column.action() == .drop {
                cols.append("ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) DROP \(column.getName().quotedDatabaseIdentifier)")
            }
        }
        let constraints = self.collectColumnConstraints(definition, dropBeforeCreate: dropBeforeCreate)
        cols.append(contentsOf: constraints)
        return cols
    }
    
    public func collectColumnConstraints(_ definition:DatabaseTableDefinition, dropBeforeCreate:Bool = false) -> [String] {
        var cols:[String] = []
        var indexedColumns:[String:[String]] = [:]
        var constraintColumns:[String:[String]] = [:]
        for column in definition.getColumns() {
            if column.action() != .drop {
                if let notNull = column.isNotNull() {
                    if notNull == true {
                        cols.append("ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) ALTER COLUMN \(column.getName().quotedDatabaseIdentifier) SET NOT NULL")
                    }else {
                        cols.append("ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) ALTER COLUMN \(column.getName().quotedDatabaseIdentifier) DROP NOT NULL")
                    }
                }
                if let defaultValue = column.getDefaultExpression(), let columnType = column.getDefaultValueType() {
                    var sql = "ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) ALTER COLUMN \(column.getName().quotedDatabaseIdentifier) SET DEFAULT "
                    var bulkUpdateSql = "UPDATE \(definition.getName().quotedDatabaseIdentifier) SET \(column.getName().quotedDatabaseIdentifier) = "
                    let sqlType = self.sqlType(of: columnType)
                    if sqlType == "TEXT" || sqlType == "VARCHAR" {
                        sql += defaultValue.quotedDatabaseValueIdentifier
                        bulkUpdateSql += defaultValue.quotedDatabaseValueIdentifier
                    }else if sqlType == "BOOL" {
                        sql += defaultValue.quotedDatabaseValueIdentifier
                        bulkUpdateSql += defaultValue.quotedDatabaseValueIdentifier
                    }else{
                        sql += defaultValue
                        bulkUpdateSql += defaultValue
                    }
                    bulkUpdateSql += " WHERE \(column.getName().quotedDatabaseIdentifier) IS NULL"
                    cols.append(sql)
                    cols.append(bulkUpdateSql)
                    
                    // TODO: add UPDATE TABLE SQL for the new column with default value
                }
                if let primaryKey = column.isPrimaryKey() {
                    let name = self.getConstraintName(type: "pk", table: definition.getName(), column: column.getName())
                    if primaryKey == true {
                        cols.append("ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) ADD CONSTRAINT \(name.quotedDatabaseIdentifier) PRIMARY KEY (\(column.getName().quotedDatabaseIdentifier))")
                    }else{
                        cols.append("ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) DROP CONSTRAINT \(name.quotedDatabaseIdentifier)")
                    }
                }
                if let _ = column.isIndexed() {
                    let name = self.getConstraintName(type: "index", table: definition.getName(), column: column.getName(), specified: column.indexName())
                    if let _ = indexedColumns[name] {
                        indexedColumns[name]!.append(column.getName())
                    }else{
                        indexedColumns[name] = [column.getName()]
                    }
                }
                if column.isAddUniqueConstraint() {
                    let name = self.getConstraintName(type: "unique", table: definition.getName(), column: column.getName(), specified: column.constraintName())
                    if let _ = constraintColumns[name] {
                        constraintColumns[name]!.append(column.getName())
                    }else{
                        constraintColumns[name] = [column.getName()]
                    }
                }
                if column.isDropUniqueConstraint() {
                    let name = self.getConstraintName(type: "unique", table: definition.getName(), column: column.getName(), specified: column.constraintName())
                    cols.append("ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) DROP CONSTRAINT \(name.quotedDatabaseIdentifier)")
                }
            }
            
            if column.action() == .drop {
                cols.append("ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) DROP \(column.getName().quotedDatabaseIdentifier)")
            }
        }
        for (name, columns) in indexedColumns {
            if dropBeforeCreate {
                cols.append("DROP INDEX IF EXISTS \(name.quotedDatabaseIdentifier)")
            }
            let index = "CREATE INDEX \(name.quotedDatabaseIdentifier) ON \(definition.getName().quotedDatabaseIdentifier) (\(columns.joinedQuoted(separator: ", ")))"
            cols.append(index)
        }
        for (name, columns) in constraintColumns {
            let unique = "ALTER TABLE \(definition.getName().quotedDatabaseIdentifier) ADD CONSTRAINT \(name.quotedDatabaseIdentifier) UNIQUE (\(columns.joinedQuoted(separator: ", ")))"
            cols.append(unique)
        }
        return cols
    }
    
    public func dropTable(_ definition:DatabaseTableDefinition) -> [String] {
        let sql = "DROP TABLE IF EXISTS \(definition.getName().quotedDatabaseIdentifier)"
        return [sql]
    }
    
    
    public func exists(version: String) -> String {
        return "SELECT count(1) FROM version_migrations WHERE ver = '\(version)'"
    }
    
    public func initialise() -> String {
        return "CREATE TABLE IF NOT EXISTS version_migrations (ver VARCHAR)"
    }
    
    public func add(version: String) -> String {
        return "INSERT INTO version_migrations VALUES ('\(version)')"
    }
    
    public func cleanVersions() -> String {
        return "DELETE FROM version_migrations"
    }
    
    private func getConstraintName(type:String, table:String, column:String, specified:String = "") -> String {
        var name = ""
        if specified != "" {
            name = "\(table)_\(type)_\(specified)"
        }else{
            name = "\(table)_\(type)_\(column)"
        }
        return name
    }
}
