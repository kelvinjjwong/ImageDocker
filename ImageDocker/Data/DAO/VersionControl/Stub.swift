//
//  Stub.swift
//  TreeView
//
//  Created by Kelvin Wong on 2020/4/22.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

public final class StubDBExecutor : DBExecutor {
    
    let logger = ConsoleLogger(category: "StubDBExecutor")
    
    public func count(sql: String) -> Int {
        self.logger.log("\n\n  >>> count by sql:\n\(sql)")
        return 0
    }
    
    public func execute(sql: String) throws {
        self.logger.log("\n\n  >>> stub executing sql:\n\(sql)")
    }
    
}

public final class MigratorTest {
    
    let logger = ConsoleLogger(category: "MigratorTest")
    
    init(){
        
    }
    
    func tryMigrate() {
        let migrator = DatabaseVersionMigrator(sqlGenerator: PostgresSchemaSQLGenerator(dropBeforeCreate: true), sqlExecutor: PostgresDB(database: "kelvinwong"))
        
        migrator.version("v1") { db in
            
            try db.createSequence(name: "new_table_seq")
            
            try db.create(table: "new_table") { t in
                t.column("id", .integer).primaryKey().autoIncrement(sequence: "new_table_seq")
                t.column("name", .text).notNull().indexed().defaults(to: "abc")
                t.column("age", .integer).defaults(to: "0")
                t.column("salary", .double).defaults(to: "100.5")
                t.column("updatetime", .datetime).defaults(to: "(now())")
            }
            
            try db.create(table: "new_table_2") { t in
                t.column("name", .text).primaryKey().notNull().indexed().defaults(to: "def")
            }

            try db.alter(table: "new_table") { t in
                t.change("name").notNull().indexed().defaults(to: "")
                t.add("memo", .text).notNull().defaults(to: "")
                t.change("age").defaults(to: "24", .integer)
                t.add("gov", .text).notNull().indexed().unique("place")
                t.add("province", .text).notNull().indexed().unique("place")
            }
        }
        
        migrator.version("v2") { db in

            try db.alter(table: "new_table", body: { t in
                t.change("age").notNull().indexed()
                t.add("car", .text).notNull()
                t.add("phone_manufacture", .text).null().indexed("phone")
                t.add("phone_model", .text).null().indexed("phone")
                t.add("latitude", .double).null()
                t.add("longitude", .double).null()
            })
        }
        
        migrator.version("v3") { db in
            try db.drop(table: "new_table_2")
        }
        
        do {
            try migrator.migrate(cleanVersions: false)
        }catch{
            self.logger.log(error)
        }
        
        
    }
}
