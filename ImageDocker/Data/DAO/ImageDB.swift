//
//  DBEngine.swift
//  ImageDocker
//
//  Created by Kelvin Wong on 2020/3/19.
//  Copyright © 2020 nonamecat. All rights reserved.
//
//
//import Foundation
//
//public final class ImageDB {
//    
//    public static let NOTIFICATION_ERROR = "DB_ERROR"
//    
//    let impl:ImageDBInterface
//    
//    /// - caller:
//    ///   - ViewController.doStartWork()
//    static func current() -> ImageDB{
//        return ImageDB(impl: PostgresConnection.default)
//    }
//    
//    private init(impl:ImageDBInterface) {
//        self.impl = impl
//    }
//    
//    func testDatabase() -> (Bool, Error?) {
//        return self.impl.testDatabase()
//    }
//    
//    func versionCheck() {
//        self.impl.versionCheck()
//    }
//    
//}
//
