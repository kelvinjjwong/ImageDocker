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
    
    let logger = ConsoleLogger(category: "DB", subCategory: "Postgres")
    
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
        
        return PostgresConnection.database(host: host, port: port, user: user, database: database, schema: schema, password: psw, nopsw: nopsw)
    }
    
    public static func database(host:String, port:Int, user:String, database:String, schema:String, password:String, nopsw:Bool) -> PostgresDB {
        if nopsw {
            let db = PostgresDB(database: database, host: host, port: port, user: user, password: nil, ssl: false)
            if schema == "" {
                db.schema = "public"
            }else{
                db.schema = schema
            }
            return db
        }else{
            let db = PostgresDB(database: database, host: host, port: port, user: user, password: password, ssl: false)
            if schema == "" {
                db.schema = "public"
            }else{
                db.schema = schema
            }
            return db
        }
    }
    
    func testDatabase() -> (Bool, Error?) {
        do {
            try PostgresConnection.database().execute(sql: "SELECT NOW()")
            return (true, nil)
        }catch{
            self.logger.log("Error at testDatabase()")
            self.logger.log(error)
            return (false, error)
        }
    }
    
    func testDatabase(db:PostgresDB) -> (Bool, Error?) {
        do {
            try db.execute(sql: "SELECT NOW()")
            return (true, nil)
        }catch{
            self.logger.log("[DB][Postgres] Error at testDatabase(db)")
            self.logger.log(error)
            return (false, error)
        }
    }
    
    func createDatabase(commandPath:String, database:String, host:String, port:Int, user:String) -> (Bool, String, PostgresError, Error?) {
        var result = ""
        var status = false
        var err:Error? = nil
        let pipe = Pipe()
        
        let path = URL(fileURLWithPath: commandPath).appendingPathComponent("createdb").path
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = path
            cmd.arguments = ["-h", host, "-p", "\(port)", "-U", user, "-w", database]
            do {
                try cmd.run()
                status = true
            }catch{
                err = error
                self.logger.log(error)
            }
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            result = string
        }
        var pgError:PostgresError = .none
        if result != "" || err != nil {
            pgError = .other
        }
        if result.contains("role") && result.contains("does not exist") {
            pgError = .wrong_user
            status = false
        }else if result.contains("Connection refused") && result.contains("port") {
            pgError = .wrong_port
            status = false
        }else if result.contains("could not translate host name") {
            pgError = .wrong_hostname
            status = false
        }
        return (status, result, pgError, err)
    }
    
    func getExistDatabases(commandPath:String, host:String, port:Int) -> [String] {
        
        var result:[String] = []
        
        let psql_path = URL(fileURLWithPath: commandPath).appendingPathComponent("psql").path
        let cmdline = "\(psql_path) -h \(host) -lt --csv | awk -F',' '{print $1}' | grep -v '='"
        
        let pipe = Pipe()
        let cmd = Process()
        cmd.standardOutput = pipe
        cmd.standardError = pipe
        cmd.launchPath = "/bin/bash"
        cmd.arguments = ["-c", cmdline]
        
        cmd.launch()
        cmd.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        let lines = string.components(separatedBy: "\n")
        for line in lines {
            result.append(line)
        }
        return result
    }
    
    func cloneDatabase(commandPath:String, srcDatabase:String, srcHost:String, srcPort:Int, srcUser:String, destDatabase:String, destHost:String, destPort:Int, destUser:String) -> (Bool, Error?) {
        
        let pgdump_path = URL(fileURLWithPath: commandPath).appendingPathComponent("pg_dump").path
        let psql_path = URL(fileURLWithPath: commandPath).appendingPathComponent("psql").path
        
        let cmd = "\(pgdump_path) -h \(srcHost) -U \(srcUser) \"\(srcDatabase)\" | \(psql_path) -h \(destHost) -U \(destUser) \"\(destDatabase)\""
        self.logger.log(cmd)
        let pipe = Pipe()
        let pgdump = Process("/bin/bash", ["-c", cmd])
        pgdump.standardOutput = pipe
        pgdump.standardError = pipe
        
        let startTime = Date()
        self.logger.log("doing pgdump clone")
        pgdump.launch()
        pgdump.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let string = String(data: data, encoding: String.Encoding.utf8)!
        pipe.fileHandleForReading.closeFile()
        let lines = string.components(separatedBy: "\n")
        var errors:[String] = []
        var hasError = false
        for line in lines {
            if line.contains("FATAL") {
                hasError = true
                errors.append(line)
            }
        }
        self.logger.timecost("end of pgdump clone", fromDate: startTime)
        if !hasError {
            return (true, nil)
        }else{
            return (false, fatalError(errors.joined(separator: "\n")))
        }
    }
    
    func backupDatabase(commandPath:String, database:String, host:String, port:Int, user:String, backupPath:String, suffix:String = "-on-runtime") -> (String, Bool, Error?) {
        
        let pgdump_path = URL(fileURLWithPath: commandPath).appendingPathComponent("pg_dump").path
        
        let folder = ExecutionEnvironment.default.getBackupFolderName(suffix: suffix, database: "pgsql")
        let filename = "ImageDocker.backup.gz"
        let backupfolder = URL(fileURLWithPath: backupPath).appendingPathComponent(folder)
        
        do{
            try FileManager.default.createDirectory(at: backupfolder, withIntermediateDirectories: true, attributes: nil)
        }catch{
            self.logger.log("Unable to create backup folder \(backupfolder.path)")
            self.logger.log(error)
            return (folder, false, error)
        }
        let filepath = backupfolder.appendingPathComponent(filename)
        
        let cmd = "\(pgdump_path) -h \(host) -U \(user) \(database) | /usr/bin/gzip > \(filepath.path)"
        self.logger.log(cmd)
        let pgdump = Process("/bin/bash", ["-c", cmd])
        
        let startTime = Date()
        self.logger.log("doing pgdump backup")
        pgdump.launch()
        pgdump.waitUntilExit()
        self.logger.timecost("end of pgdump backup", fromDate: startTime)
        return (folder, true, nil)
    }
    
    func restoreDatabase(commandPath:String, database:String, host:String, port:Int, user:String, backupFolder:String) -> (Bool, Error?) {
        let psql_path = URL(fileURLWithPath: commandPath).appendingPathComponent("psql").path
        
        let backupPath = URL(fileURLWithPath: PreferencesController.databasePath()).appendingPathComponent("DataBackup").appendingPathComponent(backupFolder).appendingPathComponent("ImageDocker.backup.gz").path
        
        let cmd = "/usr/bin/gunzip -c \(backupPath) | \(psql_path) -h \(host) \(database)"
        self.logger.log(cmd)
        let pgdump = Process("/bin/bash", ["-c", cmd])
        
        let startTime = Date()
        self.logger.log("doing psql restore")
        pgdump.launch()
        pgdump.waitUntilExit()
        self.logger.timecost("end of psql restore", fromDate: startTime)
        return (true, nil)
    }
    
    
}

public enum PostgresError {
    case none
    case wrong_hostname
    case wrong_port
    case wrong_user
    case other
}
