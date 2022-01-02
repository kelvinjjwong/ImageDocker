//
//  String.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/20.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

extension String {
    /// Returns the receiver, quoted for safe insertion as an identifier in an
    /// SQL query.
    ///
    ///     db.execute(sql: "SELECT * FROM \(tableName.quotedDatabaseIdentifier)")
    @inlinable public var quotedDatabaseIdentifier: String {
        return "\"\(self)\""
    }
    
    @inlinable public var quotedDatabaseValueIdentifier: String {
        return "\'\(self)\'"
    }
}


@usableFromInline
func add(_ value: inout Int) -> String {
    value += 1
    return "$\(value)"
}

extension Array {
    
    @inlinable public func joinedQuoted(separator: String) -> String {
        var values:[String] = []
        for value in self {
            values.append("\(value)".quotedDatabaseIdentifier)
        }
        return values.joined(separator: separator)
    }
    
    @inlinable public func joinedSingleQuoted(separator: String) -> String {
        var values:[String] = []
        for value in self {
            values.append("\(value)".quotedDatabaseValueIdentifier)
        }
        return values.joined(separator: separator)
    }
}
