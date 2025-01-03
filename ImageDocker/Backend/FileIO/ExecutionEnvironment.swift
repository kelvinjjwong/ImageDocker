//
//  ExecutionEnvironment.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2019/3/17.
//  Copyright © 2019 nonamecat. All rights reserved.
//

import Foundation
import LoggerFactory
import PostgresModelFactory

struct ExecutionEnvironment {
    
    let logger = LoggerFactory.get(category: "ExecutionEnvironment")
    
    static let `default` = ExecutionEnvironment()
    
    fileprivate let RUBY = URL(fileURLWithPath: "/usr/bin/ruby")
    
    func installHomebrew() -> String{
        var result = ""
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = RUBY.path
            cmd.arguments = ["-e", "\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""]
            do {
                try cmd.run()
            }catch{
                self.logger.log(.error, error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            result = string
        }
        return result
    }
    
    func uninstallHomebrew() -> String{
        var result = ""
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = RUBY.path
            cmd.arguments = ["-e", "\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)\""]
            do {
                try cmd.run()
            }catch{
                self.logger.log(.error, error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            result = string
        }
        return result
    }
    
    func locate(_ command:String) -> String{
        var paths:[String] = ["/opt/homebrew/bin","/usr/local/bin","/usr/bin","/bin","/usr/sbin","/sbin"]
        autoreleasepool { () -> Void in
            let taskShell = Process()
            taskShell.launchPath = "/bin/ls"
            taskShell.arguments = ["-r", "/Library/Frameworks/Python.framework/Versions/"]
            let pipeShell = Pipe()
            taskShell.standardOutput = pipeShell
            taskShell.standardError = pipeShell
            taskShell.launch()
            taskShell.waitUntilExit()
            let data = pipeShell.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: String.Encoding.utf8)!
            pipeShell.fileHandleForReading.closeFile()
            if output != "" {
                let versions = output.components(separatedBy: "\n")
                for version in versions {
                    paths.append("/Library/Frameworks/Python.framework/Versions/\(version)/bin")
                }
            }
        }
        
        for path in paths {
            let p = URL(fileURLWithPath: path).appendingPathComponent(command).path
            //self.logger.log(p)
            if p.isFileExists() {
                return p
            }
        }
        return ""
    }
    
    func pipList(_ pipPath:String) -> Set<String>{
        self.logger.log(.trace, "calling pip: \(pipPath)")
        var result:Set<String> = []
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = pipPath
            cmd.arguments = ["list"]
            do {
                try cmd.run()
            }catch{
                self.logger.log(.error, error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            self.logger.log(string)
            let lines = string.components(separatedBy: "\n")
            for line in lines {
                let part = line.components(separatedBy: " ")
                if !part[0].starts(with: "Package") && !part[0].starts(with: "-") {
                    result.insert(part[0])
                }
            }
        }
        return result
    }
    
    
    
    func brewList(_ brewPath:String) -> Set<String>{
        var result:Set<String> = []
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = brewPath
            cmd.arguments = ["list"]
            do {
                try cmd.run()
            }catch{
                self.logger.log(.error, error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            let lines = string.components(separatedBy: "\n")
            for line in lines {
                let parts = line.components(separatedBy: " ")
                for part in parts {
                    if part != "" {
                        result.insert(part)
                    }
                }
            }
        }
        return result
    }
    
    func brewCaskList(_ brewPath:String) -> Set<String>{
        var result:Set<String> = []
        let pipe = Pipe()
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = brewPath
            cmd.arguments = ["cask", "list"]
            do {
                try cmd.run()
            }catch{
                self.logger.log(.error, error)
            }
            //cmd.terminate()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            let lines = string.components(separatedBy: "\n")
            for line in lines {
                let parts = line.components(separatedBy: " ")
                for part in parts {
                    if part != "" {
                        result.insert(part)
                    }
                }
            }
        }
        return result
    }
    
    func findPostgresCommand(from paths:[String]) -> String? {
        for path in paths {
            if URL(fileURLWithPath: path).appendingPathComponent("psql").path.isFileExists()
                && URL(fileURLWithPath: path).appendingPathComponent("pg_dump").path.isFileExists()
                && URL(fileURLWithPath: path).appendingPathComponent("createdb").path.isFileExists()
            {
                return path
            }
        }
        return nil
    }
    
    static let instructionForDlibFaceRecognition = """
How to install:
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install python3
brew cask install xquartz
brew install gtk+3 boost
brew install boost-python
pip3 install virtualenv virtualenvwrapper
pip3 install numpy scipy matplotlib scikit-image scikit-learn ipython
brew install dlib
pip3 install imutils
pip3 install opencv-python
brew install cmake
pip3 install face_recognition
"""
    
    static let componentsForDlibFaceRecognition:[String] = ["boost-python", "numpy", "dlib", "imutils", "opencv-python", "face-recognition"]

    func getBackupFolderName(suffix:String, database:String="") -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMdd_HHmmss"
        var db = ""
        if database != "" {
            db = "-\(database)"
        }
        let backupFolder = "DataBackup-\(dateFormat.string(from: Date()))\(db)\(suffix)"
        return backupFolder
    }
    
    func createLocalDatabaseFileBackup(suffix:String) -> (String, Bool, Error?){
        self.logger.log(.trace, "Start to create sqlite db backup")
        var backupFolder = ""
        let dbUrl = URL(fileURLWithPath: Setting.database.databasePath())
        let dbFile = dbUrl.appendingPathComponent("ImageDocker.sqlite")
        let dbFileSHM = dbUrl.appendingPathComponent("ImageDocker.sqlite-shm")
        let dbFileWAL = dbUrl.appendingPathComponent("ImageDocker.sqlite-wal")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: dbFile.path) {
            backupFolder = self.getBackupFolderName(suffix: suffix)
            let backupUrl = dbUrl.appendingPathComponent("DataBackup").appendingPathComponent(backupFolder)
            do{
                try fileManager.createDirectory(at: backupUrl, withIntermediateDirectories: true, attributes: nil)
                
                self.logger.log(.trace, "Backup data to: \(backupUrl.path)")
                try fileManager.copyItem(at: dbFile, to: backupUrl.appendingPathComponent("ImageDocker.sqlite"))
                if fileManager.fileExists(atPath: dbFileSHM.path){
                    try fileManager.copyItem(at: dbFileSHM, to: backupUrl.appendingPathComponent("ImageDocker.sqlite-shm"))
                }
                if fileManager.fileExists(atPath: dbFileWAL.path){
                    try fileManager.copyItem(at: dbFileWAL, to: backupUrl.appendingPathComponent("ImageDocker.sqlite-wal"))
                }
            }catch{
                self.logger.log(.error, error)
                return (backupFolder, false, error)
            }
        }
        self.logger.log(.trace, "Finish create db backup")
        return (backupFolder, true, nil)
    }
    
    func getDatabaseBackupVolume() -> String {
        let dbUrl = URL(fileURLWithPath: Setting.database.databasePath())
        let dbBackupUrl = dbUrl.appendingPathComponent("DataBackup")
        let dbBackupRealUrl = LocalDirectory.bridge.getSymbolicLinkDestination(path: dbBackupUrl.path)
        let dbBackupVolume = LocalDirectory.bridge.getDiskMountPointVolume(path: dbBackupRealUrl)
        return dbBackupVolume
    }
    
    func createDatabaseBackup(profile:DatabaseProfile, suffix:String) -> (String, Bool, Error?) {
        if profile.engine.lowercased() == "postgresql" {
            guard let cmd = DatabaseBackupController.getPostgresCommandPath() else {
                self.logger.log(.error, "Unable to locate pg_dump command in macOS, backup aborted.")
                return ("", false, nil)
            }
            
            let backupPath = URL(fileURLWithPath: Setting.database.databasePath()).appendingPathComponent("DataBackup").path
            
            return PostgresConnection.default.backupDatabase(commandPath: cmd, database: profile.database, host: profile.host, port: profile.port, user: profile.user, backupPath: backupPath, suffix: suffix)
        }else{
            self.logger.log(.trace, "Database location error. backup aborted.")
            return ("", false, nil)
        }
    }
    
    func listDatabaseBackup() -> [String] {
        let backupPath = URL(fileURLWithPath: Setting.database.databasePath()).appendingPathComponent("DataBackup").path
        let cmdline = "cd \(backupPath); ls -l | grep -v total | awk -F' ' '{print $NF}' | sort -r"
        let pipe = Pipe()
        var result:[String] = []
        
        autoreleasepool { () -> Void in
            let cmd = Process()
            cmd.standardOutput = pipe
            cmd.standardError = pipe
            cmd.launchPath = "/bin/bash"
            cmd.arguments = ["-c", cmdline]
            defer {
                cmd.terminate()
            }
            cmd.launch()
            cmd.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let string = String(data: data, encoding: String.Encoding.utf8)!
            pipe.fileHandleForReading.closeFile()
            
            let lines = string.components(separatedBy: "\n")
            
            for line in lines {
                result.append(line)
            }
        }
        return result
    }

}
