//
//  PersistenceContainer.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit

// MARK: - PersistenceContainer

/// Use persistence containers in the `encode(to:)` method of your
/// encodable records:
///
///     struct Player: EncodableRecord {
///         var id: Int64?
///         var name: String?
///
///         func encode(to container: inout PersistenceContainer) {
///             container["id"] = id
///             container["name"] = name
///         }
///     }
public struct PostgresDBValueContainer {
    // fileprivate for Row(_:PersistenceContainer)
    // The ordering of the OrderedDictionary helps generating always the same
    // SQL queries, and hit the statement cache.
    var storage: OrderedDictionary<String, PostgresValueConvertible?>
    
    /// Accesses the value associated with the given column.
    ///
    /// It is undefined behavior to set different values for the same column.
    /// Column names are case insensitive, so defining both "name" and "NAME"
    /// is considered undefined behavior.

    public subscript(_ column: String) -> PostgresValueConvertible? {
        get { return storage[column] ?? nil }
        set { storage.updateValue(newValue, forKey: column) }
    }
    
    init() {
        storage = OrderedDictionary()
    }
    
    init(minimumCapacity: Int) {
        storage = OrderedDictionary(minimumCapacity: minimumCapacity)
    }
    
    /// Convenience initializer from a record
    init<Record: EncodableDBRecord>(_ record: Record) {
        self.init()
        record.encode(to: &self)
    }
    
    /// Columns stored in the container, ordered like values.
    var columns: [String] {
        return Array(storage.keys)
    }
    
    /// Values stored in the container, ordered like columns.
    var values: [PostgresValueConvertible?] {
        return Array(storage.values)
    }
    
    func valuesOf(columns conditionColumns: [String]) -> [PostgresValueConvertible?] {
        var indexes:[Int] = []
        let cols = self.columns
        for col in conditionColumns {
            let colA = col.lowercased()
            var i = -1
            for column in cols {
                i += 1
                let colB = column.lowercased()
                if colA == colB {
                    indexes.append(i)
                    break
                }
            }
        }
        var result:[PostgresValueConvertible?] = []
        for k in indexes {
            result.append(self.values[k])
        }
        return result
    }
    
    /// Accesses the value associated with the given column, in a
    /// case-insensitive fashion.
    ///
    /// :nodoc:
    subscript(caseInsensitive column: String) -> PostgresValueConvertible? {
        get {
            if let value = storage[column] {
                return value
            }
            let lowercaseColumn = column.lowercased()
            for (key, value) in storage where key.lowercased() == lowercaseColumn {
                return value
            }
            return nil
        }
        set {
            if storage[column] != nil {
                storage[column] = newValue
                return
            }
            let lowercaseColumn = column.lowercased()
            for key in storage.keys where key.lowercased() == lowercaseColumn {
                storage[key] = newValue
                return
            }
            
            storage[column] = newValue
        }
    }
    
    // Returns nil if column is not defined
    func value(forCaseInsensitiveColumn column: String) -> PostgresValueConvertible? {
        let lowercaseColumn = column.lowercased()
        for (key, value) in storage where key.lowercased() == lowercaseColumn {
            return value?.postgresValue ?? nil
        }
        return nil
    }
    
    var isEmpty: Bool {
        return storage.isEmpty
    }
    
    /// An iterator over the (column, value) pairs
    func makeIterator() -> IndexingIterator<OrderedDictionary<String, PostgresValueConvertible?>> {
        return storage.makeIterator()
    }
    
    func changesIterator(from container: PostgresDBValueContainer) -> AnyIterator<(String, PostgresValue)> {
        var newValueIterator = makeIterator()
        return AnyIterator {
            // Loop until we find a change, or exhaust columns:
            while let (column, newValue) = newValueIterator.next() {
                let oldValue = container[caseInsensitive: column]
                let oldDbValue = oldValue?.postgresValue ?? PostgresValue(nil)
                let newDbValue = newValue?.postgresValue ?? PostgresValue(nil)
                if newDbValue != oldDbValue {
                    return (column, oldDbValue)
                }
            }
            return nil
        }
    }
}

