//
//  DBEngine.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//

import Foundation

public final class ImageDB {
    
    public static let NOTIFICATION_ERROR = "DB_ERROR"
    
    let impl:ImageDBInterface
    
    static let local = ImageDB(impl: PostgresConnection.default)
    
    static let remote = ImageDB(impl: PostgresConnection.default)
    
    /// - caller:
    ///   - ViewController.doStartWork()
    static func current() -> ImageDB{
        if Setting.database.databaseLocation() == "local" {
            return local
        }else{
            return remote
        }
    }
    
    private init(impl:ImageDBInterface) {
        self.impl = impl
    }
    
    func testDatabase() -> (Bool, Error?) {
        return self.impl.testDatabase()
    }
    
    func versionCheck() {
        self.impl.versionCheck()
    }
    
}

