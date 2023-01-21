//
//  PostgresRecord.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/26.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit

public protocol PostgresRecord : Codable, EncodableDBRecord {
    
    init()
    
    func save(_ db: PostgresDB)
    
    func postgresTable() -> String
    
    func primaryKeys() -> [String]
    
    func autofillColumns() -> [String]
}

extension PostgresRecord {
    
    private func exists(_ db: PostgresDB, parameters: [String : PostgresValueConvertible?]) -> Bool {
        let count = self.count(db, parameters: parameters)
        if count > 0 {
            return true
        }else{
            return false
        }
    }
    
    public func save(_ db: PostgresDB) {
        db.save(object: self, table: self.postgresTable(), primaryKeys: self.primaryKeys(), autofillColumns: self.autofillColumns())
    }
    
    public func delete(_ db: PostgresDB, keyColumns:[String] = []) {
        db.delete(object: self, table: self.postgresTable(), primaryKeys: keyColumns.count > 0 ? keyColumns : self.primaryKeys())
    }
    
    private func count(_ db: PostgresDB) -> Int {
        return db.count(object: self, table: self.postgresTable())
    }
    
    private func count(_ db: PostgresDB, parameters: [String : PostgresValueConvertible?]) -> Int {
        return db.count(object: self, table: self.postgresTable(), parameters: parameters)
    }
    
    private func count(_ db: PostgresDB, where whereSQL:String, parameters: [PostgresValueConvertible?] = []) -> Int {
        return db.count(object: self, table: self.postgresTable(), where: whereSQL, values: parameters)
    }
    
    private func fetchOne(_ db: PostgresDB) -> Self? {
        return db.queryOne(object: self, table: self.postgresTable())
    }
    
    private func fetchOne(_ db: PostgresDB, parameters: [String : PostgresValueConvertible?]) -> Self? {
        return db.queryOne(object: self, table: self.postgresTable(), parameters: parameters)
    }
    
    private func fetchOne(_ db: PostgresDB, where whereSQL:String, orderBy:String = "", values:[PostgresValueConvertible?] = []) -> Self? {
        return db.queryOne(object: self, table: self.postgresTable(), where: whereSQL, orderBy: orderBy, values: values)
    }
    
    private func fetchOne(_ db: PostgresDB, sql: String, values:[PostgresValueConvertible?] = []) -> Self? {
        return db.queryOne(object: self, table: self.postgresTable(), sql: sql, values: values)
    }
    
    private func fetchAll(_ db: PostgresDB, orderBy:String = "") -> [Self] {
        return db.query(object: self, table: self.postgresTable(), orderBy: orderBy)
    }
    
    private func fetchAll(_ db: PostgresDB, parameters: [String : PostgresValueConvertible?], orderBy: String = "") -> [Self] {
        return db.query(object: self, table: self.postgresTable(), parameters: parameters, orderBy: orderBy)
    }
    
    private func fetchAll(_ db: PostgresDB, where whereSQL:String, orderBy:String = "", values:[PostgresValueConvertible?] = [], offset:Int? = nil, limit:Int? = nil) -> [Self] {
        return db.query(object: self, table: self.postgresTable(), where: whereSQL, orderBy: orderBy, values: values, offset: offset, limit: limit)
    }
    
    private func fetchAll(_ db: PostgresDB, sql: String, values:[PostgresValueConvertible?] = [], offset:Int? = nil, limit:Int? = nil) -> [Self] {
        return db.query(object: self, table: self.postgresTable(), sql: sql, values: values, offset: offset, limit: limit)
    }
}

extension PostgresRecord {
    
    public static func exists(_ db: PostgresDB, parameters: [String : PostgresValueConvertible?]) -> Bool {
        let obj = Self.init()
        return obj.exists(db, parameters: parameters)
    }
    
    public static func count(_ db: PostgresDB) -> Int {
        let obj = Self.init()
        return obj.count(db)
    }
    
    public static func count(_ db: PostgresDB, parameters: [String : PostgresValueConvertible?]) -> Int {
        let obj = Self.init()
        return obj.count(db, parameters: parameters)
    }
    
    public static func count(_ db: PostgresDB, where whereSQL:String, parameters: [PostgresValueConvertible?] = []) -> Int {
        let obj = Self.init()
        return obj.count(db, where: whereSQL, parameters: parameters)
    }
    
    public static func fetchOne(_ db: PostgresDB) -> Self? {
        let obj = Self.init()
        return obj.fetchOne(db)
    }
    
    public static func fetchOne(_ db: PostgresDB, parameters: [String : PostgresValueConvertible?]) -> Self? {
        let obj = Self.init()
        return obj.fetchOne(db, parameters: parameters)
    }
    
    public static func fetchOne(_ db: PostgresDB, where whereSQL:String, orderBy:String = "", values:[PostgresValueConvertible?] = []) -> Self? {
        let obj = Self.init()
        return obj.fetchOne(db, where: whereSQL, orderBy: orderBy, values: values)
    }
    
    public static func fetchOne(_ db: PostgresDB, sql: String, values:[PostgresValueConvertible?] = []) -> Self? {
        let obj = Self.init()
        return obj.fetchOne(db, sql: sql, values: values)
    }
    
    public static func fetchAll(_ db: PostgresDB, orderBy: String = "") -> [Self] {
        let obj = Self.init()
        return obj.fetchAll(db, orderBy: orderBy)
    }
    
    public static func fetchAll(_ db: PostgresDB, parameters: [String : PostgresValueConvertible?], orderBy: String = "") -> [Self] {
        let obj = Self.init()
        return obj.fetchAll(db, parameters: parameters, orderBy: orderBy)
    }
    
    public static func fetchAll(_ db: PostgresDB, where whereSQL:String, orderBy:String = "", values:[PostgresValueConvertible?] = [], offset:Int? = nil, limit:Int? = nil) -> [Self] {
        let obj = Self.init()
        return obj.fetchAll(db, where: whereSQL, orderBy: orderBy, values: values, offset: offset, limit: limit)
    }
    
    public static func fetchAll(_ db: PostgresDB, sql:String, values:[PostgresValueConvertible?] = [], offset:Int? = nil, limit:Int? = nil) -> [Self] {
        let obj = Self.init()
        return obj.fetchAll(db, sql: sql, values: values, offset: offset, limit: limit)
    }
}


public protocol PostgresCustomRecord : PostgresRecord {
    
}

extension PostgresCustomRecord {

    func postgresTable() -> String {
        return ""
    }
    
    func primaryKeys() -> [String] {
        return []
    }
    
    func autofillColumns() -> [String] {
        return []
    }
}
