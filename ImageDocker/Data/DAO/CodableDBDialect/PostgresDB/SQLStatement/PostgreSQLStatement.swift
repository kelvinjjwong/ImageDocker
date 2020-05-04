//
//  SQLStatement.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/20.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit

/// A statement represents an SQL query.
///
/// It is the base class of UpdateStatement that executes *update statements*,
/// and SelectStatement that fetches rows.
public class SQLStatement {
    
    /// The SQL query
    public var sql:String = ""
    
    public var arguments:[PostgresValueConvertible?] = []
    
    //unowned let database: Database
    
    init(sql:String) {
        self.sql = sql
    }
    
    deinit {
    }
}


public final class PostgreSQLStatementGenerator<Record: EncodableDBRecord> {
    
    /// DAO keeps a copy the record's persistenceContainer, so that this
    /// dictionary is built once whatever the database operation. It is
    /// guaranteed to have at least one (key, value) pair.
    let persistenceContainer: PostgresDBValueContainer
    
    /// The table name
    let databaseTableName: String
    
    public init(table:String, record: Record) {
        self.databaseTableName = table
        persistenceContainer = PostgresDBValueContainer(record)
    }
    
    func insertStatement() -> SQLStatement {
        let query = InsertQuery(
            tableName: databaseTableName,
            columns: persistenceContainer.columns)
        let statement = SQLStatement(sql: query.sql)
        statement.arguments = persistenceContainer.values
        return statement
    }
    
    func updateStatement(keyColumns: [String]) -> SQLStatement {
        
        let setA = Set(persistenceContainer.columns)
        let setB = Set(keyColumns)
        let diff = setA.subtracting(setB)
        let updateColumns = Array(diff)
        
        let query = UpdateQuery(
            tableName: databaseTableName,
            columns: updateColumns,
            conditionColumns: keyColumns)
        let statement = SQLStatement(sql: query.sql)
        statement.arguments = persistenceContainer.valuesOf(columns: updateColumns) + persistenceContainer.valuesOf(columns: keyColumns)
        return statement
    }
    
    func deleteStatement(keyColumns: [String]) -> SQLStatement {
        
        let query = DeleteQuery(
            tableName: databaseTableName,
            conditionColumns: keyColumns)
        let statement = SQLStatement(sql: query.sql)
        statement.arguments = persistenceContainer.valuesOf(columns: keyColumns)
        return statement
    }
    
    func existsStatement(keyColumns: [String]) -> SQLStatement {
        
        let query = ExistsQuery(
            tableName: databaseTableName,
            conditionColumns: keyColumns)
        let statement = SQLStatement(sql: query.sql)
        statement.arguments = persistenceContainer.valuesOf(columns: keyColumns)
        return statement
    }
    
    func selectStatement(columns:String = "", keyColumns: [String], orderBy:String = "", schema:String = "public") -> SQLStatement {
        
        let query = SelectQuery(
            schema: schema,
            tableName: databaseTableName,
            selectColumns: columns,
            conditionColumns: keyColumns,
            whereSQL: "",
            orderBy: orderBy)
        let statement = SQLStatement(sql: query.sql)
        statement.arguments = persistenceContainer.valuesOf(columns: keyColumns)
        return statement
    }
    
    func selectStatement(where whereSQL:String, orderBy:String = "", values:[PostgresValueConvertible?] = [], schema:String = "public") -> SQLStatement {
        
        let query = SelectQuery(
            schema: schema,
            tableName: databaseTableName,
            selectColumns: "",
            conditionColumns: [],
            whereSQL: whereSQL,
            orderBy: orderBy)
        let statement = SQLStatement(sql: query.sql)
        statement.arguments = values
        return statement
    }
    
    func countStatement(keyColumns: [String], schema:String = "public") -> SQLStatement {
        
        let query = CountQuery(
            schema: schema,
            tableName: databaseTableName,
            conditionColumns: keyColumns,
            whereSQL: "")
        let statement = SQLStatement(sql: query.sql)
        statement.arguments = persistenceContainer.valuesOf(columns: keyColumns)
        return statement
    }
    
    func countStatement(where whereSQL:String, values:[PostgresValueConvertible?] = [], schema:String = "public") -> SQLStatement {
        
        let query = CountQuery(
            schema: schema,
            tableName: databaseTableName,
            conditionColumns: [],
            whereSQL: whereSQL)
        let statement = SQLStatement(sql: query.sql)
        statement.arguments = values
        return statement
    }
}
