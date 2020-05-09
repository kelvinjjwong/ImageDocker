//
//  DBEngine+PostgresConnection+PostgresClientKit.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/4/6.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation
import PostgresClientKit

public final class PostgresConnection : ImageDBInterface {
    
    static let `default` = PostgresConnection()
    
    public static func database() -> PostgresDB {
        let host = PreferencesController.remoteDBServer()
        let port = PreferencesController.remoteDBPort()
        let user = PreferencesController.remoteDBUsername()
        let psw = PreferencesController.remoteDBPassword()
        let nopsw = PreferencesController.remoteDBNoPassword()
        var schema = PreferencesController.remoteDBSchema()
        if schema == "" {
            schema = "public"
        }
        let database = PreferencesController.remoteDBDatabase()
        if nopsw {
            let db = PostgresDB(database: database, host: host, port: port, user: user, password: nil, ssl: false)
            db.schema = schema
            return db
        }else{
            let db = PostgresDB(database: database, host: host, port: port, user: user, password: psw, ssl: false)
            db.schema = schema
            return db
        }
    }
    
    func testDatabase() -> (Bool, Error?) {
        do {
            try PostgresConnection.database().execute(sql: "SELECT NOW()")
            return (true, nil)
        }catch{
            print(error)
            return (false, error)
        }
    }
    
    
    
}
