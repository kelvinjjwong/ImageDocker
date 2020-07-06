
//
//  CRUDStatement.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/23.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation


// MARK: - InsertQuery

public struct InsertQuery: Hashable {
    let tableName: String
    let columns: [String]
}

extension InsertQuery {
    var sql: String {
        let columnsSQL = columns.map { $0.quotedDatabaseIdentifier }.joined(separator: ", ")
        var placeholders:[String] = []
        var i=0
        for _ in columns {
            i += 1
            placeholders.append("$\(i)")
        }
        let valuesSQL = placeholders.joined(separator: ",")
            
        let sql: String = """
                INSERT INTO \(tableName.quotedDatabaseIdentifier) (\(columnsSQL)) \
                VALUES (\(valuesSQL))
                """
        return sql
    }
}


// MARK: - UpdateQuery

public struct UpdateQuery: Hashable {
    let tableName: String
    let columns: [String]
    let conditionColumns: [String]
}

extension UpdateQuery {
    var sql: String {
        
        var placeholders:[String] = []
        var i=0
        for column in columns {
            i += 1
            placeholders.append("\(column.quotedDatabaseIdentifier)=$\(i)")
        }
        let updateSQL = placeholders.joined(separator: ", ")
        
        placeholders.removeAll()
        
        for column in conditionColumns {
            i += 1
            placeholders.append("\(column.quotedDatabaseIdentifier)=$\(i)")
        }
        let whereSQL = placeholders.joined(separator: " AND ")
        let sql: String = """
                UPDATE \(tableName.quotedDatabaseIdentifier) \
                SET \(updateSQL) \
                WHERE \(whereSQL)
                """
        return sql
    }
}


// MARK: - DeleteQuery

public struct DeleteQuery {
    let tableName: String
    let conditionColumns: [String]
}

extension DeleteQuery {
    var sql: String {
        var placeholders:[String] = []
        var i=0
        for column in conditionColumns {
            i += 1
            placeholders.append("\(column.quotedDatabaseIdentifier)=$\(i)")
        }
        let whereSQL = placeholders.joined(separator: " AND ")
        return "DELETE FROM \(tableName.quotedDatabaseIdentifier) WHERE \(whereSQL)"
    }
}


// MARK: - ExistsQuery

public struct ExistsQuery {
    let tableName: String
    let conditionColumns: [String]
}

extension ExistsQuery {
    var sql: String {
        var placeholders:[String] = []
        var i=0
        for column in conditionColumns {
            i += 1
            placeholders.append("\(column.quotedDatabaseIdentifier)=$\(i)")
        }
        let whereSQL = placeholders.joined(separator: " AND ")
        return "SELECT 1 FROM \(tableName.quotedDatabaseIdentifier) WHERE \(whereSQL)"
    }
}



// MARK: - SelectQuery

public struct SelectQuery {
    let schema: String
    let tableName: String
    let selectColumns: String
    let conditionColumns: [String]
    let whereSQL: String
    let orderBy: String
}

extension SelectQuery {
    var sql: String {

        let columns = (selectColumns == "") ? "*" : selectColumns
        var orderStmt = ""
        if orderBy != "" {
            orderStmt = "ORDER BY \(orderBy)"
        }
        var whereStmt = ""
        if whereSQL != "" {
            whereStmt = "WHERE \(whereSQL)"
        }else if conditionColumns.count > 0 {
            var placeholders:[String] = []
            var i=0
            for column in conditionColumns {
                i += 1
                placeholders.append("\(column.quotedDatabaseIdentifier)=$\(i)")
            }
            whereStmt = "WHERE \(placeholders.joined(separator: " AND "))"
        }
        return "SELECT \(columns) FROM \(schema.quotedDatabaseIdentifier).\(tableName.quotedDatabaseIdentifier) \(whereStmt) \(orderStmt)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


// MARK: - CountQuery

public struct CountQuery: Hashable {
    let schema: String
    let tableName: String
    let conditionColumns: [String]
    let whereSQL: String
}

extension CountQuery {
    var sql: String {
        var whereStmt = ""
        if whereSQL != "" {
            whereStmt = "WHERE \(whereSQL)"
        }else if conditionColumns.count > 0 {
            var placeholders:[String] = []
            var i=0
            for column in conditionColumns {
                i += 1
                placeholders.append("\(column.quotedDatabaseIdentifier)=$\(i)")
            }
            whereStmt = "WHERE \(placeholders.joined(separator: " AND "))"
        }
        return "SELECT count(1) FROM \(schema.quotedDatabaseIdentifier).\(tableName.quotedDatabaseIdentifier) \(whereStmt)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
