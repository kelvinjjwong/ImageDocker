//
//  DatabaseColumnTypes.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/21.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

public struct ColumnType: RawRepresentable, Hashable {
    /// :nodoc:
    public let rawValue: String
    
    /// :nodoc:
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// The `TEXT` SQL column type
    public static let text = ColumnType("TEXT")
    
    /// The `INTEGER` SQL column type
    public static let integer = ColumnType("INTEGER")
    
    public static let smallinteger = ColumnType("SMALLINTEGER")
    
    public static let biginteger = ColumnType("BIGINTEGER")
    
    // The `SERIAL` SQL column type
    //
    // see: https://www.postgresql.org/docs/9.2/datatype-numeric.html#DATATYPE-SERIAL
    //
    public static let serial = ColumnType("SERIAL")
    
    public static let smallserial = ColumnType("SMALLSERIAL")
    
    public static let bigserial = ColumnType("BIGSERIAL")
    
    /// The `DOUBLE` SQL column type
    public static let double = ColumnType("DOUBLE")
    
    /// The `NUMERIC` SQL column type
    public static let numeric = ColumnType("NUMERIC")
    
    /// The `BOOLEAN` SQL column type
    public static let boolean = ColumnType("BOOLEAN")
    
    /// The `BLOB` SQL column type
    public static let blob = ColumnType("BLOB")
    
    /// The `DATE` SQL column type
    public static let date = ColumnType("DATE")
    
    /// The `DATETIME` SQL column type
    public static let datetime = ColumnType("DATETIME")
}
