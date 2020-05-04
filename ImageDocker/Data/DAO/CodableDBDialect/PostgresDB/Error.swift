//
//  Error.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/20.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit

@usableFromInline
func fatalConversionError<T>(
    to: T.Type,
    from dbValue: PostgresValue?)
    -> Never
{
    fatalError("Unable to convert from \(dbValue ?? PostgresValue(nil)) to \(to)")
}



/// The error for missing columns
public struct MissingColumnError: Error {
    var column: String
}

/// The error that triggers JSON decoding
public struct JSONRequiredError: Error { }



/// An error thrown by a type that adopts PersistableRecord.
public enum PersistenceError: Error, CustomStringConvertible {
    
    /// Thrown by MutablePersistableRecord.update() when no matching row could be
    /// found in the database.
    ///
    /// - databaseTableName: the table of the unfound record
    /// - key: the key of the unfound record (column and values)
    case recordNotFound(databaseTableName: String, key: [String: PostgresValue])
}

// CustomStringConvertible
extension PersistenceError {
    /// :nodoc:
    public var description: String {
        switch self {
        case let .recordNotFound(databaseTableName: databaseTableName, key: key):
            let keys = key.keys.joined(separator: ", ")
            return "Key not found in table \(databaseTableName): \(keys)"
        }
    }
}
