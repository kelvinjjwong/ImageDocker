//
//  Row.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation



class PostgresRow : CustomStringConvertible {
    
    public var table:String = ""
    
    /// The values of the columns for this `Row`.
    public var values: [PostgresRowValueConvertible]
    public var columnNames: [String]
    public var types: [DatabaseType]
    
    /// Creates a `Row`.
    ///
    /// - Parameter columns: the column values
    init(columnNames:[String], types:[DatabaseType] = [], values: [PostgresRowValueConvertible]) {
        self.columnNames = columnNames
        self.types = types
        self.values = values
    }
    
    public static func read<T:Decodable>(_ object:T, types:[DatabaseType], values:[PostgresRowValueConvertible])  -> PostgresRow {
        let mirror = Mirror(reflecting: object)
        var columnNames:[String] = []
        for child in mirror.children {
            if let column = child.label {
                columnNames.append(column)
            }
        }
        return PostgresRow(columnNames: columnNames, types: types, values: values)
        
    }
    
    public func hasNull(atIndex index:Int) -> Bool {
        guard index >= 0 && index < values.count else {
            return true
        }
        return values[index].postgresValue.isNull
    }
    
    public func hasNull(atColumn name: String) -> Bool {
        if let idx = index(ofColumn: name) {
            return hasNull(atIndex: idx)
        }else{
            return true
        }
    }
    
    /// Returns true if and only if the row has that column.
    ///
    /// This method is case-insensitive.
    public func hasColumn(_ columnName: String) -> Bool {
        return index(ofColumn: columnName) != nil
    }
    
    func index(ofColumn name: String) -> Int? {
        let lowercaseName = name.lowercased()
        return columnNames.firstIndex { columnName in columnName.lowercased() == lowercaseName }
    }
    
    
    
    /// Returns Int64, Double, String, Data or nil, depending on the value
    /// stored at the given column.
    ///
    /// Column name lookup is case-insensitive, and when several columns have
    /// the same name, the leftmost column is considered.
    ///
    /// The result is nil if the row does not contain the column.
    public subscript(_ columnName: String) -> PostgresRowValueConvertible? {
        // IMPLEMENTATION NOTE
        // This method has a single know use case: checking if the value is nil,
        // as in:
        //
        //     if row["foo"] != nil { ... }
        //
        // Without this method, the code above would not compile.
        guard let index = index(ofColumn: columnName) else {
            return nil
        }
        return values[index]
    }
    
    
    
    
    public subscript<Value:PostgresRowValueConvertible>(_ columnName: String) -> Value {
        guard let index = index(ofColumn: columnName) else {
            fatalError("Unable to convert value of column \(columnName)")
        }
        //self.logger.log("debug 11")
        return Value.decode(from: self, atUncheckedIndex: index)
    }
    
    
    public subscript<Value:PostgresRowValueConvertible>(_ columnName: String) -> Value? {
        guard let index = index(ofColumn: columnName) else {
            return nil
        }
        //self.logger.log("debug 8")
        return Value.decodeIfPresent(from: self, atUncheckedIndex: index)
    }
    
    
    public subscript(_ index: Int) -> PostgresRowValueConvertible? {
        // IMPLEMENTATION NOTE
        // This method has a single know use case: checking if the value is nil,
        // as in:
        //
        //     if row["foo"] != nil { ... }
        //
        // Without this method, the code above would not compile.
        guard index >= 0 || index < values.count else {
            return nil
        }
        return values[index]
    }
    
    public subscript<Value:PostgresRowValueConvertible>(_ index: Int) -> Value {
        //self.logger.log("debug 12")
        return Value.decode(from: self, atUncheckedIndex: index)
    }
    
    
    public subscript<Value:PostgresRowValueConvertible>(_ index: Int) -> Value? {
        guard index >= 0 || index < values.count else {
            return nil
        }
        //self.logger.log("debug 9")
        return Value.decodeIfPresent(from: self, atUncheckedIndex: index)
    }
    
    //
    // MARK: CustomStringConvertible
    //
    
    /// A string representation of this `Row`.
    public var description: String {
        return "Row(values: \(values))"
    }
    
    
}
