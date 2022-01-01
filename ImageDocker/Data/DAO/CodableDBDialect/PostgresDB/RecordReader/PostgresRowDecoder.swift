//
//  RowDecoder.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit


// For testability. Not intended to become public as long as FetchableRecord has
// a non-throwing row initializer, since this would open an undesired door.
class PostgresRowDecoder {
    init() { }
    
    func decode<T: Decodable>(_ type: T.Type = T.self, from row: PostgresRow) throws -> T {
        let decoder = _RowDecoder<T>(row: row, codingPath: [])
        return try T(from: decoder)
    }
    
    func decodeIfPresent<T: Decodable>(_ type: T.Type = T.self, from row: PostgresRow) throws -> T? {
        let decoder = _RowDecoder<T>(row: row, codingPath: [])
        //self.logger.log("debug 0")
        return try T(from: decoder)
    }
}


// MARK: - _RowDecoder

/// The decoder that decodes a record from a database row
private struct _RowDecoder<R: Decodable>: Decoder {
    
    let logger = ConsoleLogger(category: "_RowDecoder")
    var row: PostgresRow
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] { return [:] }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        return KeyedDecodingContainer(KeyedContainer<Key>(decoder: self))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard let codingKey = codingPath.last else {
            fatalError("unkeyed decoding from database row is not supported")
        }
        let keys = row.columnNames
        let debugDescription: String
        if keys.isEmpty {
            debugDescription = "No available columns"
        } else {
            debugDescription = "Available keys for row: \(keys.sorted())"
        }
        throw DecodingError.keyNotFound(
            codingKey,
            DecodingError.Context(
                codingPath: Array(codingPath.dropLast()),
                debugDescription: debugDescription))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        guard let key = codingPath.last else {
            fatalError("single value decoding from database row is not supported")
        }
        guard let index = row.index(ofColumn: key.stringValue) else {
            // Don't use DecodingError.keyNotFound:
            // We need to specifically recognize missing columns in order to
            // provide correct feedback.
            throw MissingColumnError(column: key.stringValue)
        }
        // See DatabaseValueConversionErrorTests.testDecodableFetchableRecord2
        return PostgresColumnDecoder<R>(row: row, columnIndex: index, codingPath: codingPath)
    }
    
    class KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        let logger = ConsoleLogger(category: "KeyedContainer")
        
        let decoder: _RowDecoder
        var codingPath: [CodingKey] { return decoder.codingPath }
        var decodedRootKey: CodingKey?
        
        init(decoder: _RowDecoder) {
            self.decoder = decoder
        }
        
        var allKeys: [Key] {
            let row = decoder.row
            return Set(row.columnNames)
                .compactMap { Key(stringValue: $0) }
        }
        
        func contains(_ key: Key) -> Bool {
            let row = decoder.row
            return row.hasColumn(key.stringValue)
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            let row = decoder.row
            if contains(key) {
                return row.hasNull(atColumn: key.stringValue)
            }else{
                return true
            }
        }
        
        // swiftlint:disable comma
        func decode(_ type: Bool.Type,   forKey key: Key) throws -> Bool   { return decoder.row[key.stringValue] }
        func decode(_ type: Int.Type,    forKey key: Key) throws -> Int    { return decoder.row[key.stringValue] }
        func decode(_ type: Int8.Type,   forKey key: Key) throws -> Int8   { return decoder.row[key.stringValue] }
        func decode(_ type: Int16.Type,  forKey key: Key) throws -> Int16  { return decoder.row[key.stringValue] }
        func decode(_ type: Int32.Type,  forKey key: Key) throws -> Int32  { return decoder.row[key.stringValue] }
        func decode(_ type: Int64.Type,  forKey key: Key) throws -> Int64  { return decoder.row[key.stringValue] }
        func decode(_ type: UInt.Type,   forKey key: Key) throws -> UInt   { return decoder.row[key.stringValue] }
        func decode(_ type: UInt8.Type,  forKey key: Key) throws -> UInt8  { return decoder.row[key.stringValue] }
        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { return decoder.row[key.stringValue] }
        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { return decoder.row[key.stringValue] }
        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { return decoder.row[key.stringValue] }
        func decode(_ type: Float.Type,  forKey key: Key) throws -> Float  { return decoder.row[key.stringValue] }
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double { return decoder.row[key.stringValue] }
        func decode(_ type: String.Type, forKey key: Key) throws -> String { return decoder.row[key.stringValue] }
        func decode(_ type: Date.Type,   forKey key: Key) throws -> Date   { return decoder.row[key.stringValue] }
        // swiftlint:enable comma
        
        func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T: Decodable {
            let row = decoder.row
            let keyName = key.stringValue
            
            // Column?
            if let index = row.index(ofColumn: keyName) {
                // Prefer PostgresRowValueConvertible decoding over Decodable.
                if row.hasNull(atIndex: index) {
                    return nil
                }else if let type = T.self as? PostgresRowValueConvertible.Type {
                    //self.logger.log("debug 2, rowIndex: \(index), is null? \(row.hasNull(atIndex: index))")
                    return type.decodeIfPresent(from: row, atUncheckedIndex: index) as! T?
                } else {
                    //self.logger.log("debug 3")
                    return try decode(type, fromRow: row, columnAtIndex: index, key: key)
                }
            }
            
            // Key is not a column
            return nil
        }
        
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
            let row = decoder.row
            let keyName = key.stringValue
            
            // Column?
            if let index = row.index(ofColumn: keyName) {
                // Prefer PostgresRowValueConvertible decoding over Decodable.
                if let type = T.self as? PostgresRowValueConvertible.Type {
                    //self.logger.log("debug 4")
                    return type.decode(from: row, atUncheckedIndex: index) as! T
                } else {
                    //self.logger.log("debug 5")
                    return try decode(type, fromRow: row, columnAtIndex: index, key: key)
                }
            }
            
            // Key is not a column, and not a scope.
            //
            // Should be throw an error? Well... The use case is the following:
            //
            //      // SELECT book.*, author.* FROM book
            //      // JOIN author ON author.id = book.authorId
            //      let request = Book.including(required: Book.author)
            //
            // Rows loaded from this request don't have any "book" key:
            //
            //      let row = try Row.fetchOne(db, request)!
            //      self.logger.log(row.debugDescription)
            //      // ▿ [id:1 title:"Moby-Dick" authorId:2]
            //      //   unadapted: [id:1 title:"Moby-Dick" authorId:2 id:2 name:"Melville"]
            //      //   author: [id:2 name:"Melville"]
            //
            // And yet we have to decode the "book" key when we decode the
            // BookInfo type below:
            //
            //      struct BookInfo {
            //          var book: Book // <- decodes from the "book" key
            //          var author: Author
            //      }
            //      let infos = try BookInfos.fetchAll(db, request)
            //
            // Our current strategy is to assume that a missing key (such as
            // "book", which is not the name of a column, and not the name of a
            // scope) has to be decoded right from the base row.
            //
            // Yeah, there may be better ways to handle this.
            if let decodedRootKey = decodedRootKey {
                throw DecodingError.keyNotFound(decodedRootKey, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "No such key: \(decodedRootKey.stringValue)")) 
            }
            decodedRootKey = key
            //self.logger.log("debug 6")
            return try decode(type, fromRow: row, codingPath: codingPath + [key])
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key)
            throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
        {
            fatalError("not implemented")
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            throw DecodingError.typeMismatch(
                UnkeyedDecodingContainer.self,
                DecodingError.Context(codingPath: codingPath, debugDescription: "unkeyed decoding is not supported"))
        }
        
        func superDecoder() throws -> Decoder {
            // Not sure
            return decoder
        }
        
        func superDecoder(forKey key: Key) throws -> Decoder {
            fatalError("not implemented")
        }
        
        // Helper methods
        
        @inline(__always)
        private func decode<T>(
            _ type: T.Type,
            fromRow row: PostgresRow,
            codingPath: [CodingKey])
            throws -> T
            where T: Decodable
        {
            do {
                let decoder = _RowDecoder(row: row, codingPath: codingPath)
                return try T(from: decoder)
            } catch {
                self.logger.log("Error at PostgresRowDecoder.decoe<T>(type:fromRoww:codingPath) throws -> T")
                self.logger.log(error)
                // Support for DatabaseValueConversionErrorTests.testDecodableFetchableRecord2
                fatalConversionError(
                    to: type,
                    from: nil)
            }
        }
        
        @inline(__always)
        private func decode<T>(
            _ type: T.Type,
            fromRow row: PostgresRow,
            columnAtIndex index: Int,
            key: Key)
            throws -> T
            where T: Decodable
        {
            do {
                // This decoding will fail for types that decode from keyed
                // or unkeyed containers, because we're decoding a single
                // value here (string, int, double, data, null). If such an
                // error happens, we'll switch to JSON decoding.
                let columnDecoder = PostgresColumnDecoder<R>(
                    row: row,
                    columnIndex: index,
                    codingPath: codingPath + [key])
                return try T(from: columnDecoder)
            } catch {
                self.logger.log("Error at PostgresRowDecoder.decoe<T>(type:fromRoww:columnAtIndex:key) throws -> T")
                self.logger.log(error)
                //self.logger.log("debug 10, columnIndex:\(index), isNull? \(row.hasNull(atIndex: index))")
                guard let data = Data.decodeIfPresent(from: row, atUncheckedIndex: index) else{
                    fatalConversionError(
                        to: T.self,
                        from: nil)
                }
                let decoder = JSONDecoder()
                decoder.dataDecodingStrategy = .base64
                decoder.dateDecodingStrategy = .millisecondsSince1970
                decoder.nonConformingFloatDecodingStrategy = .throw
                //self.logger.log("debug 7")
                return try decoder.decode(type.self, from: data)
            }
        }
    }
}

// MARK: - ColumnDecoder

/// The decoder that decodes from a database column
private struct PostgresColumnDecoder<R: Decodable>: Decoder {
    var row: PostgresRow
    var columnIndex: Int
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] { return [:] }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        // We need to switch to JSON decoding
        throw JSONRequiredError()
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        // We need to switch to JSON decoding
        throw JSONRequiredError()
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

extension PostgresColumnDecoder: SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        return row.hasNull(atIndex: columnIndex)
    }
    
    func decode(_ type: Bool.Type  ) throws -> Bool   { return row[columnIndex] }
    func decode(_ type: Int.Type   ) throws -> Int    { return row[columnIndex] }
    func decode(_ type: Int8.Type  ) throws -> Int8   { return row[columnIndex] }
    func decode(_ type: Int16.Type ) throws -> Int16  { return row[columnIndex] }
    func decode(_ type: Int32.Type ) throws -> Int32  { return row[columnIndex] }
    func decode(_ type: Int64.Type ) throws -> Int64  { return row[columnIndex] }
    func decode(_ type: UInt.Type  ) throws -> UInt   { return row[columnIndex] }
    func decode(_ type: UInt8.Type ) throws -> UInt8  { return row[columnIndex] }
    func decode(_ type: UInt16.Type) throws -> UInt16 { return row[columnIndex] }
    func decode(_ type: UInt32.Type) throws -> UInt32 { return row[columnIndex] }
    func decode(_ type: UInt64.Type) throws -> UInt64 { return row[columnIndex] }
    func decode(_ type: Float.Type ) throws -> Float  { return row[columnIndex] }
    func decode(_ type: Double.Type) throws -> Double { return row[columnIndex] }
    func decode(_ type: String.Type) throws -> String { return row[columnIndex] }
    func decode(_ type: Date.Type)   throws -> Date   { return row[columnIndex] }
    
    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        // Prefer DatabaseValueConvertible decoding over Decodable.
        // This allows decoding Date from String, or DatabaseValue from NULL.
        if let type = T.self as? PostgresRowValueConvertible.Type {
            return type.decode(from: row, atUncheckedIndex: columnIndex) as! T
        } else {
            return try T(from: self)
        }
    }
}
