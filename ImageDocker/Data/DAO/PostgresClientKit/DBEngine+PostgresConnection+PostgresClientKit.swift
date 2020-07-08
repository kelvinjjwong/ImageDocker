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
    
    public static func database(_ location:ImageDBLocation = .fromSetting) -> PostgresDB {
        var host = "127.0.0.1"
        var port = 5432
        var user = "postgres"
        var psw = ""
        var nopsw = false
        var schema = "unknown"
        var database = "unknown"
        
        var loc = ""
        if location == .remoteDBServer {
            loc = "network"
        }else if location == .localDBServer {
            loc = "localServer"
        }else{
            loc = PreferencesController.databaseLocation()
        }
        if loc == "" {
            loc = PreferencesController.databaseLocation()
        }
        
        // default value
        if loc == "" {
            loc = "network"
        }
        
        if loc == "localServer" {
            host = PreferencesController.localDBServer()
            port = PreferencesController.localDBPort()
            user = PreferencesController.localDBUsername()
            psw = PreferencesController.localDBPassword()
            nopsw = PreferencesController.localDBNoPassword()
            schema = PreferencesController.localDBSchema()
            if schema == "" {
                schema = "public"
            }
            database = PreferencesController.localDBDatabase()
            
        }else if loc == "network" {
            host = PreferencesController.remoteDBServer()
            port = PreferencesController.remoteDBPort()
            user = PreferencesController.remoteDBUsername()
            psw = PreferencesController.remoteDBPassword()
            nopsw = PreferencesController.remoteDBNoPassword()
            schema = PreferencesController.remoteDBSchema()
            if schema == "" {
                schema = "public"
            }
            database = PreferencesController.remoteDBDatabase()
        }
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
            print("Error at testDatabase()")
            print(error)
            return (false, error)
        }
    }
    
    
    
}
