//
//  ValueTypeConversion.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit



public protocol PostgresRowValueProtocol {
    
    static func fromPostgresValue(_ dbValue: PostgresValue) -> Self?
}

extension PostgresRowValueProtocol {
    
    static func decode(from row: PostgresRow, atUncheckedIndex index: Int) -> Self {
        //print("column size: \(row.values.count), decode index: \(index)")
        let dbValue = row.values[index].postgresValue
        //self.logger.log("decoding table [\(row.table)] column: \(row.columnNames[index])")
        //self.logger.log(" >> value to be decoded: \(dbValue.rawValue ?? "nil")")
        if let value = fromPostgresValue(dbValue) {
//            self.logger.log("decoding column: \(row.columnNames[index])")
//            self.logger.log("value to be decoded: \(dbValue.rawValue ?? "nil")")
//            self.logger.log("value decoded: \(value)")
            return value
        } else {
            print("\(Date()) [PostgresRowValueProtocol] fatal error: decoding table [\(row.table)] column: \(row.columnNames[index])")
            print("\(Date()) [PostgresRowValueProtocol] fatal error: >> value to be decoded: \(dbValue.rawValue ?? "nil")")
            fatalConversionError(to: Self.self, from: dbValue)
        }
    }
    
    static func decodeIfPresent(from row: PostgresRow, atUncheckedIndex index: Int) -> Self? {
        //self.logger.log("decodeIfPresent column size: \(row.values.count), decode index: \(index)")
        let dbValue = row.values[index].postgresValue
        //self.logger.log("decodeIfPresent decoding table [\(row.table)] column: \(row.columnNames[index])")
        //self.logger.log(" >> decodeIfPresent value to be decoded: \(dbValue.rawValue ?? "nil")")
        if let value = fromPostgresValue(dbValue) {
            return value
        } else {
            return nil
        }
    }
}

typealias PostgresRowValueConvertible = PostgresValueConvertible & PostgresRowValueProtocol

extension PostgresValue : PostgresRowValueProtocol {
    
    public static func fromPostgresValue(_ dbValue: PostgresValue) -> PostgresValue? {
        return dbValue
    }
    
}

extension Data : PostgresRowValueConvertible {
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Data? {
        if value.isNull {
            return nil
        }else{
            return value.rawValue?.data(using: .utf8)
        }
    }
    
}

extension Bool : PostgresRowValueProtocol {
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Bool? {
        if value.isNull {
            return nil
        }else{
            do {
                return try value.bool()
            }catch{
                return nil
            }
        }
    }
}

extension String : PostgresRowValueProtocol {
    
    public static func fromPostgresValue(_ value:PostgresValue) -> String? {
        if value.isNull {
            return nil
        }else{
            do {
                return try value.string()
            }catch{
                return nil
            }
        }
    }
    
}

extension Decimal : PostgresRowValueProtocol {
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Decimal? {
        if value.isNull {
            return nil
        }else{
            do {
                return try value.decimal()
            }catch{
                return nil
            }
        }
    }
    
}

extension Double : PostgresRowValueProtocol {
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Double? {
        if value.isNull {
            return nil
        }else{
            do {
                return try value.double()
            }catch{
                return nil
            }
        }
    }
    
}

extension Float : PostgresRowValueConvertible {
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Float? {
        if value.isNull {
            return nil
        }else{
            do {
                return try Float(value.double())
            }catch{
                return nil
            }
        }
    }
    
}

extension Int : PostgresRowValueProtocol {
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Int? {
        if value.isNull {
            return nil
        }else{
            do {
                return try value.int()
            }catch{
                return nil
            }
        }
    }
    
}

extension Int8 : PostgresRowValueConvertible {
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Int8? {
        if value.isNull {
            return nil
        }else{
            do {
                return try Int8(value.int())
            }catch{
                return nil
            }
        }
    }
    
}

extension Int16 : PostgresRowValueConvertible {
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Int16? {
        if value.isNull {
            return nil
        }else{
            do {
                return try Int16(value.int())
            }catch{
                return nil
            }
        }
    }
    
}

extension Int32 : PostgresRowValueConvertible {
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Int32? {
        if value.isNull {
            return nil
        }else{
            do {
                return try Int32(value.int())
            }catch{
                return nil
            }
        }
    }
    
}

extension Int64 : PostgresRowValueConvertible {
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Int64? {
        if value.isNull {
            return nil
        }else{
            do {
                return try Int64(value.int())
            }catch{
                return nil
            }
        }
    }
    
}



extension UInt : PostgresRowValueConvertible {
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public static func fromPostgresValue(_ value:PostgresValue) -> UInt? {
        if value.isNull {
            return nil
        }else{
            do {
                return try UInt(value.int())
            }catch{
                return nil
            }
        }
    }
    
}

extension UInt8 : PostgresRowValueConvertible {
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public static func fromPostgresValue(_ value:PostgresValue) -> UInt8? {
        if value.isNull {
            return nil
        }else{
            do {
                return try UInt8(value.int())
            }catch{
                return nil
            }
        }
    }
    
}

extension UInt16 : PostgresRowValueConvertible {
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public static func fromPostgresValue(_ value:PostgresValue) -> UInt16? {
        if value.isNull {
            return nil
        }else{
            do {
                return try UInt16(value.int())
            }catch{
                return nil
            }
        }
    }
    
}

extension UInt32 : PostgresRowValueConvertible {
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public static func fromPostgresValue(_ value:PostgresValue) -> UInt32? {
        if value.isNull {
            return nil
        }else{
            do {
                return try UInt32(value.int())
            }catch{
                return nil
            }
        }
    }
    
}

extension UInt64 : PostgresRowValueConvertible {
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public static func fromPostgresValue(_ value:PostgresValue) -> UInt64? {
        if value.isNull {
            return nil
        }else{
            do {
                return try UInt64(value.int())
            }catch{
                return nil
            }
        }
    }
    
}

extension Date : PostgresRowValueConvertible {
    
    public static var postgresTimeZone : TimeZone {
        return TimeZone(identifier: "UTC") ?? .current
    }
    
    public static var localTimeZone : TimeZone {
        return TimeZone.current
    }
    
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: self))
    }
    
    public func timezone(from: TimeZone, to: TimeZone) -> Date {
        let fromOffset =  Double(from.secondsFromGMT())
        let toOffset = Double(to.secondsFromGMT())
        return Date(timeIntervalSince1970: self.timeIntervalSince1970 - fromOffset + toOffset)
    }
    
    
    public static func fromPostgresValue(_ value:PostgresValue) -> Date? {
        if value.isNull {
            return nil
        }else{
            do {
                return try value.date().date(in: Date.postgresTimeZone)
            }catch{
                do {
                    return try value.timestamp().date(in: Date.postgresTimeZone)
                }catch{
                    do {
                        return try value.timestampWithTimeZone().date
                    }catch{
                        return nil
                    }
                }
            }
        }
    }
    
}
