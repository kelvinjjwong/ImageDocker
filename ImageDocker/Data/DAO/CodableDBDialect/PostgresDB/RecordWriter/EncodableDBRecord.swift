//
//  EncodableRecord.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit

/// Types that adopt EncodableRecord can be encoded into the database.
public protocol EncodableDBRecord {
    /// Encodes the record into database values.
    ///
    /// Store in the *container* argument all values that should be stored in
    /// the columns of the database table (see databaseTableName()).
    ///
    /// Primary key columns, if any, must be included.
    ///
    ///     struct Player: EncodableRecord {
    ///         var id: Int64?
    ///         var name: String?
    ///
    ///         func encode(to container: inout PostgresDBValueContainer) {
    ///             container["id"] = id
    ///             container["name"] = name
    ///         }
    ///     }
    ///
    /// It is undefined behavior to set different values for the same column.
    /// Column names are case insensitive, so defining both "name" and "NAME"
    /// is considered undefined behavior.
    func encode(to container: inout PostgresDBValueContainer)
    
    // MARK: - Customizing the Format of Database Columns
    
    /// When the EncodableRecord type also adopts the standard Encodable
    /// protocol, you can use this dictionary to customize the encoding process
    /// into database rows.
    ///
    /// For example:
    ///
    ///     // A key that holds a encoder's name
    ///     let encoderName = CodingUserInfoKey(rawValue: "encoderName")!
    ///
    ///     struct Player: PersistableRecord, Encodable {
    ///         // Customize the encoder name when encoding a database row
    ///         static let databaseEncodingUserInfo: [CodingUserInfoKey: Any] = [encoderName: "Database"]
    ///
    ///         func encode(to encoder: Encoder) throws {
    ///             // Print the encoder name
    ///             self.logger.log(encoder.userInfo[encoderName])
    ///             ...
    ///         }
    ///     }
    ///
    ///     let player = Player(...)
    ///
    ///     // prints "Database"
    ///     try player.insert(db)
    ///
    ///     // prints "JSON"
    ///     let encoder = JSONEncoder()
    ///     encoder.userInfo = [encoderName: "JSON"]
    ///     let data = try encoder.encode(player)
    static var dbRecordEncodingUserInfo: [CodingUserInfoKey: Any] { get }
    
    /// When the EncodableRecord type also adopts the standard Encodable
    /// protocol, this method controls the encoding process of nested properties
    /// into JSON database columns.
    ///
    /// The default implementation returns a JSONEncoder with the
    /// following properties:
    ///
    /// - dataEncodingStrategy: .base64
    /// - dateEncodingStrategy: .millisecondsSince1970
    /// - nonConformingFloatEncodingStrategy: .throw
    /// - outputFormatting: .sortedKeys (iOS 11.0+, macOS 10.13+, tvOS 11.0+, watchOS 4.0+)
    ///
    /// You can override those defaults:
    ///
    ///     struct Achievement: Encodable {
    ///         var name: String
    ///         var date: Date
    ///     }
    ///
    ///     struct Player: Encodable, PersistableRecord {
    ///         // stored in a JSON column
    ///         var achievements: [Achievement]
    ///
    ///         static func databaseJSONEncoder(for column: String) -> JSONEncoder {
    ///             let encoder = JSONEncoder()
    ///             encoder.dateEncodingStrategy = .iso8601
    ///             return encoder
    ///         }
    ///     }
    static func dbRecordJSONEncoder(for column: String) -> JSONEncoder
}

extension EncodableDBRecord {
    public static var dbRecordEncodingUserInfo: [CodingUserInfoKey: Any] {
        return [:]
    }
    
    public static func dbRecordJSONEncoder(for column: String) -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.nonConformingFloatEncodingStrategy = .throw
        if #available(watchOS 4.0, OSX 10.13, iOS 11.0, tvOS 11.0, *) {
            // guarantee some stability in order to ease record comparison
            encoder.outputFormatting = .sortedKeys
        }
        return encoder
    }
}

extension EncodableDBRecord {
    /// A dictionary whose keys are the columns encoded in the `encode(to:)` method.
    public var dbRecordDictionary: [String: PostgresValue] {
        return Dictionary(PostgresDBValueContainer(self).storage).mapValues { $0?.postgresValue ?? PostgresValue(nil) }
    }
}

extension EncodableDBRecord {
    
    // MARK: - Record Comparison
    
    /// Returns a boolean indicating whether this record and the other record
    /// have the same database representation.
    public func dbRecordEquals(_ record: Self) -> Bool {
        return PostgresDBValueContainer(self).changesIterator(from: PostgresDBValueContainer(record)).next() == nil
    }
    
    /// A dictionary of values changed from the other record.
    ///
    /// Its keys are column names. Its values come from the other record.
    ///
    /// Note that this method is not symmetrical, not only in terms of values,
    /// but also in terms of columns. When the two records don't define the
    /// same set of columns in their `encode(to:)` method, only the columns
    /// defined by the receiver record are considered.
    public func dbRecordChanges<Record: EncodableDBRecord>(from record: Record) -> [String: PostgresValue] {
        let changes = PostgresDBValueContainer(self).changesIterator(from: PostgresDBValueContainer(record))
        return Dictionary(uniqueKeysWithValues: changes)
    }
}

extension EncodableDBRecord where Self: Encodable {
    public func encode(to container: inout PostgresDBValueContainer) {
        let encoder = RecordEncoder<Self>(persistenceContainer: container)
        try! encode(to: encoder)
        container = encoder.persistenceContainer
    }
}

// MARK: - RecordEncoder

/// The encoder that encodes a record into PostgresDBValueContainer
private class RecordEncoder<Record: EncodableDBRecord>: Encoder {
    var codingPath: [CodingKey] { return [] }
    var userInfo: [CodingUserInfoKey: Any] { return Record.dbRecordEncodingUserInfo }
    private var _persistenceContainer: PostgresDBValueContainer
    var persistenceContainer: PostgresDBValueContainer { return _persistenceContainer }
    
    init(persistenceContainer: PostgresDBValueContainer) {
        _persistenceContainer = persistenceContainer
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        let container = KeyedContainer<Key>(recordEncoder: self)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("unkeyed encoding is not supported")
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        // @itaiferber on https://forums.swift.org/t/how-to-encode-objects-of-unknown-type/12253/11
        //
        // > Encoding a value into a single-value container is equivalent to
        // > encoding the value directly into the encoder, with the primary
        // > difference being the above: encoding into the encoder writes the
        // > contents of a type into the encoder, while encoding to a
        // > single-value container gives the encoder a chance to intercept the
        // > type as a whole.
        //
        // Wait for somebody hitting this fatal error so that we can write a
        // meaningful regression test.
        fatalError("single value encoding is not supported")
    }
    
    private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        var recordEncoder: RecordEncoder
        var userInfo: [CodingUserInfoKey: Any] { return Record.dbRecordEncodingUserInfo }
        
        init(recordEncoder: RecordEncoder) {
            self.recordEncoder = recordEncoder
        }
        
        var codingPath: [CodingKey] { return [] }
        
        // swiftlint:disable comma
        func encode(_ value: Bool,   forKey key: Key) throws { recordEncoder.persist(value, forKey: key) }
        func encode(_ value: Int,    forKey key: Key) throws { recordEncoder.persist(value, forKey: key) }
        func encode(_ value: Int8,   forKey key: Key) throws { recordEncoder.persist(Int(value), forKey: key) }
        func encode(_ value: Int16,  forKey key: Key) throws { recordEncoder.persist(Int(value), forKey: key) }
        func encode(_ value: Int32,  forKey key: Key) throws { recordEncoder.persist(Int(value), forKey: key) }
        func encode(_ value: Int64,  forKey key: Key) throws { recordEncoder.persist(Int(value), forKey: key) }
        func encode(_ value: UInt,   forKey key: Key) throws { recordEncoder.persist(Int(value), forKey: key) }
        func encode(_ value: UInt8,  forKey key: Key) throws { recordEncoder.persist(Int(value), forKey: key) }
        func encode(_ value: UInt16, forKey key: Key) throws { recordEncoder.persist(Int(value), forKey: key) }
        func encode(_ value: UInt32, forKey key: Key) throws { recordEncoder.persist(Int(value), forKey: key) }
        func encode(_ value: UInt64, forKey key: Key) throws { recordEncoder.persist(Int(value), forKey: key) }
        func encode(_ value: Float,  forKey key: Key) throws { recordEncoder.persist(Double(value), forKey: key) }
        func encode(_ value: Double, forKey key: Key) throws { recordEncoder.persist(value, forKey: key) }
        func encode(_ value: String, forKey key: Key) throws { recordEncoder.persist(value, forKey: key) }
        func encode(_ value: Date,   forKey key: Key) throws { recordEncoder.persist(value, forKey: key) }
        // swiftlint:enable comma
        
        func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
            try recordEncoder.encode(value, forKey: key)
        }
        
        func encodeNil(forKey key: Key) throws { recordEncoder.persist(nil, forKey: key) }
        
        // swiftlint:disable comma
        func encodeIfPresent(_ value: Bool?,   forKey key: Key) throws { recordEncoder.persist(value, forKey: key) }
        func encodeIfPresent(_ value: Int?,    forKey key: Key) throws { recordEncoder.persist(value, forKey: key) }
        func encodeIfPresent(_ value: Int8?,   forKey key: Key) throws { recordEncoder.persist(value == nil ? nil : (Int(value!)), forKey: key) }
        func encodeIfPresent(_ value: Int16?,  forKey key: Key) throws { recordEncoder.persist(value == nil ? nil : (Int(value!)), forKey: key) }
        func encodeIfPresent(_ value: Int32?,  forKey key: Key) throws { recordEncoder.persist(value == nil ? nil : (Int(value!)), forKey: key) }
        func encodeIfPresent(_ value: Int64?,  forKey key: Key) throws { recordEncoder.persist(value == nil ? nil : (Int(value!)), forKey: key) }
        func encodeIfPresent(_ value: UInt?,   forKey key: Key) throws { recordEncoder.persist(value == nil ? nil : (Int(value!)), forKey: key) }
        func encodeIfPresent(_ value: UInt8?,  forKey key: Key) throws { recordEncoder.persist(value == nil ? nil : (Int(value!)), forKey: key) }
        func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws { recordEncoder.persist(value == nil ? nil : (Int(value!)), forKey: key) }
        func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws { recordEncoder.persist(value == nil ? nil : (Int(value!)), forKey: key) }
        func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws { recordEncoder.persist(value == nil ? nil : (Int(value!)), forKey: key) }
        func encodeIfPresent(_ value: Float?,  forKey key: Key) throws { recordEncoder.persist(value == nil ? nil : (Double(value!)), forKey: key) }
        func encodeIfPresent(_ value: Double?, forKey key: Key) throws { recordEncoder.persist(value, forKey: key) }
        func encodeIfPresent(_ value: String?, forKey key: Key) throws { recordEncoder.persist(value, forKey: key) }
        func encodeIfPresent(_ value: Date?,   forKey key: Key) throws { recordEncoder.persist(value, forKey: key) }
        // swiftlint:disable comma
        
        func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T: Encodable {
            if let value = value {
                try recordEncoder.encode(value, forKey: key)
            } else {
                recordEncoder.persist(nil, forKey: key)
            }
        }
        
        func nestedContainer<NestedKey>(
            keyedBy keyType: NestedKey.Type,
            forKey key: Key)
            -> KeyedEncodingContainer<NestedKey>
        {
            fatalError("Not implemented")
        }
        
        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            fatalError("Not implemented")
        }
        
        func superEncoder() -> Encoder {
            fatalError("Not implemented")
        }
        
        func superEncoder(forKey key: Key) -> Encoder {
            fatalError("Not implemented")
        }
    }
    
    /// Helper methods
    @inline(__always)
    fileprivate func persist(_ value: PostgresValueConvertible?, forKey key: CodingKey) {
        _persistenceContainer[key.stringValue] = value
    }
    
    @inline(__always)
    fileprivate func encode<T>(_ value: T, forKey key: CodingKey) throws where T: Encodable {
        if let date = value as? Date {
            persist(date.postgresTimestampWithTimeZone, forKey: key)
        } else if let value = value as? PostgresValueConvertible {
            // Prefer DatabaseValueConvertible encoding over Decodable.
            persist(value.postgresValue, forKey: key)
        } else {
            do {
                // This encoding will fail for types that encode into keyed
                // or unkeyed containers, because we're encoding a single
                // value here (string, int, double, data, null). If such an
                // error happens, we'll switch to JSON encoding.
                let encoder = DBColumnEncoder(recordEncoder: self, key: key)
                try value.encode(to: encoder)
                if encoder.requiresJSON {
                    // Here we handle empty arrays and dictionaries.
                    throw JSONRequiredError()
                }
            } catch is JSONRequiredError {
                // Encode to JSON
                let jsonData = try Record.dbRecordJSONEncoder(for: key.stringValue).encode(value)
                
                // Store JSON String in the database for easier debugging and
                // database inspection. Thanks to SQLite weak typing, we won't
                // have any trouble decoding this string into data when we
                // eventually perform JSON decoding.
                // TODO: possible optimization: avoid this conversion to string,
                // and store raw data bytes as an SQLite string
                let jsonString = String(data: jsonData, encoding: .utf8)!
                persist(jsonString, forKey: key)
            }
        }
    }
}

// MARK: - ColumnEncoder

/// The encoder that encodes into a database column
private class DBColumnEncoder<Record: EncodableDBRecord>: Encoder {
    var recordEncoder: RecordEncoder<Record>
    var key: CodingKey
    var codingPath: [CodingKey] { return [key] }
    var userInfo: [CodingUserInfoKey: Any] { return Record.dbRecordEncodingUserInfo }
    var requiresJSON = false
    
    init(recordEncoder: RecordEncoder<Record>, key: CodingKey) {
        self.recordEncoder = recordEncoder
        self.key = key
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        // Keyed values require JSON encoding: we need to throw
        // JSONRequiredError. Since we can't throw right from here, let's
        // delegate the job to a dedicated container.
        requiresJSON = true
        let container = JSONRequiredEncoder<Record>.KeyedContainer<Key>(codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // Keyed values require JSON encoding: we need to throw
        // JSONRequiredError. Since we can't throw right from here, let's
        // delegate the job to a dedicated container.
        requiresJSON = true
        return JSONRequiredEncoder<Record>(codingPath: codingPath)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

extension DBColumnEncoder: SingleValueEncodingContainer {
    func encodeNil() throws { recordEncoder.persist(nil, forKey: key) }
    
    func encode(_ value: Bool  ) throws { recordEncoder.persist(value, forKey: key) }
    func encode(_ value: Int   ) throws { recordEncoder.persist(value, forKey: key) }
    func encode(_ value: Int8  ) throws { recordEncoder.persist(Int(value), forKey: key) }
    func encode(_ value: Int16 ) throws { recordEncoder.persist(Int(value), forKey: key) }
    func encode(_ value: Int32 ) throws { recordEncoder.persist(Int(value), forKey: key) }
    func encode(_ value: Int64 ) throws { recordEncoder.persist(Int(value), forKey: key) }
    func encode(_ value: UInt  ) throws { recordEncoder.persist(Int(value), forKey: key) }
    func encode(_ value: UInt8 ) throws { recordEncoder.persist(Int(value), forKey: key) }
    func encode(_ value: UInt16) throws { recordEncoder.persist(Int(value), forKey: key) }
    func encode(_ value: UInt32) throws { recordEncoder.persist(Int(value), forKey: key) }
    func encode(_ value: UInt64) throws { recordEncoder.persist(Int(value), forKey: key) }
    func encode(_ value: Float ) throws { recordEncoder.persist(Double(value), forKey: key) }
    func encode(_ value: Double) throws { recordEncoder.persist(value, forKey: key) }
    func encode(_ value: String) throws { recordEncoder.persist(value, forKey: key) }
    func encode(_ value: Date)   throws { recordEncoder.persist(value, forKey: key) }
    
    func encode<T>(_ value: T) throws where T: Encodable {
        try recordEncoder.encode(value, forKey: key)
    }
}


// MARK: - JSONRequiredEncoder

/// The encoder that always ends up with a JSONRequiredError
private struct JSONRequiredEncoder<Record: EncodableDBRecord>: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] { return Record.dbRecordEncodingUserInfo }
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let container = KeyedContainer<Key>(codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return self
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
    
    struct KeyedContainer<KeyType: CodingKey>: KeyedEncodingContainerProtocol {
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any] { return Record.dbRecordEncodingUserInfo }
        
        func encodeNil(forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: Bool,   forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: Int,    forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: Int8,   forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: Int16,  forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: Int32,  forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: Int64,  forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: UInt,   forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: UInt8,  forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: UInt16, forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: UInt32, forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: UInt64, forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: Float,  forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: Double, forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: String, forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode(_ value: Date,   forKey key: KeyType) throws { throw JSONRequiredError() }
        func encode<T>(_ value: T, forKey key: KeyType) throws where T: Encodable { throw JSONRequiredError() }
        
        func nestedContainer<NestedKey>(
            keyedBy keyType: NestedKey.Type,
            forKey key: KeyType)
            -> KeyedEncodingContainer<NestedKey>
            where NestedKey: CodingKey
        {
            let container = KeyedContainer<NestedKey>(codingPath: codingPath + [key])
            return KeyedEncodingContainer(container)
        }
        
        func nestedUnkeyedContainer(forKey key: KeyType) -> UnkeyedEncodingContainer {
            return JSONRequiredEncoder(codingPath: codingPath)
        }
        
        func superEncoder() -> Encoder {
            return JSONRequiredEncoder(codingPath: codingPath)
        }
        
        func superEncoder(forKey key: KeyType) -> Encoder {
            return JSONRequiredEncoder(codingPath: codingPath)
        }
    }
}

extension JSONRequiredEncoder: SingleValueEncodingContainer {
    func encodeNil() throws { throw JSONRequiredError() }
    func encode(_ value: Bool  ) throws { throw JSONRequiredError() }
    func encode(_ value: Int   ) throws { throw JSONRequiredError() }
    func encode(_ value: Int8  ) throws { throw JSONRequiredError() }
    func encode(_ value: Int16 ) throws { throw JSONRequiredError() }
    func encode(_ value: Int32 ) throws { throw JSONRequiredError() }
    func encode(_ value: Int64 ) throws { throw JSONRequiredError() }
    func encode(_ value: UInt  ) throws { throw JSONRequiredError() }
    func encode(_ value: UInt8 ) throws { throw JSONRequiredError() }
    func encode(_ value: UInt16) throws { throw JSONRequiredError() }
    func encode(_ value: UInt32) throws { throw JSONRequiredError() }
    func encode(_ value: UInt64) throws { throw JSONRequiredError() }
    func encode(_ value: Float ) throws { throw JSONRequiredError() }
    func encode(_ value: Double) throws { throw JSONRequiredError() }
    func encode(_ value: String) throws { throw JSONRequiredError() }
    func encode(_ value: Date)   throws { throw JSONRequiredError() }
    func encode<T>(_ value: T) throws where T: Encodable { throw JSONRequiredError() }
}

extension JSONRequiredEncoder: UnkeyedEncodingContainer {
    var count: Int { return 0 }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type)
        -> KeyedEncodingContainer<NestedKey>
        where NestedKey: CodingKey
    {
        let container = KeyedContainer<NestedKey>(codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return self
    }
    
    mutating func superEncoder() -> Encoder {
        return self
    }
}
